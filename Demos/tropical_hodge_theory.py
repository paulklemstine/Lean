#!/usr/bin/env python3
"""Self-contained numerical examples for closed Hodge decomposition.

The script uses only the Python standard library. Run: python3 demo.py
"""
from __future__ import annotations

from dataclasses import dataclass
from math import sqrt
from typing import List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Euclidean dot product."""
    return sum(a * b for a, b in zip(x, y))


def norm(x: Sequence[float]) -> float:
    """Euclidean norm."""
    return sqrt(dot(x, x))


def add(x: Sequence[float], y: Sequence[float]) -> Vector:
    return [a + b for a, b in zip(x, y)]


def sub(x: Sequence[float], y: Sequence[float]) -> Vector:
    return [a - b for a, b in zip(x, y)]


def scale(a: float, x: Sequence[float]) -> Vector:
    return [a * value for value in x]


def mat_vec(matrix: Matrix, x: Sequence[float]) -> Vector:
    return [dot(row, x) for row in matrix]


def transpose(matrix: Matrix) -> Matrix:
    if not matrix:
        return []
    return [list(column) for column in zip(*matrix)]


def mat_mul(left: Matrix, right: Matrix) -> Matrix:
    right_t = transpose(right)
    return [[dot(row, column) for column in right_t] for row in left]


def columns(matrix: Matrix) -> List[Vector]:
    return transpose(matrix)


def orthonormal_range(matrix: Matrix, tolerance: float = 1e-12) -> List[Vector]:
    """Modified Gram--Schmidt basis for the column space."""
    basis: List[Vector] = []
    for column in columns(matrix):
        residual = list(column)
        for q in basis:
            residual = sub(residual, scale(dot(q, residual), q))
        length = norm(residual)
        if length > tolerance:
            basis.append(scale(1.0 / length, residual))
    return basis


def project_onto_basis(x: Sequence[float], basis: Sequence[Vector]) -> Vector:
    result = [0.0 for _ in x]
    for q in basis:
        result = add(result, scale(dot(q, x), q))
    return result


@dataclass(frozen=True)
class Decomposition:
    exact: Vector
    harmonic: Vector
    closure_residual: float
    reconstruction_residual: float
    orthogonality_residual: float


def closed_hodge_decomposition(
    d_prev: Matrix, d_next: Matrix, x: Vector, tolerance: float = 1e-10
) -> Decomposition:
    """Project a closed cochain onto the exact range and its complement."""
    complex_residual = sum(norm(row) for row in mat_mul(d_next, d_prev))
    if complex_residual > tolerance:
        raise ValueError("The matrices do not form a cochain complex.")
    closure = norm(mat_vec(d_next, x))
    if closure > tolerance * (1.0 + norm(x)):
        raise ValueError(f"The input is not closed (residual {closure:.3e}).")
    basis = orthonormal_range(d_prev, tolerance)
    exact = project_onto_basis(x, basis)
    harmonic = sub(x, exact)
    orthogonality = max((abs(dot(q, harmonic)) for q in basis), default=0.0)
    return Decomposition(
        exact=exact,
        harmonic=harmonic,
        closure_residual=norm(mat_vec(d_next, harmonic)),
        reconstruction_residual=norm(sub(x, add(exact, harmonic))),
        orthogonality_residual=orthogonality,
    )


def weighted_projection_diagonal(
    d_prev: Matrix, x: Vector, weights: Vector
) -> Tuple[Vector, Vector]:
    """Weighted projection when the exact range has one generator."""
    generator = columns(d_prev)[0]
    weighted_dot = lambda u, v: sum(w * a * b for w, a, b in zip(weights, u, v))
    coefficient = weighted_dot(generator, x) / weighted_dot(generator, generator)
    exact = scale(coefficient, generator)
    return exact, sub(x, exact)


def demonstrate_nontrivial_harmonic_mode() -> None:
    d_prev = [[1.0], [0.0], [0.0]]
    d_next = [[0.0, 0.0, 1.0]]
    x = [2.0, -3.0, 0.0]
    result = closed_hodge_decomposition(d_prev, d_next, x)
    shifted = add(x, mat_vec(d_prev, [7.0]))
    shifted_result = closed_hodge_decomposition(d_prev, d_next, shifted)
    print("DEMO 1 — nontrivial harmonic representative")
    print("x:", x, "exact:", result.exact, "harmonic:", result.harmonic)
    print("after exact perturbation, harmonic:", shifted_result.harmonic)
    assert norm(sub(result.harmonic, shifted_result.harmonic)) < 1e-12


def demonstrate_counterexample() -> None:
    d_prev = [[1.0], [0.0]]
    d_next = [[0.0, 1.0]]
    z = [0.0, 1.0]
    print("\nDEMO 2 — failure for a nonclosed cochain")
    print("closure defect:", mat_vec(d_next, z))
    try:
        closed_hodge_decomposition(d_prev, d_next, z)
    except ValueError as error:
        print("correctly rejected:", error)
    else:
        raise AssertionError("A nonclosed vector was incorrectly accepted.")


def demonstrate_weighted_projection() -> None:
    d_prev = [[1.0], [1.0], [0.0]]
    d_next = [[1.0, -1.0, 0.0]]
    x = [2.0, 2.0, 5.0]
    weights = [1.0, 4.0, 2.0]
    exact, harmonic = weighted_projection_diagonal(d_prev, x, weights)
    generator = columns(d_prev)[0]
    weighted_orthogonality = sum(
        w * a * b for w, a, b in zip(weights, generator, harmonic)
    )
    print("\nDEMO 3 — weighted orthogonal decomposition")
    print("exact:", exact, "harmonic:", harmonic)
    print("weighted orthogonality residual:", weighted_orthogonality)
    assert norm(sub(x, add(exact, harmonic))) < 1e-12
    assert norm(mat_vec(d_next, harmonic)) < 1e-12
    assert abs(weighted_orthogonality) < 1e-12


def main() -> None:
    demonstrate_nontrivial_harmonic_mode()
    demonstrate_counterexample()
    demonstrate_weighted_projection()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
