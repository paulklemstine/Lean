#!/usr/bin/env python3
"""Exact numerical demonstrations of deformation rigidity.

The script uses only Python's standard library.  All linear algebra is performed
with Fraction, so rank and nullspace certificates are exact rather than based on
floating-point tolerances.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, Sequence, TypeAlias

Number: TypeAlias = int | Fraction
Matrix: TypeAlias = list[list[Fraction]]
Vector: TypeAlias = list[Fraction]


def as_fraction_matrix(rows: Sequence[Sequence[Number]]) -> Matrix:
    """Copy a rectangular matrix and convert all entries to exact fractions."""
    if not rows:
        return []
    width = len(rows[0])
    if any(len(row) != width for row in rows):
        raise ValueError("matrix must be rectangular")
    return [[Fraction(value) for value in row] for row in rows]


def rref(rows: Sequence[Sequence[Number]]) -> tuple[Matrix, list[int]]:
    """Return reduced row-echelon form and the ordered pivot columns."""
    matrix = as_fraction_matrix(rows)
    if not matrix:
        return matrix, []
    row_count, column_count = len(matrix), len(matrix[0])
    pivot_row = 0
    pivots: list[int] = []
    for column in range(column_count):
        candidate = next(
            (row for row in range(pivot_row, row_count) if matrix[row][column] != 0),
            None,
        )
        if candidate is None:
            continue
        matrix[pivot_row], matrix[candidate] = matrix[candidate], matrix[pivot_row]
        pivot = matrix[pivot_row][column]
        matrix[pivot_row] = [entry / pivot for entry in matrix[pivot_row]]
        for row in range(row_count):
            if row == pivot_row:
                continue
            factor = matrix[row][column]
            if factor != 0:
                matrix[row] = [
                    entry - factor * pivot_entry
                    for entry, pivot_entry in zip(matrix[row], matrix[pivot_row])
                ]
        pivots.append(column)
        pivot_row += 1
        if pivot_row == row_count:
            break
    return matrix, pivots


def matrix_rank(rows: Sequence[Sequence[Number]]) -> int:
    """Compute exact matrix rank."""
    return len(rref(rows)[1])


def nullspace_basis(rows: Sequence[Sequence[Number]]) -> list[Vector]:
    """Compute an exact basis for the right nullspace of a nonempty matrix."""
    reduced, pivots = rref(rows)
    if not reduced:
        raise ValueError("the number of columns is ambiguous for an empty matrix")
    column_count = len(reduced[0])
    free_columns = [column for column in range(column_count) if column not in pivots]
    basis: list[Vector] = []
    for free in free_columns:
        vector = [Fraction(0) for _ in range(column_count)]
        vector[free] = Fraction(1)
        for row, pivot_column in enumerate(pivots):
            vector[pivot_column] = -reduced[row][free]
        basis.append(vector)
    return basis


def matvec(rows: Sequence[Sequence[Number]], vector: Sequence[Number]) -> Vector:
    """Multiply a matrix by a vector exactly."""
    matrix = as_fraction_matrix(rows)
    exact_vector = [Fraction(value) for value in vector]
    if matrix and len(matrix[0]) != len(exact_vector):
        raise ValueError("incompatible matrix and vector dimensions")
    return [sum((entry * value for entry, value in zip(row, exact_vector)), Fraction(0))
            for row in matrix]


def is_rigid(rows: Sequence[Sequence[Number]]) -> bool:
    """Test whether the represented relation map has zero kernel."""
    if not rows:
        return False
    return matrix_rank(rows) == len(rows[0])


def determinant(rows: Sequence[Sequence[Number]]) -> Fraction:
    """Compute the exact determinant by fraction-preserving elimination."""
    matrix = as_fraction_matrix(rows)
    size = len(matrix)
    if any(len(row) != size for row in matrix):
        raise ValueError("determinant requires a square matrix")
    result = Fraction(1)
    sign = 1
    for column in range(size):
        candidate = next((row for row in range(column, size)
                          if matrix[row][column] != 0), None)
        if candidate is None:
            return Fraction(0)
        if candidate != column:
            matrix[column], matrix[candidate] = matrix[candidate], matrix[column]
            sign *= -1
        pivot = matrix[column][column]
        result *= pivot
        for row in range(column + 1, size):
            factor = matrix[row][column] / pivot
            for col in range(column + 1, size):
                matrix[row][col] -= factor * matrix[column][col]
    return sign * result


def extend_coefficients(rows: Sequence[Sequence[Number]]) -> Matrix:
    """Represent scalar extension from integers/rationals to rational coefficients."""
    return as_fraction_matrix(rows)


def contragredient_weight(weight: Sequence[int]) -> list[int]:
    """Apply negate-and-reverse duality to an algebraic-weight variation."""
    return [-entry for entry in reversed(weight)]


def rigidity_family(parameter: int) -> Matrix:
    """Return the relation matrix [[1,t],[t,1]] at an integral parameter t."""
    return as_fraction_matrix([[1, parameter], [parameter, 1]])


def format_vector(vector: Iterable[Fraction]) -> str:
    """Format an exact vector compactly."""
    return "(" + ", ".join(str(value) for value in vector) + ")"


def main() -> None:
    """Run four demonstrations and print exact certificates."""
    rigid_matrix = [[1, 2], [0, 3], [4, -1]]
    flexible_matrix = [[1, 2, 3], [2, 4, 6], [-1, -2, -3]]

    print("1. Rigid rectangular relation map")
    print(f"   rank = {matrix_rank(rigid_matrix)}, columns = 2")
    print(f"   rigid = {is_rigid(rigid_matrix)}")
    print(f"   nullspace basis = {nullspace_basis(rigid_matrix)}")
    extended = extend_coefficients(rigid_matrix)
    print(f"   rigid after rational scalar extension = {is_rigid(extended)}")

    print("\n2. Non-rigid relation map and explicit tangent vectors")
    flexible_basis = nullspace_basis(flexible_matrix)
    print(f"   rank = {matrix_rank(flexible_matrix)}, tangent dimension = {len(flexible_basis)}")
    for index, vector in enumerate(flexible_basis, start=1):
        print(f"   tangent vector {index}: {format_vector(vector)}, "
              f"image = {format_vector(matvec(flexible_matrix, vector))}")

    print("\n3. Determinantal rigidity family A(t) = [[1,t],[t,1]]")
    for parameter in range(-3, 4):
        matrix = rigidity_family(parameter)
        print(f"   t={parameter:2d}: det={str(determinant(matrix)):>2}, "
              f"rigid={is_rigid(matrix)}, kernel={nullspace_basis(matrix)}")

    print("\n4. Contragredient duality")
    weight = [3, -1, 4, 0]
    dual = contragredient_weight(weight)
    double_dual = contragredient_weight(dual)
    print(f"   variation    = {weight}")
    print(f"   dual         = {dual}")
    print(f"   double dual  = {double_dual}")
    print(f"   involutive   = {double_dual == weight}")
    print(f"   dual is zero iff original is zero: "
          f"{(all(x == 0 for x in dual)) == (all(x == 0 for x in weight))}")


if __name__ == "__main__":
    main()
