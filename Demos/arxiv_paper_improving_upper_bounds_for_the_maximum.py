#!/usr/bin/env python3
"""Numerical demonstrations of upper-bound seed reductions for maximum clique.

The program uses only the Python standard library.  Graphs are represented by
sets of undirected edges, greedy coloring supplies valid clique upper bounds,
and exhaustive enumeration is used only on small examples to audit results.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Callable, Iterable, Sequence

Vertex = int
Seed = frozenset[Vertex]


@dataclass
class Graph:
    """A finite simple undirected graph with adjacency sets."""

    adjacency: dict[Vertex, set[Vertex]]

    @classmethod
    def from_edges(cls, vertices: Iterable[Vertex], edges: Iterable[tuple[Vertex, Vertex]]) -> "Graph":
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

    def common_neighbors(self, seed: Iterable[Vertex], current: Iterable[Vertex] | None = None) -> set[Vertex]:
        seed_set = set(seed)
        candidates = self.vertices if current is None else set(current)
        return {x for x in candidates if all(d in self.adjacency[x] for d in seed_set)}

    def greedy_coloring_bound(self, subset: Iterable[Vertex]) -> int:
        """Return the number of colors in a proper greedy coloring."""
        chosen = set(subset)
        order = sorted(chosen, key=lambda v: (-len(self.adjacency[v] & chosen), v))
        colors: dict[Vertex, int] = {}
        for v in order:
            forbidden = {colors[w] for w in self.adjacency[v] if w in colors}
            color = 0
            while color in forbidden:
                color += 1
            colors[v] = color
        return 0 if not colors else 1 + max(colors.values())

    def clique_number(self, subset: Iterable[Vertex] | None = None) -> int:
        """Compute the exact clique number by enumeration; suitable for small demos."""
        vertices = sorted(self.vertices if subset is None else set(subset))
        for size in range(len(vertices), -1, -1):
            if any(self.is_clique(c) for c in combinations(vertices, size)):
                return size
        return 0


def seed_certificate(graph: Graph, seed: Seed, incumbent: int, current: set[Vertex] | None = None) -> tuple[bool, int, set[Vertex]]:
    """Test |D| + U(N_S(D)) <= k using a greedy-coloring upper bound."""
    state = graph.vertices if current is None else current
    local = graph.common_neighbors(seed, state)
    bound = graph.greedy_coloring_bound(local)
    return len(seed) + bound <= incumbent, bound, local


def peel_vertices(graph: Graph, incumbent: int) -> tuple[set[Vertex], list[tuple[Vertex, int, tuple[Vertex, ...]]]]:
    """Repeatedly remove the first vertex passing the dynamic singleton test."""
    current = graph.vertices
    trace: list[tuple[Vertex, int, tuple[Vertex, ...]]] = []
    changed = True
    while changed:
        changed = False
        for v in sorted(current):
            passed, bound, local = seed_certificate(graph, frozenset({v}), incumbent, current)
            if passed:
                trace.append((v, bound, tuple(sorted(local))))
                current.remove(v)
                changed = True
                break
    return current, trace


def improving_cliques(graph: Graph, incumbent: int, subset: set[Vertex] | None = None) -> list[frozenset[Vertex]]:
    """Enumerate all cliques larger than the incumbent in a small graph."""
    vertices = sorted(graph.vertices if subset is None else subset)
    answer: list[frozenset[Vertex]] = []
    for size in range(incumbent + 1, len(vertices) + 1):
        answer.extend(frozenset(c) for c in combinations(vertices, size) if graph.is_clique(c))
    return answer


def vertex_demo() -> None:
    """Show a vertex certified by coloring although degree counting fails."""
    neighbors = range(1, 7)
    edges = [(0, x) for x in neighbors]
    edges += [(1, 2), (3, 4), (5, 6)]  # a matching: coloring bound two
    graph = Graph.from_edges(range(7), edges)
    passed, bound, local = seed_certificate(graph, frozenset({0}), incumbent=3)
    print("Vertex reduction beyond degree counting")
    print(f"  neighborhood={sorted(local)}, degree bound={len(local)}, coloring bound={bound}")
    print(f"  certificate: 1 + {bound} <= 3 is {passed}")


def edge_demo() -> None:
    """Show an edge certified by a bipartite common neighborhood."""
    common = range(2, 7)
    edges = [(0, 1)] + [(x, w) for x in (0, 1) for w in common]
    edges += [(2, 5), (2, 6), (3, 5), (4, 6)]  # bipartite local graph
    graph = Graph.from_edges(range(7), edges)
    passed, bound, local = seed_certificate(graph, frozenset({0, 1}), incumbent=4)
    print("\nEdge reduction from common-neighborhood structure")
    print(f"  common neighborhood={sorted(local)}, count={len(local)}, coloring bound={bound}")
    print(f"  certificate: 2 + {bound} <= 4 is {passed}")


def peeling_demo() -> None:
    """Run dynamic peeling and audit preservation of all improving cliques."""
    vertices = range(9)
    edges = list(combinations((0, 1, 2, 3), 2))  # protected K4
    edges += [(4, 0), (4, 1), (5, 1), (5, 2), (6, 2), (6, 3), (7, 0), (8, 3), (7, 8)]
    graph = Graph.from_edges(vertices, edges)
    incumbent = 3
    before = improving_cliques(graph, incumbent)
    remaining, trace = peel_vertices(graph, incumbent)
    after = improving_cliques(graph, incumbent, remaining)
    print("\nDynamic peeling audit")
    for step, (v, bound, local) in enumerate(trace, 1):
        print(f"  step {step}: remove {v}; local={list(local)}; 1 + {bound} <= {incumbent}")
    print(f"  remaining vertices={sorted(remaining)}")
    print(f"  improving cliques before={list(map(sorted, before))}")
    print(f"  improving cliques after ={list(map(sorted, after))}")
    assert set(before) == set(after), "an improving clique was lost"
    print("  audit passed: every clique larger than the incumbent survived")


def main() -> None:
    vertex_demo()
    edge_demo()
    peeling_demo()


if __name__ == "__main__":
    main()
