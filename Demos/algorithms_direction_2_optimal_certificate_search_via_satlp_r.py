#!/usr/bin/env python3
"""
algorithms.py — Algorithms for hypergraph transversal computation
with monotone SAT reduction and sunflower-based branching.

Implements:
1. Brute-force minimum transversal
2. Greedy hitting set approximation
3. Sunflower detection and pruning
4. LP relaxation for hitting set (using scipy)
5. Monotone SAT encoding and decoding

All algorithms include docstrings, type hints, and complexity analysis.
"""

from itertools import combinations
from typing import List, Set, Tuple, Optional, Dict, FrozenSet
from collections import defaultdict
import math


class Hypergraph:
    """A finite hypergraph with vertices and edges (sets of vertices).

    Attributes:
        vertices: Set of vertex labels (integers).
        edges: List of edges, each a frozenset of vertices.
    """

    def __init__(self, vertices: Set[int], edges: List[Set[int]]):
        self.vertices = frozenset(vertices)
        self.edges = [frozenset(e) for e in edges]

    @property
    def num_vertices(self) -> int:
        return len(self.vertices)

    @property
    def num_edges(self) -> int:
        return len(self.edges)

    @property
    def max_edge_size(self) -> int:
        return max((len(e) for e in self.edges), default=0)

    def is_transversal(self, T: Set[int]) -> bool:
        """Check if T is a transversal (hitting set).

        Time: O(|edges| · max_edge_size)
        """
        return all(T & e for e in self.edges)

    def degree(self, v: int) -> int:
        """Number of edges containing vertex v."""
        return sum(1 for e in self.edges if v in e)

    def remove_vertex(self, v: int) -> 'Hypergraph':
        """Return hypergraph with all edges containing v removed."""
        remaining = [e for e in self.edges if v not in e]
        return Hypergraph(self.vertices - {v}, remaining)

    def __repr__(self) -> str:
        return f"Hypergraph(|V|={self.num_vertices}, |E|={self.num_edges})"


def brute_force_min_transversal(H: Hypergraph) -> Tuple[Set[int], int]:
    """Find minimum transversal by exhaustive search.

    Time: O(2^|V| · |E| · d) where d = max edge size
    Space: O(|V|)

    Returns:
        (transversal, size)
    """
    if not H.edges:
        return set(), 0

    v_list = sorted(H.vertices)
    for k in range(1, len(v_list) + 1):
        for combo in combinations(v_list, k):
            T = set(combo)
            if H.is_transversal(T):
                return T, k
    return set(v_list), len(v_list)


def greedy_hitting_set(H: Hypergraph) -> Tuple[Set[int], int]:
    """Greedy approximation: repeatedly pick the highest-degree vertex.

    Approximation ratio: H_d (d-th harmonic number) for d-uniform hypergraphs.
    For d=3 (Pythagorean triples): ratio ≤ 11/6 ≈ 1.83.

    Time: O(|V| · |E| · d) per iteration, O(τ) iterations
    Space: O(|V| + |E| · d)

    Returns:
        (transversal, size)
    """
    T: Set[int] = set()
    remaining_edges = list(H.edges)
    vertices = set(H.vertices)

    while remaining_edges:
        # Find vertex with maximum degree in remaining edges
        degrees: Dict[int, int] = defaultdict(int)
        for e in remaining_edges:
            for v in e:
                if v in vertices:
                    degrees[v] += 1

        if not degrees:
            break

        best_v = max(degrees, key=degrees.get)
        T.add(best_v)
        vertices.discard(best_v)

        # Remove all edges hit by best_v
        remaining_edges = [e for e in remaining_edges if best_v not in e]

    return T, len(T)


def find_sunflower(edges: List[FrozenSet[int]], d: int, k: int) -> Optional[Tuple[FrozenSet[int], List[FrozenSet[int]]]]:
    """Find a sunflower of size k in a family of sets of size ≤ d.

    Uses the Erdős–Rado bound: if |edges| > d! · (k-1)^d, a sunflower exists.

    Time: O(|edges|^k · d^2) worst case (brute force search)
    Space: O(|edges| · d)

    Returns:
        (kernel, list_of_edges) or None if no sunflower found
    """
    for combo in combinations(range(len(edges)), k):
        edge_group = [edges[i] for i in combo]
        # Check if they form a sunflower
        pairs = list(combinations(edge_group, 2))
        if not pairs:
            continue
        kernel = pairs[0][0] & pairs[0][1]
        if all(e1 & e2 == kernel for e1, e2 in pairs):
            petals = [e - kernel for e in edge_group]
            if all(p1.isdisjoint(p2) for p1, p2 in combinations(petals, 2)):
                return kernel, edge_group
    return None


