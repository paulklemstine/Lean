#!/usr/bin/env python3
"""Numerical demonstrations of toughness and complete-host thresholds.

The program uses only the Python standard library.  Graphs are represented by
sets of unordered vertex pairs.  Exhaustive deletion is intended for small
examples and returns an explicit witness whenever 1-toughness fails.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import FrozenSet, Iterable, Optional, Sequence

Vertex = int
Edge = tuple[Vertex, Vertex]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph with vertices ``0, ..., order - 1``."""

    order: int
    edges: FrozenSet[Edge]

    @staticmethod
    def from_edges(order: int, edges: Iterable[Edge]) -> "Graph":
        normalized: set[Edge] = set()
        for a, b in edges:
            if not (0 <= a < order and 0 <= b < order):
                raise ValueError("edge endpoint outside the vertex set")
            if a == b:
                raise ValueError("loops are not allowed")
            normalized.add((min(a, b), max(a, b)))
        return Graph(order, frozenset(normalized))

    def adjacent(self, a: Vertex, b: Vertex) -> bool:
        return a != b and (min(a, b), max(a, b)) in self.edges

    def component_count_after_deletion(self, deleted: Iterable[Vertex]) -> int:
        removed = set(deleted)
        remaining = set(range(self.order)) - removed
        count = 0
        while remaining:
            count += 1
            stack = [remaining.pop()]
            while stack:
                u = stack.pop()
                reached = {v for v in remaining if self.adjacent(u, v)}
                remaining.difference_update(reached)
                stack.extend(reached)
        return count

    def toughness_violation(self) -> Optional[tuple[FrozenSet[Vertex], int]]:
        """Return ``(S, c(G-S))`` with ``c(G-S) > |S|``, if one exists."""
        vertices = range(self.order)
        for size in range(self.order + 1):
            for choice in combinations(vertices, size):
                components = self.component_count_after_deletion(choice)
                if components > 1 and components > size:
                    return frozenset(choice), components
        return None

    def is_one_tough(self) -> bool:
        return self.toughness_violation() is None

    def cut_vertices(self) -> list[Vertex]:
        if self.component_count_after_deletion(()) != 1:
            return []
        return [
            v
            for v in range(self.order)
            if self.component_count_after_deletion((v,)) > 1
        ]

    def with_edges(self, additions: Iterable[Edge]) -> "Graph":
        return Graph.from_edges(self.order, list(self.edges) + list(additions))


def complete_graph(order: int) -> Graph:
    return Graph.from_edges(order, combinations(range(order), 2))


def cycle_graph(order: int) -> Graph:
    if order < 3:
        raise ValueError("a simple cycle needs at least three vertices")
    return Graph.from_edges(order, ((i, (i + 1) % order) for i in range(order)))


def star_graph(leaves: int) -> Graph:
    return Graph.from_edges(leaves + 1, ((0, i) for i in range(1, leaves + 1)))


def path_graph(order: int) -> Graph:
    return Graph.from_edges(order, ((i, i + 1) for i in range(order - 1)))


def is_complete(graph: Graph) -> bool:
    return len(graph.edges) == graph.order * (graph.order - 1) // 2


def induced_in_complete_host(pattern: Graph, host_order: int) -> bool:
    """Apply the exact criterion: completeness and enough host vertices."""
    return is_complete(pattern) and pattern.order <= host_order


def component_profile(graph: Graph) -> list[tuple[int, int]]:
    """For each deletion size, return the largest surviving component count."""
    profile: list[tuple[int, int]] = []
    for size in range(graph.order + 1):
        maximum = max(
            graph.component_count_after_deletion(choice)
            for choice in combinations(range(graph.order), size)
        )
        profile.append((size, maximum))
    return profile


def print_toughness_demo() -> None:
    print("1. Exhaustive component-count tests")
    for name, graph in (("cycle C6", cycle_graph(6)), ("star with 5 leaves", star_graph(5))):
        witness = graph.toughness_violation()
        print(f"   {name}: 1-tough = {witness is None}; violation = {witness}")
        print(f"      cut vertices = {graph.cut_vertices()}")
        print(f"      deletion profile (|S|, max components) = {component_profile(graph)}")


def print_monotonicity_demo() -> None:
    print("\n2. Edge-addition monotonicity")
    base = cycle_graph(6)
    reinforced = base.with_edges([(0, 3), (1, 4), (2, 5)])
    print(f"   C6 is 1-tough: {base.is_one_tough()}")
    print(f"   reinforced C6 is 1-tough: {reinforced.is_one_tough()}")
    inequalities = []
    for size in range(base.order + 1):
        for choice in combinations(range(base.order), size):
            old = base.component_count_after_deletion(choice)
            new = reinforced.component_count_after_deletion(choice)
            inequalities.append(new <= old)
    print(f"   c(reinforced-S) <= c(base-S) for all 64 deletion sets: {all(inequalities)}")


def print_threshold_demo() -> None:
    print("\n3. Exact induced thresholds in complete hosts")
    patterns: Sequence[tuple[str, Graph]] = (
        ("triangle K3", complete_graph(3)),
        ("path P3", path_graph(3)),
        ("clique K5", complete_graph(5)),
    )
    for name, pattern in patterns:
        answers = [induced_in_complete_host(pattern, n) for n in range(0, 8)]
        print(f"   {name:11s}: hosts K0,...,K7 -> {answers}")


def main() -> None:
    print_toughness_demo()
    print_monotonicity_demo()
    print_threshold_demo()


if __name__ == "__main__":
    main()
