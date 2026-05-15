#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Chronological Ordering

Implements the core algorithms from the research paper:
1. Floyd-Warshall all-pairs shortest paths
2. Chronological order extraction
3. Zero-weight cycle detection via Tarjan's SCC
4. Lawvere metric validation
5. Hasse diagram computation
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass

INF = float('inf')


@dataclass
class ChronologicalOrderResult:
    """Result of computing a chronological order on a weighted digraph."""
    distance_matrix: np.ndarray
    relation: Set[Tuple[int, int]]
    is_partial_order: bool
    is_reflexive: bool
    is_transitive: bool
    is_antisymmetric: bool
    has_zero_weight_cycle: bool
    zero_cycle_witnesses: List[Tuple[int, int]]  # pairs violating antisymmetry
    covers: Set[Tuple[int, int]]  # Hasse diagram edges
    n_vertices: int
    labels: List[str]


def floyd_warshall(n: int, edges: List[Tuple[int, int, float]]) -> np.ndarray:
    """All-pairs shortest paths via Floyd-Warshall.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        n: Number of vertices.
        edges: List of (source, target, weight) triples.

    Returns:
        Distance matrix d where d[i][j] = shortest path from i to j.
    """
    d = np.full((n, n), INF)
    for i in range(n):
        d[i, i] = 0.0
    for u, v, w in edges:
        if w < d[u, v]:
            d[u, v] = w
    for k in range(n):
        for i in range(n):
            if d[i, k] == INF:
                continue
            for j in range(n):
                new_dist = d[i, k] + d[k, j]
                if new_dist < d[i, j]:
                    d[i, j] = new_dist
    return d


def dijkstra(n: int, adj: Dict[int, List[Tuple[int, float]]],
             source: int) -> np.ndarray:
    """Single-source shortest paths via Dijkstra's algorithm.

    Time complexity: O((n + m) log n) with a binary heap.

    Args:
        n: Number of vertices.
        adj: Adjacency list {u: [(v, w), ...]}.
        source: Source vertex.

    Returns:
        Array of distances from source.
    """
    import heapq
    dist = np.full(n, INF)
    dist[source] = 0.0
    pq = [(0.0, source)]
    visited = set()
    while pq:
        d_u, u = heapq.heappop(pq)
        if u in visited:
            continue
        visited.add(u)
        for v, w in adj.get(u, []):
            new_dist = d_u + w
            if new_dist < dist[v]:
                dist[v] = new_dist
                heapq.heappush(pq, (new_dist, v))
    return dist


def tarjan_scc(n: int, adj: Dict[int, List[int]]) -> List[List[int]]:
    """Tarjan's algorithm for strongly connected components.

    Time complexity: O(n + m)

    Args:
        n: Number of vertices.
        adj: Adjacency list (unweighted).

    Returns:
        List of SCCs, each a list of vertex indices.
    """
    index_counter = [0]
    stack = []
    on_stack = [False] * n
    index = [-1] * n
    lowlink = [-1] * n
    result = []

    def strongconnect(v: int):
        index[v] = index_counter[0]
        lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack[v] = True

        for w in adj.get(v, []):
            if index[w] == -1:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif on_stack[w]:
                lowlink[v] = min(lowlink[v], index[w])

        if lowlink[v] == index[v]:
            component = []
            while True:
                w = stack.pop()
                on_stack[w] = False
                component.append(w)
                if w == v:
                    break
            result.append(component)

    for v in range(n):
        if index[v] == -1:
            strongconnect(v)

    return result


def detect_zero_weight_cycles(
    n: int, edges: List[Tuple[int, int, float]], tol: float = 1e-12
) -> Tuple[bool, List[List[int]]]:
    """Detect zero-weight directed cycles using Tarjan's SCC on zero-weight subgraph.

    Time complexity: O(n + m)

    Args:
        n: Number of vertices.
        edges: Weighted directed edges.
        tol: Tolerance for zero weight comparison.

    Returns:
        (has_cycle, nontrivial_sccs): Whether a zero-weight cycle exists,
        and the list of nontrivial SCCs in the zero-weight subgraph.
    """
    # Build zero-weight subgraph
    zero_adj: Dict[int, List[int]] = {}
    for u, v, w in edges:
        if abs(w) <= tol:
            zero_adj.setdefault(u, []).append(v)

    sccs = tarjan_scc(n, zero_adj)
    nontrivial = [scc for scc in sccs if len(scc) > 1]
    return len(nontrivial) > 0, nontrivial


