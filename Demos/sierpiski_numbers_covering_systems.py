#!/usr/bin/env python3
"""Numerical demonstrations for the period-36 covering of 78557 * 2^n + 1.

Only the Python standard library is required.  The script validates the seven
class rules, constructs the full residue table, and demonstrates guaranteed
proper divisors for small and very large exponents.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd, lcm
from typing import Iterable, Sequence

K = 78_557
PERIOD = 36
PRIME_TABLE: tuple[int, ...] = (
    3, 5, 3, 73, 3, 5, 3, 7, 3, 5, 3, 13,
    3, 5, 3, 19, 3, 5, 3, 7, 3, 5, 3, 13,
    3, 5, 3, 37, 3, 5, 3, 7, 3, 5, 3, 13,
)


@dataclass(frozen=True)
class CoveringRule:
    """A residue class and the prime assigned to every exponent in it."""

    residue: int
    modulus: int
    prime: int

    def contains(self, exponent: int) -> bool:
        return exponent % self.modulus == self.residue


RULES: tuple[CoveringRule, ...] = (
    CoveringRule(0, 2, 3),
    CoveringRule(1, 4, 5),
    CoveringRule(1, 3, 7),
    CoveringRule(11, 12, 13),
    CoveringRule(15, 18, 19),
    CoveringRule(27, 36, 37),
    CoveringRule(3, 9, 73),
)


def is_prime(number: int) -> bool:
    """Return whether number is prime by deterministic trial division."""
    if number < 2:
        return False
    if number % 2 == 0:
        return number == 2
    divisor = 3
    while divisor * divisor <= number:
        if number % divisor == 0:
            return False
        divisor += 2
    return True


def term(exponent: int) -> int:
    """Compute 78557 * 2**exponent + 1."""
    if exponent < 0:
        raise ValueError("the exponent must be nonnegative")
    return K * (1 << exponent) + 1


def guaranteed_divisor(exponent: int) -> int:
    """Read a guaranteed prime divisor from the period-36 table."""
    if exponent < 0:
        raise ValueError("the exponent must be nonnegative")
    return PRIME_TABLE[exponent % PERIOD]


def validate_rules(rules: Sequence[CoveringRule] = RULES) -> None:
    """Validate primality, periodicity, base divisibility, and coverage."""
    common_period = lcm(*(rule.modulus for rule in rules))
    assert common_period == PERIOD
    for rule in rules:
        assert 0 <= rule.residue < rule.modulus
        assert is_prime(rule.prime)
        assert pow(2, rule.modulus, rule.prime) == 1
        assert (K * pow(2, rule.residue, rule.prime) + 1) % rule.prime == 0
    for residue in range(common_period):
        assert any(rule.contains(residue) for rule in rules)


def validate_period_table() -> None:
    """Check all 36 entries of the compact certificate."""
    assert len(PRIME_TABLE) == PERIOD
    for residue, prime in enumerate(PRIME_TABLE):
        assert prime in {3, 5, 7, 13, 19, 37, 73}
        assert is_prime(prime)
        assert pow(2, PERIOD, prime) == 1
        assert (K * pow(2, residue, prime) + 1) % prime == 0
        assert prime < term(residue)


def demonstrate(exponents: Iterable[int]) -> None:
    """Print certificate data for selected exponents."""
    print(f"{'n':>8} {'n mod 36':>8} {'prime':>7} {'digits':>8} {'remainder':>10}")
    print("-" * 47)
    for exponent in exponents:
        prime = guaranteed_divisor(exponent)
        value = term(exponent)
        print(
            f"{exponent:8d} {exponent % PERIOD:8d} {prime:7d} "
            f"{len(str(value)):8d} {value % prime:10d}"
        )
        assert 1 < prime < value and value % prime == 0


def compatible(residue1: int, modulus1: int, residue2: int, modulus2: int) -> bool:
    """Apply the generalized Chinese-remainder compatibility criterion."""
    return (residue1 - residue2) % gcd(modulus1, modulus2) == 0


def main() -> None:
    validate_rules()
    validate_period_table()
    demonstrate([0, 1, 3, 7, 11, 15, 27, 35, 36, 63, 1_000, 10_000])
    print("\nAll seven rules and all 36 period-table entries are valid.")
    print("The classes 1 mod 4 and 1 mod 3 are compatible:", compatible(1, 4, 1, 3))
    print("The classes 0 mod 2 and 1 mod 4 are compatible:", compatible(0, 2, 1, 4))


if __name__ == "__main__":
    main()
