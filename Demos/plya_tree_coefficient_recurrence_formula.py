"""Numerical demonstration of the Pólya tree coefficient recurrence.

This script exercises the *main theorem* (`polya_tree_recurrence`) and its
supporting identity (`divisor_bridge`) over the exact rationals, reproducing
OEIS A000081 (rooted unlabelled trees) and checking that the analytic series
coefficient `sCoeff` and the arithmetic divisor weight `omegaSeq` agree exactly.

Run:  python demo.py

All functions are inlined and use exact rational arithmetic (fractions.Fraction)
so that the integrality of the recurrence output is visible without rounding.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List


# --- Reference: OEIS A000081 (a_0 = 0, a_1 = 1, ...) -----------------------
A000081: List[int] = [0, 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766]


def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n (n >= 1)."""
    return [d for d in range(1, n + 1) if n % d == 0]


def omega_seq(a: Callable[[int], Fraction], n: int) -> Fraction:
    """Divisor weight omega_n = sum_{d | n} d * a_d   (Lean: omegaSeq)."""
    return sum((Fraction(d) * a(d) for d in divisors(n)), Fraction(0))


def s_coeff(a: Callable[[int], Fraction], n: int) -> Fraction:
    """n-th coefficient of S(z) = sum_{i>=1} A(z^i)/i, i.e.
    sCoeff(a, n) = sum_{i | n} a_{n/i} / i   (Lean: sCoeff)."""
    return sum((a(n // i) / Fraction(i) for i in divisors(n)), Fraction(0))


def polya_tree_sequence(n_max: int) -> List[Fraction]:
    """Generate a_0 .. a_{n_max} via the main recurrence (Lean: polya_tree_recurrence):

        a_1 = 1,
        a_k = (1/(k-1)) * sum_{j=1}^{k-1} a_j * omega_{k-j}   for k >= 2.

    Returns the list of coefficients as exact Fractions.
    """
    a: List[Fraction] = [Fraction(0)] * (n_max + 1)
    if n_max >= 1:
        a[1] = Fraction(1)

    def lookup(i: int) -> Fraction:
        return a[i]

    for k in range(2, n_max + 1):
        conv = sum(
            (a[j] * omega_seq(lookup, k - j) for j in range(1, k)),
            Fraction(0),
        )
        a[k] = conv / Fraction(k - 1)
    return a


def check_divisor_bridge(a: Callable[[int], Fraction], n_max: int) -> bool:
    """Verify the divisor bridge  n * sCoeff(a, n) == omegaSeq(a, n)  for 1 <= n <= n_max."""
    return all(
        Fraction(n) * s_coeff(a, n) == omega_seq(a, n) for n in range(1, n_max + 1)
    )


def main() -> None:
    n_max = 12
    seq = polya_tree_sequence(n_max)

    print("Pólya tree recurrence demo (OEIS A000081)")
    print("=" * 52)
    print(f"{'k':>3} | {'a_k (recurrence)':>18} | {'A000081':>8} | match")
    print("-" * 52)
    all_match = True
    for k in range(0, n_max + 1):
        ak = seq[k]
        assert ak.denominator == 1, f"a_{k} is not an integer: {ak}"
        ref = A000081[k]
        ok = int(ak) == ref
        all_match = all_match and ok
        print(f"{k:>3} | {str(int(ak)):>18} | {ref:>8} | {'OK' if ok else 'XX'}")
    print("-" * 52)
    print(f"All terms match A000081: {all_match}")

    # The recurrence's input is forced by the divisor bridge.
    bridge_ok = check_divisor_bridge(lambda i: seq[i], n_max)
    print(f"Divisor bridge  n * sCoeff == omega  for n <= {n_max}: {bridge_ok}")

    # Show one explicit divisor-weight computation.
    print()
    print("Sample divisor weights omega_m = sum_{d|m} d * a_d:")
    for m in [1, 2, 3, 4, 6]:
        terms = " + ".join(f"{d}*{int(seq[d])}" for d in divisors(m))
        print(f"  omega_{m} = {terms} = {int(omega_seq(lambda i: seq[i], m))}")


if __name__ == "__main__":
    main()
