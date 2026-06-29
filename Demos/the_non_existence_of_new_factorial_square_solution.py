"""
demo.py — Numerical demonstrations for Brocard's problem (n! + 1 = m^2).

This self-contained script illustrates the main results from the accompanying
research:

  * The three Brown numbers n = 4, 5, 7 and the identities n! + 1 = m^2.
  * An exhaustive search confirming no other Brown numbers below a bound
    (mirrors `brocard_no_others_below_1000`).
  * Structural obstructions: m is odd (`brocard_m_odd`), the factorization
    (m-1)(m+1) = n! (`brocard_factor`), and the Wilson divisibility constraint
    p | m when n = p - 1 is prime (`brocard_wilson_dvd`, `brocard_wilson_ge`).
  * Factorials are almost never squares (`factorial_square_iff_le_one`).
  * The geometric equivalence with triangular numbers
    (`factorial_eq_eight_triangular_iff_brown`, `triangular_indices`).
  * Convergence of the Brocard density series sum 1/sqrt(n!)
    (`summable_inv_sqrt_factorial`) that powers the Borel-Cantelli heuristic.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

from math import isqrt, factorial, sqrt
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# Core predicates
# ---------------------------------------------------------------------------

def is_perfect_square(n: int) -> bool:
    """Decidable perfect-square test via integer square root.

    Mirrors `isPerfectSquareB` in the Lean development: a nonnegative integer n
    is a perfect square iff floor(sqrt(n))^2 == n.
    """
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def integer_sqrt_if_square(n: int) -> Optional[int]:
    """Return the exact square root of n if n is a perfect square, else None."""
    r = isqrt(n)
    return r if r * r == n else None


def is_prime(n: int) -> bool:
    """Simple deterministic primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True


def triangular(y: int) -> int:
    """The y-th triangular number T_y = y(y+1)/2."""
    return y * (y + 1) // 2


def triangular_index(m: int) -> Optional[int]:
    """If m is triangular, return y with T_y = m; else None.

    Solves y(y+1)/2 = m, i.e. y = (-1 + sqrt(1 + 8m)) / 2.
    """
    disc = 1 + 8 * m
    s = integer_sqrt_if_square(disc)
    if s is None:
        return None
    if (s - 1) % 2 != 0:
        return None
    return (s - 1) // 2


# ---------------------------------------------------------------------------
# Brown number search
# ---------------------------------------------------------------------------

def brown_numbers_below(bound: int) -> List[Tuple[int, int]]:
    """Return all (n, m) with n < bound and n! + 1 = m^2.

    Exhaustive search mirroring `brocard_no_others_below_1000`.
    """
    results: List[Tuple[int, int]] = []
    for n in range(bound):
        val = factorial(n) + 1
        m = integer_sqrt_if_square(val)
        if m is not None:
            results.append((n, m))
    return results


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_known_solutions() -> None:
    print("=" * 70)
    print("The three Brown numbers: n! + 1 = m^2")
    print("=" * 70)
    for n in (4, 5, 7):
        val = factorial(n) + 1
        m = integer_sqrt_if_square(val)
        assert m is not None
        print(f"  {n}! + 1 = {factorial(n)} + 1 = {val} = {m}^2")
    print()


def demo_exhaustive_search(bound: int = 1000) -> None:
    print("=" * 70)
    print(f"Exhaustive search for Brown numbers with n < {bound}")
    print("(mirrors brocard_no_others_below_1000)")
    print("=" * 70)
    sols = brown_numbers_below(bound)
    ns = [n for n, _ in sols]
    print(f"  Brown numbers found: {ns}")
    assert ns == [4, 5, 7], "Unexpected Brown number(s) — would refute the conjecture!"
    print("  Confirmed: only 4, 5, 7 (no new solutions below the bound).")
    print()


