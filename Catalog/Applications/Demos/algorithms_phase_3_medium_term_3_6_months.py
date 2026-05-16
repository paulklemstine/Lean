"""
Algorithms for Finite Rate-Distortion Theory and Voice-Leading Geometry

This module implements the core algorithms that correspond to the
formally verified mathematical structures:

1. Blahut-Arimoto algorithm for R(D) computation
2. Optimal voice-leading via Hungarian/brute-force assignment
3. Tropical envelope computation
4. Voice-leading rate-distortion analysis
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Dict, Optional


# ============================================================
# Algorithm 1: Blahut-Arimoto for R(D)
# ============================================================

def blahut_arimoto(
    p_x: np.ndarray,
    distortion: np.ndarray,
    beta: float,
    max_iter: int = 500,
    tol: float = 1e-12
) -> Tuple[float, float, np.ndarray]:
    """
    Blahut-Arimoto algorithm for a single Lagrange multiplier value.

    The algorithm alternates between:
    1. Updating W(y|x) ∝ q(y) exp(-β d(x,y))   [optimal channel]
    2. Updating q(y) = Σ_x p(x) W(y|x)           [output marginal]

    Convergence is guaranteed by the alternating minimization structure.

    Parameters:
        p_x: Source distribution, shape (|X|,)
        distortion: Distortion matrix, shape (|X|, |Y|)
        beta: Lagrange multiplier (inverse temperature)
        max_iter: Maximum number of iterations
        tol: Convergence tolerance

    Returns:
        rate: Mutual information I(X;Y) in nats
        dist: Expected distortion E[d(X,Y)]
        W: Optimal channel W(y|x), shape (|X|, |Y|)

    Time complexity: O(max_iter * |X| * |Y|)
    Space complexity: O(|X| * |Y|)
    """
    n_x, n_y = distortion.shape
    q_y = np.ones(n_y) / n_y

    for iteration in range(max_iter):
        # Step 1: Compute optimal channel
        log_W = np.log(q_y[None, :] + 1e-300) - beta * distortion
        log_W -= log_W.max(axis=1, keepdims=True)
        W = np.exp(log_W)
        W /= W.sum(axis=1, keepdims=True)

        # Step 2: Update output marginal
        q_y_new = p_x @ W

        # Check convergence
        if np.max(np.abs(q_y_new - q_y)) < tol:
            q_y = q_y_new
            break
        q_y = q_y_new

    # Compute rate and distortion
    p_xy = p_x[:, None] * W
    p_y = p_xy.sum(axis=0)

    rate = 0.0
    for x in range(n_x):
        for y in range(n_y):
            if p_xy[x, y] > 1e-300 and p_y[y] > 1e-300:
                rate += p_xy[x, y] * np.log(p_xy[x, y] / (p_x[x] * p_y[y]))

    dist = np.sum(p_xy * distortion)

    return max(0, rate), dist, W


def compute_rd_curve(
    p_x: np.ndarray,
    distortion: np.ndarray,
    n_points: int = 100,
    beta_min: float = 0.01,
    beta_max: float = 30.0
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the full R(D) curve by sweeping the Lagrange multiplier.

    Returns:
        distortions: Sorted array of distortion values
        rates: Corresponding rate values (in bits)
    """
    betas = np.linspace(beta_min, beta_max, n_points)
    results = [blahut_arimoto(p_x, distortion, b) for b in betas]

    rates = np.array([r / np.log(2) for r, _, _ in results])  # Convert to bits
    dists = np.array([d for _, d, _ in results])

    idx = np.argsort(dists)
    return dists[idx], rates[idx]


# ============================================================
# Algorithm 2: Optimal Voice-Leading Assignment
# ============================================================

def voice_leading_cost(
    source: List[int],
    target: List[int],
    perm: List[int]
) -> int:
    """
    Compute voice-leading cost for a given permutation assignment.

    Parameters:
        source: Source voicing (list of pitches)
        target: Target voicing (list of pitches)
        perm: Permutation mapping source voices to target voices

    Returns:
        Total absolute displacement
    """
    return sum(abs(source[i] - target[perm[i]]) for i in range(len(source)))


def optimal_assignment(
    source: List[int],
    target: List[int]
) -> Tuple[int, List[int]]:
    """
    Find the optimal voice-leading assignment (minimum cost permutation).

    Uses brute-force for small n (n ≤ 8) which is suitable for
    musical applications. For larger n, use the Hungarian algorithm.

    Parameters:
        source: Source voicing
        target: Target voicing

    Returns:
        min_cost: Minimum total displacement
        best_perm: Optimal permutation (as list)

    Time complexity: O(n! * n) for brute-force
    """
    n = len(source)
    assert len(target) == n, "Voicings must have equal cardinality"

    best_cost = float('inf')
    best_perm = list(range(n))

    for perm in permutations(range(n)):
        cost = voice_leading_cost(source, target, list(perm))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)

    return best_cost, best_perm


