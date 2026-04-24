"""Core tropical (min-plus) primitives for the Crystalline framework.

Reference: TropicalDeepLearningFoundations.lean, TropicalNeuralBridge.lean
"""

import torch
import torch.nn as nn


def tropical_add(a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
    """Tropical addition: element-wise minimum.

    In the tropical semiring, addition is min and multiplication is +.
    """
    return torch.minimum(a, b)


def tropical_mul(a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
    """Tropical multiplication: element-wise standard addition.

    In the tropical semiring, multiplication is +.
    """
    return a + b


def tropical_matmul(A: torch.Tensor, B: torch.Tensor) -> torch.Tensor:
    """Tropical matrix multiplication.

    Computes C[m, n] = min_k(A[m, k] + B[k, n])

    This replaces standard matmul (sum of products) with min of sums,
    eliminating all floating-point multiplications.
    """
    # A: (M, K), B: (K, N)
    # A.unsqueeze(-1): (M, K, 1)
    # B.unsqueeze(0): (1, K, N)
    # sum broadcasts to: (M, K, N)
    # min over dim=1 (the K dimension): (M, N)
    return torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]


def tropical_state_update(
    state: torch.Tensor,
    gate: torch.Tensor,
    input_term: torch.Tensor,
) -> torch.Tensor:
    """Tropical analogue of a gated recurrence update.

    Standard recurrence: s_t = gate * s_{t-1} + input_term
    Tropical analogue:     s_t = min(gate + s_{t-1}, input_term)

    Args:
        state: Previous state tensor of shape (..., d)
        gate: Decay/gate tensor of shape (..., d)
        input_term: Input contribution tensor of shape (..., d)

    Returns:
        Updated state tensor of shape (..., d)
    """
    # gate + state is tropical multiplication
    # min(..., input_term) is tropical addition
    return torch.minimum(gate + state, input_term)


def tropical_dot_product(Q: torch.Tensor, K: torch.Tensor) -> torch.Tensor:
    """Tropical dot product using L1 distance (for attention scores).

    Computes scores[b, h, m, n] = -sum_d(|Q[b, h, m, d] - K[b, h, n, d]|)

    Negative L1 distance serves as a tropical inner product.
    """
    # Q: (B, H, M, D), K: (B, H, N, D)
    # diff: (B, H, M, N, D)
    diff = Q.unsqueeze(-2) - K.unsqueeze(-3)
    return -torch.sum(torch.abs(diff), dim=-1)