def validate_lawvere_metric(d: np.ndarray, tol: float = 1e-10) -> dict:
    """Check if a distance matrix satisfies the Lawvere metric axioms.

    Args:
        d: n×n distance matrix.
        tol: Numerical tolerance.

    Returns:
        Dict with validation results.
    """
    n = d.shape[0]
    results = {}

    # L1: d(v,v) = 0
    diag_zero = all(abs(d[i, i]) < tol for i in range(n))
    results["reflexivity"] = diag_zero

    # L2: d(u,v) ≥ 0
    nonneg = np.all(d >= -tol)
    results["nonnegativity"] = bool(nonneg)

    # L3: Triangle inequality
    triangle_ok = True
    worst_violation = 0.0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i, k] != INF and d[i, j] != INF and d[j, k] != INF:
                    violation = d[i, k] - d[i, j] - d[j, k]
                    if violation > tol:
                        triangle_ok = False
                        worst_violation = max(worst_violation, violation)
    results["triangle_inequality"] = triangle_ok
    results["worst_triangle_violation"] = worst_violation

    # L4: Separation
    separated = True
    for i in range(n):
        for j in range(n):
            if i != j and abs(d[i, j]) < tol and abs(d[j, i]) < tol:
                separated = False
                break
    results["separation"] = separated

    results["is_lawvere"] = diag_zero and bool(nonneg) and triangle_ok
    results["is_separated_lawvere"] = results["is_lawvere"] and separated

    return results


def compute_chronological_order(
    n: int,
    edges: List[Tuple[int, int, float]],
    labels: Optional[List[str]] = None,
    tol: float = 1e-12,
) -> ChronologicalOrderResult:
    """Compute the chronological order from a weighted digraph.

    This is the main algorithm: it computes tropical shortest-path distances
    and extracts the partial order u ≼ v ⟺ d(u,v) = 0.

    Time complexity: O(n³) for Floyd-Warshall + O(n²) for extraction.

    Args:
        n: Number of vertices.
        edges: List of (source, target, weight) directed edges.
        labels: Optional vertex labels.
        tol: Numerical tolerance for zero comparison.

    Returns:
        ChronologicalOrderResult with all computed properties.
    """
    if labels is None:
        labels = [str(i) for i in range(n)]

    # Step 1: Compute all-pairs shortest paths
    d = floyd_warshall(n, edges)

    # Step 2: Extract chronological relation
    relation = set()
    for i in range(n):
        for j in range(n):
            if d[i, j] != INF and abs(d[i, j]) < tol:
                relation.add((i, j))

    # Step 3: Check properties
    is_reflexive = all((i, i) in relation for i in range(n))

    is_transitive = True
    for i in range(n):
        for j in range(n):
            if (i, j) not in relation:
                continue
            for k in range(n):
                if (j, k) in relation and (i, k) not in relation:
                    is_transitive = False

    witnesses = []
    is_antisymmetric = True
    for i in range(n):
        for j in range(i + 1, n):
            if (i, j) in relation and (j, i) in relation:
                is_antisymmetric = False
                witnesses.append((i, j))

    # Step 4: Compute covers (Hasse diagram)
    covers = set()
    for i, j in relation:
        if i == j:
            continue
        is_cover = True
        for k in range(n):
            if k != i and k != j and (i, k) in relation and (k, j) in relation:
                is_cover = False
                break
        if is_cover:
            covers.add((i, j))

    has_cycle, _ = detect_zero_weight_cycles(n, edges, tol)

    return ChronologicalOrderResult(
        distance_matrix=d,
        relation=relation,
        is_partial_order=is_reflexive and is_transitive and is_antisymmetric,
        is_reflexive=is_reflexive,
        is_transitive=is_transitive,
        is_antisymmetric=is_antisymmetric,
        has_zero_weight_cycle=has_cycle,
        zero_cycle_witnesses=witnesses,
        covers=covers,
        n_vertices=n,
        labels=labels,
    )


