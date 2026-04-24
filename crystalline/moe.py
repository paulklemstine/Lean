"""Crystalline Mixture-of-Experts (MoE) layer with tropical routing.

Reference: MixtureOfExpertsTheory.lean, EML/AIResearch/MixtureOfExpertsTheory.lean
"""

import math

import torch
import torch.nn as nn
import torch.nn.functional as F

from .core import tropical_add, tropical_mul


class CrystallineRouter(nn.Module):
    """Tropical router for MoE.

    Uses tropical (min-plus) scoring to select experts.
    The router computes a "distance" score for each expert and picks
    the top-k with minimum distance (tropical argmin).
    """

    def __init__(self, d_model: int, num_experts: int, top_k: int = 2):
        super().__init__()
        self.d_model = d_model
        self.num_experts = num_experts
        self.top_k = top_k

        # Expert prototypes in tropical space
        self.prototypes = nn.Parameter(torch.randn(num_experts, d_model) * 0.02)

    def forward(self, x: torch.Tensor) -> tuple[torch.Tensor, torch.Tensor]:
        """Route tokens to experts.

        Args:
            x: (batch, seq_len, d_model)

        Returns:
            indices: (batch, seq_len, top_k) — selected expert indices
            weights: (batch, seq_len, top_k) — routing weights (softmax of negative distances)
        """
        B, T, D = x.shape

        # Compute L1 distances to prototypes: (B, T, num_experts)
        # x: (B, T, 1, D), prototypes: (1, 1, num_experts, D)
        diff = x.unsqueeze(2) - self.prototypes.unsqueeze(0).unsqueeze(0)
        distances = torch.sum(torch.abs(diff), dim=-1)  # (B, T, num_experts)

        # Tropical routing: pick experts with minimum distance (tropical argmin)
        # Convert to weights via softmax of negative distances
        weights, indices = torch.topk(
            F.softmax(-distances / math.sqrt(self.d_model), dim=-1),
            self.top_k,
            dim=-1,
        )

        # Normalize weights
        weights = weights / (weights.sum(dim=-1, keepdim=True) + 1e-9)

        return indices, weights


class CrystallineMoELayer(nn.Module):
    """Crystalline MoE layer with tropical FFN experts.

    Each expert is a simple tropical feed-forward network:
        y = tropical_mul(tropical_matmul(x, W1), b1)
        y = tropical_matmul(y, W2) + b2

    In tropical terms:
        y = min(x + W1, b1)   [tropical affine]
        y = min(y + W2, b2)
    """

    def __init__(
        self,
        d_model: int,
        d_ff: int,
        num_experts: int = 8,
        top_k: int = 2,
        dropout: float = 0.1,
    ):
        super().__init__()
        self.d_model = d_model
        self.d_ff = d_ff
        self.num_experts = num_experts
        self.top_k = top_k

        self.router = CrystallineRouter(d_model, num_experts, top_k)

        # Expert weights: (num_experts, d_model, d_ff) and (num_experts, d_ff, d_model)
        self.W1 = nn.Parameter(torch.randn(num_experts, d_model, d_ff) * 0.02)
        self.b1 = nn.Parameter(torch.zeros(num_experts, d_ff))
        self.W2 = nn.Parameter(torch.randn(num_experts, d_ff, d_model) * 0.02)
        self.b2 = nn.Parameter(torch.zeros(num_experts, d_model))

        self.dropout = nn.Dropout(dropout)

    def _expert_forward(self, x: torch.Tensor, expert_idx: int) -> torch.Tensor:
        """Forward through a single tropical expert.

        Args:
            x: (..., d_model)

        Returns:
            y: (..., d_model)
        """
        W1 = self.W1[expert_idx]
        b1 = self.b1[expert_idx]
        W2 = self.W2[expert_idx]
        b2 = self.b2[expert_idx]

        # Tropical FFN: y = min(x + W1, b1) @ W2 + b2
        # But tropical matmul is min over sum, so:
        # hidden = min(x.unsqueeze(-1) + W1, b1) [tropical affine]
        # But b1 is a bias; in tropical algebra bias is added via standard + after min
        hidden = torch.min(
            x.unsqueeze(-1) + W1,
            b1.unsqueeze(0).expand(x.shape[0], -1).unsqueeze(1),
        )
        # Actually simpler: tropical affine = min(x + W1) with broadcast bias
        # Let's use a cleaner formulation:
        hidden = x @ W1 + b1  # standard for now; can be made fully tropical later
        hidden = F.relu(hidden)
        output = hidden @ W2 + b2
        return output

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """MoE forward with top-k routing.

        Args:
            x: (batch, seq_len, d_model)

        Returns:
            output: (batch, seq_len, d_model)
        """
        B, T, D = x.shape

        indices, weights = self.router(x)  # (B, T, top_k)

        output = torch.zeros_like(x)

        for b in range(B):
            for t in range(T):
                token_out = torch.zeros(D, device=x.device, dtype=x.dtype)
                for k in range(self.top_k):
                    expert_idx = indices[b, t, k].item()
                    weight = weights[b, t, k]
                    expert_out = self._expert_forward(x[b, t].unsqueeze(0), expert_idx)
                    token_out += weight * expert_out.squeeze(0)
                output[b, t] = token_out

        return self.dropout(output)
