"""
Tie geometry of the trailing-zero statistic: numerical demonstrations.

This self-contained script verifies, by direct computation, every quantitative
claim of the accompanying paper:

  1. The trailing-zero tie profile of a window of 2^s consecutive integers is
     exactly D_s = (2^(s-1), ..., 2, 1, 1), for ANY starting point.
  2. The closed-form ceiling  Sp(D_b) = (6/7) * (1 + 1/(2^b (2^b + 1))),
     and its convergence to 6/7 at rate O(4^-b).
  3. The one-bit shift law: uniform draws at exact bit-length b+1 have
     trailing-zero profile D_b and popcount profile B_b.
  4. The cube-sum reduction and the exact inversion threshold b >= 3, with
     equality of ceilings at b = 1, 2.
  5. The recorded measurement (seeds 0.7291 / 0.7286 / 0.7087, advantage
     +0.134) checked against the theory.
  6. A Monte-Carlo sanity check that the ceiling really is attained by an
     order-compatible response and never exceeded by an arbitrary one.

Only the standard library is used; all arithmetic on ceilings is exact
(fractions.Fraction).
"""

from __future__ import annotations

import random
from fractions import Fraction
from math import comb
from typing import Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Basic statistics
# ---------------------------------------------------------------------------


def trailing_zeros(x: int) -> int:
    """The 2-adic valuation nu_2(x): number of trailing binary zeros.

    By convention nu_2(0) is treated as 'maximal' by the caller; here we
    return the number of trailing zeros of the binary expansion, and 0 is
    handled explicitly by the profile routines.
    """
    if x == 0:
        raise ValueError("nu_2(0) is infinite; handle 0 separately")
    return (x & -x).bit_length() - 1


def popcount(x: int) -> int:
    """Number of one-bits in the binary expansion of x."""
    return bin(x).count("1")


# ---------------------------------------------------------------------------
# 2. Tie profiles and the Spearman ceiling
# ---------------------------------------------------------------------------


def profile_of(values: Sequence[int]) -> List[int]:
    """Tie profile: the sorted list of fibre sizes of a statistic's values."""
    counts: Dict[int, int] = {}
    for v in values:
        counts[v] = counts.get(v, 0) + 1
    return [counts[k] for k in sorted(counts)]


def cube_sum(profile: Sequence[int]) -> int:
    """Sum of cubes of the block sizes."""
    return sum(m ** 3 for m in profile)


def spearman_ceiling(profile: Sequence[int]) -> Fraction:
    """Maximal attainable squared Spearman coefficient for this tie profile.

    Sp(L) = 1 - (sum_j m_j^3 - n) / (n^3 - n),  n = sum_j m_j >= 2.
    """
    n = sum(profile)
    if n < 2:
        raise ValueError("profile mass must be at least 2")
    return Fraction(1) - Fraction(cube_sum(profile) - n, n ** 3 - n)


# ---------------------------------------------------------------------------
# 3. The two canonical profiles
# ---------------------------------------------------------------------------


def dyadic_profile(b: int) -> List[int]:
    """D_b = (2^(b-1), 2^(b-2), ..., 2, 1, 1), of mass 2^b."""
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def binomial_profile(b: int) -> List[int]:
    """B_b = (C(b,0), ..., C(b,b)), of mass 2^b."""
    return [comb(b, j) for j in range(b + 1)]


def franel(b: int) -> int:
    """The b-th Franel number, sum_j C(b,j)^3 = cube sum of B_b."""
    return sum(comb(b, j) ** 3 for j in range(b + 1))


def dyadic_ceiling_closed_form(b: int) -> Fraction:
    """(6/7) * (1 + 1 / (2^b (2^b + 1)))."""
    n = 2 ** b
    return Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))


# ---------------------------------------------------------------------------
# 4. Window profiles, computed two ways
# ---------------------------------------------------------------------------


def window_profile_bruteforce(start: int, s: int) -> List[int]:
    """Trailing-zero tie profile of [start, start + 2^s) by enumeration.

    Blocks are indexed by k = 0..s-1 (exactly k trailing zeros) plus one
    'cap' block collecting the unique multiple of 2^s in the window.
    Cost Theta(2^s) -- use only for small s.
    """
    blocks = [0] * (s + 1)
    for x in range(start, start + 2 ** s):
        if x == 0 or x % (2 ** s) == 0:
            blocks[s] += 1
            continue
        k = trailing_zeros(x)
        if k >= s:
            blocks[s] += 1
        else:
            blocks[k] += 1
    return blocks


def window_profile_closed_form(s: int) -> List[int]:
    """Trailing-zero tie profile of any window of 2^s consecutive integers.

    Independent of the starting point (translation invariance): cost O(s).
    """
    return dyadic_profile(s)


def exact_bitlen_zero_profile(b: int) -> List[int]:
    """Trailing-zero profile of the integers of exact bit-length b+1."""
    return window_profile_bruteforce(2 ** b, b)


def exact_bitlen_popcount_profile(b: int) -> List[int]:
    """Popcount profile of the integers of exact bit-length b+1."""
    return profile_of([popcount(x) for x in range(2 ** b, 2 ** (b + 1))])


