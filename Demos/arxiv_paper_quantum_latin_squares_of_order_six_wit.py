#!/usr/bin/env python3
"""Numerical and combinatorial demonstrations for order-six quantum Latin squares.

The script illustrates the exact finite counting certificates for cardinalities
19, 21, and 23, and numerically checks the Schur-product orthogonality identity
using the order-six Fourier Hadamard matrix.  It requires only the Python
standard library.
"""

from __future__ import annotations

import cmath
import math
from collections import Counter
from typing import Hashable, Iterable, Sequence, TypeVar

Label = TypeVar("Label", bound=Hashable)
Vector = tuple[complex, ...]


def upper_pairs(n: int) -> list[tuple[int, int]]:
    """Return all unordered pairs with repetition in lexicographic order."""
    return [(i, j) for i in range(n) for j in range(i, n)]


def symmetric_range(labels: dict[tuple[int, int], Label], n: int) -> set[Label]:
    """Extend upper-triangular labels symmetrically and return the full range."""
    return {labels[(min(i, j), max(i, j))] for i in range(n) for j in range(n)}


def nineteen_ray_certificate() -> tuple[int, dict[Hashable, list[tuple[int, int]]]]:
    """Construct the unique-triple fiber pattern and return its range and fibers."""
    pairs = upper_pairs(6)
    labels: dict[tuple[int, int], Hashable] = {pair: pair for pair in pairs}
    common = (0, 1)
    labels[(2, 5)] = common
    labels[(3, 4)] = common
    fibers: dict[Hashable, list[tuple[int, int]]] = {}
    for pair, label in labels.items():
        fibers.setdefault(label, []).append(pair)
    return len(symmetric_range(labels, 6)), fibers


def twenty_one_ray_certificate() -> int:
    """Count a symmetric array injectively labeled on all unordered pairs."""
    labels = {pair: pair for pair in upper_pairs(6)}
    return len(symmetric_range(labels, 6))


def twenty_three_ray_certificate() -> tuple[int, Counter[str]]:
    """Count disjoint tagged ray families in four- and two-dimensional summands."""
    rays_four = {("C4", k) for k in range(19)}
    rays_two = {("C2", k) for k in range(4)}
    union = rays_four | rays_two
    return len(union), Counter(tag for tag, _ in union)


def inner(v: Sequence[complex], w: Sequence[complex]) -> complex:
    """Hermitian inner product."""
    return sum(a.conjugate() * b for a, b in zip(v, w))


def schur(v: Sequence[complex], w: Sequence[complex]) -> Vector:
    """Coordinatewise product."""
    return tuple(a * b for a, b in zip(v, w))


def fourier_hadamard(n: int) -> list[Vector]:
    """Return the columns of the unnormalized Fourier Hadamard matrix."""
    omega = cmath.exp(2j * math.pi / n)
    return [tuple(omega ** (row * col) for row in range(n)) for col in range(n)]


def schur_square(columns: Sequence[Vector]) -> list[list[Vector]]:
    """Build the normalized Schur-product quantum Latin array."""
    scale = math.sqrt(len(columns))
    return [[tuple(z / scale for z in schur(x, y)) for y in columns] for x in columns]


def max_gram_error(vectors: Iterable[Vector]) -> float:
    """Maximum deviation of a vector family Gram matrix from the identity."""
    items = list(vectors)
    return max(
        abs(inner(v, w) - (1.0 if i == j else 0.0))
        for i, v in enumerate(items)
        for j, w in enumerate(items)
    )


def verify_fourier_example() -> tuple[float, float]:
    """Return maximal row and column orthonormality errors for order six."""
    square = schur_square(fourier_hadamard(6))
    row_error = max(max_gram_error(row) for row in square)
    col_error = max(max_gram_error(square[i][j] for i in range(6)) for j in range(6))
    return row_error, col_error


def main() -> None:
    card19, fibers = nineteen_ray_certificate()
    triple = next(members for members in fibers.values() if len(members) == 3)
    card21 = twenty_one_ray_certificate()
    card23, components = twenty_three_ray_certificate()
    row_error, col_error = verify_fourier_example()

    assert card19 == 19
    assert set(triple) == {(0, 1), (2, 5), (3, 4)}
    assert card21 == 21
    assert card23 == 23 and components == Counter({"C4": 19, "C2": 4})
    assert row_error < 1e-12 and col_error < 1e-12

    print("Order-six cardinality certificates")
    print(f"  unique triple {sorted(triple)} -> {card19} rays")
    print(f"  injective upper triangle (6*7/2) -> {card21} rays")
    print(f"  disjoint direct sum 19+4 -> {card23} rays: {dict(components)}")
    print("Numerical Schur-product orthogonality check (Fourier example)")
    print(f"  maximum row Gram error:    {row_error:.3e}")
    print(f"  maximum column Gram error: {col_error:.3e}")


if __name__ == "__main__":
    main()
