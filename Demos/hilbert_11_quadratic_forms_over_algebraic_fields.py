#!/usr/bin/env python3
"""Numerical demonstrations for quadratic forms and scalar extension.

The script uses only Python's standard library.  It demonstrates:
1. bounded rational isotropic-witness search;
2. preservation of quadratic values under an invertible coordinate change;
3. persistence of a rational zero after extension to the complex numbers;
4. creation of a new zero after adjoining a square root of -1.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import gcd
from typing import Iterable, Sequence, TypeVar

Scalar = TypeVar("Scalar", int, Fraction, complex)
Matrix = Sequence[Sequence[Scalar]]
Vector = Sequence[Scalar]


def quadratic_value(matrix: Matrix[Scalar], vector: Vector[Scalar]) -> Scalar:
    """Return v^T A v for a square matrix A and compatible vector v."""
    n = len(vector)
    if len(matrix) != n or any(len(row) != n for row in matrix):
        raise ValueError("matrix must be square and match the vector dimension")
    return sum(
        matrix[i][j] * vector[i] * vector[j]
        for i in range(n)
        for j in range(n)
    )


def mat_vec(matrix: Matrix[Scalar], vector: Vector[Scalar]) -> list[Scalar]:
    """Multiply a matrix by a vector."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("incompatible dimensions")
    return [sum(a * x for a, x in zip(row, vector)) for row in matrix]


def primitive(vector: Sequence[int]) -> bool:
    """Return whether the integer coordinates have gcd one."""
    common = 0
    for coordinate in vector:
        common = gcd(common, abs(coordinate))
    return common == 1


def bounded_isotropic_witnesses(
    matrix: Matrix[int], bound: int, *, primitive_only: bool = True
) -> list[tuple[int, ...]]:
    """Find integer representatives of rational zeros in [-bound, bound]^n.

    Opposite vectors represent the same projective zero, so the first nonzero
    coordinate is required to be positive.  This removes duplicate signs.
    """
    if bound < 1:
        raise ValueError("bound must be positive")
    n = len(matrix)
    answers: list[tuple[int, ...]] = []
    for vector in product(range(-bound, bound + 1), repeat=n):
        if not any(vector):
            continue
        first = next(x for x in vector if x != 0)
        if first < 0 or (primitive_only and not primitive(vector)):
            continue
        if quadratic_value(matrix, vector) == 0:
            answers.append(vector)
    return answers


def demonstrate_coordinate_change() -> None:
    """Check Q'(u)=Q(Pu) for a shear and transport a known zero."""
    lorentz: list[list[int]] = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]
    shear: list[list[int]] = [[1, 1, 0], [0, 1, 0], [0, 0, 1]]
    # P^{-1}(3,4,5)=(-1,4,5).
    transformed_witness = [-1, 4, 5]
    original_witness = mat_vec(shear, transformed_witness)
    old_value = quadratic_value(lorentz, original_witness)
    new_value = quadratic_value(lorentz, mat_vec(shear, transformed_witness))
    assert original_witness == [3, 4, 5]
    assert old_value == new_value == 0
    print("Coordinate change:")
    print(f"  u = {transformed_witness}, P u = {original_witness}")
    print(f"  Q'(u) = Q(Pu) = {new_value}\n")


def demonstrate_scalar_extension() -> None:
    """Show one persistent zero and one zero newly available over C."""
    lorentz: list[list[int]] = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]
    rational_zero = [Fraction(3), Fraction(4), Fraction(5)]
    complex_zero = [complex(x) for x in rational_zero]
    assert quadratic_value(lorentz, rational_zero) == 0
    assert abs(quadratic_value(lorentz, complex_zero)) < 1e-12

    sum_two_squares: list[list[complex]] = [[1, 0], [0, 1]]
    new_zero = [1 + 0j, 1j]
    assert abs(quadratic_value(sum_two_squares, new_zero)) < 1e-12
    print("Scalar extension:")
    print(f"  Rational zero {rational_zero} remains the zero {complex_zero} over C.")
    print(f"  The form x^2 + y^2 gains the nonzero complex zero {new_zero}.\n")


def demonstrate_bounded_search() -> None:
    """Search for primitive rational zeros of two diagonal forms."""
    lorentz = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]
    positive = [[1, 0], [0, 1]]
    lorentz_hits = bounded_isotropic_witnesses(lorentz, 5)
    positive_hits = bounded_isotropic_witnesses(positive, 5)
    assert (3, 4, 5) in lorentz_hits
    assert not positive_hits
    print("Bounded witness search:")
    print(f"  Primitive projective zeros of x^2+y^2-z^2 with bound 5: {len(lorentz_hits)}")
    print(f"  Sample witnesses: {lorentz_hits[:8]}")
    print(f"  Zeros of x^2+y^2 in the same rational search: {positive_hits}\n")


def main() -> None:
    """Run all demonstrations."""
    print("Quadratic Forms over Field Extensions\n" + "=" * 37 + "\n")
    demonstrate_bounded_search()
    demonstrate_coordinate_change()
    demonstrate_scalar_extension()
    print("All exact and numerical checks passed.")


if __name__ == "__main__":
    main()
