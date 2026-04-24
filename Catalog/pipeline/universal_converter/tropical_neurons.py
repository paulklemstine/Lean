"""
Tropical & Exotic Neuron Implementations
=========================================

Provides neuron types that replace classical (linear + activation) neurons
with algebraically richer primitives:

  1. **Tropical Neuron** — computes max-plus over inputs:
       y = max_j (w_j + x_j)
     This is a linear function in the (max, +) tropical semiring.

  2. **LogSumExp Neuron** — soft approximation to tropical neuron:
       y = (1/β) * log Σ_j exp(β * (w_j + x_j))
     Recovers the tropical neuron as β → ∞.

  3. **Min-Plus (Dual Tropical) Neuron** — min-plus semiring:
       y = min_j (w_j + x_j)

  4. **OISC (One Instruction Set Computing) Neuron** — a single universal
     instruction (subtract-and-branch-if-negative / SUBLEQ) that can
     emulate any classical neuron when composed.

  5. **Morphological Neuron** — dilation/erosion from mathematical morphology.

All neurons are drop-in replacements for nn.Linear in PyTorch.
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import math
from typing import Optional


class TropicalNeuron(nn.Module):
    """
    Tropical (max-plus) linear layer.

    For input x ∈ ℝ^{in_features}:
        output_i = max_j (W_{ij} + x_j)

    This is an exact linear map in the tropical semiring (ℝ ∪ {-∞}, max, +).
    """

    def __init__(self, in_features: int, out_features: int, bias: bool = True):
        super().__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = nn.Parameter(torch.empty(out_features, in_features))
        if bias:
            self.bias = nn.Parameter(torch.empty(out_features))
        else:
            self.register_parameter("bias", None)
        self.reset_parameters()

    def reset_parameters(self):
        nn.init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in = self.in_features
            bound = 1 / math.sqrt(fan_in)
            nn.init.uniform_(self.bias, -bound, bound)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # W_{ij} + x_j for all i, j  →  shape (batch, out, in)
        expanded = self.weight.unsqueeze(0) + x.unsqueeze(-2)
        out = expanded.max(dim=-1).values  # tropical "matrix multiply"
        if self.bias is not None:
            out = out + self.bias  # tropical bias = additive shift
        return out


class LogSumExpNeuron(nn.Module):
    """
    Smooth (differentiable) approximation to the tropical neuron.

        y_i = (1/β) * log Σ_j exp(β * (W_{ij} + x_j))

    As β → ∞ this converges to max_j(W_{ij} + x_j) (tropical neuron).
    As β → 0 this converges to (1/n) Σ_j (W_{ij} + x_j) (mean, classical).
    β is learnable.
    """

    def __init__(self, in_features: int, out_features: int, beta_init: float = 5.0):
        super().__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = nn.Parameter(torch.empty(out_features, in_features))
        self.bias = nn.Parameter(torch.zeros(out_features))
        # Learnable temperature (log-scale for positivity)
        self.log_beta = nn.Parameter(torch.tensor(math.log(beta_init)))
        self.reset_parameters()

    def reset_parameters(self):
        nn.init.kaiming_uniform_(self.weight, a=math.sqrt(5))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        beta = self.log_beta.exp()
        expanded = self.weight.unsqueeze(0) + x.unsqueeze(-2)
        out = (1.0 / beta) * torch.logsumexp(beta * expanded, dim=-1)
        return out + self.bias


class DualTropicalNeuron(nn.Module):
    """
    Min-plus (dual tropical) neuron:
        y_i = min_j (W_{ij} + x_j)
    """

    def __init__(self, in_features: int, out_features: int, bias: bool = True):
        super().__init__()
        self.weight = nn.Parameter(torch.empty(out_features, in_features))
        self.bias = nn.Parameter(torch.zeros(out_features)) if bias else None
        nn.init.kaiming_uniform_(self.weight, a=math.sqrt(5))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        expanded = self.weight.unsqueeze(0) + x.unsqueeze(-2)
        out = expanded.min(dim=-1).values
        if self.bias is not None:
            out = out + self.bias
        return out


class OISCNeuron(nn.Module):
    """
    One Instruction Set Computing (OISC / SUBLEQ) neuron.

    Emulates classical neurons via a sequence of SUBLEQ micro-ops:
        SUBLEQ a, b, c  →  mem[b] -= mem[a]; if mem[b] ≤ 0 goto c

    For differentiable training we use a soft approximation:
        mem[b] -= mem[a]
        gate = σ(-β * mem[b])  (soft branch)
        output = gate * branch_true + (1 - gate) * branch_false

    A stack of k SUBLEQ ops with learnable addresses can approximate
    any piecewise-linear function (universal computation).
    """

    def __init__(self, in_features: int, out_features: int, n_ops: int = 8,
                 beta: float = 10.0):
        super().__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.n_ops = n_ops
        self.beta = beta

        # For each output neuron, we have n_ops SUBLEQ operations
        # Each op has learnable source weights and accumulation weights
        self.source_weights = nn.Parameter(
            torch.randn(out_features, n_ops, in_features) * 0.1
        )
        self.accum_weights = nn.Parameter(
            torch.randn(out_features, n_ops, in_features) * 0.1
        )
        self.gate_bias = nn.Parameter(torch.zeros(out_features, n_ops))
        self.output_proj = nn.Linear(n_ops, 1, bias=True)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        batch = x.shape[0]
        # Source: weighted combination of inputs  (batch, out, n_ops)
        src = torch.einsum("bi,oqi->boq", x, self.source_weights)
        acc = torch.einsum("bi,oqi->boq", x, self.accum_weights)

        # SUBLEQ: acc -= src, then soft gate
        diff = acc - src
        gate = torch.sigmoid(-self.beta * (diff + self.gate_bias))

        # Aggregate gated results
        out = self.output_proj(gate).squeeze(-1)  # (batch, out)
        return out


class MorphologicalNeuron(nn.Module):
    """
    Morphological (dilation / erosion) neuron from mathematical morphology.

    Dilation:  y_i = max_j (W_{ij} + x_j)  (same as tropical)
    Erosion:   y_i = min_j (W_{ij} - x_j)  (dual)

    Combined (hit-or-miss): y = α * dilation + (1-α) * erosion
    where α is learnable per output.
    """

    def __init__(self, in_features: int, out_features: int):
        super().__init__()
        self.dilation = TropicalNeuron(in_features, out_features, bias=False)
        self.erosion_weight = nn.Parameter(torch.empty(out_features, in_features))
        self.alpha = nn.Parameter(torch.full((out_features,), 0.5))
        self.bias = nn.Parameter(torch.zeros(out_features))
        nn.init.kaiming_uniform_(self.erosion_weight, a=math.sqrt(5))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        dil = self.dilation(x)
        # Erosion: min_j(W_{ij} - x_j)
        ero = (self.erosion_weight.unsqueeze(0) - x.unsqueeze(-2)).min(dim=-1).values
        a = torch.sigmoid(self.alpha)
        return a * dil + (1 - a) * ero + self.bias


class ExoticNeuronFactory:
    """Factory for creating exotic neuron layers from configuration."""

    REGISTRY = {
        "tropical": TropicalNeuron,
        "logsumexp": LogSumExpNeuron,
        "dual_tropical": DualTropicalNeuron,
        "oisc": OISCNeuron,
        "morphological": MorphologicalNeuron,
    }

    @classmethod
    def create(cls, neuron_type: str, in_features: int, out_features: int,
               **kwargs) -> nn.Module:
        if neuron_type not in cls.REGISTRY:
            raise ValueError(
                f"Unknown neuron type '{neuron_type}'. "
                f"Available: {list(cls.REGISTRY.keys())}"
            )
        return cls.REGISTRY[neuron_type](in_features, out_features, **kwargs)

    @classmethod
    def available(cls):
        return list(cls.REGISTRY.keys())