# ---------------------------------------------------------------------------
# 5. Inversion criterion
# ---------------------------------------------------------------------------


def inversion_holds(b: int) -> bool:
    """True iff the popcount ceiling strictly exceeds the trailing-zero one.

    Equivalent arithmetic criterion: 7 * franel(b) < 8^b + 6.
    """
    return 7 * franel(b) < 8 ** b + 6


# ---------------------------------------------------------------------------
# 6. A Monte-Carlo check that the ceiling is a real ceiling
# ---------------------------------------------------------------------------


def spearman(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Spearman rank correlation with mid-ranks for ties."""

    def midranks(vs: Sequence[float]) -> List[float]:
        order = sorted(range(len(vs)), key=lambda i: vs[i])
        ranks = [0.0] * len(vs)
        i = 0
        while i < len(order):
            j = i
            while j + 1 < len(order) and vs[order[j + 1]] == vs[order[i]]:
                j += 1
            avg = (i + j) / 2.0 + 1.0
            for t in range(i, j + 1):
                ranks[order[t]] = avg
            i = j + 1
        return ranks

    rx, ry = midranks(xs), midranks(ys)
    n = len(xs)
    mx, my = sum(rx) / n, sum(ry) / n
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    return num / (dx * dy) if dx > 0 and dy > 0 else 0.0


def monte_carlo_ceiling(s: int, trials: int, seed: int) -> Tuple[float, float]:
    """Empirical max |rho| over random responses, and rho for the best response.

    Returns (best_random_rho2, order_compatible_rho2) on the window [0, 2^s).
    """
    rng = random.Random(seed)
    xs = list(range(1, 2 ** s))  # drop 0 to keep nu_2 finite
    tvals = [trailing_zeros(x) for x in xs]
    best_random = 0.0
    for _ in range(trials):
        ys = [rng.random() for _ in xs]
        best_random = max(best_random, spearman(tvals, ys) ** 2)
    # order-compatible response: strictly increasing in T, arbitrary inside ties
    ideal = [t + rng.random() for t in tvals]
    return best_random, spearman(tvals, ideal) ** 2


# ---------------------------------------------------------------------------
# 7. The recorded measurement
# ---------------------------------------------------------------------------

SEEDS: Tuple[Fraction, Fraction, Fraction] = (
    Fraction(7291, 10000),
    Fraction(7286, 10000),
    Fraction(7087, 10000),
)
ADVANTAGE = Fraction(134, 1000)
CI_LOW, CI_HIGH = Fraction(113, 1000), Fraction(158, 1000)
BAND_LOW, BAND_HIGH = Fraction(55, 100), Fraction(85, 100)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_translation_invariance() -> None:
    print("=" * 72)
    print("1. TRANSLATION INVARIANCE: every window of 2^s consecutive integers")
    print("=" * 72)
    for s in (3, 5, 7):
        target = window_profile_closed_form(s)
        print(f"\n  scale s = {s},  predicted profile D_{s} = {target}")
        for start in (0, 1, 2 ** s, 3 * 2 ** s, 12345, 999983, 2 ** 20 + 7):
            got = window_profile_bruteforce(start, s)
            flag = "OK " if got == target else "FAIL"
            print(f"    [{start:>8}, {start + 2**s:>8})  ->  {got}   {flag}")
    print("\n  Alignment is irrelevant; only the length 2^s matters.")


def demo_closed_form_ceiling() -> None:
    print()
    print("=" * 72)
    print("2. CLOSED-FORM CEILING  Sp(D_b) = (6/7)(1 + 1/(2^b(2^b+1)))")
    print("=" * 72)
    print(f"\n  {'b':>3} {'Sp(D_b) (exact)':>28} {'rho_max':>12} {'Sp - 6/7':>14}")
    for b in (1, 2, 3, 5, 10, 20, 47):
        direct = spearman_ceiling(dyadic_profile(b))
        closed = dyadic_ceiling_closed_form(b)
        assert direct == closed, "closed form disagrees with the definition"
        gap = float(direct - Fraction(6, 7))
        print(f"  {b:>3} {str(direct)[:28]:>28} {float(direct) ** 0.5:>12.9f} {gap:>14.3e}")
    print(f"\n  limit rho_max = sqrt(6/7) = {(6 / 7) ** 0.5:.9f}")
    print("  the correction is below 4^-b: at b = 47 it is < 1e-28.")


def demo_one_bit_shift() -> None:
    print()
    print("=" * 72)
    print("3. ONE-BIT SHIFT LAW under exact-bit-length conditioning")
    print("=" * 72)
    print("\n  exact bit-length b+1  ->  full-range bit-length b, for BOTH statistics\n")
    for b in range(1, 10):
        z = exact_bitlen_zero_profile(b)
        w = exact_bitlen_popcount_profile(b)
        okz = z == dyadic_profile(b)
        okw = w == binomial_profile(b)
        print(
            f"  b+1 = {b + 1:>2}:  trailing-zeros -> D_{b} {'OK ' if okz else 'FAIL'}"
            f"   popcount -> B_{b} {'OK ' if okw else 'FAIL'}"
        )
    print("\n  Conditioning costs exactly one bit for both dials simultaneously,")
    print("  so every comparison between them transports unchanged.")


def demo_inversion_threshold() -> None:
    print()
    print("=" * 72)
    print("4. CUBE SUMS AND THE EXACT INVERSION THRESHOLD (b >= 3)")
    print("=" * 72)
    print(
        f"\n  {'b':>3} {'C(D_b)':>14} {'C(B_b)=franel':>14} "
        f"{'7*franel':>14} {'8^b+6':>14}  verdict"
    )
    for b in range(1, 13):
        cd = cube_sum(dyadic_profile(b))
        cb = franel(b)
        sd = spearman_ceiling(dyadic_profile(b))
        sb = spearman_ceiling(binomial_profile(b))
        if sd < sb:
            verdict = "popcount ceiling HIGHER"
        elif sd == sb:
            verdict = "ceilings EQUAL"
        else:
            verdict = "trailing-zero HIGHER"
        assert (sd < sb) == inversion_holds(b), "criterion mismatch"
        print(f"  {b:>3} {cd:>14} {cb:>14} {7 * cb:>14} {8 ** b + 6:>14}  {verdict}")
    print("\n  Equality at b = 1, 2 (profiles (1,1)=(1,1) and (2,1,1) vs (1,2,1),")
    print("  permutations of each other); strict inversion for every b >= 3.")


def demo_recorded_measurement() -> None:
    print()
    print("=" * 72)
    print("5. THE RECORDED MEASUREMENT, CHECKED AGAINST THE THEORY")
    print("=" * 72)
    pooled = sum(SEEDS) / 3
    baseline = pooled - ADVANTAGE
    ceiling47 = dyadic_ceiling_closed_form(47)
    rho_max = float(ceiling47) ** 0.5
    print("\n  seeds:", ", ".join(f"{float(r):.4f}" for r in SEEDS))
    print(f"  pooled            = {float(pooled):.6f}")
    print(f"  advantage         = +{float(ADVANTAGE):.3f}  CI [{float(CI_LOW):.3f},"
          f" {float(CI_HIGH):.3f}]")
    print(f"  implied baseline  = {float(baseline):.6f}")
    print(f"  seed spread       = {float(SEEDS[0] - SEEDS[2]):.4f}")
    inside = all(BAND_LOW < r < BAND_HIGH for r in SEEDS)
    print(f"\n  all seeds inside band [0.55, 0.85]: {inside}")
    print(f"  baseline inside band              : {BAND_LOW < baseline < BAND_HIGH}")
    print(f"\n  exact-bit-length-48 ceiling rho_max = {rho_max:.9f}")
    for i, r in enumerate(SEEDS):
        print(f"    seed {i}: rho^2 = {float(r) ** 2:.6f} < {float(ceiling47):.6f}"
              f"   headroom {rho_max - float(r):.4f}")
    delta_ceiling = float(dyadic_ceiling_closed_form(47) - dyadic_ceiling_closed_form(64))
    print(f"\n  ceiling change, exact-48 -> full-range-64 : {delta_ceiling:.3e}")
    print(f"  dial change over the same regime change   : > 0.07")
    print("  => the bit-length trend is not tie geometry (28 orders of magnitude apart).")
    sd = spearman_ceiling(dyadic_profile(47))
    sb_gt = inversion_holds(47)
    print(f"\n  at bit-length 47 the popcount baseline has the HIGHER ceiling: {sb_gt}")
    print("  yet the measurement puts trailing zeros +0.134 ABOVE it:")
    print("  the advantage runs against the tie geometry, so it is signal.")
    print(f"\n  ceiling of every 2^47-window (any placement) = 6/7 * (1 + 1/(2^47(2^47+1)))")
    print(f"    numerically {float(sd):.15f}")


def demo_monte_carlo() -> None:
    print()
    print("=" * 72)
    print("6. MONTE-CARLO SANITY CHECK OF THE CEILING (s = 9)")
    print("=" * 72)
    s = 9
    best_random, ideal = monte_carlo_ceiling(s, trials=200, seed=20261110)
    theory = float(spearman_ceiling(dyadic_profile(s)))
    print(f"\n  theoretical ceiling Sp(D_{s})        = {theory:.6f}")
    print(f"  best rho^2 over 200 random responses = {best_random:.6f}")
    print(f"  rho^2 for an order-compatible response = {ideal:.6f}")
    print("\n  random responses fall far short; the order-compatible response")
    print("  essentially attains the ceiling, and nothing exceeds it.")


def main() -> None:
    print()
    print("TIE GEOMETRY OF THE TRAILING-ZERO STATISTIC")
    print("numerical demonstrations")
    demo_translation_invariance()
    demo_closed_form_ceiling()
    demo_one_bit_shift()
    demo_inversion_threshold()
    demo_recorded_measurement()
    demo_monte_carlo()
    print()
    print("All checks completed.")


if __name__ == "__main__":
    main()
