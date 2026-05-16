#!/usr/bin/env python3
"""
Algorithms for Finite Rate-Distortion Theory and Voice-Leading Geometry

Implements the core algorithms from the research paper:
1. Blahut-Arimoto algorithm for computing R(D)
2. Optimal voice-leading assignment (Hungarian algorithm)
3. Voice-leading rate-distortion computation
4. Tropical/piecewise-linear envelope extraction

Each algorithm has docstrings, type hints, and complexity analysis.
"""

import numpy as np
from itertools import permutations
from typing import Tuple, List, Optional


# ============================================================================
# Algorithm 1: Blahut-Arimoto for Finite Rate-Distortion
# ============================================================================

def blahut_arimoto(
    p_x: np.ndarray,
    d: np.ndarray,
    beta: float = 1.0,
    max_iter: int = 500,
    tol: float = 1e-10
) -> Tuple[float, np.ndarray, float]:
    """
    Blahut-Arimoto algorithm for computing R(D) at a given slope parameter β.
    
    Computes the channel W that minimizes I(X;Y) + β·E[d(X,Y)] for a given β ≥ 0.
    The pair (D(β), R(β)) traces out the R(D) curve as β varies.
    
    Algorithm:
        1. Initialize W uniformly
        2. Repeat until convergence:
           a. q(y) = Σ_x p(x) W(y|x)              [output marginal]
           b. W(y|x) ∝ q(y) exp(-β d(x,y))        [channel update]
        3. Compute I(X;Y) and E[d(X,Y)]
    
    Complexity:
        Time: O(max_iter · |X| · |Y|)
        Space: O(|X| · |Y|)
    
    Convergence: Guaranteed to converge to the global optimum (the objective
    I + β·D is convex in W). Rate: geometric, typically O(1/ε) iterations.
    
    Args:
        p_x: Source distribution, shape (|X|,)
        d: Distortion matrix, shape (|X|, |Y|)
        beta: Lagrange multiplier (slope parameter) ≥ 0
        max_iter: Maximum number of iterations
        tol: Convergence tolerance on mutual information
    
    Returns:
        rate: Mutual information I(X;Y) in nats
        channel: Optimal channel W[x, y] = P(Y=y|X=x)
        distortion: Expected distortion E[d(X,Y)]
    """
    n_x, n_y = d.shape
    assert len(p_x) == n_x, "Source distribution size must match distortion matrix"
    assert np.abs(np.sum(p_x) - 1.0) < 1e-8, "Source must be a probability distribution"
    
    # Initialize channel uniformly
    W = np.ones((n_x, n_y)) / n_y
    
    prev_rate = float('inf')
    
    for iteration in range(max_iter):
        # E-step: compute output marginal
        q_y = p_x @ W
        q_y = np.maximum(q_y, 1e-300)
        
        # M-step: update channel
        for x in range(n_x):
            log_weights = np.log(q_y) - beta * d[x]
            log_weights -= np.max(log_weights)  # numerical stability
            W[x] = np.exp(log_weights)
            W[x] /= np.sum(W[x])
        
        # Compute mutual information
        q_y = p_x @ W
        q_y = np.maximum(q_y, 1e-300)
        rate = 0.0
        for x in range(n_x):
            for y in range(n_y):
                joint = p_x[x] * W[x, y]
                if joint > 1e-300:
                    rate += joint * np.log(joint / (p_x[x] * q_y[y]))
        
        # Check convergence
        if abs(rate - prev_rate) < tol:
            break
        prev_rate = rate
    
    # Compute distortion
    distortion = np.sum(p_x[:, None] * W * d)
    
    return rate, W, distortion


