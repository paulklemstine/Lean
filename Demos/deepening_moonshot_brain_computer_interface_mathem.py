"""
Error-Correcting Neural Codes and the Sphere-Packing (Hamming) Bound
====================================================================

Self-contained numerical demonstrations of the results:

  * Raw capacity: N binary neurons realize exactly 2^N patterns.
  * Weight partition: #{patterns of weight k} = C(N,k), and sum_k C(N,k) = 2^N.
  * Hamming-ball volume: |B(c,r)| = sum_{k=0}^{r} C(N,k), independent of center c.
  * Sphere-packing bound: for a t-error-correcting codebook C on N neurons,
        |C| * sum_{k=0}^{t} C(N,k) <= 2^N.
  * Corollaries: t=0 gives |C| <= 2^N; t=1 gives |C| * (N+1) <= 2^N.
  * The Hamming(7,4) code is perfect: it meets the t=1 bound with equality.

Every function is inlined; the script uses only the Python standard library.
Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb
from typing import Iterable, List, Sequence, Tuple

Pattern = Tuple[int, ...]  # a length-N tuple of 0/1


# ---------------------------------------------------------------------------
# Core definitions
# ---------------------------------------------------------------------------
def all_patterns(n: int) -> List[Pattern]:
    """Every binary pattern on n neurons; there are 2^n of them."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def weight(c: Pattern) -> int:
    """Number of firing neurons (Hamming weight)."""
    return sum(c)


def hamming_distance(x: Pattern, y: Pattern) -> int:
    """Number of neurons on which x and y disagree."""
    if len(x) != len(y):
        raise ValueError("patterns must have equal length")
    return sum(1 for xi, yi in zip(x, y) if xi != yi)


def ball(center: Pattern, radius: int) -> List[Pattern]:
    """All patterns within Hamming distance `radius` of `center`."""
    n = len(center)
    return [p for p in all_patterns(n) if hamming_distance(center, p) <= radius]


def ball_volume_formula(n: int, r: int) -> int:
    """Closed form V(N,r) = sum_{k=0}^{r} C(N,k)."""
    return sum(comb(n, k) for k in range(r + 1))


def corrects_t_errors(codebook: Sequence[Pattern], t: int) -> bool:
    """True iff every pair of distinct codewords is at distance >= 2t+1."""
    for x, y in combinations(codebook, 2):
        if hamming_distance(x, y) < 2 * t + 1:
            return False
    return True


def min_distance(codebook: Sequence[Pattern]) -> int:
    """Minimum pairwise Hamming distance of a codebook (inf if <2 words)."""
    dists = [hamming_distance(x, y) for x, y in combinations(codebook, 2)]
    return min(dists) if dists else 10**9


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_raw_capacity(max_n: int = 8) -> None:
    print("=" * 68)
    print("1. RAW CAPACITY:  #patterns on N neurons = 2^N")
    print("=" * 68)
    for n in range(0, max_n + 1):
        count = len(all_patterns(n))
        assert count == 2 ** n
        print(f"   N = {n:2d}:  enumerated {count:6d}   2^N = {2**n:6d}   OK")
    print()


def demo_weight_partition(n: int = 6) -> None:
    print("=" * 68)
    print(f"2. WEIGHT PARTITION (N={n}):  #{{weight k}} = C(N,k),  sum = 2^N")
    print("=" * 68)
    patterns = all_patterns(n)
    total = 0
    for k in range(n + 1):
        counted = sum(1 for p in patterns if weight(p) == k)
        formula = comb(n, k)
        assert counted == formula
        total += counted
        print(f"   weight {k}: enumerated {counted:3d}   C({n},{k}) = {formula:3d}   OK")
    assert total == 2 ** n
    print(f"   sum over weights = {total} = 2^{n} = {2**n}   OK")
    print()


