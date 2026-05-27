#!/usr/bin/env python3
"""
algorithms.py — Certified computational methods for the Heterogeneity–Gap Theory

Implements the core algorithms for:
1. Computing edge-size distribution invariants (heterogeneity, collision index, support width)
2. Exact transversal number computation (brute-force, for small instances)
3. Fractional transversal LP relaxation
4. Certified witness verification for positive ceiling gap
5. Generating the disjoint-triangles family

All functions include docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
import itertools
import math
from collections import Counter
from typing import FrozenSet, List, Optional, Tuple, Dict

import numpy as np


# ══════════════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ══════════════════════════════════════════════════════════════════════

class Hypergraph:
    """
    A finite hypergraph H = (V, E) where V = {0, ..., n-1} and E is a
    collection of subsets of V.

    Attributes:
        n_vertices: Number of vertices.
        edges: List of frozensets representing edges.
    """

    def __init__(self, n_vertices: int, edges: List[FrozenSet[int]]):
        self.n_vertices = n_vertices
        self.edges = list(set(edges))  # deduplicate
        self._validate()

    def _validate(self) -> None:
        for e in self.edges:
            for v in e:
                assert 0 <= v < self.n_vertices, f"Vertex {v} out of range"

    @property
    def vertices(self) -> List[int]:
        return list(range(self.n_vertices))

    @property
    def edge_sizes(self) -> List[int]:
        """List of edge cardinalities."""
        return [len(e) for e in self.edges]

    def __repr__(self) -> str:
        return f"Hypergraph(n={self.n_vertices}, m={len(self.edges)})"


# ══════════════════════════════════════════════════════════════════════
# EDGE-SIZE DISTRIBUTION INVARIANTS
# ══════════════════════════════════════════════════════════════════════

def edge_heterogeneity(H: Hypergraph) -> float:
    """
    Compute the edge-size heterogeneity (variance of edge cardinalities).

    Definition: σ² = (1/m) Σ_{e ∈ E} (|e| - d̄)²
    where d̄ = (1/m) Σ_{e ∈ E} |e| is the mean edge size.

    Time complexity: O(m) where m = |E|.
    Space complexity: O(1).

    Returns 0 for empty edge sets.

    >>> H = Hypergraph(4, [frozenset([0,1]), frozenset([0,1,2])])
    >>> edge_heterogeneity(H)
    0.25
    """
    if not H.edges:
        return 0.0
    sizes = H.edge_sizes
    mean = sum(sizes) / len(sizes)
    return sum((s - mean) ** 2 for s in sizes) / len(sizes)


def edge_size_support_width(H: Hypergraph) -> int:
    """
    Compute the support width: max edge size − min edge size.

    Time complexity: O(m).
    Space complexity: O(1).

    Returns 0 for empty edge sets.

    >>> H = Hypergraph(5, [frozenset([0,1]), frozenset([0,1,2,3,4])])
    >>> edge_size_support_width(H)
    3
    """
    if not H.edges:
        return 0
    sizes = H.edge_sizes
    return max(sizes) - min(sizes)


def collision_index(H: Hypergraph) -> float:
    """
    Compute the collision index (Herfindahl index) of the edge-size distribution.

    Definition: CI = Σ_k p_k² where p_k = #{e : |e| = k} / m.

    This is the probability that two uniformly random edges have the same
    cardinality. CI = 1 iff all edges have the same size (uniform).
    CI < 1 iff at least two distinct edge sizes exist (non-uniform).

    Time complexity: O(m).
    Space complexity: O(d) where d = number of distinct edge sizes.

    Returns 1 for empty edge sets (convention).

    >>> H = Hypergraph(4, [frozenset([0,1]), frozenset([0,1,2])])
    >>> collision_index(H)
    0.5
    """
    if not H.edges:
        return 1.0
    sizes = H.edge_sizes
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c / n) ** 2 for c in counts.values())


def edge_size_distribution_support(H: Hypergraph) -> set:
    """
    The set of distinct edge cardinalities.

    Time complexity: O(m).

    >>> H = Hypergraph(5, [frozenset([0,1]), frozenset([2,3,4])])
    >>> sorted(edge_size_distribution_support(H))
    [2, 3]
    """
    return set(H.edge_sizes)


def renyi_entropy_proxy(H: Hypergraph) -> float:
    """
    Compute -log₂(collision_index), a proxy for Rényi 2-entropy of
    the edge-size distribution.

    Returns 0 for uniform distributions (CI = 1).
    Higher values indicate more disorder.

    Time complexity: O(m).
    """
    ci = collision_index(H)
    if ci <= 0 or ci >= 1:
        return 0.0 if ci >= 1 else float('inf')
    return -math.log2(ci)


# ══════════════════════════════════════════════════════════════════════
# TRANSVERSAL NUMBER COMPUTATION
# ══════════════════════════════════════════════════════════════════════

def is_transversal(H: Hypergraph, S: set) -> bool:
    """
    Check if S is a transversal (hitting set) of H.

    Time complexity: O(m · max_edge_size).

    >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
    >>> is_transversal(H, {1})
    True
    >>> is_transversal(H, {0})
    False
    """
    return all(S & e for e in H.edges)


def transversal_number_exact(H: Hypergraph) -> int:
    """
    Compute τ(H) exactly by brute-force enumeration.

    Time complexity: O(2^n · m · max_edge_size).
    Space complexity: O(n).

    WARNING: Only feasible for n ≤ 25 or so.

    >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
    >>> transversal_number_exact(H)
    1
    """
    for size in range(H.n_vertices + 1):
        for S in itertools.combinations(range(H.n_vertices), size):
            if is_transversal(H, set(S)):
                return size
    return H.n_vertices


def fractional_transversal_lp(H: Hypergraph) -> float:
    """
    Compute τ*(H) via LP relaxation.

    Minimize Σ x_v subject to:
        Σ_{v ∈ e} x_v ≥ 1 for each edge e
        0 ≤ x_v ≤ 1 for each vertex v

    Uses scipy.optimize.linprog with HiGHS solver.

    Time complexity: polynomial in n and m (LP).

    >>> H = Hypergraph(4, [frozenset([0,1]), frozenset([2,3])])
    >>> fractional_transversal_lp(H)
    2.0
    """
    try:
        from scipy.optimize import linprog
    except ImportError:
        raise ImportError("scipy required for LP computation")

    n = H.n_vertices
    c = np.ones(n)
    A_ub = []
    b_ub = []
    for e in H.edges:
        row = np.zeros(n)
        for v in e:
            row[v] = -1
        A_ub.append(row)
        b_ub.append(-1)
    bounds = [(0, 1) for _ in range(n)]
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return result.fun
    raise ValueError("LP solver failed")


def verify_fractional_transversal(
    H: Hypergraph, weights: Dict[int, float], tol: float = 1e-9
) -> Tuple[bool, float]:
    """
    Verify that a given weight assignment is a valid fractional transversal
    and compute its value.

    A certified witness checker: returns (is_valid, value).

    Time complexity: O(n + m · max_edge_size).

    >>> H = Hypergraph(4, [frozenset([0,1]), frozenset([2,3])])
    >>> verify_fractional_transversal(H, {0: 0.5, 1: 0.5, 2: 0.5, 3: 0.5})
    (True, 2.0)
    """
    # Check nonnegativity
    for v in range(H.n_vertices):
        w = weights.get(v, 0.0)
        if w < -tol:
            return False, float('inf')

    # Check covering constraints
    for e in H.edges:
        edge_sum = sum(weights.get(v, 0.0) for v in e)
        if edge_sum < 1.0 - tol:
            return False, float('inf')

    # Compute value
    value = sum(max(0, weights.get(v, 0.0)) for v in range(H.n_vertices))
    return True, value


def certified_positive_ceil_gap(H: Hypergraph) -> Tuple[bool, dict]:
    """
    Certified check for positive ceiling gap.

    Returns (has_gap, certificate) where certificate contains:
    - tau: integer transversal number
    - tau_star: fractional transversal number
    - ceil_tau_star: ⌈τ*⌉
    - gap: τ - ⌈τ*⌉

    Time complexity: O(2^n · m) for exact τ, polynomial for τ*.
    """
    tau = transversal_number_exact(H)
    tau_star = fractional_transversal_lp(H)
    ceil_tau_star = math.ceil(tau_star - 1e-9)  # numerical tolerance
    gap = tau - ceil_tau_star

    cert = {
        'tau': tau,
        'tau_star': tau_star,
        'ceil_tau_star': ceil_tau_star,
        'gap': gap,
        'has_positive_gap': gap >= 1,
        'heterogeneity': edge_heterogeneity(H),
        'collision_index': collision_index(H),
        'support_width': edge_size_support_width(H),
    }
    return gap >= 1, cert


# ══════════════════════════════════════════════════════════════════════
# EXPLICIT FAMILIES
# ══════════════════════════════════════════════════════════════════════

def disjoint_triangles_family(n: int) -> Hypergraph:
    """
    Construct the disjoint-triangles-plus-large-edge family.

    Parameters:
        n: number of triangle groups (n ≥ 3 for meaningful results)

    Returns:
        Hypergraph on 3n vertices with:
        - 3n edges of size 2 (all pairs within each triple)
        - 1 edge of size n (one vertex from each triple)

    Properties (proved in Lean):
    - edgeHeterogeneity > 0 for n ≥ 3
    - τ = 2n, τ* ≤ 3n/2
    - Ceiling gap ≥ 1 for n ≥ 3

    Time complexity: O(n).

    >>> H = disjoint_triangles_family(3)
    >>> H.n_vertices
    9
    >>> len(H.edges)
    10
    """
    n_vertices = 3 * n
    edges = []

    # Triangle pair edges
    for i in range(n):
        base = 3 * i
        edges.append(frozenset([base, base + 1]))
        edges.append(frozenset([base, base + 2]))
        edges.append(frozenset([base + 1, base + 2]))

    # Large edge
    large = frozenset(3 * i for i in range(n))
    edges.append(large)

    return Hypergraph(n_vertices, edges)


# ══════════════════════════════════════════════════════════════════════
# EXAMPLE USAGE
# ══════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=== Algorithms Module: Example Usage ===\n")

    # Example 1: Uniform hypergraph
    H_uniform = Hypergraph(6, [
        frozenset([0, 1, 2]),
        frozenset([1, 2, 3]),
        frozenset([2, 3, 4]),
        frozenset([3, 4, 5]),
    ])
    print(f"Uniform H: {H_uniform}")
    print(f"  Heterogeneity: {edge_heterogeneity(H_uniform)}")
    print(f"  Collision index: {collision_index(H_uniform)}")
    print(f"  Support width: {edge_size_support_width(H_uniform)}")
    print(f"  Rényi entropy proxy: {renyi_entropy_proxy(H_uniform)}")

    # Example 2: Heterogeneous hypergraph
    H_het = Hypergraph(6, [
        frozenset([0, 1]),
        frozenset([2, 3]),
        frozenset([0, 1, 2, 3, 4, 5]),
    ])
    print(f"\nHeterogeneous H: {H_het}")
    print(f"  Heterogeneity: {edge_heterogeneity(H_het):.4f}")
    print(f"  Collision index: {collision_index(H_het):.4f}")
    print(f"  Support width: {edge_size_support_width(H_het)}")
    print(f"  Rényi entropy proxy: {renyi_entropy_proxy(H_het):.4f}")

    # Example 3: Disjoint triangles family
    print("\n--- Disjoint Triangles Family ---")
    for n in [3, 4, 5, 6]:
        H = disjoint_triangles_family(n)
        has_gap, cert = certified_positive_ceil_gap(H)
        print(f"  n={n}: τ={cert['tau']}, τ*={cert['tau_star']:.2f}, "
              f"gap={cert['gap']}, het={cert['heterogeneity']:.3f}, "
              f"CI={cert['collision_index']:.3f}")
