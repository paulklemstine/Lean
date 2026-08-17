"""
Calibration equals maximal robustness: numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type hinted.

The script demonstrates, with exact rational arithmetic wherever exactness matters:

  1. Quota ladders of a seed ensemble and the median law of a measured knee set.
  2. The parity law of calibration: a rung reads 1/2 on coin-flip seeds iff 2m = n+1.
  3. The calibration defect of an even ensemble, its sandwich, and its 1/(2*sqrt(pi)) limit.
  4. The exact breakdown number beta(n, m) = min(m - 1, n - m), verified by brute-force
     adversarial search over corruption sets.
  5. The contamination curve: achievable readings are exactly the clean bracket.
  6. What a fourth seed does (and does not) buy, and what a fifth does.
  7. Condorcet convergence and the exact certification crossing at 47 seeds for p = 2/3.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from math import comb, pi, sqrt
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------------
# 1. Quota ladders
# ----------------------------------------------------------------------------------


def pass_set(knees: Sequence[int], budget: int) -> Tuple[int, ...]:
    """Indices of seeds whose knee is at or below `budget`."""
    return tuple(i for i, k in enumerate(knees) if k <= budget)


def quota_budget(knees: Sequence[int], m: int) -> int:
    """The m-th rung of the quota ladder: least budget at which >= m seeds clear the bar.

    Equivalently the m-th smallest knee (and 0 for m = 0).
    """
    if m <= 0:
        return 0
    if m > len(knees):
        raise ValueError("quota exceeds ensemble size")
    return sorted(knees)[m - 1]


def ladder(knees: Sequence[int]) -> List[int]:
    """All rungs Q(1), ..., Q(n)."""
    return [quota_budget(knees, m) for m in range(1, len(knees) + 1)]


# ----------------------------------------------------------------------------------
# 2. The rung distribution function (binomial upper tail)
# ----------------------------------------------------------------------------------


def rung_prob(n: int, m: int, p: Fraction) -> Fraction:
    """P(at least m of n independent seeds clear the bar), each with probability p.

    Exact rational arithmetic; O(n - m) terms.
    """
    if m <= 0:
        return Fraction(1)
    if m > n:
        return Fraction(0)
    q = 1 - p
    total = Fraction(0)
    for j in range(m, n + 1):
        total += comb(n, j) * p**j * q ** (n - j)
    return total


def tail_count(n: int, m: int) -> int:
    """Number of n-seed outcomes with at least m passes: sum_{j>=m} C(n, j)."""
    return sum(comb(n, j) for j in range(m, n + 1))


def is_calibrated(n: int, m: int) -> bool:
    """Does rung m read exactly 1/2 on coin-flip seeds?"""
    return rung_prob(n, m, Fraction(1, 2)) == Fraction(1, 2)


def defect(r: int) -> Fraction:
    """Calibration defect of a 2r-seed ensemble: C(2r, r) / 2^(2r+1)."""
    return Fraction(comb(2 * r, r), 2 ** (2 * r + 1))


# ----------------------------------------------------------------------------------
# 3. Robustness: breakdown numbers and contamination curves
# ----------------------------------------------------------------------------------


def breakdown_number(n: int, m: int) -> int:
    """The two-sided breakdown number of the m-th rung of an n-seed ensemble."""
    return min(m - 1, n - m)


def contamination_bracket(knees: Sequence[int], m: int, c: int) -> Tuple[int, int]:
    """Clean bracket [Q(m - c), Q(m + c)] of achievable readings at contamination level c."""
    n = len(knees)
    if c > breakdown_number(n, m):
        raise ValueError("contamination level exceeds the breakdown number")
    return quota_budget(knees, m - c), quota_budget(knees, m + c)


def achievable_readings(
    knees: Sequence[int], m: int, c: int, alternatives: Iterable[int]
) -> List[int]:
    """Brute-force search: every reading of rung m obtainable by corrupting <= c seeds.

    Corrupted seeds may take any value in `alternatives`.
    """
    n = len(knees)
    found: set[int] = set()
    alts = list(alternatives)
    for size in range(c + 1):
        for corrupted in combinations(range(n), size):
            for values in product(alts, repeat=size):
                perturbed = list(knees)
                for idx, v in zip(corrupted, values):
                    perturbed[idx] = v
                found.add(quota_budget(perturbed, m))
    return sorted(found)


# ----------------------------------------------------------------------------------
# 4. The four-seed reading
# ----------------------------------------------------------------------------------


def reading_four(x: int, base: Sequence[int] = (160, 224, 256)) -> Fraction:
    """Mean of the two middle order statistics of `base` together with a fourth knee x."""
    sample = sorted(list(base) + [x])
    return Fraction(sample[1] + sample[2], 2)


def bias_four(x: int, centre: int = 224) -> Fraction:
    """|four-seed reading - three-seed median|."""
    value = reading_four(x)
    return value - centre if value >= centre else centre - value


# ----------------------------------------------------------------------------------
# 5. Condorcet convergence and certification
# ----------------------------------------------------------------------------------


def miss_probability(r: int, p: Fraction) -> Fraction:
    """1 - P(median rung of a (2r+1)-seed ensemble reads 'pass')."""
    return 1 - rung_prob(2 * r + 1, r + 1, p)


def crude_rate(r: int, p: Fraction) -> Fraction:
    """Geometric Condorcet bound 2(1-p)(4p(1-p))^r."""
    return 2 * (1 - p) * (4 * p * (1 - p)) ** r


def sharp_rate(r: int, p: Fraction) -> Fraction:
    """Sharpened bound C(2r+1, r) (p(1-p))^{r+1} / (2p - 1)."""
    return Fraction(comb(2 * r + 1, r)) * (p * (1 - p)) ** (r + 1) / (2 * p - 1)


def first_crossing(p: Fraction, epsilon: Fraction, limit: int = 200) -> int:
    """Least ensemble size 2r+1 whose median rung misses with probability <= epsilon."""
    for r in range(limit):
        if miss_probability(r, p) <= epsilon:
            return 2 * r + 1
    raise RuntimeError("no crossing below the search limit")


def first_crossing_of_bound(
    bound_name: str, p: Fraction, epsilon: Fraction, limit: int = 200
) -> int:
    """Least ensemble size at which the named bound certifies the target miss level."""
    fn = {"crude": crude_rate, "sharp": sharp_rate}[bound_name]
    for r in range(limit):
        if fn(r, p) <= epsilon:
            return 2 * r + 1
    raise RuntimeError("no crossing below the search limit")


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------

RULE = "=" * 84


def demo_median_law() -> None:
    print(RULE)
    print("1. THE MEASURED KNEE SETS AND THE 7/8 MEDIAN LAW")
    print(RULE)
    cells: List[Tuple[str, int, int, Tuple[int, int, int]]] = [
        ("short context", 4, 1024, (96, 112, 128)),
        ("long context", 4, 2048, (160, 224, 256)),
    ]
    for name, d, ctx, knees in cells:
        scale = d * ctx // 32
        rungs = ladder(knees)
        median = rungs[1]
        multiples = [Fraction(k, scale) for k in sorted(knees)]
        print(f"\n{name}:  d = {d}, L = {ctx},  natural scale P = d*L/32 = {scale}")
        print(f"  knees                : {sorted(knees)}")
        print(f"  as multiples of P    : {[str(x) for x in multiples]}")
        print(f"  ladder Q(1),Q(2),Q(3): {rungs}")
        print(f"  spread Q(3) - Q(1)   : {rungs[2] - rungs[0]}  = {Fraction(rungs[2]-rungs[0], scale)} P")
        print(f"  median               : {median} = {Fraction(median, scale)} * P", end="")
        print("   <-- exactly 7/8 P" if Fraction(median, scale) == Fraction(7, 8) else "")
        assert Fraction(median, scale) == Fraction(7, 8)
    print("\n  Four pre-registered point predictions for the third long-context seed were")
    print("  224, 240, 256, 192; the measured value was 160, refuting all four, while the")
    print("  median of the completed three-seed set landed exactly on 7/8 * P = 224.")


def demo_parity_law() -> None:
    print()
    print(RULE)
    print("2. THE PARITY LAW OF CALIBRATION:  R_n(m, 1/2) = 1/2  <=>  2m = n + 1")
    print(RULE)
    for n in range(1, 9):
        marks: List[str] = []
        for m in range(1, n + 1):
            value = rung_prob(n, m, Fraction(1, 2))
            flag = "*" if value == Fraction(1, 2) else " "
            marks.append(f"m={m}:{str(value):>9}{flag}")
            assert (value == Fraction(1, 2)) == (2 * m == n + 1)
        print(f"n = {n}:  " + "  ".join(marks))
    print("\n  '*' marks a calibrated rung.  Odd n: exactly one, the median. Even n: none.")
    print("\n  Reflection identity T(n,m) + T(n,n+1-m) = 2^n (a spot check):")
    for n, m in [(5, 2), (6, 3), (7, 4), (8, 5)]:
        lhs = tail_count(n, m) + tail_count(n, n + 1 - m)
        print(f"    n={n}, m={m}:  {tail_count(n,m)} + {tail_count(n,n+1-m)} = {lhs} = 2^{n}")
        assert lhs == 2**n


def demo_defect() -> None:
    print()
    print(RULE)
    print("3. THE CALIBRATION DEFECT OF AN EVEN ENSEMBLE")
    print(RULE)
    print("  central rungs of a 2r-seed ensemble read 1/2 +- delta_r,  delta_r = C(2r,r)/2^(2r+1)")
    print()
    header = f"{'r':>4} {'n=2r':>5} {'delta_r':>12} {'lower':>10} {'upper':>10} {'delta*sqrt(r)':>15}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for r in [1, 2, 3, 5, 10, 50, 200, 1000]:
        d = defect(r)
        lo = 1.0 / (2.0 * sqrt(4 * r + 1))
        hi = 1.0 / (2.0 * sqrt(3 * r + 1))
        assert lo <= float(d) <= hi
        upper = rung_prob(2 * r, r, Fraction(1, 2))
        lower = rung_prob(2 * r, r + 1, Fraction(1, 2))
        assert upper - Fraction(1, 2) == d and Fraction(1, 2) - lower == d
        assert (upper + lower) / 2 == Fraction(1, 2)  # averaging repairs calibration exactly
        print(f"{r:>4} {2*r:>5} {float(d):>12.6f} {lo:>10.6f} {hi:>10.6f} {float(d)*sqrt(r):>15.6f}")
    print(f"\n  limit of delta_r * sqrt(r) = 1/(2*sqrt(pi)) = {1/(2*sqrt(pi)):.6f}")
    print(f"  bracket endpoints          : 1/(2*sqrt(5)) = {1/(2*sqrt(5)):.6f},"
          f"  1/(2*sqrt(3)) = {1/(2*sqrt(3)):.6f}")
    print("  (consistency of bracket and limit is exactly the statement 3 <= pi <= 5)")
    partial = sum(float(defect(r)) for r in range(1, 20001))
    print(f"  sum of delta_r for r <= 20000 = {partial:.3f}  (the series diverges)")


def demo_breakdown() -> None:
    print()
    print(RULE)
    print("4. THE EXACT BREAKDOWN NUMBER  beta(n, m) = min(m - 1, n - m)")
    print(RULE)
    for n in range(1, 8):
        row = "  ".join(f"m={m}: {breakdown_number(n, m)}" for m in range(1, n + 1))
        print(f"n = {n}:  {row}")
    print("\n  Guarantee rung (m = n) and best-case rung (m = 1) always have breakdown 0.")
    print("  Odd n = 2r+1: the unique maximiser is the median m = r+1, with beta = r.")
    print("  Even n = 2r : the maximum r-1 is attained twice, at m = r and m = r+1.")

    knees = [160, 224, 256]
    print("\n  Adversarial verification on the measured sample {160, 224, 256}:")
    for m in (1, 2, 3):
        beta = breakdown_number(3, m)
        clean = quota_budget(knees, m)
        # one corrupted seed, allowed to take an extreme value in either direction
        readings = achievable_readings(knees, m, 1, alternatives=[0, 10**6])
        print(f"    rung m={m}: clean reading {clean:>4}, beta = {beta}, "
              f"readings under 1 corrupted seed: min {min(readings)}, max {max(readings)}")
    print("    -> rungs 1 and 3 are driven to 0 / above any bound by a single bad seed;")
    print("       the median stays inside the clean range [160, 256].")


def demo_contamination_curve() -> None:
    print()
    print(RULE)
    print("5. THE CONTAMINATION CURVE: ACHIEVABLE READINGS = THE CLEAN BRACKET")
    print(RULE)
    knees = [160, 224, 256]
    lo, hi = contamination_bracket(knees, 2, 1)
    reachable = achievable_readings(knees, 2, 1, alternatives=[0, 100, 160, 200, 224, 256, 10**6])
    print(f"  sample {knees}, median rung m = 2, contamination level c = 1")
    print(f"  predicted bracket [Q(1), Q(3)] = [{lo}, {hi}]")
    print(f"  brute-force reachable readings : {reachable}")
    print(f"  both endpoints attained        : {lo in reachable and hi in reachable}")
    print(f"  maximal bias                   : -{224 - lo} / +{hi - 224}  (asymmetric!)")
    assert all(lo <= v <= hi for v in reachable)

    print("\n  A larger example, five seeds, median rung m = 3, radius c = 1 and c = 2:")
    five = [40, 55, 70, 90, 200]
    for c in (1, 2):
        blo, bhi = contamination_bracket(five, 3, c)
        got = achievable_readings(five, 3, c, alternatives=[0, 45, 60, 80, 150, 10**6])
        print(f"    c = {c}: bracket [{blo}, {bhi}], reachable min {min(got)}, max {max(got)}")
        assert min(got) == blo and max(got) == bhi


def demo_fourth_seed() -> None:
    print()
    print(RULE)
    print("6. WHAT A FOURTH SEED BUYS (AND WHAT A FIFTH DOES)")
    print(RULE)
    print("  four-seed reading = mean of the two middle order statistics of {160,224,256,x}\n")
    print(f"  {'x':>6} {'reading':>10} {'bias':>8}")
    print("  " + "-" * 26)
    for x in [0, 100, 160, 176, 192, 208, 224, 240, 256, 300, 1000]:
        print(f"  {x:>6} {str(reading_four(x)):>10} {str(bias_four(x)):>8}")
    assert bias_four(224) == 0
    assert all(bias_four(x) > 0 for x in range(0, 400) if x != 224)
    assert all(bias_four(x) <= 32 for x in range(0, 2000))
    assert all(bias_four(x) <= 16 for x in range(192, 2000))
    print("\n  bias = 0 iff x = 224; bias = 32 iff x <= 160; bias <= 16 iff x >= 192.")

    print("\n  calibration and robustness of the central rungs:")
    for n, m in [(3, 2), (4, 2), (4, 3), (5, 3)]:
        value = rung_prob(n, m, Fraction(1, 2))
        print(f"    n = {n}, m = {m}: R = {str(value):>9}"
              f"  calibrated: {str(is_calibrated(n, m)):>5}"
              f"  breakdown: {breakdown_number(n, m)}")
    print("\n  three seeds : median calibrated, breakdown 1")
    print("  four  seeds : neither central rung calibrated (defect 3/16), breakdown still 1")
    print("  five  seeds : median calibrated again, breakdown 2  <-- the useful increment")


def demo_condorcet() -> None:
    print()
    print(RULE)
    print("7. CONDORCET CONVERGENCE AND THE CERTIFICATION CROSSING AT p = 2/3")
    print(RULE)
    p = Fraction(2, 3)
    print(f"  {'n=2r+1':>7} {'miss (truth)':>16} {'sharp bound':>14} {'crude bound':>14}")
    print("  " + "-" * 54)
    for r in [1, 2, 5, 10, 22, 23, 24, 30, 36]:
        truth = miss_probability(r, p)
        print(f"  {2*r+1:>7} {float(truth):>16.8f} {float(sharp_rate(r, p)):>14.8f}"
              f" {float(crude_rate(r, p)):>14.8f}")
    eps = Fraction(1, 100)
    truth_cross = first_crossing(p, eps)
    sharp_cross = first_crossing_of_bound("sharp", p, eps)
    crude_cross = first_crossing_of_bound("crude", p, eps)
    print(f"\n  exact crossing of the 1% level      : {truth_cross} seeds")
    print(f"  first size certified by sharp bound : {sharp_cross} seeds")
    print(f"  first size certified by crude bound : {crude_cross} seeds")
    assert (truth_cross, sharp_cross, crude_cross) == (47, 49, 73)
    print("  (no bound dominating the sharpened rate can certify at 47: the sharpened rate")
    print(f"   at 47 seeds is {float(sharp_rate(23, p)):.6f} > 0.01, while the truth is"
          f" {float(miss_probability(23, p)):.6f})")

    three = rung_prob(3, 2, p)
    print(f"\n  the three-seed median rung at p = 2/3 reads {three} = {float(three):.4f},")
    print(f"  so its miss probability is {1 - three} = {float(1-three):.4f} ~ 26%:")
    print("  a point estimate, not a certified centre.")
    assert 1 - three == Fraction(7, 27)


def demo_window_width() -> None:
    print()
    print(RULE)
    print("8. WINDOW WIDTH: THE MEDIAN IS NOT ALWAYS THE NARROWEST READING")
    print(RULE)
    straggler = [0, 0, 0, 10, 20]
    print(f"  sample {straggler}: ladder {ladder(straggler)}")
    for m in (2, 3, 4):
        lo, hi = contamination_bracket(straggler, m, 1)
        print(f"    rung m = {m}: window [{lo}, {hi}], width {hi - lo}")
    w_med = contamination_bracket(straggler, 3, 1)
    w_off = contamination_bracket(straggler, 2, 1)
    assert (w_med[1] - w_med[0]) > (w_off[1] - w_off[0])
    print("  -> the median window (width 10) is strictly wider than the m = 2 window (width 0).")

    unimodal = [0, 9, 15, 21, 30]
    gaps = [unimodal[i] - unimodal[i - 1] for i in range(1, 5)]
    print(f"\n  centre-minimal sample {unimodal}: gaps {gaps} shrink toward the centre")
    widths: Dict[int, int] = {}
    for m in (2, 3, 4):
        lo, hi = contamination_bracket(unimodal, m, 1)
        widths[m] = hi - lo
        print(f"    rung m = {m}: window [{lo}, {hi}], width {hi - lo}")
    assert widths[3] == min(widths.values())
    print("  -> under centre-minimality the median window is narrowest, as the theory predicts.")

    measured = [160, 224, 256]
    g = [measured[1] - measured[0], measured[2] - measured[1]]
    print(f"\n  measured sample {measured}: gaps {g} are equidistant from the centre yet unequal,")
    print("  so centre-minimality is vacuous at three seeds; the median's robustness there is")
    print("  explained by the breakdown number, not by narrowness.")


def demo_dichotomy() -> None:
    print()
    print(RULE)
    print("9. THE DICHOTOMY: CALIBRATED  <=>  MAXIMALLY ROBUST  (odd ensembles)")
    print(RULE)
    print(f"  {'n':>3} {'m':>3} {'R_n(m,1/2)':>14} {'calibrated':>11} {'beta':>5} {'maximal':>8}")
    print("  " + "-" * 50)
    for n in [3, 5, 7]:
        r = (n - 1) // 2
        for m in range(1, n + 1):
            value = rung_prob(n, m, Fraction(1, 2))
            cal = value == Fraction(1, 2)
            beta = breakdown_number(n, m)
            maximal = beta == r
            assert cal == maximal  # the dichotomy
            print(f"  {n:>3} {m:>3} {str(value):>14} {str(cal):>11} {beta:>5} {str(maximal):>8}")
        print()
    print("  Even ensembles fail on both sides at once:")
    for n in [4, 6]:
        r = n // 2
        cal_any = any(is_calibrated(n, m) for m in range(1, n + 1))
        maxima = [m for m in range(1, n + 1) if breakdown_number(n, m) == r - 1]
        print(f"    n = {n}: any calibrated rung? {cal_any};"
              f" rungs of maximal breakdown {r-1}: {maxima}")
        assert not cal_any and len(maxima) == 2


def main() -> None:
    demo_median_law()
    demo_parity_law()
    demo_defect()
    demo_breakdown()
    demo_contamination_curve()
    demo_fourth_seed()
    demo_condorcet()
    demo_window_width()
    demo_dichotomy()
    print()
    print(RULE)
    print("All assertions passed.")
    print(RULE)


if __name__ == "__main__":
    main()


"""Quota ladder, breakdown table, and contamination curve of a seed ensemble.

