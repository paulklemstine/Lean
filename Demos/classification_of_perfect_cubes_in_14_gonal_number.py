"""
Perfect Cubes Among the Tetradecagonal Numbers
==============================================

Numerical demonstrations of the classification theorem:

    The only non-negative integers n with P_14(n) = n(6n - 5) a perfect cube
    are n = 0, 1, 5, giving the cubes 0, 1, 125.

This script is fully self-contained (standard library only). It:

  1. Enumerates tetradecagonal cubes up to a bound and confirms {0, 1, 5}.
  2. Verifies the four structural ingredients of the proof on sample data:
       - the coprimality identity  gcd(n, 6n-5) = gcd(n, 5),
       - coprime cube splitting in the case 5 does not divide n,
       - the 5-adic valuation obstruction in the case 5 divides n,
       - the Mordell transform  (12n - 5)^2 = 24 t^3 + 25.
  3. Independently recovers the solutions from integer points on the
     Mordell curve X^2 = 24 Y^3 + 25.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

def tetradecagonal(n: int) -> int:
    """The n-th tetradecagonal (14-gonal) number P_14(n) = 6n^2 - 5n."""
    return 6 * n * n - 5 * n


def integer_cube_root(x: int) -> int | None:
    """Return the integer t with t^3 == x if it exists, else None (x >= 0)."""
    if x < 0:
        return None
    t = round(x ** (1.0 / 3.0)) if x > 0 else 0
    for c in (t - 1, t, t + 1):
        if c >= 0 and c * c * c == x:
            return c
    return None


def is_perfect_square(x: int) -> bool:
    """True iff x is a non-negative perfect square."""
    if x < 0:
        return False
    r = isqrt(x)
    return r * r == x


# --------------------------------------------------------------------------
# 1. Direct enumeration
# --------------------------------------------------------------------------

def tetradecagonal_cubes(bound: int) -> List[Tuple[int, int]]:
    """All (n, t) with 0 <= n <= bound and P_14(n) = t^3."""
    out: List[Tuple[int, int]] = []
    for n in range(bound + 1):
        p = tetradecagonal(n)
        t = integer_cube_root(p)
        if t is not None:
            out.append((n, t))
    return out


# --------------------------------------------------------------------------
# 2. Structural ingredients
# --------------------------------------------------------------------------

def check_gcd_identity(n: int) -> bool:
    """Lemma 1: gcd(n, 6n - 5) = gcd(n, 5)."""
    return gcd(abs(n), abs(6 * n - 5)) == gcd(abs(n), 5)


def check_coprime_split(n: int, t: int) -> bool:
    """Lemma 2: if 5 does not divide n and n(6n-5)=t^3, both factors are cubes."""
    if n % 5 == 0:
        return True  # hypothesis 5 ∤ n not met; nothing to check
    if tetradecagonal(n) != t ** 3:
        return True  # premise not met
    a = integer_cube_root(n)
    b = integer_cube_root(6 * n - 5) if 6 * n - 5 >= 0 else None
    return a is not None and b is not None


def check_five_adic(m: int, t: int) -> bool:
    """Lemma 3: if (5m)(6*5m - 5) = t^3 then 5 | m or 5 | (6m - 1)."""
    n = 5 * m
    if tetradecagonal(n) != t ** 3:
        return True  # premise not met
    return (m % 5 == 0) or ((6 * m - 1) % 5 == 0)


def check_mordell_transform(n: int, t: int) -> bool:
    """Lemma 4: n(6n-5)=t^3  ==>  (12n - 5)^2 = 24 t^3 + 25."""
    if tetradecagonal(n) != t ** 3:
        return True
    return (12 * n - 5) ** 2 == 24 * t ** 3 + 25


# --------------------------------------------------------------------------
# 3. Mordell-curve recovery: X^2 = 24 Y^3 + 25, with X = 12n - 5, Y = t
# --------------------------------------------------------------------------

def mordell_points(y_bound: int) -> List[Tuple[int, int]]:
    """Integer points (X, Y) on X^2 = 24 Y^3 + 25 with |Y| <= y_bound."""
    pts: List[Tuple[int, int]] = []
    for y in range(-y_bound, y_bound + 1):
        r = 24 * y ** 3 + 25
        if r >= 0 and is_perfect_square(r):
            x = isqrt(r)
            pts.append((x, y))
            if x != 0:
                pts.append((-x, y))
    return pts


def recover_n_from_mordell(y_bound: int) -> List[int]:
    """Pull back integer points to n = (X + 5)/12 when X ≡ 7 (mod 12), n >= 0."""
    ns = set()
    for x, y in mordell_points(y_bound):
        if (x + 5) % 12 == 0:
            n = (x + 5) // 12
            if n >= 0 and tetradecagonal(n) == y ** 3 and y >= 0:
                ns.add(n)
    return sorted(ns)


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> None:
    print("Tetradecagonal numbers P_14(n) = 6n^2 - 5n:")
    print("  n:   ", list(range(9)))
    print("  P14: ", [tetradecagonal(n) for n in range(9)])
    print()

    sols = tetradecagonal_cubes(100_000)
    print(f"Tetradecagonal cubes with n <= 100000: {sols}")
    print(f"  -> cubes: {[(n, tetradecagonal(n)) for n, _ in sols]}")
    assert sols == [(0, 0), (1, 1), (5, 5)], "unexpected solution set!"
    print("  Confirmed: exactly (0,0), (1,1), (5,5).")
    print()

    print("Lemma 1 (gcd identity) on n = -10..10:",
          all(check_gcd_identity(n) for n in range(-10, 11)))
    print("Lemma 2 (coprime split) on solutions:",
          all(check_coprime_split(n, t) for n, t in sols))
    print("Lemma 3 (5-adic) on m with n=5m a solution:",
          all(check_five_adic(m, t) for m in range(0, 50)
              for t in [integer_cube_root(tetradecagonal(5 * m)) or -1]))
    print("Lemma 4 (Mordell transform) on solutions:",
          all(check_mordell_transform(n, t) for n, t in sols))
    print()

    print("Integer points on X^2 = 24 Y^3 + 25 with |Y| <= 10:")
    for x, y in sorted(mordell_points(10)):
        print(f"  (X, Y) = ({x:4d}, {y:2d})   check: {x*x} = 24*{y}^3 + 25 = {24*y**3+25}")
    print()
    print("Recovered n from Mordell points:", recover_n_from_mordell(50))


if __name__ == "__main__":
    main()
