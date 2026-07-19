#!/usr/bin/env python3
"""Numerical demonstrations for equality-constrained data integration."""

from __future__ import annotations

from collections import Counter, defaultdict
from itertools import product
from typing import Dict, Hashable, Iterable, List, Mapping, Sequence, Tuple, TypeVar

T = TypeVar("T", bound=Hashable)
Edge = Tuple[int, int]


class UnionFind:
    """Disjoint-set structure for connected components."""

    def __init__(self, size: int) -> None:
        self.parent = list(range(size))
        self.rank = [0] * size

    def find(self, item: int) -> int:
        while self.parent[item] != item:
            self.parent[item] = self.parent[self.parent[item]]
            item = self.parent[item]
        return item

    def union(self, left: int, right: int) -> None:
        a, b = self.find(left), self.find(right)
        if a == b:
            return
        if self.rank[a] < self.rank[b]:
            a, b = b, a
        self.parent[b] = a
        if self.rank[a] == self.rank[b]:
            self.rank[a] += 1


def connected_components(size: int, edges: Iterable[Edge]) -> List[List[int]]:
    """Return the vertex sets of the equality-constraint components."""
    uf = UnionFind(size)
    for left, right in edges:
        if not (0 <= left < size and 0 <= right < size):
            raise ValueError("edge endpoint outside the cell set")
        uf.union(left, right)
    groups: Dict[int, List[int]] = defaultdict(list)
    for vertex in range(size):
        groups[uf.find(vertex)].append(vertex)
    return list(groups.values())


def count_consistent_assignments(size: int, edges: Iterable[Edge], q: int) -> int:
    """Count q-valued assignments satisfying all edge equalities."""
    if q < 1:
        raise ValueError("the value set must be nonempty")
    component_count = len(connected_components(size, edges))
    return q**component_count


def enumerate_consistent_assignments(
    size: int, edges: Sequence[Edge], values: Sequence[T]
) -> List[Tuple[T, ...]]:
    """Enumerate feasible assignments; intended only for small examples."""
    return [
        assignment
        for assignment in product(values, repeat=size)
        if all(assignment[left] == assignment[right] for left, right in edges)
    ]


def constrained_hamming_imputation(
    size: int,
    edges: Sequence[Edge],
    observations: Mapping[int, T],
    values: Sequence[T],
) -> Tuple[List[T], int]:
    """Minimize observed Hamming loss subject to edge equalities.

    Ties are resolved by the order in ``values``. The return value consists of
    the completed assignment and its observed Hamming loss.
    """
    if not values:
        raise ValueError("the value set must be nonempty")
    if any(index < 0 or index >= size for index in observations):
        raise ValueError("observation index outside the cell set")
    allowed = set(values)
    if any(value not in allowed for value in observations.values()):
        raise ValueError("an observation is outside the declared value set")

    output = [values[0]] * size
    for component in connected_components(size, edges):
        frequencies = Counter(
            observations[index] for index in component if index in observations
        )
        chosen = max(values, key=lambda value: frequencies[value])
        for index in component:
            output[index] = chosen
    loss = sum(output[index] != value for index, value in observations.items())
    return output, loss


def complete_partial_database(
    size: int, observations: Mapping[int, T], default: T
) -> List[T]:
    """Complete an unconstrained partial database with a default value."""
    return [observations.get(index, default) for index in range(size)]


def main() -> None:
    print("DEMO 1 — Every unconstrained partial database is completable")
    partial = {0: "A", 3: "B"}
    completion = complete_partial_database(5, partial, default="A")
    print(f"observations: {partial}")
    print(f"one completion: {completion}\n")

    print("DEMO 2 — A triangle has three equations but rank two")
    triangle = [(0, 1), (1, 2), (0, 2)]
    feasible = enumerate_consistent_assignments(3, triangle, [0, 1])
    predicted = count_consistent_assignments(3, triangle, q=2)
    print(f"feasible Boolean assignments: {feasible}")
    print(f"exact count q^c: {predicted}; fraction: {predicted}/8 = {predicted / 8:.2f}")
    print("naive independent-edge fraction: 1/8 = 0.125\n")

    print("DEMO 3 — Componentwise constrained Hamming imputation")
    edges = [(0, 1), (1, 2), (3, 4)]
    observations = {0: "red", 1: "red", 2: "blue", 4: "blue", 5: "red"}
    result, loss = constrained_hamming_imputation(
        size=6, edges=edges, observations=observations, values=["red", "blue"]
    )
    print(f"components: {connected_components(6, edges)}")
    print(f"observations: {observations}")
    print(f"optimal feasible assignment: {result}")
    print(f"minimum observed Hamming loss: {loss}\n")

    print("DEMO 4 — Consistency depends on components, not raw edge count")
    path = [(0, 1), (1, 2), (2, 3)]
    cycle = path + [(3, 0), (0, 2)]
    for name, graph in [("path", path), ("cycle with redundant edges", cycle)]:
        count = count_consistent_assignments(4, graph, q=3)
        print(f"{name}: {len(graph)} edges, {count} consistent ternary assignments")


if __name__ == "__main__":
    main()
