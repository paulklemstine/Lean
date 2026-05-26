#!/usr/bin/env python3
"""
Algorithms for Heterogeneity–Gap Analysis in Hypergraphs
=========================================================

Implements the core computational algorithms from the research paper:
  1. Edge-size heterogeneity (variance)
  2. Support width
  3. Collision index (Herfindahl)
  4. Exact transversal number (brute force)
  5. Fractional transversal number (LP relaxation)
  6. Certified fractional transversal verification
"""

import numpy as np
import itertools
from typing import List, Set, FrozenSet, Dict, Tuple, Optional
from collections import Counter
from fractions import Fraction


# ============================================================
# Hypergraph representation
# ============================================================

class Hypergraph:
    """
    A finite hypergraph H = (V, E) where V = {0, ..., n-1}.

    Attributes:
        n: number of vertices
        edges: list of frozensets (edges)
    """
    def __init__(self, n: int, edges: List[FrozenSet[int]]):
        self.n = n
        self.edges = list(set(edges))  # deduplicate

    def __repr__(self) -> str:
        return f"Hypergraph(n={self.n}, |E|={len(self.edges)})"


# ============================================================
# Algorithm 1: Edge-Size Statistics
# ============================================================

def edge_sizes(H: Hypergraph) -> List[int]:
    """Return the list of edge cardinalities.

    Time: O(|E|)
    Space: O(|E|)
    """
    return [len(e) for e in H.edges]


def edge_heterogeneity(H: Hypergraph) -> float:
    """
    Compute the edge-size heterogeneity (variance of edge cardinalities).

    Definition: σ² = (1/|E|) Σ_{e ∈ E} (|e| - μ)²
    where μ = (1/|E|) Σ_{e ∈ E} |e|.

    Returns 0 for empty edge sets.

    Time: O(|E|)
    Space: O(|E|)

    Example:
        >>> H = Hypergraph(5, [frozenset([0,1]), frozenset([0,1,2,3])])
        >>> edge_heterogeneity(H)
        1.0
    """
    sizes = edge_sizes(H)
    if not sizes:
        return 0.0
    mu = sum(sizes) / len(sizes)
    return sum((s - mu) ** 2 for s in sizes) / len(sizes)


def edge_size_support_width(H: Hypergraph) -> int:
    """
    Compute the support width: max edge size - min edge size.

    Returns 0 for empty edge sets.

    Time: O(|E|)
    Space: O(1)

    Example:
        >>> H = Hypergraph(5, [frozenset([0,1]), frozenset([0,1,2,3])])
        >>> edge_size_support_width(H)
        2
    """
    sizes = edge_sizes(H)
    if not sizes:
        return 0
    return max(sizes) - min(sizes)


def collision_index(H: Hypergraph) -> float:
    """
    Compute the collision index (Herfindahl index) of the edge-size distribution.

    Definition: CI = Σ_k p_k² where p_k = |{e : |e| = k}| / |E|.

    Returns 1 for empty or uniform edge sets.
    Returns strictly < 1 for non-uniform edge sets.

    Time: O(|E|)
    Space: O(|distinct sizes|)

    Example:
        >>> H = Hypergraph(5, [frozenset([0,1]), frozenset([0,1,2,3])])
        >>> collision_index(H)  # Two distinct sizes, each with prob 1/2
        0.5
    """
    sizes = edge_sizes(H)
    if not sizes:
        return 1.0
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c / n) ** 2 for c in counts.values())


def edge_size_distribution_support(H: Hypergraph) -> set:
    """
    Return the set of distinct edge cardinalities.

    Time: O(|E|)
    Space: O(|distinct sizes|)
    """
    return set(edge_sizes(H))


# ============================================================
# Algorithm 2: Exact Transversal Number (Brute Force)
# ============================================================

def is_transversal(H: Hypergraph, S: Set[int]) -> bool:
    """
    Check if S is a transversal (hitting set) of H.

    Time: O(|E| · |S|)

    Example:
        >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
        >>> is_transversal(H, {1})
        True
        >>> is_transversal(H, {0})
        False
    """
    return all(len(S & e) > 0 for e in H.edges)


def transversal_number_exact(H: Hypergraph) -> int:
    """
    Compute τ(H) exactly by exhaustive search over all subsets.

    Finds the minimum cardinality transversal.

    Time: O(2^n · |E| · n)  — exponential, only practical for n ≤ 20
    Space: O(n)

    Example:
        >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
        >>> transversal_number_exact(H)
        1
    """
    if not H.edges:
        return 0
    vertices = list(range(H.n))
    for k in range(H.n + 1):
        for S in itertools.combinations(vertices, k):
            if is_transversal(H, set(S)):
                return k
    return H.n


# ============================================================
# Algorithm 3: Fractional Transversal Number (LP Relaxation)
# ============================================================

