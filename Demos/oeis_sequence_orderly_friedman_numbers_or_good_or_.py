#!/usr/bin/env python3
"""Numerical demonstrations for the repeated-127 orderly Friedman family.

The script uses only Python's standard library. It generates terms by recurrence
and closed form, checks exact identities, evaluates the two seed certificates,
and prints exact normalized errors using fractions.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, List


def family_recurrence(n: int) -> int:
    """Return F_n from F_0=127 and F_(n+1)=1000*F_n+127."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    value = 127
    for _ in range(n):
        value = 1000 * value + 127
    return value


def family_closed_form(n: int) -> int:
    """Return F_n = 127*(1000**(n+1)-1)//999."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    numerator = 127 * (pow(1000, n + 1) - 1)
    quotient, remainder = divmod(numerator, 999)
    if remainder != 0:
        raise ArithmeticError("geometric-series division was unexpectedly inexact")
    return quotient


def repeated_decimal_block(n: int) -> int:
    """Return the integer whose decimal expansion has n+1 copies of '127'."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return int("127" * (n + 1))


def certificate_127() -> int:
    """Evaluate the orderly seed certificate -1 + 2^7."""
    return -1 + 2**7


def certificate_736() -> int:
    """Evaluate the even orderly certificate 7 + 3^6."""
    return 7 + 3**6


def normalized_error(n: int) -> Fraction:
    """Return 127/999 - F_n/1000^(n+1) exactly."""
    return Fraction(127, 999) - Fraction(family_recurrence(n), 1000 ** (n + 1))


def audit_term(n: int) -> None:
    """Assert all proved numerical characterizations for index n."""
    value = family_recurrence(n)
    assert value == family_closed_form(n)
    assert value == repeated_decimal_block(n)
    assert 999 * value == 127 * (1000 ** (n + 1) - 1)
    assert value % 1000 == 127
    assert 126 * 1000 ** (n + 1) < 999 * value
    assert 999 * value < 127 * 1000 ** (n + 1)
    assert normalized_error(n) == Fraction(127, 999 * 1000 ** (n + 1))


def demo_repeated_family(indices: Iterable[int] = range(6)) -> None:
    """Print terms and compare recurrence, closed form, and decimal repetition."""
    print("DEMO 1 — Repeated-certificate family")
    print(" n  digits  F_n")
    for n in indices:
        audit_term(n)
        value = family_recurrence(n)
        print(f"{n:2d}  {len(str(value)):6d}  {value}")
    print("All representations and exact identities agree.\n")


def demo_normalized_convergence(indices: Iterable[int] = range(5)) -> None:
    """Display exact normalized values and geometrically decaying errors."""
    print("DEMO 2 — Exact normalized convergence")
    limit = Fraction(127, 999)
    print(f"Limit = 127/999 = {float(limit):.15f}")
    previous: Fraction | None = None
    for n in indices:
        value = family_recurrence(n)
        ratio = Fraction(value, 1000 ** (n + 1))
        error = normalized_error(n)
        shrink = "—" if previous is None else str(previous / error)
        print(
            f"n={n}: ratio={float(ratio):.15f}, "
            f"error={error}, previous/error={shrink}"
        )
        previous = error
    print("After the first row, every error is exactly 1/1000 of its predecessor.\n")


def demo_boundary_checks() -> None:
    """Evaluate the even certificate and detect the supplied list's inversion."""
    print("DEMO 3 — Boundary and data checks")
    assert certificate_127() == 127
    even_value = certificate_736()
    assert even_value == 736 and even_value % 2 == 0
    print(f"-1 + 2^7 = {certificate_127()}")
    print(f"7 + 3^6 = {even_value}, which is even")

    reported: List[int] = [
        127, 343, 736, 1285, 2187, 2502, 2592, 2737, 3125, 3685,
        3864, 3972, 4096, 6455, 11264, 11664, 12850, 13825, 14641, 155,
    ]
    inversions = [
        (i, a, b) for i, (a, b) in enumerate(zip(reported, reported[1:])) if a >= b
    ]
    assert inversions == [(18, 14641, 155)]
    print("Non-increasing adjacent pair(s):", inversions)
    print("The displayed list is therefore not strictly increasing.\n")


def main() -> None:
    """Run all numerical demonstrations."""
    demo_repeated_family()
    demo_normalized_convergence()
    demo_boundary_checks()


if __name__ == "__main__":
    main()
