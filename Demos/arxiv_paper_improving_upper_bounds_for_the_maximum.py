#!/usr/bin/env python3
"""Numerical demonstrations of upper-bound-driven maximum-clique reductions.

The script uses only the Python standard library.  It constructs small graphs,
computes exact clique numbers and greedy-coloring upper bounds, applies vertex
peeling, and checks preservation by exhaustive enumeration.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Callable, Iterable, Iterator, Sequence

Vertex = int
UpperBound = Callable[[set[Vertex]], int]


@dataclass
class Graph:
    """A finite simple undirected graph represented by adjacency sets."""

    adjacency: dict[Vertex, set[Vertex]]

    @classmethod
    def from_edges(cls, vertices: Iterable[Vertex],
                   edges: Iterable[tuple[Vertex, Vertex]]) -> "Graph":
        adjacency = {v: set() for v in vertices}
        for u, v in edges:
            if u == v:
                raise ValueError("loops are not allowed")
            adjacency[u].add(v)
            adjacency[v].add(u)
        return cls(adjacency)

    @property
    def vertices(self) -> set[Vertex]:
        return set(self.adjacency)

    def is_clique(self, vertices: Iterable[Vertex]) -> bool:
        chosen = list(vertices)
        return all(v in self.adjacency[u] for u, v in combinations(chosen, 2))

    def common_neighbors(self, pattern: Iterable[Vertex],
                         active: set[Vertex] | None = None) -> set[Vertex]:
        pattern_set = set(pattern)
        region = self.vertices if active is None else set(active)
        if not pattern_set:
            return region
        result = set(region)
        for v in pattern_set:
            result &= self.adjacency[v]
        return result

    def cliques(self, active: set[Vertex] | None = None) -> Iterator[set[Vertex]]:
        region = sorted(self.vertices if active is None else active)
        for size in range(len(region) + 1):
            for candidate in combinations(region, size):
                if self.is_clique(candidate):
                    yield set(candidate)

    def clique_number(self, active: set[Vertex] | None = None) -> int:
        return max(map(len, self.cliques(active)), default=0)

    def greedy_coloring_bound(self, active: set[Vertex]) -> int:
        """Return the color count from a degree-ordered greedy coloring."""
        colors: dict[Vertex, int] = {}
        order = sorted(active,
                       key=lambda v: len(self.adjacency[v] & active),
                       reverse=True)
        for v in order:
            forbidden = {colors[w] for w in self.adjacency[v] if w in colors}
            color = 0
            while color in forbidden:
                color += 1
            colors[v] = color
        return 0 if not colors else 1 + max(colors.values())


def extension_score(graph: Graph, active: set[Vertex], pattern: set[Vertex],
                    upper_bound: UpperBound) -> int:
    """Compute |D| + U(S intersect N(D))."""
    completion_region = graph.common_neighbors(pattern, active)
    return len(pattern) + upper_bound(completion_region)


def core_peel(graph: Graph, active: set[Vertex], target: int,
              upper_bound: UpperBound) -> tuple[set[Vertex], list[tuple[Vertex, int]]]:
    """Repeatedly delete a vertex whose extension score is below target."""
    remaining = set(active)
    trace: list[tuple[Vertex, int]] = []
    changed = True
    while changed:
        changed = False
        for v in sorted(remaining):
            score = extension_score(graph, remaining, {v}, upper_bound)
            if score < target:
                trace.append((v, score))
                remaining.remove(v)
                changed = True
                break
    return remaining, trace


def verify_extension_bound(graph: Graph, active: set[Vertex],
                           upper_bound: UpperBound) -> int:
    """Exhaustively count tested triples (C,D,S) satisfying the bound."""
    checks = 0
    for clique in graph.cliques(active):
        vertices = sorted(clique)
        for size in range(len(vertices) + 1):
            for pattern_tuple in combinations(vertices, size):
                pattern = set(pattern_tuple)
                assert len(clique) <= extension_score(
                    graph, active, pattern, upper_bound
                )
                checks += 1
    return checks


def make_demo_graph() -> Graph:
    """Build a graph with a preserved 5-clique and misleading dense regions."""
    main_clique = range(5)
    edges: list[tuple[int, int]] = list(combinations(main_clique, 2))
    # Vertex 5 sees many vertices, but its neighborhood around 6..11 is a cycle.
    edges += [(5, x) for x in range(6, 12)]
    edges += [(x, 6 + ((x - 6 + 1) % 6)) for x in range(6, 12)]
    # Attach a triangle so that ordinary degree and structural tests differ.
    edges += [(12, 13), (13, 14), (12, 14), (5, 12), (5, 13), (5, 14)]
    return Graph.from_edges(range(15), edges)


def main() -> None:
    graph = make_demo_graph()
    active = graph.vertices
    exact: UpperBound = lambda region: graph.clique_number(region)
    coloring: UpperBound = graph.greedy_coloring_bound
    cardinality: UpperBound = len

    print("Upper-bound-driven maximum-clique reductions")
    print("=" * 52)
    print(f"Vertices: {len(active)}")
    print(f"Exact maximum clique size: {graph.clique_number(active)}")

    checks = verify_extension_bound(graph, active, exact)
    print(f"Extension inequalities checked exhaustively: {checks}")

    target = 5
    for name, bound in [("cardinality", cardinality),
                        ("greedy coloring", coloring),
                        ("exact local", exact)]:
        residual, trace = core_peel(graph, active, target, bound)
        before = graph.clique_number(active)
        after = graph.clique_number(residual)
        print(f"\n{name.title()} bound")
        print(f"  deletion trace (vertex, certified score): {trace}")
        print(f"  residual vertices: {sorted(residual)}")
        print(f"  clique number before/after: {before}/{after}")
        assert before == after == 5
        assert set(range(5)) <= residual

    # Pair test: six common neighbors inducing a 6-cycle have clique number 2.
    cycle_edges = [(i, (i + 1) % 6) for i in range(6)]
    pair_edges = cycle_edges + [(6, i) for i in range(6)] + [(7, i) for i in range(6)] + [(6, 7)]
    pair_graph = Graph.from_edges(range(8), pair_edges)
    pair_region = pair_graph.common_neighbors({6, 7}, pair_graph.vertices)
    pair_score = 2 + pair_graph.clique_number(pair_region)
    print("\nEdge-pattern example")
    print(f"  common neighbors of edge (6, 7): {sorted(pair_region)}")
    print(f"  raw common-neighbor count: {len(pair_region)}")
    print(f"  exact extension score: {pair_score}")
    print("  conclusion for target 5: edge excluded" if pair_score < 5 else
          "  conclusion for target 5: test inconclusive")
    assert pair_score == 4


if __name__ == "__main__":
    main()
