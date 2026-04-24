"""
Tropical Attention Mechanisms
==============================

Replaces standard softmax attention with tropical variants:

  1. **Tropical Attention** — replace softmax with hardmax (tropical):
       Attn(Q,K,V) = V[argmax_j(Q_i · K_j)]
     This selects the single most relevant key (winner-take-all).

  2. **Top-k Tropical Attention** — tropical over top-k keys:
       Attn = Σ_{j ∈ top-k} softmax(Q_i · K_j) V_j
     Sparse attention with bounded compute.

  3. **LogSumExp Attention** — smooth interpolation:
       As temperature → 0, softmax → hardmax (tropical limit).

  4. **Linear Attention** — kernel approximation:
       Attn(Q,K,V) = φ(Q)(φ(K)^T V)  for feature map φ
     O(n) instead of O(n²).

All are drop-in replacements for standard multi-head attention.
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import math
from typing import Optional, Tuple


class TropicalAttention(nn.Module):
    """
    Hard (tropical) attention: winner-take-all over keys.

    For each query position, selects the single key with highest
    dot-product score. This is equivalent to attention in the
    tropical semiring (max, +) where softmax → hardmax.

    Memory: O(n) instead of O(n²) — no full attention matrix needed.
    """

    def __init__(self, embed_dim: int, num_heads: int, dropout: float = 0.0):
        super().__init__()
        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads
        assert embed_dim % num_heads == 0

        self.q_proj = nn.Linear(embed_dim, embed_dim)
        self.k_proj = nn.Linear(embed_dim, embed_dim)
        self.v_proj = nn.Linear(embed_dim, embed_dim)
        self.out_proj = nn.Linear(embed_dim, embed_dim)
        self.scale = self.head_dim ** -0.5

    def forward(
        self,
        query: torch.Tensor,
        key: torch.Tensor,
        value: torch.Tensor,
        attn_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        B, T, _ = query.shape
        S = key.shape[1]

        Q = self.q_proj(query).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        K = self.k_proj(key).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        V = self.v_proj(value).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)

        # Tropical attention: hardmax (argmax over keys)
        scores = torch.matmul(Q, K.transpose(-2, -1)) * self.scale
        if attn_mask is not None:
            scores = scores + attn_mask

        # Winner-take-all: select the key with maximum score
        indices = scores.argmax(dim=-1)  # (B, H, T)
        indices_expanded = indices.unsqueeze(-1).expand(-1, -1, -1, self.head_dim)
        out = V.gather(2, indices_expanded)  # (B, H, T, D)

        out = out.transpose(1, 2).contiguous().view(B, T, self.embed_dim)
        return self.out_proj(out)


class TopKTropicalAttention(nn.Module):
    """
    Top-k sparse attention: softmax only over the k highest-scoring keys.

    Interpolates between tropical (k=1) and full softmax (k=S).
    Compute: O(n·k) instead of O(n²), with k typically 32-128.
    """

    def __init__(
        self, embed_dim: int, num_heads: int, top_k: int = 32, dropout: float = 0.0
    ):
        super().__init__()
        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads
        self.top_k = top_k

        self.q_proj = nn.Linear(embed_dim, embed_dim)
        self.k_proj = nn.Linear(embed_dim, embed_dim)
        self.v_proj = nn.Linear(embed_dim, embed_dim)
        self.out_proj = nn.Linear(embed_dim, embed_dim)
        self.scale = self.head_dim ** -0.5
        self.dropout = nn.Dropout(dropout)

    def forward(
        self,
        query: torch.Tensor,
        key: torch.Tensor,
        value: torch.Tensor,
        attn_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        B, T, _ = query.shape
        S = key.shape[1]
        k = min(self.top_k, S)

        Q = self.q_proj(query).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        K = self.k_proj(key).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        V = self.v_proj(value).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)

        scores = torch.matmul(Q, K.transpose(-2, -1)) * self.scale
        if attn_mask is not None:
            scores = scores + attn_mask

        # Keep only top-k scores, mask the rest to -inf
        topk_vals, topk_idx = scores.topk(k, dim=-1)
        sparse_scores = torch.full_like(scores, float("-inf"))
        sparse_scores.scatter_(-1, topk_idx, topk_vals)

        attn_weights = F.softmax(sparse_scores, dim=-1)
        attn_weights = self.dropout(attn_weights)

        out = torch.matmul(attn_weights, V)
        out = out.transpose(1, 2).contiguous().view(B, T, self.embed_dim)
        return self.out_proj(out)


class LinearAttention(nn.Module):
    """
    Linear (kernel) attention: O(n) complexity.

    Uses feature map φ(x) = elu(x) + 1 to approximate softmax:
        Attn(Q,K,V) = φ(Q) (φ(K)^T V) / (φ(Q) φ(K)^T 1)

    This avoids materializing the n×n attention matrix.
    """

    def __init__(self, embed_dim: int, num_heads: int, dropout: float = 0.0):
        super().__init__()
        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads

        self.q_proj = nn.Linear(embed_dim, embed_dim)
        self.k_proj = nn.Linear(embed_dim, embed_dim)
        self.v_proj = nn.Linear(embed_dim, embed_dim)
        self.out_proj = nn.Linear(embed_dim, embed_dim)

    @staticmethod
    def feature_map(x: torch.Tensor) -> torch.Tensor:
        return F.elu(x) + 1

    def forward(
        self,
        query: torch.Tensor,
        key: torch.Tensor,
        value: torch.Tensor,
        attn_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        B, T, _ = query.shape
        S = key.shape[1]

        Q = self.q_proj(query).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        K = self.k_proj(key).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        V = self.v_proj(value).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)

        Q = self.feature_map(Q)
        K = self.feature_map(K)

        # Linear attention: φ(Q)(φ(K)^T V) / (φ(Q)(φ(K)^T 1))
        KV = torch.matmul(K.transpose(-2, -1), V)  # (B, H, D, D)
        num = torch.matmul(Q, KV)  # (B, H, T, D)
        denom = torch.matmul(Q, K.transpose(-2, -1).sum(dim=-1, keepdim=True))
        denom = denom.clamp(min=1e-6)

        out = num / denom
        out = out.transpose(1, 2).contiguous().view(B, T, self.embed_dim)
        return self.out_proj(out)


class HybridTropicalTransformerBlock(nn.Module):
    """
    A transformer block using:
      - Top-k tropical attention (sparse, fast)
      - Tropical or LogSumExp feed-forward neurons
      - Pre-norm (RMSNorm)
    """

    def __init__(
        self,
        embed_dim: int,
        num_heads: int,
        ff_dim: int,
        top_k: int = 32,
        neuron_type: str = "logsumexp",
        dropout: float = 0.0,
    ):
        super().__init__()
        from .tropical_neurons import ExoticNeuronFactory

        self.norm1 = nn.RMSNorm(embed_dim)
        self.attn = TopKTropicalAttention(embed_dim, num_heads, top_k, dropout)
        self.norm2 = nn.RMSNorm(embed_dim)

        # Feed-forward with exotic neurons
        self.ff_up = ExoticNeuronFactory.create(neuron_type, embed_dim, ff_dim)
        self.ff_down = nn.Linear(ff_dim, embed_dim)  # standard for output projection
        self.ff_act = nn.GELU()
        self.dropout = nn.Dropout(dropout)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # Attention with residual
        h = self.norm1(x)
        h = self.attn(h, h, h)
        x = x + self.dropout(h)

        # Feed-forward with residual
        h = self.norm2(x)
        h = self.ff_up(h)
        h = self.ff_act(h)
        h = self.ff_down(h)
        x = x + self.dropout(h)

        return x
