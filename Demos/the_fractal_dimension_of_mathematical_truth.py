#!/usr/bin/env python3
"""Numerical demonstrations for the golden-mean truth language.

The admissible binary words contain no adjacent pair ``11``.  This script
checks exact Fibonacci counts by enumeration, verifies the elementary growth
bounds, displays density contraction, and approximates log_2(phi).
"""

from __future__ import annotations

from math import floor, log2, sqrt
from typing import Iterable, Iterator


def fibonacci(n: int) -> int:
    """Return F_n with F_0 = 0 and F_1 = 1 in O(n) integer additions."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def admissible(word: str) -> bool:
    """Return whether a binary word avoids two consecutive ones."""
    if any(bit not in "01" for bit in word):
        raise ValueError("word must contain only '0' and '1'")
    return "11" not in word


def truth_words(n: int) -> list[str]:
    """Generate all admissible words of length n via 0W_(n-1) union 10W_(n-2)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    words: list[list[str]] = [[""], ["0", "1"]]
    if n <= 1:
        return words[n]
    for length in range(2, n + 1):
        next_words = ["0" + w for w in words[length - 1]]
        next_words.extend("10" + w for w in words[length - 2])
        words.append(next_words)
    return words[n]


def count_truth_words(n: int) -> int:
    """Count admissible length-n words in O(n) arithmetic steps and O(1) registers."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return 1
    previous, current = 1, 2
    for _ in range(1, n):
        previous, current = current, previous + current
    return current


def zero_extension(word: str, extra: int = 16) -> str:
    """Exhibit a finite prefix of an infinite admissible extension by appending zeros."""
    if not admissible(word):
        raise ValueError("the prefix is not admissible")
    if extra < 0:
        raise ValueError("extra must be nonnegative")
    return word + "0" * extra


def dimension_estimate(n: int) -> float:
    """Return log_2(|W_n|)/n for n > 0."""
    if n <= 0:
        raise ValueError("n must be positive")
    return log2(count_truth_words(n)) / n


def ratio_estimate(n: int) -> float:
    """Return log_2(|W_(n+1)|/|W_n|), a fast dimension estimator."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return log2(count_truth_words(n + 1) / count_truth_words(n))


def rows(max_n: int) -> Iterator[tuple[int, int, int, int, float, float]]:
    """Yield n, count, lower bound, full count, density, and dimension estimate."""
    for n in range(max_n + 1):
        count = count_truth_words(n)
        estimate = 0.0 if n == 0 else log2(count) / n
        yield n, count, 2 ** floor(n / 2), 2**n, count / (2**n), estimate


def verify_results(max_n: int = 24) -> None:
    """Check the exact count and all finite inequalities through max_n."""
    for n in range(max_n + 1):
        count = count_truth_words(n)
        assert count == fibonacci(n + 2)
        if n <= 16:
            generated = truth_words(n)
            assert len(generated) == count
            assert len(set(generated)) == count
            assert all(len(word) == n and admissible(word) for word in generated)
            assert all(admissible(zero_extension(word)) for word in generated)
        assert 2 ** floor(n / 2) <= count <= 2**n
        if n >= 2:
            assert count < 2**n
        assert count_truth_words(n + 2) <= 3 * count


def print_table(max_n: int = 20) -> None:
    """Print a numerical summary of growth, rarity, and dimension convergence."""
    header = (
        f"{'n':>3} {'|W_n|':>12} {'2^floor(n/2)':>14} "
        f"{'2^n':>12} {'density':>12} {'D_n':>11}"
    )
    print(header)
    print("-" * len(header))
    for n, count, lower, full, density, estimate in rows(max_n):
        print(
            f"{n:3d} {count:12d} {lower:14d} {full:12d} "
            f"{density:12.8f} {estimate:11.8f}"
        )


def main() -> None:
    """Run all demonstrations."""
    verify_results()
    print("Admissible words at depth 4:")
    print(", ".join(truth_words(4)))
    print()
    print_table()
    phi = (1.0 + sqrt(5.0)) / 2.0
    target = log2(phi)
    print(f"\nTarget dimension log_2(phi): {target:.12f}")
    for n in (5, 10, 20, 40, 80):
        print(
            f"n={n:2d}: direct={dimension_estimate(n):.12f}, "
            f"ratio={ratio_estimate(n):.12f}"
        )
    print("\nAll exact finite checks passed.")


if __name__ == "__main__":
    main()