def compute_quotient_order(
    n: int,
    edges: List[Tuple[int, int, float]],
    labels: Optional[List[str]] = None,
    tol: float = 1e-12,
) -> Tuple[ChronologicalOrderResult, Dict[int, int]]:
    """Compute the quotient partial order by collapsing zero-distance equivalence classes.

    When zero-weight cycles exist, quotient by the equivalence relation
    u ~ v ⟺ d(u,v) = 0 ∧ d(v,u) = 0 to obtain a partial order.

    Args:
        n, edges, labels, tol: As in compute_chronological_order.

    Returns:
        (result, vertex_map): The chronological order on the quotient,
        and a mapping from original vertices to quotient vertices.
    """
    if labels is None:
        labels = [str(i) for i in range(n)]

    d = floyd_warshall(n, edges)

    # Find equivalence classes
    visited = [False] * n
    classes: List[List[int]] = []
    vertex_map: Dict[int, int] = {}

    for i in range(n):
        if visited[i]:
            continue
        cls = [i]
        visited[i] = True
        for j in range(i + 1, n):
            if not visited[j]:
                if (d[i, j] != INF and abs(d[i, j]) < tol and
                        d[j, i] != INF and abs(d[j, i]) < tol):
                    cls.append(j)
                    visited[j] = True
        cls_idx = len(classes)
        for v in cls:
            vertex_map[v] = cls_idx
        classes.append(cls)

    # Build quotient graph
    n_q = len(classes)
    q_labels = ["{" + ",".join(labels[v] for v in cls) + "}" for cls in classes]
    q_edges = set()
    for u, v, w in edges:
        qu, qv = vertex_map[u], vertex_map[v]
        q_edges.add((qu, qv, w))

    result = compute_chronological_order(n_q, list(q_edges), q_labels, tol)
    return result, vertex_map


# ─────────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demo: Chronological Order Computation")
    print("=" * 60)

    # Example: network with zero-weight edges
    edges = [
        (0, 1, 0), (1, 2, 3), (0, 2, 5),
        (2, 3, 0), (3, 4, 1), (0, 4, 2),
    ]
    labels = ["A", "B", "C", "D", "E"]
    result = compute_chronological_order(5, edges, labels)

    print(f"\nGraph: {len(edges)} edges on {result.n_vertices} vertices")
    print(f"Partial order? {result.is_partial_order}")
    print(f"  Reflexive: {result.is_reflexive}")
    print(f"  Transitive: {result.is_transitive}")
    print(f"  Antisymmetric: {result.is_antisymmetric}")
    print(f"Zero-weight cycle? {result.has_zero_weight_cycle}")
    print(f"\nCovers (Hasse diagram):")
    for i, j in sorted(result.covers):
        print(f"  {labels[i]} → {labels[j]}")

    # Lawvere metric validation
    print(f"\nLawvere metric validation:")
    validation = validate_lawvere_metric(result.distance_matrix)
    for k, v in validation.items():
        print(f"  {k}: {v}")

    # Quotient example
    print("\n" + "=" * 60)
    print("Quotient Order Demo (graph with zero-weight cycle)")
    print("=" * 60)

    edges2 = [
        (0, 1, 0), (1, 0, 0),  # zero-weight cycle
        (0, 2, 3), (2, 3, 0),
    ]
    labels2 = ["P", "Q", "R", "S"]
    q_result, vmap = compute_quotient_order(4, edges2, labels2)

    print(f"\nOriginal vertices mapped to quotient classes:")
    for v, qv in sorted(vmap.items()):
        print(f"  {labels2[v]} → class {qv} ({q_result.labels[qv]})")
    print(f"\nQuotient is partial order? {q_result.is_partial_order}")
    print(f"Quotient covers:")
    for i, j in sorted(q_result.covers):
        print(f"  {q_result.labels[i]} → {q_result.labels[j]}")
