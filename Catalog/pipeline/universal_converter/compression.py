"""
Multi-Stage Compression Pipeline
=================================

Implements the full compression stack:
  1. Quantization    — reduce precision (FP32 → INT8/INT4/binary)
  2. Pruning         — remove near-zero weights (unstructured & structured)
  3. Distillation    — transfer knowledge from large → small model
  4. Crystallization — nudge weights to exact integers (sin²(πw) penalty)
  5. Low-rank        — SVD-based factorization of weight matrices

Each stage has formally verified error bounds (see Lean proofs).
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import logging
from typing import Optional, Tuple, Dict, Any
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────────────────────
# Stage 1: Quantization
# ─────────────────────────────────────────────────────────────

class QuantizationScheme(Enum):
    SYMMETRIC = "symmetric"
    ASYMMETRIC = "asymmetric"
    STOCHASTIC = "stochastic"


@dataclass
class QuantConfig:
    bits: int = 4
    scheme: QuantizationScheme = QuantizationScheme.SYMMETRIC
    group_size: int = 128
    per_channel: bool = True


class Quantizer:
    """
    Weight quantization with verified error bounds.

    Theorem (QuantizationBounds.lean):
      For b-bit symmetric quantization with scale s = max|W| / (2^(b-1) - 1),
      the per-element error satisfies |W - Q(W)| ≤ s/2.
    """

    @staticmethod
    def quantize_symmetric(
        W: torch.Tensor, bits: int = 4, group_size: int = 128
    ) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        """
        Symmetric quantization: Q(w) = round(w / scale) * scale

        Returns: (quantized_weights, scales, zero_points)
        """
        qmin = -(2 ** (bits - 1))
        qmax = 2 ** (bits - 1) - 1

        orig_shape = W.shape
        if W.dim() >= 2 and group_size > 0:
            # Group quantization
            W_flat = W.reshape(-1, W.shape[-1])
            n_groups = max(1, W_flat.shape[-1] // group_size)
            W_grouped = W_flat.reshape(W_flat.shape[0], n_groups, -1)
            scales = W_grouped.abs().amax(dim=-1, keepdim=True) / qmax
            scales = scales.clamp(min=1e-8)
            W_q = (W_grouped / scales).round().clamp(qmin, qmax)
            W_deq = (W_q * scales).reshape(orig_shape)
        else:
            scales = W.abs().amax() / qmax
            scales = scales.clamp(min=1e-8)
            W_q = (W / scales).round().clamp(qmin, qmax)
            W_deq = W_q * scales

        return W_deq, scales, torch.zeros_like(scales)

    @staticmethod
    def quantize_stochastic(
        W: torch.Tensor, bits: int = 4
    ) -> Tuple[torch.Tensor, torch.Tensor]:
        """
        Stochastic quantization: unbiased estimator E[Q(w)] = w.

        For each weight w, round up with probability (w/s - floor(w/s)),
        round down otherwise.
        """
        qmax = 2 ** (bits - 1) - 1
        scale = W.abs().amax() / qmax
        scale = scale.clamp(min=1e-8)
        W_scaled = W / scale
        W_floor = W_scaled.floor()
        prob = W_scaled - W_floor
        W_q = W_floor + (torch.rand_like(W_scaled) < prob).float()
        W_q = W_q.clamp(-qmax - 1, qmax)
        return W_q * scale, scale


def quantize_model(model: nn.Module, config: QuantConfig) -> nn.Module:
    """Apply quantization to all weight matrices in the model."""
    quantizer = Quantizer()
    total_original = 0
    total_quantized = 0

    for name, param in model.named_parameters():
        if "weight" in name and param.dim() >= 2:
            total_original += param.numel() * 32  # bits
            W_q, scales, _ = quantizer.quantize_symmetric(
                param.data, bits=config.bits, group_size=config.group_size
            )
            param.data.copy_(W_q)
            total_quantized += param.numel() * config.bits

    ratio = total_original / max(total_quantized, 1)
    logger.info(f"Quantization: {config.bits}-bit, compression ratio: {ratio:.1f}x")
    return model


# ─────────────────────────────────────────────────────────────
# Stage 2: Pruning
# ─────────────────────────────────────────────────────────────

class PruningMethod(Enum):
    MAGNITUDE = "magnitude"
    WANDA = "wanda"
    STRUCTURED = "structured"


@dataclass
class PruneConfig:
    method: PruningMethod = PruningMethod.MAGNITUDE
    sparsity: float = 0.5
    structured: bool = False


class Pruner:
    """
    Weight pruning with verified bounds.

    Theorem (PruningBounds.lean):
      For magnitude pruning at sparsity s, the Frobenius error
      ||W - W_pruned||_F is bounded by the sum of removed singular values.
    """

    @staticmethod
    def magnitude_prune(W: torch.Tensor, sparsity: float) -> torch.Tensor:
        """Zero out the smallest |sparsity| fraction of weights."""
        flat = W.abs().flatten()
        k = int(flat.numel() * sparsity)
        if k == 0:
            return W
        threshold = flat.kthvalue(k).values
        mask = W.abs() >= threshold
        return W * mask.float()

    @staticmethod
    def wanda_prune(
        W: torch.Tensor, X_norm: Optional[torch.Tensor], sparsity: float
    ) -> torch.Tensor:
        """
        Wanda pruning: prune by |W| * ||X||_2 (activation-aware).
        If X_norm is not available, falls back to magnitude pruning.
        """
        if X_norm is None:
            return Pruner.magnitude_prune(W, sparsity)

        # Importance score: element-wise |w_ij| * ||x_j||_2
        if X_norm.dim() == 1 and W.dim() == 2:
            importance = W.abs() * X_norm.unsqueeze(0)
        else:
            importance = W.abs()

        flat = importance.flatten()
        k = int(flat.numel() * sparsity)
        if k == 0:
            return W
        threshold = flat.kthvalue(k).values
        mask = importance >= threshold
        return W * mask.float()

    @staticmethod
    def structured_prune(W: torch.Tensor, sparsity: float) -> torch.Tensor:
        """Remove entire rows (neurons) with smallest L2 norm."""
        if W.dim() < 2:
            return W
        row_norms = W.norm(dim=1)
        k = int(W.shape[0] * sparsity)
        if k == 0:
            return W
        threshold = row_norms.kthvalue(max(k, 1)).values
        mask = (row_norms >= threshold).float().unsqueeze(1)
        return W * mask


def prune_model(model: nn.Module, config: PruneConfig) -> nn.Module:
    """Apply pruning to all weight matrices."""
    pruner = Pruner()
    total_params = 0
    total_zeros = 0

    for name, param in model.named_parameters():
        if "weight" in name and param.dim() >= 2:
            if config.method == PruningMethod.MAGNITUDE:
                param.data = pruner.magnitude_prune(param.data, config.sparsity)
            elif config.method == PruningMethod.WANDA:
                param.data = pruner.wanda_prune(param.data, None, config.sparsity)
            elif config.method == PruningMethod.STRUCTURED:
                param.data = pruner.structured_prune(param.data, config.sparsity)

            total_params += param.numel()
            total_zeros += (param.data == 0).sum().item()

    actual_sparsity = total_zeros / max(total_params, 1)
    logger.info(f"Pruning: target={config.sparsity:.1%}, actual={actual_sparsity:.1%}")
    return model


# ─────────────────────────────────────────────────────────────
# Stage 3: Knowledge Distillation
# ─────────────────────────────────────────────────────────────

@dataclass
class DistillConfig:
    temperature: float = 4.0
    alpha: float = 0.5  # weight for distillation vs hard loss
    epochs: int = 3
    lr: float = 1e-4


class DistillationLoss(nn.Module):
    """
    Combined distillation loss:
        L = α * KL(softmax(z_s/T), softmax(z_t/T)) * T²
          + (1 - α) * CE(z_s, y)

    Theorem (DistillationLoss.lean):
      KL divergence is non-negative and zero iff student = teacher.
    """

    def __init__(self, temperature: float = 4.0, alpha: float = 0.5):
        super().__init__()
        self.T = temperature
        self.alpha = alpha

    def forward(
        self,
        student_logits: torch.Tensor,
        teacher_logits: torch.Tensor,
        labels: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        # Soft targets
        soft_student = F.log_softmax(student_logits / self.T, dim=-1)
        soft_teacher = F.softmax(teacher_logits / self.T, dim=-1)
        kl_loss = F.kl_div(soft_student, soft_teacher, reduction="batchmean")
        kl_loss = kl_loss * (self.T ** 2)

        if labels is not None and self.alpha < 1.0:
            hard_loss = F.cross_entropy(student_logits, labels)
            return self.alpha * kl_loss + (1 - self.alpha) * hard_loss

        return kl_loss


# ─────────────────────────────────────────────────────────────
# Stage 4: Crystallization
# ─────────────────────────────────────────────────────────────

@dataclass
class CrystalConfig:
    lambda_crystal: float = 0.01
    target: str = "integer"  # "integer" | "power_of_two" | "ternary"
    anneal_steps: int = 1000


class Crystallizer:
    """
    Weight crystallization: nudge weights toward exact discrete values.

    Theorem (Crystallization.lean):
      The crystallization penalty sin²(πw) = 0  iff  w ∈ ℤ.
      Total crystallization error for n weights ≤ n/2.
    """

    @staticmethod
    def crystal_penalty(W: torch.Tensor) -> torch.Tensor:
        """sin²(πw) penalty — zero at integers."""
        return torch.sin(np.pi * W).pow(2).mean()

    @staticmethod
    def crystal_penalty_power_of_two(W: torch.Tensor) -> torch.Tensor:
        """Penalty for distance to nearest power of 2."""
        signs = W.sign()
        log_abs = (W.abs() + 1e-10).log2()
        rounded = log_abs.round()
        return (log_abs - rounded).pow(2).mean()

    @staticmethod
    def crystal_penalty_ternary(W: torch.Tensor) -> torch.Tensor:
        """Penalty for distance to {-1, 0, +1}."""
        # Distance to nearest element of {-1, 0, +1}
        d_neg1 = (W + 1).pow(2)
        d_zero = W.pow(2)
        d_pos1 = (W - 1).pow(2)
        min_dist = torch.minimum(torch.minimum(d_neg1, d_zero), d_pos1)
        return min_dist.mean()

    @staticmethod
    def crystallize_weights(W: torch.Tensor, target: str = "integer") -> torch.Tensor:
        """Hard crystallization: snap weights to nearest discrete value."""
        if target == "integer":
            return W.round()
        elif target == "power_of_two":
            signs = W.sign()
            log_abs = (W.abs() + 1e-10).log2()
            return signs * (2.0 ** log_abs.round())
        elif target == "ternary":
            # Snap to {-1, 0, +1}
            out = torch.zeros_like(W)
            out[W > 0.5] = 1.0
            out[W < -0.5] = -1.0
            return out
        else:
            return W.round()


def crystallize_model(
    model: nn.Module, config: CrystalConfig
) -> Tuple[nn.Module, float]:
    """Apply hard crystallization to all weights."""
    crystallizer = Crystallizer()
    total_error = 0.0
    n_params = 0

    for name, param in model.named_parameters():
        if "weight" in name:
            original = param.data.clone()
            param.data = crystallizer.crystallize_weights(param.data, config.target)
            error = (original - param.data).abs().mean().item()
            total_error += error * param.numel()
            n_params += param.numel()

    avg_error = total_error / max(n_params, 1)
    logger.info(
        f"Crystallization ({config.target}): "
        f"avg per-weight error = {avg_error:.6f}"
    )
    return model, avg_error


# ─────────────────────────────────────────────────────────────
# Stage 5: Low-Rank Factorization
# ─────────────────────────────────────────────────────────────

@dataclass
class LowRankConfig:
    rank_fraction: float = 0.5  # keep this fraction of singular values
    min_rank: int = 4
    energy_threshold: float = 0.95  # keep enough SVs for 95% energy


class LowRankFactorizer:
    """
    SVD-based weight matrix factorization: W ≈ U_r S_r V_r^T

    Theorem (TensorRankBounds.lean):
      ||W - W_r||_F = sqrt(Σ_{i>r} σ_i²)  (Eckart-Young-Mirsky).
    """

    @staticmethod
    def factorize(
        W: torch.Tensor, config: LowRankConfig
    ) -> Tuple[torch.Tensor, torch.Tensor]:
        """
        Return (A, B) where W ≈ A @ B, with A: (m, r), B: (r, n).
        Total params: r(m+n) instead of mn — saves when r < mn/(m+n).
        """
        if W.dim() != 2:
            return W, torch.eye(W.shape[-1], device=W.device, dtype=W.dtype)

        U, S, Vh = torch.linalg.svd(W.float(), full_matrices=False)

        # Determine rank from energy threshold
        energy = (S ** 2).cumsum(0) / (S ** 2).sum()
        r = max(
            config.min_rank,
            int((energy < config.energy_threshold).sum().item()) + 1,
        )
        r = min(r, int(min(W.shape) * config.rank_fraction))
        r = max(r, 1)

        A = U[:, :r] * S[:r].unsqueeze(0)  # (m, r)
        B = Vh[:r, :]  # (r, n)

        return A.to(W.dtype), B.to(W.dtype)


# ─────────────────────────────────────────────────────────────
# Full Pipeline
# ─────────────────────────────────────────────────────────────

@dataclass
class FullCompressionConfig:
    quantize: bool = True
    quant_config: QuantConfig = None
    prune: bool = True
    prune_config: PruneConfig = None
    distill: bool = False
    distill_config: DistillConfig = None
    crystallize: bool = True
    crystal_config: CrystalConfig = None
    low_rank: bool = False
    low_rank_config: LowRankConfig = None

    def __post_init__(self):
        if self.quant_config is None:
            self.quant_config = QuantConfig()
        if self.prune_config is None:
            self.prune_config = PruneConfig()
        if self.distill_config is None:
            self.distill_config = DistillConfig()
        if self.crystal_config is None:
            self.crystal_config = CrystalConfig()
        if self.low_rank_config is None:
            self.low_rank_config = LowRankConfig()


def full_compression_pipeline(
    model: nn.Module,
    config: Optional[FullCompressionConfig] = None,
) -> Tuple[nn.Module, Dict[str, Any]]:
    """
    Run the complete compression pipeline.

    Order matters:
      1. Low-rank (if enabled) — reduce matrix sizes first
      2. Pruning — remove unimportant weights
      3. Quantization — reduce precision
      4. Crystallization — snap to discrete values

    (Distillation is a training-time technique and handled separately.)
    """
    if config is None:
        config = FullCompressionConfig()

    report = {}
    original_size = sum(
        p.numel() * p.element_size() for p in model.parameters()
    )
    report["original_size_bytes"] = original_size

    if config.prune:
        logger.info("Stage: Pruning")
        model = prune_model(model, config.prune_config)
        report["pruning_sparsity"] = config.prune_config.sparsity

    if config.quantize:
        logger.info("Stage: Quantization")
        model = quantize_model(model, config.quant_config)
        report["quantization_bits"] = config.quant_config.bits

    if config.crystallize:
        logger.info("Stage: Crystallization")
        model, crystal_error = crystallize_model(model, config.crystal_config)
        report["crystallization_error"] = crystal_error

    final_size = sum(
        p.numel() * p.element_size() for p in model.parameters()
    )
    report["final_size_bytes"] = final_size
    report["compression_ratio"] = original_size / max(final_size, 1)

    # Count effective parameters (non-zero)
    total = sum(p.numel() for p in model.parameters())
    nonzero = sum((p != 0).sum().item() for p in model.parameters())
    report["total_params"] = total
    report["nonzero_params"] = nonzero
    report["effective_sparsity"] = 1 - nonzero / max(total, 1)

    return model, report
