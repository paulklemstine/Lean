#!/usr/bin/env python3
"""Numerical demonstrations of reticulations and cooperative systems.

The script uses only the Python standard library.  It constructs coordinate and
affine cooperative systems, validates the Latin and orthogonality conditions,
encodes a system as a svelte array, and checks unique intersections and the
m*n cardinality law.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Sequence, Tuple

GridPoint = Tuple[int, int]
Matrix = List[List[int]]
Pair = Tuple[int, int]


def shape(matrix: Sequence[Sequence[int]]) -> Tuple[int, int]:
    """Return (rows, columns), rejecting ragged or empty matrices."""
    if not matrix or not matrix[0]:
        raise ValueError("matrices must be nonempty")
    width = len(matrix[0])
    if any(len(row) != width for row in matrix):
        raise ValueError("matrix is ragged")
    return len(matrix), width


def horizontal(m: int, n: int) -> Matrix:
    """Return H(i,j)=i on an m-by-n grid."""
    return [[i for _ in range(n)] for i in range(m)]


def vertical(m: int, n: int) -> Matrix:
    """Return V(i,j)=j on an m-by-n grid."""
    return [[j for j in range(n)] for _ in range(m)]


def affine_column_matrix(m: int, n: int, shifts: Sequence[int]) -> Matrix:
    """Build C(i,j)=(i+shifts[j]) mod m, a column-Latin matrix."""
    if m <= 0 or n <= 0 or len(shifts) != n:
        raise ValueError("positive dimensions and one shift per column required")
    return [[(i + shifts[j]) % m for j in range(n)] for i in range(m)]


def affine_row_matrix(m: int, n: int, shifts: Sequence[int]) -> Matrix:
    """Build R(i,j)=(j+shifts[i]) mod n, a row-Latin matrix."""
    if m <= 0 or n <= 0 or len(shifts) != m:
        raise ValueError("positive dimensions and one shift per row required")
    return [[(j + shifts[i]) % n for j in range(n)] for i in range(m)]


def is_column_latin(matrix: Sequence[Sequence[int]]) -> bool:
    """Test whether every column is a permutation of range(m)."""
    m, n = shape(matrix)
    target = set(range(m))
    return all({matrix[i][j] for i in range(m)} == target for j in range(n))


def is_row_latin(matrix: Sequence[Sequence[int]]) -> bool:
    """Test whether every row is a permutation of range(n)."""
    m, n = shape(matrix)
    target = set(range(n))
    return all(set(matrix[i]) == target for i in range(m))


def pair_index(c_matrix: Sequence[Sequence[int]],
               r_matrix: Sequence[Sequence[int]]) -> Dict[Pair, GridPoint]:
    """Return the unique cell for each pair, or reject non-orthogonality."""
    m, n = shape(c_matrix)
    if shape(r_matrix) != (m, n):
        raise ValueError("matrix shapes differ")
    inverse: Dict[Pair, GridPoint] = {}
    for i in range(m):
        for j in range(n):
            pair = (c_matrix[i][j], r_matrix[i][j])
            if not (0 <= pair[0] < m and 0 <= pair[1] < n):
                raise ValueError(f"out-of-range pair {pair}")
            if pair in inverse:
                raise ValueError(f"repeated pair {pair}")
            inverse[pair] = (i, j)
    if len(inverse) != m * n:
        raise ValueError("not every pair occurs")
    return inverse


def is_orthogonal(c_matrix: Sequence[Sequence[int]],
                  r_matrix: Sequence[Sequence[int]]) -> bool:
    """Test whether every ordered symbol pair occurs exactly once."""
    try:
        pair_index(c_matrix, r_matrix)
        return True
    except ValueError:
        return False


@dataclass(frozen=True)
class CooperativeSystem:
    """Collections whose every column/row-type cross-pair is orthogonal."""

    column_matrices: Tuple[Matrix, ...]
    row_matrices: Tuple[Matrix, ...]

    def validate(self) -> Tuple[int, int]:
        if not self.column_matrices or not self.row_matrices:
            raise ValueError("at least one matrix of each type is required")
        m, n = shape(self.column_matrices[0])
        if any(shape(c) != (m, n) or not is_column_latin(c)
               for c in self.column_matrices):
            raise ValueError("invalid column-Latin collection")
        if any(shape(r) != (m, n) or not is_row_latin(r)
               for r in self.row_matrices):
            raise ValueError("invalid row-Latin collection")
        for c_matrix in self.column_matrices:
            for r_matrix in self.row_matrices:
                if not is_orthogonal(c_matrix, r_matrix):
                    raise ValueError("a cross-type pair is not orthogonal")
        return m, n

    def svelte_rows(self) -> List[Tuple[int, ...]]:
        """Encode each grid point by all left labels followed by right labels."""
        m, n = self.validate()
        return [
            tuple(c[i][j] for c in self.column_matrices)
            + tuple(r[i][j] for r in self.row_matrices)
            for i in range(m)
            for j in range(n)
        ]


def verify_svelte_projections(rows: Iterable[Tuple[int, ...]], m: int, n: int,
                              left_count: int, right_count: int) -> bool:
    """Check every left-right projection against the full m-by-n pair grid."""
    materialized = list(rows)
    expected = {(q, r) for q in range(m) for r in range(n)}
    if len(materialized) != m * n:
        return False
    for u in range(left_count):
        for v in range(right_count):
            projection = {(row[u], row[left_count + v]) for row in materialized}
            if projection != expected:
                return False
    return True


def print_matrix(name: str, matrix: Sequence[Sequence[int]]) -> None:
    print(f"{name}:")
    for row in matrix:
        print("  " + " ".join(map(str, row)))


def main() -> None:
    m, n = 3, 4
    h = horizontal(m, n)
    v = vertical(m, n)

    print("=== Canonical 3-by-4 cooperative pair ===")
    print_matrix("Horizontal H", h)
    print_matrix("Vertical V", v)
    print(f"column-Latin(H): {is_column_latin(h)}")
    print(f"row-Latin(V):    {is_row_latin(v)}")
    print(f"orthogonal(H,V): {is_orthogonal(h, v)}")
    inverse = pair_index(h, v)
    print(f"unique cell carrying pair (2, 3): {inverse[(2, 3)]}")
    print(f"point count: {len(inverse)} = {m}*{n} = {m*n}\n")

    # A second coordinate view obtained by global cyclic relabelings remains
    # cross-orthogonal to both coordinate matrices.
    c_shift = affine_column_matrix(m, n, [1] * n)
    r_shift = affine_row_matrix(m, n, [2] * m)
    system = CooperativeSystem((h, c_shift), (v, r_shift))
    rows = system.svelte_rows()

    print("=== Two-by-two cooperative system and its svelte encoding ===")
    print_matrix("Shifted column-Latin matrix", c_shift)
    print_matrix("Shifted row-Latin matrix", r_shift)
    print(f"number of encoded rows: {len(rows)}")
    print(f"all four cross-projections complete: "
          f"{verify_svelte_projections(rows, m, n, 2, 2)}")
    print("first six rows (two left labels, then two right labels):")
    for row in rows[:6]:
        print(" ", row)

    print("\n=== Canonical-coordinate characterizations ===")
    print("C is column-Latin iff (C,V) is orthogonal:",
          is_column_latin(c_shift) == is_orthogonal(c_shift, v))
    print("R is row-Latin iff (H,R) is orthogonal:",
          is_row_latin(r_shift) == is_orthogonal(h, r_shift))

    # Local Latin conditions alone do not force global cooperation.
    c_vary = affine_column_matrix(m, n, [0, 1, 2, 0])
    bad_r = affine_row_matrix(m, n, [0, 1, 2])
    print("\n=== Local balance versus global cooperation ===")
    print(f"c_vary is column-Latin: {is_column_latin(c_vary)}")
    print(f"bad_r is row-Latin: {is_row_latin(bad_r)}")
    print(f"c_vary orthogonal to bad_r: {is_orthogonal(c_vary, bad_r)}")


if __name__ == "__main__":
    main()
