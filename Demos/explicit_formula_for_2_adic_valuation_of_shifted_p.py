"""
Explicit 2-adic valuation of the shifted Perrin sequence  R_m - 1.

The Perrin sequence is defined by
    R_0 = 3,  R_1 = 0,  R_2 = 2,   R_{n+3} = R_{n+1} + R_n.

This script demonstrates, numerically and self-containedly, the main results:

  1. Parity classification (period 7):
        v2(R_m - 1) = 0  <=>  m mod 7 in {1, 2, 4}.

  2. Explicit closed form (period 28) on 25 of the 28 residue classes:
        v2(R_m - 1) = nu(m mod 28)  in  {0, 1, 2},
     for every residue except the three exceptional ones {10, 19, 26}.

  3. Self-similar refinement (period 56): on the three exceptional classes
        m mod 28 in {10, 19, 26}   (equivalently R_m = 1 mod 8),
     the valuation is >= 3, and each class splits mod 56 into one class with
     valuation exactly 3 and one class with valuation >= 4.

Everything below is standalone: no imports beyond the standard library.
"""

from __future__ import annotations

from collections import defaultdict
from math import isqrt


# ---------------------------------------------------------------------------
# Core sequences and valuation
# ---------------------------------------------------------------------------
def perrin(n_max: int) -> list[int]:
    """Return [R_0, R_1, ..., R_{n_max}] of the Perrin sequence."""
    R: list[int] = [3, 0, 2]
    for i in range(3, n_max + 1):
        R.append(R[i - 2] + R[i - 3])  # R_i = R_{i-2} + R_{i-3}
    return R


def two_adic_valuation(x: int) -> int:
    """The exponent of 2 in the factorization of a nonzero integer x."""
    if x == 0:
        raise ValueError("2-adic valuation of 0 is infinite")
    x = abs(x)
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


# ---------------------------------------------------------------------------
# The explicit period-28 valuation table  nu(r)
# ---------------------------------------------------------------------------
_NU_ONE = {0, 3, 7, 13, 14, 17, 21, 27}
_NU_TWO = {5, 6, 12, 20, 24}
EXCEPTIONAL = {10, 19, 26}


def perrin_nu(m: int) -> int:
    """
    The predicted constant valuation nu(m mod 28) for the 25 regular residues.
    (Returns 0 on the exceptional residues, where the true value is unbounded.)
    """
    r = m % 28
    if r in _NU_ONE:
        return 1
    if r in _NU_TWO:
        return 2
    return 0


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_parity(n_max: int = 400) -> None:
    print("=" * 68)
    print("RESULT 1  -  parity classification (period 7)")
    print("  v2(R_m - 1) = 0  <=>  m mod 7 in {1, 2, 4}")
    print("=" * 68)
    R = perrin(n_max)
    ok = True
    for m in range(1, n_max):
        odd = two_adic_valuation(R[m] - 1) == 0
        pred = (m % 7) in {1, 2, 4}
        ok = ok and (odd == pred)
    print(f"  checked m = 1 .. {n_max - 1}:  agreement = {ok}")


def demo_mod28(n_max: int = 2000) -> None:
    print("=" * 68)
    print("RESULT 2  -  explicit closed form on 25 residues (period 28)")
    print("  v2(R_m - 1) = nu(m mod 28)  for m mod 28 not in {10,19,26}")
    print("=" * 68)
    R = perrin(n_max)
    observed: dict[int, set[int]] = defaultdict(set)
    for m in range(1, n_max):
        observed[m % 28].add(two_adic_valuation(R[m] - 1))
    print(f"  {'r':>3} | {'observed v2':<20} | predicted nu(r)")
    print("  " + "-" * 48)
    for r in range(28):
        obs = sorted(observed[r])
        tag = "  (EXCEPTIONAL, unbounded)" if r in EXCEPTIONAL else ""
        pred = "-" if r in EXCEPTIONAL else str(perrin_nu(r))
        print(f"  {r:>3} | {str(obs):<20} | {pred}{tag}")


def demo_mod56(n_max: int = 4000) -> None:
    print("=" * 68)
    print("RESULT 3  -  self-similar refinement (period 56)")
    print("  each exceptional class mod 28 splits mod 56 into")
    print("  one 'exactly 3' child and one 'at least 4' child")
    print("=" * 68)
    R = perrin(n_max)
    observed: dict[int, set[int]] = defaultdict(set)
    for m in range(1, n_max):
        observed[m % 56].add(two_adic_valuation(R[m] - 1))
    children = {10: (10, 38), 19: (19, 47), 26: (26, 54)}
    for parent, (a, b) in children.items():
        print(f"  parent m mod 28 = {parent}:")
        for c in (a, b):
            obs = sorted(observed[c])
            kind = "exactly 3" if obs == [3] else "persists >= 4"
            print(f"     m mod 56 = {c:>2} : observed {obs}  ->  {kind}")


def demo_value_set(n_max: int = 200000) -> None:
    print("=" * 68)
    print("RESULT 4  -  the valuation realizes every natural number")
    print("=" * 68)
    R = perrin(n_max)
    first_witness: dict[int, int] = {}
    for m in range(1, n_max):
        v = two_adic_valuation(R[m] - 1)
        first_witness.setdefault(v, m)
    for v in range(0, 9):
        if v in first_witness:
            print(f"  smallest m with v2(R_m - 1) = {v}:  m = {first_witness[v]}")


def demo_perrin_brocard(n_max: int = 4000) -> None:
    print("=" * 68)
    print("APPLICATION  -  Perrin-Brocard equation  R_m = x^2 + 1")
    print("  A square has EVEN 2-adic valuation, so any m with")
    print("  v2(R_m - 1) odd is instantly excluded.")
    print("=" * 68)
    R = perrin(n_max)
    excluded = [r for r in range(28)
                if r not in EXCEPTIONAL and perrin_nu(r) % 2 == 1]
    print(f"  residues mod 28 excluded by odd valuation: {sorted(excluded)}")
    hits = []
    for m in range(3, n_max):
        y = R[m] - 1
        if y >= 0 and isqrt(y) ** 2 == y:
            hits.append((m, isqrt(y)))
    print(f"  solutions of R_m = x^2 + 1 found for m < {n_max}: {hits}")


if __name__ == "__main__":
    demo_parity()
    print()
    demo_mod28()
    print()
    demo_mod56()
    print()
    demo_value_set()
    print()
    demo_perrin_brocard()
