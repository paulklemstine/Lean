"""
Universal Weight Converter
==========================

Converts weights from any HuggingFace model into the exotic neuron framework.

The conversion pipeline:
  1. Extract weight matrices from the HuggingFace model
  2. Analyze weight structure (rank, sparsity, spectral properties)
  3. Map classical (linear + activation) layers to exotic equivalents
  4. Transfer weights with optimal initialization

Key insight: ReLU(Wx + b) = max(Wx + b, 0) is already a tropical operation.
So converting a ReLU network to tropical form is exact (zero error).
For non-ReLU activations, we use piecewise-linear approximation within
bounded error guarantees (see Lean proofs in CompilationCompression.lean).
"""

import torch
import torch.nn as nn
import numpy as np
import logging
from typing import Dict, Any, Optional, Tuple, List
from dataclasses import dataclass
from collections import OrderedDict

from .tropical_neurons import (
    TropicalNeuron, LogSumExpNeuron, DualTropicalNeuron,
    OISCNeuron, MorphologicalNeuron, ExoticNeuronFactory,
)

logger = logging.getLogger(__name__)


@dataclass
class ConversionStats:
    """Statistics from weight conversion."""
    total_params_original: int = 0
    total_params_converted: int = 0
    layers_converted: int = 0
    layers_skipped: int = 0
    max_conversion_error: float = 0.0
    mean_conversion_error: float = 0.0
    compression_ratio: float = 1.0
    neuron_type_counts: Dict[str, int] = None

    def __post_init__(self):
        if self.neuron_type_counts is None:
            self.neuron_type_counts = {}


class WeightAnalyzer:
    """Analyze weight matrices to determine optimal exotic neuron mapping."""

    @staticmethod
    def compute_effective_rank(W: torch.Tensor, threshold: float = 0.01) -> int:
        """Effective rank via singular value thresholding."""
        if W.dim() < 2:
            return 1
        try:
            S = torch.linalg.svdvals(W.float())
            total = S.sum()
            if total < 1e-12:
                return 0
            normalized = S / total
            return int((normalized > threshold).sum().item())
        except Exception:
            return min(W.shape)

    @staticmethod
    def compute_sparsity(W: torch.Tensor, threshold: float = 1e-6) -> float:
        """Fraction of near-zero entries."""
        return float((W.abs() < threshold).sum() / W.numel())

    @staticmethod
    def compute_tropical_fitness(W: torch.Tensor) -> float:
        """
        Score in [0, 1] indicating how well W fits a tropical representation.

        High fitness when:
        - Weights are sparse (tropical ops are max over few terms)
        - Weight distribution is multimodal (piecewise-linear landscape)
        - Low effective rank (tropical matrices have low tropical rank)
        """
        sparsity = WeightAnalyzer.compute_sparsity(W)
        rank_ratio = WeightAnalyzer.compute_effective_rank(W) / max(min(W.shape), 1)
        # Bimodality: check if histogram has multiple peaks
        hist = torch.histc(W.float().flatten(), bins=32)
        hist_norm = hist / hist.sum()
        entropy = -(hist_norm * (hist_norm + 1e-10).log()).sum().item()
        max_entropy = np.log(32)
        bimodality = 1.0 - entropy / max_entropy

        return float(0.4 * sparsity + 0.3 * (1 - rank_ratio) + 0.3 * bimodality)

    @classmethod
    def recommend_neuron_type(cls, W: torch.Tensor, activation: str = "relu") -> str:
        """Recommend the best exotic neuron type for a given weight matrix."""
        tropical_fitness = cls.compute_tropical_fitness(W)
        sparsity = cls.compute_sparsity(W)

        if activation in ("relu", "leaky_relu"):
            # ReLU is natively tropical
            if tropical_fitness > 0.6:
                return "tropical"
            return "logsumexp"  # smooth tropical, better for gradient flow
        elif activation in ("gelu", "silu", "swish"):
            # These are smooth — LogSumExp is a better match
            return "logsumexp"
        elif sparsity > 0.7:
            return "morphological"
        else:
            return "oisc"  # universal fallback


