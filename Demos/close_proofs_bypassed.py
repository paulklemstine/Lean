#!/usr/bin/env python3
"""Numerical demonstrations for primitive Fibonacci divisors and mixed-radix numerals."""

from __future__ import annotations

from math import factorial, gcd, isqrt
from typing import Callable, Iterable, Sequence


def fibonacci(n: int) -> int:
    """Return F_n for F_0 = 0 and F_1 = 1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def prime_factors(n: int) -> list[int]:
    """Return the distinct prime factors of a positive integer."""
    if n < 1:
        raise ValueError("n must be positive")
    factors: list[int] = []
    p = 2
    while p * p <= n:
        if n % p == 0:
            factors.append(p)
            while n % p == 0:
                n //= p
        p = 3 if p == 2 else p + 2
    if n > 1:
        factors.append(n)
    return factors


def proper_divisors(n: int) -> list[int]:
    """List the positive proper divisors of n."""
    if n < 1:
        raise ValueError("n must be positive")
    small: list[int] = []
    large: list[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            if d < n:
                small.append(d)
            q = n // d
            if q != d and q < n:
                large.append(q)
    return small + large[::-1]


def strip_shared_factors(value: int, other: int) -> int:
    """Repeatedly divide value by its gcd with other until they are coprime."""
    while value > 0:
        common = gcd(value, other)
        if common <= 1:
            break
        value //= common
    return value


def fibonacci_primitive_part(n: int) -> int:
    """Strip from F_n every factor shared with F_d for positive proper d | n."""
    remainder = fibonacci(n)
    for d in proper_divisors(n):
        remainder = strip_shared_factors(remainder, fibonacci(d))
    return remainder


def primitive_prime_divisors(n: int) -> list[int]:
    """Find primes dividing F_n but no F_k with 0 < k < n."""
    fn = fibonacci(n)
    return [
        p
        for p in prime_factors(fn)
        if all(fibonacci(k) % p != 0 for k in range(1, n))
    ]


def radix_products(radices: Sequence[int]) -> list[int]:
    """Return place weights 1, b_0, b_0 b_1, ... for the supplied radices."""
    products: list[int] = []
    running = 1
    for base in radices:
        if base <= 0:
            raise ValueError("radices must be positive")
        products.append(running)
        running *= base
    return products


def mixed_radix_value(digits: Sequence[int], radices: Sequence[int]) -> int:
    """Evaluate a valid finite mixed-radix digit vector."""
    if len(digits) != len(radices):
        raise ValueError("digits and radices must have equal length")
    if any(d < 0 or d >= b for d, b in zip(digits, radices)):
        raise ValueError("each digit must satisfy 0 <= digit < local radix")
    return sum(d * w for d, w in zip(digits, radix_products(radices)))


def mixed_radix_digits(value: int, radices: Sequence[int]) -> list[int]:
    """Extract the unique valid digits for 0 <= value < the total product."""
    if value < 0:
        raise ValueError("value must be nonnegative")
    total = 1
    for base in radices:
        if base <= 0:
            raise ValueError("radices must be positive")
        total *= base
    if value >= total:
        raise ValueError("value lies outside the represented initial interval")
    digits: list[int] = []
    quotient = value
    for base in radices:
        digits.append(quotient % base)
        quotient //= base
    return digits


def factorial_value(digits: Sequence[int]) -> int:
    """Evaluate digits c_i at factorial weights i!, requiring c_i < i + 1."""
    if any(d < 0 or d >= i + 1 for i, d in enumerate(digits)):
        raise ValueError("factorial digit c_i must satisfy 0 <= c_i < i + 1")
    return sum(d * factorial(i) for i, d in enumerate(digits))


def show_fibonacci_examples(indices: Iterable[int]) -> None:
    print("Primitive Fibonacci divisors")
    print(" n | F_n | stripped part | primitive primes")
    for n in indices:
        print(
            f"{n:2d} | {fibonacci(n):>10d} | {fibonacci_primitive_part(n):>13d} | "
            f"{primitive_prime_divisors(n)}"
        )


def show_factorial_bridge() -> None:
    print("\nFactorial numerals as mixed-radix numerals")
    digits = [0, 1, 2, 3, 1, 4]
    radices = [i + 1 for i in range(len(digits))]
    mixed = mixed_radix_value(digits, radices)
    fact = factorial_value(digits)
    recovered = mixed_radix_digits(mixed, radices)
    print(f"digits                 = {digits}")
    print(f"radices                = {radices}")
    print(f"place weights          = {radix_products(radices)}")
    print(f"mixed-radix value      = {mixed}")
    print(f"factorial-system value = {fact}")
    print(f"recovered digits       = {recovered}")
    assert mixed == fact and recovered == digits


def main() -> None:
    show_fibonacci_examples([13, 14, 15, 16, 18, 20, 24, 30])
    show_factorial_bridge()


if __name__ == "__main__":
    main()
