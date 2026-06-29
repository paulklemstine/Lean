"""
Numerical demonstrations for:

    A Sharp Upper Bound for Uniform VC-Dimension Families via Layered Stars

This self-contained script illustrates the verified results:

  * the binomial toolkit (central entry maximal; Sauer-Shelah sum monotone and
    bounded by 2^n);
  * the layered-star formula quantities  layeredSum, starLayer, Mformula;
  * the uniform layered-star family (all floor(d/2)-subsets of [n]) together with
    a brute-force computation of its VC dimension, confirming it is <= d and equal
    to floor(d/2);
  * the conjectured layered-star optimum
        M_d(n) = max_{0<=k<=floor(d/2)}  sum_{i=0}^{k} C(n-2i-1, d-2i).

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, List, Tuple


# --------------------------------------------------------------------------- #
#  1. Binomial toolkit (Section 2 of the paper)
# --------------------------------------------------------------------------- #
def central_binomial(n: int) -> int:
    """The middle entry C(n, floor(n/2)), the maximal entry of row n."""
    return comb(n, n // 2)


def row_is_maximized_at_center(n: int) -> bool:
    """Check C(n,k) <= C(n, floor(n/2)) for every k (Lemma `choose_le_middle`)."""
    top: int = central_binomial(n)
    return all(comb(n, k) <= top for k in range(n + 1))


def sauer_shelah_sum(n: int, d: int) -> int:
    """layeredSum(n, d) = sum_{k=0}^{d} C(n, k) (the Sauer-Shelah growth bound)."""
    return sum(comb(n, k) for k in range(d + 1))


def sauer_shelah_within_2n(n: int, d: int) -> bool:
    """Check layeredSum(n, d) <= 2^n for d <= n (`layeredSum_le_pow`)."""
    return d > n or sauer_shelah_sum(n, d) <= 2 ** n


def star_layer(d: int, k: int) -> int:
    """The size profile of star layer k: C(d, k) (`starLayer`)."""
    return comb(d, k)


def mformula(n: int, d: int) -> int:
    """Mformula(n, d) = C(n, floor(d/2)), the central uniform-layer size."""
    return comb(n, d // 2)


# --------------------------------------------------------------------------- #
#  2. The uniform layered-star family and its VC dimension (Section 4)
# --------------------------------------------------------------------------- #
Subset = FrozenSet[int]
Family = List[Subset]


def uniform_star_family(n: int, d: int) -> Family:
    """All floor(d/2)-element subsets of [n] = {0, ..., n-1}."""
    r: int = d // 2
    return [frozenset(c) for c in combinations(range(n), r)]


def shatters(family: Iterable[Subset], s: Subset) -> bool:
    """True iff every subset T of s appears as (member ∩ s) for some member."""
    traces = {frozenset(m & s) for m in family}
    for size in range(len(s) + 1):
        for t in combinations(sorted(s), size):
            if frozenset(t) not in traces:
                return False
    return True


def vc_dimension(family: Family, n: int) -> int:
    """Brute-force VC dimension over ground set [n]."""
    best: int = 0
    for size in range(n + 1):
        if any(shatters(family, frozenset(c)) for c in combinations(range(n), size)):
            best = size
    return best


# --------------------------------------------------------------------------- #
#  3. The conjectured layered-star optimum (Section 3.1 / Algorithm C)
# --------------------------------------------------------------------------- #
def layered_star_value(n: int, d: int, k: int) -> int:
    """Size of the depth-k layered star:  sum_{i=0}^{k} C(n-2i-1, d-2i)."""
    return sum(comb(n - 2 * i - 1, d - 2 * i) for i in range(k + 1))


def conjectured_optimum(n: int, d: int) -> Tuple[int, int]:
    """Return (M_d(n), best_k) maximizing over 0 <= k <= floor(d/2)."""
    best_val: int = -1
    best_k: int = 0
    for k in range(d // 2 + 1):
        v: int = layered_star_value(n, d, k)
        if v > best_val:
            best_val, best_k = v, k
    return best_val, best_k


# --------------------------------------------------------------------------- #
#  Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("1. Binomial toolkit")
    print("=" * 70)
    for n in range(0, 9):
        print(f"  row {n}: central C({n},{n//2}) = {central_binomial(n):4d}"
              f"   maximal-at-center: {row_is_maximized_at_center(n)}")
    print()
    for (n, d) in [(6, 2), (8, 3), (10, 4)]:
        ss = sauer_shelah_sum(n, d)
        print(f"  layeredSum({n},{d}) = {ss:4d}  <= 2^{n} = {2**n}"
              f"   ok: {sauer_shelah_within_2n(n, d)}")
    print()

    print("=" * 70)
    print("2. Star-layer profile peaks at floor(d/2)")
    print("=" * 70)
    for d in [4, 5, 6]:
        profile = [star_layer(d, k) for k in range(d + 1)]
        print(f"  d={d}: starLayer = {profile}   argmax = {d//2}"
              f"   (= floor(d/2): {profile.index(max(profile)) == d // 2 or max(profile)==profile[d//2]})")
    print()

    print("=" * 70)
    print("3. Uniform layered-star family: size and VC dimension")
    print("=" * 70)
    for (n, d) in [(5, 2), (6, 3), (6, 4), (7, 4)]:
        fam = uniform_star_family(n, d)
        size = len(fam)
        claimed = mformula(n, d)
        vc = vc_dimension(fam, n)
        print(f"  n={n}, d={d}: |F|={size:3d}  Mformula=C({n},{d//2})={claimed:3d}"
              f"  size_ok={size == claimed}"
              f"   VCdim={vc} <= d={d}: {vc <= d}  (= floor(d/2)={d//2}: {vc == d//2})")
    print()

    print("=" * 70)
    print("4. Conjectured layered-star optimum  M_d(n)")
    print("=" * 70)
    for (n, d) in [(8, 3), (10, 4), (12, 5), (14, 6)]:
        val, k = conjectured_optimum(n, d)
        print(f"  n={n}, d={d}: M_d(n) = {val:5d}  attained at k={k}  (<= floor(d/2)={d//2})")
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
