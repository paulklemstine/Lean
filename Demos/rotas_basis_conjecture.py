#!/usr/bin/env python3
"""Exact numerical demonstrations of Rota arrangements in dimensions one and two."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import permutations
from typing import Iterable, Sequence, TypeAlias

Scalar: TypeAlias = Fraction
Vector2: TypeAlias = tuple[Scalar, Scalar]
Row2: TypeAlias = tuple[Vector2, Vector2]
Grid2: TypeAlias = tuple[Row2, Row2]


def vector(x: int, y: int) -> Vector2:
    """Construct a two-dimensional vector with exact rational coordinates."""
    return Fraction(x), Fraction(y)


def determinant(x: Vector2, y: Vector2) -> Scalar:
    """Return the exact determinant of two column vectors."""
    return x[0] * y[1] - x[1] * y[0]


def independent(x: Vector2, y: Vector2) -> bool:
    """Decide whether two vectors form a basis of a two-dimensional space."""
    return determinant(x, y) != 0


def validate_basis(row: Row2, label: str) -> None:
    """Raise ValueError unless row is an ordered basis."""
    if not independent(*row):
        raise ValueError(f"{label} is not a basis: determinant = {determinant(*row)}")


def column_determinants(grid: Grid2) -> tuple[Scalar, Scalar]:
    """Compute the two exact column determinants of a 2-by-2 vector grid."""
    return determinant(grid[0][0], grid[1][0]), determinant(grid[0][1], grid[1][1])


def is_rota_arrangement(grid: Grid2, first: Row2, second: Row2) -> bool:
    """Check row preservation and independence of both columns."""
    rows_preserved = sorted(grid[0]) == sorted(first) and sorted(grid[1]) == sorted(second)
    return rows_preserved and all(value != 0 for value in column_determinants(grid))


def construct_rank_two(first: Row2, second: Row2) -> Grid2:
    """Construct the rank-two arrangement guaranteed by the exchange lemma."""
    validate_basis(first, "first row")
    validate_basis(second, "second row")
    straight: Grid2 = (first, second)
    if all(value != 0 for value in column_determinants(straight)):
        return straight
    swapped: Grid2 = (first, (second[1], second[0]))
    if not all(value != 0 for value in column_determinants(swapped)):
        raise AssertionError("exchange lemma violated for valid input bases")
    return swapped


@dataclass(frozen=True)
class PairingAudit:
    """A complete record of one possible second-row ordering."""

    permutation: tuple[int, int]
    grid: Grid2
    determinants: tuple[Scalar, Scalar]

    @property
    def succeeds(self) -> bool:
        return all(value != 0 for value in self.determinants)


def audit_pairings(first: Row2, second: Row2) -> list[PairingAudit]:
    """Enumerate both relative pairings and report their column determinants."""
    validate_basis(first, "first row")
    validate_basis(second, "second row")
    audits: list[PairingAudit] = []
    for order in permutations((0, 1)):
        reordered: Row2 = (second[order[0]], second[order[1]])
        grid: Grid2 = (first, reordered)
        audits.append(PairingAudit(order, grid, column_determinants(grid)))
    return audits


def format_vector(v: Vector2) -> str:
    return f"({v[0]}, {v[1]})"


def print_grid(grid: Grid2) -> None:
    for row in grid:
        print("  [" + ", ".join(format_vector(v) for v in row) + "]")


def demonstrate_case(name: str, first: Row2, second: Row2) -> None:
    print(f"\n{name}")
    print("-" * len(name))
    print(f"Input row determinants: {determinant(*first)}, {determinant(*second)}")
    for audit in audit_pairings(first, second):
        status = "works" if audit.succeeds else "fails"
        print(f"Second-row order {audit.permutation}: columns {audit.determinants} -> {status}")
    result = construct_rank_two(first, second)
    print("Chosen Rota arrangement:")
    print_grid(result)
    print(f"Verified: {is_rota_arrangement(result, first, second)}")


def rank_one_demo(nonzero_scalars: Iterable[int]) -> None:
    """Show that every nonzero singleton is a rank-one arrangement."""
    values = list(nonzero_scalars)
    if any(value == 0 for value in values):
        raise ValueError("rank-one basis vectors must be nonzero")
    print("Rank-one examples")
    print("-----------------")
    for value in values:
        print(f"The 1x1 grid [{value}] has a nonzero column and is therefore a basis grid.")


def main() -> None:
    rank_one_demo([1, -3, 7])
    demonstrate_case(
        "Straight pairing succeeds",
        (vector(1, 0), vector(0, 1)),
        (vector(1, 1), vector(2, 1)),
    )
    demonstrate_case(
        "A swap is forced",
        (vector(1, 0), vector(0, 1)),
        (vector(2, 0), vector(1, 3)),
    )
    demonstrate_case(
        "Both pairings succeed",
        (vector(1, 0), vector(0, 1)),
        (vector(1, 1), vector(1, -1)),
    )


if __name__ == "__main__":
    main()
