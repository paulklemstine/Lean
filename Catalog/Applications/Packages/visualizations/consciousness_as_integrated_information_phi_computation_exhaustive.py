#!/usr/bin/env python3
"""
Algorithms for Causal Integration Theory

Type-hinted implementations of the core algorithms for computing
integrated information (Phi) and related quantities.
"""

from typing import List, Tuple, Set, Dict, Optional
from itertools import combinations
import numpy as np


def cross_weight(weight: np.ndarray, subset: Set[int]) -> float:
    """
    Compute the cross-weight of a bipartition {S, S^c}.

    The cross-weight measures total causal influence flowing across
    the partition boundary.

    Parameters:
        weight: n×n non-negative weight matrix
        subset: Set of node indices forming one side of the bipartition

    Returns:
        Sum of weights from S to S^c plus weights from S^c to S
    """
    n = weight.shape[0]
    complement = set(range(n)) - subset
    cw = 0.0
    for i in subset:
        for j in complement:
            cw += weight[i, j]
    for i in complement:
        for j in subset:
            cw += weight[i, j]
    return cw


def compute_phi(weight: np.ndarray) -> Tuple[float, Set[int]]:
    """
    Compute Φ (integrated information) via exhaustive search.

    Finds the minimum cross-weight over all non-trivial bipartitions.
    This is the minimum cut problem on a directed weighted graph.

    Parameters:
        weight: n×n non-negative weight matrix

    Returns:
        (phi_value, minimizing_subset)

    Complexity: O(2^n * n^2) — exponential in network size
    """
    n = weight.shape[0]
    if n < 2:
        return (0.0, set())

    best_phi = float('inf')
    best_S: Set[int] = set()

    for k in range(1, n):
        for S_tuple in combinations(range(n), k):
            S = set(S_tuple)
            cw = cross_weight(weight, S)
            if cw < best_phi:
                best_phi = cw
                best_S = S

    return (best_phi, best_S)


def integration_profile(weight: np.ndarray) -> Dict[Tuple[int, ...], float]:
    """
    Compute the full integration profile: cross-weight for every non-trivial subset.

    Parameters:
        weight: n×n non-negative weight matrix

    Returns:
        Dictionary mapping subsets (as sorted tuples) to cross-weights
    """
    n = weight.shape[0]
    profile: Dict[Tuple[int, ...], float] = {}
    for k in range(1, n):
        for S_tuple in combinations(range(n), k):
            S = set(S_tuple)
            profile[S_tuple] = cross_weight(weight, S)
    return profile


def spectral_gap(weight: np.ndarray) -> float:
    """
    Compute the spectral gap: difference between second-smallest
    and smallest cross-weight values.

    A larger spectral gap indicates more robust integration.

    Parameters:
        weight: n×n non-negative weight matrix

    Returns:
        spectral_gap >= 0
    """
    profile = integration_profile(weight)
    if len(profile) < 2:
        return 0.0
    values = sorted(set(profile.values()))
    if len(values) < 2:
        return 0.0
    return values[1] - values[0]


def integration_complexity(weight: np.ndarray) -> int:
    """
    Count distinct cross-weight values across all bipartitions.

    Parameters:
        weight: n×n non-negative weight matrix

    Returns:
        Number of distinct cross-weight values
    """
    profile = integration_profile(weight)
    return len(set(round(v, 10) for v in profile.values()))


def weight_decomposition(weight: np.ndarray, subset: Set[int]) -> Tuple[float, float, float]:
    """
    Decompose total weight into internal(S) + internal(S^c) + cross(S).

    Theorem (totalWeight_decomp): This decomposition is exact.

    Parameters:
        weight: n×n non-negative weight matrix
        subset: Set of node indices

    Returns:
        (internal_S, internal_Sc, cross_weight_S)
    """
    n = weight.shape[0]
    complement = set(range(n)) - subset
    S_list = sorted(subset)
    Sc_list = sorted(complement)

    int_S = sum(weight[i, j] for i in S_list for j in S_list)
    int_Sc = sum(weight[i, j] for i in Sc_list for j in Sc_list)
    cw = cross_weight(weight, subset)

    return (int_S, int_Sc, cw)


def is_block_diagonal(weight: np.ndarray, subset: Set[int], tol: float = 1e-12) -> bool:
    """
    Check if the network is block-diagonal with respect to a partition.

    If True, Theorem phi_blockDiag_zero guarantees Φ = 0.

    Parameters:
        weight: n×n non-negative weight matrix
        subset: Set of node indices
        tol: numerical tolerance

    Returns:
        True if all cross-partition edges have weight ≈ 0
    """
    n = weight.shape[0]
    complement = set(range(n)) - subset
    for i in subset:
        for j in complement:
            if weight[i, j] > tol or weight[j, i] > tol:
                return False
    return True


def is_strongly_integrated(weight: np.ndarray) -> bool:
    """
    Check if the network is strongly integrated (Φ > 0).

    Theorem: Equivalent to all cross-weights being positive.
    Theorem: Not strongly integrated iff block-diagonal for some partition.

    Parameters:
        weight: n×n non-negative weight matrix

    Returns:
        True if Φ > 0
    """
    phi_val, _ = compute_phi(weight)
    return phi_val > 0


def find_maximally_integrated_subsystem(
    weight: np.ndarray, size: int
) -> Tuple[Set[int], float]:
    """
    Find the size-k subset with maximum internal weight.

    This implements the IsMaxIntegrated predicate from the Lean formalization.

    Parameters:
        weight: n×n non-negative weight matrix
        size: desired subset size

    Returns:
        (best_subset, internal_weight)
    """
    n = weight.shape[0]
    best_iw = -float('inf')
    best_S: Set[int] = set()

    for S_tuple in combinations(range(n), size):
        S = set(S_tuple)
        iw = sum(weight[i, j] for i in S for j in S)
        if iw > best_iw:
            best_iw = iw
            best_S = S

    return (best_S, best_iw)


if __name__ == "__main__":
    # Quick example
    W = np.array([
        [0, 3, 1],
        [2, 0, 4],
        [1, 1, 0]
    ], dtype=float)

    phi_val, phi_S = compute_phi(W)
    print(f"Network:\n{W}")
    print(f"Φ = {phi_val:.2f}, minimizing partition: {phi_S}")
    print(f"Integration complexity: {integration_complexity(W)}")
    print(f"Spectral gap: {spectral_gap(W):.2f}")
    print(f"Strongly integrated: {is_strongly_integrated(W)}")
