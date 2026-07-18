#!/usr/bin/env python3
"""Numerical demonstrations for cohomological obstructions in incomplete data.

The script uses only the Python standard library.  It computes matrix ranks by
Gaussian elimination, checks the cochain identity D1 D0 = 0, evaluates the
first-cohomology dimension, extracts simple quotient representatives, and
reconstructs a flag nerve from its overlap graph.
"""

from __future__ import annotations

from itertools import combinations
from typing import Iterable, Sequence

Matrix = list[list[float]]


def shape(a: Sequence[Sequence[float]]) -> tuple[int, int]:
    """Return matrix dimensions, accepting an empty matrix as 0 by 0."""
    if not a:
        return (0, 0)
    width = len(a[0])
    if any(len(row) != width for row in a):
        raise ValueError("Matrix rows have inconsistent lengths")
    return (len(a), width)


def transpose(a: Sequence[Sequence[float]]) -> Matrix:
    """Transpose a rectangular matrix."""
    rows, cols = shape(a)
    return [[float(a[i][j]) for i in range(rows)] for j in range(cols)]


def matmul(a: Sequence[Sequence[float]], b: Sequence[Sequence[float]]) -> Matrix:
    """Multiply two rectangular matrices."""
    ar, ac = shape(a)
    br, bc = shape(b)
    if ac != br:
        raise ValueError(f"Incompatible shapes {(ar, ac)} and {(br, bc)}")
    return [
        [sum(float(a[i][k]) * float(b[k][j]) for k in range(ac)) for j in range(bc)]
        for i in range(ar)
    ]


def rref(a: Sequence[Sequence[float]], tolerance: float = 1e-10) -> tuple[Matrix, list[int]]:
    """Compute reduced row-echelon form and pivot columns."""
    matrix = [list(map(float, row)) for row in a]
    rows, cols = shape(matrix)
    pivots: list[int] = []
    pivot_row = 0
    for col in range(cols):
        candidate = max(range(pivot_row, rows), key=lambda i: abs(matrix[i][col]), default=-1)
        if candidate < 0 or abs(matrix[candidate][col]) <= tolerance:
            continue
        matrix[pivot_row], matrix[candidate] = matrix[candidate], matrix[pivot_row]
        scale = matrix[pivot_row][col]
        matrix[pivot_row] = [x / scale for x in matrix[pivot_row]]
        for i in range(rows):
            if i == pivot_row:
                continue
            factor = matrix[i][col]
            if abs(factor) > tolerance:
                matrix[i] = [x - factor * y for x, y in zip(matrix[i], matrix[pivot_row])]
        pivots.append(col)
        pivot_row += 1
        if pivot_row == rows:
            break
    matrix = [[0.0 if abs(x) <= tolerance else x for x in row] for row in matrix]
    return matrix, pivots


def matrix_rank(a: Sequence[Sequence[float]], tolerance: float = 1e-10) -> int:
    """Compute numerical matrix rank."""
    return len(rref(a, tolerance)[1])


def nullspace(a: Sequence[Sequence[float]], tolerance: float = 1e-10) -> Matrix:
    """Return a basis of the null space as a list of column vectors."""
    reduced, pivots = rref(a, tolerance)
    _, cols = shape(a)
    free = [j for j in range(cols) if j not in pivots]
    basis: Matrix = []
    for free_col in free:
        vector = [0.0] * cols
        vector[free_col] = 1.0
        for row, pivot_col in enumerate(pivots):
            vector[pivot_col] = -reduced[row][free_col]
        basis.append(vector)
    return basis


def column_basis(a: Sequence[Sequence[float]], tolerance: float = 1e-10) -> Matrix:
    """Return independent columns of a as vectors."""
    _, pivots = rref(a, tolerance)
    rows, _ = shape(a)
    return [[float(a[i][j]) for i in range(rows)] for j in pivots]


