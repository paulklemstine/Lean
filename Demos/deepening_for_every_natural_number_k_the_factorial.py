#!/usr/bin/env python3
"""Numerical demonstrations of factorial codes and permutation ranking.

The module uses the conventional selection form of Lehmer ranking.  Factorial
code digits are stored in ascending order: digits[i] multiplies i! and obeys
0 <= digits[i] <= i.
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from random import Random
from typing import Iterable, Sequence


def validate_code(digits: Sequence[int]) -> None:
    """Raise ValueError unless digits form a bounded factorial code."""
    for i, digit in enumerate(digits):
        if not 0 <= digit <= i:
            raise ValueError(f"digit {i} must lie in [0, {i}], got {digit}")


def code_value(digits: Sequence[int]) -> int:
    """Evaluate ascending factorial digits as sum(digits[i] * i!)."""
    validate_code(digits)
    return sum(digit * factorial(i) for i, digit in enumerate(digits))


def integer_to_factorial_code(rank: int, length: int) -> list[int]:
    """Return the unique length-'length' factorial code of a valid rank."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    if not 0 <= rank < factorial(length):
        raise ValueError(f"rank must lie in [0, {factorial(length)})")
    remainder = rank
    digits: list[int] = []
    for radix in range(1, length + 1):
        remainder, digit = divmod(remainder, radix)
        digits.append(digit)
    assert remainder == 0
    return digits


def code_to_permutation(digits: Sequence[int]) -> tuple[int, ...]:
    """Unrank ascending factorial digits by ordered-pool selection."""
    validate_code(digits)
    pool = list(range(len(digits)))
    output: list[int] = []
    for digit in reversed(digits):
        output.append(pool.pop(digit))
    return tuple(output)


def permutation_to_code(permutation: Sequence[int]) -> list[int]:
    """Rank a permutation and return its ascending factorial digits."""
    length = len(permutation)
    if sorted(permutation) != list(range(length)):
        raise ValueError("input must be a permutation of range(length)")
    pool = list(range(length))
    descending_digits: list[int] = []
    for item in permutation:
        index = pool.index(item)
        descending_digits.append(index)
        pool.pop(index)
    return list(reversed(descending_digits))


def rank_permutation(permutation: Sequence[int]) -> int:
    """Return the unique rank in [0, length!)."""
    return code_value(permutation_to_code(permutation))


def unrank_permutation(rank: int, length: int) -> tuple[int, ...]:
    """Return the unique permutation with the requested factoradic rank."""
    return code_to_permutation(integer_to_factorial_code(rank, length))


def enumerate_rank_table(length: int) -> list[tuple[int, list[int], tuple[int, ...]]]:
    """Build the complete rank/code/permutation table for a small length."""
    return [
        (rank, integer_to_factorial_code(rank, length), unrank_permutation(rank, length))
        for rank in range(factorial(length))
    ]


def verify_complete_classification(max_length: int = 7) -> None:
    """Numerically check range, uniqueness, and round trips through max_length."""
    for length in range(max_length + 1):
        table = enumerate_rank_table(length)
        values = [code_value(code) for _, code, _ in table]
        classified = [permutation for _, _, permutation in table]
        assert values == list(range(factorial(length)))
        assert len(set(classified)) == factorial(length)
        assert set(classified) == set(permutations(range(length)))
        for rank, code, permutation in table:
            assert rank_permutation(permutation) == rank
            assert permutation_to_code(permutation) == code


def demonstrate_rank_seventeen() -> None:
    """Print the full conversion of rank 17 at length four."""
    rank, length = 17, 4
    code = integer_to_factorial_code(rank, length)
    permutation = code_to_permutation(code)
    print("Example: rank 17 among permutations of four symbols")
    print(f"  ascending factorial code: {code}")
    print(f"  weighted value:           {code_value(code)}")
    print(f"  classified permutation:   {permutation}")
    print(f"  recovered rank:           {rank_permutation(permutation)}")


def demonstrate_small_counts() -> None:
    """Print matching counts of ranks and distinct classified permutations."""
    print("\nCounts of factorial codes and classified permutations")
    print("  k   k!   distinct outputs")
    for length in range(0, 7):
        outputs = {unrank_permutation(rank, length) for rank in range(factorial(length))}
        print(f"  {length:<2}  {factorial(length):<4} {len(outputs)}")


def demonstrate_uniform_sampling(length: int = 5, trials: int = 12_000) -> None:
    """Sample uniform ranks and summarize the first-symbol frequencies."""
    rng = Random(20260715)
    counts = [0] * length
    for _ in range(trials):
        rank = rng.randrange(factorial(length))
        permutation = unrank_permutation(rank, length)
        counts[permutation[0]] += 1
    expected = trials / length
    print(f"\nUniform-rank sampling ({trials} trials, k={length})")
    for symbol, count in enumerate(counts):
        print(f"  first symbol {symbol}: {count:5d} (expected about {expected:.0f})")


def main() -> None:
    """Run exhaustive checks and three readable demonstrations."""
    verify_complete_classification()
    print("Exhaustive round-trip checks passed for lengths 0 through 7.\n")
    demonstrate_rank_seventeen()
    demonstrate_small_counts()
    demonstrate_uniform_sampling()


if __name__ == "__main__":
    main()
