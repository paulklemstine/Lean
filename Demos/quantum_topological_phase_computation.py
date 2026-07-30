#!/usr/bin/env python3
"""Numerical experiments for Fibonacci anyon fusion and braid gates.

The script uses only Python's standard library.  It checks the golden-ratio
identities, constructs the Fibonacci F and R matrices, verifies F^2 = I,
and compares the two three-strand braid words F R F R F R and R F R F R F
in the equivalent generator formulation sigma_1 = R, sigma_2 = F R F.
"""

from __future__ import annotations

import cmath
import math
from typing import Iterable, TypeAlias

Matrix2: TypeAlias = tuple[tuple[complex, complex], tuple[complex, complex]]


def matmul(a: Matrix2, b: Matrix2) -> Matrix2:
    """Multiply two 2-by-2 complex matrices."""
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )  # type: ignore[return-value]


def dagger(a: Matrix2) -> Matrix2:
    """Return the conjugate transpose."""
    return tuple(
        tuple(a[j][i].conjugate() for j in range(2)) for i in range(2)
    )  # type: ignore[return-value]


def subtract(a: Matrix2, b: Matrix2) -> Matrix2:
    return tuple(
        tuple(a[i][j] - b[i][j] for j in range(2)) for i in range(2)
    )  # type: ignore[return-value]


def frobenius(a: Matrix2) -> float:
    return math.sqrt(sum(abs(z) ** 2 for row in a for z in row))


def determinant(a: Matrix2) -> complex:
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def word_product(generators: dict[int, Matrix2], word: Iterable[int]) -> Matrix2:
    """Evaluate a positive braid word, reading factors from left to right."""
    result: Matrix2 = ((1 + 0j, 0j), (0j, 1 + 0j))
    for letter in word:
        result = matmul(result, generators[letter])
    return result


def fibonacci_matrices() -> tuple[float, Matrix2, Matrix2, Matrix2]:
    """Return phi, F, R, and the conjugated second braid generator F R F."""
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    off = math.sqrt(1.0 / phi)
    f: Matrix2 = (((1.0 / phi) + 0j, off + 0j),
                  (off + 0j, (-1.0 / phi) + 0j))
    r0 = cmath.exp(-4j * math.pi / 5.0)
    r1 = cmath.exp(3j * math.pi / 5.0)
    r: Matrix2 = ((r0, 0j), (0j, r1))
    second = matmul(matmul(f, r), f)
    return phi, f, r, second


def main() -> None:
    phi, f, sigma1, sigma2 = fibonacci_matrices()
    identity: Matrix2 = ((1 + 0j, 0j), (0j, 1 + 0j))
    left = word_product({1: sigma1, 2: sigma2}, [1, 2, 1])
    right = word_product({1: sigma1, 2: sigma2}, [2, 1, 2])

    print("Fibonacci anyon numerical demonstration")
    print(f"phi = {phi:.15f}")
    print(f"|phi^2 - phi - 1| = {abs(phi * phi - phi - 1):.3e}")
    print(f"||F^2-I||_F = {frobenius(subtract(matmul(f, f), identity)):.3e}")
    print(f"det(F) = {determinant(f):.15f}")
    print(f"|R_1|, |R_tau| = {abs(sigma1[0][0]):.15f}, {abs(sigma1[1][1]):.15f}")
    print(f"||R^*R-I||_F = {frobenius(subtract(matmul(dagger(sigma1), sigma1), identity)):.3e}")
    print(f"||sigma1 sigma2 sigma1 - sigma2 sigma1 sigma2||_F = {frobenius(subtract(left, right)):.3e}")
    print("\nThese floating-point residuals illustrate exact algebraic identities;")
    print("they are numerical evidence, not a density test for the braid image.")


if __name__ == "__main__":
    main()
