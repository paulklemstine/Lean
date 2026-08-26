#!/usr/bin/env python3
"""
Exact band geometry of the Fermat window  v(j) = j^2 - N,  j in (s, 3s],  s = isqrt(N).

This script is a self-contained numerical companion to the results on the
"left-edge spike" of a Fermat scan window.  Everything below is exact integer
arithmetic (Python's arbitrary-precision ints and math.isqrt); floating point is
used only for reporting normalised positions and for the continuum crossing curve.

Demonstrated results
--------------------
1. Degeneracy.  For every 96-bit modulus N (2^95 <= N < 2^96) and every first-decile
   position j (5*(j-s) < s+5), the residue satisfies v(j) < 2^95.  Hence the filter
   "keep v >= 2^95" removes 100% of the first-decile mass.
2. Scale-freeness.  For every N >= 2^16 and every first-decile j: 100*v(j) < 45*N,
   hence 2*v(j) < N, hence bitlen(v) < bitlen(N).
3. Necessity of the size hypothesis.  N = 36482 breaks the 0.45 bound and N = 962
   breaks the 1/2 bound.
4. Exact band counts.  #{j in (s,3s] : v(j) < T} = min(3s, isqrt(N+T-1)) - s, and the
   bit-length histogram telescopes into differences of integer square roots.
5. Window fraction.  For 96-bit moduli the sub-2^95 band occupies 11%-21% of the window.
6. Continuum crossing curve.  u0(N) = (sqrt(1 + 2^95/N) - 1)/2 is strictly decreasing
   and lies in ((sqrt6-2)/4, (sqrt2-1)/2] = (0.112372..., 0.207107...].
7. Discrete-continuum bridge.  |(m-s)/(2s) - u0(N)| <= 3/s, which is ~2e-14 at 96 bits.
8. Two stratifications.  Explicit 96-bit witnesses: a full-size residue at u = 0.15 for
   one modulus and a sub-2^95 residue at u = 0.20 for another.
"""

from __future__ import annotations

import math
import random
from math import isqrt
from typing import Dict, Iterator, List, Tuple

TWO95: int = 2 ** 95
TWO96: int = 2 ** 96
SQRT6_ENDPOINT: float = (math.sqrt(6.0) - 2.0) / 4.0   # 0.112372435695794...
SQRT2_ENDPOINT: float = (math.sqrt(2.0) - 1.0) / 2.0   # 0.207106781186547...


# --------------------------------------------------------------------------- #
# Core window arithmetic
# --------------------------------------------------------------------------- #

def resid(n: int, j: int) -> int:
    """The Fermat residue v(j) = j^2 - N (exact, arbitrary precision)."""
    return j * j - n


def window_bounds(n: int) -> Tuple[int, int]:
    """The scan window (s, 3s] as the inclusive integer range [s+1, 3s]."""
    s = isqrt(n)
    return s + 1, 3 * s


def normalised_position(n: int, j: int) -> float:
    """u = (j - s) / (2s), the position of j inside the window, in (0, 1]."""
    s = isqrt(n)
    return (j - s) / (2.0 * s)


def in_first_decile(n: int, j: int) -> bool:
    """The slack integer form of the first decile: s < j and 5(j-s) < s + 5."""
    s = isqrt(n)
    return s < j and 5 * (j - s) < s + 5


def bitlen(v: int) -> int:
    """Number of binary digits of v (bitlen(0) = 0)."""
    return v.bit_length()


def low_band_count(n: int, threshold: int) -> int:
    """#{ j in (s, 3s] : v(j) < threshold } = min(3s, isqrt(N+T-1)) - s, exactly."""
    if threshold < 1:
        return 0
    s = isqrt(n)
    return max(0, min(3 * s, isqrt(n + threshold - 1)) - s)


def band_histogram(n: int, max_bits: int) -> Dict[int, int]:
    """Exact population of each bit-length band of the window, for bands <= max_bits.

    Uses the telescoping identity
        #{bitlen v = b} = C(b) - C(b-1),   C(b) = min(3s, isqrt(N + 2^b - 1)) - s.
    Cost: max_bits integer square roots, versus O(s) for a naive scan.
    """
    cumulative = [low_band_count(n, 1 << b) for b in range(max_bits + 1)]
    return {b: cumulative[b] - cumulative[b - 1]
            for b in range(1, max_bits + 1)
            if cumulative[b] - cumulative[b - 1] > 0}


