#!/usr/bin/env python3
"""
Tropical Certified Information Dynamics — Algorithms

Complete implementations of the certification algorithms with docstrings,
type hints, complexity analysis, and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


# ========================================================================
# Data Structures
# ========================================================================

@dataclass
class KineticCertificate:
    """Certificate of kinetic tropical margin stability.

    Attributes:
        margin: The score margin at t=0 (must be > 0 for valid certificate).
        lipschitz_constant: Max |v_i|, the worst-case score drift rate.
        certified_time: The guaranteed stability time T = m/(2L+1).
        winning_class: Index of the winning class at t=0.
    """
    margin: float
    lipschitz_constant: float
    certified_time: float
    winning_class: int


@dataclass
class PolyhedralCertificate:
    """Certificate of polyhedral membership stability.

    Attributes:
        min_slack: Minimum slack across all constraints.
        stability_radius: The certified perturbation radius.
        slack_vector: Individual slacks for each constraint.
        critical_constraint: Index of the tightest constraint.
    """
    min_slack: float
    stability_radius: float
    slack_vector: np.ndarray
    critical_constraint: int


@dataclass
class SpreadContractionResult:
    """Result of spread contraction computation.

    Attributes:
        original_spread: Spread of the original vector.
        coarsened_spread: Spread after coarse-graining.
        contraction_ratio: coarsened_spread / original_spread.
        coarsened_vector: The coarse-grained output vector.
    """
    original_spread: float
    coarsened_spread: float
    contraction_ratio: float
    coarsened_vector: np.ndarray


# ========================================================================
# Algorithm 1: Tropical Affine Score Computation
# ========================================================================

def trop_affine_score(w: np.ndarray, x: np.ndarray, b: float) -> float:
    """Compute the tropical affine score: b + max_i(w_i + x_i).

    This is the fundamental building block for tropicalized neural networks.
    A ReLU network layer computes max(0, Wx + b), which in tropical arithmetic
    corresponds to multiple tropical affine scores.

    Args:
        w: Weight vector of shape (n,).
        x: Input vector of shape (n,).
        b: Bias scalar.

    Returns:
        The tropical affine score.

    Complexity: O(n) time, O(1) space.

    Example:
        >>> trop_affine_score(np.array([1.0, 0.5]), np.array([2.0, 3.0]), 0.1)
        3.6
    """
    return b + np.max(w + x)


# ========================================================================
# Algorithm 2: Kinetic Certificate Computation
# ========================================================================

def compute_kinetic_certificate(
    weights: List[np.ndarray],
    biases: List[float],
    x0: np.ndarray,
    v: np.ndarray
) -> KineticCertificate:
    """Compute a kinetic tropical margin stability certificate.

    Given K competing tropical affine scores and a linear trajectory
    x(t) = x0 + t*v, certifies that the winning class at t=0 remains
    the winner for |t| < T.

    Algorithm:
        1. Compute all K scores at t=0.
        2. Find the winner and the margin to the runner-up.
        3. Compute L = max_i |v_i|.
        4. Return T = margin / (2*L + 1).

    Args:
        weights: List of K weight vectors, each shape (n,).
        biases: List of K bias scalars.
        x0: Initial position, shape (n,).
        v: Velocity vector, shape (n,).

    Returns:
        KineticCertificate with the certified stability time.

    Complexity: O(K*n) time, O(K) space.

    Example:
        >>> w1, w2 = np.array([1.0, 0.5]), np.array([0.3, 0.9])
        >>> cert = compute_kinetic_certificate([w1, w2], [0.5, -0.1],
        ...     np.array([1.0, 2.0]), np.array([0.1, -0.05]))
        >>> cert.certified_time > 0
        True
    """
    scores = [trop_affine_score(w, x0, b) for w, b in zip(weights, biases)]
    sorted_indices = np.argsort(scores)[::-1]
    winner = sorted_indices[0]
    runner_up = sorted_indices[1]
    margin = scores[winner] - scores[runner_up]

    if margin <= 0:
        return KineticCertificate(
            margin=margin,
            lipschitz_constant=np.max(np.abs(v)),
            certified_time=0.0,
            winning_class=winner
        )

    L = np.max(np.abs(v))
    T = margin / (2 * L + 1)

    return KineticCertificate(
        margin=margin,
        lipschitz_constant=L,
        certified_time=T,
        winning_class=winner
    )


def verify_kinetic_certificate(
    cert: KineticCertificate,
    weights: List[np.ndarray],
    biases: List[float],
    x0: np.ndarray,
    v: np.ndarray,
    n_samples: int = 1000
) -> bool:
    """Empirically verify a kinetic certificate by sampling the trajectory.

    Args:
        cert: The certificate to verify.
        weights, biases, x0, v: The problem parameters.
        n_samples: Number of time samples within the certified interval.

    Returns:
        True if the certificate holds for all sampled times.
    """
    if cert.certified_time <= 0:
        return True

    times = np.linspace(-cert.certified_time * 0.999, cert.certified_time * 0.999,
                        n_samples)
    for t in times:
        xt = x0 + t * v
        scores = [trop_affine_score(w, xt, b)
                  for w, b in zip(weights, biases)]
        if np.argmax(scores) != cert.winning_class:
            return False
    return True


# ========================================================================
# Algorithm 3: Spread Contraction Computation
# ========================================================================

def compute_spread_contraction(
    x: np.ndarray,
    partition: List[List[int]]
) -> SpreadContractionResult:
    """Compute the spread before and after coarse-graining.

    Implements the tropical data processing inequality:
    spread(T_π(x)) ≤ spread(x).

    Algorithm:
        1. Compute spread(x) = max(x) - min(x).
        2. For each block B in the partition, compute max(x[B]).
        3. Compute spread of the coarsened vector.
        4. Return both spreads and the contraction ratio.

    Args:
        x: Input score vector, shape (n,).
        partition: List of blocks, each a list of indices.
            Must be a partition of {0, ..., n-1} with each block nonempty.

    Returns:
        SpreadContractionResult with original and coarsened spreads.

    Complexity: O(n) time, O(m) space where m = len(partition).

    Example:
        >>> x = np.array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0])
        >>> result = compute_spread_contraction(x, [[0,1], [2,3], [4,5]])
        >>> result.contraction_ratio <= 1.0
        True
    """
    orig_spread = np.max(x) - np.min(x)
    coarsened = np.array([np.max(x[block]) for block in partition])
    coarse_spread = np.max(coarsened) - np.min(coarsened)

    ratio = coarse_spread / orig_spread if orig_spread > 0 else 0.0

    return SpreadContractionResult(
        original_spread=orig_spread,
        coarsened_spread=coarse_spread,
        contraction_ratio=ratio,
        coarsened_vector=coarsened
    )


# ========================================================================
# Algorithm 4: Polyhedral Stability Radius
# ========================================================================

def compute_polyhedral_certificate(
    A: np.ndarray,
    b: np.ndarray,
    x: np.ndarray
) -> PolyhedralCertificate:
    """Compute an explicit polyhedral membership stability certificate.

    For a polyhedron P = {x : Ax ≤ b}, certifies that all points within
    ℓ∞-distance ε of x lie in P, where ε = min_j s_j(x)/(R_j + 1).

    Algorithm:
        1. Compute slack s_j = b_j - (Ax)_j for each constraint j.
        2. Compute row norm R_j = ∑_i |A_{ji}| for each constraint j.
        3. Compute radius_j = s_j / (R_j + 1) for each constraint j.
        4. Return ε = min_j radius_j.

    Args:
        A: Constraint matrix, shape (k, n).
        b: Constraint bounds, shape (k,).
        x: Query point, shape (n,).

    Returns:
        PolyhedralCertificate with the stability radius.

    Complexity: O(kn) time, O(k) space.

    Example:
        >>> A = np.array([[1, 0], [-1, 0], [0, 1], [0, -1]], dtype=float)
        >>> b = np.ones(4)
        >>> cert = compute_polyhedral_certificate(A, b, np.array([0.0, 0.0]))
        >>> cert.stability_radius
        0.5
    """
    slack = b - A @ x
    if np.any(slack <= 0):
        critical = int(np.argmin(slack))
        return PolyhedralCertificate(
            min_slack=float(np.min(slack)),
            stability_radius=0.0,
            slack_vector=slack,
            critical_constraint=critical
        )

    row_norms = np.sum(np.abs(A), axis=1)
    radii = slack / (row_norms + 1)
    critical = int(np.argmin(radii))

    return PolyhedralCertificate(
        min_slack=float(np.min(slack)),
        stability_radius=float(np.min(radii)),
        slack_vector=slack,
        critical_constraint=critical
    )


# ========================================================================
# Algorithm 5: Tropical Mutual Information
# ========================================================================

def compute_tmi(K: np.ndarray) -> float:
    """Compute the tropical mutual information of a channel.

    TMI(K) = max_{x1,x2} δ_K(x1, x2) where
    δ_K(x1,x2) = max_y(K[x1,y] - K[x2,y]) + max_y(K[x2,y] - K[x1,y]).

    Args:
        K: Channel matrix, shape (n_inputs, n_outputs).

    Returns:
        The tropical mutual information.

    Complexity: O(n_inputs² × n_outputs) time.
    """
    n_in = K.shape[0]
    max_dist = 0.0
    for i in range(n_in):
        for j in range(n_in):
            forward = np.max(K[i] - K[j])
            backward = np.max(K[j] - K[i])
            dist = forward + backward
            max_dist = max(max_dist, dist)
    return max_dist


def postprocess_channel(K: np.ndarray, g: List[int]) -> np.ndarray:
    """Post-process a channel by a deterministic map.

    (K▷g)(x,z) = max{K(x,y) : g(y) = z}.

    Args:
        K: Channel matrix, shape (n_inputs, n_outputs).
        g: Deterministic map from outputs to new outputs.

    Returns:
        Post-processed channel matrix.
    """
    n_in = K.shape[0]
    n_out_new = max(g) + 1
    Kg = np.full((n_in, n_out_new), -np.inf)
    for y, z in enumerate(g):
        Kg[:, z] = np.maximum(Kg[:, z], K[:, y])
    return Kg


# ========================================================================
# Algorithm 6: Combined Kinetic Polyhedral Certificate
# ========================================================================

def compute_kinetic_polyhedral_certificate(
    A: np.ndarray,
    b: np.ndarray,
    x0: np.ndarray,
    v: np.ndarray
) -> Tuple[float, float]:
    """Compute a combined kinetic polyhedral stability certificate.

    Certifies that x(t) = x0 + t*v remains in P = {x : Ax ≤ b}
    for |t| < T.

    Algorithm:
        1. Compute spatial stability radius δ.
        2. Compute speed bound S = ∑|v_i| + 1.
        3. Return T = δ / S.

    Args:
        A, b: Polyhedron parameters.
        x0: Initial position.
        v: Velocity vector.

    Returns:
        Tuple (stability_radius, certified_time).
    """
    cert = compute_polyhedral_certificate(A, b, x0)
    if cert.stability_radius <= 0:
        return (0.0, 0.0)

    speed = np.sum(np.abs(v)) + 1
    T = cert.stability_radius / speed

    return (cert.stability_radius, T)


# ========================================================================
# Example Usage
# ========================================================================

if __name__ == "__main__":
    print("Algorithm Examples")
    print("=" * 50)

    # Kinetic certificate
    w1 = np.array([1.0, 0.5, 0.8])
    w2 = np.array([0.3, 0.9, 0.2])
    x0 = np.array([1.0, 2.0, 1.5])
    v = np.array([0.1, -0.05, 0.2])

    cert = compute_kinetic_certificate([w1, w2], [0.5, -0.1], x0, v)
    print(f"\nKinetic Certificate:")
    print(f"  Margin: {cert.margin:.4f}")
    print(f"  Lipschitz constant: {cert.lipschitz_constant:.4f}")
    print(f"  Certified time: {cert.certified_time:.4f}")
    print(f"  Winning class: {cert.winning_class}")
    print(f"  Verified: {verify_kinetic_certificate(cert, [w1, w2], [0.5, -0.1], x0, v)}")

    # Spread contraction
    x = np.array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0])
    result = compute_spread_contraction(x, [[0, 1], [2, 3], [4, 5], [6, 7]])
    print(f"\nSpread Contraction:")
    print(f"  Original spread: {result.original_spread:.4f}")
    print(f"  Coarsened spread: {result.coarsened_spread:.4f}")
    print(f"  Contraction ratio: {result.contraction_ratio:.4f}")

    # Polyhedral certificate
    A = np.array([[1, 0, 0], [-1, 0, 0], [0, 1, 0],
                  [0, -1, 0], [0, 0, 1], [0, 0, -1]], dtype=float)
    b_vec = np.ones(6)
    pcert = compute_polyhedral_certificate(A, b_vec, np.array([0.3, -0.2, 0.1]))
    print(f"\nPolyhedral Certificate:")
    print(f"  Min slack: {pcert.min_slack:.4f}")
    print(f"  Stability radius: {pcert.stability_radius:.4f}")
    print(f"  Critical constraint: {pcert.critical_constraint}")
