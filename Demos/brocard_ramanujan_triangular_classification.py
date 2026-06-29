"""Numerical demonstrations for the Brocard-Ramanujan Triangular Classification.

This script illustrates the proved results from
`Catalog/NumberTheory/FactorialNotSquare.lean`:

    * `factorial_square_iff_le_one`:  n! is a perfect square  <=>  n <= 1.
    * `factorial_square_triangular_iff_le_one`:
          n! is square AND triangular  <=>  n <= 1.

and contextualizes them against the (open) Brocard-Ramanujan problem
n! + 1 = m^2, whose only known solutions are the Brown numbers
(4, 5), (5, 11), (7, 71), equivalently n!/8 triangular for n in {4, 5, 7}.

The proof engine is Bertrand's postulate: for every n >= 2 there is a prime p
with n/2 < p <= n, and such a prime divides n! exactly once (p-adic valuation 1),
which forbids n! from being a perfect square.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

from math import isqrt, factorial


# ---------------------------------------------------------------------------
# Basic figurate-number predicates
# ---------------------------------------------------------------------------

def is_perfect_square(m: int) -> bool:
    """Return True iff m is a perfect square (m = k^2 for some k in N)."""
    if m < 0:
        return False
    r: int = isqrt(m)
    return r * r == m


def is_triangular(m: int) -> bool:
    """Return True iff m is a triangular number m = t(t+1)/2.

    Equivalent characterization: m is triangular iff 8*m + 1 is a perfect square,
    since t(t+1)/2 = m  <=>  (2t+1)^2 = 8m + 1.
    """
    if m < 0:
        return False
    return is_perfect_square(8 * m + 1)


def triangular_index(m: int) -> int | None:
    """If m = T_t = t(t+1)/2, return t; otherwise return None."""
    if not is_triangular(m):
        return None
    t: int = (isqrt(8 * m + 1) - 1) // 2
    return t


# ---------------------------------------------------------------------------
# Prime utilities and the Bertrand obstruction
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d: int = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def bertrand_prime(n: int) -> int | None:
    """Return a prime p with n/2 < p <= n (Bertrand's postulate, n >= 2).

    Searching downward from n yields the largest such prime, which is the
    cleanest witness to the square obstruction.
    """
    if n < 2:
        return None
    for p in range(n, n // 2, -1):
        if is_prime(p):
            return p
    return None


def p_adic_valuation_factorial(n: int, p: int) -> int:
    """Legendre's formula: the exact exponent of prime p in n!.

        v_p(n!) = sum_{i>=1} floor(n / p^i).
    """
    total: int = 0
    power: int = p
    while power <= n:
        total += n // power
        power *= p
    return total


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_square_classification(limit: int = 15) -> None:
    """Show that n! is a perfect square only for n in {0, 1}."""
    print("=" * 68)
    print("THEOREM  factorial_square_iff_le_one:  n! is a square  <=>  n <= 1")
    print("=" * 68)
    print(f"{'n':>3} | {'n!':>13} | square? | Bertrand prime p in (n/2, n] | v_p(n!)")
    print("-" * 68)
    for n in range(limit + 1):
        f: int = factorial(n)
        sq: bool = is_perfect_square(f)
        p = bertrand_prime(n)
        if p is None:
            print(f"{n:>3} | {f:>13} | {str(sq):>7} | {'(none, n<2)':>28} |   -")
        else:
            v: int = p_adic_valuation_factorial(n, p)
            print(f"{n:>3} | {f:>13} | {str(sq):>7} | {p:>28} |   {v}")
    print()
    squares = [n for n in range(limit + 1) if is_perfect_square(factorial(n))]
    print(f"n with n! a perfect square (n <= {limit}): {squares}")
    print("Observed: exactly {0, 1}, matching the theorem.\n")


def demo_square_triangular(limit: int = 15) -> None:
    """Show that n! is simultaneously square and triangular only for n in {0,1}."""
    print("=" * 68)
    print("THEOREM  factorial_square_triangular_iff_le_one")
    print("         n! is square AND triangular  <=>  n <= 1")
    print("=" * 68)
    rows = []
    for n in range(limit + 1):
        f = factorial(n)
        rows.append((n, is_perfect_square(f), is_triangular(f)))
    print(f"{'n':>3} | {'square?':>8} | {'triangular?':>11} | both?")
    print("-" * 44)
    for n, sq, tri in rows:
        print(f"{n:>3} | {str(sq):>8} | {str(tri):>11} | {str(sq and tri)}")
    both = [n for n, sq, tri in rows if sq and tri]
    print(f"\nn with n! square AND triangular (n <= {limit}): {both}")
    print("Observed: exactly {0, 1}, matching the theorem.\n")


def demo_brocard_ramanujan(limit: int = 40) -> None:
    """Brown numbers: n! + 1 = m^2  <=>  n!/8 is triangular.

    Demonstrates the equivalence proved in the paper and recovers the only
    known solutions n in {4, 5, 7}.  (Full finiteness is an OPEN problem.)
    """
    print("=" * 68)
    print("CONTEXT  Brocard-Ramanujan (OPEN):  n! + 1 = m^2")
    print("         equivalently  n!/8 is triangular")
    print("=" * 68)
    print(f"{'n':>3} | {'n!+1':>14} | n!+1 square? | n!/8 triangular? (T_t)")
    print("-" * 64)
    brown = []
    for n in range(2, limit + 1):
        f = factorial(n)
        plus_one_sq = is_perfect_square(f + 1)
        eighth_ok = (f % 8 == 0) and is_triangular(f // 8)
        t = triangular_index(f // 8) if f % 8 == 0 else None
        tag = f"T_{t}" if (eighth_ok and t is not None) else "-"
        if plus_one_sq:
            m = isqrt(f + 1)
            brown.append((n, m))
            mark = f"YES  (m={m})"
        else:
            mark = "no"
        # Verify the equivalence the paper proves:
        assert plus_one_sq == eighth_ok, "equivalence n!+1 square <=> n!/8 triangular failed!"
        if n <= 8 or plus_one_sq:
            print(f"{n:>3} | {f + 1:>14} | {mark:>12} | {tag}")
    print(f"\nBrown numbers (n, m) with n! + 1 = m^2 found for n <= {limit}: {brown}")
    print("Known Brown numbers: (4, 5), (5, 11), (7, 71). Finiteness is OPEN.\n")


def main() -> None:
    demo_square_classification(limit=15)
    demo_square_triangular(limit=15)
    demo_brocard_ramanujan(limit=40)


if __name__ == "__main__":
    main()