Given the knees of n stochastic runs (the least budget at which each run clears a fixed
quality bar), this module computes:

  * the quota ladder Q(1) <= ... <= Q(n), i.e. the sorted knees, where Q(m) is the least
    budget at which at least m of the runs clear the bar;
  * the exact two-sided breakdown number beta(n, m) = min(m - 1, n - m) of every rung, the
    number of corrupted runs the rung tolerates before its reading can be driven to 0 or
    above any prescribed bound;
  * the contamination curve of a rung: for every level c <= beta(n, m), the set of readings
    an adversary controlling c runs can force is exactly the clean bracket
    [Q(m - c), Q(m + c)], both endpoints attained.

Complexity: O(n log n) for the ladder (O(n) with counting sort on a bounded budget grid),
O(1) per breakdown number, O(1) per contamination bracket, O(n^2) for the full table.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple


def quota_ladder(knees: Sequence[int]) -> List[int]:
    """Return [Q(1), ..., Q(n)], the rungs of the quota ladder (the sorted knees)."""
    return sorted(knees)


def rung(knees: Sequence[int], m: int) -> int:
    """Q(m): least budget at which at least m runs clear the bar. Q(0) = 0."""
    if m <= 0:
        return 0
    if m > len(knees):
        raise ValueError("quota exceeds ensemble size")
    return quota_ladder(knees)[m - 1]


