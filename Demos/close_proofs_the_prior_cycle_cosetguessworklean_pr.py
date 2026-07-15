#!/usr/bin/env python3
"""Numerical demonstrations of mixed-radix uniqueness and Fibonacci primitive parts."""

from __future__ import annotations

from dataclasses import dataclass
from math import factorial, gcd, isqrt, prod
from typing import Iterable, Sequence


def mixed_radix_encode(digits: Sequence[int], bases: Sequence[int]) -> int:
    """Return the value of valid low-to-high mixed-radix digits."""
    if len(digits) != len(bases):
        raise ValueError("digits and bases must have the same length")
    value = 0
    weight = 1
    for digit, base in zip(digits, bases):
        if base < 1 or not 0 <= digit < base:
            raise ValueError("each digit must satisfy 0 <= digit < base")
        value += digit * weight
        weight *= base
    return value


def mixed_radix_decode(value: int, bases: Sequence[int]) -> list[int]:
    """Decode 0 <= value < product(bases) into low-to-high digits."""
    if value < 0 or any(base < 2 for base in bases):
        raise ValueError("value must be nonnegative and every base at least 2")
    capacity = prod(bases)
    if value >= capacity:
        raise ValueError("value does not fit in the requested number of places")
    digits: list[int] = []
    quotient = value
    for base in bases:
        digits.append(quotient % base)
        quotient //= base
    assert quotient == 0
    return digits


def factorial_digits(value: int) -> list[int]:
    """Return factorial digits in low-to-high order, including the forced 0! digit."""
    if value < 0:
        raise ValueError("value must be nonnegative")
    digits = [0]
    quotient = value
    base = 2
    while quotient:
        digits.append(quotient % base)
        quotient //= base
        base += 1
    return digits


def factorial_value(digits: Sequence[int]) -> int:
    """Evaluate low-to-high factorial digits after checking 0 <= c_i <= i."""
    if any(not 0 <= digit <= i for i, digit in enumerate(digits)):
        raise ValueError("factorial digit c_i must satisfy 0 <= c_i <= i")
    return sum(digit * factorial(i) for i, digit in enumerate(digits))


def fibonacci(n: int) -> int:
    """Compute F_n exactly by fast doubling."""
    if n < 0:
        raise ValueError("n must be nonnegative")

    def pair(k: int) -> tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = pair(k // 2)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k % 2 else (c, d)

    return pair(n)[0]


def proper_divisors(n: int) -> list[int]:
    """List the positive proper divisors of n in increasing order."""
    if n <= 1:
        return []
    divisors = {1}
    for d in range(2, isqrt(n) + 1):
        if n % d == 0:
            divisors.add(d)
            if d * d != n:
                divisors.add(n // d)
    return sorted(d for d in divisors if d < n)


def strip_all(value: int, inherited: int) -> int:
    """Remove every prime-power contribution shared with inherited."""
    if value <= 0:
        raise ValueError("value must be positive")
    while (common := gcd(value, inherited)) > 1:
        value //= common
    return value


def fibonacci_primitive_part(n: int) -> int:
    """Strip F_n against F_d for every positive proper divisor d of n."""
    if n < 3:
        raise ValueError("the primitive-part demonstration expects n >= 3")
    residual = fibonacci(n)
    for d in proper_divisors(n):
        residual = strip_all(residual, fibonacci(d))
    return residual


def smallest_prime_factor(value: int) -> int:
    """Return the smallest prime factor of an integer greater than one."""
    if value <= 1:
        raise ValueError("value must exceed one")
    if value % 2 == 0:
        return 2
    candidate = 3
    while candidate * candidate <= value:
        if value % candidate == 0:
            return candidate
        candidate += 2
    return value


def is_primitive_fibonacci_divisor(prime: int, n: int) -> bool:
    """Directly check that prime first divides the Fibonacci sequence at n."""
    return fibonacci(n) % prime == 0 and all(
        fibonacci(k) % prime != 0 for k in range(1, n)
    )


@dataclass(frozen=True)
class PrimitivePartExample:
    index: int
    fibonacci_number: int
    primitive_part: int
    witness_prime: int


def primitive_part_example(n: int) -> PrimitivePartExample:
    """Construct and validate a primitive-prime witness at index n."""
    residual = fibonacci_primitive_part(n)
    prime = smallest_prime_factor(residual)
    assert is_primitive_fibonacci_divisor(prime, n)
    return PrimitivePartExample(n, fibonacci(n), residual, prime)


def demo_mixed_radix_round_trips() -> None:
    """Show exact encoding and recovery in three heterogeneous base systems."""
    cases = [
        ([2, 1, 4], [3, 5, 7]),
        ([59, 12, 6], [60, 24, 7]),
        ([1, 0, 3, 2], [2, 3, 4, 5]),
    ]
    print("Mixed-radix round trips")
    for digits, bases in cases:
        value = mixed_radix_encode(digits, bases)
        recovered = mixed_radix_decode(value, bases)
        assert recovered == digits
        print(f"  bases={bases}, digits={digits}, value={value}, recovered={recovered}")


def demo_factorial_bridge() -> None:
    """Display factorial digits and the matching running-product evaluation."""
    print("\nFactorial / mixed-radix bridge")
    for value in (42, 463, 2026):
        digits = factorial_digits(value)
        reconstructed = factorial_value(digits)
        bases = list(range(1, len(digits) + 1))
        bridged = mixed_radix_encode(digits, bases)
        assert reconstructed == bridged == value
        print(f"  {value} -> low-to-high digits {digits} -> {reconstructed}")


def demo_fibonacci_primitive_parts() -> None:
    """Extract and directly validate primitive prime witnesses at sample indices."""
    print("\nFibonacci primitive parts")
    for n in (13, 14, 18, 24, 30, 48):
        example = primitive_part_example(n)
        print(
            f"  n={n:2d}, F_n={example.fibonacci_number}, "
            f"primitive part={example.primitive_part}, "
            f"witness prime={example.witness_prime}"
        )


if __name__ == "__main__":
    demo_mixed_radix_round_trips()
    demo_factorial_bridge()
    demo_fibonacci_primitive_parts()
