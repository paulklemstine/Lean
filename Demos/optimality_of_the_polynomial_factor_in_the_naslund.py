"""
Numerical demonstrations for the slice-rank bound on 3-sunflower-free families.

This self-contained script illustrates, with explicit small computations:

  1. The per-coordinate mod-3 detection factor 1 - (a*b + b*c + c*a), showing it
     is 0 exactly when a coordinate lies in exactly two of three sets.
  2. The characterization: three distinct sets form a sunflower (equal pairwise
     intersections) iff no coordinate lies in exactly two of them.
  3. Brute-force verification that on a small uniform sunflower-free family the
     Naslund-Sawin tensor T_F is the diagonal tensor (1 on the diagonal, 0 off).
  4. The monomial count M(n) = sum_{k <= n/3} C(n,k), the proven bound
     (n+1)*3*M(n), and its exponential base 3/2^(2/3).
  5. The constant identities: 2^H(1/3) = 3/2^(2/3), log2(3/2^(2/3)) = log2 3 - 2/3,
     and (3/2^(2/3))^3 = 27/4.

All functions are inlined and type-hinted; no external dependencies.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import FrozenSet, Iterable, List, Tuple

Set = FrozenSet[int]

# Exponential base of the Naslund-Sawin bound.
BASE: float = 3.0 / 2.0 ** (2.0 / 3.0)


# ---------------------------------------------------------------------------
# 1. The mod-3 per-coordinate detection factor
# ---------------------------------------------------------------------------
def coordinate_factor(in_a: bool, in_b: bool, in_c: bool) -> int:
    """Return (1 - (ab + bc + ca)) mod 3 for one coordinate's memberships."""
    a, b, c = int(in_a), int(in_b), int(in_c)
    return (1 - (a * b + b * c + c * a)) % 3


def demo_coordinate_factor() -> None:
    print("=== 1. Per-coordinate factor 1 - (ab + bc + ca) over F_3 ===")
    print(" a b c | count-in | factor")
    for a in (0, 1):
        for b in (0, 1):
            for c in (0, 1):
                cnt = a + b + c
                fac = coordinate_factor(bool(a), bool(b), bool(c))
                note = "  <- exactly two" if cnt == 2 else ""
                print(f" {a} {b} {c} |    {cnt}     |   {fac}{note}")
    print("Factor is 0 exactly when a coordinate is in exactly two sets.\n")


# ---------------------------------------------------------------------------
# 2. The tensor T_0 and the sunflower characterization
# ---------------------------------------------------------------------------
def T0(a: Set, b: Set, c: Set, n: int) -> int:
    """Product over coordinates of the per-coordinate factor, in F_3."""
    value = 1
    for i in range(n):
        value = (value * coordinate_factor(i in a, i in b, i in c)) % 3
    return value


def is_sunflower(a: Set, b: Set, c: Set) -> bool:
    """Three DISTINCT sets form a sunflower iff pairwise intersections are equal."""
    if a == b or a == c or b == c:
        return False
    return (a & b) == (a & c) == (b & c)


def demo_sunflower_characterization(n: int = 5) -> None:
    print(f"=== 2. Sunflower  <=>  T_0 = 1  (ground set of size {n}) ===")
    subsets: List[Set] = [frozenset(s)
                          for r in range(n + 1)
                          for s in combinations(range(n), r)]
    checked = 0
    mismatches = 0
    for a, b, c in combinations(subsets, 3):  # distinct triples
        checked += 1
        if is_sunflower(a, b, c) != (T0(a, b, c, n) == 1):
            mismatches += 1
    print(f"Distinct triples checked: {checked}; mismatches: {mismatches}")
    print("For every distinct triple: (is a sunflower) == (T_0 == 1).\n")


# ---------------------------------------------------------------------------
# 3. Diagonalization on a uniform sunflower-free family
# ---------------------------------------------------------------------------
def is_sunflower_free(family: List[Set]) -> bool:
    for a, b, c in combinations(family, 3):
        if is_sunflower(a, b, c):
            return False
    return True


def demo_diagonalization(n: int = 5, k: int = 2) -> None:
    print(f"=== 3. T_F is diagonal on a uniform sunflower-free family "
          f"(n={n}, sets of size {k}) ===")
    # Greedily build a uniform sunflower-free family of k-subsets.
    all_k: List[Set] = [frozenset(s) for s in combinations(range(n), k)]
    family: List[Set] = []
    for s in all_k:
        if is_sunflower_free(family + [s]):
            family.append(s)
    print(f"Uniform sunflower-free family size: {len(family)}")

    off_diag_nonzero = 0
    diag_nonone = 0
    for a in family:
        for b in family:
            for c in family:
                v = T0(a, b, c, n)
                if a == b == c:
                    if v != 1:
                        diag_nonone += 1
                else:
                    if v != 0:
                        off_diag_nonzero += 1
    print(f"Diagonal entries != 1: {diag_nonone}")
    print(f"Off-diagonal entries != 0: {off_diag_nonzero}")
    print("So T_F equals the diagonal tensor with support = the family.\n")


# ---------------------------------------------------------------------------
# 4. The monomial count and the proven bound
# ---------------------------------------------------------------------------
def M(n: int) -> int:
    """M(n) = sum_{k <= n/3} C(n,k): squarefree monomials of degree at most n/3."""
    return sum(math.comb(n, k) for k in range(0, n // 3 + 1))


def proven_bound(n: int) -> int:
    """The Naslund-Sawin upper bound (n+1) * 3 * M(n) for general families."""
    return (n + 1) * 3 * M(n)


def demo_bound_growth() -> None:
    print("=== 4. Monomial count M(n), proven bound, and exponential base ===")
    print(f"Exponential base 3/2^(2/3) = {BASE:.10f}")
    print(f"{'n':>4} | {'M(n)':>22} | {'(n+1)*3*M(n)':>26} | bound / base^n")
    for n in (30, 60, 90, 120, 150):
        b = proven_bound(n)
        ratio = b / (BASE ** n)
        print(f"{n:>4} | {M(n):>22} | {b:>26} | {ratio:.4e}")
    print("bound / base^n grows only polynomially (~ sqrt(n)); "
          "conjecturally ~ n^(1/6).\n")


# ---------------------------------------------------------------------------
# 5. Constant identities
# ---------------------------------------------------------------------------
def binary_entropy(p: float) -> float:
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def demo_constant_identities() -> None:
    print("=== 5. Constant identities for 3/2^(2/3) ===")
    print(f"3/2^(2/3)                = {BASE:.10f}")
    print(f"2^H(1/3)                 = {2 ** binary_entropy(1/3):.10f}")
    print(f"H(1/3)                   = {binary_entropy(1/3):.10f}")
    print(f"log2 3 - 2/3             = {math.log2(3) - 2/3:.10f}")
    print(f"log2(3/2^(2/3))          = {math.log2(BASE):.10f}")
    print(f"(3/2^(2/3))^3            = {BASE ** 3:.10f}")
    print(f"27/4                     = {27/4:.10f}\n")


def main() -> None:
    demo_coordinate_factor()
    demo_sunflower_characterization(n=5)
    demo_diagonalization(n=5, k=2)
    demo_bound_growth()
    demo_constant_identities()


if __name__ == "__main__":
    main()
