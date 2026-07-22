#!/usr/bin/env python3
"""Numerical demonstrations of negabinary, Fibonacci, and base-(i-1) numeration."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List, Sequence, Tuple


BitList = List[int]  # least-significant digit first
Gaussian = Tuple[int, int]  # (real, imaginary)


def evaluate_negabinary(bits: Sequence[int]) -> int:
    """Evaluate least-significant-first binary digits in base -2."""
    value = 0
    power = 1
    for bit in bits:
        if bit not in (0, 1):
            raise ValueError("digits must be 0 or 1")
        value += bit * power
        power *= -2
    return value


def to_negabinary(n: int) -> BitList:
    """Return the canonical least-significant-first base -2 expansion of n."""
    bits: BitList = []
    while n != 0:
        remainder = n % 2
        bits.append(remainder)
        n = (remainder - n) // 2
    return bits


def fibonacci_numbers_through(n: int) -> List[int]:
    """Return F_0,...,F_k with F_k <= n < F_(k+1), retaining F_2=1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    fibs = [0, 1]
    while fibs[-1] <= n:
        fibs.append(fibs[-1] + fibs[-2])
    return fibs[:-1] if fibs[-1] > n else fibs


def zeckendorf_indices(n: int) -> List[int]:
    """Return decreasing Fibonacci indices in the unique nonconsecutive sum for n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return []
    fibs = fibonacci_numbers_through(n)
    indices: List[int] = []
    remainder = n
    for index in range(len(fibs) - 1, 1, -1):
        if fibs[index] <= remainder:
            indices.append(index)
            remainder -= fibs[index]
    if remainder != 0:
        raise AssertionError("greedy Fibonacci decomposition failed")
    return indices


def gaussian_add(z: Gaussian, w: Gaussian) -> Gaussian:
    return (z[0] + w[0], z[1] + w[1])


def gaussian_mul(z: Gaussian, w: Gaussian) -> Gaussian:
    return (z[0] * w[0] - z[1] * w[1], z[0] * w[1] + z[1] * w[0])


def evaluate_complex_base(bits: Sequence[int]) -> Gaussian:
    """Evaluate least-significant-first bits in the Gaussian base i-1."""
    value: Gaussian = (0, 0)
    power: Gaussian = (1, 0)
    beta: Gaussian = (-1, 1)
    for bit in bits:
        if bit not in (0, 1):
            raise ValueError("digits must be 0 or 1")
        if bit:
            value = gaussian_add(value, power)
        power = gaussian_mul(power, beta)
    return value


def complex_digit_and_next(z: Gaussian) -> Tuple[int, Gaussian]:
    """Extract the forced parity digit and quotient for base i-1."""
    x, y = z
    digit = (x + y) % 2
    numerator = x - digit
    return digit, ((y - numerator) // 2, -(numerator + y) // 2)


# Direct terminal words for the exceptional norm-descent points.
EXCEPTIONAL_WORDS: dict[Gaussian, BitList] = {
    (0, 1): [1, 1],
    (0, -1): [1, 1, 1],
    (-1, 0): [1, 0, 1, 1, 1],
    (-2, 1): [1, 1, 1, 1, 1],
    (-2, -1): [1, 1, 0, 1, 0, 1, 1, 1],
}


def to_complex_base(z: Gaussian) -> BitList:
    """Return the canonical base-(i-1) expansion, least significant first."""
    if z == (0, 0):
        return []
    if z in EXCEPTIONAL_WORDS:
        return EXCEPTIONAL_WORDS[z].copy()
    digit, successor = complex_digit_and_next(z)
    return [digit] + to_complex_base(successor)


def displayed(bits: Sequence[int]) -> str:
    """Display a least-significant-first word in conventional order."""
    return "".join(str(bit) for bit in reversed(bits)) or "0"


def run_demo() -> None:
    print("NEGABINARY ROUND TRIPS")
    for n in range(-13, 14):
        bits = to_negabinary(n)
        assert evaluate_negabinary(bits) == n
        print(f"{n:>3} -> {displayed(bits):>8}_(-2)")

    print("\nZECKENDORF EXPANSIONS")
    for n in (1, 10, 42, 100, 2026):
        indices = zeckendorf_indices(n)
        fibs = fibonacci_numbers_through(n)
        terms = [fibs[index] for index in indices]
        assert sum(terms) == n
        assert all(a - b > 1 for a, b in zip(indices, indices[1:]))
        print(f"{n} = {' + '.join(map(str, terms))} (indices {indices})")

    print("\nGAUSSIAN BASE i-1 ROUND TRIPS")
    for z in ((0, 1), (0, -1), (-2, 1), (3, -4), (7, 5), (-6, -3)):
        bits = to_complex_base(z)
        assert evaluate_complex_base(bits) == z
        print(f"{z[0]:+d}{z[1]:+d}i -> {displayed(bits)}_(i-1)")

    # The exact counterexample to unconditional norm descent.
    digit, successor = complex_digit_and_next((0, 1))
    norm = lambda w: w[0] * w[0] + w[1] * w[1]
    assert digit == 1 and successor == (1, 0)
    assert norm((0, 1)) == norm(successor) == 1
    print("\nAt i, extraction gives digit 1 and successor 1: the norm stays 1.")


if __name__ == "__main__":
    run_demo()
