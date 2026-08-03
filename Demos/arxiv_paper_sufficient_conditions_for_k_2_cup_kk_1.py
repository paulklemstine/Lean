#!/usr/bin/env python3
"""Numerical demonstrations of common antineighborhood characterizations.

The script uses only the Python standard library.  Graphs are represented by
vertices 0,...,n-1 and undirected edges stored as normalized pairs.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Iterable, Iterator, Optional

Edge = tuple[int, int]
Witness = tuple[tuple[int, ...], Edge]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph on vertices ``range(order)``."""

    order: int
    edges: frozenset[Edge]

    @staticmethod
    def from_edges(order: int, edges: Iterable[Edge]) -> "Graph":
        normalized: set[Edge] = set()
        for u, v in edges:
            if not (0 <= u < order and 0 <= v < order):
                raise ValueError("edge endpoint outside the vertex range")
            if u == v:
                raise ValueError("loops are not allowed")
            normalized.add((min(u, v), max(u, v)))
        return Graph(order, frozenset(normalized))

    def adjacent(self, u: int, v: int) -> bool:
        return u != v and (min(u, v), max(u, v)) in self.edges

    def is_independent(self, vertices: Iterable[int]) -> bool:
        chosen = tuple(vertices)
        return all(not self.adjacent(u, v) for u, v in combinations(chosen, 2))

    def antineighborhood(self, vertices: Iterable[int]) -> tuple[int, ...]:
        chosen = tuple(vertices)
        return tuple(
            v for v in range(self.order)
            if all(not self.adjacent(v, a) for a in chosen)
        )

    def internal_edges(self, vertices: Iterable[int]) -> tuple[Edge, ...]:
        chosen = tuple(vertices)
        return tuple((u, v) for u, v in combinations(chosen, 2) if self.adjacent(u, v))

    def independent_sets(self, size: int) -> Iterator[tuple[int, ...]]:
        if size < 0 or size > self.order:
            return
        for chosen in combinations(range(self.order), size):
            if self.is_independent(chosen):
                yield chosen


def forbidden_witness(graph: Graph, k: int) -> Optional[Witness]:
    """Return an independent k-set and an edge in its common antineighborhood.

    A returned pair is exactly a witness to an induced K_2 union k K_1.
    ``None`` certifies that exhaustive enumeration found no such witness.
    """
    if k < 0:
        raise ValueError("k must be nonnegative")
    for independent_set in graph.independent_sets(k):
        quiet_zone = graph.antineighborhood(independent_set)
        edges = graph.internal_edges(quiet_zone)
        if edges:
            return independent_set, edges[0]
    return None


def is_k2_union_k1_free(graph: Graph, k: int) -> bool:
    """Decide whether ``graph`` is (K_2 union k K_1)-free."""
    return forbidden_witness(graph, k) is None


def inspect_large_independent_set(graph: Graph, vertices: Iterable[int], k: int) -> dict[str, object]:
    """Inspect the quiet zone of an independent set of size at least k."""
    chosen = tuple(vertices)
    if len(chosen) < k:
        raise ValueError("the supplied set has fewer than k vertices")
    if not graph.is_independent(chosen):
        raise ValueError("the supplied set is not independent")
    quiet_zone = graph.antineighborhood(chosen)
    edges = graph.internal_edges(quiet_zone)
    witness: Optional[Witness] = (chosen[:k], edges[0]) if edges else None
    return {"set": chosen, "antineighborhood": quiet_zone, "internal_edges": edges, "witness": witness}


def all_graphs(order: int) -> Iterator[Graph]:
    """Generate all labeled simple graphs of the given order."""
    possible = tuple(combinations(range(order), 2))
    for mask in range(1 << len(possible)):
        edges = (possible[i] for i in range(len(possible)) if mask & (1 << i))
        yield Graph.from_edges(order, edges)


def verify_parameter_monotonicity(order: int, max_k: int) -> tuple[int, int]:
    """Exhaustively check freeness at k implies freeness at every larger l."""
    checked = 0
    for graph in all_graphs(order):
        flags = [is_k2_union_k1_free(graph, k) for k in range(max_k + 1)]
        for k in range(max_k + 1):
            for ell in range(k, max_k + 1):
                checked += 1
                assert not flags[k] or flags[ell]
    return 1 << (order * (order - 1) // 2), checked


def main() -> None:
    violating = Graph.from_edges(5, [(2, 3), (3, 4)])
    repaired = Graph.from_edges(5, [(0, 2), (2, 3), (3, 4)])

    print("Example 1: a visible forbidden pattern for k=2")
    print("  edges:", sorted(violating.edges))
    print("  witness (independent set, quiet-zone edge):", forbidden_witness(violating, 2))
    print("  inspection of independent set {0,1}:", inspect_large_independent_set(violating, (0, 1), 2))

    print("\nExample 2: adding an attachment removes that particular witness")
    print("  edges:", sorted(repaired.edges))
    print("  first remaining witness, if any:", forbidden_witness(repaired, 2))

    print("\nExample 3: boundary k=0")
    empty = Graph.from_edges(4, [])
    one_edge = Graph.from_edges(4, [(0, 1)])
    print("  edgeless graph is free:", is_k2_union_k1_free(empty, 0))
    print("  graph with one edge is free:", is_k2_union_k1_free(one_edge, 0))

    print("\nExample 4: exhaustive monotonicity check on all graphs with five vertices")
    graph_count, implication_count = verify_parameter_monotonicity(5, 4)
    print(f"  checked {implication_count} implications across {graph_count} labeled graphs")
    print("  no counterexample found")


if __name__ == "__main__":
    main()
