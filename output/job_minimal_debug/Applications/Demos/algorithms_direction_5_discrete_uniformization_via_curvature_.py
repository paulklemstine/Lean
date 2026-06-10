#!/usr/bin/env python3
"""
Algorithms for Discrete Uniformization via Curvature Flow

Implements the core algorithms from the research paper:
1. Curvature variance computation with bias-variance decomposition
2. Greedy curvature flow via edge flips
3. Curvature step (pairwise redistribution)
4. Spectral gap estimation
"""

import math
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────
# Algorithm 1: Variance Decomposition
# ─────────────────────────────────────────────────────────

def compute_mean(K: List[float]) -> float:
    """Compute the mean of a curvature profile.

    Args:
        K: Curvature values at each vertex.

    Returns:
        The arithmetic mean ∑K_i / n.

    >>> compute_mean([1.0, 2.0, 3.0])
    2.0
    """
    return sum(K) / len(K)


def compute_variance(K: List[float]) -> float:
    """Compute the (unnormalized) variance of a curvature profile.

    Variance = ∑_i (K_i - K̄)²

    Args:
        K: Curvature values at each vertex.

    Returns:
        Sum of squared deviations from the mean.

    >>> compute_variance([1.0, 1.0, 1.0])
    0.0
    >>> abs(compute_variance([0.0, 2.0]) - 2.0) < 1e-10
    True
    """
    mu = compute_mean(K)
    return sum((k - mu) ** 2 for k in K)


def variance_decomposition(K: List[float], c: float) -> Dict[str, float]:
    """Verify the bias-variance decomposition:

        ‖K - c‖² = Var(K) + n · (K̄ - c)²

    This is Theorem `sq_dist_decomposition` from the Lean formalization.

    Args:
        K: Curvature profile.
        c: Target constant.

    Returns:
        Dictionary with sq_dist, variance, bias, and numerical error.

    >>> r = variance_decomposition([1.0, 3.0], 1.5)
    >>> abs(r['error']) < 1e-14
    True
    """
    n = len(K)
    mu = compute_mean(K)
    sq_dist = sum((k - c) ** 2 for k in K)
    var = compute_variance(K)
    bias = n * (mu - c) ** 2

    return {
        "sq_dist": sq_dist,
        "variance": var,
        "bias": bias,
        "decomposition": var + bias,
        "error": sq_dist - (var + bias),
    }


# ─────────────────────────────────────────────────────────
# Algorithm 2: Curvature Step (Pairwise Redistribution)
# ─────────────────────────────────────────────────────────

def curvature_step(K: List[float], i: int, j: int, t: float = 0.5) -> List[float]:
    """Perform a curvature redistribution step between vertices i and j.

    K_i ← K_i + t·(K_j - K_i)
    K_j ← K_j + t·(K_i - K_j)
    K_k ← K_k  for k ∉ {i, j}

    At t=1/2, this equalizes K_i and K_j (averaging step).
    Preserves total curvature (Gauss-Bonnet invariance).

    This corresponds to `curvatureStep` in the Lean formalization.

    Args:
        K: Current curvature profile.
        i, j: Vertex indices to redistribute between.
        t: Step size in [0, 1].

    Returns:
        New curvature profile after the step.

    >>> K = [0.0, 4.0, 2.0]
    >>> K_new = curvature_step(K, 0, 1, 0.5)
    >>> abs(K_new[0] - 2.0) < 1e-10 and abs(K_new[1] - 2.0) < 1e-10
    True
    >>> abs(sum(K_new) - sum(K)) < 1e-10  # total preserved
    True
    """
    result = list(K)
    ki, kj = K[i], K[j]
    result[i] = ki + t * (kj - ki)
    result[j] = kj + t * (ki - kj)
    return result


def best_curvature_step(K: List[float]) -> Tuple[int, int, float]:
    """Find the pair (i, j) whose t=1/2 curvature step maximally reduces variance.

    Pseudocode:
        best_reduction = 0
        for each pair (i, j):
            K' = curvature_step(K, i, j, 0.5)
            reduction = Var(K) - Var(K')
            if reduction > best_reduction:
                best = (i, j, reduction)
        return best

    Complexity: O(n³) per step (n² pairs × O(n) variance computation).

    Args:
        K: Current curvature profile.

    Returns:
        (i, j, reduction) for the best pair, or (-1, -1, 0) if no improvement.
    """
    n = len(K)
    var_before = compute_variance(K)
    best_i, best_j, best_red = -1, -1, 0.0

    for i in range(n):
        for j in range(i + 1, n):
            K_new = curvature_step(K, i, j, 0.5)
            var_after = compute_variance(K_new)
            reduction = var_before - var_after
            if reduction > best_red + 1e-15:
                best_i, best_j, best_red = i, j, reduction

    return best_i, best_j, best_red


# ─────────────────────────────────────────────────────────
# Algorithm 3: Greedy Curvature Flow
# ─────────────────────────────────────────────────────────

@dataclass
class FlowResult:
    """Result of running greedy curvature flow."""
    final_K: List[float]
    variance_history: List[float]
    steps: int
    converged: bool
    pairs_flipped: List[Tuple[int, int]]


