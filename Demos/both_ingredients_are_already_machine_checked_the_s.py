"""
Rigidity and strict subadditivity of the universal coding price
===============================================================

Self-contained numerical demonstration, in exact rational arithmetic wherever
possible, of the results of the accompanying paper.

For a finite message space X and a family of laws {p_theta}, the Shtarkov sum

    C_S = sum_x  max_theta p_theta(x)

is the exponential of the minimax pointwise regret of universal coding.  The
demonstrations below verify:

  1. the conservation law            C_S + Omega = k
  2. rigidity of the maximal price   C_S = k  <=>  mutual singularity
  3. rigidity of the free class      C_S = 1  <=>  all sources coincide
  4. the two-source formula          C_S = 1 + d_TV(p, q)
  5. the total-variation sandwich and the stability bounds
  6. the all-pairs affinity bound    sum_{t != t'} (1 - d_TV) <= k(k-1) Omega
  7. the tied-product gap for two point-mass blocks
  8. the quarter bound for two constant strings on distinct letters
  9. exact memoryless Shtarkov sums via the method of types, strict
     submultiplicativity C_S(n1+n2) < C_S(n1) C_S(n2), and C_S(n) < m^n

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Law = Sequence[Fraction]          # a probability law on {0, ..., |X| - 1}
Klass = Sequence[Law]             # a finite source class: one law per parameter


# --------------------------------------------------------------------------
# 1. Finite source classes
# --------------------------------------------------------------------------

def envelope(klass: Klass) -> List[Fraction]:
    """Maximum-likelihood envelope  p_hat(x) = max_theta p_theta(x)."""
    n_msg = len(klass[0])
    return [max(law[x] for law in klass) for x in range(n_msg)]


def shtarkov_sum(klass: Klass) -> Fraction:
    """C_S = sum_x max_theta p_theta(x)."""
    return sum(envelope(klass), Fraction(0))


def overlap(klass: Klass) -> Fraction:
    """Omega = sum_x ( sum_theta p_theta(x) - max_theta p_theta(x) )."""
    n_msg = len(klass[0])
    total = Fraction(0)
    for x in range(n_msg):
        total += sum(law[x] for law in klass) - max(law[x] for law in klass)
    return total


def tv_distance(p: Law, q: Law) -> Fraction:
    """Total variation distance  (1/2) sum_x |p(x) - q(x)|."""
    return sum((abs(a - b) for a, b in zip(p, q)), Fraction(0)) / 2


def mutually_singular(klass: Klass) -> bool:
    """No message carries positive mass under two distinct sources."""
    n_msg = len(klass[0])
    for x in range(n_msg):
        charging = sum(1 for law in klass if law[x] != 0)
        if charging >= 2:
            return False
    return True


def all_equal(klass: Klass) -> bool:
    """All sources have the same law."""
    return all(tuple(law) == tuple(klass[0]) for law in klass)


# --------------------------------------------------------------------------
# 2. The memoryless class, evaluated exactly by the method of types
# --------------------------------------------------------------------------

def compositions(n: int, m: int) -> Iterable[Tuple[int, ...]]:
    """All non-negative integer vectors of length m summing to n (types)."""
    if m == 1:
        yield (n,)
        return
    for first in range(n + 1):
        for rest in compositions(n - first, m - 1):
            yield (first,) + rest


def multinomial(counts: Sequence[int]) -> int:
    """Number of strings with the given letter counts."""
    total = sum(counts)
    value = math.factorial(total)
    for c in counts:
        value //= math.factorial(c)
    return value


def type_envelope(counts: Sequence[int]) -> Fraction:
    """Maximum-likelihood envelope of any string with these letter counts:
    prod_a (k_a / n)^{k_a}, with the convention 0^0 = 1."""
    n = sum(counts)
    value = Fraction(1)
    for c in counts:
        if c > 0:
            value *= Fraction(c, n) ** c
    return value


def memoryless_shtarkov_sum(n: int, m: int) -> Fraction:
    """Exact C_S(n) for the memoryless class on an alphabet of m letters."""
    if n == 0:
        return Fraction(1)
    return sum(
        (Fraction(multinomial(counts)) * type_envelope(counts)
         for counts in compositions(n, m)),
        Fraction(0),
    )


def memoryless_shtarkov_sum_bruteforce(n: int, m: int) -> Fraction:
    """Same quantity summed over all m^n strings (sanity check, small n)."""
    total = Fraction(0)
    for word in itertools.product(range(m), repeat=n):
        counts = [word.count(a) for a in range(m)]
        total += type_envelope(counts)
    return total


def tied_envelope_two_letters(n1: int, n2: int, grid: int = 2000) -> float:
    """max over the simplex of theta(a)^n1 theta(b)^n2 for distinct a, b.

    Restricted to the face theta(a) + theta(b) <= 1, which is where the maximum
    lives; the true optimum is n1^n1 n2^n2 / (n1+n2)^(n1+n2) <= 1/4."""
    best = 0.0
    for i in range(grid + 1):
        ta = i / grid
        tb = 1.0 - ta
        best = max(best, ta ** n1 * tb ** n2)
    return best


# --------------------------------------------------------------------------
# 3. Demonstrations
# --------------------------------------------------------------------------

def frac(*entries: Tuple[int, int]) -> List[Fraction]:
    return [Fraction(a, b) for a, b in entries]


def demo_conservation_and_rigidity() -> None:
    print("=" * 74)
    print("1. Conservation law, rigidity, and the two-source formula")
    print("=" * 74)

    examples: Dict[str, Klass] = {
        "p=(1/2,1/3,1/6), q=(1/4,1/4,1/2)":
            [frac((1, 2), (1, 3), (1, 6)), frac((1, 4), (1, 4), (1, 2))],
        "p=(1,0,0), q=(0,1/2,1/2)  [singular]":
            [frac((1, 1), (0, 1), (0, 1)), frac((0, 1), (1, 2), (1, 2))],
        "three copies of uniform on 3 letters":
            [frac((1, 3), (1, 3), (1, 3))] * 3,
        "three point masses on 3 letters":
            [frac((1, 1), (0, 1), (0, 1)),
             frac((0, 1), (1, 1), (0, 1)),
             frac((0, 1), (0, 1), (1, 1))],
    }

    for name, klass in examples.items():
        k = len(klass)
        cs, om = shtarkov_sum(klass), overlap(klass)
        print(f"\n  class: {name}")
        print(f"    k = {k},  C_S = {cs},  Omega = {om},  C_S + Omega = {cs + om}")
        assert cs + om == k, "conservation law failed"
        print(f"    C_S = k ?  {cs == k}     mutually singular ?  {mutually_singular(klass)}")
        assert (cs == k) == mutually_singular(klass), "upper rigidity failed"
        print(f"    C_S = 1 ?  {cs == 1}     all sources equal ?  {all_equal(klass)}")
        assert (cs == 1) == all_equal(klass), "lower rigidity failed"
        if k == 2:
            d = tv_distance(klass[0], klass[1])
            print(f"    pair formula:  1 + d_TV = {1 + d}   (C_S = {cs})")
            assert cs == 1 + d, "two-source formula failed"


def demo_sandwich_and_stability() -> None:
    print()
    print("=" * 74)
    print("2. Total-variation sandwich, stability, all-pairs affinity")
    print("=" * 74)

    klass: Klass = [
        frac((1, 2), (1, 4), (1, 4)),
        frac((1, 2), (1, 4), (1, 4)),          # a duplicate: a very close pair
        frac((1, 10), (1, 10), (4, 5)),
        frac((0, 1), (1, 2), (1, 2)),
    ]
    k = len(klass)
    cs, om = shtarkov_sum(klass), overlap(klass)
    print(f"\n  k = {k},  C_S = {cs} = {float(cs):.6f},  Omega = {om}")
    assert cs + om == k

    max_tv = max(tv_distance(klass[i], klass[j])
                 for i in range(k) for j in range(k) if i != j)
    print(f"  lower bound 1 + max pairwise d_TV = {1 + max_tv} <= C_S : "
          f"{1 + max_tv <= cs}")
    assert 1 + max_tv <= cs

    for ref in range(k):
        bound = 1 + sum((tv_distance(law, klass[ref]) for law in klass), Fraction(0))
        assert cs <= bound
    print(f"  upper bound 1 + sum_theta d_TV(p_theta, p_ref) holds for every "
          f"reference: True")

    worst = min((tv_distance(klass[i], klass[j]), i, j)
                for i in range(k) for j in range(k) if i != j)
    d, i, j = worst
    print(f"  closest pair ({i},{j}) has d_TV = {d}; stability bound "
          f"k - 1 + d_TV = {k - 1 + d} >= C_S : {cs <= k - 1 + d}")
    assert cs <= k - 1 + d

    affinity = sum((1 - tv_distance(klass[i], klass[j])
                    for i in range(k) for j in range(k) if i != j), Fraction(0))
    print(f"  all-pairs affinity = {affinity} <= k(k-1) Omega = {k * (k - 1) * om} : "
          f"{affinity <= k * (k - 1) * om}")
    assert affinity <= k * (k - 1) * om


def demo_singularity_sweep() -> None:
    print()
    print("=" * 74)
    print("3. Exhaustive sweep: C_S = k is equivalent to mutual singularity")
    print("=" * 74)

    palette: List[Law] = [
        frac((1, 1), (0, 1), (0, 1)),
        frac((0, 1), (1, 1), (0, 1)),
        frac((0, 1), (0, 1), (1, 1)),
        frac((1, 2), (1, 2), (0, 1)),
        frac((1, 2), (0, 1), (1, 2)),
        frac((0, 1), (1, 2), (1, 2)),
        frac((1, 3), (1, 3), (1, 3)),
        frac((1, 4), (1, 4), (1, 2)),
    ]
    tested = disagreements = maximal = 0
    for triple in itertools.product(palette, repeat=3):
        tested += 1
        cs = shtarkov_sum(list(triple))
        singular = mutually_singular(list(triple))
        maximal += int(cs == 3)
        disagreements += int((cs == 3) != singular)
    print(f"\n  classes tested: {tested}")
    print(f"  classes with C_S = 3 (maximal price): {maximal}")
    print(f"  disagreements between 'C_S = 3' and mutual singularity: {disagreements}")
    assert disagreements == 0


def demo_tied_point_masses() -> None:
    print()
    print("=" * 74)
    print("4. Tying two point-mass blocks: C_S drops from m^2 to m")
    print("=" * 74)

    for m in (2, 3, 4, 5):
        # point-mass class on m letters, and its tied square on m x m messages
        single: Klass = [[Fraction(int(x == a)) for x in range(m)] for a in range(m)]
        tied: Klass = [
            [Fraction(int(x1 == a)) * Fraction(int(x2 == a))
             for x1 in range(m) for x2 in range(m)]
            for a in range(m)
        ]
        cs1, cst = shtarkov_sum(single), shtarkov_sum(tied)
        print(f"  m = {m}:  C_S(single) = {cs1},  C_S(tied) = {cst},  "
              f"C_S(single)^2 = {cs1 ** 2},  strict gap: {cst < cs1 ** 2}")
        assert cst == m and (m < 2 or cst < cs1 ** 2)


def demo_quarter_bound() -> None:
    print()
    print("=" * 74)
    print("5. The quarter bound: two constant strings have no common maximiser")
    print("=" * 74)
    print("\n  block lengths   sup_theta theta(a)^n1 theta(b)^n2   (bound 1/4)")
    for n1, n2 in [(1, 1), (1, 2), (2, 2), (3, 1), (5, 4), (10, 10)]:
        value = tied_envelope_two_letters(n1, n2)
        exact = (n1 ** n1) * (n2 ** n2) / float((n1 + n2) ** (n1 + n2))
        print(f"    n1={n1:3d}, n2={n2:3d}      {value:.10f}   "
              f"(closed form {exact:.10f})")
        assert value <= 0.25 + 1e-12
    print("\n  Separately, each constant string has envelope exactly 1, so the tied")
    print("  envelope is deficient by at least 3/4 at this single outcome pair.")


def demo_memoryless() -> None:
    print()
    print("=" * 74)
    print("6. Memoryless Shtarkov sums, strict subadditivity, C_S(n) < m^n")
    print("=" * 74)

    for m in (2, 3):
        print(f"\n  alphabet size m = {m}")
        print("    n   C_S(n) exact        C_S(n)      m^n     m^n / C_S(n)   "
              "log2 C_S(n)   ((m-1)/2) log2 n")
        values: Dict[int, Fraction] = {}
        for n in range(1, 9):
            cs = memoryless_shtarkov_sum(n, m)
            values[n] = cs
            ratio = float(Fraction(m) ** n / cs)
            asym = (m - 1) / 2 * math.log2(n) if n > 1 else 0.0
            shown = str(cs) if len(str(cs)) <= 18 else f"{float(cs):.8f}"
            print(f"   {n:2d}   {shown:>18}  {float(cs):10.6f}  {m ** n:7d}   "
                  f"{ratio:11.3f}   {math.log2(float(cs)):10.5f}   {asym:14.5f}")
            assert n < 2 or cs < Fraction(m) ** n, "C_S(n) < m^n failed"

        assert values[1] == m, "C_S(1) = m failed"
        assert memoryless_shtarkov_sum_bruteforce(4, m) == values[4]

        print("    strict submultiplicativity  C_S(n1+n2) < C_S(n1) C_S(n2):")
        for n1 in range(1, 5):
            for n2 in range(1, 5):
                lhs = values[n1 + n2]
                rhs = values[n1] * values[n2]
                assert lhs < rhs, (n1, n2)
        print("      verified for all 1 <= n1, n2 <= 4  (16 splits, exact arithmetic)")

        print("    bit form (strict subadditivity of the price, in bits):")
        for n1, n2 in [(1, 1), (2, 3), (3, 4), (4, 4)]:
            lhs = math.log2(float(values[n1 + n2]))
            rhs = math.log2(float(values[n1])) + math.log2(float(values[n2]))
            print(f"      n1={n1}, n2={n2}:  {lhs:.6f} < {rhs:.6f}  "
                  f"(saving {rhs - lhs:.6f} bits)")
            assert lhs < rhs


def demo_type_bound() -> None:
    print()
    print("=" * 74)
    print("7. The type bound and its (non-)saturation")
    print("=" * 74)
    print("\n  For the memoryless class the letter counts are a sufficient statistic;")
    print("  the number of types bounds C_S(n) from above, and the bound is far from")
    print("  saturated -- which is why the price is (m-1)/2 log2 n, not (m-1) log2 n.")
    print("\n    m   n   #types   C_S(n)     C_S(n)/#types")
    for m in (2, 3):
        for n in (4, 8, 12):
            n_types = math.comb(n + m - 1, m - 1)
            cs = float(memoryless_shtarkov_sum(n, m))
            print(f"   {m:2d}  {n:2d}   {n_types:6d}   {cs:8.4f}   {cs / n_types:12.6f}")
            assert cs <= n_types


def main() -> None:
    demo_conservation_and_rigidity()
    demo_sandwich_and_stability()
    demo_singularity_sweep()
    demo_tied_point_masses()
    demo_quarter_bound()
    demo_memoryless()
    demo_type_bound()
    print()
    print("=" * 74)
    print("All demonstrations completed; every assertion above passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
