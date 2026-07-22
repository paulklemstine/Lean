#!/usr/bin/env python3
"""Numerical demonstrations of ranked hierarchies and diagonalization.

The examples use finite data to display three general mechanisms:
(1) strict rank decrease certifies the absence of directed cycles;
(2) wrapping and unwrapping preserve a represented value;
(3) the diagonal complement escapes every finite predicate table.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Hashable, Iterable, List, Sequence, Tuple, TypeVar, Generic

Node = TypeVar("Node", bound=Hashable)
Value = TypeVar("Value")
Edge = Tuple[Node, Node]  # (child, parent): child depends on parent


def find_two_cycles(edges: Iterable[Edge[Node]]) -> List[Edge[Node]]:
    """Return canonical representatives of all reversed edge pairs."""
    edge_set = set(edges)
    found = set()
    for child, parent in edge_set:
        if (parent, child) in edge_set:
            found.add(tuple(sorted((child, parent), key=repr)))
    return sorted(found, key=repr)


def validate_rank_certificate(
    ranks: Dict[Node, int], edges: Iterable[Edge[Node]]
) -> Tuple[bool, List[Edge[Node]]]:
    """Check rank(child) < rank(parent) on every dependency edge."""
    violations: List[Edge[Node]] = []
    for child, parent in edges:
        if child not in ranks or parent not in ranks:
            raise KeyError(f"missing rank for edge {(child, parent)!r}")
        if ranks[child] >= ranks[parent]:
            violations.append((child, parent))
    return not violations, violations


def path_ranks(path: Sequence[Node], ranks: Dict[Node, int]) -> List[int]:
    """Return the rank sequence along a path for inspection."""
    return [ranks[node] for node in path]


@dataclass(frozen=True)
class Lift(Generic[Value]):
    """A wrapper modeling a higher-level presentation of a value."""

    value: Value


def up(value: Value) -> Lift[Value]:
    return Lift(value)


def down(lifted: Lift[Value]) -> Value:
    return lifted.value


def diagonal_complement(table: Sequence[Sequence[bool]]) -> List[bool]:
    """Construct D[i] = not table[i][i] from a square Boolean table."""
    n = len(table)
    if any(len(row) != n for row in table):
        raise ValueError("the predicate table must be square")
    return [not table[i][i] for i in range(n)]


def row_difference_witnesses(
    table: Sequence[Sequence[bool]], diagonal: Sequence[bool]
) -> List[int]:
    """For each row i, confirm that coordinate i differs from the diagonal."""
    if len(table) != len(diagonal):
        raise ValueError("dimension mismatch")
    return [i for i, row in enumerate(table) if row[i] != diagonal[i]]


def hierarchy_demo() -> None:
    ranks = {"source": 4, "parser": 3, "ast": 2, "optimizer": 1, "code": 0}
    edges = [
        ("parser", "source"),
        ("ast", "parser"),
        ("optimizer", "ast"),
        ("code", "optimizer"),
    ]
    valid, violations = validate_rank_certificate(ranks, edges)
    path = ["source", "parser", "ast", "optimizer", "code"]
    print("Ranked dependency hierarchy")
    print(f"  path:  {' -> '.join(path)}")
    print(f"  ranks: {path_ranks(path, ranks)}")
    print(f"  certificate valid: {valid}; violations: {violations}")
    print(f"  two-cycles: {find_two_cycles(edges)}")

    tangled = edges + [("source", "parser")]
    valid_bad, violations_bad = validate_rank_certificate(ranks, tangled)
    print("After inserting the reverse edge source depends on parser:")
    print(f"  certificate valid: {valid_bad}; violations: {violations_bad}")
    print(f"  two-cycles: {find_two_cycles(tangled)}")


def lifting_demo() -> None:
    value = {"level": 0, "payload": [2, 3, 5, 7]}
    once = up(value)
    twice = up(once)
    print("\nReversible presentation transport")
    print(f"  down(up(value)) == value: {down(once) == value}")
    print(f"  down(down(up(up(value)))) == value: {down(down(twice)) == value}")


def diagonal_demo() -> None:
    table = [
        [False, False, False, False],
        [False, True, False, True],
        [True, True, False, False],
        [True, False, True, False],
    ]
    diagonal = diagonal_complement(table)
    witnesses = row_difference_witnesses(table, diagonal)
    print("\nFinite diagonal escape")
    for index, row in enumerate(table):
        print(f"  code {index} represents {row}")
    print(f"  diagonal complement: {diagonal}")
    print(f"  differs from row i at coordinate i for i = {witnesses}")
    print(f"  diagonal appears among rows: {diagonal in [list(r) for r in table]}")


def universe_demo(max_level: int = 7) -> None:
    if max_level < 0:
        raise ValueError("max_level must be nonnegative")
    successors = [(i, i + 1) for i in range(max_level + 1)]
    print("\nFinite window onto the unbounded level ladder")
    print("  successor witnesses:", successors)
    print("  every displayed i satisfies i < i + 1:", all(i < j for i, j in successors))
    print("  no displayed reversed strict pair:", all(not (j < i) for i, j in successors))


def main() -> None:
    hierarchy_demo()
    universe_demo()
    lifting_demo()
    diagonal_demo()


if __name__ == "__main__":
    main()
