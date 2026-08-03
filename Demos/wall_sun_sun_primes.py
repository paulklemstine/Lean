#!/usr/bin/env python3
"""Numerical demonstrations for Wall–Sun–Sun prime tests.

The script uses only the Python standard library. It computes Fibonacci numbers
modulo p² by fast doubling, reproduces the complete table below 12, checks the
counterexample p = 11 to residue sufficiency, and optionally searches farther.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Iterable


@dataclass(frozen=True)
class CandidateResult:
    """The data needed to audit one Wall–Sun–Sun candidate test."""

    p: int
    is_prime: bool
    index: int
    modulus: int
    remainder: int

    @property
    def is_wall_sun_sun(self) -> bool:
        return self.is_prime and self.remainder == 0


def is_prime(n: int) -> bool:
    """Return whether n is prime by deterministic trial division."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    divisor = 3
    while divisor <= isqrt(n):
        if n % divisor == 0:
            return False
        divisor += 2
    return True


def fibonacci_index(p: int) -> int:
    """Return p - 1 for residues 1,4 modulo 5, and p + 1 otherwise."""
    if p < 1:
        raise ValueError("p must be positive")
    return p - 1 if p % 5 in (1, 4) else p + 1


def fib_pair_mod(n: int, modulus: int) -> tuple[int, int]:
    """Return (F_n mod modulus, F_(n+1) mod modulus) by fast doubling."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if modulus < 1:
        raise ValueError("modulus must be positive")
    if n == 0:
        return 0, 1 % modulus
    a, b = fib_pair_mod(n // 2, modulus)
    c = (a * ((2 * b - a) % modulus)) % modulus
    d = (a * a + b * b) % modulus
    if n % 2 == 0:
        return c, d
    return d, (c + d) % modulus


def fibonacci_mod(n: int, modulus: int) -> int:
    """Return F_n modulo modulus."""
    return fib_pair_mod(n, modulus)[0]


def test_candidate(p: int) -> CandidateResult:
    """Compute all quantities in the Wall–Sun–Sun test for p."""
    if p < 1:
        raise ValueError("p must be positive")
    index = fibonacci_index(p)
    modulus = p * p
    return CandidateResult(
        p=p,
        is_prime=is_prime(p),
        index=index,
        modulus=modulus,
        remainder=fibonacci_mod(index, modulus),
    )


def primes_up_to(bound: int) -> Iterable[int]:
    """Yield all primes at most bound using a compact Eratosthenes sieve."""
    if bound < 2:
        return
    sieve = bytearray(b"\x01") * (bound + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, isqrt(bound) + 1):
        if sieve[p]:
            start = p * p
            count = (bound - start) // p + 1
            sieve[start : bound + 1 : p] = b"\x00" * count
    for p, flag in enumerate(sieve):
        if flag:
            yield p


def search(bound: int) -> list[CandidateResult]:
    """Return Wall–Sun–Sun witnesses among primes no larger than bound."""
    return [result for p in primes_up_to(bound)
            if (result := test_candidate(p)).is_wall_sun_sun]


def print_small_table() -> None:
    """Print the exhaustive candidate table for primes below 12."""
    print("Complete prime-candidate check below 12")
    print(" p | I(p) | p^2 | F_I(p) mod p^2 | outcome")
    print("---+------+-----+------------------+----------------")
    for p in primes_up_to(11):
        result = test_candidate(p)
        outcome = "Wall–Sun–Sun" if result.is_wall_sun_sun else "fails"
        print(
            f"{result.p:2d} | {result.index:4d} | {result.modulus:3d} |"
            f" {result.remainder:16d} | {outcome}"
        )


def main() -> None:
    print_small_table()
    eleven = test_candidate(11)
    print("\nResidue-condition counterexample")
    print(f"11 mod 5 = {11 % 5}, yet F_{eleven.index} mod 11^2 = "
          f"{eleven.remainder} != 0.")

    bound = 10_000
    witnesses = search(bound)
    print(f"\nExploratory search through {bound:,}")
    if witnesses:
        print("Witnesses:", ", ".join(str(item.p) for item in witnesses))
    else:
        print("No Wall–Sun–Sun prime found in this finite range.")
        print("This finite outcome is evidence only; it does not settle existence.")


if __name__ == "__main__":
    main()
