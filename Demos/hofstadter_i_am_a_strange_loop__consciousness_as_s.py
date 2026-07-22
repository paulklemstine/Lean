#!/usr/bin/env python3
"""Numerical demonstrations of reflective depth, first returns, and diagonal limits."""

from __future__ import annotations

from typing import Callable, Hashable, Iterable, Optional, Sequence, TypeVar

T = TypeVar("T")
H = TypeVar("H", bound=Hashable)


def iterate(function: Callable[[T], T], value: T, steps: int) -> T:
    """Apply ``function`` to ``value`` exactly ``steps`` times."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    result = value
    for _ in range(steps):
        result = function(result)
    return result


def verify_retraction(
    states: Iterable[T], encode: Callable[[T], T], inspect: Callable[[T], T]
) -> bool:
    """Check inspect(encode(state)) == state throughout a finite collection."""
    return all(inspect(encode(state)) == state for state in states)


def verify_reflective_depth(
    states: Iterable[T],
    encode: Callable[[T], T],
    inspect: Callable[[T], T],
    depth: int,
) -> bool:
    """Check n nested encodings followed by n inspections on finite states."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return all(
        iterate(inspect, iterate(encode, state, depth), depth) == state
        for state in states
    )


def first_return(
    transition: Callable[[H], H], start: H, max_steps: int
) -> Optional[int]:
    """Return the first positive time at which the orbit revisits ``start``."""
    if max_steps < 1:
        raise ValueError("max_steps must be positive")
    current = start
    for step in range(1, max_steps + 1):
        current = transition(current)
        if current == start:
            return step
    return None


def diagonal_predicate(table: Sequence[Sequence[bool]]) -> list[bool]:
    """Negate the diagonal of a square Boolean representation table."""
    size = len(table)
    if any(len(row) != size for row in table):
        raise ValueError("the predicate table must be square")
    return [not table[index][index] for index in range(size)]


def demonstrate_reflective_depth() -> None:
    """Use tagged integer states to exhibit exact reconstruction at many depths."""
    # States (value, level) allow nontrivial encoding while remaining in one space.
    states = [(value, 0) for value in range(-2, 3)]

    def encode(state: tuple[int, int]) -> tuple[int, int]:
        value, level = state
        return value, level + 1

    def inspect(state: tuple[int, int]) -> tuple[int, int]:
        value, level = state
        return value, level - 1

    print("Inspectable self-model on tagged integer states")
    print("  one-step retraction:", verify_retraction(states, encode, inspect))
    for depth in (0, 1, 2, 3, 10, 50):
        valid = verify_reflective_depth(states, encode, inspect, depth)
        print(f"  depth {depth:>2}: {valid}")


def demonstrate_first_returns() -> None:
    """Compare periods one, two, and three and an aperiodic bounded search."""
    identity = lambda x: x
    swap = lambda x: 1 - x
    rotate_three = lambda x: (x + 1) % 3
    integer_shift = lambda x: x + 1

    print("\nFirst-return periods")
    print("  identity:", first_return(identity, 0, 10))
    print("  transposition:", first_return(swap, 0, 10))
    print("  three-state rotation:", first_return(rotate_three, 0, 10))
    print("  integer shift within 100 steps:", first_return(integer_shift, 0, 100))


def demonstrate_diagonal_escape() -> None:
    """Construct a Boolean predicate absent from every row of a finite table."""
    table = [
        [False, False, True, False],
        [True, True, False, False],
        [False, True, True, True],
        [True, False, True, True],
    ]
    missing = diagonal_predicate(table)

    print("\nDiagonal predicate")
    for index, row in enumerate(table):
        differs_at_own_index = missing[index] != row[index]
        print(f"  row {index}: {row}; diagonal differs here: {differs_at_own_index}")
    print("  constructed predicate:", missing)
    print("  absent from represented rows:", missing not in table)


def main() -> None:
    """Run all demonstrations."""
    demonstrate_reflective_depth()
    demonstrate_first_returns()
    demonstrate_diagonal_escape()


if __name__ == "__main__":
    main()
