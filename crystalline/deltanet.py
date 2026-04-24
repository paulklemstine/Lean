"""Crystalline DeltaNet layer: tropical adaptation of Gated DeltaNet.

Reference: Qwen3.6-35B-A3B uses Gated DeltaNet with recurrence:
    s_t = Λ_t ⊙ s_{t-1} + k_t v_t^T

Crystalline tropical analogue:
    s_t = min(Λ_t + s_{t-1}, k_t + v_t)   [element-wise tropical ops]

This replaces multiplicative gating with tropical (min-plus) state transitions,
eliminating floating-point multiplications in the recurrence.
"""

import math

import torch
import torch.nn as nn
import torch.nn.functional as F

from .core import tropical_state_update, tropical_dot_product


class CrystallineDeltaLayer(nn.Module):
    """A single Crystalline DeltaNet block using tropical recurrence.

    Args:
        d_model: Model dimension
        num_heads: Number of attention heads
        gate_dim: Dimension of the decay gate (typically d_model // num_heads)
        dropout: Dropout probability
    """

    def __init__(self, d_model: int, num_heads: int = 4, gate_dim: int = None, dropout: float = 0.1):
        super().__init__()
        self.d_model = d_model
        self.num_heads = num_heads
        self.head_dim = d_model // num_heads
        assert self.head_dim * num_heads == d_model, "d_model must be divisible by num_heads"

        self.gate_dim = gate_dim or self.head_dim

        # Projections for Q, K, V, and gate
        self.q_proj = nn.Linear(d_model, d_model, bias=False)
        self.k_proj = nn.Linear(d_model, d_model, bias=False)
        self.v_proj = nn.Linear(d_model, d_model, bias=False)
        self.gate_proj = nn.Linear(d_model, num_heads * self.gate_dim, bias=False)

        # Output projection
        self.out_proj = nn.Linear(d_model, d_model, bias=False)

        self.dropout = nn.Dropout(dropout)
        self.scale = math.sqrt(self.head_dim)

    def forward(self, x: torch.Tensor, mask: torch.Tensor = None) -> torch.Tensor:
        """Forward pass using tropical recurrence.

        Args:
            x: (batch, seq_len, d_model)
            mask: Optional causal mask

        Returns:
            output: (batch, seq_len, d_model)
        """
        B, T, D = x.shape

        # Project to Q, K, V
        Q = self.q_proj(x)  # (B, T, D)
        K = self.k_proj(x)
        V = self.v_proj(x)

        # Reshape to multi-head: (B, T, H, Hd) -> (B, H, T, Hd)
        Q = Q.view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        K = K.view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        V = V.view(B, T, self.num_heads, self.head_dim).transpose(1, 2)

        # Compute decay gates: project to d_model and reshape to (B, H, Hd)
        gates = self.gate_proj(x)
        gates = gates.view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        # Tropical gates should be negative for decay (closer to -inf = stronger decay)
        gates = torch.tanh(gates) * 2.0  # Scale to roughly (-2, 2)

        # Tropical DeltaNet recurrence
        # state: (B, H, Hd) — accumulated context per head
        state = torch.zeros(
            B, self.num_heads, self.head_dim,
            device=x.device, dtype=torch.float32
        )

        outputs = []
        for t in range(T):
            q_t = Q[:, :, t, :]      # (B, H, Hd)
            k_t = K[:, :, t, :]      # (B, H, Hd)
            v_t = V[:, :, t, :]      # (B, H, Hd)
            gate_t = gates[:, :, t, :]  # (B, H, Hd)

            # Tropical update: state = min(gate + state, k_t + v_t)
            # gate + state is tropical multiplication (standard addition)
            # min(..., input_term) is tropical addition
            input_term = k_t + v_t  # tropical "multiplication"
            state = tropical_state_update(state, gate_t, input_term)

            # Output for this timestep: weighted by negative L1 distance
            # Simplified element-wise tropical inner product
            weight = -torch.sum(torch.abs(q_t - state), dim=-1, keepdim=True)
            out_t = weight * v_t
            outputs.append(out_t)

        # Stack outputs: (B, H, T, Hd)
        output = torch.stack(outputs, dim=2)

        # Reshape back: (B, T, D)
        output = output.transpose(1, 2).contiguous().view(B, T, D)
        output = self.out_proj(output)
        output = self.dropout(output)

        return output