def demo_ball_volume(n: int = 6) -> None:
    print("=" * 68)
    print(f"3. HAMMING-BALL VOLUME (N={n}): |B(c,r)| = sum_{{k<=r}} C(N,k)")
    print("   (independent of the center c)")
    print("=" * 68)
    patterns = all_patterns(n)
    # Test several centers to confirm center-independence.
    centers = [patterns[0], patterns[1], patterns[len(patterns) // 2], patterns[-1]]
    for r in range(n + 1):
        formula = ball_volume_formula(n, r)
        sizes = {len(ball(c, r)) for c in centers}
        assert sizes == {formula}, (sizes, formula)
        print(f"   r = {r}:  |B(c,r)| = {formula:3d} for all tested centers   OK")
    print()


def demo_sphere_packing(codebook: Sequence[Pattern], name: str) -> None:
    n = len(codebook[0])
    d = min_distance(codebook)
    # A codebook of minimum distance d corrects t = floor((d-1)/2) errors.
    t = (d - 1) // 2
    lhs = len(codebook) * ball_volume_formula(n, t)
    rhs = 2 ** n
    print(f"   {name}: N={n}, |C|={len(codebook)}, min-dist={d}, corrects t={t}")
    print(f"       |C| * V(N,t) = {len(codebook)} * {ball_volume_formula(n, t)}"
          f" = {lhs}   <=   2^{n} = {rhs}   "
          f"{'(PERFECT: equality)' if lhs == rhs else 'OK'}")
    assert corrects_t_errors(codebook, t)
    assert lhs <= rhs


def hamming_7_4_code() -> List[Pattern]:
    """
    The Hamming(7,4) code: 16 codewords of length 7, minimum distance 3,
    a perfect single-error-correcting code (meets the t=1 sphere-packing bound
    with equality: 16 * (7+1) = 128 = 2^7).

    Systematic construction: 4 data bits d0..d3, 3 parity bits chosen so that
    each parity checks a distinct triple of data bits.
    """
    code: List[Pattern] = []
    for d0, d1, d2, d3 in product((0, 1), repeat=4):
        p0 = d0 ^ d1 ^ d3
        p1 = d0 ^ d2 ^ d3
        p2 = d1 ^ d2 ^ d3
        code.append((d0, d1, d2, d3, p0, p1, p2))
    return code


def demo_codes() -> None:
    print("=" * 68)
    print("4. SPHERE-PACKING BOUND on explicit codebooks")
    print("=" * 68)

    # Repetition code {000, 111}: N=3, distance 3, corrects 1 error.
    rep3 = [(0, 0, 0), (1, 1, 1)]
    demo_sphere_packing(rep3, "3-bit repetition code")

    # A distance-3 code on N=5: {00000, 11100, 00111, 11011}, pairwise dist >= 3.
    c5 = [(0, 0, 0, 0, 0), (1, 1, 1, 0, 0), (0, 0, 1, 1, 1), (1, 1, 0, 1, 1)]
    demo_sphere_packing(c5, "distance-3 code on 5 neurons")

    # Hamming(7,4): perfect single-error-correcting code.
    demo_sphere_packing(hamming_7_4_code(), "Hamming(7,4) code")
    print()


def demo_capacity_price(max_n: int = 12) -> None:
    print("=" * 68)
    print("5. THE PRICE OF ROBUSTNESS:  usable capacity ceilings")
    print("=" * 68)
    print(f"   {'N':>3} {'2^N':>10} {'2^N/(N+1)':>14} {'2^N/V(N,2)':>14}")
    for n in range(3, max_n + 1):
        raw = 2 ** n
        single = raw / (n + 1)
        double = raw / ball_volume_formula(n, 2)
        print(f"   {n:>3} {raw:>10} {single:>14.2f} {double:>14.2f}")
    print("   (t=1 ceiling = raw/(N+1);  t=2 ceiling = raw/V(N,2))")
    print()


def main() -> None:
    demo_raw_capacity()
    demo_weight_partition()
    demo_ball_volume()
    demo_codes()
    demo_capacity_price()
    print("All assertions passed: the sphere-packing bound holds in every case.")


if __name__ == "__main__":
    main()
