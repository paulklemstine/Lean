#!/usr/bin/env python3
"""Numerical demonstrations for the finite Library of Babel.

The script uses only Python's standard library. It demonstrates exact library
cardinality, Hamming geometry, the distinction between edit paths and topology,
and finite incompressibility bounds without enumerating enormous libraries.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Iterable, Iterator, Sequence, TypeVar

Symbol = TypeVar("Symbol")
Book = tuple[Symbol, ...]


@dataclass(frozen=True)
class IncompressibilityBound:
    """Exact finite counting bound for a description language."""

    total_books: int
    descriptions: int
    guaranteed_undescribed: int
    guaranteed_fraction: Fraction


def library_size(alphabet_size: int, length: int) -> int:
    """Return the exact number A**L of length-L books on A symbols."""
    if alphabet_size < 0 or length < 0:
        raise ValueError("alphabet_size and length must be nonnegative")
    return alphabet_size**length


def hamming_distance(left: Sequence[Symbol], right: Sequence[Symbol]) -> int:
    """Count positions at which two equal-length books differ in O(L) time."""
    if len(left) != len(right):
        raise ValueError("Hamming distance requires equal lengths")
    return sum(a != b for a, b in zip(left, right))


def shortest_edit_path(
    start: Sequence[Symbol], target: Sequence[Symbol]
) -> list[tuple[Symbol, ...]]:
    """Construct a shortest path of single-symbol edits from start to target."""
    if len(start) != len(target):
        raise ValueError("books must have equal lengths")
    current = list(start)
    path = [tuple(current)]
    for index, symbol in enumerate(target):
        if current[index] != symbol:
            current[index] = symbol
            path.append(tuple(current))
    return path


def open_hamming_ball(
    center: Sequence[Symbol], universe: Iterable[Sequence[Symbol]], radius: float
) -> list[tuple[Symbol, ...]]:
    """Enumerate a finite open Hamming ball for a supplied small universe."""
    if radius <= 0:
        return []
    return [
        tuple(book)
        for book in universe
        if hamming_distance(center, book) < radius
    ]


def enumerate_books(alphabet: Sequence[Symbol], length: int) -> Iterator[Book[Symbol]]:
    """Enumerate a small finite library; runtime and output size are A**L."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    yield from product(alphabet, repeat=length)


def incompressibility_bound(
    alphabet_size: int, length: int, descriptions: int
) -> IncompressibilityBound:
    """Compute the guaranteed number and fraction outside any decoder range."""
    if descriptions < 0:
        raise ValueError("descriptions must be nonnegative")
    total = library_size(alphabet_size, length)
    undescribed = max(0, total - descriptions)
    fraction = Fraction(undescribed, total) if total else Fraction(0, 1)
    return IncompressibilityBound(total, descriptions, undescribed, fraction)


def binary_program_bound(book_length: int, program_length: int) -> IncompressibilityBound:
    """Specialize the counting bound to L-bit books and k-bit programs."""
    if program_length < 0:
        raise ValueError("program_length must be nonnegative")
    return incompressibility_bound(2, book_length, 2**program_length)


def demonstrate() -> None:
    """Print reproducible examples of all central numerical results."""
    print("FINITE LIBRARY CARDINALITY")
    for alphabet_size, length in [(2, 10), (3, 8), (25, 410)]:
        size = library_size(alphabet_size, length)
        print(f"A={alphabet_size}, L={length}: A^L has {len(str(size))} decimal digits")
        if size < 10**20:
            print(f"  exact size = {size:,}")

    print("\nHAMMING GEOMETRY")
    start = tuple("00101101")
    target = tuple("01100111")
    distance = hamming_distance(start, target)
    path = shortest_edit_path(start, target)
    print(f"start={''.join(start)}, target={''.join(target)}")
    print(f"distance={distance}; shortest path has {len(path) - 1} edits")
    print(" -> ".join("".join(book) for book in path))

    small_library = list(enumerate_books((0, 1), 4))
    ball = open_hamming_ball((0, 0, 0, 0), small_library, 0.5)
    print(f"Open radius-1/2 ball around 0000: {ball}")
    assert ball == [(0, 0, 0, 0)]

    print("\nBINARY INCOMPRESSIBILITY")
    bound = binary_program_bound(book_length=20, program_length=12)
    print(f"total books: {bound.total_books:,}")
    print(f"12-bit descriptions: {bound.descriptions:,}")
    print(f"guaranteed undescribed: {bound.guaranteed_undescribed:,}")
    print(
        "guaranteed fraction: "
        f"{bound.guaranteed_fraction} = {float(bound.guaranteed_fraction):.8f}"
    )

    print("\nCOMPRESSION SAVINGS TABLE")
    print("saved bits | guaranteed incompressible fraction")
    for saved_bits in (1, 2, 4, 8, 10, 20):
        fraction = Fraction(2**saved_bits - 1, 2**saved_bits)
        print(f"{saved_bits:10d} | {fraction!s:>12} = {float(fraction):.9f}")


if __name__ == "__main__":
    demonstrate()
