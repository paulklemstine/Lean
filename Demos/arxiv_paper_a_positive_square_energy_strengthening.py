#!/usr/bin/env python3
"""Numerical demonstrations for determinant values on 2 x 2 matrix lattices.

The script uses only the Python standard library.  It checks the signature
identity, the sharp determinant--energy inequality and its scalar extremizers,
and the arithmetic concentration of determinant values on integer matrices.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from itertools import product
from math import ceil, isclose
from typing import Iterable, Iterator, TypeAlias

Matrix2: TypeAlias = tuple[tuple[float, float], tuple[float, float]]
IntMatrix2: TypeAlias = tuple[tuple[int, int], tuple[int, int]]


@dataclass(frozen=True)
class MatrixDiagnostics:
    """Pointwise determinant and energy information for a 2 x 2 matrix."""

    determinant: float
    square_energy: float
    signature_value: float
    inequality_slack: float


def determinant(matrix: Matrix2) -> float:
    """Return ad - bc for a 2 x 2 matrix."""
    (a, b), (c, d) = matrix
    return a * d - b * c


def square_energy(matrix: Matrix2) -> float:
    """Return the squared Frobenius norm."""
    return sum(entry * entry for row in matrix for entry in row)


def signature_coordinates(matrix: Matrix2) -> tuple[float, float, float, float]:
    """Apply the linear change putting determinant in signature (2, 2) form."""
    (a, b), (c, d) = matrix
    return ((a + d) / 2.0, (b - c) / 2.0, (a - d) / 2.0, (b + c) / 2.0)


def signature_value(matrix: Matrix2) -> float:
    """Evaluate x1^2 + x2^2 - x3^2 - x4^2 in signature coordinates."""
    x1, x2, x3, x4 = signature_coordinates(matrix)
    return x1 * x1 + x2 * x2 - x3 * x3 - x4 * x4


def diagnose(matrix: Matrix2) -> MatrixDiagnostics:
    """Compute all pointwise quantities used by the main identities."""
    det = determinant(matrix)
    energy = square_energy(matrix)
    return MatrixDiagnostics(det, energy, signature_value(matrix), energy - 2.0 * abs(det))


def scalar_identity(scale: float) -> Matrix2:
    """Construct scale times the 2 x 2 identity matrix."""
    return ((scale, 0.0), (0.0, scale))


def integer_matrices_in_ball(radius: float) -> Iterator[IntMatrix2]:
    """Yield integer 2 x 2 matrices of Frobenius norm strictly below radius."""
    bound = ceil(radius)
    radius_squared = radius * radius
    for a, b, c, d in product(range(-bound, bound + 1), repeat=4):
        if a * a + b * b + c * c + d * d < radius_squared:
            yield ((a, b), (c, d))


def determinant_histogram(radius: float) -> Counter[int]:
    """Count determinant values of integer matrices in a Frobenius ball."""
    histogram: Counter[int] = Counter()
    for (a, b), (c, d) in integer_matrices_in_ball(radius):
        histogram[a * d - b * c] += 1
    return histogram


def count_determinants_in_window(radius: float, lower: float, upper: float) -> int:
    """Count integer matrices in the ball with determinant in an open window."""
    if not lower < upper:
        raise ValueError("the determinant window must satisfy lower < upper")
    total = 0
    for (a, b), (c, d) in integer_matrices_in_ball(radius):
        det = a * d - b * c
        if lower < det < upper:
            total += 1
    return total


def verify_examples(matrices: Iterable[Matrix2]) -> None:
    """Assert the exact identities numerically on supplied examples."""
    for matrix in matrices:
        data = diagnose(matrix)
        assert isclose(data.determinant, data.signature_value, abs_tol=1e-12)
        assert data.inequality_slack >= -1e-12
        if not isclose(data.determinant, 0.0, abs_tol=1e-12):
            assert data.square_energy > 0.0


def main() -> None:
    examples: list[Matrix2] = [
        ((1.0, 2.0), (3.0, 4.0)),
        ((2.0, -1.0), (1.5, 3.0)),
        ((5.0, 10.0), (1.0, 2.0)),  # singular
        scalar_identity(3.0),
    ]
    verify_examples(examples)

    print("Pointwise determinant diagnostics")
    print("matrix | determinant | energy | signature value | energy - 2|det|")
    for matrix in examples:
        data = diagnose(matrix)
        print(
            f"{matrix} | {data.determinant:10.4f} | {data.square_energy:8.4f} | "
            f"{data.signature_value:15.4f} | {data.inequality_slack:16.4f}"
        )

    print("\nSharpness on scalar matrices")
    for scale in (0.5, 1.0, 2.0, -3.0):
        data = diagnose(scalar_identity(scale))
        print(f"r={scale:4.1f}: 2|det(rI)|={2 * abs(data.determinant):6.2f}, E(rI)={data.square_energy:6.2f}")
        assert isclose(2.0 * abs(data.determinant), data.square_energy)

    radius = 5.0
    histogram = determinant_histogram(radius)
    total = sum(histogram.values())
    nonintegral_window_count = count_determinants_in_window(radius, 1.0 / 3.0, 2.0 / 3.0)
    print(f"\nInteger lattice inside Frobenius radius {radius:g}")
    print(f"matrices enumerated: {total}")
    print(f"distinct determinant values: {len(histogram)}")
    print(f"count in the integer-free window (1/3, 2/3): {nonintegral_window_count}")
    print("most frequent determinant values:", histogram.most_common(10))
    assert nonintegral_window_count == 0


if __name__ == "__main__":
    main()