def breakdown_number(n: int, m: int) -> int:
    """Exact two-sided breakdown number of the m-th rung of an n-run ensemble."""
    return min(m - 1, n - m)


def contamination_bracket(knees: Sequence[int], m: int, c: int) -> Tuple[int, int]:
    """Achievable readings of rung m under c corrupted runs: exactly [Q(m-c), Q(m+c)]."""
    n = len(knees)
    if not 1 <= m <= n:
        raise ValueError("rung out of range")
    if c > breakdown_number(n, m):
        raise ValueError(f"level {c} exceeds breakdown number {breakdown_number(n, m)}")
    return rung(knees, m - c), rung(knees, m + c)


def maximal_bias(knees: Sequence[int], m: int, c: int) -> Tuple[int, int]:
    """(downward bias, upward bias) an adversary controlling c runs can force on rung m."""
    lo, hi = contamination_bracket(knees, m, c)
    clean = rung(knees, m)
    return clean - lo, hi - clean


def robustness_report(knees: Sequence[int]) -> Dict[int, Dict[str, object]]:
    """Full per-rung report: clean reading, breakdown number, and all contamination brackets."""
    n = len(knees)
    report: Dict[int, Dict[str, object]] = {}
    for m in range(1, n + 1):
        beta = breakdown_number(n, m)
        report[m] = {
            "reading": rung(knees, m),
            "breakdown": beta,
            "curves": {c: contamination_bracket(knees, m, c) for c in range(beta + 1)},
            "calibrated": 2 * m == n + 1,
        }
    return report


