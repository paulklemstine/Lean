#!/usr/bin/env python3
"""Numerical demonstrations for universal-library counting and cyclic indexes."""

from __future__ import annotations

from itertools import product
from math import floor, log10
from typing import Iterable, Sequence


Word = tuple[int, ...]


def library_size(alphabet_size: int, volume_length: int) -> int:
    """Return the number A**L of length-L words over an A-symbol alphabet."""
    if alphabet_size < 0 or volume_length < 0:
        raise ValueError("alphabet_size and volume_length must be nonnegative")
    return alphabet_size**volume_length


def constrained_count(alphabet_size: int, volume_length: int, fixed_positions: int) -> int:
    """Count volumes after symbols at distinct positions have been prescribed."""
    if alphabet_size < 0 or not 0 <= fixed_positions <= volume_length:
        raise ValueError("require A >= 0 and 0 <= fixed_positions <= volume_length")
    return alphabet_size ** (volume_length - fixed_positions)


def union_probability_bound(alphabet_size: int, volume_length: int, pattern_length: int) -> float:
    """Return min(1, (L-m+1)/A**m), the passage-occurrence union bound."""
    if alphabet_size <= 0 or not 0 <= pattern_length <= volume_length:
        raise ValueError("require A > 0 and 0 <= pattern_length <= volume_length")
    return min(1.0, (volume_length - pattern_length + 1) / alphabet_size**pattern_length)


def contains_pattern(word: Sequence[int], pattern: Sequence[int]) -> bool:
    """Test whether pattern occurs contiguously in word."""
    m = len(pattern)
    return any(tuple(word[i : i + m]) == tuple(pattern) for i in range(len(word) - m + 1))


def exact_occurrence_count(alphabet_size: int, volume_length: int, pattern: Sequence[int]) -> int:
    """Enumerate a small library and count volumes containing pattern."""
    if alphabet_size <= 0 or len(pattern) > volume_length:
        raise ValueError("require A > 0 and pattern length <= volume length")
    if any(not 0 <= symbol < alphabet_size for symbol in pattern):
        raise ValueError("pattern symbol outside alphabet")
    return sum(
        contains_pattern(word, pattern)
        for word in product(range(alphabet_size), repeat=volume_length)
    )


def exact_occurrence_probability(
    alphabet_size: int, volume_length: int, pattern: Sequence[int]
) -> float:
    """Return the exact probability by exhaustive enumeration for small inputs."""
    return exact_occurrence_count(alphabet_size, volume_length, pattern) / library_size(
        alphabet_size, volume_length
    )


def cyclic_windows(cycle: Sequence[int], order: int) -> list[Word]:
    """Return all cyclic windows of the requested order."""
    if not cycle or order <= 0:
        raise ValueError("cycle must be nonempty and order must be positive")
    n = len(cycle)
    return [tuple(cycle[(i + j) % n] for j in range(order)) for i in range(n)]


def verify_complete_cyclic_index(cycle: Sequence[int], alphabet_size: int, order: int) -> bool:
    """Check that cyclic windows equal all A**k words, each exactly once."""
    windows = cyclic_windows(cycle, order)
    expected = set(product(range(alphabet_size), repeat=order))
    return len(windows) == len(expected) and len(set(windows)) == len(windows) and set(windows) == expected


def de_bruijn_sequence(alphabet_size: int, order: int) -> list[int]:
    """Construct a de Bruijn cycle B(A, order) using the classical FKM recursion."""
    if alphabet_size <= 0 or order <= 0:
        raise ValueError("alphabet_size and order must be positive")
    work = [0] * (alphabet_size * order + 1)
    sequence: list[int] = []

    def generate(t: int, period: int) -> None:
        if t > order:
            if order % period == 0:
                sequence.extend(work[1 : period + 1])
            return
        work[t] = work[t - period]
        generate(t + 1, period)
        for symbol in range(work[t - period] + 1, alphabet_size):
            work[t] = symbol
            generate(t + 1, t)

    generate(1, 1)
    return sequence


def format_word(word: Iterable[int]) -> str:
    """Format a short integer word without separators."""
    return "".join(str(x) for x in word)


def main() -> None:
    print("UNIVERSAL LIBRARY COUNTS")
    print(f"Four symbols, length 16: 4^16 = {library_size(4, 16):,}")
    digits = 1 + floor(1_312_000 * log10(25))
    print(f"Babel-scale count 25^1,312,000 has {digits:,} decimal digits.")
    print(f"Fixing 5 positions in a 12-symbol four-letter volume leaves {constrained_count(4, 12, 5):,} volumes.")

    print("\nEXACT OCCURRENCE VERSUS UNION BOUND")
    pattern = (1, 1)
    exact_count = exact_occurrence_count(2, 3, pattern)
    exact_probability = exact_count / library_size(2, 3)
    bound = union_probability_bound(2, 3, len(pattern))
    print(f"Binary length-3 volumes containing 11: {exact_count}/8 = {exact_probability:.3f}")
    print(f"Union bound: {bound:.3f}; the gap comes from the overlapping word 111.")
    for m in (4, 8, 16):
        babel_bound = union_probability_bound(25, 1_312_000, m)
        print(f"Babel-scale bound for a fixed passage of length {m:2d}: {babel_bound:.6e}")

    print("\nFOUR-SYMBOL CYCLIC INDEX")
    mini = [0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3]
    windows = cyclic_windows(mini, 2)
    print("Cycle:", format_word(mini))
    print("Windows:", ", ".join(format_word(window) for window in windows))
    print("Complete and collision-free:", verify_complete_cyclic_index(mini, 4, 2))

    generated = de_bruijn_sequence(4, 2)
    print("An algorithmically generated order-two cycle:", format_word(generated))
    print("Generated cycle is complete:", verify_complete_cyclic_index(generated, 4, 2))


if __name__ == "__main__":
    main()
