#!/usr/bin/env python3
"""Numerical models for algebraic transport in an R=T comparison.

The examples use finite fields and finite-dimensional vector spaces to display:
1. transport of roots (points) across an explicit comparison;
2. transport of a basis across an invertible linear map;
3. uniqueness after precomposition with a surjection; and
4. maximal specialization of a two-variable polynomial ring.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

Vector = tuple[int, ...]
Matrix = tuple[tuple[int, ...], ...]


def mod_inverse(a: int, p: int) -> int:
    """Return the inverse of a modulo p, raising ValueError when none exists."""
    a %= p
    if a == 0:
        raise ValueError("zero has no multiplicative inverse")
    return pow(a, -1, p)


def roots_of_quadratic_constant(constant: int, p: int) -> list[int]:
    """Return all a in F_p satisfying a^2 = constant."""
    return [a for a in range(p) if (a * a - constant) % p == 0]


def mat_vec(matrix: Matrix, vector: Vector, p: int) -> Vector:
    """Multiply a square matrix by a vector over F_p."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix and vector dimensions do not match")
    return tuple(sum(a * b for a, b in zip(row, vector)) % p for row in matrix)


def invert_matrix(matrix: Matrix, p: int) -> Matrix:
    """Invert a square matrix over the prime field F_p by row reduction."""
    n = len(matrix)
    if n == 0 or any(len(row) != n for row in matrix):
        raise ValueError("matrix must be nonempty and square")
    augmented = [
        [entry % p for entry in matrix[i]]
        + [1 if i == j else 0 for j in range(n)]
        for i in range(n)
    ]
    for column in range(n):
        pivot = next((r for r in range(column, n) if augmented[r][column] % p), None)
        if pivot is None:
            raise ValueError("matrix is singular")
        augmented[column], augmented[pivot] = augmented[pivot], augmented[column]
        scale = mod_inverse(augmented[column][column], p)
        augmented[column] = [(scale * x) % p for x in augmented[column]]
        for row in range(n):
            if row != column:
                factor = augmented[row][column]
                augmented[row] = [
                    (x - factor * y) % p
                    for x, y in zip(augmented[row], augmented[column])
                ]
    return tuple(tuple(row[n:]) for row in augmented)


def transport_basis(comparison: Matrix, p: int) -> list[Vector]:
    """Pull the standard target basis back through an invertible comparison."""
    inverse = invert_matrix(comparison, p)
    n = len(comparison)
    standard_basis = [tuple(1 if i == j else 0 for i in range(n)) for j in range(n)]
    return [mat_vec(inverse, vector, p) for vector in standard_basis]


def verify_surjective_uniqueness(
    source: Iterable[int],
    target: Iterable[int],
    q: Callable[[int], int],
    phi: Callable[[int], int],
    psi: Callable[[int], int],
) -> bool:
    """Check finite-set surjectivity and cancellation of two target maps."""
    source_values = list(source)
    target_values = list(target)
    image = {q(r) for r in source_values}
    if image != set(target_values):
        return False
    composites_agree = all(phi(q(r)) == psi(q(r)) for r in source_values)
    return composites_agree and all(phi(t) == psi(t) for t in target_values)


@dataclass(frozen=True)
class Polynomial2:
    """A sparse polynomial sum c*u^i*v^j with integer coefficients."""

    terms: tuple[tuple[int, int, int], ...]

    def specialize(self, u: int, v: int, p: int) -> int:
        """Evaluate at (u,v) and reduce modulo p."""
        return sum(c * pow(u, i, p) * pow(v, j, p) for c, i, j in self.terms) % p


def main() -> None:
    print("=== 1. Transport of deformation points to eigenpackets ===")
    roots = roots_of_quadratic_constant(2, 7)
    print("Roots of z^2 = 2 in F_7:", roots)
    for root in roots:
        print(f"deformation x -> {root} transports uniquely to eigenpacket y -> {root}")

    print("\n=== 2. Freeness and basis transport ===")
    comparison: Matrix = ((1, 1), (0, 1))
    inverse = invert_matrix(comparison, 7)
    pulled_back_basis = transport_basis(comparison, 7)
    print("Comparison matrix over F_7:", comparison)
    print("Inverse matrix:", inverse)
    print("Pulled-back target basis:", pulled_back_basis)
    print("Images of pulled-back vectors:", [mat_vec(comparison, v, 7) for v in pulled_back_basis])

    print("\n=== 3. Uniqueness along a surjection ===")
    q = lambda r: r % 6
    phi = lambda t: (5 * t) % 6
    psi_equal = lambda t: (5 * t) % 6
    print(
        "Equal maps after reduction Z/12 -> Z/6 cancel:",
        verify_surjective_uniqueness(range(12), range(6), q, phi, psi_equal),
    )
    nonsurjective_q = lambda r: 0
    psi_different = lambda t: t % 6
    print(
        "A non-surjective presentation cannot certify uniqueness:",
        verify_surjective_uniqueness(range(12), range(6), nonsurjective_q, phi, psi_different),
    )

    print("\n=== 4. Maximal specialization of weight variables ===")
    polynomial = Polynomial2(((1, 2, 0), (1, 1, 1), (2, 0, 1), (1, 0, 0)))
    value = polynomial.specialize(u=2, v=3, p=5)
    print("u^2 + uv + 2v + 1 at (2,3) modulo 5:", value)
    print("Its inverse in F_5:", mod_inverse(value, 5))
    nonzero_products = {
        (a, b): (a * b) % 5 for a in range(1, 5) for b in range(1, 5)
    }
    print("No product of two nonzero residues is zero:", 0 not in nonzero_products.values())


if __name__ == "__main__":
    main()