if __name__ == "__main__":
    measured = [160, 224, 256]  # three seeds at d = 4, context 2048
    print("ladder:", quota_ladder(measured))
    for m, info in robustness_report(measured).items():
        print(f"  rung {m}: {info}")
    print("median =", rung(measured, 2), "= 7/8 * (4 * 2048 / 32)")


"""Rung distribution function, calibration test, and certification threshold search.

Under the model "each run clears a fixed bar independently with probability p", the m-th
rung of an n-run ensemble sits at or below that budget with probability equal to the
binomial upper tail

    R_n(m, p) = sum_{j >= m} C(n, j) p^j (1 - p)^(n - j).

This module evaluates R_n(m, p) without factorials, using the term recurrence

    t_{j+1} = t_j * ((n - j) p) / ((j + 1) (1 - p)),      t_m = C(n, m) p^m (1-p)^(n-m),

tests calibration (R_n(m, 1/2) = 1/2, which holds iff 2m = n + 1), and locates the exact
ensemble size at which the median rung's miss probability first drops below a target.

Complexity: O(n - m) exact rational multiplications per tail evaluation; the certification
search performs O(log(1/eps) / log(1 / (4p(1-p)))) evaluations, by the geometric Condorcet
rate 1 - R_{2r+1}(r+1, p) <= 2(1-p)(4p(1-p))^r.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List, Tuple


def rung_prob(n: int, m: int, p: Fraction) -> Fraction:
    """Exact binomial upper tail R_n(m, p) via the term recurrence (no factorials)."""
    if m <= 0:
        return Fraction(1)
    if m > n:
        return Fraction(0)
    q = 1 - p
    if q == 0:
        return Fraction(1)
    term = Fraction(comb(n, m)) * p**m * q ** (n - m)
    total = term
    for j in range(m, n):
        term = term * Fraction((n - j)) * p / (Fraction(j + 1) * q)
        total += term
    return total


def is_calibrated(n: int, m: int) -> bool:
    """True iff rung m reads exactly 1/2 on coin-flip runs; equivalently 2m = n + 1."""
    return rung_prob(n, m, Fraction(1, 2)) == Fraction(1, 2)


def calibration_defect(r: int) -> Fraction:
    """Defect of a 2r-run ensemble: its central rungs read 1/2 +- C(2r, r) / 2^(2r+1)."""
    return Fraction(comb(2 * r, r), 2 ** (2 * r + 1))


def miss_probability(r: int, p: Fraction) -> Fraction:
    """1 - R_{2r+1}(r+1, p): the median rung's failure probability."""
    return 1 - rung_prob(2 * r + 1, r + 1, p)


def crude_rate(r: int, p: Fraction) -> Fraction:
    """Geometric Condorcet bound 2(1 - p) (4p(1 - p))^r."""
    return 2 * (1 - p) * (4 * p * (1 - p)) ** r


def sharp_rate(r: int, p: Fraction) -> Fraction:
    """Sharpened one-term bound C(2r+1, r) (p(1-p))^{r+1} / (2p - 1)."""
    return Fraction(comb(2 * r + 1, r)) * (p * (1 - p)) ** (r + 1) / (2 * p - 1)


def certification_threshold(p: Fraction, epsilon: Fraction, limit: int = 400) -> int:
    """Least odd ensemble size whose median rung misses with probability <= epsilon.

    Monotonicity of the median rung in the ensemble size (for p > 1/2) makes the first
    crossing the answer.
    """
    for r in range(limit):
        if miss_probability(r, p) <= epsilon:
            return 2 * r + 1
    raise RuntimeError("no crossing below the search limit")


def certification_table(p: Fraction, epsilon: Fraction) -> List[Tuple[str, int]]:
    """Ensemble sizes required by the truth and by each bound."""
    rows: List[Tuple[str, int]] = [("truth", certification_threshold(p, epsilon))]
    for name, fn in (("sharpened rate", sharp_rate), ("crude rate", crude_rate)):
        for r in range(400):
            if fn(r, p) <= epsilon:
                rows.append((name, 2 * r + 1))
                break
    return rows


if __name__ == "__main__":
    p = Fraction(2, 3)
    print("three-run median rung at p = 2/3 :", rung_prob(3, 2, p), "-> miss", 1 - rung_prob(3, 2, p))
    for name, size in certification_table(p, Fraction(1, 100)):
        print(f"1% certification via {name:>15}: {size} runs")
    for n in range(1, 7):
        cal = [m for m in range(1, n + 1) if is_calibrated(n, m)]
        print(f"n = {n}: calibrated rungs {cal}")