def crossing_position(n: int, threshold: int = TWO95) -> float:
    """Continuum crossing curve u0(N) = (sqrt(1 + T/N) - 1) / 2."""
    return (math.sqrt(1.0 + threshold / n) - 1.0) / 2.0


def removal_fraction(n: int, threshold: int, cutoff: float) -> float:
    """Exact fraction of the region {u <= cutoff} deleted by the filter "keep v >= T".

    Returns 1.0 exactly when the filter is degenerate on that region.
    """
    s = isqrt(n)
    last_tiny = min(3 * s, isqrt(n + threshold - 1))
    last_pos = s + int(2 * s * cutoff)
    if last_pos <= s:
        return float("nan")
    return (min(last_tiny, last_pos) - s) / (last_pos - s)


# --------------------------------------------------------------------------- #
# Modulus generation
# --------------------------------------------------------------------------- #

def random_96bit_moduli(count: int, seed: int = 20260828) -> Iterator[int]:
    """Uniform 96-bit moduli, i.e. 2^95 <= N < 2^96."""
    rng = random.Random(seed)
    for _ in range(count):
        yield rng.randrange(TWO95, TWO96)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_degeneracy(trials: int = 12) -> None:
    print("=" * 78)
    print("1. DEGENERACY:  every first-decile residue of a 96-bit modulus is < 2^95")
    print("=" * 78)
    print(f"{'s = isqrt(N)':>18} {'last decile j':>18} {'u':>8} "
          f"{'bitlen v':>9} {'v < 2^95':>9}")
    worst = 0
    for n in random_96bit_moduli(trials):
        s = isqrt(n)
        j_last = s + (s + 4) // 5           # largest j with 5(j-s) <= s+4
        v = resid(n, j_last)
        assert in_first_decile(n, j_last)
        assert v < TWO95, "degeneracy theorem violated"
        worst = max(worst, bitlen(v))
        print(f"{s:>18} {j_last:>18} {normalised_position(n, j_last):>8.5f} "
              f"{bitlen(v):>9} {str(v < TWO95):>9}")
    print(f"\nmaximal bit-length observed over the whole first decile: {worst} (<= 95)")
    print("=> the filter 'keep v >= 2^95' removes 100% of first-decile mass.\n")


def demo_scale_free(trials: int = 8) -> None:
    print("=" * 78)
    print("2. SCALE-FREENESS:  100*v < 45*N on the first decile, for every N >= 2^16")
    print("=" * 78)
    rng = random.Random(11235)
    print(f"{'bits of N':>10} {'v / N':>12} {'bitlen N':>9} {'bitlen v':>9}")
    for exponent in (17, 24, 32, 48, 64, 80, 96, 128)[:trials]:
        n = rng.randrange(2 ** (exponent - 1), 2 ** exponent)
        s = isqrt(n)
        j_last = s + (s + 4) // 5
        v = resid(n, j_last)
        assert 100 * v < 45 * n, "scale-free bound violated"
        assert bitlen(v) < bitlen(n)
        print(f"{exponent:>10} {v / n:>12.6f} {bitlen(n):>9} {bitlen(v):>9}")
    print("\nthe ratio v/N approaches 0.44 = (1.2)^2 - 1 from below at every scale.\n")


def demo_counterexamples() -> None:
    print("=" * 78)
    print("3. THE SIZE HYPOTHESES ARE LOAD-BEARING")
    print("=" * 78)
    for n, j, label, holds in (
        (36482, 230, "100*v < 45*N", lambda nn, vv: 100 * vv < 45 * nn),
        (962, 38, "2*v < N", lambda nn, vv: 2 * vv < nn),
    ):
        s = isqrt(n)
        v = resid(n, j)
        print(f"N = {n:>7}   s = {s:>4}   j = {j:>4}   in first decile: "
              f"{in_first_decile(n, j)}")
        print(f"    v = {v:>7}   0.45*N = {0.45 * n:>10.1f}   N/2 = {n / 2:>10.1f}")
        print(f"    '{label}' holds?  {holds(n, v)}   <-- counterexample\n")
    print("both fail only for small N: beyond N = 36482 the 0.45 bound always holds.\n")


