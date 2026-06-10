#!/usr/bin/env python3
"""
Algorithms for Diophantine ReLU Approximation Theory

Type-hinted implementations of the core algorithms connecting
ReLU network architecture to approximation quality.
"""

from typing import Tuple, List, Optional
import math


def relu(x: float) -> float:
    """ReLU activation: max(0, x)."""
    return max(0.0, x)


def softplus(x: float, temperature: float = 1.0) -> float:
    """Softplus (smooth ReLU): (1/t) * log(1 + exp(t*x)).
    
    As temperature → ∞, softplus → relu (tropical limit / Maslov dequantization).
    """
    tx = temperature * x
    if tx > 20:
        return x  # Avoid overflow
    return math.log(1 + math.exp(tx)) / temperature


def soft_hard_gap(x: float) -> float:
    """Gap between softplus and ReLU.
    
    Returns log(1 + exp(-|x|)), which is:
    - Maximized at x=0 where gap = log(2)
    - Tends to 0 as |x| → ∞
    """
    return math.log(1 + math.exp(-abs(x)))


def leibniz_term(k: int) -> float:
    """k-th term of the Leibniz series: (-1)^k / (2k+1)."""
    return ((-1) ** k) / (2 * k + 1)


def leibniz_partial_sum(n: int) -> float:
    """n-th partial sum of Leibniz series for π/4."""
    return sum(leibniz_term(k) for k in range(n))


def leibniz_pi_approx(n: int) -> float:
    """Approximate π using n terms of the Leibniz series."""
    return 4.0 * leibniz_partial_sum(n)


def min_terms_for_epsilon(epsilon: float) -> int:
    """Minimum number of Leibniz terms for |4·S_N - π| < ε.
    
    Error bound: |4·S_N - π| ≤ 4/(2N+1).
    So we need 4/(2N+1) < ε, i.e., N > (4/ε - 1)/2.
    """
    return math.ceil((4.0 / epsilon - 1) / 2)


def piece_count(width: int, depth: int) -> int:
    """Maximum number of linear pieces in a depth-L width-w ReLU network."""
    return width ** depth


def param_count(width: int, depth: int) -> int:
    """Parameter count of a 1D→1D ReLU network with given width and depth.
    
    Each layer: w weights + w biases = 2w parameters.
    Output layer: w weights + 1 bias.
    Total: depth * 2w + w + 1.
    """
    return depth * width * 2 + width + 1


def min_depth_for_pieces(width: int, target_pieces: int) -> int:
    """Minimum depth to achieve at least target_pieces linear pieces.
    
    Need w^L ≥ target_pieces, so L ≥ log_w(target_pieces).
    """
    if width <= 1:
        return target_pieces  # Width 1 = affine, can't add pieces
    return math.ceil(math.log(target_pieces) / math.log(width))


def min_network_for_pi_approx(
    epsilon: float, width: int = 2
) -> Tuple[int, int, int]:
    """Minimum network spec (width, depth, params) for ε-approximation of π.
    
    Returns (width, depth, param_count).
    
    Strategy: Use Leibniz series.
    1. Need N ≥ 4/(2ε) terms → O(1/ε) terms
    2. Need depth L ≥ log_w(N) to store N pieces
    3. Parameter count = 2wL + w + 1
    """
    n_terms = min_terms_for_epsilon(epsilon)
    depth = min_depth_for_pieces(width, n_terms)
    params = param_count(width, depth)
    return (width, depth, params)


def depth_width_efficiency_ratio(width: int, depth: int) -> float:
    """Ratio of pieces to parameters: w^L / (2wL + w + 1).
    
    This ratio grows exponentially with depth, demonstrating
    the exponential advantage of depth over width.
    """
    pieces = piece_count(width, depth)
    params = param_count(width, depth)
    return pieces / params


def best_rational_approx(
    target: float, max_denom: int = 1000
) -> Tuple[int, int, float]:
    """Find best rational approximation p/q to target with q ≤ max_denom.
    
    Uses brute force (for demonstration). Returns (p, q, error).
    A ReLU network with rational weights can represent p/q exactly.
    """
    best_p, best_q, best_err = 0, 1, abs(target)
    for q in range(1, max_denom + 1):
        p = round(target * q)
        err = abs(target - p / q)
        if err < best_err:
            best_p, best_q, best_err = p, q, err
    return best_p, best_q, best_err


def continued_fraction_convergents(
    x: float, max_terms: int = 20
) -> List[Tuple[int, int]]:
    """Compute continued fraction convergents of x.
    
    These give the best rational approximations (by Dirichlet's theorem).
    The convergent p_n/q_n satisfies |x - p_n/q_n| < 1/q_n^2.
    """
    convergents = []
    a = math.floor(x)
    p_prev, p_curr = 1, a
    q_prev, q_curr = 0, 1
    convergents.append((p_curr, q_curr))
    
    remainder = x - a
    for _ in range(max_terms):
        if abs(remainder) < 1e-15:
            break
        remainder = 1.0 / remainder
        a = math.floor(remainder)
        p_prev, p_curr = p_curr, a * p_curr + p_prev
        q_prev, q_curr = q_curr, a * q_curr + q_prev
        convergents.append((p_curr, q_curr))
        remainder = remainder - a
    
    return convergents


if __name__ == "__main__":
    print("=== Diophantine ReLU Approximation Algorithms ===\n")
    
    # Test π approximation
    for eps_exp in range(1, 8):
        eps = 10 ** (-eps_exp)
        w, d, p = min_network_for_pi_approx(eps)
        print(f"ε = 10^{-eps_exp}: width={w}, depth={d}, params={p}, "
              f"pieces={piece_count(w, d)}, efficiency={depth_width_efficiency_ratio(w, d):.1f}")
    
    print("\n--- Continued fraction convergents of π ---")
    for p, q in continued_fraction_convergents(math.pi, 10):
        err = abs(math.pi - p/q)
        print(f"  {p}/{q} = {p/q:.15f}, error = {err:.2e}")