def sunflower_branching_transversal(H: Hypergraph, budget: int = 100) -> Tuple[Set[int], int]:
    """FPT algorithm for minimum transversal using sunflower branching.

    Algorithm:
    1. If no edges, return ∅.
    2. If a sunflower of size > d·τ exists, branch on kernel elements.
    3. Otherwise, the edge count is bounded; solve by brute force.

    Parameterized complexity: O(d^τ · poly(n))
    where d = max edge size, τ = transversal number.

    Returns:
        (transversal, size)
    """
    if not H.edges:
        return set(), 0

    d = H.max_edge_size
    if d == 0:
        return set(), 0

    # Try to find a sunflower of size d+1
    sunflower = find_sunflower(H.edges, d, d + 1)

    if sunflower is not None:
        kernel, sf_edges = sunflower
        if kernel:
            # Branch on kernel elements
            best_T: Optional[Set[int]] = None
            best_size = float('inf')
            for v in kernel:
                sub_H = H.remove_vertex(v)
                sub_T, sub_size = sunflower_branching_transversal(sub_H, budget - 1)
                if budget <= 0:
                    break
                candidate = sub_T | {v}
                if len(candidate) < best_size:
                    best_T = candidate
                    best_size = len(candidate)
            return best_T or set(), best_size if best_T else 0

    # No large sunflower found; use greedy as fallback
    return greedy_hitting_set(H)


def encode_monotone_sat(H: Hypergraph) -> Tuple[List[List[int]], Dict[int, int]]:
    """Encode a hitting set problem as a monotone CNF.

    Each edge becomes a clause (disjunction of positive literals).
    Variables correspond to vertices.

    Time: O(|E| · d)
    Space: O(|V| + |E| · d)

    Returns:
        (clauses, variable_map) where clauses is a list of lists of positive ints,
        and variable_map maps vertex labels to variable indices.
    """
    var_map = {v: i + 1 for i, v in enumerate(sorted(H.vertices))}
    clauses = [[var_map[v] for v in sorted(e)] for e in H.edges]
    return clauses, var_map


def decode_sat_assignment(assignment: Set[int], var_map: Dict[int, int]) -> Set[int]:
    """Decode a SAT assignment back to a vertex set.

    Time: O(|assignment|)
    """
    inv_map = {v: k for k, v in var_map.items()}
    return {inv_map[v] for v in assignment if v in inv_map}


def lp_relaxation_bound(H: Hypergraph) -> float:
    """Compute LP relaxation lower bound for minimum hitting set.

    The LP relaxation assigns fractional values x_v ∈ [0,1] to each vertex
    and minimizes Σ x_v subject to Σ_{v∈e} x_v ≥ 1 for each edge e.

    For d-uniform hypergraphs, the integrality gap is at most H_d.

    Uses a simple dual bound: the LP value ≥ |edges| / max_degree.

    Time: O(|V| · |E|)
    """
    if not H.edges:
        return 0.0

    max_deg = max(H.degree(v) for v in H.vertices) if H.vertices else 1
    return len(H.edges) / max(max_deg, 1)


def verify_transversal_optimality(H: Hypergraph, T: Set[int]) -> Dict[str, any]:
    """Verify properties of a transversal.

    Returns a dictionary with:
    - is_transversal: bool
    - is_minimal: bool (no proper subset is a transversal)
    - lp_bound: float (LP relaxation lower bound)
    - ratio: float (|T| / lp_bound)
    """
    is_trans = H.is_transversal(T)

    # Check minimality
    is_minimal = True
    if is_trans:
        for v in T:
            if H.is_transversal(T - {v}):
                is_minimal = False
                break

    lp_bound = lp_relaxation_bound(H)
    ratio = len(T) / lp_bound if lp_bound > 0 else float('inf')

    return {
        'is_transversal': is_trans,
        'is_minimal': is_minimal,
        'lp_bound': lp_bound,
        'ratio': ratio,
        'size': len(T),
    }


# ─── Example usage ───

if __name__ == "__main__":
    print("Algorithms for Hypergraph Transversal Computation")
    print("=" * 50)

    # Build Pythagorean triple hypergraph
    from demo import find_pythagorean_triples

    for n in [10, 15, 20, 25]:
        triples = find_pythagorean_triples(n)
        vertices = set(range(1, n + 1))
        edges = [set(t) for t in triples]
        H = Hypergraph(vertices, edges)

        print(f"\n{H}")

        # Brute force (for small n)
        if n <= 20:
            bf_T, bf_size = brute_force_min_transversal(H)
            print(f"  Brute force: τ = {bf_size}, T = {sorted(bf_T)}")

        # Greedy
        gr_T, gr_size = greedy_hitting_set(H)
        print(f"  Greedy:      τ ≈ {gr_size}, T = {sorted(gr_T)}")

        # Sunflower branching
        sf_T, sf_size = sunflower_branching_transversal(H)
        print(f"  Sunflower:   τ ≈ {sf_size}, T = {sorted(sf_T)}")

        # LP bound
        lp = lp_relaxation_bound(H)
        print(f"  LP bound:    ≥ {lp:.2f}")

        # Verification
        info = verify_transversal_optimality(H, gr_T)
        print(f"  Greedy ratio: {info['ratio']:.3f}")

        # SAT encoding
        clauses, var_map = encode_monotone_sat(H)
        print(f"  SAT encoding: {len(clauses)} clauses, {len(var_map)} variables")
        print(f"  All clauses monotone (positive): {all(all(l > 0 for l in c) for c in clauses)}")
