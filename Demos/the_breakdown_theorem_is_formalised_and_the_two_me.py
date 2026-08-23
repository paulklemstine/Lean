"""
The finite-sample breakdown theorem for the median: numerical demonstrations.

This module is fully self-contained (standard library only) and uses exact
rational arithmetic throughout, so every number printed below is exact.

It demonstrates, on two measured normalised distributions and on synthetic
samples:

  1. The measured data: three-channel count triples, their normalised first
     coordinates, and their medians.
  2. Counting stability: a predicate count changes by at most the Hamming
     distance between two equal-length datasets.
  3. The breakdown half: with 2k < n, every median of every k-contamination is
     trapped inside the range of the clean data (verified by random search).
  4. The sharpness half: with 2k >= n, overwriting the first k entries with any
     prescribed target t makes t a median.
  5. The breakdown number of the median is ceil(n/2); that of the mean is 1.
  6. The order-statistic breakdown profile beta(j) = min(j+1, n-j), a discrete
     tent peaking at the median index.
  7. The universal ceiling: the Donoho-Huber equivariance shear breaks every
     translation-equivariant estimator at budget ceil(n/2).
  8. The coding bridge: the translation code {x, x+c} has minimum Hamming
     distance n, and confusability at radius k holds exactly when n <= 2k.

Run:  python3 demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Rat = Fraction
Dataset = List[Rat]


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------


def hamming(xs: Sequence[Rat], ys: Sequence[Rat]) -> int:
    """Number of positions at which two equal-length datasets differ."""
    if len(xs) != len(ys):
        raise ValueError("datasets must have equal length")
    return sum(1 for a, b in zip(xs, ys) if a != b)


def count_le(xs: Sequence[Rat], m: Rat) -> int:
    """#{i : x_i <= m}."""
    return sum(1 for x in xs if x <= m)


def count_ge(xs: Sequence[Rat], m: Rat) -> int:
    """#{i : m <= x_i}."""
    return sum(1 for x in xs if m <= x)


def is_median(xs: Sequence[Rat], m: Rat) -> bool:
    """m is a median of xs: at least half of xs is <= m and at least half is >= m."""
    n = len(xs)
    return n <= 2 * count_le(xs, m) and n <= 2 * count_ge(xs, m)


