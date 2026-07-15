#!/usr/bin/env python3
"""Numerical demonstrations for well-founded disjunctive games.

The examples use finite countdown positions.  They compare recursive outcome
calculation with the exact two-heap criterion, simulate the mirror strategy,
and exhibit the two composition counterexamples.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Iterable, List, Optional, Sequence, Tuple

Position = Tuple[int, int]
Move = Tuple[str, int]


def countdown_options(position: Position) -> Iterable[Position]:
    """Generate all positions obtained by decreasing exactly one heap."""
    left, right = position
    for new_left in range(left):
        yield (new_left, right)
    for new_right in range(right):
        yield (left, new_right)


@lru_cache(maxsize=None)
def recursive_is_winning(position: Position) -> bool:
    """Evaluate a finite countdown position by the recursive outcome equation."""
    return any(not recursive_is_winning(option) for option in countdown_options(position))


def exact_is_winning(position: Position) -> bool:
    """Apply the exact two-heap countdown theorem."""
    return position[0] != position[1]


def balancing_move(position: Position) -> Optional[Position]:
    """Return the canonical move to the losing diagonal, if it exists."""
    left, right = position
    if left == right:
        return None
    common = min(left, right)
    return (common, common)


def outcome_table(limit: int) -> List[List[str]]:
    """Return an outcome table indexed by the two heap sizes."""
    if limit < 0:
        raise ValueError("limit must be nonnegative")
    return [
        ["W" if recursive_is_winning((left, right)) else "L" for right in range(limit + 1)]
        for left in range(limit + 1)
    ]


def print_outcome_table(limit: int) -> None:
    """Print a labeled countdown outcome table."""
    table = outcome_table(limit)
    header = "m\\n | " + " ".join(f"{n:>2}" for n in range(limit + 1))
    print(header)
    print("-" * len(header))
    for m, row in enumerate(table):
        print(f"{m:>3} | " + " ".join(f"{entry:>2}" for entry in row))


def mirror_response(before: Position, after_opening: Position) -> Position:
    """Mirror one legal opening from a diagonal countdown position."""
    left, right = before
    if left != right:
        raise ValueError("the state before the opening must be diagonal")
    new_left, new_right = after_opening
    changed_left = new_left < left and new_right == right
    changed_right = new_right < right and new_left == left
    if changed_left:
        return (new_left, new_left)
    if changed_right:
        return (new_right, new_right)
    raise ValueError("after_opening must be a legal one-heap decrease")


def simulate_mirror(start: int, openings: Sequence[Move]) -> List[Position]:
    """Simulate adversarial openings and the corresponding mirror responses.

    A move is ("L", value) or ("R", value).  Every supplied value must be
    smaller than the current common heap size.
    """
    if start < 0:
        raise ValueError("start must be nonnegative")
    state = (start, start)
    history = [state]
    for side, value in openings:
        if value < 0 or value >= state[0]:
            raise ValueError("each opening must strictly decrease one heap")
        if side.upper() == "L":
            opened = (value, state[1])
        elif side.upper() == "R":
            opened = (state[0], value)
        else:
            raise ValueError("side must be 'L' or 'R'")
        history.append(opened)
        state = mirror_response(state, opened)
        history.append(state)
    return history


def verify_exact_law(limit: int) -> None:
    """Assert recursive and exact outcomes agree throughout a finite square."""
    for left in range(limit + 1):
        for right in range(limit + 1):
            recursive = recursive_is_winning((left, right))
            exact = exact_is_winning((left, right))
            assert recursive == exact, (left, right, recursive, exact)


def demonstrate_counterexamples() -> None:
    """Display the two failures of naive composition rules."""
    single_one_wins = 1 != 0  # A one-heap game is represented against an empty heap.
    double_one_wins = exact_is_winning((1, 1))
    zero_loses_alone = not exact_is_winning((0, 0))
    zero_plus_one_wins = exact_is_winning((0, 1))
    print("A single heap of size 1 is winning:", single_one_wins)
    print("The sum (1, 1) is winning:", double_one_wins)
    print("Heap 0 is losing in isolation:", zero_loses_alone)
    print("The sum (0, 1) is winning:", zero_plus_one_wins)


def main() -> None:
    """Run all numerical demonstrations."""
    limit = 8
    verify_exact_law(limit)
    print(f"Recursive evaluation agrees with m != n for 0 <= m,n <= {limit}.\n")
    print_outcome_table(limit)

    print("\nCanonical winning moves from selected off-diagonal positions:")
    for position in [(2, 7), (9, 3), (0, 5)]:
        print(f"  {position} -> {balancing_move(position)}")

    openings: Sequence[Move] = [("L", 6), ("R", 4), ("L", 1), ("R", 0)]
    trajectory = simulate_mirror(9, openings)
    print("\nMirror-strategy trajectory:")
    print("  " + " -> ".join(map(str, trajectory)))

    print("\nContrarian examples:")
    demonstrate_counterexamples()


if __name__ == "__main__":
    main()
