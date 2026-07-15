#!/usr/bin/env python3
"""Numerical demonstrations of kernel quotients in character-polynomial codes.

The examples use matrices over prime fields.  The post-trace word associated
with y in F_p^m is the phase vector exp(2*pi*i*y_j/p), which is injective on
F_p^m.  Thus matrix-kernel cosets are exactly codeword collision classes.
"""

from __future__ import annotations

from cmath import exp, pi
from itertools import product
from typing import Iterable, Sequence

Vector = tuple[int, ...]
Matrix = list[list[int]]


def mat_vec(matrix: Sequence[Sequence[int]], vector: Sequence[int], p: int) -> Vector:
    """Multiply a matrix and vector modulo the prime p."""
    return tuple(sum(a * x for a, x in zip(row, vector)) % p for row in matrix)


def subtract(a: Sequence[int], b: Sequence[int], p: int) -> Vector:
    """Subtract vectors modulo p."""
    return tuple((x - y) % p for x, y in zip(a, b))


def rref(matrix: Sequence[Sequence[int]], p: int) -> tuple[Matrix, list[int]]:
    """Return reduced row-echelon form and pivot columns over F_p."""
    a = [[x % p for x in row] for row in matrix]
    if not a:
        return a, []
    rows, cols = len(a), len(a[0])
    pivot_row = 0
    pivots: list[int] = []
    for col in range(cols):
        candidate = next((r for r in range(pivot_row, rows) if a[r][col]), None)
        if candidate is None:
            continue
        a[pivot_row], a[candidate] = a[candidate], a[pivot_row]
        inverse = pow(a[pivot_row][col], -1, p)
        a[pivot_row] = [(inverse * x) % p for x in a[pivot_row]]
        for r in range(rows):
            if r != pivot_row and a[r][col]:
                factor = a[r][col]
                a[r] = [(x - factor * y) % p for x, y in zip(a[r], a[pivot_row])]
        pivots.append(col)
        pivot_row += 1
        if pivot_row == rows:
            break
    return a, pivots


def rank_mod(matrix: Sequence[Sequence[int]], p: int) -> int:
    """Compute matrix rank over F_p."""
    return len(rref(matrix, p)[1])


def all_vectors(p: int, dimension: int) -> Iterable[Vector]:
    """Generate all vectors in F_p^dimension."""
    return product(range(p), repeat=dimension)


def phase_word(visible: Sequence[int], p: int) -> tuple[complex, ...]:
    """Map visible field coordinates injectively to p-th roots of unity."""
    return tuple(exp(2j * pi * y / p) for y in visible)


def visible_image(matrix: Sequence[Sequence[int]], p: int) -> set[Vector]:
    """Enumerate the exact visible image of a matrix map."""
    n = len(matrix[0]) if matrix else 0
    return {mat_vec(matrix, x, p) for x in all_vectors(p, n)}


def kernel(matrix: Sequence[Sequence[int]], p: int) -> set[Vector]:
    """Enumerate the matrix kernel."""
    n = len(matrix[0]) if matrix else 0
    zero = (0,) * len(matrix)
    return {x for x in all_vectors(p, n) if mat_vec(matrix, x, p) == zero}


def canonical_representatives(matrix: Sequence[Sequence[int]], p: int) -> dict[Vector, Vector]:
    """Choose the lexicographically least parameter for every visible value."""
    n = len(matrix[0]) if matrix else 0
    representatives: dict[Vector, Vector] = {}
    for x in all_vectors(p, n):
        representatives.setdefault(mat_vec(matrix, x, p), x)
    return representatives


def collision_test(matrix: Sequence[Sequence[int]], a: Vector, b: Vector, p: int) -> bool:
    """Test equality of encoded words by checking whether a-b is in the kernel."""
    return all(y == 0 for y in mat_vec(matrix, subtract(a, b, p), p))


def demonstrate_single_map() -> None:
    """Verify exact cardinality and a transversal for a rank-two map over F_5."""
    p = 5
    matrix = [[1, 0, 1, 0], [0, 1, 0, 1]]
    n = 4
    rank = rank_mod(matrix, p)
    image = visible_image(matrix, p)
    ker = kernel(matrix, p)
    reps = canonical_representatives(matrix, p)

    assert len(image) == p**rank == 25
    assert len(ker) == p ** (n - rank) == 25
    assert len(reps) == len(image)
    assert len(image) * len(ker) == p**n
    assert len({phase_word(y, p) for y in image}) == len(image)

    a = (1, 2, 3, 4)
    z = (2, 1, 3, 4)  # z=(-3,-4,3,4), so Mz=0 mod 5.
    b = tuple((x + y) % p for x, y in zip(a, z))
    assert z in ker and collision_test(matrix, a, b, p)

    print("Example 1: rank-two trace-visible map over F_5")
    print(f"  raw parameters: {p**n}")
    print(f"  rank: {rank}; distinct words: {len(image)}")
    print(f"  kernel size/descriptions per word: {len(ker)}")
    print(f"  canonical transversal size: {len(reps)}")
    print(f"  collision pair: {a} and {b}\n")


def demonstrate_coordinate_family() -> None:
    """Verify coefficientwise collisions for two copies of a trace-like map."""
    p = 3
    # tau(x,y,z)=(x+y+z); two independent coefficients give a block map.
    block = [[1, 1, 1, 0, 0, 0], [0, 0, 0, 1, 1, 1]]
    rank = rank_mod(block, p)
    image = visible_image(block, p)
    ker = kernel(block, p)
    assert rank == 2 and len(image) == p**2
    assert len(ker) == p**4

    c = (1, 0, 2, 2, 1, 0)
    d = (0, 1, 2, 1, 2, 0)
    # Each three-coordinate coefficient difference has coordinate sum zero.
    assert collision_test(block, c, d, p)

    print("Example 2: coefficientwise trace for two coefficients over F_3")
    print(f"  raw families: {p**6}")
    print(f"  visible rank: {rank}; distinct words: {len(image)}")
    print(f"  kernel size: {len(ker)}")
    print(f"  coordinatewise collision pair: {c} and {d}\n")


def demonstrate_rank_sweep() -> None:
    """Compare raw and exact counts for maps of several ranks over F_2."""
    p, n = 2, 4
    matrices = [
        [[0, 0, 0, 0]],
        [[1, 1, 0, 0]],
        [[1, 0, 1, 0], [0, 1, 0, 1]],
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0]],
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
    ]
    print("Example 3: rank controls cardinality over F_2")
    for matrix in matrices:
        rank = rank_mod(matrix, p)
        count = len(visible_image(matrix, p))
        multiplicity = len(kernel(matrix, p))
        assert count == p**rank and count * multiplicity == p**n
        print(f"  rank {rank}: {count:2d} words, {multiplicity:2d} descriptions per word")


def main() -> None:
    demonstrate_single_map()
    demonstrate_coordinate_family()
    demonstrate_rank_sweep()


if __name__ == "__main__":
    main()
