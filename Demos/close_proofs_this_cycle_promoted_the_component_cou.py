#!/usr/bin/env python3
"""Numerical demonstrations of component antitonicity and graph toughness.

The program uses only the Python standard library.  Run it directly to print
three reproducible experiments and exact deletion certificates.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import FrozenSet, Iterable, Iterator, Sequence

Vertex = int
Edge = tuple[Vertex, Vertex]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph on vertices 0, ..., n-1."""

    n: int
    edges: FrozenSet[Edge]

    @staticmethod
    def create(n: int, edges: Iterable[Edge]) -> "Graph":
        if n < 0:
            raise ValueError("The number of vertices must be nonnegative")
        normalized: set[Edge] = set()
        for a, b in edges:
            if not (0 <= a < n and 0 <= b < n):
                raise ValueError(f"Edge {(a, b)} has an endpoint outside the graph")
            if a == b:
                raise ValueError("Loops are not allowed")
            normalized.add((min(a, b), max(a, b)))
        return Graph(n, frozenset(normalized))

    def with_edges(self, extra: Iterable[Edge]) -> "Graph":
        return Graph.create(self.n, tuple(self.edges) + tuple(extra))

    def is_spanning_subgraph_of(self, other: "Graph") -> bool:
        return self.n == other.n and self.edges <= other.edges

    def neighbors(self, vertex: Vertex) -> Iterator[Vertex]:
        for a, b in self.edges:
            if a == vertex:
                yield b
            elif b == vertex:
                yield a


def subsets(n: int) -> Iterator[FrozenSet[Vertex]]:
    """Yield every subset of {0, ..., n-1}."""
    vertices = range(n)
    for size in range(n + 1):
        for choice in combinations(vertices, size):
            yield frozenset(choice)


def component_count(graph: Graph, deleted: FrozenSet[Vertex]) -> int:
    """Count components after deleting the specified vertices."""
    active = set(range(graph.n)) - set(deleted)
    unseen = set(active)
    count = 0
    while unseen:
        count += 1
        start = unseen.pop()
        stack = [start]
        while stack:
            vertex = stack.pop()
            for neighbor in graph.neighbors(vertex):
                if neighbor in unseen:
                    unseen.remove(neighbor)
                    stack.append(neighbor)
    return count


def toughness_violation(graph: Graph) -> tuple[FrozenSet[Vertex], int] | None:
    """Return a violating set S and c(G-S), or None when G is 1-tough."""
    for deleted in subsets(graph.n):
        count = component_count(graph, deleted)
        if count > 1 and count > len(deleted):
            return deleted, count
    return None


def is_one_tough(graph: Graph) -> bool:
    return toughness_violation(graph) is None


def verify_component_antitonicity(sparse: Graph, dense: Graph) -> bool:
    """Check c_dense(S) <= c_sparse(S) for every deletion set S."""
    if not sparse.is_spanning_subgraph_of(dense):
        raise ValueError("The first graph must be a spanning subgraph of the second")
    return all(
        component_count(dense, deleted) <= component_count(sparse, deleted)
        for deleted in subsets(sparse.n)
    )


def path_graph(n: int) -> Graph:
    return Graph.create(n, ((i, i + 1) for i in range(n - 1)))


def cycle_graph(n: int) -> Graph:
    if n < 3:
        raise ValueError("A simple cycle requires at least three vertices")
    return Graph.create(n, list((i, i + 1) for i in range(n - 1)) + [(n - 1, 0)])


def star_graph(leaves: int) -> Graph:
    return Graph.create(leaves + 1, ((0, i) for i in range(1, leaves + 1)))


def format_set(values: FrozenSet[int]) -> str:
    return "{" + ", ".join(map(str, sorted(values))) + "}"


def demo_fixed_deletion() -> None:
    """Show a component count falling along an edge-augmentation chain."""
    deleted = frozenset({1, 4})
    graphs: Sequence[Graph] = (
        path_graph(6),
        path_graph(6).with_edges([(0, 2)]),
        path_graph(6).with_edges([(0, 2), (3, 5)]),
    )
    counts = [component_count(graph, deleted) for graph in graphs]
    print("Experiment 1 — fixed deletion under edge addition")
    print(f"  deleted vertices: {format_set(deleted)}")
    print(f"  component counts: {counts} (nonincreasing)\n")


def demo_toughness_certificates() -> None:
    """Compare an exact positive cycle result with star and path witnesses."""
    examples = {
        "six-cycle": cycle_graph(6),
        "five-leaf star": star_graph(5),
        "six-vertex path": path_graph(6),
    }
    print("Experiment 2 — exact 1-toughness decisions")
    for name, graph in examples.items():
        violation = toughness_violation(graph)
        if violation is None:
            print(f"  {name}: 1-tough")
        else:
            deleted, count = violation
            print(
                f"  {name}: not 1-tough; deleting {format_set(deleted)} "
                f"leaves {count} components"
            )
    print()


def demo_upward_and_downward_transport() -> None:
    """Check both propagation directions on concrete graph pairs."""
    cycle = cycle_graph(6)
    reinforced = cycle.with_edges([(0, 3), (1, 4), (2, 5)])
    star = star_graph(5)
    sparse_star = Graph.create(6, [(0, 1), (0, 2), (0, 3)])
    witness = frozenset({0})
    print("Experiment 3 — order transport")
    print(
        "  cycle <= reinforced graph; all component inequalities:",
        verify_component_antitonicity(cycle, reinforced),
    )
    print(f"  cycle tough: {is_one_tough(cycle)}")
    print(f"  reinforced graph tough: {is_one_tough(reinforced)}")
    print(
        "  star witness descends to a spanning subgraph:",
        component_count(star, witness),
        "<=",
        component_count(sparse_star, witness),
    )


def main() -> None:
    demo_fixed_deletion()
    demo_toughness_certificates()
    demo_upward_and_downward_transport()


if __name__ == "__main__":
    main()