"""Assemble PACKAGE.json from the deliverable files and the package assets."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES: List[str] = sorted(
    str(p.relative_to(ROOT)) for p in (ROOT / "Catalog" / "Probability").glob("*.lean")
)


def lean_bundle() -> str:
    chunks: List[str] = []
    for rel in LEAN_FILES:
        chunks.append(f"-- ===== {rel} =====\n" + read(ROOT / rel).rstrip() + "\n")
    return "\n".join(chunks)


ALGORITHMS = [
    {
        "name": "Quota Ladder Construction, Breakdown Table, and Contamination Curve",
        "description": (
            "Turns the raw readings of n stochastic runs into the ensemble's quota ladder "
            "Q(1) <= ... <= Q(n), where Q(m) is the least budget at which at least m runs clear "
            "the quality bar (equivalently the m-th order statistic). It then annotates every "
            "rung with its exact two-sided breakdown number beta(n, m) = min(m - 1, n - m) — the "
            "number of corrupted runs the reading tolerates before an adversary can drive it to "
            "zero or above any prescribed bound — and with its contamination curve: for every "
            "level c <= beta(n, m) the set of readings an adversary controlling c runs can force "
            "is exactly the clean bracket [Q(m - c), Q(m + c)], both endpoints attained, so the "
            "maximal bias equals the clean spread and is in general asymmetric. Complexity: "
            "O(n log n) for the ladder (O(n) with counting sort on a bounded budget grid), O(1) "
            "per breakdown number and per bracket, O(n^2) for the complete robustness report. "
            "This is the pipeline's entry point: every downstream statement about which reading "
            "to publish is a statement about a row of its output table."
        ),
        "pseudocode": (
            "INPUT : readings K[1..n] of n runs; quota m; contamination level c\n"
            "OUTPUT: rung reading, breakdown number, achievable readings under c corruptions\n"
            "\n"
            "procedure QUOTA_LADDER(K[1..n]):\n"
            "    L <- sort(K) ascending            # O(n log n)\n"
            "    return L                           # L[m] = Q(m), and Q(0) = 0\n"
            "\n"
            "procedure BREAKDOWN(n, m):\n"
            "    return min(m - 1, n - m)\n"
            "\n"
            "procedure CONTAMINATION_BRACKET(L, n, m, c):\n"
            "    if c > BREAKDOWN(n, m):\n"
            "        return BROKEN                  # reading can be forced to 0 or to +infinity\n"
            "    lo <- (m - c = 0) ? 0 : L[m - c]\n"
            "    hi <- L[m + c]\n"
            "    return [lo, hi]                    # attained at both ends\n"
            "\n"
            "procedure ROBUSTNESS_REPORT(K[1..n]):\n"
            "    L <- QUOTA_LADDER(K)\n"
            "    for m <- 1 to n:\n"
            "        b <- BREAKDOWN(n, m)\n"
            "        emit ( rung        = L[m],\n"
            "               breakdown   = b,\n"
            "               curves      = { c -> CONTAMINATION_BRACKET(L, n, m, c) : 0 <= c <= b },\n"
            "               calibrated  = (2m = n + 1) )"
        ),
        "code": read(ASSETS / "algo_quota_ladder.py"),
    },
    {
        "name": "Binomial Rung Tail Evaluation and Certification Threshold Search",
        "description": (
            "Evaluates the rung distribution function R_n(m, p) = sum_{j >= m} C(n, j) p^j "
            "(1 - p)^(n - j) — the probability that the m-th rung of an n-run ensemble sits at "
            "or below a given budget when each run clears the bar independently with probability "
            "p — and uses it for two tasks. First, calibration testing: a rung reads exactly 1/2 "
            "on coin-flip runs if and only if 2m = n + 1, and for even ensembles the two central "
            "rungs miss 1/2 by the defect C(2r, r) / 2^(2r+1). Second, ensemble sizing: for "
            "p > 1/2 the median rung's miss probability strictly decreases in the ensemble size, "
            "so the least ensemble certifying a target miss level is located by a monotone scan. "
            "Evaluation uses the term recurrence t_{j+1} = t_j (n - j) p / ((j + 1)(1 - p)), "
            "avoiding factorials: O(n - m) exact rational multiplications per tail. The scan "
            "length is O(log(1/eps) / log(1 / (4p(1-p)))) by the geometric Condorcet rate "
            "2(1 - p)(4p(1 - p))^r. With exact arithmetic the located crossing (47 runs at "
            "p = 2/3 for a 1% target, versus 49 for the sharpened bound and 73 for the crude one) "
            "is a certificate rather than a floating-point impression."
        ),
        "pseudocode": (
            "INPUT : ensemble size n, quota m, per-run pass probability p (exact rational)\n"
            "OUTPUT: R_n(m, p); calibration verdict; least certifying ensemble size\n"
            "\n"
            "procedure RUNG_PROB(n, m, p):\n"
            "    if m <= 0: return 1\n"
            "    if m > n : return 0\n"
            "    q <- 1 - p\n"
            "    t <- C(n, m) * p^m * q^(n - m)     # first term\n"
            "    S <- t\n"
            "    for j <- m to n - 1:\n"
            "        t <- t * ((n - j) * p) / ((j + 1) * q)\n"
            "        S <- S + t\n"
            "    return S\n"
            "\n"
            "procedure IS_CALIBRATED(n, m):\n"
            "    return RUNG_PROB(n, m, 1/2) = 1/2  # equivalently 2m = n + 1\n"
            "\n"
            "procedure CERTIFICATION_THRESHOLD(p, eps):\n"
            "    for r <- 0, 1, 2, ...:\n"
            "        miss <- 1 - RUNG_PROB(2r + 1, r + 1, p)\n"
            "        if miss <= eps: return 2r + 1   # monotone in r, so first crossing is least\n"
            "\n"
            "procedure BOUND_THRESHOLD(bound, p, eps):\n"
            "    for r <- 0, 1, 2, ...:\n"
            "        if bound(r, p) <= eps: return 2r + 1\n"
            "    # bound = 2(1-p)(4p(1-p))^r          (crude geometric rate)\n"
            "    # bound = C(2r+1,r)(p(1-p))^{r+1}/(2p-1)  (sharpened one-term rate)"
        ),
        "code": read(ASSETS / "algo_rung_tail.py"),
    },
]

DEMOS = [
    {
        "name": "End-to-End Numerical Tour: Median Law, Parity Law, Breakdown Numbers, and the Dichotomy",
        "description": (
            "A single self-contained script (standard library only, exact rational arithmetic) "
            "that reproduces every quantitative claim of the work. It verifies that the two "
            "measured knee sets {96, 112, 128} and {160, 224, 256} have medians exactly 7/8 of "
            "the natural scale dL/32; tabulates the rung probabilities of ensembles up to size 8 "
            "and confirms that a rung reads 1/2 on coin flips precisely when 2m = n + 1; computes "
            "the even-ensemble calibration defect, checks it against the proved sandwich "
            "1/(2 sqrt(4r+1)) <= delta_r <= 1/(2 sqrt(3r+1)) and against the limit "
            "delta_r sqrt(r) -> 1/(2 sqrt(pi)), and shows the two central rungs averaging to "
            "exactly 1/2; brute-forces an adversary over all corruption sets to confirm that the "
            "breakdown number is exactly min(m-1, n-m) and that the achievable readings are "
            "exactly the clean bracket with both endpoints attained; charts the four-run reading "
            "and its bias as the fourth outcome varies; locates the Condorcet certification "
            "crossing at 47 runs (sharpened bound 49, crude bound 73) and the three-run miss "
            "probability 7/27; and finally verifies the calibration-robustness dichotomy rung by "
            "rung for odd ensembles together with its simultaneous failure for even ones. Every "
            "claim is enforced by an assertion, so the script fails loudly if any of them breaks."
        ),
        "code": read(ROOT / "demo.py"),
    },
    {
        "name": "Exhaustive Adversarial Verification of the Breakdown Formula and the Dichotomy",
        "description": (
            "A brute-force certificate rather than an illustration. Over every ensemble of size "
            "at most six drawn from a small alphabet of readings, and for every rung and every "
            "contamination level, the script enumerates all ways of corrupting that many runs "
            "(each corrupted run free to take any alphabet value, zero, or a huge value) and "
            "records the set of readings actually forced. It then checks two things: below the "
            "breakdown number the forced readings lie exactly in the clean bracket "
            "[Q(m-c), Q(m+c)] with both endpoints attained, and one level above it the reading "
            "escapes to zero or above any bound. Separately, using exact rational arithmetic, it "
            "checks for every ensemble size up to fourteen that a rung is calibrated iff its "
            "breakdown number is maximal (odd sizes), that no rung is calibrated and the maximum "
            "is attained by exactly two rungs (even sizes), and that the two central rungs of an "
            "even ensemble read 1/2 plus and minus the central binomial defect and average to "
            "exactly 1/2. Roughly 17,500 adversarial assertions and 105 rung assertions run in a "
            "few seconds."
        ),
        "code": read(ASSETS / "demo_exhaustive_check.py"),
    },
]

VISUALIZATIONS = [
    {
        "name": "Two Profiles, One Rung: Calibration and Robustness Side by Side",
        "description": (
            "A three-panel figure that makes the dichotomy visible. The upper-left panel plots "
            "the calibration profile R_n(m, 1/2) against the quota m for ensembles of size three "
            "to seven, with the 1/2 level marked: odd-size curves pass exactly through 1/2 at the "
            "median quota, even-size curves step over it. The upper-right panel plots the "
            "robustness profile beta(n, m) = min(m - 1, n - m), whose unique maximiser for odd n "
            "sits at exactly the same quota, while for even n two rungs tie. The lower panel "
            "shows the calibration defect of even ensembles together with its proved sandwich "
            "and its asymptotic 1/(2 sqrt(pi r)), documenting that even ensembles approach "
            "calibration only at the slow rate r^(-1/2)."
        ),
        "code": read(ASSETS / "viz_dichotomy.py"),
    },
    {
        "name": "Contamination Curves of the Measured Ensemble and the Cost of Certifying Its Centre",
        "description": (
            "Left: the quota ladder of the measured three-run knee set {160, 224, 256} at "
            "(d, L) = (4, 2048), with the natural scale P = dL/32 = 256 and the 7/8 median line "
            "drawn in. Each rung carries its contamination curve at one corrupted run: the median "
            "gets the finite bracket [160, 256], while the best-case and guarantee rungs, having "
            "breakdown number zero, get unbounded arrows in both directions. Right: Condorcet "
            "convergence at the measured per-run frequency p = 2/3 on a log scale, comparing the "
            "exact miss probability of the median rung with the sharpened and crude bounds and "
            "marking the three certification sizes 47, 49 and 73 for a 1% target."
        ),
        "code": read(ASSETS / "viz_contamination.py"),
    },
]

INTERACTIVE = [
    {
        "title": "The Seed Ensemble Laboratory: Ladders, Rungs, and a Live Adversary",
        "description": (
            "The centrepiece widget. Type in the readings of your own runs and the page builds "
            "the ensemble's quota ladder, draws every rung, and scores each one twice: the "
            "probability it reads 'pass' on coin-flip runs (with calibrated rungs highlighted) "
            "and its exact breakdown number min(m-1, n-m). A slider sets how many runs an "
            "adversary controls; rungs still within tolerance are drawn with their contamination "
            "curve [Q(m-c), Q(m+c)], and rungs past breakdown are drawn as unbounded dashed "
            "lines. Clicking a rung runs a live brute-force adversary over all corruption sets of "
            "the chosen size, printing the forced readings, confirming that they fill the "
            "predicted bracket exactly, and reporting the resulting asymmetric bias. Preset "
            "buttons walk the reader through the measured three-run ensemble, the effect of "
            "adding a fourth and a fifth run, and the straggler sample that refutes the "
            "'median is narrowest' conjecture. A collapsible panel gives the full proofs of the "
            "parity law, the breakdown formula, and the dichotomy."
        ),
        "html": read(ASSETS / "widget_ensemble_lab.html"),
    },
    {
        "title": "How Many Runs Certify a Centre? A Condorcet Convergence Explorer",
        "description": (
            "An interactive log-scale plot of three curves: the exact miss probability of the "
            "median rung of a (2r+1)-run ensemble, the sharpened one-term bound "
            "C(2r+1, r)(p(1-p))^{r+1}/(2p-1), and the crude geometric bound 2(1-p)(4p(1-p))^r. "
            "Sliders control the per-run pass probability p and the target miss level; the widget "
            "reports the least ensemble size at which each of the three crosses the target, "
            "showing how far each proof route overshoots the truth (at p = 2/3 and a 1% target: "
            "47 versus 49 versus 73) and how the miss probability contracts by a factor of "
            "roughly 4p(1-p) for every extra pair of runs. A collapsible section derives the "
            "exact one-monomial Condorcet increment behind all three curves."
        ),
        "html": read(ASSETS / "widget_certification.html"),
    },
    {
        "title": "Should You Run a Fourth Seed? A Design Calculator",
        "description": (
            "A decision widget for the practical question the theory answers uncomfortably. "
            "Given the measured three-run readings 160, 224 and 256, a slider sets the outcome of "
            "a hypothetical fourth run; the page plots the resulting four-run reading (the mean "
            "of the two middle order statistics) as a piecewise-linear function of that outcome, "
            "shades its distance from the exact three-run centre of 224, and shows that the bias "
            "vanishes only when the fourth run lands exactly on 224, never exceeds 32, and drops "
            "to at most 16 once the outcome reaches 192. Alongside, a fixed table compares the "
            "three-, four- and five-run ensembles on both quality scores, making the verdict "
            "concrete: a fourth run leaves the breakdown number at one and destroys calibration, "
            "while a fifth raises the breakdown number to two and restores it. A collapsible "
            "panel gives the arithmetic of the four-run reading and the central defect 3/16."
        ),
        "html": read(ASSETS / "widget_fourth_seed.html"),
    },
]


def main() -> None:
    package: Dict[str, object] = {
        "title": (
            "Calibration Equals Maximal Robustness: The Exact Breakdown Number of a Quota Rung"
        ),
        "domain": "Probability",
        "description": (
            "For an ensemble of n stochastic runs, the m-th rung of its quota ladder is unbiased "
            "on coin-flip runs exactly when it tolerates the maximal number of corrupted runs, "
            "the exact tolerance being min(m-1, n-m); for odd ensembles this pins the median "
            "uniquely, while for even ensembles both properties fail together. Applied to a "
            "measured three-run knee set {160, 224, 256} whose median is exactly 7/8 of the "
            "natural scale, the theory shows a fourth run buys neither robustness nor "
            "calibration while a fifth buys both."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-17",
        "key_results": [
            "Calibration-Robustness Dichotomy: in an ensemble of 2r+1 runs, a rung of the quota "
            "ladder reads exactly 1/2 on coin-flip runs if and only if its breakdown number is "
            "maximal, so the median is simultaneously the unique unbiased reading and the unique "
            "maximally sabotage-resistant one",
            "Exact breakdown number of a rung: c corrupted runs move the m-th rung by at most c "
            "rungs of the clean ladder in either direction, and this is sharp — the two-sided "
            "breakdown number equals min(m-1, n-m), so the guarantee and best-case readings are "
            "destroyed by a single corrupted run",
            "Parity law of calibration: a rung reads 1/2 on coin-flip runs if and only if "
            "2m = n+1, so an ensemble admits a calibrated rung precisely when its size is odd; "
            "for even size 2r the two central rungs read 1/2 plus and minus the defect "
            "C(2r,r)/2^(2r+1) and average to exactly 1/2",
            "Calibration defect asymptotics: the defect is squeezed between 1/(2 sqrt(4r+1)) and "
            "1/(2 sqrt(3r+1)), is non-summable, and satisfies defect times sqrt(r) tending to "
            "1/(2 sqrt(pi))",
            "Design verdict for a measured ensemble: with three runs reading {160, 224, 256} and "
            "median exactly 7/8 of the product scale, a fourth run leaves the breakdown number at "
            "1 and destroys calibration, and matches the three-run centre only by landing exactly "
            "on it, whereas a fifth run raises the breakdown number to 2 and restores calibration",
        ],
        "keywords": [
            "order statistics",
            "breakdown point",
            "binomial upper tail",
            "calibration",
            "robust statistics",
            "Condorcet jury theorem",
            "central binomial coefficient",
            "seed ensembles",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": DEMOS,
        "algorithms": ALGORITHMS,
        "visualizations": VISUALIZATIONS,
        "interactive_demos": INTERACTIVE,
        "interactive_layout": read(ASSETS / "interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": read(ASSETS / "future_directions.md"),
        "modules": {"demo": read(ROOT / "demo.py")},
        "lean_files": LEAN_FILES,
    }
    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size / 1024:.1f} KB)")


if __name__ == "__main__":
    main()


"""Exhaustive computational check of the breakdown formula and the dichotomy.

