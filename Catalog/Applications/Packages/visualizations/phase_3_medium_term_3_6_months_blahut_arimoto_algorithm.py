#!/usr/bin/env python3
"""
Algorithms for Finite Rate-Distortion Theory and Voice-Leading Geometry

Implements:
1. Blahut-Arimoto algorithm for finite R(D) computation
2. Voice-leading distance via optimal assignment
3. Tropical envelope construction
4. Voice-leading category composition
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional


# ============================================================================
# Algorithm 1: Blahut-Arimoto for Finite Rate-Distortion
# ============================================================================

def blahut_arimoto(
    p_x: np.ndarray,
    d: np.ndarray,
    beta: float,
    n_iter: int = 500,
    tol: float = 1e-12,
) -> Tuple[np.ndarray, float, float]:
    """
    Blahut-Arimoto algorithm for computing the rate-distortion function.
    
    Solves: min_{Q(y|x)} I(X;Y) subject to E[d(X,Y)] ≤ D
    via the Lagrangian: min_{Q} I(X;Y) + β·E[d(X,Y)]
    
    Parameters
    ----------
    p_x : array of shape (n_x,)
        Source distribution.
    d : array of shape (n_x, n_y)
        Distortion matrix. d[i,j] = distortion between source i and reproduction j.
    beta : float >= 0
        Lagrange multiplier (slope parameter). Larger beta → smaller distortion.
    n_iter : int
        Maximum iterations.
    tol : float
        Convergence tolerance.
    
    Returns
    -------
    channel : array of shape (n_x, n_y)
        Optimal conditional distribution Q*(y|x).
    rate : float
        Mutual information I(X;Y) in nats.
    distortion : float
        Expected distortion E[d(X,Y)].
    
    Complexity
    ----------
    Time: O(n_iter * n_x * n_y)
    Space: O(n_x * n_y)
    
    Convergence: Linear convergence to the global optimum (convex problem).
    """
    n_x = len(p_x)
    n_y = d.shape[1]
    
    # Initialize output distribution uniformly
    q_y = np.ones(n_y) / n_y
    channel = np.ones((n_x, n_y)) / n_y
    
    for iteration in range(n_iter):
        old_channel = channel.copy()
        
        # E-step: update channel Q(y|x)
        for i in range(n_x):
            for j in range(n_y):
                channel[i, j] = q_y[j] * np.exp(-beta * d[i, j])
            row_sum = channel[i].sum()
            if row_sum > 0:
                channel[i] /= row_sum
        
        # M-step: update output marginal q(y)
        q_y = p_x @ channel
        q_y = np.maximum(q_y, 1e-30)
        
        # Check convergence
        if np.max(np.abs(channel - old_channel)) < tol:
            break
    
    # Compute rate and distortion
    rate = _mutual_information(p_x, channel)
    distortion = _expected_distortion(p_x, channel, d)
    
    return channel, rate, distortion


def compute_rd_curve(
    p_x: np.ndarray,
    d: np.ndarray,
    n_points: int = 100,
    beta_range: Tuple[float, float] = (0.01, 100.0),
) -> List[Tuple[float, float]]:
    """
    Compute the full rate-distortion curve R(D).
    
    Sweeps the Lagrange multiplier β from beta_range[0] to beta_range[1]
    and returns (D, R) pairs sorted by D.
    
    The curve R(D) is convex and nonincreasing (verified formally in Lean).
    
    Parameters
    ----------
    p_x : array
        Source distribution.
    d : array
        Distortion matrix.
    n_points : int
        Number of points on the curve.
    beta_range : tuple
        Range of Lagrange multipliers.
    
    Returns
    -------
    List of (distortion, rate) pairs, sorted by distortion.
    """
    betas = np.logspace(
        np.log10(beta_range[0]),
        np.log10(beta_range[1]),
        n_points
    )
    
    results = []
    for beta in betas:
        _, rate, dist = blahut_arimoto(p_x, d, beta)
        results.append((dist, rate))
    
    return sorted(results, key=lambda x: x[0])


# ============================================================================
# Algorithm 2: Voice-Leading Distance
# ============================================================================

def voice_leading_distance(
    v: List[int],
    w: List[int],
) -> Tuple[int, List[int]]:
    """
    Compute minimum voice-leading distance between two chords.
    
    Finds the permutation σ minimizing Σᵢ |v[i] - w[σ(i)]|.
    
    For n voices, this is equivalent to the linear assignment problem
    and can be solved in O(n!) by brute force (sufficient for musical
    applications where n ≤ 6) or O(n³) by the Hungarian algorithm.
    
    Parameters
    ----------
    v, w : lists of integers
        Pitch sequences (same length).
    
    Returns
    -------
    distance : int
        Minimum total voice displacement.
    best_perm : list
        Optimal voice assignment permutation.
    
    The distance satisfies (formally verified in Lean):
    - d(v, v) = 0
    - d(v, w) ≥ 0
    - d(v, w) ≤ d(v, u) + d(u, w)  (triangle inequality)
    """
    n = len(v)
    assert len(w) == n, "Chords must have same number of voices"
    
    best_cost = float('inf')
    best_perm = list(range(n))
    
    for perm in permutations(range(n)):
        cost = sum(abs(v[i] - w[perm[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)
    
    return best_cost, best_perm


def voice_leading_compose(
    perm1: List[int],
    perm2: List[int],
) -> List[int]:
    """
    Compose two voice-leading permutations.
    
    Composition in the voice-leading category: if σ maps A→B and τ maps B→C,
    then τ∘σ maps A→C.
    
    Key property (formally verified):
        cost(τ∘σ) ≤ cost(σ) + cost(τ)
    """
    n = len(perm1)
    return [perm2[perm1[i]] for i in range(n)]


# ============================================================================
# Algorithm 3: Tropical Envelope Construction
# ============================================================================

def tropical_envelope(
    p_x: np.ndarray,
    d: np.ndarray,
    n_tangents: int = 50,
) -> List[Tuple[float, float]]:
    """
    Construct the tropical (piecewise-linear) envelope of R(D).
    
    R(D) = sup_{(m,b) ∈ A} (m·D + b)
    
    where A is a finite set of affine functionals derived from the
    Lagrangian dual.
    
    For each β ≥ 0:
        Φ(β) = inf_K { I(X;Y) + β·E[d(X,Y)] }
    gives an affine minorant:
        R(D) ≥ Φ(β) - β·D
    
    This is formally verified in Lean (rateDistortion_affine_lower_bound).
    
    Parameters
    ----------
    p_x : array
        Source distribution.
    d : array
        Distortion matrix.
    n_tangents : int
        Number of tangent lines to compute.
    
    Returns
    -------
    List of (slope, intercept) pairs defining the tropical envelope.
    """
    betas = np.logspace(-1, 3, n_tangents)
    affine_funcs = []
    
    for beta in betas:
        _, mi, dist = blahut_arimoto(p_x, d, beta)
        phi = mi + beta * dist
        slope = -beta
        intercept = phi
        affine_funcs.append((slope, intercept))
    
    return affine_funcs


def evaluate_tropical_envelope(
    affine_funcs: List[Tuple[float, float]],
    D: float,
) -> float:
    """Evaluate tropical envelope at distortion D."""
    return max(s * D + b for s, b in affine_funcs)


# ============================================================================
# Helper Functions
# ============================================================================

def _mutual_information(p_x: np.ndarray, channel: np.ndarray) -> float:
    """Compute mutual information I(X;Y)."""
    p_xy = p_x[:, np.newaxis] * channel
    p_y = p_xy.sum(axis=0)
    
    mi = 0.0
    for i in range(len(p_x)):
        for j in range(channel.shape[1]):
            if p_xy[i, j] > 1e-15 and p_x[i] > 1e-15 and p_y[j] > 1e-15:
                mi += p_xy[i, j] * np.log(p_xy[i, j] / (p_x[i] * p_y[j]))
    return mi


def _expected_distortion(
    p_x: np.ndarray,
    channel: np.ndarray,
    d: np.ndarray,
) -> float:
    """Compute expected distortion E[d(X,Y)]."""
    p_xy = p_x[:, np.newaxis] * channel
    return np.sum(p_xy * d)


# ============================================================================
# Example: Voice-Leading Rate-Distortion
# ============================================================================

def voice_leading_rd_example():
    """
    Complete example: compute R(D) for a repertoire of triads
    with voice-leading distortion.
    
    This demonstrates the grand bridge theorem:
    voice-leading distortion induces a valid rate-distortion problem.
    """
    # Define chord repertoire
    chords = {
        'C major': [0, 4, 7],
        'C minor': [0, 3, 7],
        'E minor': [4, 7, 11],
        'G major': [7, 11, 2],
    }
    chord_list = list(chords.values())
    chord_names = list(chords.keys())
    n = len(chord_list)
    
    # Source distribution (e.g., from a corpus analysis)
    p_x = np.array([0.4, 0.2, 0.25, 0.15])
    
    # Voice-leading distortion matrix
    d_vl = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_vl[i, j], _ = voice_leading_distance(chord_list[i], chord_list[j])
    
    print("Voice-Leading Distortion Matrix:")
    print(f"{'':>12}", end='')
    for name in chord_names:
        print(f"{name:>10}", end='')
    print()
    for i, name in enumerate(chord_names):
        print(f"{name:>12}", end='')
        for j in range(n):
            print(f"{d_vl[i,j]:>10.0f}", end='')
        print()
    
    # Compute R(D) curve
    rd_curve = compute_rd_curve(p_x, d_vl)
    
    print("\nVoice-Leading R(D) curve (bits):")
    for D, R in rd_curve[::20]:
        print(f"  D = {D:.2f} semitones, R = {R/np.log(2):.4f} bits")
    
    # Tropical envelope
    envelope = tropical_envelope(p_x, d_vl)
    
    return rd_curve, envelope


if __name__ == "__main__":
    voice_leading_rd_example()
