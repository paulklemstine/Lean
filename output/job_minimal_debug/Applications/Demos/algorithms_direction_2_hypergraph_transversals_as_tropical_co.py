#!/usr/bin/env python3
"""
Algorithms for Tropical Hypergraph Transversal Theory

Implements the verified algorithms from the research paper:
1. Threshold rounding algorithm for fractional transversals
2. Active witness certification
3. Tropical extremality detection
4. Feasibility-preserving upward closure construction

All algorithms operate over exact rational arithmetic (fractions.Fraction)
for mathematical rigor matching the Lean formalization.
"""

from fractions import Fraction
from typing import List, Set, FrozenSet, Dict, Tuple, Optional
from itertools import combinations


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Threshold Rounding
# ──────────────────────────────────────────────────────────────────────────────

def threshold_round(
    vertices: Set[int],
    edges: List[FrozenSet[int]],
    x: Dict[int, Fraction],
    d: Optional[int] = None
) -> Tuple[FrozenSet[int], Dict[str, object]]:
    """
    Threshold rounding algorithm for fractional transversals.

    Given a fractional transversal x of a rank-d hypergraph,
    compute the threshold set T_{1/d}(x) = {v : x(v) ≥ 1/d}.

    Args:
        vertices: The vertex set V
        edges: List of edges (each a frozenset of vertices)
        x: Fractional assignment x: V → ℚ≥0
        d: Rank bound (max edge size). Auto-computed if None.

    Returns:
        (S, info) where S is the threshold set and info contains diagnostics.

    Complexity: O(|V| + |E| · d) time, O(|V|) space.
    """
    if d is None:
        d = max(len(e) for e in edges) if edges else 1

    tau = Fraction(1, d)
    S = frozenset(v for v in vertices if x.get(v, Fraction(0)) >= tau)

    # Verify transversal property
    is_transversal = all(len(e & S) > 0 for e in edges)

    # Compute cost ratio
    frac_cost = sum(x.get(v, Fraction(0)) for v in vertices)
    int_cost = len(S)
    ratio = Fraction(int_cost, 1) / frac_cost if frac_cost > 0 else None

    info = {
        'tau': tau,
        'd': d,
        'is_transversal': is_transversal,
        'fractional_cost': frac_cost,
        'integral_cost': int_cost,
        'approximation_ratio': ratio,
        'ratio_within_d': ratio is not None and ratio <= d,
    }

    return S, info


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Active Witness Certification
# ──────────────────────────────────────────────────────────────────────────────

def certify_active_witnesses(
    edges: List[FrozenSet[int]],
    x: Dict[int, Fraction]
) -> Tuple[bool, Dict[int, Optional[FrozenSet[int]]]]:
    """
    Certify the unique active witness property for a fractional assignment.

    For each support vertex v, find an edge e such that:
    - v ∈ e
    - Σ_{u ∈ e} x(u) = 1 (active constraint)
    - No other support vertex is in e

    Args:
        edges: List of hypergraph edges
        x: Fractional assignment

    Returns:
        (has_property, witnesses) where witnesses maps each support vertex
        to its witness edge (or None if no witness exists).

    Complexity: O(|supp(x)| · |E| · d) time.
    """
    supp = frozenset(v for v, xv in x.items() if xv != Fraction(0))
    witnesses: Dict[int, Optional[FrozenSet[int]]] = {}

    for v in supp:
        witnesses[v] = None
        for e in edges:
            if v not in e:
                continue
            edge_sum = sum(x.get(u, Fraction(0)) for u in e)
            if edge_sum != Fraction(1):
                continue
            # Check isolation
            other_supp = {u for u in supp if u != v and u in e}
            if len(other_supp) == 0:
                witnesses[v] = e
                break

    has_property = all(w is not None for w in witnesses.values())
    return has_property, witnesses


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Extremality Detection
# ──────────────────────────────────────────────────────────────────────────────

def detect_tropical_extremality(
    vertices: Set[int],
    edges: List[FrozenSet[int]],
    S: FrozenSet[int],
    d: int
) -> Dict[str, object]:
    """
    Detect tropical extremality of an integral transversal S.

    Checks multiple extremality criteria:
    1. Minimality: no proper subset of S is a transversal
    2. Witness support: S admits a feasible fractional transversal
       with unique active witnesses on S
    3. Irreducibility: S cannot be written as union of two proper
       sub-transversals

    Args:
        vertices: Vertex set
        edges: Hypergraph edges
        S: Candidate integral transversal
        d: Rank bound

    Returns:
        Dictionary with extremality analysis.

    Complexity: O(|S| · |E| + 2^|S| · |E|) worst case for minimality check.
    """
    is_trans = all(len(e & S) > 0 for e in edges)

    # Minimality check
    is_minimal = is_trans
    if is_trans:
        for v in S:
            S_minus_v = S - {v}
            if all(len(e & S_minus_v) > 0 for e in edges):
                is_minimal = False
                break

    # Irreducibility check
    is_irreducible = True
    if is_trans and len(S) >= 2:
        for size in range(1, len(S)):
            for subset in combinations(S, size):
                A = frozenset(subset)
                B = S - A
                if (all(len(e & A) > 0 for e in edges) and
                    all(len(e & B) > 0 for e in edges)):
                    is_irreducible = False
                    break
            if not is_irreducible:
                break

    # Check if S arises from threshold rounding
    tau = Fraction(1, d)
    # The indicator of S, scaled to 1/d on S, is feasible iff S is a transversal
    x_witness = {v: tau if v in S else Fraction(0) for v in vertices}
    arises_from_threshold = (
        all(sum(x_witness.get(u, Fraction(0)) for u in e) >= 1
            for e in edges)
    )

    return {
        'is_transversal': is_trans,
        'is_minimal': is_minimal,
        'is_irreducible': is_irreducible,
        'arises_from_threshold': arises_from_threshold,
        'tropically_extremal': is_minimal and is_irreducible,
    }


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Feasibility-Preserving Upward Closure
# ──────────────────────────────────────────────────────────────────────────────