def rank_of_vectors(vectors: Sequence[Sequence[float]], tolerance: float = 1e-10) -> int:
    """Compute the dimension of the span of column vectors."""
    if not vectors:
        return 0
    return matrix_rank(transpose(vectors), tolerance)


def is_zero_matrix(a: Sequence[Sequence[float]], tolerance: float = 1e-10) -> bool:
    """Test whether all matrix entries vanish within tolerance."""
    return all(abs(x) <= tolerance for row in a for x in row)


def h1_dimension(d0: Matrix, d1: Matrix, tolerance: float = 1e-10) -> int:
    """Return dim H^1 = dim C1 - rank(D0) - rank(D1)."""
    d0_rows, _ = shape(d0)
    _, d1_cols = shape(d1)
    if d0_rows != d1_cols:
        raise ValueError("D0 must map into the domain of D1")
    if not is_zero_matrix(matmul(d1, d0), tolerance):
        raise ValueError("The matrices do not satisfy D1 D0 = 0")
    answer = d0_rows - matrix_rank(d0, tolerance) - matrix_rank(d1, tolerance)
    if answer < 0:
        raise ArithmeticError("Negative dimension indicates inconsistent rank tolerance")
    return answer


def h1_representatives(d0: Matrix, d1: Matrix, tolerance: float = 1e-10) -> Matrix:
    """Extract vectors in ker(D1) independent modulo im(D0)."""
    if not is_zero_matrix(matmul(d1, d0), tolerance):
        raise ValueError("The matrices do not satisfy D1 D0 = 0")
    accepted = column_basis(d0, tolerance)
    representatives: Matrix = []
    current_rank = rank_of_vectors(accepted, tolerance)
    for vector in nullspace(d1, tolerance):
        trial = accepted + [vector]
        trial_rank = rank_of_vectors(trial, tolerance)
        if trial_rank > current_rank:
            representatives.append(vector)
            accepted.append(vector)
            current_rank = trial_rank
    return representatives


def all_cliques(vertices: Iterable[str], edges: Iterable[tuple[str, str]]) -> list[tuple[str, ...]]:
    """Enumerate nonempty faces of the clique complex of an overlap graph."""
    ordered = sorted(set(vertices))
    edge_set = {frozenset((u, v)) for u, v in edges if u != v}
    faces: list[tuple[str, ...]] = []
    for size in range(1, len(ordered) + 1):
        for subset in combinations(ordered, size):
            if all(frozenset(pair) in edge_set for pair in combinations(subset, 2)):
                faces.append(subset)
    return faces


def print_complex(name: str, d0: Matrix, d1: Matrix) -> None:
    """Print ranks, obstruction dimension, and representatives."""
    print(f"\n{name}")
    print("-" * len(name))
    print(f"rank(D0) = {matrix_rank(d0)}")
    print(f"rank(D1) = {matrix_rank(d1)}")
    print(f"dim(C1)  = {len(d0)}")
    print(f"dim(H1)  = {h1_dimension(d0, d1)}")
    print(f"representatives = {h1_representatives(d0, d1)}")


def main() -> None:
    """Run three demonstrations of the principal results."""
    d0_one = [[1, 0], [0, 1], [0, 0], [0, 0]]
    d1_one = [[0, 0, 1, 0]]
    print_complex("A complex with one surviving obstruction", d0_one, d1_one)

    d0_maximal = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    d1_zero = [[0, 0, 0]]
    d0_surjective = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    print_complex("Maximal obstruction with zero maps", d0_maximal, d1_zero)
    print_complex("Vanishing obstruction with a surjective patch map", d0_surjective, d1_zero)

    vertices = ["A", "B", "C", "D"]
    edges = [("A", "B"), ("A", "C"), ("B", "C"), ("C", "D")]
    faces = all_cliques(vertices, edges)
    print("\nFlag nerve reconstructed from pairwise overlaps")
    print("-" * 48)
    print("faces:", faces)
    print("The clique {A, B, C} becomes a filled triangular overlap face.")


if __name__ == "__main__":
    main()
