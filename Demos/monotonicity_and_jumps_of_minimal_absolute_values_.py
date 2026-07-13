"""Numerical demonstrations of the fifth-roots-of-unity / golden-ratio bridge.

This self-contained script verifies, to machine precision, the exact identities
connecting sums of fifth roots of unity with the golden ratio and the Fibonacci
and Lucas numbers, and it computes the minimal non-vanishing modulus sigma_5(n)
of an n-term sum of fifth roots of unity for small n.

Key facts demonstrated:
  * The Gaussian periods p = zeta + zeta^4 and q = zeta^2 + zeta^3 satisfy
        p + q = -1,   p * q = -1,
    so {p, q} = {-phi, -psi} where phi = (1+sqrt5)/2, psi = (1-sqrt5)/2.
  * Lucas bridge:      p^n + q^n = (-1)^n * L_n.
  * Fibonacci bridge:  (p^n - q^n)^2 = 5 * F_n^2.
  * Golden moduli:     {|p|, |q|} = {phi, 1/phi}.
  * sigma_5(2) = 1/phi = 0.6180339887...
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Iterator

PHI: float = (1.0 + math.sqrt(5.0)) / 2.0
PSI: float = (1.0 - math.sqrt(5.0)) / 2.0
ZETA: complex = cmath.exp(2j * math.pi / 5.0)  # primitive fifth root of unity


def lucas(n: int) -> int:
    """Return the n-th Lucas number (L0 = 2, L1 = 1, L(n+2) = L(n+1) + L(n))."""
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fibonacci(n: int) -> int:
    """Return the n-th Fibonacci number (F0 = 0, F1 = 1)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def gaussian_periods(zeta: complex) -> tuple[complex, complex]:
    """Return the two Gaussian periods p = zeta+zeta^4 and q = zeta^2+zeta^3."""
    p = zeta + zeta ** 4
    q = zeta ** 2 + zeta ** 3
    return p, q


def verify_period_sum_prod(tol: float = 1e-12) -> bool:
    """Check p + q = -1 and p * q = -1."""
    p, q = gaussian_periods(ZETA)
    return abs((p + q) - (-1)) < tol and abs((p * q) - (-1)) < tol


def verify_lucas_bridge(max_n: int = 15, tol: float = 1e-9) -> bool:
    """Check p^n + q^n = (-1)^n * L_n for n = 0..max_n."""
    p, q = gaussian_periods(ZETA)
    for n in range(max_n + 1):
        lhs = p ** n + q ** n
        rhs = ((-1) ** n) * lucas(n)
        if abs(lhs - rhs) > tol * (1 + abs(rhs)):
            return False
    return True


def verify_fibonacci_bridge(max_n: int = 15, tol: float = 1e-9) -> bool:
    """Check (p^n - q^n)^2 = 5 * F_n^2 for n = 0..max_n."""
    p, q = gaussian_periods(ZETA)
    for n in range(max_n + 1):
        lhs = (p ** n - q ** n) ** 2
        rhs = 5 * fibonacci(n) ** 2
        if abs(lhs - rhs) > tol * (1 + abs(rhs)):
            return False
    return True


def verify_golden_moduli(tol: float = 1e-12) -> bool:
    """Check {|p|, |q|} = {phi, 1/phi}."""
    p, q = gaussian_periods(ZETA)
    moduli = sorted([abs(p), abs(q)])
    return abs(moduli[0] - 1.0 / PHI) < tol and abs(moduli[1] - PHI) < tol


def all_sums(n: int) -> Iterator[complex]:
    """Yield every n-term sum of fifth roots of unity (as compositions of n)."""
    roots = [ZETA ** k for k in range(5)]
    # a composition (a0,...,a4) of n gives the sum sum_k a_k * root_k
    for combo in itertools.combinations_with_replacement(range(5), n):
        s = 0j
        for k in combo:
            s += roots[k]
        yield s


def sigma5(n: int, tol: float = 1e-9) -> float:
    """Compute sigma_5(n): the minimal modulus of a non-vanishing n-term sum."""
    best = math.inf
    for s in all_sums(n):
        m = abs(s)
        if m > tol:  # non-vanishing
            best = min(best, m)
    return best


def jump_predicted(n: int, bound: int = 200) -> bool:
    """Predict whether sigma_5(n) > sigma_5(n+5), i.e. n+5 in {5F_m, L_m, 2L_m}."""
    target = n + 5
    fam: set[int] = set()
    m = 1
    while True:
        fm, lm = fibonacci(m), lucas(m)
        vals = [5 * fm, lm, 2 * lm]
        if min(vals) > bound and 5 * fm > bound:
            break
        for v in vals:
            fam.add(v)
        m += 1
        if m > 60:
            break
    return target in fam


def main() -> None:
    print("Golden ratio phi           =", PHI)
    print("Conjugate  psi             =", PSI)
    print("1/phi                      =", 1.0 / PHI)
    print()

    p, q = gaussian_periods(ZETA)
    print("Gaussian periods:")
    print(f"  p = zeta + zeta^4  = {p.real:+.10f}{p.imag:+.1e}i   |p| = {abs(p):.10f}")
    print(f"  q = zeta^2 + zeta^3 = {q.real:+.10f}{q.imag:+.1e}i   |q| = {abs(q):.10f}")
    print(f"  p + q = {(p + q).real:+.10f}   p * q = {(p * q).real:+.10f}")
    print()

    print("Identity checks:")
    print("  p + q = -1 and p*q = -1     :", verify_period_sum_prod())
    print("  Lucas bridge (n<=15)        :", verify_lucas_bridge())
    print("  Fibonacci bridge (n<=15)    :", verify_fibonacci_bridge())
    print("  Golden moduli {phi, 1/phi}  :", verify_golden_moduli())
    print()

    print("Lucas bridge table:  p^n + q^n  vs  (-1)^n L_n")
    for n in range(1, 9):
        lhs = (p ** n + q ** n).real
        rhs = ((-1) ** n) * lucas(n)
        print(f"  n={n:2d}:  {lhs:+10.5f}   (-1)^n L_n = {rhs:+d}")
    print()

    print("Fibonacci bridge table:  (p^n - q^n)^2  vs  5 F_n^2")
    for n in range(1, 9):
        lhs = ((p ** n - q ** n) ** 2).real
        rhs = 5 * fibonacci(n) ** 2
        print(f"  n={n:2d}:  {lhs:12.5f}   5 F_n^2 = {rhs:d}")
    print()

    print("Minimal non-vanishing modulus sigma_5(n):")
    prev = None
    for n in range(1, 13):
        s = sigma5(n)
        mark = ""
        if prev is not None and n >= 6:
            if s < prev - 1e-7:
                mark = "  <-- strict decrease"
        pred = "predicted jump" if (n >= 6 and jump_predicted(n - 5)) else ""
        # Note: compare sigma_5(n-5) -> sigma_5(n); jump predicted iff n in {5F,L,2L}
        print(f"  sigma_5({n:2d}) = {s:.10f}{mark}")
        prev = s
    print()
    print(f"sigma_5(2) = {sigma5(2):.10f}   (should equal 1/phi = {1.0 / PHI:.10f})")


if __name__ == "__main__":
    main()