def voice_leading_distance_matrix(
    chords: List[List[int]]
) -> np.ndarray:
    """
    Compute the pairwise voice-leading distance matrix.

    Parameters:
        chords: List of voicings (each a list of pitches)

    Returns:
        Distance matrix (symmetric, zero diagonal)
    """
    n = len(chords)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            D[i, j], _ = optimal_assignment(chords[i], chords[j])
    return D


# ============================================================
# Algorithm 3: Tropical Envelope Computation
# ============================================================

def tropical_envelope(
    p_x: np.ndarray,
    distortion: np.ndarray,
    n_slopes: int = 50
) -> List[Tuple[float, float]]:
    """
    Compute the tropical (piecewise-linear) envelope of R(D).

    R(D) = sup_{s ≥ 0} { L(s) - s*D }

    where L(s) = inf_W { I(X;Y) + s * E[d(X,Y)] }.

    Each s gives an affine lower bound on R(D).

    Parameters:
        p_x: Source distribution
        distortion: Distortion matrix
        n_slopes: Number of slope values to evaluate

    Returns:
        List of (slope, intercept) pairs defining affine lower bounds
    """
    betas = np.linspace(0.01, 20, n_slopes)
    affine_bounds = []

    for beta in betas:
        rate, dist, _ = blahut_arimoto(p_x, distortion, beta)
        rate_bits = rate / np.log(2)
        # The affine function through (dist, rate_bits) with slope -beta/ln(2)
        slope = -beta / np.log(2)
        intercept = rate_bits - slope * dist
        affine_bounds.append((slope, intercept))

    return affine_bounds


def evaluate_tropical_envelope(
    affine_bounds: List[Tuple[float, float]],
    D: float
) -> float:
    """
    Evaluate the tropical envelope at distortion D.

    R(D) ≈ max_{(m,b) ∈ A} { m*D + b }
    """
    return max(m * D + b for m, b in affine_bounds)


# ============================================================
# Algorithm 4: Voice-Leading Rate-Distortion Analysis
# ============================================================

def voice_leading_rd_analysis(
    chords: List[List[int]],
    chord_names: List[str],
    distribution: np.ndarray,
    n_points: int = 80
) -> Dict:
    """
    Complete rate-distortion analysis for a chord repertoire.

    Parameters:
        chords: List of voicings
        chord_names: Names of chords
        distribution: Probability distribution over chords
        n_points: Number of R(D) curve points

    Returns:
        Dictionary with analysis results
    """
    # Compute distortion matrix
    dist_matrix = voice_leading_distance_matrix(chords)

    # Compute R(D) curve
    distortions, rates = compute_rd_curve(distribution, dist_matrix, n_points)

    # Compute tropical envelope
    envelope = tropical_envelope(distribution, dist_matrix)

    # Source entropy
    H_X = -sum(p * np.log2(p) for p in distribution if p > 0)

    return {
        'chords': chords,
        'chord_names': chord_names,
        'distribution': distribution.tolist(),
        'distortion_matrix': dist_matrix.tolist(),
        'rd_curve': {
            'distortions': distortions.tolist(),
            'rates': rates.tolist()
        },
        'tropical_envelope': envelope,
        'source_entropy': H_X,
    }


if __name__ == "__main__":
    # Example: analyze a triad repertoire
    chords = [
        [60, 64, 67],  # C major
        [62, 65, 69],  # D minor
        [64, 67, 71],  # E minor
        [65, 69, 72],  # F major
        [67, 71, 74],  # G major
        [69, 72, 76],  # A minor
    ]
    names = ['C', 'Dm', 'Em', 'F', 'G', 'Am']
    dist = np.array([0.25, 0.10, 0.10, 0.20, 0.25, 0.10])

    result = voice_leading_rd_analysis(chords, names, dist)

    print(f"Source entropy: {result['source_entropy']:.4f} bits")
    print(f"Distortion matrix:\n{np.array(result['distortion_matrix'])}")
    print(f"\nR(D) curve computed with {len(result['rd_curve']['distortions'])} points")
    print(f"D range: [{min(result['rd_curve']['distortions']):.2f}, {max(result['rd_curve']['distortions']):.2f}]")
    print(f"R range: [{min(result['rd_curve']['rates']):.4f}, {max(result['rd_curve']['rates']):.4f}]")
