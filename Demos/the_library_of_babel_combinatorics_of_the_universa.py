#!/usr/bin/env python3
"""Numerical demonstrations for universal finite libraries.

The script uses only Python's standard library.  It demonstrates canonical
base-q addressing, exact finite acceptance probabilities, pattern statistics,
and the constructive distributed-capacity theorem.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import ceil, comb, log10
from typing import Callable, Iterable, Iterator, Sequence

Book = tuple[int, ...]
Checker = Callable[[Book], bool]


def library_size(q: int, n: int) -> int:
    """Return the number q**n of length-n words over q symbols."""
    if q < 0 or n < 0:
        raise ValueError("q and n must be nonnegative")
    return q**n


def encode_book(book: Sequence[int], q: int) -> int:
    """Encode a book as a base-q integer using Horner's rule."""
    if q < 2:
        raise ValueError("q must be at least 2")
    address = 0
    for symbol in book:
        if not 0 <= symbol < q:
            raise ValueError(f"symbol {symbol} is outside 0..{q - 1}")
        address = address * q + symbol
    return address


def decode_address(address: int, q: int, n: int) -> Book:
    """Decode 0 <= address < q**n to exactly n base-q symbols."""
    if q < 2 or n < 0:
        raise ValueError("q must be at least 2 and n nonnegative")
    if not 0 <= address < q**n:
        raise ValueError("address is outside the library")
    digits = [0] * n
    value = address
    for index in range(n - 1, -1, -1):
        value, digits[index] = divmod(value, q)
    return tuple(digits)


def enumerate_books(q: int, n: int) -> Iterator[Book]:
    """Yield every book in canonical address order."""
    if q < 0 or n < 0:
        raise ValueError("q and n must be nonnegative")
    yield from product(range(q), repeat=n)


def exact_acceptance_probability(q: int, n: int, checker: Checker) -> tuple[int, Fraction]:
    """Count accepted books and return the exact uniform probability."""
    total = library_size(q, n)
    if total == 0:
        raise ValueError("uniform probability requires a nonempty library")
    accepted = sum(checker(book) for book in enumerate_books(q, n))
    return accepted, Fraction(accepted, total)


def count_pattern_occurrences(book: Sequence[int], pattern: Sequence[int]) -> int:
    """Count ordinary, possibly overlapping occurrences of pattern in book."""
    k = len(pattern)
    if k == 0:
        return len(book) + 1
    return sum(tuple(book[i : i + k]) == tuple(pattern) for i in range(len(book) - k + 1))


def exact_pattern_probability(q: int, n: int, pattern: Sequence[int]) -> Fraction:
    """Exhaustively compute the probability of at least one pattern occurrence."""
    _, probability = exact_acceptance_probability(
        q, n, lambda book: count_pattern_occurrences(book, pattern) > 0
    )
    return probability


def distributed_placement(total: int, books: int, capacity: int) -> list[tuple[int, int]]:
    """Assign records to (book, slot) pairs exactly when total <= books*capacity."""
    if min(total, books, capacity) < 0:
        raise ValueError("all quantities must be nonnegative")
    if total > books * capacity:
        raise ValueError("insufficient distributed capacity")
    if total == 0:
        return []
    if capacity == 0:
        raise ValueError("positive records require positive capacity")
    return [divmod(record, capacity) for record in range(total)]


def main() -> None:
    print("UNIVERSAL FINITE LIBRARY — NUMERICAL DEMONSTRATIONS\n")

    babel_q, babel_n = 25, 1_312_000
    decimal_digits = int(babel_n * log10(babel_q)) + 1
    print(f"Babel-scale count: 25^1,312,000 has {decimal_digits:,} decimal digits.")

    mini_total = library_size(4, 16)
    print(f"Four-symbol length-16 library: 4^16 = {mini_total:,} books.")
    samples: list[Book] = [(0,) * 16, tuple(range(4)) * 4, (3,) * 16]
    for book in samples:
        address = encode_book(book, 4)
        recovered = decode_address(address, 4, 16)
        assert recovered == book
        print(f"  {book} -> {address:,} -> recovered exactly")

    checker: Checker = lambda book: sum(book) == 4
    accepted, probability = exact_acceptance_probability(2, 8, checker)
    assert accepted == comb(8, 4) == 70
    print("\nBinary length-8 checker: exactly four 1s")
    print(f"  accepted = {accepted}; probability = {probability} = {float(probability):.6f}")

    pattern = (0, 1, 0)
    pattern_probability = exact_pattern_probability(2, 8, pattern)
    opportunities = 8 - len(pattern) + 1
    expected_occurrences = Fraction(opportunities, 2 ** len(pattern))
    union_bound = min(Fraction(1), expected_occurrences)
    print("\nPattern 010 in a random binary word of length 8")
    print(f"  exact probability of at least one occurrence = {pattern_probability}")
    print(f"  expected occurrence count = {expected_occurrences}")
    print(f"  union-bound upper bound = {union_bound}")

    total, capacity = 23, 5
    required_books = ceil(total / capacity)
    placement = distributed_placement(total, required_books, capacity)
    assert len(set(placement)) == total
    print("\nDistributed catalog placement")
    print(f"  {total} records at {capacity} per book require {required_books} books.")
    print(f"  first locations: {placement[:7]}")
    print(f"  final locations: {placement[-3:]}")


if __name__ == "__main__":
    main()
