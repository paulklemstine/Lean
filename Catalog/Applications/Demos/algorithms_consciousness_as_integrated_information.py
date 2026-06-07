"""
Integrated Information Theory: Core Algorithms

Implements the mathematical framework for computing integrated information (Φ)
on finite causal systems represented as weighted directed graphs.
"""

from typing import List, Tuple, Set, FrozenSet
import itertools
import numpy as np


def cut_value(weights: np.ndarray, subset: Set[int]) -> float:
    """
    Compute the cut value of a bipartition.

    The cut value measures the total causal influence crossing a partition,
    in both directions. For a subset S and its complement Sᶜ:

        cut(S) = Σ_{i∈S, j∈Sᶜ} w(i,j) + Σ_{i∈Sᶜ, j∈S} w(i,j)

    Args:
        weights: n×n non-negative weight matrix
        subset: set of indices forming one side of the bipartition

    Returns:
        Total weight of edges crossing the partition (both directions)
    """
    n = weights.shape[0]
    complement = set(range(n)) - subset
    forward = sum(weights[i, j] for i in subset for j in complement)
    backward = sum(weights[i, j] for i in complement for j in subset)
    return forward + backward


def phi(weights: np.ndarray) -> Tuple[float, Set[int]]:
    """
    Compute the integrated information Φ of a causal system.

    Φ is the minimum cut value over all non-trivial bipartitions —
    the cheapest way to split the system into disconnected parts.

    Args:
        weights: n×n non-negative weight matrix

    Returns:
        Tuple of (Φ value, minimizing partition)
    """
    n = weights.shape[0]
    if n < 2:
        return 0.0, set()

    min_cut = float('inf')
    min_partition: Set[int] = set()

    # Iterate over all non-trivial subsets (2^n - 2 possibilities)
    for k in range(1, n):
        for subset_tuple in itertools.combinations(range(n), k):
            subset = set(subset_tuple)
            cv = cut_value(weights, subset)
            if cv < min_cut:
                min_cut = cv
                min_partition = subset

    return min_cut, min_partition


def subsystem_phi(weights: np.ndarray, system: Set[int]) -> float:
    """
    Compute the integrated information of a subsystem.

    Args:
        weights: n×n weight matrix of the full system
        system: set of indices defining the subsystem

    Returns:
        Φ value of the subsystem
    """
    system_list = sorted(system)
    m = len(system_list)
    if m < 2:
        return 0.0

    min_cut = float('inf')
    for k in range(1, m):
        for subset_tuple in itertools.combinations(system_list, k):
            T = set(subset_tuple)
            S_minus_T = system - T
            forward = sum(weights[i, j] for i in T for j in S_minus_T)
            backward = sum(weights[i, j] for i in S_minus_T for j in T)
            cv = forward + backward
            min_cut = min(min_cut, cv)

    return min_cut


def find_complex(weights: np.ndarray) -> Tuple[Set[int], float]:
    """
    Find the maximally integrated subsystem (the "complex").

    This implements the exclusion principle: among all subsystems of size ≥ 2,
    find the one with the maximum integrated information.

    Args:
        weights: n×n weight matrix

    Returns:
        Tuple of (complex indices, maximum Φ)
    """
    n = weights.shape[0]
    max_phi = -float('inf')
    max_system: Set[int] = set()

    for size in range(2, n + 1):
        for subset_tuple in itertools.combinations(range(n), size):
            system = set(subset_tuple)
            sp = subsystem_phi(weights, system)
            if sp > max_phi:
                max_phi = sp
                max_system = system

    return max_system, max_phi


def direct_sum(w1: np.ndarray, w2: np.ndarray) -> np.ndarray:
    """
    Compute the direct sum (block-diagonal) of two weight matrices.

    The direct sum has no cross-connections between the two blocks,
    so by the composition theorem, its Φ = 0.

    Args:
        w1: n₁×n₁ weight matrix
        w2: n₂×n₂ weight matrix

    Returns:
        (n₁+n₂)×(n₁+n₂) block-diagonal weight matrix
    """
    n1, n2 = w1.shape[0], w2.shape[0]
    result = np.zeros((n1 + n2, n1 + n2))
    result[:n1, :n1] = w1
    result[n1:, n1:] = w2
    return result


def scale_system(weights: np.ndarray, r: float) -> np.ndarray:
    """Scale all weights by a non-negative factor."""
    assert r >= 0, "Scaling factor must be non-negative"
    return r * weights
