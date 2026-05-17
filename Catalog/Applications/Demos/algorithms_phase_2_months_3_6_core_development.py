#!/usr/bin/env python3
"""
Algorithms for Tropical Kinetic Certification

Implements the core algorithms derived from the formal theorems:
1. Kinetic margin certificate computation
2. Tropical coarse-graining and spread analysis
3. Polyhedral slack-based stability certificates
4. Combined kinetic-polyhedral certification
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class KineticCertificate:
    """Certificate for kinetic tropical margin stability."""
    margin: float
    lipschitz_constant: float
    stability_radius: float
    winning_class: int
    is_certified: bool

    def __repr__(self) -> str:
        return (f"KineticCertificate(margin={self.margin:.6f}, "
                f"L={self.lipschitz_constant:.6f}, "
                f"ε={self.stability_radius:.6f}, "
                f"winner={self.winning_class}, "
                f"certified={self.is_certified})")


@dataclass
class PolyhedralCertificate:
    """Certificate for polyhedral membership stability."""
    slacks: np.ndarray
    row_norms: np.ndarray
    stability_radius: float
    min_slack: float
    is_interior: bool

    def __repr__(self) -> str:
        return (f"PolyhedralCertificate(ε={self.stability_radius:.6f}, "
                f"min_slack={self.min_slack:.6f}, "
                f"interior={self.is_interior})")


@dataclass
class KineticPolyhedralCertificate:
    """Combined certificate for kinetic polyhedral stability."""
    spatial_radius: float
    time_horizon: float
    velocity_bound: float
    is_certified: bool

    def __repr__(self) -> str:
        return (f"KineticPolyhedralCertificate(δ={self.spatial_radius:.6f}, "
                f"T={self.time_horizon:.6f}, "
                f"certified={self.is_certified})")


# ============================================================================
# Algorithm 1: Kinetic Tropical Margin Certificate
# ============================================================================

def compute_kinetic_certificate(
    weights: List[np.ndarray],
    biases: List[float],
    x0: np.ndarray,
    v: np.ndarray,
    class1: int = 0,
    class2: int = 1
) -> KineticCertificate:
    """
    Compute a kinetic tropical margin stability certificate.

    Given weight vectors and biases for multiple classes, compute the
    certified time interval during which the winning class at t=0
    remains the winner along the trajectory x(t) = x0 + t*v.

    Algorithm:
        1. Compute scores s_i = b_i + max_j(w_{i,j} + x0_j) for each class
        2. Find the winning class (argmax score)
        3. Compute margin m = s_winner - s_runner_up
        4. Compute Lipschitz constant L = max_j |v_j|
        5. Return certificate with ε = m / (2L + 1)

    Complexity: O(C * n) where C = number of classes, n = dimension

    Args:
        weights: List of weight vectors, one per class
        biases: List of bias values, one per class
        x0: Initial position vector
        v: Velocity vector
        class1, class2: Indices of the two classes to compare

    Returns:
        KineticCertificate with certified stability radius
    """
    n = len(x0)

    # Compute scores at t=0
    score1 = biases[class1] + np.max(weights[class1] + x0)
    score2 = biases[class2] + np.max(weights[class2] + x0)

    margin = score1 - score2
    winner = class1 if margin > 0 else class2

    # Lipschitz constant
    L = np.max(np.abs(v))

    # Stability radius
    abs_margin = abs(margin)
    eps = abs_margin / (2 * L + 1) if abs_margin > 0 else 0.0

    return KineticCertificate(
        margin=abs_margin,
        lipschitz_constant=L,
        stability_radius=eps,
        winning_class=winner,
        is_certified=abs_margin > 0
    )


def compute_multiclass_kinetic_certificate(
    weights: List[np.ndarray],
    biases: List[float],
    x0: np.ndarray,
    v: np.ndarray
) -> KineticCertificate:
    """
    Compute kinetic certificate for multi-class tropical classification.

    Finds the minimum pairwise margin between the winning class and all others.

    Complexity: O(C * n) where C = number of classes, n = dimension
    """
    C = len(weights)
    scores = [biases[c] + np.max(weights[c] + x0) for c in range(C)]
    winner = int(np.argmax(scores))

    # Minimum margin to any other class
    min_margin = float('inf')
    for c in range(C):
        if c != winner:
            margin = scores[winner] - scores[c]
            min_margin = min(min_margin, margin)

    L = np.max(np.abs(v))
    eps = min_margin / (2 * L + 1) if min_margin > 0 else 0.0

    return KineticCertificate(
        margin=min_margin,
        lipschitz_constant=L,
        stability_radius=eps,
        winning_class=winner,
        is_certified=min_margin > 0
    )


# ============================================================================
# Algorithm 2: Tropical Coarse-Graining and Spread Analysis
# ============================================================================

def compute_coarse_graining(
    x: np.ndarray,
    partition: List[List[int]]
) -> np.ndarray:
    """
    Compute tropical coarse-graining by taking max over partition blocks.

    Algorithm:
        For each block B in partition:
            output[j] = max_{i in B} x[i]

    Complexity: O(n)

    Args:
        x: Input score vector
        partition: List of index sets forming a partition of {0,...,n-1}

    Returns:
        Coarse-grained vector
    """
    result = np.empty(len(partition))
    for j, block in enumerate(partition):
        result[j] = np.max(x[block])
    return result


def verify_spread_monotonicity(
    x: np.ndarray,
    partition: List[List[int]]
) -> Tuple[float, float, bool]:
    """
    Verify the tropical data processing inequality for a given input and partition.

    Returns (spread_before, spread_after, is_monotone).
    """
    cg = compute_coarse_graining(x, partition)
    spread_before = np.max(x) - np.min(x)
    spread_after = np.max(cg) - np.min(cg)
    return spread_before, spread_after, spread_after <= spread_before + 1e-12


def iterated_coarse_graining(
    x: np.ndarray,
    partitions: List[List[List[int]]]
) -> List[Tuple[np.ndarray, float]]:
    """
    Apply iterated coarse-graining and track spread at each step.

    Demonstrates that spread is monotonically non-increasing.

    Complexity: O(k * n) where k = number of iterations
    """
    results = [(x.copy(), np.max(x) - np.min(x))]
    current = x.copy()

    for partition in partitions:
        current = compute_coarse_graining(current, partition)
        spread = np.max(current) - np.min(current)
        results.append((current.copy(), spread))

    return results


# ============================================================================
# Algorithm 3: Polyhedral Stability Certificate
# ============================================================================

def compute_polyhedral_certificate(
    A: np.ndarray,
    b: np.ndarray,
    x: np.ndarray
) -> PolyhedralCertificate:
    """
    Compute an explicit polyhedral membership stability certificate.

    Algorithm:
        1. Compute slack s_j = b_j - (Ax)_j for each constraint
        2. Compute row norms r_j = sum_i |A_{j,i}|
        3. Compute per-constraint radius: ε_j = s_j / (r_j + 1)
        4. Return ε = min_j ε_j

    Complexity: O(k * n) where k = constraints, n = dimension

    Args:
        A: Constraint matrix (k x n)
        b: Right-hand side vector (k,)
        x: Test point (n,)

    Returns:
        PolyhedralCertificate with certified stability radius
    """
    slacks = b - A @ x
    rn = np.sum(np.abs(A), axis=1)

    is_interior = np.all(slacks > 0)
    min_slack = np.min(slacks) if len(slacks) > 0 else float('inf')

    if is_interior:
        eps_per_constraint = slacks / (rn + 1)
        eps = np.min(eps_per_constraint)
    else:
        eps = 0.0

    return PolyhedralCertificate(
        slacks=slacks,
        row_norms=rn,
        stability_radius=eps,
        min_slack=min_slack,
        is_interior=is_interior
    )


# ============================================================================
# Algorithm 4: Combined Kinetic-Polyhedral Certificate
# ============================================================================

def compute_kinetic_polyhedral_certificate(
    A: np.ndarray,
    b: np.ndarray,
    x0: np.ndarray,
    v: np.ndarray
) -> KineticPolyhedralCertificate:
    """
    Compute a combined kinetic polyhedral stability certificate.

    If x0 is in the strict interior of {x : Ax <= b} and moves along
    x(t) = x0 + t*v, certify the time horizon for which membership holds.

    Algorithm:
        1. Compute polyhedral certificate at x0 → spatial radius δ
        2. Compute velocity bound: ||v||_1 + 1
        3. Return time horizon T = δ / (||v||_1 + 1)

    Complexity: O(k * n)

    Args:
        A: Constraint matrix (k x n)
        b: Right-hand side vector (k,)
        x0: Initial position
        v: Velocity vector

    Returns:
        KineticPolyhedralCertificate with certified time horizon
    """
    poly_cert = compute_polyhedral_certificate(A, b, x0)

    if not poly_cert.is_interior:
        return KineticPolyhedralCertificate(
            spatial_radius=0.0,
            time_horizon=0.0,
            velocity_bound=np.sum(np.abs(v)),
            is_certified=False
        )

    v_bound = np.sum(np.abs(v)) + 1
    time_horizon = poly_cert.stability_radius / v_bound

    return KineticPolyhedralCertificate(
        spatial_radius=poly_cert.stability_radius,
        time_horizon=time_horizon,
        velocity_bound=v_bound,
        is_certified=True
    )


# ============================================================================
# Example usage
# ============================================================================

if __name__ == '__main__':
    print("Algorithm Examples")
    print("=" * 60)

    # Example 1: Kinetic certificate
    print("\n--- Kinetic Certificate ---")
    weights = [np.array([1.0, 3.0, 2.0]), np.array([2.0, 1.0, 1.5])]
    biases = [0.5, 0.0]
    x0 = np.array([1.0, 0.5, 2.0])
    v = np.array([0.3, -0.2, 0.1])

    cert = compute_kinetic_certificate(weights, biases, x0, v)
    print(cert)

    # Example 2: Multi-class
    print("\n--- Multi-class Kinetic Certificate ---")
    weights3 = [np.array([1.0, 3.0, 2.0]),
                np.array([2.0, 1.0, 1.5]),
                np.array([0.5, 2.0, 3.0])]
    biases3 = [0.5, 0.0, -0.5]
    cert3 = compute_multiclass_kinetic_certificate(weights3, biases3, x0, v)
    print(cert3)

    # Example 3: Spread monotonicity
    print("\n--- Spread Monotonicity ---")
    x = np.array([5.0, 2.0, 8.0, 1.0, 6.0, 3.0])
    partition = [[0, 1], [2, 3], [4, 5]]
    s_before, s_after, is_mono = verify_spread_monotonicity(x, partition)
    print(f"Spread: {s_before:.2f} → {s_after:.2f}, monotone: {is_mono}")

    # Example 4: Polyhedral certificate
    print("\n--- Polyhedral Certificate ---")
    A = np.array([[1, 0], [-1, 0], [0, 1], [0, -1]])
    b = np.array([1, 1, 1, 1])
    x = np.array([0.3, 0.5])
    poly_cert = compute_polyhedral_certificate(A, b, x)
    print(poly_cert)

    # Example 5: Combined kinetic-polyhedral
    print("\n--- Kinetic-Polyhedral Certificate ---")
    v = np.array([0.5, 0.3])
    kp_cert = compute_kinetic_polyhedral_certificate(A, b, x, v)
    print(kp_cert)
