#!/usr/bin/env python3
"""
Algorithms for Tropical Network Analysis

Implements the core algorithms arising from the tropical compositional stability
theory, including:
1. Tropical aggregation and iterated application
2. Tropical (max-plus) matrix multiplication
3. Certified robustness radius computation
4. Tropical network depth compression
5. Bellman-style value iteration with tropical stability
"""

import numpy as np
from typing import List, Tuple, Optional


def tropical_agg(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical aggregation operator.

    Computes (tropicalAgg W x)[j] = max_i (W[i,j] + x[i])

    Args:
        W: Weight matrix of shape (n, m)
        x: Input vector of shape (n,)

    Returns:
        Output vector of shape (m,)

    Time complexity: O(n * m)
    Space complexity: O(m)
    """
    return np.max(W + x[:, np.newaxis], axis=0)


def tropical_compose(W1: np.ndarray, W2: np.ndarray) -> np.ndarray:
    """
    Tropical matrix composition (max-plus matrix multiplication).

    Computes (W1 ⊛ W2)[i,k] = max_j (W1[i,j] + W2[j,k])

    This is the max-plus analogue of standard matrix multiplication,
    where addition replaces multiplication and max replaces addition.

    Args:
        W1: First weight matrix of shape (n, m)
        W2: Second weight matrix of shape (m, p)

    Returns:
        Composed matrix of shape (n, p)

    Time complexity: O(n * m * p)
    Space complexity: O(n * p)
    """
    n, m = W1.shape
    _, p = W2.shape
    result = np.full((n, p), -np.inf)
    for i in range(n):
        for k in range(p):
            result[i, k] = np.max(W1[i, :] + W2[:, k])
    return result


def tropical_compose_fast(W1: np.ndarray, W2: np.ndarray) -> np.ndarray:
    """
    Vectorized tropical matrix composition.

    Same semantics as tropical_compose but uses broadcasting for speed.

    Time complexity: O(n * m * p)
    Space complexity: O(n * m * p) temporary
    """
    # W1: (n, m), W2: (m, p)
    # W1[:, :, None] + W2[None, :, :] -> (n, m, p), then max over m
    return np.max(W1[:, :, np.newaxis] + W2[np.newaxis, :, :], axis=1)


def tropical_power(W: np.ndarray, n: int) -> np.ndarray:
    """
    Compute the n-th tropical power of a square matrix.

    W^(⊛n) = W ⊛ W ⊛ ... ⊛ W (n times)

    Uses repeated squaring for efficiency.

    Args:
        W: Square weight matrix of shape (d, d)
        n: Power (positive integer)

    Returns:
        W^(⊛n) of shape (d, d)

    Time complexity: O(d³ log n)
    Space complexity: O(d²)
    """
    if n == 0:
        # Tropical identity: 0 on diagonal, -∞ elsewhere
        d = W.shape[0]
        result = np.full((d, d), -np.inf)
        np.fill_diagonal(result, 0.0)
        return result
    if n == 1:
        return W.copy()

    # Repeated squaring
    result = None
    base = W.copy()
    while n > 0:
        if n % 2 == 1:
            result = base if result is None else tropical_compose_fast(result, base)
        base = tropical_compose_fast(base, base)
        n //= 2
    return result


def sup_norm(x: np.ndarray) -> float:
    """Compute the sup (infinity) norm of a vector."""
    return float(np.max(np.abs(x)))


def certified_robustness_radius(
    W_layers: List[np.ndarray],
    x: np.ndarray,
    prediction_fn: Optional[callable] = None
) -> dict:
    """
    Compute the certified robustness radius of a tropical network.

    Since tropical networks are 1-Lipschitz, the certified radius equals
    the margin of the network at the given input.

    For a classifier that returns class argmax(F(x)), the certified radius
    is min_{k ≠ predicted} (F(x)[predicted] - F(x)[k]) / 2.

    Args:
        W_layers: List of weight matrices for each layer
        x: Input vector
        prediction_fn: Optional custom prediction function

    Returns:
        Dictionary with:
            - 'output': network output
            - 'predicted_class': argmax of output
            - 'margin': minimum margin to second-best class
            - 'certified_radius': guaranteed robustness radius
            - 'lipschitz_bound': Lipschitz constant bound (always 1.0)
    """
    # Forward pass through all layers
    current = x.copy()
    for W in W_layers:
        current = tropical_agg(W, current)

    output = current
    predicted = int(np.argmax(output))

    # Compute margin
    margins = []
    for k in range(len(output)):
        if k != predicted:
            margins.append(output[predicted] - output[k])

    margin = min(margins) if margins else float('inf')
    # Since Lipschitz constant is exactly 1, certified radius = margin / 2
    certified_radius = margin / 2.0

    return {
        'output': output,
        'predicted_class': predicted,
        'margin': margin,
        'certified_radius': certified_radius,
        'lipschitz_bound': 1.0,  # Proven: depth does not amplify
    }


def depth_compress(W_layers: List[np.ndarray]) -> np.ndarray:
    """
    Compress a multi-layer tropical network into a single weight matrix.

    By the tropical composition theorem:
        tropicalAgg(W_d, ... tropicalAgg(W_1, x) ...) = tropicalAgg(W_1 ⊛ ... ⊛ W_d, x)

    This algebraically collapses d layers into one, preserving exact behavior.

    Args:
        W_layers: List of weight matrices [W_1, W_2, ..., W_d]

    Returns:
        Single composed weight matrix W_1 ⊛ W_2 ⊛ ... ⊛ W_d

    Time complexity: O(d * n² * m) where n, m are max dimensions
    """
    result = W_layers[0]
    for W in W_layers[1:]:
        result = tropical_compose_fast(result, W)
    return result


def bellman_iterate(
    W: np.ndarray,
    reward: np.ndarray,
    x0: np.ndarray,
    n_iters: int = 100,
    gamma: float = 0.0
) -> Tuple[List[np.ndarray], List[float]]:
    """
    Bellman-style value iteration using tropical aggregation.

    Computes x_{t+1} = tropicalAgg(W, x_t) + gamma * reward.

    The stability theorem guarantees that different initial conditions
    converge to within ‖x0 - y0‖∞ of each other at every step.

    Args:
        W: Transition weight matrix (square)
        reward: Stage reward vector (added after each step)
        x0: Initial value vector
        n_iters: Number of iterations
        gamma: Reward scaling factor

    Returns:
        Tuple of (trajectory, convergence_gaps) where:
            - trajectory: list of value vectors at each step
            - convergence_gaps: list of ‖x_{t+1} - x_t‖∞
    """
    trajectory = [x0.copy()]
    gaps = []

    current = x0.copy()
    for _ in range(n_iters):
        next_val = tropical_agg(W, current) + gamma * reward
        gap = sup_norm(next_val - current)
        gaps.append(gap)
        trajectory.append(next_val.copy())
        current = next_val

    return trajectory, gaps


def verify_nonexpansiveness(
    W: np.ndarray,
    n_trials: int = 1000,
    n_depths: int = 20,
    dim: Optional[int] = None
) -> dict:
    """
    Empirically verify the nonexpansiveness theorem.

    Generates random input pairs and checks that
    ‖F^n(x) - F^n(y)‖∞ ≤ ‖x - y‖∞ for all tested n and all trials.

    Args:
        W: Weight matrix (if None, random)
        n_trials: Number of random input pairs to test
        n_depths: Maximum depth to test
        dim: Dimension (used if W is None)

    Returns:
        Dictionary with verification statistics
    """
    d = W.shape[0]
    max_ratios = np.zeros(n_depths)
    violations = 0

    for _ in range(n_trials):
        x = np.random.randn(d) * 5
        y = np.random.randn(d) * 5
        input_dist = sup_norm(x - y)

        if input_dist < 1e-12:
            continue

        cx, cy = x.copy(), y.copy()
        for depth in range(n_depths):
            cx = tropical_agg(W, cx)
            cy = tropical_agg(W, cy)
            ratio = sup_norm(cx - cy) / input_dist
            max_ratios[depth] = max(max_ratios[depth], ratio)
            if ratio > 1.0 + 1e-10:
                violations += 1

    return {
        'n_trials': n_trials,
        'n_depths': n_depths,
        'max_ratios_per_depth': max_ratios,
        'violations': violations,
        'theorem_holds': violations == 0,
    }


if __name__ == "__main__":
    print("Tropical Network Algorithms — Example Usage")
    print("=" * 50)

    # Example: Certified robustness
    np.random.seed(42)
    layers = [np.random.randn(5, 4), np.random.randn(4, 3)]
    x = np.random.randn(5)

    result = certified_robustness_radius(layers, x)
    print(f"\nCertified Robustness Analysis:")
    print(f"  Output: {result['output']}")
    print(f"  Predicted class: {result['predicted_class']}")
    print(f"  Margin: {result['margin']:.4f}")
    print(f"  Certified radius: {result['certified_radius']:.4f}")
    print(f"  Lipschitz bound: {result['lipschitz_bound']}")

    # Example: Depth compression
    compressed = depth_compress(layers)
    x_test = np.random.randn(5)
    out_seq = tropical_agg(layers[1], tropical_agg(layers[0], x_test))
    out_comp = tropical_agg(compressed, x_test)
    print(f"\nDepth Compression:")
    print(f"  Sequential output: {out_seq}")
    print(f"  Compressed output: {out_comp}")
    print(f"  Match: {np.allclose(out_seq, out_comp)}")

    # Example: Verification
    W = np.random.randn(6, 6)
    stats = verify_nonexpansiveness(W, n_trials=500, n_depths=50)
    print(f"\nEmpirical Verification:")
    print(f"  Trials: {stats['n_trials']}, Depths: {stats['n_depths']}")
    print(f"  Violations: {stats['violations']}")
    print(f"  Theorem holds: {stats['theorem_holds']}")
