#!/usr/bin/env python3
"""Numerical demonstrations of prime-characteristic cocycle sharpness.

For each selected prime p, the cyclic group C_p is represented by integers
0,...,p-1 under addition modulo p, while the coefficient field is represented
by the same residues.  The group action is trivial and c(a) = a.
"""

from dataclasses import dataclass
from typing import Iterable, List, Sequence, Tuple


@dataclass(frozen=True)
class VerificationReport:
    """Summary of the finite checks for one modulus."""

    p: int
    is_prime: bool
    group_order_in_field: int
    cocycle_law_holds: bool
    failed_cocycle_pairs: Tuple[Tuple[int, int], ...]
    coordinate_values: Tuple[int, ...]
    distinct_coboundaries: Tuple[Tuple[int, ...], ...]
    is_coboundary: bool


def is_prime(n: int) -> bool:
    """Return whether n is prime by trial division in O(sqrt(n)) time."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    divisor = 3
    while divisor * divisor <= n:
        if n % divisor == 0:
            return False
        divisor += 2
    return True


def group_product(a: int, b: int, p: int) -> int:
    """Product in the multiplicatively written additive cyclic group."""
    return (a + b) % p


def trivial_action(_g: int, value: int, p: int) -> int:
    """Apply the trivial action to a field element."""
    return value % p


def coordinate_cocycle(g: int, p: int) -> int:
    """Return the additive coordinate of a cyclic group element."""
    return g % p


def coboundary(v: int, g: int, p: int) -> int:
    """Compute v - g·v for the trivial action."""
    return (v - trivial_action(g, v, p)) % p


def verify_modulus(p: int) -> VerificationReport:
    """Exhaustively check the cocycle law and all possible coboundaries.

    The pair check costs O(p^2) modular operations.  Enumerating all p
    coboundary tables costs O(p^2) operations in this deliberately explicit
    pedagogical implementation.
    """
    if p < 2:
        raise ValueError("The modulus must be at least 2")

    failures: List[Tuple[int, int]] = []
    for g in range(p):
        for h in range(p):
            left = coordinate_cocycle(group_product(g, h, p), p)
            right = (
                coordinate_cocycle(g, p)
                + trivial_action(g, coordinate_cocycle(h, p), p)
            ) % p
            if left != right:
                failures.append((g, h))

    values = tuple(coordinate_cocycle(g, p) for g in range(p))
    tables = {
        tuple(coboundary(v, g, p) for g in range(p))
        for v in range(p)
    }
    return VerificationReport(
        p=p,
        is_prime=is_prime(p),
        group_order_in_field=p % p,
        cocycle_law_holds=not failures,
        failed_cocycle_pairs=tuple(failures),
        coordinate_values=values,
        distinct_coboundaries=tuple(sorted(tables)),
        is_coboundary=values in tables,
    )


def format_report(report: VerificationReport) -> str:
    """Format one verification report for terminal output."""
    conclusion = (
        "nonzero cocycle and not a coboundary"
        if report.cocycle_law_holds and not report.is_coboundary
        else "expected sharpness pattern not observed"
    )
    return "\n".join(
        [
            f"p = {report.p} (prime: {report.is_prime})",
            f"  |G| represented in F_p: {report.group_order_in_field}",
            f"  c(g) for g = 0,...,p-1: {report.coordinate_values}",
            f"  cocycle law holds for all p^2 pairs: {report.cocycle_law_holds}",
            f"  distinct trivial-action coboundaries: {report.distinct_coboundaries}",
            f"  coordinate cocycle is a coboundary: {report.is_coboundary}",
            f"  conclusion: {conclusion}",
        ]
    )


def run_demo(primes: Sequence[int] = (2, 3, 5, 7, 11)) -> None:
    """Print exhaustive demonstrations for the supplied prime moduli."""
    for p in primes:
        report = verify_modulus(p)
        if not report.is_prime:
            raise ValueError(f"Expected a prime modulus, received {p}")
        print(format_report(report))
        print()


if __name__ == "__main__":
    run_demo()
