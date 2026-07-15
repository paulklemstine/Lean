#!/usr/bin/env python3
"""Numerical demonstrations of kernels, stable extensions, and game solutions."""

from __future__ import annotations

from collections import deque
from itertools import combinations
from typing import Iterable, TypeVar

Vertex = TypeVar("Vertex", bound=int)
Edge = tuple[int, int]


def powerset(vertices: Iterable[int]) -> Iterable[frozenset[int]]:
    """Yield every subset of a finite collection of vertices."""
    items = tuple(vertices)
    for size in range(len(items) + 1):
        for chosen in combinations(items, size):
            yield frozenset(chosen)


def is_kernel(vertices: set[int], edges: set[Edge], candidate: frozenset[int]) -> bool:
    """Test directed independence and absorption."""
    independent = all(not (u in candidate and v in candidate) for u, v in edges)
    absorbing = all(
        x in candidate or any(u == x and v in candidate for u, v in edges)
        for x in vertices
    )
    return independent and absorbing


def is_stable(vertices: set[int], attacks: set[Edge], candidate: frozenset[int]) -> bool:
    """Test conflict-freeness and outward attack of every excluded vertex."""
    conflict_free = all(not (u in candidate and v in candidate) for u, v in attacks)
    covers_outside = all(
        x in candidate or any(u in candidate and v == x for u, v in attacks)
        for x in vertices
    )
    return conflict_free and covers_outside


def is_game_solution(vertices: set[int], moves: set[Edge], p_positions: frozenset[int]) -> bool:
    """Test x in P iff every move from x ends outside P."""
    return all(
        (x in p_positions)
        == all(v not in p_positions for u, v in moves if u == x)
        for x in vertices
    )


def enumerate_kernels(vertices: set[int], edges: set[Edge]) -> list[frozenset[int]]:
    """Enumerate all kernels by exhaustive subset testing."""
    return [candidate for candidate in powerset(vertices) if is_kernel(vertices, edges, candidate)]


def enumerate_stable(vertices: set[int], attacks: set[Edge]) -> list[frozenset[int]]:
    """Enumerate all stable extensions by exhaustive subset testing."""
    return [candidate for candidate in powerset(vertices) if is_stable(vertices, attacks, candidate)]


def backward_kernel(vertices: set[int], moves: set[Edge]) -> frozenset[int]:
    """Compute the unique kernel of a finite acyclic move graph in linear time."""
    successors: dict[int, list[int]] = {v: [] for v in vertices}
    indegree: dict[int, int] = {v: 0 for v in vertices}
    for source, target in moves:
        successors[source].append(target)
        indegree[target] += 1

    queue = deque(v for v in vertices if indegree[v] == 0)
    topological: list[int] = []
    while queue:
        source = queue.popleft()
        topological.append(source)
        for target in successors[source]:
            indegree[target] -= 1
            if indegree[target] == 0:
                queue.append(target)
    if len(topological) != len(vertices):
        raise ValueError("backward_kernel requires an acyclic graph")

    losing: set[int] = set()
    for source in reversed(topological):
        if all(target not in losing for target in successors[source]):
            losing.add(source)
    return frozenset(losing)


def directed_cycle(length: int) -> tuple[set[int], set[Edge]]:
    """Construct the consistently oriented cycle on length vertices."""
    if length < 2:
        raise ValueError("cycle length must be at least 2")
    vertices = set(range(length))
    return vertices, {(i, (i + 1) % length) for i in vertices}


def format_sets(sets: list[frozenset[int]]) -> str:
    return "[" + ", ".join("{" + ", ".join(map(str, sorted(s))) + "}" for s in sets) + "]"


def main() -> None:
    triangle_v, triangle_e = directed_cycle(3)
    square_v, square_e = directed_cycle(4)
    triangle_kernels = enumerate_kernels(triangle_v, triangle_e)
    triangle_stable = enumerate_stable(triangle_v, triangle_e)
    square_kernels = enumerate_kernels(square_v, square_e)
    square_stable = enumerate_stable(square_v, square_e)

    print("Directed 3-cycle")
    print("  kernels:", format_sets(triangle_kernels))
    print("  stable extensions:", format_sets(triangle_stable))
    print("Directed 4-cycle")
    print("  kernels:", format_sets(square_kernels))
    print("  stable extensions:", format_sets(square_stable))

    dag_v = set(range(8))
    dag_e: set[Edge] = {
        (0, 1), (0, 2), (1, 3), (1, 4), (2, 4),
        (2, 5), (3, 6), (4, 6), (4, 7), (5, 7),
    }
    unique = backward_kernel(dag_v, dag_e)
    all_kernels = enumerate_kernels(dag_v, dag_e)
    print("Terminating eight-position game")
    print("  backward-induction P-positions:", sorted(unique))
    print("  all kernels:", format_sets(all_kernels))
    print("  game equation holds:", is_game_solution(dag_v, dag_e, unique))
    terminals = {v for v in dag_v if not any(u == v for u, _ in dag_e)}
    print("  terminal positions:", sorted(terminals))
    print("  all terminals are P-positions:", terminals <= unique)

    reversed_attacks = {(target, source) for source, target in dag_e}
    print("  same set stable for reversed attacks:", is_stable(dag_v, reversed_attacks, unique))

    assert triangle_kernels == []
    assert triangle_stable == []
    assert set(square_kernels) == {frozenset({0, 2}), frozenset({1, 3})}
    assert set(square_stable) == {frozenset({0, 2}), frozenset({1, 3})}
    assert all_kernels == [unique]
    assert terminals <= unique
    assert is_game_solution(dag_v, dag_e, unique)
    assert is_stable(dag_v, reversed_attacks, unique)


if __name__ == "__main__":
    main()