def greedy_curvature_flow(
    K: List[float],
    epsilon: float = 1e-10,
    max_steps: int = 10000,
) -> FlowResult:
    """Greedy curvature flow algorithm.

    At each step, find the pair (i,j) whose t=1/2 curvature step
    maximally reduces variance. Repeat until variance < ε or no
    improvement is possible.

    Complexity: O(n³ · S) where S is the number of steps.
    By the convergence analysis, S = O(n · log(1/ε)) in the worst case.

    Args:
        K: Initial curvature profile satisfying Gauss-Bonnet.
        epsilon: Convergence threshold for variance.
        max_steps: Maximum number of steps.

    Returns:
        FlowResult with final profile, history, and convergence status.

    >>> r = greedy_curvature_flow([0.0, 0.0, 4.0, 4.0], epsilon=0.01)
    >>> r.converged
    True
    >>> abs(compute_variance(r.final_K)) < 0.01
    True
    """
    current = list(K)
    var_hist = [compute_variance(current)]
    pairs = []

    for step in range(max_steps):
        if var_hist[-1] < epsilon:
            return FlowResult(current, var_hist, step, True, pairs)

        i, j, reduction = best_curvature_step(current)
        if reduction <= 0:
            return FlowResult(current, var_hist, step, var_hist[-1] < epsilon, pairs)

        current = curvature_step(current, i, j, 0.5)
        var_hist.append(compute_variance(current))
        pairs.append((i, j))

    return FlowResult(current, var_hist, max_steps, var_hist[-1] < epsilon, pairs)


# ─────────────────────────────────────────────────────────
# Algorithm 4: Spectral Gap Estimation
# ─────────────────────────────────────────────────────────

def spectral_gap_ratio(K: List[float]) -> float:
    """Estimate the spectral gap ratio for the curvature profile.

    Computes: max_{i≠j} (Var(K) - Var(step(K,i,j))) / Var(K)

    The spectral gap conjecture predicts this ratio ≥ 1/n².

    Args:
        K: Curvature profile.

    Returns:
        The ratio of best variance reduction to current variance.

    >>> r = spectral_gap_ratio([0.0, 4.0])
    >>> r >= 1/4 - 1e-10  # n=2, threshold=1/4
    True
    """
    var = compute_variance(K)
    if var < 1e-15:
        return float('inf')

    _, _, reduction = best_curvature_step(K)
    return reduction / var


# ─────────────────────────────────────────────────────────
# Algorithm 5: Pythagorean Angle Computation
# ─────────────────────────────────────────────────────────

def pythagorean_angles(a: int, b: int, c: int) -> Tuple[float, float, float]:
    """Compute angles of a right triangle from Pythagorean triple (a,b,c).

    Verifies: arctan(a/b) + arctan(b/a) = π/2
    (Theorem `pythagorean_acute_angle_sum` in Lean)

    Args:
        a, b: Legs of the right triangle.
        c: Hypotenuse satisfying a² + b² = c².

    Returns:
        (alpha, beta, right_angle) where alpha + beta = π/2.

    >>> a, b, c = pythagorean_angles(3, 4, 5)
    >>> abs(a + b - math.pi/2) < 1e-14
    True
    """
    assert a**2 + b**2 == c**2, f"Not a Pythagorean triple: {a}²+{b}²≠{c}²"
    alpha = math.atan(a / b)
    beta = math.atan(b / a)
    return alpha, beta, math.pi / 2


def right_angle_curvature(degree: int) -> float:
    """Curvature at a vertex of given degree where all faces are right triangles
    with the right angle at this vertex.

    K(v) = 2π - d · (π/2) = 2π(1 - d/4)

    (Theorem `right_angle_vertex_curvature` in Lean)

    Args:
        degree: Number of incident triangles at the vertex.

    Returns:
        The discrete curvature at the vertex.

    >>> abs(right_angle_curvature(4)) < 1e-14  # flat
    True
    >>> right_angle_curvature(3) > 0  # positive curvature
    True
    """
    return 2 * math.pi * (1 - degree / 4)


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Curvature Flow Algorithms ===\n")

    # Example 1: Variance decomposition
    K = [0.5, 1.5, 2.0, 0.0]
    r = variance_decomposition(K, 1.0)
    print(f"Variance decomposition for K={K}, c=1.0:")
    print(f"  ||K-c||² = {r['sq_dist']:.4f}")
    print(f"  Var(K) + n(μ-c)² = {r['decomposition']:.4f}")
    print(f"  Error: {r['error']:.2e}\n")

    # Example 2: Greedy flow
    K = [0.0, 0.0, 0.0, 4*math.pi, 0.0, 0.0, 0.0, 0.0]
    print(f"Greedy flow on K with one hot vertex (sum={sum(K):.4f}):")
    result = greedy_curvature_flow(K, epsilon=0.001)
    print(f"  Steps: {result.steps}")
    print(f"  Final variance: {result.variance_history[-1]:.6f}")
    print(f"  Converged: {result.converged}")
    print(f"  Total preserved: {abs(sum(result.final_K) - sum(K)):.2e}\n")

    # Example 3: Spectral gap
    K = [1.0, 3.0, 2.0, 0.0]
    ratio = spectral_gap_ratio(K)
    print(f"Spectral gap ratio for K={K}: {ratio:.6f}")
    print(f"  Threshold 1/n² = {1/len(K)**2:.6f}")
    print(f"  Conjecture holds: {ratio >= 1/len(K)**2 - 1e-10}")
