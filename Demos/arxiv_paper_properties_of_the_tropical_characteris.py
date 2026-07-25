#!/usr/bin/env python3
"""Numerical demonstrations of discrete concavity for tropical coefficients.

The script uses only the Python standard library.  It checks midpoint deficits,
consecutive slopes, affine invariance, and (for small matrices) computes maxima
of tropical permanents over principal submatrices by exhaustive enumeration.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Iterable, Sequence

Number = int | float
Matrix = Sequence[Sequence[Number]]


def midpoint_deficits(coefficients: Sequence[int]) -> list[int]:
    """Return Delta_k = 2*c_k-c_{k-1}-c_{k+1} at interior indices."""
    return [
        2 * coefficients[k] - coefficients[k - 1] - coefficients[k + 1]
        for k in range(1, len(coefficients) - 1)
    ]


def consecutive_slopes(coefficients: Sequence[int]) -> list[int]:
    """Return c_k-c_{k-1} for all consecutive coefficient pairs."""
    return [
        coefficients[k] - coefficients[k - 1]
        for k in range(1, len(coefficients))
    ]


def concavity_report(coefficients: Sequence[int]) -> dict[str, object]:
    """Produce a complete local certificate for a finite integer sequence."""
    deficits = midpoint_deficits(coefficients)
    slopes = consecutive_slopes(coefficients)
    violations = [k + 1 for k, deficit in enumerate(deficits) if deficit < 0]
    return {
        "coefficients": list(coefficients),
        "slopes": slopes,
        "midpoint_deficits": deficits,
        "is_discretely_concave": not violations,
        "violating_indices": violations,
        "slopes_nonincreasing": all(
            slopes[k + 1] <= slopes[k] for k in range(len(slopes) - 1)
        ),
    }


def affine_transform(
    coefficients: Sequence[int], slope_shift: int, intercept: int
) -> list[int]:
    """Return c'_k = c_k + slope_shift*k + intercept."""
    return [
        value + slope_shift * k + intercept
        for k, value in enumerate(coefficients)
    ]


def tropical_permanent(matrix: Matrix, indices: Iterable[int]) -> Number:
    """Compute a principal tropical permanent by exhaustive permutations."""
    selected = tuple(indices)
    if not selected:
        return 0
    return max(
        sum(matrix[i][j] for i, j in zip(selected, permutation))
        for permutation in permutations(selected)
    )


def principal_tropical_coefficients(matrix: Matrix) -> list[Number]:
    """Maximize principal tropical permanents separately at every cardinality."""
    n = len(matrix)
    if any(len(row) != n for row in matrix):
        raise ValueError("matrix must be square")
    coefficients: list[Number] = []
    for size in range(n + 1):
        layer = [
            tropical_permanent(matrix, subset)
            for subset in combinations(range(n), size)
        ]
        coefficients.append(max(layer))
    return coefficients


def print_report(title: str, coefficients: Sequence[int]) -> None:
    """Print a readable certificate."""
    report = concavity_report(coefficients)
    print(f"\n{title}")
    print("-" * len(title))
    for key, value in report.items():
        print(f"{key}: {value}")


def main() -> None:
    """Run strict, obstructed, affine, and matrix-based demonstrations."""
    quadratic = [-(k**2) for k in range(7)]
    print_report("Strict quadratic profile", quadratic)

    spike = [0, 0, 10, 0, 0]
    print_report("Spike obstruction", spike)

    transformed = affine_transform(quadratic, slope_shift=7, intercept=-4)
    print_report("Affine transform of the quadratic profile", transformed)
    print(
        "Affine invariance confirmed:",
        midpoint_deficits(quadratic) == midpoint_deficits(transformed),
    )

    diagonal_symmetric_matrix: list[list[int]] = [
        [8, -20, -20, -20],
        [-20, 6, -20, -20],
        [-20, -20, 3, -20],
        [-20, -20, -20, -1],
    ]
    matrix_coefficients = [
        int(value)
        for value in principal_tropical_coefficients(diagonal_symmetric_matrix)
    ]
    print_report(
        "Principal tropical coefficients of a symmetric matrix",
        matrix_coefficients,
    )


if __name__ == "__main__":
    main()
