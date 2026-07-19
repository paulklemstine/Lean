#!/usr/bin/env python3
"""Numerical demonstrations for Eisenstein norms, braid writhe, and Fibonacci divisors."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Iterable

Eisenstein = tuple[int, int]


def eisenstein_mul(x: Eisenstein, y: Eisenstein) -> Eisenstein:
    """Multiply a+bω and c+dω in Z[ω], where ω²+ω+1=0."""
    a, b = x
    c, d = y
    return (a * c - b * d, a * d + b * c - b * d)


def eisenstein_norm_sq(x: Eisenstein) -> int:
    """Return N(a+bω)=a²-ab+b²."""
    a, b = x
    return a * a - a * b + b * b


def eisenstein_pow(x: Eisenstein, exponent: int) -> Eisenstein:
    """Compute a natural power by binary exponentiation."""
    if exponent < 0:
        raise ValueError("the exponent must be nonnegative")
    result: Eisenstein = (1, 0)
    base = x
    k = exponent
    while k:
        if k & 1:
            result = eisenstein_mul(result, base)
        base = eisenstein_mul(base, base)
        k >>= 1
    return result


def horner_eisenstein(coefficients: Iterable[int]) -> Eisenstein:
    """Evaluate ascending-order integer coefficients at ω."""
    value: Eisenstein = (0, 0)
    omega: Eisenstein = (0, 1)
    for coefficient in reversed(list(coefficients)):
        value = eisenstein_mul(value, omega)
        value = (value[0] + coefficient, value[1])
    return value


def braid_writhe(word: Iterable[int]) -> int:
    """Return the exponent sum of a signed Artin-generator word."""
    return sum(1 if letter > 0 else -1 for letter in word)


def fibonacci(n: int) -> int:
    """Return F_n with F_0=0 and F_1=1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def prime_factors(number: int) -> list[int]:
    """Return the distinct prime factors of a positive integer."""
    factors: list[int] = []
    m = number
    divisor = 2
    while divisor <= isqrt(m):
        if m % divisor == 0:
            factors.append(divisor)
            while m % divisor == 0:
                m //= divisor
        divisor = 3 if divisor == 2 else divisor + 2
    if m > 1:
        factors.append(m)
    return factors


def first_fibonacci_index_divisible_by(prime: int, limit: int) -> int | None:
    """Find the least positive k≤limit for which prime divides F_k."""
    a, b = 0, 1
    for k in range(1, limit + 1):
        a, b = b, (a + b) % prime
        if a == 0:
            return k
    return None


def primitive_prime_divisors(n: int) -> list[int]:
    """List prime divisors of F_n that divide no earlier positive F_k."""
    return [
        p
        for p in prime_factors(fibonacci(n))
        if first_fibonacci_index_divisible_by(p, n) == n
    ]


def main() -> None:
    signatures = {
        "linear": [1],
        "creative": [2, 2],
        "confused": [-1, -1],
    }
    print("Cube-root evaluations in Eisenstein coordinates")
    for name, coefficients in signatures.items():
        value = horner_eisenstein(coefficients)
        print(f"  {name:8s}: value={value}, norm={eisenstein_norm_sq(value)}")

    x: Eisenstein = (2, 1)
    print("\nPower law N(x^k)=N(x)^k for x=2+ω")
    for k in range(9):
        lhs = eisenstein_norm_sq(eisenstein_pow(x, k))
        rhs = eisenstein_norm_sq(x) ** k
        print(f"  k={k}: {lhs} = {rhs}")
        assert lhs == rhs

    print("\nWrithe certificates")
    for k in range(6):
        word = [1] * k
        print(f"  σ₁^{k}: writhe={braid_writhe(word)}")
    balanced = [1, 2, -1, -2]
    print(f"  balanced word {balanced}: writhe={braid_writhe(balanced)}")

    print("\nPrimitive prime divisors for selected Fibonacci numbers")
    for n in range(13, 21):
        print(f"  F_{n}: {primitive_prime_divisors(n)}")


if __name__ == "__main__":
    main()
