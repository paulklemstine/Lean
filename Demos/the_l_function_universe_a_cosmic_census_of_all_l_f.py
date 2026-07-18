#!/usr/bin/env python3
"""Numerical demonstrations for the rigorous L-function census boundary.

Only Python's standard library is required. The program demonstrates:
1. indistinguishable finite prefixes with distinct Dirichlet series;
2. fixed-modulus Dirichlet-character counts via Euler's totient;
3. multiplicativity of those counts for coprime moduli.
"""

from __future__ import annotations

import cmath
from dataclasses import dataclass
from math import gcd
from typing import Iterable


@dataclass(frozen=True)
class SpikeSeries:
    """A Dirichlet series with one coefficient equal to one."""

    support: int

    def coefficient(self, n: int) -> complex:
        """Return the coefficient at index n."""
        return 1.0 + 0.0j if n == self.support else 0.0 + 0.0j

    def value(self, s: complex) -> complex:
        """Evaluate support**(-s), the exact one-term Dirichlet series."""
        if self.support <= 0:
            raise ValueError("The support must be a positive integer.")
        return cmath.exp(-s * cmath.log(self.support))


def finite_prefix_witness(cutoff: int) -> tuple[SpikeSeries, SpikeSeries]:
    """Construct bounded series agreeing through cutoff but differing globally."""
    if cutoff < 0:
        raise ValueError("The cutoff must be nonnegative.")
    return SpikeSeries(cutoff + 1), SpikeSeries(cutoff + 2)


def agree_through(
    left: SpikeSeries, right: SpikeSeries, cutoff: int
) -> bool:
    """Check coefficient equality at every index from zero through cutoff."""
    return all(left.coefficient(n) == right.coefficient(n) for n in range(cutoff + 1))


def euler_totient(n: int) -> int:
    """Compute phi(n), the number of units and complex characters modulo n."""
    if n <= 0:
        raise ValueError("The modulus must be positive.")
    result = n
    remaining = n
    prime = 2
    while prime * prime <= remaining:
        if remaining % prime == 0:
            while remaining % prime == 0:
                remaining //= prime
            result -= result // prime
        prime += 1
    if remaining > 1:
        result -= result // remaining
    return result


def character_census(moduli: Iterable[int]) -> list[tuple[int, int]]:
    """Return (modulus, number of Dirichlet characters) records."""
    return [(q, euler_totient(q)) for q in moduli]


def multiplicativity_audit(m: int, k: int) -> tuple[bool, int, int]:
    """Compare phi(m*k) and phi(m)*phi(k); theorem applies if gcd is one."""
    if m <= 0 or k <= 0:
        raise ValueError("Moduli must be positive.")
    lhs = euler_totient(m * k)
    rhs = euler_totient(m) * euler_totient(k)
    return gcd(m, k) == 1, lhs, rhs


def print_prefix_demo(cutoff: int = 12, s: complex = 2.0 + 0.5j) -> None:
    """Print one finite-prefix ambiguity witness and its numerical values."""
    first, second = finite_prefix_witness(cutoff)
    print("FINITE-PREFIX AMBIGUITY")
    print(f"cutoff N                : {cutoff}")
    print(f"spike supports           : {first.support}, {second.support}")
    print(f"agree through N          : {agree_through(first, second, cutoff)}")
    print(f"all coefficients bounded: True")
    first_value = first.value(s)
    second_value = second.value(s)
    print(f"evaluation point s       : {s}")
    print(f"L_a(s)                   : {first_value:.12g}")
    print(f"L_b(s)                   : {second_value:.12g}")
    print(f"absolute difference      : {abs(first_value - second_value):.12g}")


def print_character_demo(limit: int = 20) -> None:
    """Print fixed-modulus character-family sizes through a chosen limit."""
    print("\nFIXED-MODULUS DIRICHLET CENSUS")
    print("q : number of distinct character L-functions")
    for q, count in character_census(range(1, limit + 1)):
        print(f"{q:2d}: {count:2d}")


def print_multiplicativity_demo(pairs: Iterable[tuple[int, int]]) -> None:
    """Print coprimality and totient-product audits for modulus pairs."""
    print("\nCOPRIME MULTIPLICATIVITY AUDIT")
    for m, k in pairs:
        applies, lhs, rhs = multiplicativity_audit(m, k)
        status = "theorem applies" if applies else "not a coprime pair"
        equality = "=" if lhs == rhs else "≠"
        print(f"({m}, {k}): phi({m*k})={lhs} {equality} phi({m})phi({k})={rhs}; {status}")


def main() -> None:
    """Run all numerical demonstrations."""
    print_prefix_demo()
    print_character_demo()
    print_multiplicativity_demo([(5, 8), (7, 9), (4, 2), (12, 25)])


if __name__ == "__main__":
    main()
