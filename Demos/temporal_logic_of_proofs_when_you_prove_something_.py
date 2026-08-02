#!/usr/bin/env python3
"""Finite demonstrations for temporal provability and tree leaf obstructions.

The script uses only the Python standard library. It exhaustively checks the
interaction Box A -> Box Box Future A on selected finite frames, displays a
proof-gain model, and verifies the degree-sum and leaf facts on sample trees.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence

BoolVector = tuple[bool, ...]
Relation = tuple[tuple[bool, ...], ...]
Edge = tuple[int, int]


@dataclass(frozen=True)
class TemporalFrame:
    """A finite frame with proof relation r and temporal relation t."""

    r: Relation
    t: Relation

    def __post_init__(self) -> None:
        n = len(self.r)
        if n == 0 or len(self.t) != n:
            raise ValueError("relations must have the same positive size")
        if any(len(row) != n for row in self.r + self.t):
            raise ValueError("relations must be square")

    @property
    def size(self) -> int:
        return len(self.r)


def relation_from_edges(n: int, edges: Iterable[Edge]) -> Relation:
    """Build an n-by-n Boolean relation from directed edges."""
    matrix = [[False] * n for _ in range(n)]
    for source, target in edges:
        if not (0 <= source < n and 0 <= target < n):
            raise ValueError("edge endpoint out of range")
        matrix[source][target] = True
    return tuple(tuple(row) for row in matrix)


def is_reflexive(relation: Relation) -> bool:
    return all(relation[i][i] for i in range(len(relation)))


def is_transitive(relation: Relation) -> bool:
    n = len(relation)
    return all(
        not (relation[i][j] and relation[j][k]) or relation[i][k]
        for i in range(n)
        for j in range(n)
        for k in range(n)
    )


def box(relation: Relation, values: Sequence[bool]) -> BoolVector:
    """Universal modal image; an empty successor set gives True."""
    return tuple(
        all(not relation[w][v] or values[v] for v in range(len(values)))
        for w in range(len(values))
    )


def future(relation: Relation, values: Sequence[bool]) -> BoolVector:
    """Existential temporal image."""
    return tuple(
        any(relation[w][v] and values[v] for v in range(len(values)))
        for w in range(len(values))
    )


def interaction_holds(frame: TemporalFrame, values: Sequence[bool]) -> bool:
    """Check Box A -> Box Box Future A at every state."""
    boxed = box(frame.r, values)
    conclusion = box(frame.r, box(frame.r, future(frame.t, values)))
    return all(not boxed[w] or conclusion[w] for w in range(frame.size))


def exhaustive_interaction_check(frame: TemporalFrame) -> tuple[bool, BoolVector | None]:
    """Test every Boolean valuation and return the first counterexample, if any."""
    for values in product((False, True), repeat=frame.size):
        if not interaction_holds(frame, values):
            return False, values
    return True, None


def proof_status(frame: TemporalFrame, values: Sequence[bool], state: int) -> bool:
    return box(frame.r, values)[state]


def persistence_holds_for_valuation(frame: TemporalFrame, values: Sequence[bool]) -> bool:
    boxed = box(frame.r, values)
    return all(
        not (frame.t[w][v] and boxed[w]) or boxed[v]
        for w in range(frame.size)
        for v in range(frame.size)
    )


def tree_degrees(n: int, edges: Sequence[Edge]) -> list[int]:
    """Compute degrees after validating a loop-free undirected edge list."""
    degrees = [0] * n
    seen: set[tuple[int, int]] = set()
    for a, b in edges:
        if not (0 <= a < n and 0 <= b < n) or a == b:
            raise ValueError("invalid simple-graph edge")
        edge = (min(a, b), max(a, b))
        if edge in seen:
            raise ValueError("duplicate edge")
        seen.add(edge)
        degrees[a] += 1
        degrees[b] += 1
    return degrees


def is_tree(n: int, edges: Sequence[Edge]) -> bool:
    """Test the finite tree condition by edge count and graph traversal."""
    if n < 1 or len(edges) != n - 1:
        return False
    adjacency: list[list[int]] = [[] for _ in range(n)]
    try:
        tree_degrees(n, edges)
    except ValueError:
        return False
    for a, b in edges:
        adjacency[a].append(b)
        adjacency[b].append(a)
    visited = {0}
    stack = [0]
    while stack:
        vertex = stack.pop()
        for neighbor in adjacency[vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                stack.append(neighbor)
    return len(visited) == n


def leaf_obstruction_witnesses(n: int, edges: Sequence[Edge]) -> list[int]:
    """Return vertices of degree <= 1, hence singleton non-dominance witnesses."""
    if not is_tree(n, edges):
        raise ValueError("the graph must be a nonempty tree")
    return [v for v, degree in enumerate(tree_degrees(n, edges)) if degree <= 1]


def demonstrate_temporal_results() -> None:
    print("TEMPORAL PROVABILITY")
    r = relation_from_edges(2, [(0, 1)])
    t = relation_from_edges(2, [(0, 0), (0, 1), (1, 1)])
    frame = TemporalFrame(r=r, t=t)
    valuation = (True, False)
    boxed = box(frame.r, valuation)
    valid, counterexample = exhaustive_interaction_check(frame)
    print(f"R transitive: {is_transitive(r)}; T reflexive: {is_reflexive(t)}")
    print(f"A truth vector: {valuation}; Box A: {boxed}")
    print(f"Proof gain from state 0 to 1: {not boxed[0] and boxed[1]}")
    print(f"Persistence for this valuation: {persistence_holds_for_valuation(frame, valuation)}")
    print(f"Interaction valid for all {2 ** frame.size} valuations: {valid}")
    print(f"Counterexample: {counterexample}\n")


def demonstrate_tree_results() -> None:
    print("TREE DEGREE SUM AND LEAF OBSTRUCTION")
    examples: list[tuple[str, int, list[Edge]]] = [
        ("single vertex", 1, []),
        ("path on six vertices", 6, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]),
        ("star on six vertices", 6, [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5)]),
        ("branched tree", 7, [(0, 1), (1, 2), (1, 3), (3, 4), (3, 5), (5, 6)]),
    ]
    for name, n, edges in examples:
        degrees = tree_degrees(n, edges)
        leaves = leaf_obstruction_witnesses(n, edges)
        print(f"{name}: n={n}, degrees={degrees}")
        print(f"  sum(deg)={sum(degrees)} = 2(n-1)={2 * (n - 1)}")
        print(f"  degree <= 1 vertices / singleton obstructions: {leaves}")


def main() -> None:
    demonstrate_temporal_results()
    demonstrate_tree_results()


if __name__ == "__main__":
    main()