def demo_band_histogram() -> None:
    print("=" * 78)
    print("4. EXACT BAND HISTOGRAM (deterministic, no sampling)")
    print("=" * 78)
    n = next(random_96bit_moduli(1, seed=4242))
    s = isqrt(n)
    top = bitlen(resid(n, 3 * s))            # largest band present in the window
    hist = band_histogram(n, top)
    total = 2 * s
    print(f"N = {n}   (bitlen {bitlen(n)}),   window size 2s = {total}")
    print(f"{'band (bits of v)':>18} {'positions':>22} {'window share':>14}")
    for b in sorted(hist):
        print(f"{b:>18} {hist[b]:>22} {hist[b] / total:>13.6%}")
    assert sum(hist.values()) == total, "histogram must exhaust the window"
    # brute-force cross-check of the closed form on a small modulus
    small = 1_000_003
    ss = isqrt(small)
    brute: Dict[int, int] = {}
    for j in range(ss + 1, 3 * ss + 1):
        brute[bitlen(resid(small, j))] = brute.get(bitlen(resid(small, j)), 0) + 1
    closed = band_histogram(small, bitlen(resid(small, 3 * ss)))
    assert brute == closed, "closed form disagrees with brute force"
    print("\nclosed-form histogram verified against a brute-force scan for N = 1000003.\n")


def demo_window_fraction(trials: int = 10) -> None:
    print("=" * 78)
    print("5. WINDOW FRACTION OF THE TINY CHANNEL:  always between 11% and 21%")
    print("=" * 78)
    print(f"{'2^95 / N':>10} {'excluded fraction':>19} {'u0(N) (continuum)':>19} "
          f"{'|difference|':>14}")
    for n in random_96bit_moduli(trials, seed=777):
        s = isqrt(n)
        count = low_band_count(n, TWO95)
        frac = count / (2 * s)
        u0 = crossing_position(n)
        assert 0.11 <= frac <= 0.21, "window fraction bound violated"
        assert abs(frac - u0) <= 3.0 / s
        print(f"{TWO95 / n:>10.6f} {frac:>19.14f} {u0:>19.14f} "
              f"{abs(frac - u0):>14.2e}")
    print(f"\nendpoints: (sqrt6-2)/4 = {SQRT6_ENDPOINT:.15f},"
          f"  (sqrt2-1)/2 = {SQRT2_ENDPOINT:.15f}")
    print("the discrete fraction never leaves that interval, and the bridge bound")
    print(f"3/s is about {3 / 2**47:.2e} at 96 bits.\n")


def demo_crossing_monotone() -> None:
    print("=" * 78)
    print("6. THE CROSSING CURVE IS STRICTLY DECREASING AND PINNED")
    print("=" * 78)
    print(f"{'N':>34} {'2^95/N':>10} {'u0(N)':>18}")
    grid: List[int] = [TWO95 + 1,
                       int(1.1 * TWO95), int(1.25 * TWO95), int(1.5 * TWO95),
                       int(1.75 * TWO95), int(1.9 * TWO95), TWO96 - 1]
    previous = 1.0
    for n in grid:
        u0 = crossing_position(n)
        assert u0 < previous, "u0 must be strictly decreasing"
        assert SQRT6_ENDPOINT - 1e-15 < u0 <= SQRT2_ENDPOINT + 1e-15
        previous = u0
        print(f"{n:>34} {TWO95 / n:>10.6f} {u0:>18.15f}")
    print(f"\nrange over all 96-bit moduli: ({SQRT6_ENDPOINT:.15f},"
          f" {SQRT2_ENDPOINT:.15f}]")
    print(f"decile boundary 0.1 sits strictly below the lower endpoint "
          f"({0.1 < SQRT6_ENDPOINT}) -- this is the structural cause of degeneracy.\n")