def compute_rd_curve(
    p_x: np.ndarray,
    d: np.ndarray,
    n_points: int = 100,
    beta_range: Tuple[float, float] = (0.01, 50.0)
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the full R(D) curve by sweeping the Lagrange multiplier β.
    
    Complexity: O(n_points · max_iter · |X| · |Y|)
    
    Args:
        p_x: Source distribution
        d: Distortion matrix
        n_points: Number of points on the curve
        beta_range: Range of β values to sweep
    
    Returns:
        D_values: Array of distortion values
        R_values: Array of rate values (in nats)
    """
    betas = np.logspace(np.log10(beta_range[0]), np.log10(beta_range[1]), n_points)
    
    D_values = []
    R_values = []
    
    for beta in betas:
        rate, _, distortion = blahut_arimoto(p_x, d, beta=beta)
        D_values.append(distortion)
        R_values.append(max(0, rate))
    
    # Sort by distortion
    idx = np.argsort(D_values)
    return np.array(D_values)[idx], np.array(R_values)[idx]


# ============================================================================
# Algorithm 2: Optimal Voice-Leading Assignment
# ============================================================================

def optimal_voice_leading(
    V: List[int],
    W: List[int]
) -> Tuple[float, List[int]]:
    """
    Find the optimal voice-leading between two equal-cardinality voicings.
    
    Minimizes total displacement Σ_i |V[i] - W[σ(i)]| over all permutations σ.
    
    For small n (≤ 8), uses brute-force enumeration.
    For larger n, this should use the Hungarian algorithm.
    
    Complexity:
        Brute force: O(n! · n)
        Hungarian: O(n³)
    
    Args:
        V: Source voicing (list of pitch values)
        W: Target voicing (list of pitch values)
    
    Returns:
        cost: Minimum total displacement
        assignment: Optimal permutation (list)
    """
    n = len(V)
    assert len(W) == n, "Voicings must have equal cardinality"
    
    if n <= 8:
        # Brute force for small n
        min_cost = float('inf')
        best_perm = list(range(n))
        for perm in permutations(range(n)):
            cost = sum(abs(V[i] - W[perm[i]]) for i in range(n))
            if cost < min_cost:
                min_cost = cost
                best_perm = list(perm)
        return min_cost, best_perm
    else:
        # For larger n, use sorted assignment as approximation
        V_sorted = sorted(enumerate(V), key=lambda x: x[1])
        W_sorted = sorted(enumerate(W), key=lambda x: x[1])
        perm = [0] * n
        for (vi, _), (wi, _) in zip(V_sorted, W_sorted):
            perm[vi] = wi
        cost = sum(abs(V[i] - W[perm[i]]) for i in range(n))
        return cost, perm


def voice_leading_distance_matrix(
    voicings: List[List[int]]
) -> np.ndarray:
    """
    Compute the pairwise voice-leading distance matrix.
    
    Complexity: O(n² · k! · k) where n = number of voicings, k = voicing size
    
    Args:
        voicings: List of voicings
    
    Returns:
        Distance matrix (n × n)
    """
    n = len(voicings)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            cost, _ = optimal_voice_leading(voicings[i], voicings[j])
            D[i, j] = cost
            D[j, i] = cost
    return D


# ============================================================================
# Algorithm 3: Voice-Leading Rate-Distortion
# ============================================================================

def voice_leading_rate_distortion(
    repertoire: List[List[int]],
    prototypes: List[List[int]],
    mu: np.ndarray,
    n_points: int = 100
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute the rate-distortion function for voice-leading distortion.
    
    Given a repertoire Ω of voicings with distribution μ and a prototype
    space Π, computes R_VL(D) = inf{I(X;Y) : E[d_VL(X,Y)] ≤ D}
    where d_VL is the voice-leading distance.
    
    This is the computational realization of the bridge theorem:
    voice-leading distortion induces a finite rate-distortion problem.
    
    Complexity: O(|Ω| · |Π| · k! · k + n_points · BA_cost)
    
    Args:
        repertoire: List of source voicings
        prototypes: List of prototype voicings
        mu: Probability distribution over repertoire
        n_points: Number of R(D) curve points
    
    Returns:
        D_values: Distortion values
        R_values: Rate values (nats)
        distortion_matrix: Voice-leading distortion matrix
    """
    n_rep = len(repertoire)
    n_proto = len(prototypes)
    
    # Build voice-leading distortion matrix
    d = np.zeros((n_rep, n_proto))
    for i, V in enumerate(repertoire):
        for j, W in enumerate(prototypes):
            d[i, j], _ = optimal_voice_leading(V, W)
    
    D_values, R_values = compute_rd_curve(mu, d, n_points)
    
    return D_values, R_values, d


# ============================================================================
# Algorithm 4: Tropical Envelope Extraction
# ============================================================================

def tropical_envelope(
    D_values: np.ndarray,
    R_values: np.ndarray,
    n_supporting: int = 10
) -> List[Tuple[float, float]]:
    """
    Extract the tropical/piecewise-linear envelope of an R(D) curve.
    
    R(D) = sup_{(m,b) ∈ A} (m·D + b) for a finite set A of affine functionals.
    
    Approximates this by computing supporting hyperplanes at sample points.
    
    The tropical interpretation: under sign change, R(D) = -inf_{(m,b)} (-m·D - b),
    which is a min-plus tropical polynomial.
    
    Complexity: O(n · n_supporting) where n = len(D_values)
    
    Args:
        D_values: Distortion values (sorted)
        R_values: Rate values
        n_supporting: Number of supporting hyperplanes
    
    Returns:
        List of (slope, intercept) pairs defining the tropical envelope
    """
    # Compute numerical derivatives
    dR_dD = np.gradient(R_values, D_values)
    
    # Sample supporting hyperplanes at evenly spaced points
    indices = np.linspace(0, len(D_values) - 1, n_supporting + 2, dtype=int)[1:-1]
    
    envelope = []
    for idx in indices:
        D0 = D_values[idx]
        R0 = R_values[idx]
        slope = dR_dD[idx]
        intercept = R0 - slope * D0
        envelope.append((slope, intercept))
    
    return envelope


# ============================================================================
# Example usage
# ============================================================================

if __name__ == '__main__':
    print("=== Finite Rate-Distortion Algorithms ===\n")
    
    # Example 1: Binary source
    p_x = np.array([0.7, 0.3])
    d = np.array([[0, 1], [1, 0]])
    
    D_vals, R_vals = compute_rd_curve(p_x, d, n_points=50)
    print(f"Binary source R(D) curve: {len(D_vals)} points computed")
    print(f"  D range: [{D_vals[0]:.4f}, {D_vals[-1]:.4f}]")
    print(f"  R range: [{R_vals[-1]:.4f}, {R_vals[0]:.4f}] nats")
    
    # Example 2: Voice-leading
    repertoire = [[0, 4, 7], [0, 3, 7], [0, 5, 9], [2, 7, 11]]
    prototypes = [[0, 4, 7], [2, 7, 11]]
    mu = np.array([0.3, 0.2, 0.3, 0.2])
    
    D_vl, R_vl, d_mat = voice_leading_rate_distortion(repertoire, prototypes, mu)
    print(f"\nVoice-leading R(D): {len(D_vl)} points")
    print(f"  Distortion matrix:\n{d_mat}")
    
    # Example 3: Tropical envelope
    envelope = tropical_envelope(D_vals, R_vals)
    print(f"\nTropical envelope: {len(envelope)} supporting hyperplanes")
    for i, (m, b) in enumerate(envelope[:5]):
        print(f"  Affine {i+1}: R ≥ {m:.4f}·D + {b:.4f}")
