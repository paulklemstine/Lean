#!/usr/bin/env python3
"""Numerical demonstrations for structural register allocation.

The script uses only the Python standard library.  It computes exact chromatic
and clique numbers for small graphs, checks greedy coloring from a supplied
perfect elimination ordering, and illustrates clique-based spill lower bounds.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
Coloring = Dict[Vertex, int]


@dataclass(frozen=True)
class GraphStatistics:
    """Exact statistics for a small graph."""

    vertices: int
    edges: int
    maximum_degree: int
    clique_number: int
    chromatic_number: int


def make_graph(vertex_count: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build a finite undirected simple graph with vertices 0,...,vertex_count-1."""
    graph: Graph = {v: set() for v in range(vertex_count)}
    for u, v in edges:
        if not (0 <= u < vertex_count and 0 <= v < vertex_count):
            raise ValueError("edge endpoint outside the vertex range")
        if u == v:
            raise ValueError("loops are not allowed")
        graph[u].add(v)
        graph[v].add(u)
    return graph


def path_graph(vertex_count: int) -> Graph:
    return make_graph(vertex_count, ((v, v + 1) for v in range(vertex_count - 1)))


def cycle_graph(vertex_count: int) -> Graph:
    if vertex_count < 3:
        raise ValueError("a cycle needs at least three vertices")
    return make_graph(vertex_count, ((v, (v + 1) % vertex_count) for v in range(vertex_count)))


def complete_graph(vertex_count: int) -> Graph:
    return make_graph(vertex_count, combinations(range(vertex_count), 2))


def star_graph(leaves: int) -> Graph:
    return make_graph(leaves + 1, ((0, leaf) for leaf in range(1, leaves + 1)))


def is_proper_coloring(graph: Graph, coloring: Coloring) -> bool:
    return all(coloring.get(u) != coloring.get(v) for u in graph for v in graph[u])


def find_k_coloring(graph: Graph, k: int) -> Optional[Coloring]:
    """Find a proper k-coloring by exact backtracking, or return None."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    order = sorted(graph, key=lambda v: (-len(graph[v]), v))
    coloring: Coloring = {}

    def search(index: int) -> bool:
        if index == len(order):
            return True
        vertex = order[index]
        forbidden = {coloring[n] for n in graph[vertex] if n in coloring}
        for color in range(k):
            if color not in forbidden:
                coloring[vertex] = color
                if search(index + 1):
                    return True
                del coloring[vertex]
        return False

    return dict(coloring) if search(0) else None


def chromatic_number(graph: Graph) -> Tuple[int, Coloring]:
    """Compute the exact chromatic number of a small graph."""
    if not graph:
        return 0, {}
    for k in range(1, len(graph) + 1):
        coloring = find_k_coloring(graph, k)
        if coloring is not None:
            return k, coloring
    raise RuntimeError("finite graph unexpectedly had no coloring")


def is_clique(graph: Graph, vertices: Sequence[Vertex]) -> bool:
    return all(v in graph[u] for u, v in combinations(vertices, 2))


def maximum_clique(graph: Graph) -> Tuple[int, Tuple[Vertex, ...]]:
    """Compute a maximum clique by exhaustive subset search."""
    vertices = tuple(graph)
    for size in range(len(vertices), -1, -1):
        for subset in combinations(vertices, size):
            if is_clique(graph, subset):
                return size, subset
    return 0, ()


def graph_statistics(graph: Graph) -> GraphStatistics:
    clique, _ = maximum_clique(graph)
    chromatic, _ = chromatic_number(graph)
    return GraphStatistics(
        vertices=len(graph),
        edges=sum(len(neighbors) for neighbors in graph.values()) // 2,
        maximum_degree=max((len(neighbors) for neighbors in graph.values()), default=0),
        clique_number=clique,
        chromatic_number=chromatic,
    )


def is_perfect_elimination_order(graph: Graph, order: Sequence[Vertex]) -> bool:
    """Check whether order lists every vertex once and is a PEO."""
    if len(order) != len(graph) or set(order) != set(graph):
        return False
    position = {vertex: index for index, vertex in enumerate(order)}
    for vertex in order:
        later = [n for n in graph[vertex] if position[n] > position[vertex]]
        if not is_clique(graph, later):
            return False
    return True


def color_from_elimination_order(graph: Graph, order: Sequence[Vertex], k: int) -> Coloring:
    """Greedily color in reverse PEO order with colors 0,...,k-1."""
    if not is_perfect_elimination_order(graph, order):
        raise ValueError("the supplied order is not a perfect elimination ordering")
    coloring: Coloring = {}
    for vertex in reversed(order):
        forbidden = {coloring[n] for n in graph[vertex] if n in coloring}
        available = next((color for color in range(k) if color not in forbidden), None)
        if available is None:
            raise ValueError(f"{k} colors are insufficient for this elimination step")
        coloring[vertex] = available
    assert is_proper_coloring(graph, coloring)
    return coloring


def clique_spill_lower_bound(clique_size: int, registers: int) -> int:
    """Return max(0, clique_size-registers), the forced spills in that clique."""
    if clique_size < 0 or registers < 0:
        raise ValueError("sizes must be nonnegative")
    return max(0, clique_size - registers)


def print_statistics(name: str, graph: Graph) -> None:
    stats = graph_statistics(graph)
    print(
        f"{name:20} | V={stats.vertices:2d} E={stats.edges:2d} "
        f"Delta={stats.maximum_degree:2d} omega={stats.clique_number:2d} "
        f"chi={stats.chromatic_number:2d} Delta+1={stats.maximum_degree + 1:2d}"
    )


def run_demo() -> None:
    """Run all numerical examples and assert the advertised relationships."""
    print("Exact graph statistics")
    print("-" * 86)
    examples = {
        "three-vertex path": path_graph(3),
        "eight-vertex path": path_graph(8),
        "star with 8 leaves": star_graph(8),
        "complete graph K5": complete_graph(5),
        "odd cycle C5": cycle_graph(5),
    }
    for name, graph in examples.items():
        print_statistics(name, graph)

    p3 = examples["three-vertex path"]
    p3_stats = graph_statistics(p3)
    assert p3_stats.chromatic_number == 2
    assert p3_stats.maximum_degree + 1 == 3

    star = examples["star with 8 leaves"]
    star_stats = graph_statistics(star)
    assert star_stats.chromatic_number == star_stats.clique_number == 2
    assert star_stats.maximum_degree + 1 == 9

    odd_cycle = examples["odd cycle C5"]
    odd_stats = graph_statistics(odd_cycle)
    assert odd_stats.clique_number == 2 and odd_stats.chromatic_number == 3

    print("\nElimination-order allocation")
    print("-" * 86)
    # Removing path endpoints inward is a perfect elimination ordering.
    path = examples["eight-vertex path"]
    order = tuple(range(8))
    coloring = color_from_elimination_order(path, order, 2)
    print(f"PEO valid: {is_perfect_elimination_order(path, order)}")
    print(f"Two-register assignment: {dict(sorted(coloring.items()))}")
    assert is_proper_coloring(path, coloring)

    print("\nClique spill certificates")
    print("-" * 86)
    for clique_size, registers in [(7, 4), (6, 4), (4, 4), (3, 2)]:
        bound = clique_spill_lower_bound(clique_size, registers)
        print(
            f"clique size {clique_size}, registers {registers}: "
            f"at least {bound} clique member(s) must spill"
        )
    assert clique_spill_lower_bound(7, 4) == 3

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    run_demo()
