#!/usr/bin/env python3
"""Numerical demonstrations of survival counting in vertex-deleted decks."""

from __future__ import annotations

from itertools import combinations, permutations
from typing import FrozenSet, Iterable, Iterator, Sequence

Vertex = int
Edge = tuple[Vertex, Vertex]
Graph = FrozenSet[Edge]


def normalize_edges(edges: Iterable[tuple[int, int]]) -> Graph:
    """Return loop-free edges as normalized unordered pairs."""
    result: set[Edge] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs do not have loops")
        result.add((min(u, v), max(u, v)))
    return frozenset(result)


def vertex_card(n: int, edges: Graph, deleted: int) -> Graph:
    """Delete one vertex while retaining the original labels."""
    if not 0 <= deleted < n:
        raise ValueError("deleted vertex is outside the graph")
    return frozenset((u, v) for u, v in edges if deleted not in (u, v))


def deck(n: int, edges: Graph) -> list[Graph]:
    """Construct all labeled vertex-deleted cards."""
    return [vertex_card(n, edges, v) for v in range(n)]


def recover_edge_count(card_edge_counts: Sequence[int]) -> int:
    """Recover the original edge count from card-edge counts."""
    n = len(card_edge_counts)
    if n < 3:
        raise ValueError("edge reconstruction requires at least three cards")
    total = sum(card_edge_counts)
    factor = n - 2
    quotient, remainder = divmod(total, factor)
    if remainder:
        raise ValueError("counts violate the edge-sum divisibility condition")
    return quotient


def relabeled_induced_edges(edges: Graph, vertices: tuple[int, ...]) -> Graph:
    """Return the induced graph on vertices, relabeled 0 through k-1."""
    position = {vertex: i for i, vertex in enumerate(vertices)}
    return normalize_edges(
        (position[u], position[v])
        for u, v in edges
        if u in position and v in position
    )


def are_isomorphic(k: int, first: Graph, second: Graph) -> bool:
    """Brute-force isomorphism test for two graphs on 0,...,k-1."""
    if len(first) != len(second):
        return False
    for image in permutations(range(k)):
        transported = normalize_edges((image[u], image[v]) for u, v in first)
        if transported == second:
            return True
    return False


def induced_copy_count(n: int, edges: Graph, k: int, pattern: Graph) -> int:
    """Count k-vertex subsets inducing a graph isomorphic to pattern."""
    return sum(
        are_isomorphic(k, relabeled_induced_edges(edges, support), pattern)
        for support in combinations(range(n), k)
    )


def kelly_card_counts(n: int, edges: Graph, k: int, pattern: Graph) -> list[int]:
    """Count induced copies of pattern surviving in each deletion card."""
    counts: list[int] = []
    for deleted in range(n):
        surviving = tuple(v for v in range(n) if v != deleted)
        count = 0
        for support in combinations(surviving, k):
            induced = relabeled_induced_edges(edges, support)
            if are_isomorphic(k, induced, pattern):
                count += 1
        counts.append(count)
    return counts


def demonstrate(name: str, n: int, edges: Graph) -> None:
    """Print edge reconstruction and triangle-count identities."""
    cards = deck(n, edges)
    card_edges = [len(card) for card in cards]
    recovered = recover_edge_count(card_edges)
    triangle = normalize_edges([(0, 1), (1, 2), (0, 2)])
    triangles = induced_copy_count(n, edges, 3, triangle)
    triangle_cards = kelly_card_counts(n, edges, 3, triangle)
    print(f"\n{name}: n={n}, edges={len(edges)}")
    print(f"  card edge counts: {card_edges}")
    print(f"  sum={sum(card_edges)} = (n-2)m={(n - 2) * len(edges)}")
    print(f"  recovered edge count: {recovered}")
    print(f"  triangles in graph: {triangles}")
    print(f"  triangle counts in cards: {triangle_cards}")
    print(
        f"  Kelly check: {sum(triangle_cards)} "
        f"= (n-3)N={(n - 3) * triangles}"
    )
    assert recovered == len(edges)
    assert sum(triangle_cards) == (n - 3) * triangles


def main() -> None:
    """Run examples spanning sparse, intermediate, and dense graphs."""
    cycle5 = normalize_edges((i, (i + 1) % 5) for i in range(5))
    star5 = normalize_edges((0, i) for i in range(1, 5))
    complete5 = normalize_edges(combinations(range(5), 2))
    triangle_with_tail = normalize_edges([(0, 1), (1, 2), (0, 2), (2, 3), (3, 4)])

    demonstrate("five-cycle", 5, cycle5)
    demonstrate("five-vertex star", 5, star5)
    demonstrate("complete graph on five vertices", 5, complete5)
    demonstrate("triangle with a two-edge tail", 5, triangle_with_tail)


if __name__ == "__main__":
    main()
