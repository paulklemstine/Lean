#!/usr/bin/env python3
"""Numerical demonstrations for factorial radix and Fibonacci primitive divisors."""

from __future__ import annotations

from math import factorial, gcd, isqrt
from typing import Iterable


def factorial_digits(n: int) -> list[int]:
    """Return little-endian digits c_i with n = sum(c_i * i!) and c_i < i+1."""
    if n < 0:
        raise ValueError("factorial notation requires a nonnegative integer")
    digits = [0]
    radix = 2
    while n:
        n, remainder = divmod(n, radix)
        digits.append(remainder)
        radix += 1
    return digits


def factorial_value(digits: Iterable[int]) -> int:
    """Evaluate little-endian factorial digits after validating their bounds."""
    total = 0
    for i, digit in enumerate(digits):
        if not 0 <= digit < i + 1:
            raise ValueError(f"digit {digit} at position {i} is outside [0, {i}]")
        total += digit * factorial(i)
    return total


def mixed_radix_value(radices: list[int], digits: list[int]) -> int:
    """Evaluate little-endian digits in a finite mixed-radix system."""
    if len(radices) != len(digits):
        raise ValueError("radices and digits must have equal length")
    value, place = 0, 1
    for radix, digit in zip(radices, digits):
        if radix < 1 or not 0 <= digit < radix:
            raise ValueError("invalid radix or digit")
        value += digit * place
        place *= radix
    return value


def fibonacci_numbers(n: int) -> list[int]:
    """Return F_0 through F_n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    values = [0, 1]
    for _ in range(2, n + 1):
        values.append(values[-1] + values[-2])
    return values[: n + 1]


def prime_factors(n: int) -> list[int]:
    """Return the distinct prime factors of a positive integer by trial division."""
    if n < 1:
        raise ValueError("n must be positive")
    factors: list[int] = []
    divisor = 2
    while divisor <= isqrt(n):
        if n % divisor == 0:
            factors.append(divisor)
            while n % divisor == 0:
                n //= divisor
        divisor = 3 if divisor == 2 else divisor + 2
    if n > 1:
        factors.append(n)
    return factors


def proper_divisors(n: int) -> list[int]:
    """Return all positive proper divisors of n in increasing order."""
    if n <= 1:
        return []
    small: list[int] = []
    large: list[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            if d < n:
                small.append(d)
            q = n // d
            if q != d and q < n:
                large.append(q)
    return sorted(small + large)


def strip_shared_factors(a: int, b: int) -> int:
    """Remove from a every prime factor shared with b."""
    while (g := gcd(a, b)) > 1:
        a //= g
    return a


def fibonacci_primitive_part(n: int) -> int:
    """Strip from F_n factors shared with F_d at each proper divisor d of n."""
    fib = fibonacci_numbers(n)
    residual = fib[n]
    for d in proper_divisors(n):
        residual = strip_shared_factors(residual, fib[d])
    return residual


def primitive_prime_factors(n: int) -> list[int]:
    """Find prime factors of F_n that divide no earlier positive Fibonacci term."""
    fib = fibonacci_numbers(n)
    return [
        p
        for p in prime_factors(fib[n])
        if all(fib[k] % p != 0 for k in range(1, n))
    ]


def demonstrate_factoradics() -> None:
    print("FACTORIAL NUMBER SYSTEM")
    for n in [0, 1, 42, 463, 2026]:
        digits = factorial_digits(n)
        radices = [i + 1 for i in range(len(digits))]
        recovered = factorial_value(digits)
        mixed = mixed_radix_value(radices, digits)
        print(
            f"{n:4d} -> most-significant-first digits "
            f"{''.join(map(str, reversed(digits)))}; "
            f"factorial value={recovered}, mixed-radix value={mixed}"
        )
        assert recovered == mixed == n
    print()


def demonstrate_fibonacci_primitives(start: int = 13, stop: int = 20) -> None:
    print("FIBONACCI PRIMITIVE PRIME DIVISORS")
    fib = fibonacci_numbers(stop)
    for n in range(start, stop + 1):
        primitive = primitive_prime_factors(n)
        residual = fibonacci_primitive_part(n)
        print(
            f"n={n:2d}, F_n={fib[n]:6d}, primitive primes={primitive}, "
            f"stripped primitive part={residual}"
        )
        assert primitive
        assert residual > 1
    print()


def demonstrate_gcd_identity(limit: int = 18) -> None:
    print("FIBONACCI GCD IDENTITY")
    fib = fibonacci_numbers(limit)
    examples = [(8, 12), (10, 15), (14, 18), (17, 18)]
    for m, n in examples:
        left = gcd(fib[m], fib[n])
        right = fib[gcd(m, n)]
        print(f"gcd(F_{m}, F_{n}) = {left} = F_gcd({m},{n})")
        assert left == right


def main() -> None:
    demonstrate_factoradics()
    demonstrate_fibonacci_primitives()
    demonstrate_gcd_identity()


if __name__ == "__main__":
    main()