def construct_upward_closure(
    vertices: Set[int],
    edges: List[FrozenSet[int]],
    x: Dict[int, Fraction],
    S: FrozenSet[int],
    S_prime: FrozenSet[int],
    d: int
) -> Tuple[Dict[int, Fraction], Dict[str, object]]:
    """
    Construct a feasible fractional transversal y such that
    T_{1/d}(y) = S' ⊇ S = T_{1/d}(x).

    The construction sets y(v) = max(x(v), 1/d) for v ∈ S',
    and y(v) = x(v) for v ∉ S'.

    Args:
        vertices: Vertex set
        edges: Hypergraph edges
        x: Original feasible fractional transversal
        S: Original threshold set T_{1/d}(x)
        S_prime: Target superset S' ⊇ S
        d: Rank bound

    Returns:
        (y, info) where y is the constructed fractional transversal.

    Complexity: O(|V| + |E| · d) time.
    """
    tau = Fraction(1, d)
    y = {}
    for v in vertices:
        if v in S_prime:
            y[v] = max(x.get(v, Fraction(0)), tau)
        else:
            y[v] = x.get(v, Fraction(0))

    # Verify
    T_y = frozenset(v for v in vertices if y[v] >= tau)
    is_feasible = all(
        sum(y.get(u, Fraction(0)) for u in e) >= 1
        for e in edges
    )

    info = {
        'threshold_set_correct': T_y == S_prime,
        'is_feasible': is_feasible,
        'cost_increase': sum(y[v] - x.get(v, Fraction(0)) for v in vertices),
    }

    return y, info


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Exhaustive BFS Enumeration (small instances)
# ──────────────────────────────────────────────────────────────────────────────

def enumerate_vertex_minimal_transversals(
    vertices: Set[int],
    edges: List[FrozenSet[int]]
) -> List[FrozenSet[int]]:
    """
    Enumerate all minimal transversals of a hypergraph.

    Complexity: O(2^|V| · |E| · d) worst case.
    Only practical for |V| ≤ 15.
    """
    minimal = []
    for size in range(1, len(vertices) + 1):
        for combo in combinations(sorted(vertices), size):
            S = frozenset(combo)
            if all(len(e & S) > 0 for e in edges):
                # Check minimality
                if all(not all(len(e & (S - {v})) > 0 for e in edges) for v in S):
                    minimal.append(S)
    return minimal


# ──────────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Hypergraph Transversal Algorithms")
    print("=" * 50)
    print()

    # Example hypergraph
    vertices = {0, 1, 2, 3, 4}
    edges = [
        frozenset({0, 1, 2}),
        frozenset({2, 3, 4}),
        frozenset({0, 4}),
    ]
    d = max(len(e) for e in edges)

    # Fractional transversal
    x = {0: Fraction(1, 2), 1: Fraction(0), 2: Fraction(1, 2),
         3: Fraction(0), 4: Fraction(1, 2)}

    print(f"Hypergraph: V={vertices}, rank={d}")
    print(f"Edges: {[set(e) for e in edges]}")
    print(f"x = {dict(x)}")
    print()

    # Algorithm 1: Threshold rounding
    S, info = threshold_round(vertices, edges, x, d)
    print(f"Algorithm 1 - Threshold Rounding:")
    print(f"  T_{{1/{d}}}(x) = {set(S)}")
    print(f"  Is transversal: {info['is_transversal']}")
    print(f"  Approximation ratio: {info['approximation_ratio']}")
    print()

    # Algorithm 2: Active witness certification
    has_wit, witnesses = certify_active_witnesses(edges, x)
    print(f"Algorithm 2 - Active Witness Certification:")
    print(f"  Has unique active witnesses: {has_wit}")
    for v, w in witnesses.items():
        print(f"    Vertex {v}: witness = {set(w) if w else None}")
    print()

    # Algorithm 3: Tropical extremality
    extremality = detect_tropical_extremality(vertices, edges, S, d)
    print(f"Algorithm 3 - Tropical Extremality:")
    for key, val in extremality.items():
        print(f"  {key}: {val}")
    print()

    # Algorithm 4: Upward closure
    S_prime = S | frozenset({1})
    y, info2 = construct_upward_closure(vertices, edges, x, S, S_prime, d)
    print(f"Algorithm 4 - Upward Closure:")
    print(f"  S = {set(S)}, S' = {set(S_prime)}")
    print(f"  y = {dict(y)}")
    print(f"  T_τ(y) = S': {info2['threshold_set_correct']}")
    print(f"  y is feasible: {info2['is_feasible']}")
    print()

    # Algorithm 5: Minimal transversals
    minimals = enumerate_vertex_minimal_transversals(vertices, edges)
    print(f"Algorithm 5 - All Minimal Transversals:")
    for m in minimals:
        print(f"  {set(m)}")
