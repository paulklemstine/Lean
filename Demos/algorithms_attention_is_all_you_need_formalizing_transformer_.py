#!/usr/bin/env python3
"""
Transformer Architecture: Type-Hinted Algorithm Implementations

Implements the mathematical components of the transformer architecture
as defined in the Lean formalization, with full type annotations.
"""

from dataclasses import dataclass
from typing import Callable
import numpy as np
from numpy.typing import NDArray


# Type aliases
Vec = NDArray[np.float64]
Mat = NDArray[np.float64]


def softmax_vec(x: Vec) -> Vec:
    """Softmax function: maps ℝⁿ → Δⁿ⁻¹ (probability simplex).

    Properties (formally proved):
    - Shift invariant: softmax(x + c·1) = softmax(x)
    - Sum to one: ∑ᵢ softmax(x)ᵢ = 1
    - Positive: softmax(x)ᵢ > 0
    - Monotone: xᵢ ≤ xⱼ ⟹ softmax(x)ᵢ ≤ softmax(x)ⱼ
    """
    # Shift by max for numerical stability (exact by shift invariance theorem)
    x_shifted = x - np.max(x)
    exp_x = np.exp(x_shifted)
    return exp_x / np.sum(exp_x)


@dataclass
class AttentionHead:
    """A single attention head with query, key, and value projections.

    Attributes:
        Wq: Query weight matrix (dₖ × d)
        Wk: Key weight matrix (dₖ × d)
        Wv: Value weight matrix (dᵥ × d)
    """
    Wq: Mat
    Wk: Mat
    Wv: Mat

    @property
    def d(self) -> int:
        return self.Wq.shape[1]

    @property
    def dk(self) -> int:
        return self.Wq.shape[0]

    @property
    def dv(self) -> int:
        return self.Wv.shape[0]


def attention_score(head: AttentionHead, xi: Vec, xj: Vec) -> float:
    """Compute attention score: (Wq·xᵢ)ᵀ(Wk·xⱼ).

    Formally proved to be:
    - Bilinear in (xᵢ, xⱼ)
    - Equal to xᵢᵀ·(WqᵀWk)·xⱼ (Gram factorization)
    """
    q = head.Wq @ xi
    k = head.Wk @ xj
    return float(np.dot(q, k))


def attention_gram_matrix(head: AttentionHead) -> Mat:
    """Compute the Gram matrix G = WqᵀWk.

    The attention score equals the bilinear form defined by G:
    score(xᵢ, xⱼ) = xᵢᵀ · G · xⱼ
    """
    return head.Wq.T @ head.Wk


def vec_mean(x: Vec) -> float:
    """Mean of a vector: μ(x) = (∑ᵢ xᵢ) / n."""
    return float(np.mean(x))


def vec_center(x: Vec) -> Vec:
    """Center a vector: x̃ᵢ = xᵢ - μ(x).

    Formally proved: ∑ᵢ x̃ᵢ = 0 and μ(x̃) = 0.
    """
    return x - vec_mean(x)


def vec_variance(x: Vec) -> float:
    """Population variance: σ²(x) = (∑ᵢ (xᵢ - μ)²) / n."""
    centered = vec_center(x)
    return float(np.mean(centered ** 2))


def layer_norm_vec(
    x: Vec,
    gamma: Vec | None = None,
    beta: Vec | None = None,
    eps: float = 1e-12
) -> Vec:
    """Layer normalization with optional affine parameters.

    LayerNorm(x)ᵢ = γᵢ · (xᵢ - μ) / √(σ² + ε) + βᵢ

    Properties (formally proved):
    - Output has zero mean (when γ=1, β=0)
    - Centering is exact: ∑ᵢ (xᵢ - μ) = 0
    """
    centered = vec_center(x)
    var = vec_variance(x)
    normalized = centered / np.sqrt(var + eps)

    if gamma is not None and beta is not None:
        return gamma * normalized + beta
    return normalized


