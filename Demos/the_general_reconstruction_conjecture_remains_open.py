#!/usr/bin/env python3
"""Numerical demonstrations for vertex-deleted graph reconstruction identities.

The program uses only the Python standard library.  Graphs are finite, simple,
and labeled by consecutive integers.  It verifies the edge-sum identity,
Kelly's induced-pattern identity, and compatibility of deletion with graph
complementation on a representative six-vertex graph.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, permutations
from typing import Iterable, Iterator

Edge = tuple[int, int]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph on vertices 0, ..., n-1."""

    n: int
    edges: frozenset[Edge]

    def __post_init__(self) -> None:
        if self.n < 0:
            raise ValueError("The number of vertices must be nonnegative")
        normalized: set[Edge] = set()
        for a, b in self.edges:
            if a == b or not (0 <= a < self.n and 0 <= b < self.n):
                raise ValueError(f"Invalid simple-graph edge {(a, b)}")
            normalized.add((min(a, b), max(a, b)))
        object.__setattr__(self, "edges", frozenset(normalized))

    @classmethod
    def from_edges(cls, n: int, edges: Iterable[Edge]) -> "Graph":
        return cls(n, frozenset(edges))

    def has_edge(self, a: int, b: int) -> bool:
        return (min(a, b), max(a, b)) in self.edges if a != b else False

    def induced(self, vertices: Iterable[int]) -> "Graph":
        """Return the induced graph, canonically relabeled from zero."""
        chosen = sorted(set(vertices))
        relabel = {old: new for new, old in enumerate(chosen)}
        kept = {
            (relabel[a], relabel[b])
            for a, b in self.edges
            if a in relabel and b in relabel
        }
        return Graph.from_edges(len(chosen), kept)

    def delete_vertex(self, vertex: int) -> "Graph":
        if not 0 <= vertex < self.n:
            raise IndexError(vertex)
        return self.induced(v for v in range(self.n) if v != vertex)

    def deck(self) -> list["Graph"]:
        return [self.delete_vertex(v) for v in range(self.n)]

    def complement(self) -> "Graph":
        return Graph.from_edges(
            self.n,
            ((a, b) for a, b in combinations(range(self.n), 2)
             if not self.has_edge(a, b)),
        )


def is_isomorphic(first: Graph, second: Graph) -> bool:
    """Brute-force graph isomorphism, intended for small demonstrations."""
    if first.n != second.n or len(first.edges) != len(second.edges):
        return False
    for image in permutations(range(first.n)):
        if all(
            first.has_edge(a, b) == second.has_edge(image[a], image[b])
            for a, b in combinations(range(first.n), 2)
        ):
            return True
    return False


def induced_copy_count(graph: Graph, pattern: Graph) -> int:
    """Count vertex subsets inducing a graph isomorphic to pattern."""
    if pattern.n > graph.n:
        return 0
    return sum(
        is_isomorphic(graph.induced(vertices), pattern)
        for vertices in combinations(range(graph.n), pattern.n)
    )


def card_edge_counts(graph: Graph) -> list[int]:
    """Return the edge count of every vertex-deleted card."""
    return [len(card.edges) for card in graph.deck()]


def recover_edge_count(counts: Iterable[int], order: int) -> int:
    """Recover m from card edge counts using sum counts = (order - 2)m."""
    if order < 3:
        raise ValueError("Edge recovery requires at least three vertices")
    total = sum(counts)
    quotient, remainder = divmod(total, order - 2)
    if remainder:
        raise ValueError("Counts violate the vertex-card edge-sum identity")
    return quotient


def verify_kelly(graph: Graph, pattern: Graph) -> tuple[int, int]:
    """Return the two sides of Kelly's induced-pattern identity."""
    visible = sum(induced_copy_count(card, pattern) for card in graph.deck())
    expected = (graph.n - pattern.n) * induced_copy_count(graph, pattern)
    return visible, expected


def demo() -> None:
    graph = Graph.from_edges(
        6,
        [(0, 1), (1, 2), (2, 0),  # a triangle
         (2, 3), (3, 4), (4, 5), (5, 2),  # a four-cycle sharing vertex 2
         (1, 4)],
    )
    edge = Graph.from_edges(2, [(0, 1)])
    triangle = Graph.from_edges(3, [(0, 1), (1, 2), (0, 2)])

    counts = card_edge_counts(graph)
    recovered = recover_edge_count(counts, graph.n)
    print("Graph order:", graph.n)
    print("Original edge count:", len(graph.edges))
    print("Card edge counts:", counts)
    print("Their sum:", sum(counts))
    print("Recovered edge count:", recovered)
    assert recovered == len(graph.edges)

    for name, pattern in [("edge", edge), ("triangle", triangle)]:
        original = induced_copy_count(graph, pattern)
        visible, expected = verify_kelly(graph, pattern)
        print(f"\nPattern: {name} ({pattern.n} vertices)")
        print("Copies in original graph:", original)
        print("Copies visible across cards:", visible)
        print(f"Expected multiplier {graph.n - pattern.n} gives:", expected)
        assert visible == expected

    print("\nDeletion-complement compatibility:")
    for vertex in range(graph.n):
        left = graph.complement().delete_vertex(vertex)
        right = graph.delete_vertex(vertex).complement()
        compatible = left == right
        print(f"  vertex {vertex}: {compatible}")
        assert compatible

    empty = Graph.from_edges(6, [])
    complete = empty.complement()
    assert recover_edge_count(card_edge_counts(empty), 6) == 0
    assert recover_edge_count(card_edge_counts(complete), 6) == 15
    print("\nExtremal checks: empty graph has 0 edges; complete graph has 15 edges.")
    print("All identities verified.")


if __name__ == "__main__":
    demo()
