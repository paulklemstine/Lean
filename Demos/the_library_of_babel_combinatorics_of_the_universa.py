#!/usr/bin/env python3
"""Numerical demonstrations for universal finite libraries.

The program uses exact integer and rational arithmetic.  It demonstrates
cardinality, base-q ranking, exhaustive checker probabilities, a de Bruijn
cycle for the four-symbol order-four case, and distributed catalog capacity.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import ceil, log10
from typing import Callable, Iterable, Sequence, TypeVar

Word = tuple[int, ...]
T = TypeVar("T")


def library_size(q: int, n: int) -> int:
    """Return the exact number q**n of length-n words."""
    if q < 0 or n < 0:
        raise ValueError("q and n must be nonnegative")
    return q**n


def rank_word(word: Sequence[int], q: int) -> int:
    """Interpret a word as a fixed-length base-q numeral."""
    if q < 1:
        raise ValueError("q must be positive")
    rank = 0
    for digit in word:
        if not 0 <= digit < q:
            raise ValueError(f"digit {digit} is outside 0,...,{q - 1}")
        rank = q * rank + digit
    return rank


def unrank_word(rank: int, q: int, n: int) -> Word:
    """Recover the unique length-n base-q word with the supplied rank."""
    if q < 1 or n < 0 or not 0 <= rank < q**n:
        raise ValueError("rank or dimensions are out of range")
    digits = [0] * n
    value = rank
    for position in range(n - 1, -1, -1):
        value, digits[position] = divmod(value, q)
    return tuple(digits)


def all_words(q: int, n: int) -> Iterable[Word]:
    """Stream all length-n words in lexicographic order."""
    if q < 0 or n < 0:
        raise ValueError("q and n must be nonnegative")
    return product(range(q), repeat=n)


def exact_checker_probability(
    q: int, n: int, accepts: Callable[[Word], bool]
) -> Fraction:
    """Exhaustively compute |accepted words| / q**n for a small library."""
    total = library_size(q, n)
    if total == 0:
        raise ValueError("uniform probability requires a nonempty library")
    accepted = sum(1 for word in all_words(q, n) if accepts(word))
    return Fraction(accepted, total)


def de_bruijn_sequence(q: int, n: int) -> list[int]:
    """Construct a q-ary de Bruijn cycle using the FKM recursion."""
    if q < 1 or n < 1:
        raise ValueError("q and n must be positive")
    work = [0] * (q * n + 1)
    sequence: list[int] = []

    def visit(t: int, period: int) -> None:
        if t > n:
            if n % period == 0:
                sequence.extend(work[1 : period + 1])
            return
        work[t] = work[t - period]
        visit(t + 1, period)
        for symbol in range(work[t - period] + 1, q):
            work[t] = symbol
            visit(t + 1, t)

    visit(1, 1)
    return sequence


def cyclic_windows(sequence: Sequence[int], n: int) -> set[Word]:
    """Return all cyclic windows of a given positive length."""
    if not sequence or n < 1:
        raise ValueError("sequence must be nonempty and n positive")
    length = len(sequence)
    return {
        tuple(sequence[(start + offset) % length] for offset in range(n))
        for start in range(length)
    }


def distributed_capacity(q: int, n: int, blocks: int) -> int:
    """Return the exact number q**(n*blocks) of distributed storage states."""
    if q < 0 or n < 0 or blocks < 0:
        raise ValueError("parameters must be nonnegative")
    return q ** (n * blocks)


def minimum_blocks_for_objects(q: int, n: int, object_count: int) -> int:
    """Find the least N with object_count <= q**(n*N)."""
    if q < 2 or n < 1 or object_count < 1:
        raise ValueError("require q >= 2, n >= 1, and a nonempty object class")
    blocks = 0
    capacity = 1
    block_states = q**n
    while capacity < object_count:
        capacity *= block_states
        blocks += 1
    return blocks


def demonstrate() -> None:
    """Print reproducible checks of the principal finite results."""
    print("UNIVERSAL FINITE LIBRARY — NUMERICAL DEMONSTRATION\n")

    borges_digits = ceil(1_312_000 * log10(25))
    print("1. Borges-scale cardinality")
    print("   Exact count: 25^1,312,000")
    print(f"   Decimal digits: {borges_digits:,}\n")

    q, n = 4, 16
    size = library_size(q, n)
    print("2. Four-symbol, length-sixteen mini-library")
    print(f"   4^16 = {size:,} = 2^32")
    sample = (0, 1, 2, 3) * 4
    rank = rank_word(sample, q)
    recovered = unrank_word(rank, q, n)
    print(f"   Sample word: {sample}")
    print(f"   32-bit rank: {rank:,}")
    print(f"   Rank/unrank round trip: {recovered == sample}\n")

    print("3. Exact checker probability in a tractable library")
    # Accept words whose digit sum is divisible by three.
    probability = exact_checker_probability(4, 6, lambda w: sum(w) % 3 == 0)
    print("   Checker: digit sum is divisible by 3")
    print(f"   Accepted fraction: {probability} ≈ {float(probability):.8f}")
    singleton = Fraction(1, library_size(4, 6))
    print(f"   One exact six-symbol target: {singleton}\n")

    print("4. Cyclic universal-window enumeration")
    cycle = de_bruijn_sequence(4, 4)
    windows = cyclic_windows(cycle, 4)
    print(f"   Cycle length: {len(cycle)} (expected 4^4 = 256)")
    print(f"   Distinct cyclic length-4 windows: {len(windows)}")
    print(f"   Contains every possible window: {len(windows) == 4**4}")
    print("   First 48 cyclic symbols:", "".join(map(str, cycle[:48])), "\n")

    print("5. Complete address-table capacity")
    small_q, small_n = 2, 3
    books = library_size(small_q, small_n)
    table_count = books**books
    print(f"   A binary length-3 library has M = {books} books.")
    print(f"   It has M^M = {table_count:,} possible address tables.")
    for blocks in (1, books - 1, books):
        capacity = distributed_capacity(small_q, small_n, blocks)
        relation = "enough" if capacity >= table_count else "too small"
        print(f"   {blocks} block(s): {capacity:,} states — {relation}")
    required = minimum_blocks_for_objects(small_q, small_n, table_count)
    print(f"   Exact minimum: {required} blocks = M blocks")


if __name__ == "__main__":
    demonstrate()
