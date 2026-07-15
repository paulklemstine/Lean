#!/usr/bin/env python3
"""Numerical demonstrations for an infinite family of orderly Friedman numbers."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class CertificateCheck:
    """Result of checking a small explicit orderly certificate."""

    numeral: int
    digits: tuple[int, ...]
    expression: str
    value: int

    @property
    def valid(self) -> bool:
        return tuple(map(int, str(self.numeral))) == self.digits and self.value == self.numeral


def family_term_recurrence(n: int) -> int:
    """Return F_n, where F_0 = 127 and F_(n+1) = 1000 F_n + 127."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    value = 127
    for _ in range(n):
        value = 1000 * value + 127
    return value


def family_term_closed(n: int) -> int:
    """Return F_n from the exact geometric closed form."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    numerator = 127 * (1000 ** (n + 1) - 1)
    quotient, remainder = divmod(numerator, 999)
    if remainder != 0:
        raise ArithmeticError("closed-form numerator should be divisible by 999")
    return quotient


def repeated_block(n: int) -> str:
    """Return the decimal representation consisting of n+1 copies of '127'."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return "127" * (n + 1)


def generate_family(count: int) -> list[int]:
    """Generate the first count terms by recurrence."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    return [family_term_recurrence(n) for n in range(count)]


def counting_lower_bound(x: int) -> int:
    """Count members of the repeated-127 family not exceeding x, exactly."""
    if x < 127:
        return 0
    count = 0
    value = 127
    while value <= x:
        count += 1
        value = 1000 * value + 127
    return count


def verify_terms(indices: Iterable[int]) -> None:
    """Cross-check recurrence, closed form, and decimal block construction."""
    for n in indices:
        recurrence = family_term_recurrence(n)
        closed = family_term_closed(n)
        block = int(repeated_block(n))
        assert recurrence == closed == block
        assert 999 * recurrence == 127 * (1000 ** (n + 1) - 1)
        print(
            f"n={n:2d}  F_n={recurrence}  digits={len(str(recurrence)):2d}  "
            f"all constructions agree"
        )


def main() -> None:
    certificates = [
        CertificateCheck(127, (1, 2, 7), "-1 + 2^7", -1 + 2**7),
        CertificateCheck(736, (7, 3, 6), "7 + 3^6", 7 + 3**6),
    ]
    print("Small orderly certificates")
    for certificate in certificates:
        print(
            f"  {certificate.expression} = {certificate.value}; "
            f"digits={certificate.digits}; valid={certificate.valid}"
        )
        assert certificate.valid

    print("\nRepeated-block family")
    verify_terms(range(8))

    terms = generate_family(8)
    assert all(a < b for a, b in zip(terms, terms[1:]))
    print("\nStrictly increasing:", all(a < b for a, b in zip(terms, terms[1:])))

    print("\nExact counting lower bound contributed by this family")
    for x in (126, 127, 1_000_000, 10**12, 10**24):
        print(f"  X={x:>25}: {counting_lower_bound(x)} certified family member(s) <= X")


if __name__ == "__main__":
    main()