def fractional_transversal_number(H: Hypergraph) -> float:
    """
    Compute τ*(H) by solving the LP relaxation:
        min  Σ_v x_v
        s.t. Σ_{v ∈ e} x_v ≥ 1  for all e ∈ E
             x_v ≥ 0             for all v ∈ V

    Uses scipy's HiGHS solver.

    Time: polynomial in n and |E| (LP complexity)
    Space: O(n · |E|)

    Example:
        >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
        >>> fractional_transversal_number(H)
        1.0
    """
    try:
        from scipy.optimize import linprog
    except ImportError:
        raise RuntimeError("scipy required for LP solving")

    n = H.n
    m = len(H.edges)
    if m == 0:
        return 0.0

    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, e in enumerate(H.edges):
        for v in e:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None) for _ in range(n)]

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return float(result.fun)
    raise RuntimeError(f"LP solver failed: {result.message}")


# ============================================================
# Algorithm 4: Certified Fractional Transversal Verification
# ============================================================

def verify_fractional_transversal(
    H: Hypergraph,
    x: Dict[int, Fraction]
) -> Tuple[bool, Optional[str]]:
    """
    Verify that x is a valid fractional transversal using exact arithmetic.

    Checks:
      1. x_v ≥ 0 for all v
      2. Σ_{v ∈ e} x_v ≥ 1 for all edges e

    Returns (True, None) if valid, (False, reason) otherwise.

    Time: O(|E| · max_edge_size)
    Space: O(n)

    Example:
        >>> H = Hypergraph(3, [frozenset([0,1]), frozenset([1,2])])
        >>> x = {0: Fraction(1,2), 1: Fraction(1,2), 2: Fraction(1,2)}
        >>> verify_fractional_transversal(H, x)
        (True, None)
    """
    # Check nonnegativity
    for v, val in x.items():
        if val < 0:
            return False, f"x[{v}] = {val} < 0"

    # Check covering
    for i, e in enumerate(H.edges):
        total = sum(x.get(v, Fraction(0)) for v in e)
        if total < 1:
            return False, f"Edge {i} has sum {total} < 1"

    return True, None


def fractional_transversal_value(x: Dict[int, Fraction]) -> Fraction:
    """Compute the total value of a fractional transversal."""
    return sum(x.values())


# ============================================================
# Algorithm 5: Gap Analysis
# ============================================================

def integrality_gap(H: Hypergraph) -> Dict:
    """
    Compute the full integrality gap analysis for a hypergraph.

    Returns a dictionary with:
      - tau: integer transversal number
      - tau_star: fractional transversal number
      - gap: τ - τ*
      - ceil_gap: τ - ⌈τ*⌉
      - heterogeneity: edge-size variance
      - support_width: max - min edge size
      - collision_index: Herfindahl index
      - has_positive_ceil_gap: whether ⌈τ*⌉ < τ

    Time: O(2^n · |E|) dominated by exact τ computation
    """
    tau = transversal_number_exact(H)
    tau_star = fractional_transversal_number(H)
    het = edge_heterogeneity(H)
    width = edge_size_support_width(H)
    ci = collision_index(H)

    gap = tau - tau_star
    ceil_gap = tau - int(np.ceil(tau_star - 1e-10))

    return {
        'tau': tau,
        'tau_star': tau_star,
        'gap': gap,
        'ceil_gap': ceil_gap,
        'heterogeneity': het,
        'support_width': width,
        'collision_index': ci,
        'has_positive_ceil_gap': ceil_gap >= 1,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example 1: Uniform hypergraph (3-uniform)
    print("Example 1: 3-uniform hypergraph")
    H1 = Hypergraph(6, [
        frozenset([0, 1, 2]),
        frozenset([2, 3, 4]),
        frozenset([4, 5, 0]),
    ])
    print(f"  Heterogeneity: {edge_heterogeneity(H1)}")
    print(f"  Support width: {edge_size_support_width(H1)}")
    print(f"  Collision index: {collision_index(H1)}")
    result1 = integrality_gap(H1)
    print(f"  τ = {result1['tau']}, τ* = {result1['tau_star']:.3f}")
    print(f"  Gap = {result1['gap']:.3f}")
    print()

    # Example 2: Two-level hypergraph
    print("Example 2: Two-level hypergraph (sizes 2 and 4)")
    H2 = Hypergraph(8, [
        frozenset([0, 1]),
        frozenset([2, 3]),
        frozenset([4, 5]),
        frozenset([6, 7]),
        frozenset([0, 2, 4, 6]),
        frozenset([1, 3, 5, 7]),
    ])
    print(f"  Heterogeneity: {edge_heterogeneity(H2)}")
    print(f"  Support width: {edge_size_support_width(H2)}")
    print(f"  Collision index: {collision_index(H2)}")
    result2 = integrality_gap(H2)
    print(f"  τ = {result2['tau']}, τ* = {result2['tau_star']:.3f}")
    print(f"  Gap = {result2['gap']:.3f}")
    print(f"  Ceiling gap = {result2['ceil_gap']}")
    print()

    # Example 3: Verified fractional transversal
    print("Example 3: Certified fractional transversal verification")
    x = {v: Fraction(1, 2) for v in range(8)}
    valid, reason = verify_fractional_transversal(H2, x)
    print(f"  x = 1/2 for all vertices")
    print(f"  Valid: {valid}")
    print(f"  Value: {fractional_transversal_value(x)} = {float(fractional_transversal_value(x))}")
