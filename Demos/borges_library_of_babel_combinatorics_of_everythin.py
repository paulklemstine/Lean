#!/usr/bin/env python3
"""Numerical demonstrations for the finite Library of Babel.

The script uses only Python's standard library.  It demonstrates exact library
cardinality, Hamming geometry, Hamming-ball cardinalities, and the finite
counting bound for decoder-relative incompressibility.
"""

from __future__ import annotations

from itertools import product
from math import comb, floor, log10
from typing import Iterable, Sequence, TypeVar

Symbol = TypeVar("Symbol")
Book = tuple[int, ...]


def library_cardinality(alphabet_size: int, length: int) -> int:
    """Return the exact number A**L of length-L books over A symbols."""
    if alphabet_size < 0 or length < 0:
        raise ValueError("alphabet_size and length must be nonnegative")
    return alphabet_size**length


def hamming_distance(left: Sequence[Symbol], right: Sequence[Symbol]) -> int:
    """Count coordinates at which two equally long books differ."""
    if len(left) != len(right):
        raise ValueError("Hamming distance requires equal lengths")
    return sum(x != y for x, y in zip(left, right))


def enumerate_books(alphabet_size: int, length: int) -> list[Book]:
    """Enumerate a small finite library in lexicographic order."""
    if alphabet_size < 0 or length < 0:
        raise ValueError("alphabet_size and length must be nonnegative")
    return list(product(range(alphabet_size), repeat=length))


def hamming_distance_matrix(books: Sequence[Sequence[Symbol]]) -> list[list[int]]:
    """Construct the complete pairwise Hamming-distance matrix."""
    return [[hamming_distance(x, y) for y in books] for x in books]


def hamming_ball_size(alphabet_size: int, length: int, radius: int) -> int:
    """Return sum_{j<=r} binom(L,j)(A-1)^j for a Hamming ball."""
    if alphabet_size < 1 or length < 0 or radius < 0:
        raise ValueError("require alphabet_size >= 1, length >= 0, radius >= 0")
    return sum(
        comb(length, j) * (alphabet_size - 1) ** j
        for j in range(min(radius, length) + 1)
    )


def incompressibility_bound(
    alphabet_size: int, length: int, code_count: int
) -> tuple[int, int, float]:
    """Return total books, guaranteed unnamed books, and unnamed fraction."""
    if code_count < 0:
        raise ValueError("code_count must be nonnegative")
    total = library_cardinality(alphabet_size, length)
    unnamed = max(0, total - code_count)
    fraction = unnamed / total if total else 0.0
    return total, unnamed, fraction


def binary_deficit_bound(length: int, deficit: int) -> tuple[int, int, float]:
    """Apply the exact-(L-c)-bit decoder bound, using truncated subtraction."""
    if length < 0 or deficit < 0:
        raise ValueError("length and deficit must be nonnegative")
    program_length = max(0, length - deficit)
    return incompressibility_bound(2, length, 2**program_length)


def actual_ball_size(
    center: Sequence[int], alphabet_size: int, radius: int
) -> int:
    """Enumerate a small library and count the books in a chosen ball."""
    return sum(
        hamming_distance(center, book) <= radius
        for book in enumerate_books(alphabet_size, len(center))
    )


def format_matrix(matrix: Iterable[Iterable[int]]) -> str:
    """Format a small integer matrix for terminal output."""
    return "\n".join(" ".join(f"{entry:2d}" for entry in row) for row in matrix)


def demonstrate_cardinality_and_deficit() -> None:
    """Print exact finite counts and the exponential deficit proportion."""
    print("=== Cardinality and incompressibility ===")
    a, ell = 25, 1_312_000
    # Avoid materializing the roughly 1.8-million-digit integer merely to count digits.
    decimal_digits = floor(ell * log10(a)) + 1
    print(f"Borges parameters: {a}^{ell:,} has {decimal_digits:,} decimal digits.")

    length, deficit = 20, 5
    total, unnamed, fraction = binary_deficit_bound(length, deficit)
    print(f"Binary books of length {length}: {total:,}")
    print(f"Exact {length - deficit}-bit codes: {2 ** (length - deficit):,}")
    print(f"Guaranteed unnamed books: {unnamed:,}")
    print(f"Guaranteed unnamed fraction: {fraction:.6f} = 1 - 2^-{deficit}")
    assert unnamed == total - 2 ** (length - deficit)


def demonstrate_discrete_geometry() -> None:
    """Display a small distance matrix and check unit separation."""
    print("\n=== Discrete Hamming geometry ===")
    books = enumerate_books(2, 3)
    matrix = hamming_distance_matrix(books)
    print("Books:", ["".join(map(str, book)) for book in books])
    print(format_matrix(matrix))
    off_diagonal = [matrix[i][j] for i in range(8) for j in range(8) if i != j]
    assert min(off_diagonal) == 1
    print("Smallest distance between distinct books: 1")
    print("Therefore every open ball of radius 1/2 is a singleton.")


def demonstrate_hamming_balls() -> None:
    """Compare the closed-form Hamming-ball count with enumeration."""
    print("\n=== Hamming-ball cardinality ===")
    alphabet_size, length, radius = 3, 5, 2
    center = (0,) * length
    formula = hamming_ball_size(alphabet_size, length, radius)
    enumerated = actual_ball_size(center, alphabet_size, radius)
    print(
        f"A={alphabet_size}, L={length}, r={radius}: "
        f"formula={formula}, enumeration={enumerated}"
    )
    print("Shells:")
    for j in range(radius + 1):
        shell = comb(length, j) * (alphabet_size - 1) ** j
        print(f"  distance {j}: C({length},{j})({alphabet_size - 1})^{j} = {shell}")
    assert formula == enumerated


def main() -> None:
    demonstrate_cardinality_and_deficit()
    demonstrate_discrete_geometry()
    demonstrate_hamming_balls()


if __name__ == "__main__":
    main()