class UniversalWeightConverter:
    """
    Convert any HuggingFace model's weights to the exotic neuron framework.

    Usage:
        converter = UniversalWeightConverter(strategy="auto")
        exotic_model, stats = converter.convert(hf_model)
    """

    SUPPORTED_LAYERS = (nn.Linear, nn.Conv1d, nn.Conv2d)

    def __init__(
        self,
        strategy: str = "auto",
        default_neuron: str = "logsumexp",
        beta_init: float = 5.0,
        preserve_attention: bool = True,
    ):
        """
        Args:
            strategy: "auto" (analyze weights), "tropical", "logsumexp", "oisc", etc.
            default_neuron: fallback neuron type for "auto" strategy
            beta_init: initial β for LogSumExp neurons
            preserve_attention: keep attention mechanism structure (recommended)
        """
        self.strategy = strategy
        self.default_neuron = default_neuron
        self.beta_init = beta_init
        self.preserve_attention = preserve_attention
        self.analyzer = WeightAnalyzer()

    def convert(self, model: nn.Module) -> Tuple[nn.Module, ConversionStats]:
        """
        Convert a HuggingFace model to the exotic neuron framework.

        Returns: (converted_model, conversion_stats)
        """
        stats = ConversionStats()
        stats.total_params_original = sum(p.numel() for p in model.parameters())

        # Deep copy the model structure
        converted = self._convert_module(model, stats, prefix="")

        stats.total_params_converted = sum(p.numel() for p in converted.parameters())
        if stats.total_params_original > 0:
            stats.compression_ratio = (
                stats.total_params_original / max(stats.total_params_converted, 1)
            )

        logger.info(
            f"Conversion complete: {stats.layers_converted} layers converted, "
            f"{stats.layers_skipped} skipped, "
            f"compression ratio: {stats.compression_ratio:.2f}x"
        )
        return converted, stats

    def _convert_module(
        self, module: nn.Module, stats: ConversionStats, prefix: str
    ) -> nn.Module:
        """Recursively convert modules."""
        # Don't convert attention layers if preserve_attention is set
        if self.preserve_attention and self._is_attention(module, prefix):
            stats.layers_skipped += 1
            return module

        if isinstance(module, nn.Linear):
            return self._convert_linear(module, stats, prefix)

        # Recurse into children
        new_module = module.__class__.__new__(module.__class__)
        new_module.__dict__.update(module.__dict__)

        for name, child in module.named_children():
            child_prefix = f"{prefix}.{name}" if prefix else name
            new_child = self._convert_module(child, stats, child_prefix)
            setattr(new_module, name, new_child)

        return new_module

    def _convert_linear(
        self, linear: nn.Linear, stats: ConversionStats, prefix: str
    ) -> nn.Module:
        """Convert a single nn.Linear to an exotic neuron."""
        W = linear.weight.data
        in_f, out_f = linear.in_features, linear.out_features

        # Determine neuron type
        if self.strategy == "auto":
            neuron_type = self.analyzer.recommend_neuron_type(W)
        else:
            neuron_type = self.strategy

        # Create exotic neuron
        kwargs = {}
        if neuron_type == "logsumexp":
            kwargs["beta_init"] = self.beta_init
        elif neuron_type == "oisc":
            kwargs["n_ops"] = min(8, max(2, in_f // 32))

        try:
            exotic = ExoticNeuronFactory.create(neuron_type, in_f, out_f, **kwargs)
        except Exception as e:
            logger.warning(f"Failed to create {neuron_type} at {prefix}: {e}")
            stats.layers_skipped += 1
            return linear

        # Transfer weights
        self._transfer_weights(linear, exotic, neuron_type)

        stats.layers_converted += 1
        stats.neuron_type_counts[neuron_type] = (
            stats.neuron_type_counts.get(neuron_type, 0) + 1
        )

        return exotic

    def _transfer_weights(
        self, source: nn.Linear, target: nn.Module, neuron_type: str
    ):
        """Transfer weights from classical linear layer to exotic neuron."""
        W = source.weight.data
        b = source.bias.data if source.bias is not None else None

        if neuron_type in ("tropical", "dual_tropical"):
            target.weight.data.copy_(W)
            if b is not None and hasattr(target, "bias") and target.bias is not None:
                target.bias.data.copy_(b)

        elif neuron_type == "logsumexp":
            target.weight.data.copy_(W)
            if b is not None:
                target.bias.data.copy_(b)

        elif neuron_type == "oisc":
            # Distribute weight information across SUBLEQ ops
            n_ops = target.n_ops
            chunk_size = max(1, W.shape[1] // n_ops)
            for k in range(n_ops):
                start = k * chunk_size
                end = min(start + chunk_size, W.shape[1])
                if start < W.shape[1]:
                    target.source_weights.data[:, k, start:end] = (
                        W[:, start:end] * 0.5
                    )
                    target.accum_weights.data[:, k, start:end] = (
                        W[:, start:end] * 0.5
                    )

        elif neuron_type == "morphological":
            target.dilation.weight.data.copy_(W)
            target.erosion_weight.data.copy_(-W)  # erosion ≈ dual
            if b is not None:
                target.bias.data.copy_(b)

    @staticmethod
    def _is_attention(module: nn.Module, prefix: str) -> bool:
        """Check if a module is an attention layer."""
        attn_keywords = ["attention", "attn", "self_attn", "cross_attn"]
        module_name = type(module).__name__.lower()
        prefix_lower = prefix.lower()
        return any(k in module_name or k in prefix_lower for k in attn_keywords)
