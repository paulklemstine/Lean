#!/usr/bin/env python3
"""Numerical demonstrations of canonical mixed-radix digit streams.

The module uses only the Python standard library.  Digits are ordered from the
least significant position upward.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import factorial
from typing import Iterable, Sequence


@dataclass(frozen=True)
class ExtractionRow:
    """One row of a running-product extraction trace."""

    position: int
    base: int
    place_value: int
    digit: int
    contribution: int


def running_products(bases: Sequence[int]) -> list[int]:
    """Return P_0,...,P_k for nonnegative local bases b_0,...,b_{k-1}."""
    if any(base < 0 for base in bases):
        raise ValueError("bases must be nonnegative")
    products = [1]
    for base in bases:
        products.append(products[-1] * base)
    return products


def extract_digits(n: int, bases: Sequence[int]) -> list[int]:
    """Compute D_i(n) = floor(n/P_i) mod b_i.

    Python has no intended arithmetic convention for a zero modulus, so the
    natural-number conventions n % 0 = n and n // 0 = 0 are implemented
    explicitly.  Once a running product is zero, division by it contributes 0.
    """
    if n < 0:
        raise ValueError("n must be nonnegative")
    products = running_products(bases)
    digits: list[int] = []
    for i, base in enumerate(bases):
        quotient = 0 if products[i] == 0 else n // products[i]
        digits.append(quotient if base == 0 else quotient % base)
    return digits


def evaluate(digits: Sequence[int], bases: Sequence[int]) -> int:
    """Evaluate a low-to-high mixed-radix digit sequence."""
    if len(digits) > len(bases):
        raise ValueError("one base is required for every digit")
    if any(digit < 0 for digit in digits):
        raise ValueError("digits must be nonnegative")
    products = running_products(bases)
    return sum(digit * products[i] for i, digit in enumerate(digits))


def is_valid(digits: Sequence[int], bases: Sequence[int]) -> bool:
    """Test all local inequalities 0 <= digit_i < base_i."""
    return len(digits) <= len(bases) and all(
        0 <= digit < bases[i] for i, digit in enumerate(digits)
    )


def extraction_trace(n: int, bases: Sequence[int]) -> list[ExtractionRow]:
    """Return a table exposing each extracted digit and contribution."""
    products = running_products(bases)
    digits = extract_digits(n, bases)
    return [
        ExtractionRow(i, bases[i], products[i], digit, digit * products[i])
        for i, digit in enumerate(digits)
    ]


def carry_free_add(
    left: Sequence[int], right: Sequence[int], bases: Sequence[int]
) -> list[int] | None:
    """Return the pointwise sum exactly when no position requires a carry."""
    if not (len(left) == len(right) <= len(bases)):
        raise ValueError("digit arrays must have equal supported lengths")
    sums = [a + b for a, b in zip(left, right)]
    return sums if is_valid(sums, bases) else None


def normalize_coefficients(
    coefficients: Sequence[int], bases: Sequence[int]
) -> tuple[list[int], int]:
    """Normalize arbitrary nonnegative coefficients and return final overflow.

    All used bases must be positive.  The identity
    evaluate(coefficients) = evaluate(normalized) + overflow * P_k
    is maintained.
    """
    if len(coefficients) > len(bases):
        raise ValueError("one base is required for every coefficient")
    if any(x < 0 for x in coefficients):
        raise ValueError("coefficients must be nonnegative")
    if any(base <= 0 for base in bases[: len(coefficients)]):
        raise ValueError("normalization requires positive bases")
    carry = 0
    normalized: list[int] = []
    for coefficient, base in zip(coefficients, bases):
        total = coefficient + carry
        normalized.append(total % base)
        carry = total // base
    return normalized, carry


def verify_reconstruction(n: int, bases: Sequence[int]) -> bool:
    """Check V_k(D(n)) = n mod P_k with the zero-modulus convention."""
    capacity = running_products(bases)[-1]
    expected = n if capacity == 0 else n % capacity
    return evaluate(extract_digits(n, bases), bases) == expected


def demonstrate_normal_form(n: int, bases: Sequence[int]) -> None:
    """Print extraction, reconstruction, and prefix-stability examples."""
    products = running_products(bases)
    digits = extract_digits(n, bases)
    print(f"Bases: {list(bases)}")
    print(f"Running products: {products}")
    print(f"Number: {n}; digits (low to high): {digits}")
    print(" i | base | P_i | digit | digit*P_i")
    for row in extraction_trace(n, bases):
        print(
            f"{row.position:2d} | {row.base:4d} | {row.place_value:3d} |"
            f" {row.digit:5d} | {row.contribution:9d}"
        )
    for k in range(1, len(bases) + 1):
        capacity = products[k]
        truncated = n if capacity == 0 else n % capacity
        prefix = digits[:k]
        extracted_after_truncation = extract_digits(truncated, bases[:k])
        reconstructed = evaluate(prefix, bases[:k])
        assert extracted_after_truncation == prefix
        assert reconstructed == truncated
        print(
            f"length {k}: prefix={prefix}, residue={truncated}, "
            f"reconstruction={reconstructed}"
        )


def demonstrate_addition() -> None:
    """Print one carry-free sum and one normalized sum with a carry."""
    bases = [10, 6, 4]
    left = [7, 2, 1]
    right = [2, 3, 1]
    direct = carry_free_add(left, right, bases)
    assert direct == [9, 5, 2]
    total = evaluate(left, bases) + evaluate(right, bases)
    assert evaluate(direct, bases) == total
    assert extract_digits(total, bases) == direct
    print("\nCarry-free addition")
    print(f"{left} + {right} = {direct}; numerical value = {total}")

    overflowing_left = [8, 5, 1]
    overflowing_right = [5, 4, 2]
    raw = [a + b for a, b in zip(overflowing_left, overflowing_right)]
    normalized, overflow = normalize_coefficients(raw, bases)
    capacity = running_products(bases)[-1]
    assert evaluate(raw, bases) == evaluate(normalized, bases) + overflow * capacity
    print("\nAddition requiring carries")
    print(f"raw coefficients: {raw}")
    print(f"normalized digits: {normalized}, final overflow: {overflow}")


def demonstrate_factoradic(n: int = 83, length: int = 5) -> None:
    """Show that bases i+1 produce factorial place values i!."""
    bases = [i + 1 for i in range(length)]
    products = running_products(bases)
    assert products == [factorial(i) for i in range(length + 1)]
    digits = extract_digits(n, bases)
    assert evaluate(digits, bases) == n % factorial(length)
    print("\nFactorial specialization")
    print(f"n={n}, bases={bases}, place values={products[:-1]}, digits={digits}")


def exhaustive_check(base_families: Iterable[Sequence[int]], limit: int = 500) -> None:
    """Exhaustively check reconstruction and stable prefixes on small examples."""
    checks = 0
    for bases in base_families:
        products = running_products(bases)
        for n in range(limit):
            assert verify_reconstruction(n, bases)
            full = extract_digits(n, bases)
            for k in range(1, len(bases) + 1):
                modulus = products[k]
                truncated = n if modulus == 0 else n % modulus
                assert extract_digits(truncated, bases[:k]) == full[:k]
                checks += 1
    print(f"\nExhaustive reconstruction and stability checks passed: {checks}")


def main() -> None:
    """Run all demonstrations."""
    demonstrate_normal_form(731, [10, 6, 4, 5])
    demonstrate_addition()
    demonstrate_factoradic()
    exhaustive_check(([2, 3, 5], [10, 6, 4, 5], [1, 2, 3, 4, 5], [3, 0, 7]))


if __name__ == "__main__":
    main()
