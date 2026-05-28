"""
Algorithms for Hypergraph Transversal with Bounded Pair Codegree.

Implements:
- Threshold rounding for d-uniform hypergraph transversals
- Pair codegree computation
- Conflict graph construction and greedy coloring
- Layered threshold rounding algorithm
- LP/ILP solvers for τ* and τ

Dependencies: numpy, scipy (for LP)
"""

from typing import List, Set, Tuple, Dict, Optional
from itertools import combinations
import numpy as np


def pair_codegree(edges: List[Set[int]], u: int, v: int) -> int:
    """Compute the pair codegree of vertices u and v.

    Args:
        edges: List of edges (each a set of vertex indices).
        u, v: Vertices.

    Returns:
        Number of edges containing both u and v.

    >>> pair_codegree([{0,1,2}, {1,2,3}, {0,2,4}], 1, 2)
    2
    """
    return sum(1 for e in edges if u in e and v in e)


def max_pair_codegree(edges: List[Set[int]]) -> int:
    """Compute the maximum pair codegree of a hypergraph.

    Args:
        edges: List of edges.

    Returns:
        Maximum codegree over all distinct vertex pairs.

    >>> max_pair_codegree([{0,1,2}, {1,2,3}, {0,2,4}])
    2
    """
    vertices = set().union(*edges) if edges else set()
    max_codeg = 0
    for u, v in combinations(vertices, 2):
        max_codeg = max(max_codeg, pair_codegree(edges, u, v))
    return max_codeg


def threshold_set(x: Dict[int, float], theta: float) -> Set[int]:
    """Compute the threshold set {v : x(v) >= theta}.

    Args:
        x: Fractional assignment (vertex -> weight).
        theta: Threshold value.

    Returns:
        Set of vertices with weight >= theta.

    >>> threshold_set({0: 0.5, 1: 0.3, 2: 0.8}, 0.4)
    {0, 2}
    """
    return {v for v, val in x.items() if val >= theta}


def uncovered_edges(edges: List[Set[int]], S: Set[int]) -> List[Set[int]]:
    """Find edges not hit by vertex set S.

    Args:
        edges: List of edges.
        S: Vertex set.

    Returns:
        Edges with no vertex in S.

    >>> uncovered_edges([{0,1,2}, {1,2,3}, {3,4,5}], {0, 3})
    []
    """
    return [e for e in edges if not (e & S)]


def conflict_graph(edges: List[Set[int]]) -> Dict[int, Set[int]]:
    """Build the conflict graph: edge i ~ edge j iff |e_i ∩ e_j| >= 2.

    Args:
        edges: List of edges.

    Returns:
        Adjacency dict: vertex index -> set of neighbor indices.

    >>> g = conflict_graph([{0,1,2}, {1,2,3}, {4,5,6}])
    >>> 1 in g[0]
    True
    >>> 2 in g[0]
    False
    """
    n = len(edges)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if len(edges[i] & edges[j]) >= 2:
                adj[i].add(j)
                adj[j].add(i)
    return adj


def greedy_coloring(adj: Dict[int, Set[int]]) -> Dict[int, int]:
    """Greedy graph coloring.

    Args:
        adj: Adjacency dict.

    Returns:
        Coloring: vertex -> color (0-indexed).

    >>> c = greedy_coloring({0: {1}, 1: {0, 2}, 2: {1}})
    >>> c[0] != c[1] and c[1] != c[2]
    True
    """
    coloring: Dict[int, int] = {}
    for v in sorted(adj.keys()):
        used = {coloring[u] for u in adj[v] if u in coloring}
        color = 0
        while color in used:
            color += 1
        coloring[v] = color
    return coloring


def layered_threshold_rounding(
    edges: List[Set[int]],
    x: Dict[int, float],
    d: int,
) -> Set[int]:
    """Layered threshold rounding algorithm.

    Phase 1: Select vertices with x(v) >= 1/d.
    Phase 2: Build conflict graph on uncovered edges, color it,
             repair each color class.

    Args:
        edges: List of d-element edges.
        x: Fractional transversal.
        d: Uniformity parameter.

    Returns:
        Integer transversal.
    """
    # Phase 1: Threshold
    theta = 1.0 / d
    S1 = threshold_set(x, theta)

    # Phase 2: Identify uncovered edges
    U = uncovered_edges(edges, S1)
    if not U:
        return S1

    # Build and color conflict graph
    adj = conflict_graph(U)
    colors = greedy_coloring(adj)
    num_colors = max(colors.values()) + 1 if colors else 0

    # Repair: pick one vertex per uncovered edge
    repair = set()
    for i, e in enumerate(U):
        # Pick the vertex with highest x value (greedy heuristic)
        best = max(e, key=lambda v: x.get(v, 0))
        repair.add(best)

    return S1 | repair


