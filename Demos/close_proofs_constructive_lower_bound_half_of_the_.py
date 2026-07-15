#!/usr/bin/env python3
"""Numerical demonstrations of finite join laws for the Z2 co-index."""

from __future__ import annotations

from itertools import permutations
from typing import Iterable, Sequence


def octahedral_multijoin_coindex(dimensions: Sequence[int]) -> int:
    """Return sum(dimensions) + number of joins for a nonempty finite family."""
    if not dimensions:
        raise ValueError("at least one factor is required")
    if any(d < 0 for d in dimensions):
        raise ValueError("sphere dimensions must be nonnegative")
    return sum(dimensions) + len(dimensions) - 1


def self_join_bound(witness_dimension: int, factors: int) -> int:
    """Return the certified co-index p(a+1)-1 for a p-fold self-join."""
    if witness_dimension < 0:
        raise ValueError("witness_dimension must be nonnegative")
    if factors < 1:
        raise ValueError("factors must be positive")
    return factors * (witness_dimension + 1) - 1


def suspension_tower(base_dimension: int, steps: int) -> list[int]:
    """List co-indices from the base octahedral sphere through repeated suspensions."""
    if base_dimension < 0 or steps < 0:
        raise ValueError("base_dimension and steps must be nonnegative")
    return [base_dimension + k for k in range(steps + 1)]


def permutation_values(dimensions: Sequence[int]) -> set[int]:
    """Compute co-indices for all distinct permutations of a small input."""
    return {
        octahedral_multijoin_coindex(order)
        for order in set(permutations(dimensions))
    }


def format_table(rows: Iterable[Sequence[object]]) -> str:
    """Format rows as a simple aligned text table."""
    data = [[str(cell) for cell in row] for row in rows]
    widths = [max(len(row[j]) for row in data) for j in range(len(data[0]))]
    return "\n".join(
        "  ".join(cell.rjust(widths[j]) for j, cell in enumerate(row))
        for row in data
    )


def main() -> None:
    """Run four reproducible examples of the principal formulas."""
    dimensions = [2, 0, 3, 1]
    value = octahedral_multijoin_coindex(dimensions)
    print("FINITE MULTI-JOIN")
    print(f"dimensions = {dimensions}")
    print(f"co-index = sum(dimensions) + factors - 1 = {value}\n")

    values = permutation_values(dimensions)
    print("PERMUTATION INVARIANCE")
    print(f"distinct orderings tested = {len(set(permutations(dimensions)))}")
    print(f"distinct co-index values = {sorted(values)}\n")
    assert values == {value}

    print("SUSPENSION TOWER FROM O_2")
    print(f"co-indices after 0 through 6 suspensions: {suspension_tower(2, 6)}\n")

    print("SHARP OCTAHEDRAL SELF-JOIN VALUES")
    rows: list[list[object]] = [["a\\p", 1, 2, 3, 4, 5]]
    for a in range(4):
        rows.append([a, *[self_join_bound(a, p) for p in range(1, 6)]])
    print(format_table(rows))

    assert self_join_bound(2, 4) == 11
    assert self_join_bound(0, 7) == 6
    print("\nAll numerical identities passed.")


if __name__ == "__main__":
    main()