Two brute-force verifications, over all ensembles of size n <= 6 whose readings come from a
small alphabet:

  (A) Sharpness of the breakdown number. For every ensemble, every rung m and every
      contamination level c, we enumerate all ways of corrupting c runs (each corrupted run
      taking any value in the alphabet, plus 0 and a huge value) and record the set of
      readings obtained. We check that
        * for c <= beta(n, m) = min(m - 1, n - m) the readings lie exactly in the clean
          bracket [Q(m - c), Q(m + c)], with both endpoints attained;
        * for c = beta(n, m) + 1 the reading can be forced to 0 or above any bound, so the
          bracket is destroyed.

  (B) The dichotomy. For every n and every rung m we check that the rung reads exactly 1/2 on
      coin-flip runs if and only if its breakdown number equals the maximum possible value
      (n - 1) / 2 for odd n, and that for even n neither property holds anywhere.

All arithmetic on probabilities is exact (fractions), so the verification is a certificate
rather than a floating-point impression.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from math import comb
from typing import List, Sequence, Set, Tuple

ALPHABET: Tuple[int, ...] = (1, 3, 7)
HUGE: int = 10**6


def rung(knees: Sequence[int], m: int) -> int:
    if m <= 0:
        return 0
    return sorted(knees)[m - 1]