def solve_fractional_transversal(
    edges: List[Set[int]], vertices: Set[int]
) -> Tuple[float, Dict[int, float]]:
    """Solve the LP relaxation for fractional transversal number τ*.

    min Σ_v x_v
    s.t. Σ_{v ∈ e} x_v ≥ 1 for all e
         x_v ≥ 0 for all v

    Args:
        edges: List of edges.
        vertices: Vertex set.

    Returns:
        (τ*, optimal x assignment)
    """
    from scipy.optimize import linprog

    v_list = sorted(vertices)
    v_idx = {v: i for i, v in enumerate(v_list)}
    n = len(v_list)

    # Objective: minimize sum of x
    c = np.ones(n)

    # Constraints: -Σ_{v ∈ e} x_v ≤ -1 for each edge
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            if v in v_idx:
                A_ub[i, v_idx[v]] = -1.0

    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

    if result.success:
        x_opt = {v_list[i]: result.x[i] for i in range(n)}
        return result.fun, x_opt
    else:
        raise ValueError("LP solve failed")


def solve_integer_transversal(
    edges: List[Set[int]], vertices: Set[int]
) -> Tuple[int, Set[int]]:
    """Solve the ILP for integer transversal number τ.

    Uses brute force for small instances.

    Args:
        edges: List of edges.
        vertices: Vertex set.

    Returns:
        (τ, optimal transversal)
    """
    v_list = sorted(vertices)
    n = len(v_list)

    # Try all subsets from smallest to largest
    for k in range(n + 1):
        for subset in combinations(v_list, k):
            S = set(subset)
            if all(S & e for e in edges):
                return k, S
    return n, set(v_list)


def generate_linear_hypergraph(n: int, d: int, max_edges: int = 50) -> List[Set[int]]:
    """Generate a random d-uniform linear hypergraph (pair codegree ≤ 1).

    Args:
        n: Number of vertices.
        d: Edge size.
        max_edges: Maximum number of edges.

    Returns:
        List of edges forming a linear hypergraph.
    """
    import random
    vertices = list(range(n))
    edges: List[Set[int]] = []
    pair_used: Set[Tuple[int, int]] = set()

    attempts = 0
    while len(edges) < max_edges and attempts < 1000:
        edge = set(random.sample(vertices, d))
        pairs = list(combinations(sorted(edge), 2))
        if all(p not in pair_used for p in pairs):
            edges.append(edge)
            pair_used.update(pairs)
        attempts += 1

    return edges


def edge_count_bound(n: int, d: int, K: int) -> float:
    """Upper bound on edges: K * C(n,2) / C(d,2).

    >>> edge_count_bound(10, 3, 1)
    15.0
    """
    from math import comb
    if d < 2:
        return float('inf')
    return K * comb(n, 2) / comb(d, 2)


if __name__ == "__main__":
    # Example: 3-uniform linear hypergraph
    print("=" * 60)
    print("Layered Threshold Rounding Algorithm Demo")
    print("=" * 60)

    edges = [{0, 1, 2}, {3, 4, 5}, {6, 7, 8}, {0, 3, 6}, {1, 4, 7}]
    vertices = set().union(*edges)
    d = 3

    print(f"\nHypergraph: {len(edges)} edges on {len(vertices)} vertices")
    print(f"Uniformity: d = {d}")
    print(f"Max pair codegree: {max_pair_codegree(edges)}")

    tau_star, x_opt = solve_fractional_transversal(edges, vertices)
    print(f"\nFractional transversal value τ* = {tau_star:.4f}")

    tau, S_opt = solve_integer_transversal(edges, vertices)
    print(f"Integer transversal value τ = {tau}")
    print(f"Integrality gap τ/τ* = {tau / tau_star:.4f}")

    S_rounded = layered_threshold_rounding(edges, x_opt, d)
    print(f"\nLayered rounding: |S| = {len(S_rounded)}")
    print(f"Rounding ratio: {len(S_rounded) / tau_star:.4f}")
    print(f"Edge count bound: {edge_count_bound(len(vertices), d, 1):.1f}")
