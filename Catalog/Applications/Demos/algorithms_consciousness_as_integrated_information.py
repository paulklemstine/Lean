"""
Causal Integration Algebra — Core Algorithms

Implements the key algorithms for computing integrated information Φ
and related quantities on causal systems (weighted directed graphs).

All functions are type-hinted and self-contained.
"""

from typing import List, Tuple, Optional
import itertools


def create_causal_system(n: int, weights: List[List[float]]) -> List[List[float]]:
    """Create and validate a causal system (weight matrix).
    
    Args:
        n: Number of elements
        weights: n×n matrix of causal weights (nonneg, zero diagonal)
    
    Returns:
        Validated weight matrix
    
    Raises:
        ValueError: If weights violate causal system axioms
    """
    if len(weights) != n or any(len(row) != n for row in weights):
        raise ValueError(f"Weight matrix must be {n}×{n}")
    for i in range(n):
        if weights[i][i] != 0:
            raise ValueError(f"Self-weight must be zero: w[{i}][{i}] = {weights[i][i]}")
        for j in range(n):
            if weights[i][j] < 0:
                raise ValueError(f"Weights must be nonneg: w[{i}][{j}] = {weights[i][j]}")
    return [row[:] for row in weights]


def flow_between(
    weights: List[List[float]], 
    a_set: set, 
    b_set: set
) -> float:
    """Compute total causal flow from set A to set B.
    
    Args:
        weights: n×n weight matrix
        a_set: Source vertex set
        b_set: Target vertex set
    
    Returns:
        Sum of w(i,j) for i in A, j in B
    """
    return sum(weights[i][j] for i in a_set for j in b_set)


def cross_info(weights: List[List[float]], a_set: set, n: int) -> float:
    """Compute cross-information of bipartition (A, A^c).
    
    Args:
        weights: n×n weight matrix
        a_set: One side of the bipartition
        n: Total number of elements
    
    Returns:
        flow(A, A^c) + flow(A^c, A)
    """
    complement = set(range(n)) - a_set
    return flow_between(weights, a_set, complement) + flow_between(weights, complement, a_set)


def compute_phi(weights: List[List[float]], n: int) -> Tuple[float, Optional[set]]:
    """Compute integrated information Φ (minimum bipartition cost).
    
    Uses brute-force enumeration over all non-trivial bipartitions.
    Time complexity: O(2^n · n^2)
    
    Args:
        weights: n×n weight matrix
        n: Number of elements
    
    Returns:
        (phi_value, minimizing_partition) where partition is the set A
        achieving the minimum, or None if n ≤ 1
    """
    if n <= 1:
        return (0.0, None)
    
    best_phi = float('inf')
    best_partition = None
    
    # Enumerate all non-empty proper subsets (up to complement symmetry)
    for size in range(1, n):
        for subset in itertools.combinations(range(n), size):
            a_set = set(subset)
            ci = cross_info(weights, a_set, n)
            if ci < best_phi:
                best_phi = ci
                best_partition = a_set
    
    return (best_phi, best_partition)


def compute_total_weight(weights: List[List[float]], n: int) -> float:
    """Compute total weight of all edges."""
    return sum(weights[i][j] for i in range(n) for j in range(n))


def symmetrize(weights: List[List[float]], n: int) -> List[List[float]]:
    """Symmetrize a causal system: w_sym(i,j) = (w(i,j) + w(j,i)) / 2."""
    return [[(weights[i][j] + weights[j][i]) / 2 for j in range(n)] for i in range(n)]


def scale(weights: List[List[float]], n: int, c: float) -> List[List[float]]:
    """Scale all weights by constant c ≥ 0."""
    if c < 0:
        raise ValueError("Scale factor must be nonneg")
    return [[c * weights[i][j] for j in range(n)] for i in range(n)]


def direct_sum(
    w1: List[List[float]], n1: int,
    w2: List[List[float]], n2: int
) -> Tuple[List[List[float]], int]:
    """Compute direct sum of two causal systems.
    
    Returns:
        (combined_weights, n1 + n2)
    """
    n = n1 + n2
    result = [[0.0] * n for _ in range(n)]
    for i in range(n1):
        for j in range(n1):
            result[i][j] = w1[i][j]
    for i in range(n2):
        for j in range(n2):
            result[n1 + i][n1 + j] = w2[i][j]
    return (result, n)


def compute_inter_part_flow(
    weights: List[List[float]], 
    n: int, 
    assignment: List[int]
) -> float:
    """Compute inter-part flow for a k-partition.
    
    Args:
        weights: n×n weight matrix
        n: Number of elements
        assignment: List mapping each element to its part (0-indexed)
    
    Returns:
        Total weight of edges between different parts
    """
    return sum(
        weights[i][j]
        for i in range(n) for j in range(n)
        if assignment[i] != assignment[j]
    )


def compute_integration_spectrum(
    weights: List[List[float]], n: int, max_k: Optional[int] = None
) -> List[float]:
    """Compute the integration spectrum [Φ_2, Φ_3, ..., Φ_k].
    
    Φ_k = minimum inter-part flow over all surjective k-partitions.
    Warning: Exponential in n and k. Only feasible for small systems.
    
    Args:
        weights: n×n weight matrix
        n: Number of elements
        max_k: Maximum k to compute (default: n)
    
    Returns:
        List of Φ_k values for k = 2, 3, ..., max_k
    """
    if max_k is None:
        max_k = n
    max_k = min(max_k, n)
    
    spectrum = []
    for k in range(2, max_k + 1):
        best = float('inf')
        # Enumerate all surjective assignments of n elements to k parts
        for assignment in itertools.product(range(k), repeat=n):
            # Check surjectivity
            if len(set(assignment)) < k:
                continue
            flow = compute_inter_part_flow(weights, n, list(assignment))
            best = min(best, flow)
        spectrum.append(best)
    
    return spectrum


def is_disconnected(weights: List[List[float]], n: int) -> Tuple[bool, Optional[set]]:
    """Check if a causal system is disconnected.
    
    Returns:
        (is_disconnected, witnessing_partition) where partition is the set A
        with cross_info(A) = 0, or None if connected.
    """
    phi, partition = compute_phi(weights, n)
    if phi == 0 and partition is not None:
        return (True, partition)
    return (False, None)
