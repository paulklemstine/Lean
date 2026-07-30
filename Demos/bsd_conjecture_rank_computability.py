#!/usr/bin/env python3
"""Exact numerical demonstrations for finite descent presentations.

The program computes matrix rank over the rational numbers, the dimension
n-rank(A) of the presented quotient, its parity, and the sign (-1)^rank.
A matrix result becomes an elliptic-curve rank only when accompanied by a
complete descent certificate identifying the quotient with the rationalized
Mordell--Weil group.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Sequence, TypeAlias

Rational: TypeAlias = Fraction
MatrixInput: TypeAlias = Sequence[Sequence[int | Fraction]]


@dataclass(frozen=True)
class PresentationResult:
    generators: int
    relations: int
    relation_rank: int
    quotient_rank: int

    @property
    def parity(self) -> str:
        return "even" if self.quotient_rank % 2 == 0 else "odd"

    @property
    def parity_sign(self) -> int:
        return 1 if self.quotient_rank % 2 == 0 else -1


def as_fraction_matrix(matrix: MatrixInput) -> list[list[Rational]]:
    """Copy a rectangular matrix using exact rational entries."""
    rows = [[Fraction(value) for value in row] for row in matrix]
    if not rows:
        return []
    width = len(rows[0])
    if any(len(row) != width for row in rows):
        raise ValueError("matrix must be rectangular")
    return rows


def reduced_row_echelon_form(matrix: MatrixInput) -> tuple[list[list[Rational]], list[int]]:
    """Return exact reduced row-echelon form and pivot-column indices."""
    rows = as_fraction_matrix(matrix)
    if not rows:
        return rows, []
    row_count, column_count = len(rows), len(rows[0])
    pivot_row = 0
    pivots: list[int] = []
    for column in range(column_count):
        candidate = next(
            (row for row in range(pivot_row, row_count) if rows[row][column] != 0),
            None,
        )
        if candidate is None:
            continue
        rows[pivot_row], rows[candidate] = rows[candidate], rows[pivot_row]
        pivot = rows[pivot_row][column]
        rows[pivot_row] = [value / pivot for value in rows[pivot_row]]
        for row in range(row_count):
            if row == pivot_row:
                continue
            factor = rows[row][column]
            if factor != 0:
                rows[row] = [
                    value - factor * pivot_value
                    for value, pivot_value in zip(rows[row], rows[pivot_row])
                ]
        pivots.append(column)
        pivot_row += 1
        if pivot_row == row_count:
            break
    return rows, pivots


def presentation_result(matrix: MatrixInput) -> PresentationResult:
    """Compute relation rank and quotient dimension for a relation matrix."""
    rows = as_fraction_matrix(matrix)
    generators = len(rows)
    relations = len(rows[0]) if rows else 0
    _, pivots = reduced_row_echelon_form(rows)
    relation_rank = len(pivots)
    return PresentationResult(
        generators=generators,
        relations=relations,
        relation_rank=relation_rank,
        quotient_rank=generators - relation_rank,
    )


def format_matrix(matrix: Iterable[Iterable[Rational]]) -> str:
    """Format a rational matrix without third-party dependencies."""
    rows = [[str(value) for value in row] for row in matrix]
    return "\n".join("  [" + ", ".join(row) + "]" for row in rows)


def run_examples() -> None:
    examples: dict[str, MatrixInput] = {
        "Rank-two quotient with one redundant relation": [
            [1, 0, 1],
            [0, 1, 1],
            [1, 1, 2],
            [0, 0, 0],
        ],
        "Rank-one quotient with four written relations": [
            [1, 0, 1, 2],
            [0, 1, 1, 2],
            [0, 0, 0, 0],
        ],
        "Full relation rank": [
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ],
    }
    for name, matrix in examples.items():
        rref, pivots = reduced_row_echelon_form(matrix)
        result = presentation_result(matrix)
        assert result.quotient_rank + result.relation_rank == result.generators
        print(f"\n{name}")
        print("-" * len(name))
        print("Relation matrix:")
        print(format_matrix(as_fraction_matrix(matrix)))
        print("Reduced row-echelon form:")
        print(format_matrix(rref))
        print(f"Pivot columns: {pivots}")
        print(f"relation rank = {result.relation_rank}")
        print(f"quotient rank = {result.generators} - {result.relation_rank} = {result.quotient_rank}")
        print(f"parity = {result.parity}; conditional parity sign = {result.parity_sign:+d}")

    # Exact arithmetic distinguishes a tiny nonzero pivot from zero.
    tiny = Fraction(1, 10**30)
    exact_matrix: MatrixInput = [[1, 1], [1, 1 + tiny]]
    exact = presentation_result(exact_matrix)
    assert exact.relation_rank == 2 and exact.quotient_rank == 0
    print("\nExact-arithmetic stress test")
    print("----------------------------")
    print(f"A pivot of size {tiny} remains nonzero over Q.")
    print(f"relation rank = {exact.relation_rank}; quotient rank = {exact.quotient_rank}")


if __name__ == "__main__":
    run_examples()