def demo_structural_obstructions() -> None:
    print("=" * 70)
    print("Structural obstructions on solutions of n! + 1 = m^2")
    print("=" * 70)
    print("  (1) m is odd  [brocard_m_odd]")
    print("  (2) (m-1)(m+1) = n!  [brocard_factor]")
    for n in (4, 5, 7):
        m = integer_sqrt_if_square(factorial(n) + 1)
        assert m is not None
        parity = "odd" if m % 2 == 1 else "even"
        assert m % 2 == 1
        lhs = (m - 1) * (m + 1)
        assert lhs == factorial(n)
        print(f"    n={n}: m={m} ({parity}); (m-1)(m+1) = {m-1}*{m+1} = {lhs} = {n}!")
    print()
    print("  (3) Wilson obstruction: if p prime and n = p-1, then p | m, so m >= p")
    print("      [brocard_wilson_dvd, brocard_wilson_ge]")
    for n in (4, 5, 7):
        p = n + 1
        m = integer_sqrt_if_square(factorial(n) + 1)
        assert m is not None
        if is_prime(p):
            divides = (m % p == 0)
            assert divides and m >= p
            print(f"    n={n}: p={p} is prime; p | m? {divides} (m={m}); m >= p? {m >= p}")
        else:
            print(f"    n={n}: p={p} is composite; Wilson does not apply (m={m})")
    print()


def demo_factorial_not_square(bound: int = 15) -> None:
    print("=" * 70)
    print("Factorials are perfect squares iff n <= 1")
    print("(mirrors factorial_square_iff_le_one)")
    print("=" * 70)
    for n in range(bound):
        f = factorial(n)
        sq = is_perfect_square(f)
        tag = "  <- square" if sq else ""
        print(f"  {n}! = {f}: square? {sq}{tag}")
    squares = [n for n in range(bound) if is_perfect_square(factorial(n))]
    assert squares == [0, 1]
    print(f"  Factorials that are squares (n < {bound}): {squares}")
    print()


def demo_triangular_equivalence() -> None:
    print("=" * 70)
    print("Geometric equivalence: n!/8 is triangular  <=>  n!+1 is a square")
    print("(mirrors factorial_eq_eight_triangular_iff_brown, triangular_indices)")
    print("=" * 70)
    print("  Identity check: 8 * T_y + 1 = (2y+1)^2")
    for y in range(6):
        lhs = 8 * triangular(y) + 1
        rhs = (2 * y + 1) ** 2
        assert lhs == rhs
        print(f"    y={y}: 8*T_{y}+1 = 8*{triangular(y)}+1 = {lhs} = {2*y+1}^2")
    print()
    print("  Brown numbers as triangular factorial-eighths:")
    for n in (4, 5, 7):
        f = factorial(n)
        assert f % 8 == 0
        eighth = f // 8
        y = triangular_index(eighth)
        assert y is not None
        m = 2 * y + 1
        assert m * m == f + 1
        print(f"    n={n}: {n}!/8 = {eighth} = T_{y}; m = 2y+1 = {m}")
    print()


def demo_density_series(terms: int = 25) -> None:
    print("=" * 70)
    print("Brocard density series  sum_n 1/sqrt(n!)  converges")
    print("(mirrors summable_inv_sqrt_factorial — engine of the Borel-Cantelli")
    print(" finiteness heuristic brocard_heuristic_finite)")
    print("=" * 70)
    partial = 0.0
    for n in range(terms):
        term = 1.0 / sqrt(factorial(n))
        partial += term
        if n < 12 or n == terms - 1:
            print(f"    n={n:2d}: term = {term:.3e}   partial sum = {partial:.10f}")
    print(f"  Partial sum of first {terms} terms: {partial:.10f}")
    print("  Terms decay super-exponentially; the full series converges.")
    print()


def main() -> None:
    demo_known_solutions()
    demo_exhaustive_search(1000)
    demo_structural_obstructions()
    demo_factorial_not_square(15)
    demo_triangular_equivalence()
    demo_density_series(25)
    print("All demonstrations completed and assertions verified.")


if __name__ == "__main__":
    main()
