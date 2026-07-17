#!/usr/bin/env python3
"""Numerical demonstrations of contraction, path lifting, and fiber characters."""

from __future__ import annotations

from collections import defaultdict, deque
from dataclasses import dataclass
from typing import Callable, Hashable, Iterable, Mapping, Sequence, TypeVar

V = TypeVar("V", bound=Hashable)
Q = TypeVar("Q", bound=Hashable)
S = TypeVar("S", bound=Hashable)

Edge = tuple[V, V]


@dataclass(frozen=True)
class ContractionReport:
    """Summary of one finite graph contraction."""

    quotient_edges: frozenset[tuple[Hashable, Hashable]]
    fibers_directed_connected: bool
    reachability_preserved: bool


def adjacency(vertices: Iterable[V], edges: Iterable[Edge[V]]) -> dict[V, set[V]]:
    """Build an adjacency dictionary, retaining isolated vertices."""
    result: dict[V, set[V]] = {vertex: set() for vertex in vertices}
    for source, target in edges:
        result.setdefault(source, set()).add(target)
        result.setdefault(target, set())
    return result


def reachable(graph: Mapping[V, set[V]], source: V, target: V) -> bool:
    """Decide reflexive directed reachability by breadth-first search."""
    queue: deque[V] = deque([source])
    seen: set[V] = {source}
    while queue:
        current = queue.popleft()
        if current == target:
            return True
        for neighbor in graph.get(current, set()):
            if neighbor not in seen:
                seen.add(neighbor)
                queue.append(neighbor)
    return False


def shortest_path(graph: Mapping[V, set[V]], source: V, target: V) -> list[V] | None:
    """Return a shortest directed path, or None when no path exists."""
    queue: deque[V] = deque([source])
    parent: dict[V, V | None] = {source: None}
    while queue:
        current = queue.popleft()
        if current == target:
            path: list[V] = []
            cursor: V | None = target
            while cursor is not None:
                path.append(cursor)
                cursor = parent[cursor]
            return list(reversed(path))
        for neighbor in graph.get(current, set()):
            if neighbor not in parent:
                parent[neighbor] = current
                queue.append(neighbor)
    return None


def contract_edges(edges: Iterable[Edge[V]], label: Callable[[V], Q]) -> set[Edge[Q]]:
    """Contract each edge by applying a label map to both endpoints."""
    return {(label(source), label(target)) for source, target in edges}


def fibers(vertices: Iterable[V], label: Callable[[V], Q]) -> dict[Q, list[V]]:
    """Partition vertices by their quotient labels."""
    groups: dict[Q, list[V]] = defaultdict(list)
    for vertex in vertices:
        groups[label(vertex)].append(vertex)
    return dict(groups)


def directed_fiber_connected(
    vertices: Sequence[V], edges: Sequence[Edge[V]], label: Callable[[V], Q]
) -> bool:
    """Test whether every ordered pair in every fiber is connected by a path."""
    graph = adjacency(vertices, edges)
    return all(
        reachable(graph, source, target)
        for group in fibers(vertices, label).values()
        for source in group
        for target in group
    )


def exact_reachability_holds(
    vertices: Sequence[V], edges: Sequence[Edge[V]], label: Callable[[V], Q]
) -> bool:
    """Compare original reachability with quotient reachability for all pairs."""
    graph = adjacency(vertices, edges)
    quotient_edges = contract_edges(edges, label)
    quotient_vertices = list({label(vertex) for vertex in vertices})
    quotient_graph = adjacency(quotient_vertices, quotient_edges)
    return all(
        reachable(graph, x, y) == reachable(quotient_graph, label(x), label(y))
        for x in vertices
        for y in vertices
    )


def fiber_characters(
    vertices: Iterable[V], label: Callable[[V], Q], weights: Mapping[V, int]
) -> dict[Q, int]:
    """Sum integer weights over each fiber."""
    result: dict[Q, int] = defaultdict(int)
    for vertex in vertices:
        result[label(vertex)] += weights[vertex]
    return dict(result)


def aggregate_characters(
    characters: Mapping[Q, int], second_label: Callable[[Q], S]
) -> dict[S, int]:
    """Aggregate first-stage fiber characters into second-stage characters."""
    result: dict[S, int] = defaultdict(int)
    for label, value in characters.items():
        result[second_label(label)] += value
    return dict(result)


def good_example() -> None:
    """Demonstrate exact reachability and associative character aggregation."""
    vertices = list(range(6))
    edges = [
        (0, 1), (1, 0), (2, 3), (3, 2), (4, 5), (5, 4),
        (1, 2), (3, 4),
    ]
    labels = {0: "A", 1: "A", 2: "B", 3: "B", 4: "C", 5: "C"}
    tiles = {"A": "X", "B": "X", "C": "Y"}
    weights = {vertex: 2**vertex for vertex in vertices}
    label = labels.__getitem__

    first_edges = contract_edges(edges, label)
    second_edges = contract_edges(first_edges, tiles.__getitem__)
    direct_edges = contract_edges(edges, lambda vertex: tiles[label(vertex)])
    first_characters = fiber_characters(vertices, label, weights)
    staged_characters = aggregate_characters(first_characters, tiles.__getitem__)
    direct_characters = fiber_characters(
        vertices, lambda vertex: tiles[label(vertex)], weights
    )

    graph = adjacency(vertices, edges)
    lifted = shortest_path(graph, 0, 4)

    print("=== Directed-connected contraction ===")
    print(f"Original edges: {edges}")
    print(f"First quotient edges: {sorted(first_edges)}")
    print(f"Second quotient edges: {sorted(second_edges)}")
    print(f"Direct composite edges: {sorted(direct_edges)}")
    print(f"Two-stage contraction equals direct contraction: {second_edges == direct_edges}")
    print(f"Every fiber is directed-connected: {directed_fiber_connected(vertices, edges, label)}")
    print(f"Exact reachability holds: {exact_reachability_holds(vertices, edges, label)}")
    print(f"A lifted path from vertex 0 in A to vertex 4 in C: {lifted}")
    print(f"Fiber characters: {first_characters}")
    print(f"Two-stage tile characters: {staged_characters}")
    print(f"Direct tile characters: {direct_characters}")
    print(f"Character aggregation is associative: {staged_characters == direct_characters}")
    print(f"Total character: {sum(weights.values())}")


def failure_example() -> None:
    """Show how a quotient can invent reachability without directed connectivity."""
    vertices = ["u", "v", "z"]
    edges = [("v", "u"), ("v", "z")]
    labels = {"u": "A", "v": "A", "z": "B"}
    label = labels.__getitem__
    quotient_edges = contract_edges(edges, label)
    original_graph = adjacency(vertices, edges)
    quotient_graph = adjacency(["A", "B"], quotient_edges)

    print("\n=== Failure without directed fiber connectivity ===")
    print(f"Edges: {edges}")
    print(f"Quotient edges: {sorted(quotient_edges)}")
    print(f"A reaches B in quotient: {reachable(quotient_graph, 'A', 'B')}")
    print(f"u reaches z upstairs: {reachable(original_graph, 'u', 'z')}")
    print(f"Fibers directed-connected: {directed_fiber_connected(vertices, edges, label)}")
    print(f"Exact reachability holds: {exact_reachability_holds(vertices, edges, label)}")


def main() -> None:
    good_example()
    failure_example()


if __name__ == "__main__":
    main()
