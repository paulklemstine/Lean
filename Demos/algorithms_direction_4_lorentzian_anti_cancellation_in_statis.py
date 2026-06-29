#!/usr/bin/env python3
"""
Algorithms for Lorentzian Anti-Cancellation in Ferromagnetic Statistical Physics

Implements the core computational procedures for constructing and analyzing
Ising partition polynomials, susceptibility numerators, and aggregate shadows.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Set, Optional, FrozenSet
import math


# =============================================================================
# Algorithm 1: Partition Polynomial Construction
# =============================================================================

def construct_partition_polynomial(
    vertices: List[int],
    edges: List[Tuple[int, int]],
    J: Dict[Tuple[int, int], float],
    beta: float
) -> Dict[FrozenSet[int], float]:
    """
    Construct the ferromagnetic Ising partition polynomial.

    The partition polynomial is:
        Φ(z) = Σ_{S ⊆ V} w_β(S) ∏_{i ∈ S} z_i

    where w_β(S) = exp(β · Σ_{edges aligned by S} J_e).

    Parameters
    ----------
    vertices : list of int
        Vertex set V.
    edges : list of (int, int)
        Edge set E.
    J : dict mapping (int,int) -> float
        Coupling constants (must be non-negative for ferromagnetic).
    beta : float
        Inverse temperature (must be non-negative).

    Returns
    -------
    dict mapping frozenset -> float
        Coefficients c_S of the partition polynomial.

    Time complexity: O(2^n * m) where n = |V|, m = |E|.
    Space complexity: O(2^n).
    """
    n = len(vertices)
    coeffs: Dict[FrozenSet[int], float] = {}

    for mask in range(2**n):
        S = frozenset(vertices[i] for i in range(n) if mask & (1 << i))
        energy = 0.0
        for (u, v) in edges:
            aligned = (u in S and v in S) or (u not in S and v not in S)
            coupling = J.get((u, v), J.get((v, u), 0.0))
            if aligned:
                energy += coupling
        coeffs[S] = math.exp(beta * energy)

    return coeffs


# =============================================================================
# Algorithm 2: Level Weight Computation
# =============================================================================

def compute_level_weights(
    coeffs: Dict[FrozenSet[int], float],
    n: int
) -> np.ndarray:
    """
    Compute level weights a_k = Σ_{|S|=k} w_β(S).

    Parameters
    ----------
    coeffs : dict
        Partition polynomial coefficients.
    n : int
        Number of vertices.

    Returns
    -------
    np.ndarray of shape (n+1,)
        Level weights a_0, a_1, ..., a_n.

    Time complexity: O(2^n).
    """
    weights = np.zeros(n + 1)
    for S, w in coeffs.items():
        weights[len(S)] += w
    return weights


# =============================================================================
# Algorithm 3: Susceptibility Numerator Computation
# =============================================================================

def compute_susceptibility_numerator(
    coeffs: Dict[FrozenSet[int], float],
    z: Dict[int, float],
    i: int,
    j: int
) -> float:
    """
    Compute the susceptibility numerator N_{ij} = Φ·∂_i∂_j Φ - ∂_i Φ·∂_j Φ.

    This is the numerator of the connected two-point correlation function
    (susceptibility) χ_{ij} = N_{ij} / Φ².

    Parameters
    ----------
    coeffs : dict
        Partition polynomial coefficients.
    z : dict
        Field variable values.
    i, j : int
        Vertex indices.

    Returns
    -------
    float
        The susceptibility numerator at the given point.

    Time complexity: O(2^n) per evaluation.
    """
    if i == j:
        return 0.0

    phi = 0.0
    dphi_i = 0.0
    dphi_j = 0.0
    d2phi_ij = 0.0

    for S, w in coeffs.items():
        prod = w
        for v in S:
            prod *= z[v]
        phi += prod

        if i in S:
            prod_no_i = w
            for v in S:
                if v != i:
                    prod_no_i *= z[v]
            dphi_i += prod_no_i

        if j in S:
            prod_no_j = w
            for v in S:
                if v != j:
                    prod_no_j *= z[v]
            dphi_j += prod_no_j

        if i in S and j in S:
            prod_no_ij = w
            for v in S:
                if v != i and v != j:
                    prod_no_ij *= z[v]
            d2phi_ij += prod_no_ij

    return phi * d2phi_ij - dphi_i * dphi_j


# =============================================================================
# Algorithm 4: Aggregate Shadow Computation
# =============================================================================

def compute_aggregate_shadow(
    coeffs: Dict[FrozenSet[int], float],
    vertices: List[int],
    weight_matrix: Dict[Tuple[int, int], float]
) -> Set[FrozenSet[int]]:
    """
    Compute the aggregate shadow of the partition polynomial under weight matrix A.

    The aggregate shadow is:
        ⋃_{A(i,j)≠0} supp(∂_i ∂_j p)

    For multiaffine polynomials, ∂_i ∂_j p has support
    {S \\ {i,j} : S ∈ supp(p), i ∈ S, j ∈ S}.

    Parameters
    ----------
    coeffs : dict
        Partition polynomial coefficients.
    vertices : list
        Vertex set.
    weight_matrix : dict
        Weight matrix A : (i,j) -> float.

    Returns
    -------
    set of frozensets
        The aggregate shadow.

    Time complexity: O(n² · 2^n).
    """
    shadow: Set[FrozenSet[int]] = set()

    for i in vertices:
        for j in vertices:
            if i == j:
                continue
            A_ij = weight_matrix.get((i, j), 0.0)
            if A_ij == 0.0:
                continue
            for S, w in coeffs.items():
                if abs(w) < 1e-15:
                    continue
                if i in S and j in S:
                    shadow.add(S - {i, j})

    return shadow


# =============================================================================
# Algorithm 5: Weighted Hessian Support
# =============================================================================

def compute_weighted_hessian_support(
    coeffs: Dict[FrozenSet[int], float],
    vertices: List[int],
    weight_matrix: Dict[Tuple[int, int], float],
    tol: float = 1e-12
) -> Set[FrozenSet[int]]:
    """
    Compute the support of H_A(p) = Σ_{i,j} A(i,j) · ∂_i ∂_j p.

    Parameters
    ----------
    coeffs : dict
        Partition polynomial coefficients.
    vertices : list
        Vertex set.
    weight_matrix : dict
        Weight matrix.
    tol : float
        Tolerance for zero detection.

    Returns
    -------
    set of frozensets
        The support of the weighted Hessian sum.

    Time complexity: O(n² · 2^n).
    """
    hessian_coeffs: Dict[FrozenSet[int], float] = {}

    for i in vertices:
        for j in vertices:
            if i == j:
                continue
            A_ij = weight_matrix.get((i, j), 0.0)
            if A_ij == 0.0:
                continue
            for S, w in coeffs.items():
                if i in S and j in S:
                    key = S - {i, j}
                    hessian_coeffs[key] = hessian_coeffs.get(key, 0.0) + A_ij * w

    return {k for k, v in hessian_coeffs.items() if abs(v) > tol}


# =============================================================================
# Algorithm 6: Anti-Cancellation Verification
# =============================================================================

def verify_anti_cancellation(
    coeffs: Dict[FrozenSet[int], float],
    vertices: List[int],
    weight_matrix: Dict[Tuple[int, int], float],
    tol: float = 1e-12
) -> Tuple[bool, Optional[FrozenSet[int]]]:
    """
    Verify that the aggregate shadow equals the weighted Hessian support.

    If anti-cancellation fails, returns the first counterexample monomial.

    Parameters
    ----------
    coeffs, vertices, weight_matrix : as above
    tol : float

    Returns
    -------
    (bool, optional frozenset)
        (True, None) if anti-cancellation holds.
        (False, counterexample) otherwise.
    """
    shadow = compute_aggregate_shadow(coeffs, vertices, weight_matrix)
    support = compute_weighted_hessian_support(coeffs, vertices, weight_matrix, tol)

    if shadow == support:
        return True, None

    diff = shadow.symmetric_difference(support)
    return False, next(iter(diff))


# =============================================================================
# Algorithm 7: Log-Concavity Check with Newton Inequalities
# =============================================================================

def check_newton_inequalities(
    level_weights: np.ndarray
) -> List[Tuple[int, bool, float]]:
    """
    Check all Newton inequalities: a_k² ≥ a_{k-1} · a_{k+1}.

    Returns
    -------
    list of (k, passed, ratio)
        For each k in [1, n-1], whether the inequality holds,
        and the ratio a_k² / (a_{k-1} · a_{k+1}).
    """
    results = []
    for k in range(1, len(level_weights) - 1):
        a_prev = level_weights[k - 1]
        a_curr = level_weights[k]
        a_next = level_weights[k + 1]

        if a_prev * a_next > 0:
            ratio = a_curr**2 / (a_prev * a_next)
            passed = ratio >= 1.0 - 1e-10
        else:
            ratio = float('inf')
            passed = True

        results.append((k, passed, ratio))

    return results


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    # Two-spin example
    vertices = [0, 1]
    edges = [(0, 1)]
    J = {(0, 1): 1.0}
    beta = 1.0

    coeffs = construct_partition_polynomial(vertices, edges, J, beta)
    print("Partition polynomial coefficients:", {str(k): f"{v:.4f}" for k, v in coeffs.items()})

    lw = compute_level_weights(coeffs, len(vertices))
    print("Level weights:", lw)

    z = {0: 1.0, 1: 1.0}
    N01 = compute_susceptibility_numerator(coeffs, z, 0, 1)
    print(f"Susceptibility numerator N_01 = {N01:.6f}")
    print(f"Expected (e^(2βJ) - 1) = {math.exp(2*beta)**1 - 1:.6f}")

    # Anti-cancellation
    weight_matrix = {(0, 1): 1.0, (1, 0): 1.0}
    passed, counter = verify_anti_cancellation(coeffs, vertices, weight_matrix)
    print(f"Anti-cancellation: {'PASS' if passed else f'FAIL at {counter}'}")

    # Newton inequalities
    newton = check_newton_inequalities(lw)
    for k, p, r in newton:
        print(f"  Newton k={k}: {'PASS' if p else 'FAIL'} (ratio={r:.4f})")
