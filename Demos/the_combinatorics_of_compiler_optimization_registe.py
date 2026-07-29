#!/usr/bin/env python3
"""Numerical demonstrations for degree-based spilling on K3 disjoint K1,4."""

from __future__ import annotations

from itertools import combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
Coloring = Dict[Vertex, int]


def build_counterexample() -> Graph:
    """Return the graph K3 disjoint K1,4 on vertices 0,...,7."""
    graph: Graph = {v: set() for v in range(8)}
    edges = [(0, 1), (0, 2), (1, 2), (3, 4), (3, 5), (3, 6), (3, 7)]
    for u, v in edges:
        graph[u].add(v)
        graph[v].add(u)
    return graph


def induced_without(graph: Graph, removed: Iterable[Vertex]) -> Graph:
    """Return the induced graph obtained by deleting the supplied vertices."""
    blocked = set(removed)
    return {
        v: {u for u in neighbors if u not in blocked}
        for v, neighbors in graph.items()
        if v not in blocked
    }


def find_k_coloring(graph: Graph, k: int) -> Optional[Coloring]:
    """Find a proper k-coloring by degree-ordered backtracking, if one exists."""
    if k < 1:
        return None
    order = sorted(graph, key=lambda v: (-len(graph[v]), v))
    colors: Coloring = {}

    def search(index: int) -> bool:
        if index == len(order):
            return True
        vertex = order[index]
        forbidden = {colors[u] for u in graph[vertex] if u in colors}
        for color in range(k):
            if color not in forbidden:
                colors[vertex] = color
                if search(index + 1):
                    return True
                del colors[vertex]
        return False

    return dict(colors) if search(0) else None


def chromatic_number(graph: Graph) -> Tuple[int, Coloring]:
    """Compute the exact chromatic number and one optimal coloring."""
    if not graph:
        return 0, {}
    for k in range(1, len(graph) + 1):
        coloring = find_k_coloring(graph, k)
        if coloring is not None:
            return k, coloring
    raise RuntimeError("Finite graph should always be colorable")


def clique_number(graph: Graph) -> Tuple[int, Tuple[Vertex, ...]]:
    """Compute the exact clique number by exhaustive subset search."""
    vertices = sorted(graph)
    for size in range(len(vertices), 0, -1):
        for candidate in combinations(vertices, size):
            if all(v in graph[u] for u, v in combinations(candidate, 2)):
                return size, candidate
    return 0, ()


def is_perfect_elimination_order(graph: Graph, order: Sequence[Vertex]) -> bool:
    """Check that each vertex's earlier neighbors form a clique."""
    position = {v: i for i, v in enumerate(order)}
    if set(position) != set(graph) or len(position) != len(order):
        return False
    for vertex in order:
        earlier = [u for u in graph[vertex] if position[u] < position[vertex]]
        if any(v not in graph[u] for u, v in combinations(earlier, 2)):
            return False
    return True


def spill_table(graph: Graph, k: int) -> List[Tuple[Vertex, int, bool, Optional[Coloring]]]:
    """Evaluate every one-vertex spill for a fixed register budget."""
    rows: List[Tuple[Vertex, int, bool, Optional[Coloring]]] = []
    for vertex in sorted(graph):
        coloring = find_k_coloring(induced_without(graph, {vertex}), k)
        rows.append((vertex, len(graph[vertex]), coloring is not None, coloring))
    return rows


def validate_coloring(graph: Graph, coloring: Coloring) -> bool:
    """Check a proposed coloring against every edge."""
    return set(coloring) == set(graph) and all(
        coloring[u] != coloring[v]
        for u in graph
        for v in graph[u]
        if u < v
    )


def main() -> None:
    graph = build_counterexample()
    degrees = {v: len(graph[v]) for v in sorted(graph)}
    delta = max(degrees.values())
    omega, clique = clique_number(graph)
    chi, coloring = chromatic_number(graph)

    print("Counterexample graph: K3 disjoint K1,4")
    print(f"Degrees: {degrees}")
    print(f"Maximum degree Delta = {delta}; Delta + 1 = {delta + 1}")
    print(f"Clique number omega = {omega}, witnessed by {clique}")
    print(f"Chromatic number chi = {chi}; coloring = {coloring}")
    print(f"Coloring valid: {validate_coloring(graph, coloring)}")
    print(f"Proposed max(Delta + 1, omega) = {max(delta + 1, omega)}")
    print(f"Natural order is perfect elimination: "
          f"{is_perfect_elimination_order(graph, list(range(8)))}")

    print("\nOne-vertex spills with a two-register budget:")
    print("vertex  degree  succeeds  surviving coloring")
    for vertex, degree, succeeds, witness in spill_table(graph, 2):
        print(f"{vertex:>6}  {degree:>6}  {str(succeeds):>8}  {witness}")

    center_result = find_k_coloring(induced_without(graph, {3}), 2)
    triangle_result = find_k_coloring(induced_without(graph, {0}), 2)
    assert degrees[3] == delta == 4
    assert degrees[0] == 2 < degrees[3]
    assert chi == omega == 3
    assert delta + 1 == 5
    assert center_result is None
    assert triangle_result is not None
    print("\nConclusion: spilling degree-4 vertex 3 fails, while spilling degree-2 vertex 0 succeeds.")


if __name__ == "__main__":
    main()