def median_interval(xs: Sequence[Rat]) -> Tuple[Rat, Rat]:
    """The full set of medians is the closed interval returned here."""
    s = sorted(xs)
    n = len(s)
    if n % 2 == 1:
        v = s[(n - 1) // 2]
        return (v, v)
    return (s[n // 2 - 1], s[n // 2])


def lower_median(xs: Sequence[Rat]) -> Rat:
    """The lower sample median: the ceil(n/2)-th smallest observation."""
    s = sorted(xs)
    return s[(len(s) - 1) // 2]


def mean(xs: Sequence[Rat]) -> Rat:
    """The sample mean."""
    return sum(xs, Fraction(0)) / len(xs)


def order_stat(j: int, xs: Sequence[Rat]) -> Rat:
    """The j-th smallest observation (0-indexed, clamped to n-1)."""
    s = sorted(xs)
    return s[min(j, len(s) - 1)]


def contaminate(xs: Sequence[Rat], k: int, t: Rat) -> Dataset:
    """Overwrite the first k entries of xs by the target value t."""
    if k > len(xs):
        raise ValueError("budget exceeds sample size")
    return [t] * k + list(xs[k:])


def median_breakdown_number(n: int) -> int:
    """Exact breakdown number of the median on a sample of size n: ceil(n/2)."""
    return (n + 1) // 2


def order_stat_breakdown_number(j: int, n: int) -> int:
    """Exact breakdown number of the j-th order statistic: min(j+1, n-j)."""
    return min(j + 1, n - j)


def norm_ratio(triple: Tuple[int, int, int]) -> Rat:
    """Normalised first coordinate a / (a + b + c) of a measured count triple."""
    a, b, c = triple
    return Fraction(a, a + b + c)


# --------------------------------------------------------------------------
# The measured data
# --------------------------------------------------------------------------

TRIPLES16: List[Tuple[int, int, int]] = [
    (37, 41, 22), (35, 43, 22), (38, 40, 22), (36, 42, 22),
    (34, 44, 22), (39, 39, 22), (33, 45, 22), (40, 38, 22),
    (36, 41, 23), (37, 40, 23), (35, 42, 23), (38, 39, 23),
    (34, 43, 23), (39, 38, 23), (41, 37, 22), (32, 46, 22),
]

TRIPLES8: List[Tuple[int, int, int]] = TRIPLES16[:8]

RATIOS16: Dataset = [norm_ratio(t) for t in TRIPLES16]
RATIOS8: Dataset = [norm_ratio(t) for t in TRIPLES8]

MEASURED_MEDIAN = Fraction(73, 200)


# --------------------------------------------------------------------------
# Demonstration sections
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def fmt(xs: Sequence[Rat]) -> str:
    return "[" + ", ".join(f"{float(x):.3f}" for x in xs) + "]"


def demo_measured_data() -> None:
    banner("1. The two measured normalised distributions")
    for name, triples, ratios in (
        ("16-sample run", TRIPLES16, RATIOS16),
        ("8-sample run", TRIPLES8, RATIOS8),
    ):
        lo, hi = median_interval(ratios)
        print(f"\n{name}: n = {len(ratios)}")
        print(f"  first three triples : {triples[:3]} ...  (each sums to "
              f"{sum(triples[0])})")
        print(f"  normalised readings : {fmt(ratios)}")
        print(f"  sorted              : {fmt(sorted(ratios))}")
        print(f"  median interval     : [{lo}, {hi}] = "
              f"[{float(lo):.3f}, {float(hi):.3f}]")
        print(f"  midpoint 73/200     = {float(MEASURED_MEDIAN):.3f}   "
              f"is a median? {is_median(ratios, MEASURED_MEDIAN)}")
        print(f"  range               : [{min(ratios)}, {max(ratios)}]")
        print(f"  lower sample median : {lower_median(ratios)}")
        print(f"  breakdown number    : {median_breakdown_number(len(ratios))} "
              f"(breakdown point "
              f"{median_breakdown_number(len(ratios))}/{len(ratios)})")


def demo_counting_stability(trials: int = 2000, seed: int = 20260823) -> None:
    banner("2. Counting stability: a count moves by at most the Hamming distance")
    rng = random.Random(seed)
    worst_slack = None
    tight = 0
    for _ in range(trials):
        n = rng.randint(1, 12)
        xs = [Fraction(rng.randint(-20, 20), rng.randint(1, 5)) for _ in range(n)]
        ys = list(xs)
        for i in range(n):
            if rng.random() < 0.4:
                ys[i] = Fraction(rng.randint(-40, 40), rng.randint(1, 5))
        t = Fraction(rng.randint(-20, 20), rng.randint(1, 5))
        d = hamming(xs, ys)
        lhs = count_le(ys, t)
        rhs = count_le(xs, t) + d
        assert lhs <= rhs, "counting stability violated"
        slack = rhs - lhs
        if slack == 0:
            tight += 1
        worst_slack = slack if worst_slack is None else min(worst_slack, slack)
    print(f"  checked {trials} random pairs (xs, ys) and thresholds t")
    print(f"  the inequality  #(y_i <= t)  <=  #(x_i <= t) + d_H(x,y)  never failed")
    print(f"  it was attained with equality in {tight} of {trials} trials, so the "
          f"bound is tight")


def demo_breakdown_half(trials: int = 20000, seed: int = 7) -> None:
    banner("3. Breakdown half: 2k < n traps every contaminated median in the "
           "clean range")
    rng = random.Random(seed)
    for ratios, budget, name in ((RATIOS16, 7, "16-sample run"),
                                 (RATIOS8, 3, "8-sample run")):
        n = len(ratios)
        lo, hi = min(ratios), max(ratios)
        worst_lo, worst_hi = hi, lo
        for _ in range(trials):
            ys = list(ratios)
            positions = rng.sample(range(n), rng.randint(0, budget))
            for i in positions:
                # the adversary substitutes wildly out-of-range values
                ys[i] = Fraction(rng.choice([-1, 1]) * rng.randint(0, 10 ** 6),
                                 rng.randint(1, 7))
            assert hamming(ratios, ys) <= budget
            mlo, mhi = median_interval(ys)
            # every median of ys lies in [mlo, mhi]; check both endpoints
            for m in (mlo, mhi):
                assert is_median(ys, m)
                assert lo <= m <= hi, "breakdown half violated!"
                worst_lo = min(worst_lo, m)
                worst_hi = max(worst_hi, m)
        print(f"\n  {name}: n = {n}, budget k = {budget} (2k = {2*budget} < {n})")
        print(f"    guaranteed interval  : [{lo}, {hi}] = "
              f"[{float(lo):.3f}, {float(hi):.3f}]")
        print(f"    worst median observed: [{float(worst_lo):.3f}, "
              f"{float(worst_hi):.3f}] over {trials} adversarial trials")
        print(f"    all {trials} trials stayed inside the guaranteed interval")


def demo_sharpness() -> None:
    banner("4. Sharpness half: 2k >= n installs ANY prescribed value as a median")
    targets = [Fraction(-10 ** 9), Fraction(0), Fraction(1, 3),
               Fraction(73, 200), Fraction(10 ** 9)]
    for ratios, k, name in ((RATIOS16, 8, "16-sample run"),
                            (RATIOS8, 4, "8-sample run")):
        n = len(ratios)
        print(f"\n  {name}: n = {n}, budget k = {k} (2k = {2*k} >= {n})")
        for t in targets:
            ys = contaminate(ratios, k, t)
            print(f"    target t = {str(t):>12}  ->  d_H = {hamming(ratios, ys)}, "
                  f"len = {len(ys)}, t is a median? {is_median(ys, t)}")
        # and one below the threshold, to show the attack genuinely fails there
        k_low = k - 1
        t = Fraction(10 ** 9)
        ys = contaminate(ratios, k_low, t)
        print(f"    with only k = {k_low}: t = 10^9 a median? {is_median(ys, t)} "
              f"(the honest majority still wins)")


def demo_mean_vs_median() -> None:
    banner("5. One corrupted entry destroys the mean; the median shrugs")
    for ratios, name in ((RATIOS16, "16-sample run"), (RATIOS8, "8-sample run")):
        n = len(ratios)
        B = Fraction(10 ** 6)
        # the explicit one-point attack of the mean-breakdown theorem
        c = n * (abs(B) + 1) - sum(ratios[1:], Fraction(0))
        ys = [c] + list(ratios[1:])
        lo, hi = median_interval(ys)
        print(f"\n  {name}: n = {n}, target bound B = {B}")
        print(f"    clean mean            = {float(mean(ratios)):.6f}")
        print(f"    clean median interval = [{float(median_interval(ratios)[0]):.3f},"
              f" {float(median_interval(ratios)[1]):.3f}]")
        print(f"    ONE entry replaced by {float(c):.3e}  (Hamming distance "
              f"{hamming(ratios, ys)})")
        print(f"    corrupted mean        = {float(mean(ys)):.6f}  "
              f"(exactly |B| + 1 = {float(abs(B) + 1):.1f})")
        print(f"    corrupted median int. = [{float(lo):.3f}, {float(hi):.3f}]  "
              f"-- still inside the clean range")
        print(f"    breakdown numbers: mean = 1, median = "
              f"{median_breakdown_number(n)}")


def demo_order_stat_profile() -> None:
    banner("6. The order-statistic breakdown profile beta(j) = min(j+1, n-j)")
    for ratios, name in ((RATIOS16, "16-sample run"), (RATIOS8, "8-sample run")):
        n = len(ratios)
        s = sorted(ratios)
        print(f"\n  {name}: n = {n}   (median index j* = {(n - 1) // 2}, "
              f"peak value {median_breakdown_number(n)})")
        print("    j   order stat   beta(j)   tent")
        for j in range(n):
            b = order_stat_breakdown_number(j, n)
            star = "  <-- median index" if j == (n - 1) // 2 else ""
            print(f"   {j:>2}   {float(s[j]):.3f}       {b:>2}      "
                  f"{'#' * b}{star}")
        peak = max(order_stat_breakdown_number(j, n) for j in range(n))
        assert peak == median_breakdown_number(n)
        print(f"    max over j = {peak} = ceil(n/2): the tent peaks exactly at "
              f"the median")

    # verify the sharpness attack against a specific order statistic
    print("\n  Explicit attack on the j-th order statistic (16-sample run):")
    n = len(RATIOS16)
    for j in (0, 3, 7, 12, 15):
        b = order_stat_breakdown_number(j, n)
        if j + 1 <= n - j:
            ys = contaminate(RATIOS16, j + 1, Fraction(-10 ** 9))
            direction = "flood the low tail"
        else:
            ys = contaminate(RATIOS16, n - j, Fraction(10 ** 9))
            direction = "flood the high tail"
        print(f"    j = {j:>2}: beta = {b}, {direction:>19} -> "
              f"T_j = {float(order_stat(j, ys)):+.3e}")


def shear_pair(xs: Sequence[Rat], k: int, c: Rat) -> Tuple[Dataset, Dataset]:
    """The Donoho-Huber shear pair: y = z + c coordinatewise, both k-contaminations."""
    n = len(xs)
    m = n - k
    y = list(xs[:m]) + [x + c for x in xs[m:]]
    z = [x - c for x in xs[:m]] + list(xs[m:])
    return y, z


def demo_universal_ceiling() -> None:
    banner("7. The universal ceiling: the equivariance shear breaks EVERY "
           "equivariant estimator")

    estimators: List[Tuple[str, Callable[[Sequence[Rat]], Rat]]] = [
        ("mean", mean),
        ("lower median", lower_median),
        ("midrange", lambda xs: (min(xs) + max(xs)) / 2),
        ("10% trimmed mean", lambda xs: mean(sorted(xs)[len(xs) // 10:
                                                       len(xs) - len(xs) // 10])),
        ("midhinge", lambda xs: (order_stat(len(xs) // 4, xs)
                                 + order_stat(3 * len(xs) // 4, xs)) / 2),
    ]

    xs = RATIOS16
    n = len(xs)
    c = Fraction(10 ** 6)

    # sanity check: all these estimators really are translation equivariant
    shift = Fraction(17, 3)
    for name, T in estimators:
        shifted = [x + shift for x in xs]
        assert T(shifted) == T(xs) + shift, f"{name} is not equivariant"
    print(f"  all {len(estimators)} estimators verified translation equivariant\n")

    k = median_breakdown_number(n)  # = 8
    y, z = shear_pair(xs, k, c)
    print(f"  sample size n = {n}, budget k = {k} (2k = {2*k} >= {n}), shift "
          f"c = {float(c):.0e}")
    print(f"  shear pair: d_H(x,y) = {hamming(xs, y)}, d_H(x,z) = "
          f"{hamming(xs, z)}, both <= k")
    print(f"  and y = z + c coordinatewise: "
          f"{all(a == b + c for a, b in zip(y, z))}\n")
    print(f"  {'estimator':>18} | {'T(z)':>14} | {'T(y)':>14} | {'T(y)-T(z)':>12}")
    print("  " + "-" * 68)
    for name, T in estimators:
        tz, ty = T(z), T(y)
        assert ty - tz == c, "equivariance forces the gap to equal c"
        print(f"  {name:>18} | {float(tz):>14.4f} | {float(ty):>14.4f} | "
              f"{float(ty - tz):>12.4e}")
    print("\n  Every gap equals c exactly, and c was ours to choose: no bound B "
          "covers both\n  members of the pair. Hence no equivariant estimator "
          f"survives budget {k}.")

    # below the ceiling the shear is unaffordable
    k_low = k - 1
    m = n - k_low
    print(f"\n  At k = {k_low} the two sides of the shear cost m = {m} and "
          f"n - m = {n - m}; the larger,\n  {max(m, n - m)}, exceeds the budget "
          f"{k_low}, so the shear is unaffordable -- consistent with the\n  "
          f"median surviving budget {k_low}.")


def demo_coding_bridge() -> None:
    banner("8. The coding bridge: breakdown = failure of unique decoding")
    xs = RATIOS8
    n = len(xs)
    c = Fraction(1, 7)
    shifted = [x + c for x in xs]
    print(f"  sample size n = {n}, shift c = {c} (non-zero)")
    print(f"  minimum distance of the translation code {{x, x+c}}: "
          f"d_H = {hamming(xs, shifted)} = n")
    print()
    print(f"  {'k':>3} | {'2k >= n?':>9} | {'confusing word exists':>22} | "
          f"{'median bounded?':>16}")
    print("  " + "-" * 62)
    for k in range(0, n + 1):
        m = n - k
        w = [x + c for x in xs[:m]] + list(xs[m:])
        d1, d2 = hamming(xs, w), hamming(shifted, w)
        confusable = (d1 <= k and d2 <= k)
        # theory: confusable iff n <= 2k; median bounded iff 2k < n
        assert confusable == (n <= 2 * k)
        print(f"  {k:>3} | {str(2 * k >= n):>9} | "
              f"{('yes (d=' + str(d1) + ',' + str(d2) + ')') if confusable else 'no':>22}"
              f" | {str(2 * k < n):>16}")
    print()
    print("  The 'confusable' column is the exact complement of the 'median "
          "bounded' column:")
    print("  the statistical breakdown point and the unique-decoding radius are "
          "the same integer.")


def demo_summary_table() -> None:
    banner("9. Summary: breakdown numbers as a function of sample size")
    print(f"  {'n':>4} | {'median ceil(n/2)':>17} | {'mean':>5} | "
          f"{'sample min/max':>15} | {'universal ceiling':>18}")
    print("  " + "-" * 72)
    for n in (1, 2, 3, 4, 5, 8, 9, 16, 17, 100, 101):
        print(f"  {n:>4} | {median_breakdown_number(n):>17} | {1:>5} | "
              f"{order_stat_breakdown_number(0, n):>15} | "
              f"{median_breakdown_number(n):>18}")
    print("\n  The median attains the universal ceiling at every sample size; the "
          "mean and the\n  sample extremes sit at the minimum possible value 1, "
          "independent of n.")


def main() -> None:
    print(__doc__)
    demo_measured_data()
    demo_counting_stability()
    demo_breakdown_half()
    demo_sharpness()
    demo_mean_vs_median()
    demo_order_stat_profile()
    demo_universal_ceiling()
    demo_coding_bridge()
    demo_summary_table()
    banner("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()


"""Certified breakdown analysis of the sample median.

Given a dataset of exact rationals and a contamination budget k, this algorithm
returns a *certificate*: either a proof-of-robustness (an interval that provably
contains every median of every k-contamination, together with the count-based
witness inequality), or a proof-of-failure (an explicit k-contamination whose
median is a prescribed arbitrary target).
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import List, Optional, Sequence

Rat = Fraction


@dataclass
class BreakdownCertificate:
    """Outcome of the analysis at a given budget."""
    n: int
    budget: int
    breakdown_number: int
    robust: bool
    guaranteed_interval: Optional[tuple]        # (a, b) when robust
    witness_inequality: Optional[str]           # the count bound, when robust
    attack: Optional[List[Rat]]                 # explicit contamination, when not
    attack_target: Optional[Rat]                # value installed as the median
    attack_distance: Optional[int]              # Hamming cost of the attack


def hamming(xs: Sequence[Rat], ys: Sequence[Rat]) -> int:
    """Number of positions at which two equal-length datasets differ."""
    if len(xs) != len(ys):
        raise ValueError("datasets must have equal length")
    return sum(1 for a, b in zip(xs, ys) if a != b)


def is_median(xs: Sequence[Rat], m: Rat) -> bool:
    """At least half of xs is <= m and at least half of xs is >= m."""
    n = len(xs)
    return (n <= 2 * sum(1 for x in xs if x <= m)
            and n <= 2 * sum(1 for x in xs if m <= x))


def analyse_median_breakdown(xs: Sequence[Rat],
                             budget: int,
                             target: Rat = Fraction(10 ** 9)
                             ) -> BreakdownCertificate:
    """Return a certificate for the median of `xs` at contamination `budget`.

    Complexity: O(n) for the robust branch (two counting passes), O(n) for the
    attack branch (one prefix overwrite). No sorting is required.
    """
    n = len(xs)
    if n == 0:
        raise ValueError("dataset must be non-empty")
    bn = (n + 1) // 2                      # ceil(n / 2)

    if 2 * budget < n:
        a, b = min(xs), max(xs)
        witness = (f"for every median m of every {budget}-contamination y, "
                   f"{n} <= 2*#{{i : x_i <= m}} + {2 * budget}, hence "
                   f"#{{i : x_i <= m}} > 0 and symmetrically "
                   f"#{{i : m <= x_i}} > 0")
        return BreakdownCertificate(n, budget, bn, True, (a, b), witness,
                                    None, None, None)

    k = min(budget, n)
    attack = [target] * k + list(xs[k:])
    assert is_median(attack, target)
    return BreakdownCertificate(n, budget, bn, False, None, None,
                                attack, target, hamming(xs, attack))


if __name__ == "__main__":
    data = [Fraction(a, 100) for a in
            (37, 35, 38, 36, 34, 39, 33, 40, 36, 37, 35, 38, 34, 39, 41, 32)]
    for k in (0, 5, 7, 8, 12):
        cert = analyse_median_breakdown(data, k)
        head = f"budget {k:>2} (breakdown number {cert.breakdown_number}):"
        if cert.robust:
            a, b = cert.guaranteed_interval
            print(f"{head} ROBUST, every median lies in "
                  f"[{float(a):.3f}, {float(b):.3f}]")
        else:
            print(f"{head} BROKEN, {cert.attack_distance} substitutions install "
                  f"{float(cert.attack_target):.3e} as the median")


"""The order-statistic breakdown profile, with explicit optimal attacks.

For a sample of size n, the j-th order statistic (0-indexed) has breakdown
number exactly beta(j) = min(j+1, n-j).  This algorithm computes the complete
profile in one sort and, for each index, constructs the cheaper of the two
optimal attacks: flood the low tail with a very negative value when
j + 1 <= n - j, otherwise flood the high tail with a very positive one.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import List, Sequence

Rat = Fraction


@dataclass
class ProfileEntry:
    """One row of the breakdown landscape of a sample."""
    index: int
    value: Rat                # the j-th smallest observation
    breakdown_number: int     # beta(j) = min(j+1, n-j)
    attack_side: str          # "low" or "high"
    attack_cost: int          # number of substitutions used
    attacked_value: Rat       # the order statistic after the attack


def order_stat(j: int, xs: Sequence[Rat]) -> Rat:
    """The j-th smallest observation (0-indexed, index clamped to n-1)."""
    s = sorted(xs)
    return s[min(j, len(s) - 1)]


def contaminate(xs: Sequence[Rat], k: int, t: Rat) -> List[Rat]:
    """Overwrite the first k entries of xs with the value t."""
    return [t] * k + list(xs[k:])


def breakdown_profile(xs: Sequence[Rat],
                      magnitude: Rat = Fraction(10 ** 9)) -> List[ProfileEntry]:
    """Compute the full order-statistic breakdown profile of `xs`.

    Complexity: O(n log n) for the single sort, then O(n) per attack, giving
    O(n^2) if every attack is materialised; the profile values alone cost
    O(n log n).
    """
    s = sorted(xs)
    n = len(s)
    rows: List[ProfileEntry] = []
    for j in range(n):
        beta = min(j + 1, n - j)
        if j + 1 <= n - j:
            cost, side, target = j + 1, "low", -magnitude
        else:
            cost, side, target = n - j, "high", magnitude
        attacked = order_stat(j, contaminate(s, cost, target))
        rows.append(ProfileEntry(j, s[j], beta, side, cost, attacked))
    return rows


def profile_peak(n: int) -> int:
    """max_j min(j+1, n-j) = ceil(n/2), attained at j = floor((n-1)/2)."""
    return (n + 1) // 2


if __name__ == "__main__":
    data = [Fraction(a, 100) for a in
            (37, 35, 38, 36, 34, 39, 33, 40, 36, 37, 35, 38, 34, 39, 41, 32)]
    n = len(data)
    print(f"n = {n}, peak beta = {profile_peak(n)} at index {(n - 1) // 2}\n")
    print(f"{'j':>3} {'x_(j)':>8} {'beta':>5}  {'attack':>6} {'cost':>5}"
          f"  {'result':>12}")
    for row in breakdown_profile(data):
        print(f"{row.index:>3} {float(row.value):>8.3f} "
              f"{row.breakdown_number:>5}  {row.attack_side:>6} "
              f"{row.attack_cost:>5}  {float(row.attacked_value):>12.3e}")


"""The equivariance shear and the confusing-word construction.

Two dual constructions that both express the same combinatorial fact --- a
budget k can pay for both halves of a split of an n-element sample exactly when
2k >= n.

  * `shear_pair` builds two k-contaminations y, z of the same sample with
    y = z + c coordinatewise.  Translation equivariance forces T(y) - T(z) = c
    for every location estimator T, so no bound can control both: this breaks
    *every* equivariant estimator at budget ceil(n/2).

  * `confusing_word` builds a single dataset within Hamming distance k of both
    x and its translate x + c, certifying that the two-word translation code
    {x, x+c} of minimum distance n fails unique decoding at radius k.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Rat = Fraction


def hamming(xs: Sequence[Rat], ys: Sequence[Rat]) -> int:
    """Number of positions at which two equal-length datasets differ."""
    return sum(1 for a, b in zip(xs, ys) if a != b)


def shear_pair(xs: Sequence[Rat], k: int, c: Rat) -> Tuple[List[Rat], List[Rat]]:
    """Return (y, z) with y = z + c, both within Hamming distance k of xs.

    Requires 2k >= n.  The split point is m = n - k: `y` shifts the tail up by c
    (cost n - m = k) and `z` shifts the head down by c (cost m = n - k <= k).
    Complexity: O(n).
    """
    n = len(xs)
    if 2 * k < n:
        raise ValueError("the shear is only affordable when 2k >= n")
    m = n - k
    y = list(xs[:m]) + [x + c for x in xs[m:]]
    z = [x - c for x in xs[:m]] + list(xs[m:])
    return y, z


def certify_equivariant_breakdown(T: Callable[[Sequence[Rat]], Rat],
                                  xs: Sequence[Rat],
                                  k: int,
                                  c: Rat) -> Tuple[Rat, Rat, Rat]:
    """Evaluate a translation-equivariant estimator on the shear pair.

    Returns (T(z), T(y), T(y) - T(z)); the last entry is forced to equal c, so
    choosing c large exhibits unboundedness of T under budget k.
    """
    y, z = shear_pair(xs, k, c)
    return T(z), T(y), T(y) - T(z)


def confusing_word(xs: Sequence[Rat], k: int, c: Rat) -> List[Rat]:
    """A dataset within distance k of both xs and xs + c.  Requires n <= 2k.

    Shift the first n - k coordinates by c and leave the rest: the result is at
    distance <= n - k <= k from xs and at distance <= k from xs + c.
    Complexity: O(n).
    """
    n = len(xs)
    if n > 2 * k:
        raise ValueError("no confusing word exists: 2k < n means unique decoding")
    m = n - k
    return [x + c for x in xs[:m]] + list(xs[m:])


def unique_decoding_radius(n: int) -> int:
    """Largest k for which the translation code {x, x+c} decodes uniquely."""
    return (n - 1) // 2


if __name__ == "__main__":
    data = [Fraction(a, 100) for a in
            (37, 35, 38, 36, 34, 39, 33, 40, 36, 37, 35, 38, 34, 39, 41, 32)]
    n = len(data)
    c = Fraction(10 ** 6)

    def lower_median(zs: Sequence[Rat]) -> Rat:
        return sorted(zs)[(len(zs) - 1) // 2]

    tz, ty, gap = certify_equivariant_breakdown(lower_median, data, (n + 1) // 2, c)
    print(f"shear at k = {(n + 1) // 2}: T(z) = {float(tz):.1f}, "
          f"T(y) = {float(ty):.1f}, gap = {float(gap):.1e} = c")

    shifted = [x + c for x in data]
    print(f"translation code minimum distance: {hamming(data, shifted)} = n")
    print(f"unique decoding radius: k <= {unique_decoding_radius(n)}")
    w = confusing_word(data, (n + 1) // 2, c)
    print(f"confusing word at k = {(n + 1) // 2}: distances "
          f"{hamming(data, w)} and {hamming(shifted, w)}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")

LEAN_FILES = [
    "Catalog/Computation/MedianBreakdown.lean",
    "Catalog/Computation/MedianBreakdownOptimality.lean",
    "Catalog/Computation/MedianBreakdownSelector.lean",
    "Catalog/Computation/MedianBreakdownOrderStatistics.lean",
    "Catalog/Computation/MedianBreakdownCoding.lean",
]


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def asset(name: str) -> str:
    return read(os.path.join(ASSETS, name))


def root(name: str) -> str:
    return read(os.path.join(ROOT, name))


def lean_bundle() -> str:
    parts: List[str] = []
    for rel in LEAN_FILES:
        parts.append(f"-- ==========================================================\n"
                     f"-- FILE: {rel}\n"
                     f"-- ==========================================================\n")
        parts.append(read(os.path.join(ROOT, rel)))
        parts.append("\n")
    return "".join(parts)


FUTURE_DIRECTIONS = """# Future Directions — from the median breakdown theorem outward

This cycle closed the assignment (the sharpness half of the breakdown theorem on
the two measured normalised distributions) and then kept iterating: the
threshold `2k = n` turned out to be forced by three independent structures — an
order-statistic tent, an equivariance shear, and a Hamming minimum distance.
The directions below are the conjectures that this triple coincidence suggests.

---

## D1. Concave Breakdown Profiles for L-Estimators

**Conjecture.** For any weight vector `w : Fin n → ℚ≥0` with `∑ w = 1`, the
L-estimator `T_w(xs) = ∑ⱼ wⱼ · orderStat j xs` has breakdown number exactly
`min { j+1 : w_{j'} > 0 for some j' ≤ j } ⊓ min { n-j : w_{j'} > 0 for some j' ≥ j }`,
i.e. the breakdown number is the *tent profile evaluated at the extreme support
points of `w`*, and the profile of an L-estimator is the pointwise minimum of the
profiles of the order statistics it charges.

**The key insight is** that the proven order-statistic profile
`min (j+1, n-j)` is not a coincidence of the median but a *support functional*:
contamination can only reach an L-estimator through the extremal order statistics
its weights touch, so the profile of a mixture collapses to the minimum of the
profiles of its atoms.

**Why now?** The two sandwich lemmas that bound an order statistic from a count
alone read a bound off a *count* only. Summing count-based bounds is exactly what
a weighted average needs, so the L-estimator case is now a finite-sum argument
rather than a new sorting argument. If true, this immediately yields the
breakdown numbers of the trimmed mean, the Winsorised mean, the midhinge, and
the Tukey trimean as corollaries of a single theorem.

---

## D2. Minimum-Distance Duality for Breakdown Points

**Conjecture.** Let `G` be a group acting coordinatewise on `ℚⁿ` and let `T` be
`G`-equivariant.  Then the breakdown number of `T` at `xs` is at most
`⌈d_G(xs)/2⌉`, where `d_G(xs) = min { dist_H(xs, g·xs) : g ∈ G, g·xs ≠ xs }` is
the minimum Hamming distance of the `G`-orbit of `xs`, and equality holds when
`G` acts by translations.

**The key insight is** that the bridge theorem already identifies the median's
breakdown threshold with the unique-decoding radius of the two-point code
`{xs, xs+c}`; the translation group is just the case where every orbit element is
at full distance `n`, and a group with sparser orbits should cap robustness
earlier and *more sharply*.

**Why now?** The contamination distance was proved to be a genuine Hamming metric
(symmetry and the triangle inequality) and the confusability criterion is stated
for an arbitrary shift.  Replacing "shift by `c`" by "act by `g`" changes only the
computation of the distance from `xs` to `g · xs`.  A consequence would be a
*scale*-equivariance ceiling for dispersion estimators (MAD, IQR), currently
unformalised anywhere.

---

## D3. Block-Median Breakdown Collapse

**Conjecture.** When a sample is partitioned into `b` blocks and a
median-of-medians is formed, the breakdown number is governed by the *product*
structure of the partition rather than by `n`: the adversary need only capture a
majority within a majority of blocks, so the effective threshold collapses from
`⌈n/2⌉` towards `⌈b/2⌉ · ⌈(n/b)/2⌉`, which is asymptotically `n/4` rather than
`n/2`.  Making this exact — and identifying the block sizes that minimise the
loss — would quantify the robustness cost of the hierarchical aggregation schemes
used in distributed estimation.
"""


def build() -> Dict[str, Any]:
    demo_src = root("demo.py")
    return {
        "title": "Half the Data Can Lie: The Exact Breakdown Theorem for the "
                 "Sample Median",
        "domain": "Computation",
        "description": (
            "A complete two-sided finite-sample analysis of the sample median "
            "under adversarial replacement contamination: the median is provably "
            "trapped inside the range of the honest data whenever fewer than half "
            "the entries are corrupted, and any prescribed value can be installed "
            "as the median as soon as half of them are. The threshold ceil(n/2) is "
            "shown to be a universal ceiling for all translation-equivariant "
            "estimators, the peak of the order-statistic breakdown tent, and the "
            "unique-decoding radius of the translation code, and every result is "
            "instantiated on two measured normalised distributions."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-23",
        "key_results": [
            "Counting Stability Lemma: for any predicate, the number of entries "
            "satisfying it changes by at most the Hamming distance between two "
            "equal-length datasets.",
            "Two-sided Breakdown Theorem for the median: the median is bounded "
            "under a contamination budget k if and only if 2k < n, so its "
            "breakdown number is exactly ceil(n/2), against a breakdown number of "
            "1 for the sample mean.",
            "Universal Breakdown Ceiling: every translation-equivariant location "
            "estimator is unbounded once 2k >= n, and the lower sample median is a "
            "concrete single-valued equivariant estimator attaining that ceiling.",
            "Order-Statistic Breakdown Profile: the j-th order statistic has "
            "breakdown number exactly min(j+1, n-j), a concave tent maximised "
            "precisely at the median index.",
            "Bridge Theorem: the median breaks down under budget k exactly when "
            "the two-word translation code {x, x+c} fails unique decoding at "
            "radius k, identifying the breakdown point with a minimum-distance "
            "decoding radius; on the measured 16- and 8-sample runs the breakdown "
            "numbers are exactly 8 and 4, with guaranteed median ranges [0.32, "
            "0.41] and [0.33, 0.40].",
        ],
        "keywords": [
            "breakdown point", "sample median", "adversarial contamination",
            "Hamming distance", "order statistics", "translation equivariance",
            "unique decoding", "robust statistics",
        ],
        "article": root("ARTICLE.md"),
        "research_paper": root("RESEARCH_PAPER.md"),
        "research_paper_tex": root("RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "End-to-End Verification of the Breakdown Theorem on Two "
                        "Measured Normalised Distributions",
                "description": (
                    "A nine-part numerical tour, carried out in exact rational "
                    "arithmetic so that no printed value is subject to rounding. "
                    "It reconstructs the two measured runs from their raw "
                    "three-channel count triples and confirms that both have "
                    "median 73/200; stress-tests the Counting Stability Lemma on "
                    "two thousand random dataset pairs and records how often it is "
                    "tight; runs twenty thousand adversarial trials at budget 7 "
                    "(respectively 3) and verifies that every median of every "
                    "corrupted sample stays inside the range of the honest data; "
                    "installs targets as extreme as +/-10^9 as medians using "
                    "exactly ceil(n/2) substitutions; carries out the explicit "
                    "one-point attack that drives the mean to any prescribed value "
                    "while the median does not move; tabulates the full "
                    "order-statistic breakdown tent with its optimal per-index "
                    "attacks; evaluates five genuinely equivariant estimators on "
                    "the Donoho-Huber shear pair and checks that every estimate "
                    "gap equals the chosen shift exactly; and finally tabulates "
                    "confusability of the translation code against boundedness of "
                    "the median, showing the two columns to be exact complements."
                ),
                "code": demo_src,
            },
        ],
        "algorithms": [
            {
                "name": "Certified Breakdown Analysis of the Sample Median",
                "description": (
                    "Given a dataset of exact rationals and a contamination budget "
                    "k, this algorithm returns a machine-checkable certificate of "
                    "one of two kinds. When 2k < n it returns a robustness "
                    "certificate: the interval spanned by the honest data, which "
                    "provably contains every median of every k-contamination, "
                    "together with the counting witness n <= 2*#{i : x_i <= m} + 2k "
                    "that establishes it. When 2k >= n it returns a failure "
                    "certificate: an explicit k-contamination, obtained by "
                    "overwriting the first k entries with a prescribed target, "
                    "whose median is that target. The dichotomy is exhaustive and "
                    "matches the exact breakdown number ceil(n/2), so the algorithm "
                    "never returns 'unknown'. Both branches run in O(n) time with "
                    "two counting passes and no sorting, and use exact rational "
                    "arithmetic so the certificate is not subject to floating-point "
                    "error."
                ),
                "pseudocode": (
                    "INPUT : dataset x = (x_1,...,x_n) of rationals, budget k >= 0,\n"
                    "        target t (used only in the failure branch)\n"
                    "OUTPUT: a robustness certificate or an explicit attack\n"
                    "\n"
                    " 1. if n = 0 then error 'dataset must be non-empty'\n"
                    " 2. bn <- floor((n + 1) / 2)                  // = ceil(n/2)\n"
                    " 3. if 2*k < n then                            // ROBUST BRANCH\n"
                    " 4.     a <- min_i x_i ; b <- max_i x_i        // one pass\n"
                    " 5.     witness <- 'for every median m of every k-contamination y,'\n"
                    " 6.                'n <= 2*#{i : x_i <= m} + 2k, hence both'\n"
                    " 7.                'half-counts of x at m are strictly positive'\n"
                    " 8.     return ROBUST(interval = [a, b], witness, bn)\n"
                    " 9. else                                       // FAILURE BRANCH\n"
                    "10.     k' <- min(k, n)\n"
                    "11.     y  <- (t repeated k' times) ++ (x_{k'+1},...,x_n)\n"
                    "12.     assert #{i : y_i <= t} >= k' and #{i : t <= y_i} >= k'\n"
                    "13.     assert n <= 2*k'      // both median conditions hold\n"
                    "14.     return BROKEN(attack = y, target = t,\n"
                    "15.                   distance = hamming(x, y) <= k, bn)\n"
                ),
                "code": asset("algo_breakdown_certificate.py"),
            },
            {
                "name": "Computation of the Order-Statistic Breakdown Profile with "
                        "Optimal Attacks",
                "description": (
                    "Computes the complete robustness landscape of a sample: for "
                    "every index j it reports the j-th smallest observation, its "
                    "exact breakdown number beta(j) = min(j+1, n-j), and the "
                    "cheaper of the two optimal attacks against it. The two attacks "
                    "come from converse sandwich facts — if at least j+1 entries "
                    "are <= t then the j-th order statistic is <= t, and if at "
                    "least n-j entries are >= t then it is >= t — so flooding the "
                    "low tail with j+1 copies of a large negative value, or the "
                    "high tail with n-j copies of a large positive one, destroys "
                    "it. The profile is a discrete tent equal to 1 at both sample "
                    "extremes and peaking at ceil(n/2) at the median index, which "
                    "is exactly the universal ceiling for translation-equivariant "
                    "estimators. Complexity: one sort, O(n log n), for the profile "
                    "values; materialising all n attacks costs a further O(n^2)."
                ),
                "pseudocode": (
                    "INPUT : dataset x of length n, attack magnitude M (large)\n"
                    "OUTPUT: for each j in 0..n-1 the row\n"
                    "        (x_(j), beta(j), attack side, attack cost, attacked value)\n"
                    "\n"
                    " 1. s <- sort(x)                                  // O(n log n)\n"
                    " 2. rows <- empty list\n"
                    " 3. for j = 0 to n-1 do\n"
                    " 4.     beta <- min(j + 1, n - j)\n"
                    " 5.     if j + 1 <= n - j then\n"
                    " 6.         cost <- j + 1 ; side <- 'low'  ; target <- -M\n"
                    " 7.     else\n"
                    " 8.         cost <- n - j ; side <- 'high' ; target <- +M\n"
                    " 9.     y <- (target repeated cost times) ++ drop(cost, s)\n"
                    "10.     rows.append((s[j], beta, side, cost, orderStat(j, y)))\n"
                    "11. return rows\n"
                    "12. // invariants: max_j beta(j) = ceil(n/2), attained at\n"
                    "13. //             j = floor((n-1)/2); beta(0) = beta(n-1) = 1\n"
                ),
                "code": asset("algo_order_stat_profile.py"),
            },
            {
                "name": "The Equivariance Shear and the Confusing-Word Construction",
                "description": (
                    "Two dual constructions that express one combinatorial fact: a "
                    "budget k can pay for both halves of a split of an n-element "
                    "sample exactly when 2k >= n. The shear produces two "
                    "k-contaminations y and z of the same honest sample with y = z "
                    "+ c coordinatewise; translation equivariance then forces T(y) "
                    "- T(z) = c for every location estimator T, so choosing c "
                    "enormous defeats any bound and breaks every equivariant "
                    "estimator at budget ceil(n/2). The confusing word produces a "
                    "single dataset within Hamming distance k of both x and its "
                    "translate x + c, certifying that the two-word translation code "
                    "of minimum distance n fails unique decoding at radius k. The "
                    "two constructions use the same split point m = n - k and are "
                    "the statistical and coding-theoretic readings of the same "
                    "picture. Both run in O(n) time."
                ),
                "pseudocode": (
                    "SHEAR PAIR\n"
                    "INPUT : dataset x of length n, budget k with 2k >= n, shift c\n"
                    "OUTPUT: (y, z) with d_H(x,y) <= k, d_H(x,z) <= k, y = z + c\n"
                    " 1. m <- n - k                       // split point\n"
                    " 2. y <- x_1..x_m  ++  (x_{m+1}+c, ..., x_n+c)   // cost n-m = k\n"
                    " 3. z <- (x_1-c, ..., x_m-c)  ++  x_{m+1}..x_n   // cost m = n-k <= k\n"
                    " 4. return (y, z)                    // y_i = z_i + c for all i\n"
                    "\n"
                    "CERTIFY EQUIVARIANT BREAKDOWN\n"
                    "INPUT : equivariant estimator T, dataset x, budget k, shift c\n"
                    " 5. (y, z) <- SHEAR PAIR(x, k, c)\n"
                    " 6. assert T(y) - T(z) = c           // forced by equivariance\n"
                    " 7. // any bound B fails once c > 2|B|\n"
                    "\n"
                    "CONFUSING WORD\n"
                    "INPUT : dataset x of length n, radius k with n <= 2k, shift c != 0\n"
                    "OUTPUT: w with d_H(x,w) <= k and d_H(x+c,w) <= k\n"
                    " 8. m <- n - k\n"
                    " 9. w <- (x_1+c, ..., x_m+c)  ++  x_{m+1}..x_n\n"
                    "10. assert d_H(x, w)   <= m     = n - k <= k\n"
                    "11. assert d_H(x+c, w) <= n - m = k\n"
                    "12. return w\n"
                ),
                "code": asset("algo_shear_and_decode.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Breakdown Tent of the Order Statistics",
                "description": (
                    "Left: the breakdown profile beta(j) = min(j+1, n-j) drawn over "
                    "the sixteen sorted measured readings, with the universal "
                    "ceiling ceil(n/2) = 8 marked as a dashed line and the two "
                    "median indices highlighted; the sample minimum 0.32 and "
                    "maximum 0.41 sit at height 1, exactly as fragile as the mean. "
                    "Right: the same profile for several sample sizes, rescaled to "
                    "the unit square, converging to the triangle min(u, 1-u) whose "
                    "peak is the breakdown point 1/2."
                ),
                "code": asset("viz_tent_profile.py"),
            },
            {
                "name": "Mean versus Median under a Growing Adversarial Budget",
                "description": (
                    "Left: for each budget k the set of values attainable by the "
                    "sample mean and by a median of some k-contamination of the "
                    "sixteen measured readings, on a symmetric log scale. The "
                    "mean's band is already unbounded at k = 1; the median's is a "
                    "hairline pinned inside the honest data range until k = 8, "
                    "where it explodes. Right: a zoom on the median, showing the "
                    "worst attainable value under the downward and upward flooding "
                    "attacks; both walk to the edges of the guaranteed interval "
                    "[0.32, 0.41] and stop there, which is the two-sided breakdown "
                    "theorem drawn as a picture."
                ),
                "code": asset("viz_contamination_race.py"),
            },
            {
                "name": "The Equivariance Shear and Its Coding-Theoretic Twin",
                "description": (
                    "Left: the Donoho-Huber shear. The head of the sample is pushed "
                    "down by c and the tail is pushed up by c, producing two "
                    "datasets that are each within Hamming distance 8 of the honest "
                    "sixteen readings and that differ by a global translation; "
                    "equivariance forces any location estimator to report values "
                    "exactly c apart on them. Right: the same split read as coding "
                    "theory. The honest sample and its translate are two codewords "
                    "at Hamming distance n = 16, and shifting the first n - k "
                    "coordinates produces a single word within radius k of both, so "
                    "the two hypotheses are indistinguishable at exactly the radius "
                    "at which the median breaks down."
                ),
                "code": asset("viz_shear_geometry.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Adversarial Contamination Sandbox",
                "description": (
                    "You play the adversary against sixteen measured readings "
                    "clustered near 0.365. A slider sets the contamination budget k "
                    "from 0 to 16; a second slider and three attack strategies "
                    "(install a chosen value, flood downward, flood upward) decide "
                    "what goes into the corrupted slots. The plot shows each "
                    "position of the sample with its original and substituted "
                    "value, the shaded range of the honest data, the live median "
                    "interval of the corrupted sample and the live sample mean, "
                    "while a panel reports the Hamming distance, both half-counts "
                    "and a verdict. The intended discovery is the cliff: at k = 7 "
                    "the median slides at most to the edge of [0.32, 0.41] and "
                    "stops dead, and at k = 8 it goes anywhere at all, while the "
                    "mean has already been off the scale since k = 1. Two "
                    "progressive-disclosure panels give the full counting proof of "
                    "the robustness half and the shear proof of the universal "
                    "ceiling."
                ),
                "html": asset("widget_sandbox.html"),
            },
            {
                "title": "The Breakdown Tent Explorer",
                "description": (
                    "An interactive rendering of the order-statistic breakdown "
                    "profile beta(j) = min(j+1, n-j). Sliders set the sample size n "
                    "and the index j; the bar chart redraws the whole tent, marks "
                    "the universal ceiling ceil(n/2) and the median index, and "
                    "highlights the selected order statistic. A readout names the "
                    "selected quantile, states how many corrupted entries it "
                    "survives, identifies which of the two optimal attacks (flood "
                    "the low tail with j+1 slots, or the high tail with n-j) is "
                    "cheaper, and compares its robustness to the median's. Expanding "
                    "panels derive the profile from the two converse counting facts "
                    "and explain why the same ceiling binds every "
                    "translation-equivariant estimator, not merely the quantiles."
                ),
                "html": asset("widget_tent.html"),
            },
        ],
        "interactive_layout": asset("interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }


if __name__ == "__main__":
    pkg = build()
    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(pkg, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"wrote {out} ({os.path.getsize(out)} bytes)")


"""Visualisation: mean versus median under a growing adversarial budget.

Left panel: for each budget k = 0, 1, ..., n, the range of values attainable by
the sample mean and by a median of some k-contamination of the 16 measured
readings.  The median's band is flat and pinned inside the clean data range
until k reaches 8, where it explodes; the mean's band is already unbounded at
k = 1.

Right panel: the worst-case median as a function of the budget, obtained by
flooding k positions with a large negative and a large positive value.  The
attainable set is exactly the clean range for k < 8 and the whole line at k = 8,
which is the two-sided breakdown theorem drawn as a picture.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

READINGS = [Fraction(a, 100) for a in
            (37, 35, 38, 36, 34, 39, 33, 40, 36, 37, 35, 38, 34, 39, 41, 32)]

BIG = Fraction(10 ** 6)


def median_interval(xs: Sequence[Fraction]) -> Tuple[Fraction, Fraction]:
    s = sorted(xs)
    n = len(s)
    if n % 2 == 1:
        return (s[(n - 1) // 2], s[(n - 1) // 2])
    return (s[n // 2 - 1], s[n // 2])


def flood(xs: Sequence[Fraction], k: int, t: Fraction) -> List[Fraction]:
    return [t] * k + list(xs[k:])


def main() -> None:
    n = len(READINGS)
    ks = list(range(n + 1))

    med_lo, med_hi, mean_lo, mean_hi = [], [], [], []
    for k in ks:
        down = flood(READINGS, k, -BIG)
        up = flood(READINGS, k, BIG)
        med_lo.append(float(median_interval(down)[0]))
        med_hi.append(float(median_interval(up)[1]))
        mean_lo.append(float(sum(down, Fraction(0)) / n))
        mean_hi.append(float(sum(up, Fraction(0)) / n))

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5))

    ax0.fill_between(ks, mean_lo, mean_hi, color="#c94f4f", alpha=0.30,
                     step="post", label="attainable means")
    ax0.fill_between(ks, med_lo, med_hi, color="#2b7a4b", alpha=0.55,
                     step="post", label="attainable medians")
    ax0.set_yscale("symlog", linthresh=1.0)
    ax0.axvline(8, ls="--", color="black", lw=1.2)
    ax0.text(8.2, 8e3, "breakdown at\n$k = \\lceil n/2 \\rceil = 8$", fontsize=10)
    ax0.set_xlabel("contamination budget $k$ (out of $n = 16$)")
    ax0.set_ylabel("attainable estimate (symlog scale)")
    ax0.set_title("The mean fails at $k = 1$; the median holds until $k = 8$")
    ax0.legend(loc="upper left", fontsize=9)

    clean_lo, clean_hi = float(min(READINGS)), float(max(READINGS))
    ax1.fill_between(ks[:9], [clean_lo] * 9, [clean_hi] * 9, color="#2b7a4b",
                     alpha=0.45, step="post",
                     label="guaranteed median range")
    ax1.plot(ks[:8], med_lo[:8], "o-", color="#14532d", lw=1.6,
             label="worst median, downward attack")
    ax1.plot(ks[:8], med_hi[:8], "s-", color="#166534", lw=1.6,
             label="worst median, upward attack")
    ax1.axhline(clean_lo, ls=":", color="grey")
    ax1.axhline(clean_hi, ls=":", color="grey")
    ax1.axvline(8, ls="--", color="black", lw=1.2)
    ax1.annotate("at $k=8$ the attainable set\nbecomes the whole line",
                 xy=(8, 0.42), xytext=(2.6, 0.437),
                 arrowprops=dict(arrowstyle="->", lw=1.2), fontsize=10)
    ax1.set_xlim(-0.3, 10)
    ax1.set_ylim(0.30, 0.455)
    ax1.set_xlabel("contamination budget $k$")
    ax1.set_ylabel("median of the corrupted sample")
    ax1.set_title(r"Below $2k = n$ the median never leaves $[0.32,\ 0.41]$")
    ax1.legend(loc="lower left", fontsize=9)

    fig.suptitle("Two halves of one theorem: robustness up to $2k < n$, "
                 "total failure at $2k \\geq n$", fontsize=13)
    fig.tight_layout()
    fig.savefig("contamination_race.png", dpi=160)
    print("wrote contamination_race.png")


if __name__ == "__main__":
    main()


"""Visualisation: the equivariance shear and the confusing word, side by side.

Both panels draw the 16 measured readings as dots along the index axis.

Left: the Donoho-Huber shear.  The head of the sample is pushed down by c and
the tail is pushed up by c, producing two datasets z and y that are each within
Hamming distance k = 8 of the honest sample and that differ by the *global*
translation c.  Equivariance forces any location estimator to report values
exactly c apart on them, so no bound can cover both.

Right: the coding-theoretic twin.  The honest sample x and its translate x + c
are two codewords at Hamming distance n = 16.  Shifting the first n - k
coordinates produces a single word sitting within distance k of both, so the two
hypotheses are indistinguishable --- unique decoding fails at exactly the same
radius at which the median breaks down.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np

READINGS = [Fraction(a, 100) for a in
            (37, 35, 38, 36, 34, 39, 33, 40, 36, 37, 35, 38, 34, 39, 41, 32)]


def main() -> None:
    n = len(READINGS)
    k = (n + 1) // 2          # 8
    m = n - k                 # 8
    c = 0.30                  # a visible shift, exaggerated for the picture
    x = np.array([float(v) for v in READINGS])
    idx = np.arange(n)

    y = x.copy(); y[m:] += c          # shift the tail up
    z = x.copy(); z[:m] -= c          # shift the head down
    w = x.copy(); w[:m] += c          # the confusing word
    xc = x + c                        # the translate

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5), sharey=True)

    ax0.plot(idx, x, "o", color="black", ms=7, label="honest sample $x$")
    ax0.plot(idx, y, "^", color="#2b7a4b", ms=8,
             label=f"$y$: tail shifted $+c$  (cost $n-m={n-m}$)")
    ax0.plot(idx, z, "v", color="#c94f4f", ms=8,
             label=f"$z$: head shifted $-c$  (cost $m={m}$)")
    for i in range(n):
        ax0.plot([i, i], [min(z[i], y[i]), max(z[i], y[i])], color="grey",
                 lw=0.6, zorder=0)
    ax0.axvline(m - 0.5, ls="--", color="black", lw=1.0)
    ax0.text(m - 0.4, 0.06, "split point $m = n-k$", fontsize=10)
    ax0.annotate("", xy=(11, z[11]), xytext=(11, y[11]),
                 arrowprops=dict(arrowstyle="<->", lw=1.8, color="#1d4ed8"))
    ax0.text(11.3, (z[11] + y[11]) / 2, "$y = z + c$\nglobally", fontsize=11,
             color="#1d4ed8")
    ax0.set_ylim(0.0, 1.05)
    ax0.set_xlabel("position $i$")
    ax0.set_ylabel("value")
    ax0.set_title(f"Equivariance shear at $k = {k}$:\n"
                  "two legal contaminations forced $c$ apart")
    ax0.legend(loc="upper left", fontsize=9)

    ax1.plot(idx, x, "o", color="black", ms=7, label="codeword $x$")
    ax1.plot(idx, xc, "s", color="#7c3aed", ms=7, label="codeword $x + c$")
    ax1.plot(idx, w, "X", color="#d97706", ms=9,
             label=f"confusing word $w$ ($d_H = {k}$ to each)")
    for i in range(n):
        ax1.plot([i, i], [x[i], xc[i]], color="grey", lw=0.6, zorder=0)
    ax1.axvline(m - 0.5, ls="--", color="black", lw=1.0)
    ax1.text(0.2, 0.12, f"$d_H(x,\\, x+c) = n = {n}$", fontsize=11)
    ax1.text(0.2, 0.05, "unique decoding fails once $2k \\geq n$", fontsize=11)
    ax1.set_xlabel("position $i$")
    ax1.set_title("Translation code $\\{x,\\ x+c\\}$:\n"
                  "one word within radius $k$ of both")
    ax1.legend(loc="upper left", fontsize=9)

    fig.suptitle("The same split of the sample, read statistically (left) and "
                 "coding-theoretically (right)", fontsize=13)
    fig.tight_layout()
    fig.savefig("shear_geometry.png", dpi=160)
    print("wrote shear_geometry.png")


if __name__ == "__main__":
    main()


"""Visualisation: the order-statistic breakdown tent, and where the median sits.

Left panel: the breakdown profile beta(j) = min(j+1, n-j) for the 16 measured
readings, drawn as a discrete tent over the sorted sample, with the universal
ceiling ceil(n/2) marked as a dashed line and the median index highlighted.

Right panel: the same profile for several sample sizes, rescaled to the unit
square, showing that the tent converges to the triangle min(u, 1-u) and that its
peak converges to the breakdown point 1/2.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt
import numpy as np

TRIPLES16 = [(37, 41, 22), (35, 43, 22), (38, 40, 22), (36, 42, 22),
             (34, 44, 22), (39, 39, 22), (33, 45, 22), (40, 38, 22),
             (36, 41, 23), (37, 40, 23), (35, 42, 23), (38, 39, 23),
             (34, 43, 23), (39, 38, 23), (41, 37, 22), (32, 46, 22)]


def norm_ratio(t: tuple) -> Fraction:
    a, b, c = t
    return Fraction(a, a + b + c)


def profile(n: int) -> List[int]:
    """beta(j) = min(j+1, n-j) for j = 0, ..., n-1."""
    return [min(j + 1, n - j) for j in range(n)]


def main() -> None:
    ratios = sorted(float(norm_ratio(t)) for t in TRIPLES16)
    n = len(ratios)
    beta = profile(n)
    ceiling = (n + 1) // 2
    peak_index = (n - 1) // 2

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5))

    colours = ["#c94f4f" if b < ceiling else "#2b7a4b" for b in beta]
    ax0.bar(range(n), beta, color=colours, edgecolor="black", linewidth=0.6)
    ax0.axhline(ceiling, ls="--", color="black", lw=1.2,
                label=f"universal ceiling $\\lceil n/2 \\rceil = {ceiling}$")
    ax0.annotate("median index", xy=(peak_index, ceiling),
                 xytext=(peak_index - 4.5, ceiling + 1.4),
                 arrowprops=dict(arrowstyle="->", lw=1.2), fontsize=11)
    ax0.set_xticks(range(n))
    ax0.set_xticklabels([f"{v:.2f}" for v in ratios], rotation=90, fontsize=8)
    ax0.set_xlabel("sorted measured reading  $x_{(j)}$")
    ax0.set_ylabel(r"breakdown number  $\beta(j) = \min(j+1,\ n-j)$")
    ax0.set_title("Breakdown tent of the 16 measured readings")
    ax0.set_ylim(0, ceiling + 2.6)
    ax0.legend(loc="upper left", fontsize=9)

    for n2, style in ((5, "o-"), (8, "s-"), (16, "^-"), (64, "-")):
        b = np.array(profile(n2), dtype=float) / n2
        u = (np.arange(n2) + 0.5) / n2
        ax1.plot(u, b, style, ms=4, lw=1.4, label=f"$n = {n2}$")
    u = np.linspace(0, 1, 400)
    ax1.plot(u, np.minimum(u, 1 - u), "k--", lw=1.2,
             label=r"limit $\min(u,\,1-u)$")
    ax1.axhline(0.5, color="grey", lw=0.8)
    ax1.set_xlabel("relative index  $u = j/n$")
    ax1.set_ylabel(r"breakdown point  $\beta(j)/n$")
    ax1.set_title("The tent rescales to a triangle peaking at $1/2$")
    ax1.legend(fontsize=9)

    fig.suptitle("Robustness increases monotonically towards the median, "
                 "and peaks exactly there", fontsize=13)
    fig.tight_layout()
    fig.savefig("tent_profile.png", dpi=160)
    print("wrote tent_profile.png")


if __name__ == "__main__":
    main()