def breakdown_number(n: int, m: int) -> int:
    return min(m - 1, n - m)


def rung_prob_half(n: int, m: int) -> Fraction:
    return Fraction(sum(comb(n, j) for j in range(m, n + 1)), 2**n)


def forced_readings(knees: Sequence[int], m: int, c: int) -> Set[int]:
    """All readings of rung m obtainable by corrupting exactly the given number of runs."""
    n = len(knees)
    alts = list(ALPHABET) + [0, HUGE]
    out: Set[int] = set()
    for corrupted in combinations(range(n), c):
        for values in product(alts, repeat=c):
            perturbed = list(knees)
            for i, v in zip(corrupted, values):
                perturbed[i] = v
            out.add(rung(perturbed, m))
    return out


def check_breakdown(max_n: int = 6) -> int:
    checks = 0
    for n in range(1, max_n + 1):
        for knees in product(ALPHABET, repeat=n):
            for m in range(1, n + 1):
                beta = breakdown_number(n, m)
                for c in range(beta + 1):
                    got = forced_readings(knees, m, c)
                    lo, hi = rung(knees, m - c), rung(knees, m + c)
                    assert all(lo <= v <= hi for v in got), (knees, m, c, got)
                    assert lo in got and hi in got, (knees, m, c, got)
                    checks += 1
                if beta + 1 <= n:
                    got = forced_readings(knees, m, beta + 1)
                    escaped = (0 in got and rung(knees, m) > 0) or (HUGE in got)
                    assert escaped, (knees, m, beta + 1, got)
                    checks += 1
    return checks


def check_dichotomy(max_n: int = 14) -> int:
    checks = 0
    for n in range(1, max_n + 1):
        best = max(breakdown_number(n, m) for m in range(1, n + 1))
        for m in range(1, n + 1):
            calibrated = rung_prob_half(n, m) == Fraction(1, 2)
            maximal = breakdown_number(n, m) == best
            if n % 2 == 1:
                assert calibrated == maximal, (n, m)
                assert calibrated == (2 * m == n + 1), (n, m)
            else:
                assert not calibrated, (n, m)
            checks += 1
        if n % 2 == 0:
            maximisers = [m for m in range(1, n + 1) if breakdown_number(n, m) == best]
            assert len(maximisers) == 2, (n, maximisers)
            r = n // 2
            defect = Fraction(comb(2 * r, r), 2 ** (2 * r + 1))
            assert rung_prob_half(n, r) == Fraction(1, 2) + defect
            assert rung_prob_half(n, r + 1) == Fraction(1, 2) - defect
            assert (rung_prob_half(n, r) + rung_prob_half(n, r + 1)) / 2 == Fraction(1, 2)
    return checks


def main() -> None:
    print("(A) breakdown sharpness over all ensembles of size <= 6 ...")
    a = check_breakdown()
    print(f"    {a} bracket / escape assertions passed")
    print("(B) dichotomy and even-ensemble defect for n <= 14 ...")
    b = check_dichotomy()
    print(f"    {b} rung assertions passed")
    rows: List[Tuple[int, str, str]] = []
    for n in range(1, 9):
        cal = [m for m in range(1, n + 1) if rung_prob_half(n, m) == Fraction(1, 2)]
        best = max(breakdown_number(n, m) for m in range(1, n + 1))
        maxi = [m for m in range(1, n + 1) if breakdown_number(n, m) == best]
        rows.append((n, str(cal), f"{maxi} (beta = {best})"))
    print(f"\n{'n':>3}  {'calibrated rungs':>18}  {'maximally robust rungs':>28}")
    for n, cal, maxi in rows:
        print(f"{n:>3}  {cal:>18}  {maxi:>28}")


if __name__ == "__main__":
    main()


