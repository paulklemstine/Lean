#!/usr/bin/env python3
"""Numerical demonstrations for factorial codes and the stage-four CRT obstruction."""

from __future__ import annotations

from itertools import product
from math import factorial, gcd, lcm
from typing import Sequence


def factoradic_digits(n: int, length: int) -> list[int]:
    """Return the unique low-to-high factorial digits of n at a fixed length."""
    if length < 0 or n < 0 or n >= factorial(length):
        raise ValueError("require length >= 0 and 0 <= n < length!")
    digits: list[int] = []
    quotient = n
    for i in range(length):
        quotient, digit = divmod(quotient, i + 1)
        digits.append(digit)
    assert quotient == 0
    return digits


def factoradic_value(digits: Sequence[int]) -> int:
    """Evaluate low-to-high factorial digits, checking their bounds."""
    if any(d < 0 or d > i for i, d in enumerate(digits)):
        raise ValueError("digit i must satisfy 0 <= digit <= i")
    return sum(d * factorial(i) for i, d in enumerate(digits))


def normalize_factorial_digits(raw: Sequence[int]) -> list[int]:
    """Normalize nonnegative low-to-high coefficients by upward carries."""
    if any(d < 0 for d in raw):
        raise ValueError("coefficients must be nonnegative")
    digits = list(raw) or [0]
    i = 0
    while i < len(digits):
        carry, digits[i] = divmod(digits[i], i + 1)
        if carry:
            if i + 1 == len(digits):
                digits.append(0)
            digits[i + 1] += carry
        i += 1
    while len(digits) > 1 and digits[-1] == 0:
        digits.pop()
    return digits


def all_factoradic_values(length: int) -> list[int]:
    """Enumerate values of all valid codes of the requested length."""
    ranges = [range(i + 1) for i in range(length)]
    return [factoradic_value(code) for code in product(*ranges)]


def crt_pair_mod_6(n: int) -> tuple[int, int]:
    """Return the canonical stage-three CRT coordinates."""
    return n % 2, n % 3


def crt_reconstruct_mod_6(pair: tuple[int, int]) -> int:
    """Reconstruct modulo 6 from residues modulo 2 and 3."""
    a, b = pair
    if not (0 <= a < 2 and 0 <= b < 3):
        raise ValueError("invalid residues")
    return (3 * a + 4 * b) % 6


def additive_order_mod(n: int, modulus: int) -> int:
    """Return the additive order of n modulo modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return modulus // gcd(n, modulus)


def additive_order_product(values: Sequence[int], moduli: Sequence[int]) -> int:
    """Return the additive order of an element in a residue-ring product."""
    if len(values) != len(moduli):
        raise ValueError("values and moduli must have equal lengths")
    orders = [additive_order_mod(v % m, m) for v, m in zip(values, moduli)]
    return lcm(*orders) if orders else 1


def stage_four_annihilator_check() -> bool:
    """Check that 12 annihilates all 24 triples modulo 2, 3, and 4."""
    return all(
        all((12 * x) % m == 0 for x, m in zip(xs, (2, 3, 4)))
        for xs in product(range(2), range(3), range(4))
    )


def demonstrate() -> None:
    """Print and assert the finite examples supporting the principal results."""
    values = sorted(all_factoradic_values(4))
    assert values == list(range(24))
    print("Length-four factorial codes cover exactly:", values)

    print("\nSelected factoradic expansions (high-to-low):")
    for n in (0, 5, 11, 12, 17, 23):
        digits = factoradic_digits(n, 4)
        assert factoradic_value(digits) == n
        print(f"  {n:2d} -> {tuple(reversed(digits))}")

    before = [0, 2, 4, 1]
    before_value = sum(d * factorial(i) for i, d in enumerate(before))
    normalized = normalize_factorial_digits(before)
    assert factoradic_value(normalized) == before_value
    print(f"\nCarry normalization: {before} -> {normalized}, value {before_value}")

    pairs = [crt_pair_mod_6(n) for n in range(6)]
    assert len(set(pairs)) == 6
    assert all(crt_reconstruct_mod_6(pair) == n for n, pair in enumerate(pairs))
    print("\nStage-three CRT coordinates:", dict(enumerate(pairs)))

    assert stage_four_annihilator_check()
    target_max_order = max(
        additive_order_product(xs, (2, 3, 4))
        for xs in product(range(2), range(3), range(4))
    )
    source_order = additive_order_mod(1, 24)
    assert target_max_order == 12 and source_order == 24
    print("\nStage-four additive exponents:")
    print("  maximum target element order =", target_max_order)
    print("  order of 1 modulo 24        =", source_order)
    print("  12 * 1 modulo 24            =", 12 % 24)
    print("Therefore the two additive groups cannot be isomorphic.")


if __name__ == "__main__":
    demonstrate()
