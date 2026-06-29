"""
demo.py — Weight-Threshold Profiles and the Codes -> Tropical Valuation Functor
================================================================================

Numerical companion to the formally verified results in
`Catalog/Bridges/CodeThresholdValuation.lean`.

We work with binary vectors `x : Fin n -> ZMod 2`, represented as tuples of 0/1
ints, with coordinatewise addition modulo 2 (exclusive-or). We implement:

  * support(x)        -- the set of active coordinates
  * wt(x)             -- the Hamming weight (# active coordinates)
  * tprof(x)          -- the weight-threshold profile = lead(x) + 1, tprof(0) = 0

and we numerically verify the four headline theorems:

  Theorem 3.3 (separation)        tprof(x) = 0  <=>  x = 0
  Theorem 3.5 (strong triangle)   tprof(x+y) <= max(tprof x, tprof y)
  Theorem 3.6 (isosceles law)     tprof x != tprof y => tprof(x+y) = max(...)
  Theorem 3.7 (comparison)        wt(x) <= tprof(x) <= n

We also contrast `tprof` with the Hamming weight `wt` (which is NOT ultrametric),
and run an exhaustive check on the extended Hamming [8,4,4] code.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

Vec = Tuple[int, ...]


# --------------------------------------------------------------------------- #
# Core invariants
# --------------------------------------------------------------------------- #
def add2(x: Vec, y: Vec) -> Vec:
    """Coordinatewise addition in ZMod 2 (bitwise XOR)."""
    assert len(x) == len(y)
    return tuple((a + b) % 2 for a, b in zip(x, y))


def support(x: Vec) -> List[int]:
    """Indices of nonzero coordinates."""
    return [i for i, a in enumerate(x) if a != 0]


def wt(x: Vec) -> int:
    """Hamming weight: number of active coordinates."""
    return len(support(x))


def tprof(x: Vec) -> int:
    """Weight-threshold profile: 1 + index of the top active coordinate; 0 if x = 0."""
    s = support(x)
    return max((i + 1 for i in s), default=0)


# --------------------------------------------------------------------------- #
# Theorem checks over all binary vectors of length n
# --------------------------------------------------------------------------- #
def all_vectors(n: int) -> List[Vec]:
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def check_separation(n: int) -> bool:
    zero = tuple(0 for _ in range(n))
    return all((tprof(x) == 0) == (x == zero) for x in all_vectors(n))


def check_strong_triangle(n: int) -> bool:
    vs = all_vectors(n)
    return all(tprof(add2(x, y)) <= max(tprof(x), tprof(y)) for x in vs for y in vs)


def check_isosceles(n: int) -> bool:
    vs = all_vectors(n)
    return all(
        tprof(add2(x, y)) == max(tprof(x), tprof(y))
        for x in vs
        for y in vs
        if tprof(x) != tprof(y)
    )


def check_comparison(n: int) -> bool:
    return all(wt(x) <= tprof(x) <= n for x in all_vectors(n))


def weight_fails_ultrametric(n: int) -> List[Tuple[Vec, Vec]]:
    """Return witness pairs where wt(x+y) > max(wt x, wt y) (i.e. wt is NOT ultrametric)."""
    vs = all_vectors(n)
    return [
        (x, y)
        for x in vs
        for y in vs
        if wt(add2(x, y)) > max(wt(x), wt(y))
    ]


# --------------------------------------------------------------------------- #
# The extended Hamming [8,4,4] code (Reed-Muller RM(1,3))
# --------------------------------------------------------------------------- #
HAMMING_GEN: Tuple[Vec, ...] = (
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
)


def encode(a: Vec) -> Vec:
    """encode(a)_j = sum_i a_i * gen[i][j]  (mod 2)."""
    out = [0] * 8
    for i, ai in enumerate(a):
        if ai:
            out = list(add2(tuple(out), HAMMING_GEN[i]))
    return tuple(out)


def hamming_code() -> List[Vec]:
    """All 16 codewords of the extended Hamming [8,4,4] code."""
    return [encode(a) for a in all_vectors(4)]


def hamming_report() -> None:
    code = hamming_code()
    print("Extended Hamming [8,4,4] code: 16 codewords")
    print(f"{'codeword':>10} | {'wt':>3} | {'tprof':>5}")
    print("-" * 26)
    for c in sorted(code, key=tprof):
        bits = "".join(str(b) for b in c)
        print(f"{bits:>10} | {wt(c):>3} | {tprof(c):>5}")

    # Classical weight enumerator 1 + 14 x^4 + x^8
    enum = {0: 0, 4: 0, 8: 0}
    for c in code:
        enum[wt(c)] = enum.get(wt(c), 0) + 1
    print("\nWeight enumerator (classical):", enum, "-> 1 + 14 x^4 + x^8")

    # tprof spectrum (positional)
    spectrum: dict[int, int] = {}
    for c in code:
        spectrum[tprof(c)] = spectrum.get(tprof(c), 0) + 1
    print("tprof spectrum (positional) :", dict(sorted(spectrum.items())))

    # Exhaustive functor compatibility: strong triangle + isosceles on all pairs
    tri_ok = all(
        tprof(add2(x, y)) <= max(tprof(x), tprof(y)) for x in code for y in code
    )
    iso_ok = all(
        tprof(add2(x, y)) == max(tprof(x), tprof(y))
        for x in code
        for y in code
        if tprof(x) != tprof(y)
    )
    print(f"\nStrong triangle on all 256 pairs : {tri_ok}")
    print(f"Isosceles law on distinct-profile pairs : {iso_ok}")


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("Weight-Threshold Profile tprof: a nonarchimedean valuation on codes")
    print("=" * 70)

    for n in (3, 4, 5):
        print(f"\n--- length n = {n} (all {2 ** n} binary vectors) ---")
        print(f"  separation        tprof(x)=0 <=> x=0 : {check_separation(n)}")
        print(f"  strong triangle   tprof(x+y)<=max     : {check_strong_triangle(n)}")
        print(f"  isosceles law     (distinct profiles) : {check_isosceles(n)}")
        print(f"  comparison        wt <= tprof <= n     : {check_comparison(n)}")

    print("\n--- Contrast: the Hamming weight wt is NOT ultrametric ---")
    witnesses = weight_fails_ultrametric(3)
    x, y = witnesses[0]
    s = add2(x, y)
    print(f"  e.g. x={x} (wt {wt(x)}),  y={y} (wt {wt(y)})")
    print(f"       x+y={s} (wt {wt(s)}) > max(wt x, wt y) = {max(wt(x), wt(y))}")
    print(f"  total violating pairs at n=3: {len(witnesses)}")
    print(f"  (tprof has ZERO such violations -- it is genuinely ultrametric)")

    print("\n" + "=" * 70)
    hamming_report()
    print("=" * 70)


if __name__ == "__main__":
    main()