"""Visualization: contamination curves of a measured ensemble, and Condorcet certification.

Left panel  — the quota ladder of the measured three-seed knee set {160, 224, 256} at
              (d, L) = (4, 2048), with the natural scale P = dL/32 = 256 and the 7/8 median
              line. Each rung is drawn with its contamination curve: the interval
              [Q(m-c), Q(m+c)] of readings an adversary controlling c runs can force. Rungs
              of breakdown number 0 (best case and guarantee) are drawn as unbounded arrows.
Right panel — Condorcet convergence at the measured per-seed frequency p = 2/3: the exact
              miss probability of the median rung against ensemble size, together with the
              crude geometric bound and the sharpened one-term bound, and the 1% level whose
              exact crossing is at 47 runs (sharpened bound: 49; crude bound: 73).

Requires matplotlib.  Run:  python3 viz_contamination.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List

import matplotlib.pyplot as plt


def rung(knees: List[int], m: int) -> int:
    return 0 if m <= 0 else sorted(knees)[m - 1]


def breakdown_number(n: int, m: int) -> int:
    return min(m - 1, n - m)


def rung_prob(n: int, m: int, p: Fraction) -> Fraction:
    q = 1 - p
    return sum((Fraction(comb(n, j)) * p**j * q ** (n - j) for j in range(m, n + 1)),
               Fraction(0))


def main() -> None:
    knees = [160, 224, 256]
    scale = 4 * 2048 // 32
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    labels = {1: "best case  $Q(1)$", 2: "median  $Q(2)$", 3: "guarantee  $Q(3)$"}
    for m in (1, 2, 3):
        y = m
        clean = rung(knees, m)
        beta = breakdown_number(3, m)
        ax1.plot([clean], [y], "o", color="C0", ms=9, zorder=3)
        if beta >= 1:
            lo, hi = rung(knees, m - 1), rung(knees, m + 1)
            ax1.plot([lo, hi], [y, y], lw=6, alpha=0.35, color="C2",
                     solid_capstyle="butt", zorder=2)
            ax1.text(hi + 6, y + 0.12, f"curve at $c=1$: $[{lo},{hi}]$", fontsize=9)
        else:
            ax1.annotate("", xy=(300, y), xytext=(clean, y),
                         arrowprops=dict(arrowstyle="->", color="C3", lw=2))
            ax1.annotate("", xy=(120, y), xytext=(clean, y),
                         arrowprops=dict(arrowstyle="->", color="C3", lw=2))
            ax1.text(300, y + 0.12, "breakdown 0: unbounded", fontsize=9, color="C3")
        ax1.text(120, y - 0.25, labels[m], fontsize=10)

    ax1.axvline(scale, color="k", ls=":", lw=1)
    ax1.text(scale + 3, 0.45, "$P = dL/32 = 256$", fontsize=9)
    ax1.axvline(7 * scale // 8, color="C1", ls="--", lw=1.5)
    ax1.text(7 * scale // 8 - 74, 0.45, "$(7/8)P = 224$", fontsize=9, color="C1")
    ax1.set_xlim(110, 380)
    ax1.set_ylim(0.3, 3.6)
    ax1.set_yticks([1, 2, 3])
    ax1.set_yticklabels(["$m=1$", "$m=2$", "$m=3$"])
    ax1.set_xlabel("retention budget $k$")
    ax1.set_title("Quota ladder of $\\{160,224,256\\}$ with contamination curves")
    ax1.grid(alpha=0.3, axis="x")

    p = Fraction(2, 3)
    rs = list(range(0, 40))
    sizes = [2 * r + 1 for r in rs]
    truth = [float(1 - rung_prob(2 * r + 1, r + 1, p)) for r in rs]
    crude = [float(2 * (1 - p) * (4 * p * (1 - p)) ** r) for r in rs]
    sharp = [float(Fraction(comb(2 * r + 1, r)) * (p * (1 - p)) ** (r + 1) / (2 * p - 1))
             for r in rs]
    ax2.semilogy(sizes, truth, "o-", ms=3, label="exact miss probability")
    ax2.semilogy(sizes, sharp, "--", label="sharpened bound")
    ax2.semilogy(sizes, crude, ":", label="crude geometric bound")
    ax2.axhline(0.01, color="k", lw=1)
    for size, color, text in ((47, "C0", "truth: 47"), (49, "C1", "sharp: 49"),
                              (73, "C2", "crude: 73")):
        ax2.axvline(size, color=color, ls="-.", lw=1)
        ax2.text(size + 0.5, 3e-1, text, rotation=90, fontsize=8, color=color)
    ax2.set_xlabel("ensemble size $n = 2r+1$")
    ax2.set_ylabel("probability the median rung misses")
    ax2.set_title("Certifying the centre at $p = 2/3$")
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("contamination_and_certification.png", dpi=150)
    print("wrote contamination_and_certification.png")


if __name__ == "__main__":
    main()


"""Visualization: the two profiles that pin the same rung.

Left panel  — the calibration profile: for each ensemble size n, the rung probability
              R_n(m, 1/2) plotted against the quota m, with the 1/2 level marked. The curve
              crosses 1/2 exactly at m = (n+1)/2 for odd n, and jumps over it for even n.
Right panel — the robustness profile: the breakdown number beta(n, m) = min(m-1, n-m)
              against m. Its unique maximiser (odd n) sits at exactly the same quota.
Bottom      — the calibration defect of even ensembles, delta_r = C(2r,r)/2^(2r+1), with the
              proved sandwich 1/(2 sqrt(4r+1)) <= delta_r <= 1/(2 sqrt(3r+1)) and the exact
              limit delta_r sqrt(r) -> 1/(2 sqrt(pi)).

Requires matplotlib.  Run:  python3 viz_dichotomy.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, pi, sqrt
from typing import List

import matplotlib.pyplot as plt


def rung_prob_half(n: int, m: int) -> float:
    """R_n(m, 1/2) = (sum_{j>=m} C(n,j)) / 2^n."""
    return sum(comb(n, j) for j in range(m, n + 1)) / 2**n


def breakdown_number(n: int, m: int) -> int:
    return min(m - 1, n - m)


def defect(r: int) -> float:
    return float(Fraction(comb(2 * r, r), 2 ** (2 * r + 1)))


def main() -> None:
    sizes: List[int] = [3, 4, 5, 6, 7]
    fig = plt.figure(figsize=(12, 8))
    ax1 = fig.add_subplot(2, 2, 1)
    ax2 = fig.add_subplot(2, 2, 2)
    ax3 = fig.add_subplot(2, 1, 2)

    for n in sizes:
        ms = list(range(1, n + 1))
        style = "-o" if n % 2 else "--s"
        ax1.plot(ms, [rung_prob_half(n, m) for m in ms], style, label=f"n = {n}")
        ax2.plot(ms, [breakdown_number(n, m) for m in ms], style, label=f"n = {n}")

    ax1.axhline(0.5, color="k", lw=1, ls=":")
    ax1.set_title("Calibration profile:  $R_n(m,1/2)$")
    ax1.set_xlabel("quota $m$")
    ax1.set_ylabel("probability rung $m$ reads 'pass'")
    ax1.legend(fontsize=8)
    ax1.grid(alpha=0.3)

    ax2.set_title("Robustness profile:  $\\beta(n,m)=\\min(m-1,\\,n-m)$")
    ax2.set_xlabel("quota $m$")
    ax2.set_ylabel("corrupted runs tolerated")
    ax2.legend(fontsize=8)
    ax2.grid(alpha=0.3)

    rs = list(range(1, 61))
    ax3.plot(rs, [defect(r) for r in rs], "o-", ms=3, label="defect $\\delta_r$")
    ax3.plot(rs, [1 / (2 * sqrt(4 * r + 1)) for r in rs], "--",
             label="lower bound $1/(2\\sqrt{4r+1})$")
    ax3.plot(rs, [1 / (2 * sqrt(3 * r + 1)) for r in rs], "--",
             label="upper bound $1/(2\\sqrt{3r+1})$")
    ax3.plot(rs, [1 / (2 * sqrt(pi * r)) for r in rs], ":", lw=2,
             label="asymptotic $1/(2\\sqrt{\\pi r})$")
    ax3.set_title("Even ensembles are never calibrated: the defect and its sandwich")
    ax3.set_xlabel("half-size $r$   (ensemble size $n = 2r$)")
    ax3.set_ylabel("$\\delta_r$")
    ax3.legend()
    ax3.grid(alpha=0.3)

    fig.suptitle("Calibration and robustness pin the same rung", fontsize=14)
    fig.tight_layout()
    fig.savefig("dichotomy_profiles.png", dpi=150)
    print("wrote dichotomy_profiles.png")


if __name__ == "__main__":
    main()
