#!/usr/bin/env python3
"""
Algorithms for Finite Rate-Distortion Theory and Voice-Leading Geometry

Implements:
1. Blahut-Arimoto algorithm for R(D) computation
2. Optimal voice-leading via Hungarian algorithm
3. Voice-leading distance matrix computation
4. Tropical/min-plus rate-distortion bounds
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Dict, Optional


# ===========================================================================
# Algorithm 1: Blahut-Arimoto for Rate-Distortion
# ===========================================================================

def blahut_arimoto(
    mu: np.ndarray,
    distortion: np.ndarray,
    beta: float,
    max_iter: int = 500,
    tol: float = 1e-10
) -> Tuple[np.ndarray, float, float]:
    """
    Blahut-Arimoto algorithm for computing the rate-distortion function.

    Args:
        mu: Source distribution, shape (n,)
        distortion: Distortion matrix d(x,y), shape (n, m)
        beta: Lagrange multiplier (slope parameter)
        max_iter: Maximum iterations
        tol: Convergence tolerance

    Returns:
        channel: Optimal channel P(y|x), shape (n, m)
        rate: Mutual information I(X;Y) in bits
        dist: Expected distortion E[d(X,Y)]

    Time complexity: O(max_iter * n * m)
    Space complexity: O(n * m)
    """
    n, m = distortion.shape
    channel = np.ones((n, m)) / m  # uniform initialization

    for iteration in range(max_iter):
        # E-step: compute output distribution
        py = mu @ channel  # shape (m,)
        py = np.maximum(py, 1e-300)

        # M-step: update channel
        new_channel = np.zeros((n, m))
        for x in range(n):
            logits = np.log(py) - beta * distortion[x]
            logits -= logits.max()  # numerical stability
            new_channel[x] = np.exp(logits)
            new_channel[x] /= new_channel[x].sum()

        # Check convergence
        diff = np.max(np.abs(new_channel - channel))
        channel = new_channel
        if diff < tol:
            break

    # Compute rate and distortion
    joint = np.outer(mu, np.ones(m)) * channel
    py = joint.sum(axis=0)
    rate = 0.0
    for x in range(n):
        for y in range(m):
            if joint[x, y] > 1e-300 and py[y] > 1e-300:
                rate += joint[x, y] * np.log2(joint[x, y] / (mu[x] * py[y]))

    dist = np.sum(joint * distortion)
    return channel, rate, dist


def compute_rd_curve(
    mu: np.ndarray,
    distortion: np.ndarray,
    num_points: int = 50
) -> List[Tuple[float, float]]:
    """
    Compute the full R(D) curve using Blahut-Arimoto at multiple beta values.

    Args:
        mu: Source distribution
        distortion: Distortion matrix
        num_points: Number of points on the curve

    Returns:
        List of (D, R) pairs, sorted by D
    """
    beta_values = np.logspace(-3, 3, num_points)
    points = []

    for beta in beta_values:
        _, rate, dist = blahut_arimoto(mu, distortion, beta)
        points.append((dist, rate))

    points.sort(key=lambda x: x[0])
    return points


# ===========================================================================
# Algorithm 2: Voice-Leading Distance
# ===========================================================================

def voice_leading_distance(
    V: List[int],
    W: List[int]
) -> Tuple[int, List[int]]:
    """
    Compute minimum voice-leading distance and optimal assignment.

    Uses brute-force over all permutations (optimal for small n).
    For n > 8, use the Hungarian algorithm instead.

    Args:
        V: Source voicing (pitch classes)
        W: Target voicing (pitch classes)

    Returns:
        min_cost: Minimum total displacement
        best_perm: Optimal voice assignment

    Time complexity: O(n! * n) for brute-force, O(n^3) for Hungarian
    Space complexity: O(n)
    """
    n = len(V)
    assert len(W) == n, "Voicings must have same cardinality"

    if n <= 8:
        # Brute force for small n
        best_cost = float('inf')
        best_perm = list(range(n))
        for perm in permutations(range(n)):
            cost = sum(abs(V[i] - W[perm[i]]) for i in range(n))
            if cost < best_cost:
                best_cost = cost
                best_perm = list(perm)
        return best_cost, best_perm
    else:
        # For larger n, use scipy's linear_sum_assignment (Hungarian algorithm)
        try:
            from scipy.optimize import linear_sum_assignment
            cost_matrix = np.array([[abs(V[i] - W[j]) for j in range(n)] for i in range(n)])
            row_ind, col_ind = linear_sum_assignment(cost_matrix)
            best_cost = cost_matrix[row_ind, col_ind].sum()
            best_perm = list(col_ind)
            return int(best_cost), best_perm
        except ImportError:
            # Fallback to brute force
            return voice_leading_distance.__wrapped__(V, W)


def voice_leading_distance_matrix(
    voicings: Dict[str, List[int]]
) -> Tuple[np.ndarray, List[str]]:
    """
    Compute pairwise voice-leading distance matrix.

    Args:
        voicings: Dictionary mapping names to pitch-class lists

    Returns:
        matrix: Distance matrix
        names: Ordered list of voicing names
    """
    names = list(voicings.keys())
    n = len(names)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            matrix[i, j], _ = voice_leading_distance(
                voicings[names[i]], voicings[names[j]])
    return matrix, names


# ===========================================================================
# Algorithm 3: Tropical/Min-Plus Rate-Distortion Bounds
# ===========================================================================

def min_entropy(mu: np.ndarray) -> float:
    """
    Min-entropy H_∞(μ) = -log₂(max μ(x)).

    Args:
        mu: Probability distribution

    Returns:
        Min-entropy in bits
    """
    return -np.log2(np.max(mu))


def tropical_rd_lower_bound(mu: np.ndarray, D: float) -> float:
    """
    Tropical (min-plus) lower bound on R(D).

    R_min(D) = max(0, H_∞(μ) - D)

    This is exact for the min-plus semiring and provides a certified
    lower bound on the Shannon rate-distortion function.

    Args:
        mu: Source distribution
        D: Distortion level

    Returns:
        Lower bound on R(D) in bits
    """
    return max(0.0, min_entropy(mu) - D)


def tropical_dual_envelope(
    mu: np.ndarray,
    distortion: np.ndarray,
    lambda_values: np.ndarray
) -> List[Tuple[float, float]]:
    """
    Compute the tropical dual envelope of R(D).

    For each dual variable λ ≥ 0, compute:
        Φ(λ) - λD = max_y min_x (d(x,y) + (1/λ)log(μ(x))) - D

    The supremum over λ gives a family of affine lower bounds on R(D).

    Args:
        mu: Source distribution
        distortion: Distortion matrix
        lambda_values: Dual parameter values

    Returns:
        List of (slope, intercept) pairs defining affine lower bounds
    """
    n, m = distortion.shape
    affine_funcs = []

    for lam in lambda_values:
        if lam <= 0:
            continue
        # Compute Φ(λ)
        phi = 0.0
        for y in range(m):
            vals = [lam * distortion[x, y] - np.log(mu[x]) for x in range(n) if mu[x] > 0]
            phi = max(phi, -min(vals) if vals else 0)

        affine_funcs.append((-lam, phi))

    return affine_funcs


# ===========================================================================
# Algorithm 4: Piecewise-Linear R(D) Characterization
# ===========================================================================

def identify_breakpoints(rd_curve: List[Tuple[float, float]], tol: float = 0.01) -> List[Tuple[float, float]]:
    """
    Identify breakpoints (slope changes) in an empirical R(D) curve.

    Since R(D) is convex and piecewise-linear for finite alphabets,
    the breakpoints correspond to changes in the optimal channel structure.

    Args:
        rd_curve: List of (D, R) pairs, sorted by D
        tol: Tolerance for detecting slope changes

    Returns:
        List of (D, R) breakpoints
    """
    if len(rd_curve) < 3:
        return list(rd_curve)

    breakpoints = [rd_curve[0]]

    for i in range(1, len(rd_curve) - 1):
        D_prev, R_prev = rd_curve[i-1]
        D_curr, R_curr = rd_curve[i]
        D_next, R_next = rd_curve[i+1]

        if abs(D_curr - D_prev) < 1e-12 or abs(D_next - D_curr) < 1e-12:
            continue

        slope_left = (R_curr - R_prev) / (D_curr - D_prev)
        slope_right = (R_next - R_curr) / (D_next - D_curr)

        if abs(slope_left - slope_right) > tol:
            breakpoints.append(rd_curve[i])

    breakpoints.append(rd_curve[-1])
    return breakpoints


# ===========================================================================
# Example usage
# ===========================================================================

if __name__ == '__main__':
    # Example: Binary source
    print("=== Binary Symmetric Source R(D) ===")
    mu = np.array([0.3, 0.7])
    d = np.array([[0, 1], [1, 0]])  # Hamming distortion

    curve = compute_rd_curve(mu, d, num_points=30)
    print(f"R(0) ≈ {curve[0][1]:.4f} bits (should be H(p) = {-0.3*np.log2(0.3)-0.7*np.log2(0.7):.4f})")
    print(f"D_max ≈ {curve[-1][0]:.4f} (should be {min(0.3, 0.7):.1f})")

    # Example: Voice-leading
    print("\n=== Voice-Leading Distances ===")
    triads = {
        'C maj': [0, 4, 7],
        'C min': [0, 3, 7],
        'F maj': [5, 9, 12],
        'G maj': [7, 11, 14],
    }
    matrix, names = voice_leading_distance_matrix(triads)
    print("Distance matrix:")
    for i, name in enumerate(names):
        print(f"  {name}: {matrix[i]}")

    # Tropical bound
    print("\n=== Tropical Bounds ===")
    mu_vl = np.array([0.4, 0.2, 0.2, 0.2])
    print(f"H_∞ = {min_entropy(mu_vl):.4f} bits")
    for D in [0, 1, 2, 5]:
        print(f"  R_min({D}) ≥ {tropical_rd_lower_bound(mu_vl, D):.4f}")