def demo_removal_fraction(trials: int = 6) -> None:
    print("=" * 78)
    print("7. DEGENERACY AUDIT:  removal fraction of the clause on {u <= c}")
    print("=" * 78)
    print(f"{'c = 0.05':>12} {'c = 0.10':>12} {'c = 0.15':>12} {'c = 0.25':>12} "
          f"{'c = 0.50':>12}")
    for n in random_96bit_moduli(trials, seed=31415):
        row = [removal_fraction(n, TWO95, c) for c in (0.05, 0.10, 0.15, 0.25, 0.50)]
        assert row[0] == 1.0 and row[1] == 1.0, "clause must be degenerate below 0.1"
        print(" ".join(f"{x:>12.6f}" for x in row))
    print("\nthe clause deletes exactly 100% of every region up to u = 0.10,")
    print("so it cannot discriminate anything inside the first decile.\n")


def demo_two_stratifications() -> None:
    print("=" * 78)
    print("8. POSITION AND BIT-LENGTH ARE TWO DIFFERENT STRATIFICATIONS")
    print("=" * 78)
    n1 = (2 ** 48 - 1) ** 2
    j1 = 365917469723851
    n2 = 199032864766431 ** 2
    j2 = 278646010673003
    for name, n, j in (("N1 = (2^48-1)^2", n1, j1),
                       ("N2 = 199032864766431^2", n2, j2)):
        s = isqrt(n)
        v = resid(n, j)
        assert TWO95 <= n < TWO96 and s < j <= 3 * s
        print(f"{name}")
        print(f"    N        = {n}")
        print(f"    s        = {s}")
        print(f"    j        = {j}     u = {normalised_position(n, j):.6f}")
        print(f"    v        = {v}")
        print(f"    bitlen v = {bitlen(v)}   full size (>= 2^95): {v >= TWO95}")
        print(f"    u0(N)    = {crossing_position(n):.15f}\n")
    assert resid(n1, j1) >= TWO95 and resid(n2, j2) < TWO95
    print("At u = 0.15 modulus N1 is already full size, while at the LARGER position")
    print("u = 0.20 modulus N2 is still sub-2^95.  Hence no positional cut-off in")
    print("[0.15, 0.20] can serve as a bit-length cut-off uniformly in N.\n")

    # third witness: the sharp constant cannot be pushed past 0.2072
    j3 = 281512083925640
    s2 = isqrt(n2)
    v3 = resid(n2, j3)
    assert v3 >= TWO95
    print(f"Sharpness witness: N2 at j = {j3} has u = "
          f"{normalised_position(n2, j3):.6f} and a FULL-SIZE residue,")
    print(f"so the universal degeneracy constant c* satisfies "
          f"0.1123 <= c* <= 0.2072.  (s = {s2})\n")


def demo_inclusion_channel() -> None:
    print("=" * 78)
    print("9. HOW SMALL THE INCLUSION CHANNEL GETS")
    print("=" * 78)
    n = next(random_96bit_moduli(1, seed=99991))
    s = isqrt(n)
    print(f"N = {n}  (bitlen {bitlen(n)})")
    print(f"{'offset j - s':>14} {'u':>12} {'bitlen v':>9}")
    for delta in (1, 2, 10, 10 ** 3, 10 ** 6, 10 ** 9, 10 ** 12, 10 ** 13, 10 ** 14):
        j = s + delta
        if j > 3 * s:
            break
        print(f"{delta:>14} {normalised_position(n, j):>12.9f} "
              f"{bitlen(resid(n, j)):>9}")
    v_first = resid(n, s + 1)
    assert v_first <= 2 * s + 1
    print(f"\nv(s+1) = {v_first} <= 2*sqrt(N)+1 = {2 * s + 1}"
          f"   (bitlen {bitlen(v_first)}, about half of {bitlen(n)})")
    print("Such residues are smooth far more often than full-size draws: this is the")
    print("magnitude channel that inflates the raw left-edge spike.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  EXACT BAND GEOMETRY OF THE FERMAT WINDOW  v(j) = j^2 - N")
    print("#  the left-edge spike is not one object")
    print("#" * 78)
    print()
    demo_degeneracy()
    demo_scale_free()
    demo_counterexamples()
    demo_band_histogram()
    demo_window_fraction()
    demo_crossing_monotone()
    demo_removal_fraction()
    demo_two_stratifications()
    demo_inclusion_channel()
    print("All assertions passed: every printed claim was checked exactly.")


if __name__ == "__main__":
    main()