def sinusoidal_pe(d: int, pos: int) -> Vec:
    """Sinusoidal positional encoding at position `pos`.

    PE(pos, 2i) = sin(pos / 10000^(2i/d))
    PE(pos, 2i+1) = cos(pos / 10000^(2i/d))
    """
    pe = np.zeros(d)
    for i in range(d):
        freq = pos / (10000.0 ** (2.0 * (i // 2) / d))
        pe[i] = np.sin(freq) if i % 2 == 0 else np.cos(freq)
    return pe


def add_positional_encoding(X: Mat) -> Mat:
    """Add sinusoidal positional encoding to input embeddings.

    Positional information enters additively: X̂ = X + PE.
    """
    n, d = X.shape
    return np.array([X[pos] + sinusoidal_pe(d, pos) for pos in range(n)])


@dataclass
class FFNLayer:
    """Feedforward network layer: two linear maps with activation.

    FFN(x) = W₂ · σ(W₁ · x + b₁) + b₂
    """
    W1: Mat
    b1: Vec
    activation: Callable[[Vec], Vec]
    W2: Mat
    b2: Vec

    def apply(self, x: Vec) -> Vec:
        hidden = self.activation(self.W1 @ x + self.b1)
        return self.W2 @ hidden + self.b2


def residual_connect(f: Callable[[Vec], Vec], x: Vec) -> Vec:
    """Residual connection: Res(f, x) = f(x) + x.

    Formally proved:
    - Res(0, x) = x (identity when f = 0)
    - Res(g, Res(f, x)) = g(f(x) + x) + (f(x) + x)
    """
    return f(x) + x


def iterate_layer(f: Callable[[Vec], Vec], n: int, x: Vec) -> Vec:
    """Apply function f exactly n times (transformer depth).

    Formally proved: iterate(f, m+n, x) = iterate(f, m, iterate(f, n, x))
    """
    result = x
    for _ in range(n):
        result = f(result)
    return result


@dataclass
class MultiHeadConfig:
    """Multi-head attention configuration."""
    heads: list[AttentionHead]
    Wo: Mat  # Output projection

    @property
    def num_heads(self) -> int:
        return len(self.heads)


def multi_head_attention(config: MultiHeadConfig, X: Mat) -> Mat:
    """Compute multi-head attention on a sequence of token vectors.

    For each query position i:
    1. Compute attention scores with all key positions
    2. Apply softmax to get attention weights
    3. Weighted sum of value vectors
    4. Concatenate heads and project with Wo
    """
    n = X.shape[0]
    head_outputs = []

    for head in config.heads:
        # Compute attention scores
        scores = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                scores[i, j] = attention_score(head, X[i], X[j])

        # Scale by sqrt(dk)
        scores = scores / np.sqrt(head.dk)

        # Softmax per row
        weights = np.array([softmax_vec(scores[i]) for i in range(n)])

        # Weighted sum of values
        V = X @ head.Wv.T  # (n, dv)
        output = weights @ V  # (n, dv)
        head_outputs.append(output)

    # Concatenate and project
    concat = np.concatenate(head_outputs, axis=1)  # (n, h*dv)
    return concat @ config.Wo.T  # (n, d)


@dataclass
class TransformerBlock:
    """A complete transformer block: attention + FFN with residual connections."""
    attn: MultiHeadConfig
    ffn: FFNLayer
    d: int

    def forward(self, X: Mat) -> Mat:
        # Sub-layer 1: Multi-head attention + residual + layer norm
        attn_out = multi_head_attention(self.attn, X)
        X = np.array([layer_norm_vec(X[i] + attn_out[i]) for i in range(X.shape[0])])

        # Sub-layer 2: FFN + residual + layer norm
        ffn_out = np.array([self.ffn.apply(X[i]) for i in range(X.shape[0])])
        X = np.array([layer_norm_vec(X[i] + ffn_out[i]) for i in range(X.shape[0])])

        return X


def create_random_transformer(
    d: int = 8,
    dk: int = 4,
    dv: int = 4,
    dff: int = 16,
    n_heads: int = 2,
    n_layers: int = 2,
    seed: int = 42
) -> list[TransformerBlock]:
    """Create a random transformer with given dimensions."""
    rng = np.random.default_rng(seed)
    scale = 0.1

    blocks = []
    for _ in range(n_layers):
        heads = []
        for _ in range(n_heads):
            head = AttentionHead(
                Wq=rng.normal(scale=scale, size=(dk, d)),
                Wk=rng.normal(scale=scale, size=(dk, d)),
                Wv=rng.normal(scale=scale, size=(dv, d)),
            )
            heads.append(head)

        attn = MultiHeadConfig(
            heads=heads,
            Wo=rng.normal(scale=scale, size=(d, n_heads * dv)),
        )

        ffn = FFNLayer(
            W1=rng.normal(scale=scale, size=(dff, d)),
            b1=np.zeros(dff),
            activation=lambda x: np.maximum(0, x),  # ReLU
            W2=rng.normal(scale=scale, size=(d, dff)),
            b2=np.zeros(d),
        )

        blocks.append(TransformerBlock(attn=attn, ffn=ffn, d=d))

    return blocks


if __name__ == "__main__":
    # Create and run a small transformer
    d, seq_len = 8, 4
    blocks = create_random_transformer(d=d)

    X = np.random.randn(seq_len, d)
    print(f"Input shape: {X.shape}")
    print(f"Input:\n{X}\n")

    for i, block in enumerate(blocks):
        X = block.forward(X)
        print(f"After block {i+1}:\n{X}\n")

    print(f"Output shape: {X.shape}")
