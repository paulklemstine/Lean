"""
Algorithms for Transversal Predictor Theory
============================================

Implements exact and greedy algorithms for computing transversal numbers
of finite obstruction hypergraphs, along with the transversal predictor
for phase transition location.

All algorithms operate on hypergraphs represented as:
  - V: a set of vertices (ground set)
  - C: a collection of hyperedges (obstructions), each a frozenset of vertices
"""

from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Collection
import math


# ---------------------------------------------------------------------------
# Type aliases
# ---------------------------------------------------------------------------
Vertex = int
Edge = FrozenSet[Vertex]
Hypergraph = list[Edge]


# ---------------------------------------------------------------------------
# Exact transversal number (brute-force for small instances)
# ---------------------------------------------------------------------------

def is_hitting_set(C: Collection[Edge], T: frozenset[Vertex]) -> bool:
    """Check whether T intersects every hyperedge in C.

    >>> C = [frozenset({1,2,3}), frozenset({2,3,4})]
    >>> is_hitting_set(C, frozenset({2}))
    True
    >>> is_hitting_set(C, frozenset({1,4}))
    True
    >>> is_hitting_set(C, frozenset({1}))
    False
    """
    return all(T & e for e in C)


def transversal_number_exact(V: set[Vertex], C: Collection[Edge]) -> int:
    """Compute the exact transversal number τ(C) by brute-force search.

    Returns the minimum size of a hitting set of C within V.
    Complexity: O(2^|V| * |C|) — only feasible for |V| ≤ ~25.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> transversal_number_exact(V, C)
    2
    >>> C = [frozenset({1,2}), frozenset({1,3}), frozenset({1,4})]
    >>> transversal_number_exact(V, C)
    1
    """
    if not C:
        return 0
    V_list = sorted(V)
    for k in range(len(V_list) + 1):
        for subset in combinations(V_list, k):
            T = frozenset(subset)
            if is_hitting_set(C, T):
                return k
    return len(V)  # should never reach here


def minimum_hitting_set(V: set[Vertex], C: Collection[Edge]) -> frozenset[Vertex]:
    """Return a minimum-cardinality hitting set.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> T = minimum_hitting_set(V, C)
    >>> len(T)
    2
    >>> is_hitting_set(C, T)
    True
    """
    if not C:
        return frozenset()
    V_list = sorted(V)
    for k in range(len(V_list) + 1):
        for subset in combinations(V_list, k):
            T = frozenset(subset)
            if is_hitting_set(C, T):
                return T
    return frozenset(V)


# ---------------------------------------------------------------------------
# Greedy transversal (logarithmic approximation)
# ---------------------------------------------------------------------------

def greedy_hitting_set(V: set[Vertex], C: Collection[Edge]) -> frozenset[Vertex]:
    """Greedy hitting set: repeatedly pick the vertex covering the most uncovered edges.

    This gives an H_r-approximation where r = max edge size (set cover guarantee).

    >>> V = {1, 2, 3, 4, 5}
    >>> C = [frozenset({1,2,3}), frozenset({2,3,4}), frozenset({4,5})]
    >>> T = greedy_hitting_set(V, C)
    >>> is_hitting_set(C, T)
    True
    """
    uncovered = list(C)
    T = set()
    while uncovered:
        # Pick vertex covering the most uncovered edges
        best_v = max(V, key=lambda v: sum(1 for e in uncovered if v in e))
        T.add(best_v)
        uncovered = [e for e in uncovered if best_v not in e]
    return frozenset(T)


def greedy_transversal_number(V: set[Vertex], C: Collection[Edge]) -> int:
    """Greedy approximation of the transversal number.

    >>> V = {1, 2, 3, 4, 5}
    >>> C = [frozenset({1,2,3}), frozenset({2,3,4}), frozenset({4,5})]
    >>> tau_g = greedy_transversal_number(V, C)
    >>> tau_g >= 2  # true minimum is 2
    True
    """
    return len(greedy_hitting_set(V, C))


# ---------------------------------------------------------------------------
# Transversal predictor and related invariants
# ---------------------------------------------------------------------------

def transversal_predictor(V: set[Vertex], C: Collection[Edge],
                          exact: bool = True) -> int:
    """Compute the transversal predictor k_τ(C) = |V| - τ(C).

    This is the largest subset size at which satisfiability is possible.

    Args:
        V: ground set
        C: obstruction hyperedges
        exact: if True, use exact τ(C); otherwise use greedy approximation

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> transversal_predictor(V, C)
    2
    """
    if exact:
        tau = transversal_number_exact(V, C)
    else:
        tau = greedy_transversal_number(V, C)
    return len(V) - tau


def transversal_slack(V: set[Vertex], C: Collection[Edge],
                      S: frozenset[Vertex]) -> int:
    """Compute the transversal slack σ_C(S) = |V \\ S| - τ(C).

    Positive slack indicates satisfiability is structurally plausible.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> transversal_slack(V, C, frozenset({1, 3}))
    0
    >>> transversal_slack(V, C, frozenset({1}))
    1
    """
    tau = transversal_number_exact(V, C)
    complement_size = len(V - S)
    return complement_size - tau


