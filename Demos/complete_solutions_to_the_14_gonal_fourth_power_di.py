"""
Numerical demonstrations for the 14-gonal fourth-power Diophantine equation

        P_14(n) = 6 n^2 - 5 n = t^4.

This script is fully self-contained (standard library only) and demonstrates:

  1. The complete solution set {(0,0), (1,1), (1,-1), (-2000,70), (-2000,-70)}.
  2. The quartic-Pell normal form  (12 n - 5)^2 - 24 t^4 = 25.
  3. The coprimality dichotomy at the prime 5.
  4. The two descent branches and their Thue equations
        6 a^4 - b^4 = 5      (coprime, n > 0)
        e^4 - 150 c^4 = 1     (divisible)
  5. The mod-16 obstruction ruling out the negative coprime quadrant.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic                                                             #
# --------------------------------------------------------------------------- #
def p14(n: int) -> int:
    """The n-th tetradecagonal (14-gonal) number, P_14(n) = 6 n^2 - 5 n."""
    return 6 * n * n - 5 * n


def is_perfect_fourth_power(x: int) -> Optional[int]:
    """Return a nonnegative t with t**4 == x if it exists, else None."""
    if x < 0:
        return None
    r = round(x ** 0.25)
    for t in (r - 1, r, r + 1):
        if t >= 0 and t ** 4 == x:
            return t
    return None


# --------------------------------------------------------------------------- #
# 1. Brute-force search for solutions                                         #
# --------------------------------------------------------------------------- #
def search_solutions(bound: int) -> List[Tuple[int, int]]:
    """All (n, t) with |n| <= bound and P_14(n) = t^4 (t >= 0 recorded once)."""
    out: List[Tuple[int, int]] = []
    for n in range(-bound, bound + 1):
        t = is_perfect_fourth_power(p14(n))
        if t is not None:
            out.append((n, t))
    return out


# --------------------------------------------------------------------------- #
# 2. Pell normal form check                                                   #
# --------------------------------------------------------------------------- #
def pell_residual(n: int, t: int) -> int:
    """(12 n - 5)^2 - 24 t^4 ; equals 25 iff P_14(n) = t^4."""
    return (12 * n - 5) ** 2 - 24 * t ** 4


# --------------------------------------------------------------------------- #
# 3. Coprimality dichotomy at 5                                               #
# --------------------------------------------------------------------------- #
def factor_gcd(n: int) -> int:
    """gcd(n, 6n - 5); equals 1 iff 5 does not divide n, else 5."""
    return gcd(n, 6 * n - 5)


# --------------------------------------------------------------------------- #
# 4. Thue equations from the two descent branches                            #
# --------------------------------------------------------------------------- #
def thue_coprime_positive(bound: int) -> List[Tuple[int, int]]:
    """Nonnegative solutions of 6 a^4 - b^4 = 5 with a, b <= bound."""
    return [(a, b) for a in range(bound + 1) for b in range(bound + 1)
            if 6 * a ** 4 - b ** 4 == 5]


def thue_divisible(bound: int) -> List[Tuple[int, int]]:
    """Nonnegative solutions of e^4 - 150 c^4 = 1 with c, e <= bound."""
    return [(c, e) for c in range(bound + 1) for e in range(bound + 1)
            if e ** 4 - 150 * c ** 4 == 1]


# --------------------------------------------------------------------------- #
# 5. The mod-16 obstruction for the negative coprime branch                  #
# --------------------------------------------------------------------------- #
def fourth_power_residues_mod16() -> List[int]:
    """The set { x^4 mod 16 : x in Z } = {0, 1}."""
    return sorted({(x ** 4) % 16 for x in range(16)})


def negative_branch_residues_mod16() -> List[int]:
    """Possible values of (b^4 - 6 a^4) mod 16; note 5 is absent."""
    res = set()
    for b in range(16):
        for a in range(16):
            res.add((b ** 4 - 6 * a ** 4) % 16)
    return sorted(res)


# --------------------------------------------------------------------------- #
# Driver                                                                       #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print(" 14-gonal fourth powers:  6 n^2 - 5 n = t^4")
    print("=" * 70)

    print("\n[1] Brute-force search over |n| <= 3000:")
    sols = search_solutions(3000)
    for n, t in sols:
        print(f"    n = {n:>6}   P_14(n) = {p14(n):>10}   = {t}^4")
    print(f"    -> {len(sols)} solution(s) with t >= 0 "
          f"(each negative t doubles the count for t != 0).")

    print("\n[2] Pell normal form  (12 n - 5)^2 - 24 t^4 = 25:")
    for n, t in sols:
        print(f"    n = {n:>6}, t = {t:>3}:  residual = {pell_residual(n, t)}")

    print("\n[3] Coprimality dichotomy  gcd(n, 6n - 5):")
    for n in (1, 2, 5, 10, -2000):
        g = factor_gcd(n)
        tag = "5 | n  (divisible)" if n % 5 == 0 else "5 nmid n (coprime)"
        print(f"    n = {n:>6}:  gcd = {g}   [{tag}]")

    print("\n[4] Thue equations from the descent:")
    print("    coprime/positive  6 a^4 - b^4 = 5 :",
          thue_coprime_positive(30), "-> n = a^4 = 1")
    div = thue_divisible(60)
    print("    divisible         e^4 - 150 c^4 = 1 :", div)
    for c, e in div:
        m = -25 * c ** 4 if c else 0
        n = 5 * m
        print(f"        (c, e) = ({c}, {e}) -> m = {m}, n = 5m = {n}")

    print("\n[5] mod-16 obstruction (negative coprime branch b^4 - 6 a^4 = 5):")
    print("    fourth powers mod 16     :", fourth_power_residues_mod16())
    print("    b^4 - 6 a^4 values mod 16:", negative_branch_residues_mod16())
    print("    5 in that set?           :",
          5 in negative_branch_residues_mod16(), " -> branch impossible")

    print("\n[6] The large solution, fully decomposed (n = -2000):")
    n, t = -2000, 70
    m, s = n // 5, t // 5
    print(f"    n = 5m  with m = {m};   t = 5s with s = {s}")
    print(f"    m * (6m - 1) = {m * (6 * m - 1)}  ==  25 * s^4 = {25 * s ** 4}")
    print(f"    m = -25 * 2^4 = {-25 * 2 ** 4};  6m - 1 = {6 * m - 1} = -7^4")
    print(f"    e^4 - 150 c^4 = 7^4 - 150 * 2^4 = {7 ** 4 - 150 * 2 ** 4}")

    print("\nConclusion: the 14-gonal fourth powers are exactly "
          "0, 1, and 24,010,000 = 70^4.")


if __name__ == "__main__":
    main()