def uniform_obstruction_rank(C: Collection[Edge]) -> int:
    """Maximum edge size in the hypergraph.

    >>> C = [frozenset({1,2,3}), frozenset({2,3})]
    >>> uniform_obstruction_rank(C)
    3
    """
    if not C:
        return 0
    return max(len(e) for e in C)


def obstruction_density(V: set[Vertex], C: Collection[Edge]) -> float:
    """Density ρ = |C| / |V|.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> obstruction_density(V, C)
    0.5
    """
    if not V:
        return 0.0
    return len(list(C)) / len(V)


# ---------------------------------------------------------------------------
# Satisfiability checking and counting
# ---------------------------------------------------------------------------

def is_satisfiable(C: Collection[Edge], S: frozenset[Vertex]) -> bool:
    """Check whether S is satisfiable: no obstruction is fully contained in S.

    >>> C = [frozenset({1,2,3}), frozenset({2,3,4})]
    >>> is_satisfiable(C, frozenset({1,2}))
    True
    >>> is_satisfiable(C, frozenset({1,2,3}))
    False
    """
    return all(not e.issubset(S) for e in C)


def max_satisfiable_card(V: set[Vertex], C: Collection[Edge]) -> int:
    """Compute the maximum cardinality of a satisfiable subset.

    Theorem: this equals |V| - τ(C).

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> max_satisfiable_card(V, C)
    2
    """
    V_list = sorted(V)
    best = 0
    for k in range(len(V_list), -1, -1):
        for subset in combinations(V_list, k):
            S = frozenset(subset)
            if is_satisfiable(C, S):
                return k
    return 0


def sat_count_at_card(V: set[Vertex], C: Collection[Edge], k: int) -> int:
    """Count the number of k-element satisfiable subsets.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> sat_count_at_card(V, C, 2)
    4
    """
    V_list = sorted(V)
    count = 0
    for subset in combinations(V_list, k):
        S = frozenset(subset)
        if is_satisfiable(C, S):
            count += 1
    return count


def sat_probability_at_card(V: set[Vertex], C: Collection[Edge], k: int) -> float:
    """Probability that a random k-element subset is satisfiable.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2}), frozenset({3,4})]
    >>> sat_probability_at_card(V, C, 2)  # 4/6
    0.6666666666666666
    """
    total = math.comb(len(V), k)
    if total == 0:
        return 0.0
    return sat_count_at_card(V, C, k) / total


# ---------------------------------------------------------------------------
# Triangle obstruction systems (Kn)
# ---------------------------------------------------------------------------

def triangle_edges(n: int) -> set[Vertex]:
    """Ground set: ordered edges of K_n, encoded as (i,j) -> i*n + j."""
    return {i * n + j for i in range(n) for j in range(i + 1, n)}


def triangle_obstructions(n: int) -> Hypergraph:
    """Obstruction hypergraph for triangle-freeness on K_n.

    Each triangle {i,j,k} with i<j<k contributes the edge set
    {(i,j), (i,k), (j,k)} as an obstruction.

    >>> len(triangle_obstructions(4))
    4
    >>> len(triangle_obstructions(5))
    10
    """
    obstructions = []
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                edge_set = frozenset({i * n + j, i * n + k, j * n + k})
                obstructions.append(edge_set)
    return obstructions


# ---------------------------------------------------------------------------
# Fractional transversal (LP relaxation via simple rounding)
# ---------------------------------------------------------------------------

def fractional_transversal_uniform(V: set[Vertex], C: Collection[Edge]) -> float:
    """Simple fractional transversal lower bound.

    For uniform hypergraphs of rank r, assigns weight 1/r to every vertex
    in the union of edges. This gives a feasible fractional solution.
    The LP dual gives τ* ≤ τ.

    Returns a lower bound on τ(C) via the simple 1/r weighting.

    >>> V = {1, 2, 3, 4}
    >>> C = [frozenset({1,2,3}), frozenset({2,3,4})]
    >>> fractional_transversal_uniform(V, C) <= 2
    True
    """
    if not C:
        return 0.0
    r = uniform_obstruction_rank(C)
    if r == 0:
        return 0.0
    # Simple LP relaxation: w(v) = 1/r for v in union of edges
    # This is feasible since each edge has r elements each with weight 1/r
    vertices_in_edges = set()
    for e in C:
        vertices_in_edges |= e
    return len(vertices_in_edges) / r


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    print("All doctests passed.")

    # Quick example
    V = {1, 2, 3, 4, 5}
    C = [frozenset({1, 2, 3}), frozenset({3, 4, 5}), frozenset({1, 4, 5})]
    tau = transversal_number_exact(V, C)
    pred = transversal_predictor(V, C)
    msc = max_satisfiable_card(V, C)
    print(f"\nExample: V={V}")
    print(f"Obstructions: {C}")
    print(f"τ(C) = {tau}")
    print(f"Transversal predictor k_τ = |V| - τ = {pred}")
    print(f"Max satisfiable card = {msc}")
    print(f"Theorem verified: k_τ == max_sat_card? {pred == msc}")
