"""
demo.py -- Numerical demonstration of the low-tail seed-ensemble results.

Context
-------
An attention-truncation experiment on a small causal transformer
(d = 4 heads, ctx = 2048 tokens, accuracy bar 0.98 of the untruncated model)
measured a "knee" -- the smallest retained top-k attention budget at which the
model still meets the bar -- for three training seeds:

        K = {256, 224, 160}

with product point P = d * ctx / 32 = 256 (an 8x attention speed-up), so the
three knees read P, (7/8)P and (5/8)P.  The value 224 = (7/8)P is the centre of
the sample; the straggler 160 = (5/8)P is the "low tail".  A fourth seed was
pre-registered with outcome set {160, 192, 224, 256}.

This script verifies, by direct computation, every quantitative claim of the
accompanying paper:

  1. the tail bar tau = 192 = (3/4)P is the midpoint of 160 and 224;
  2. the tail statistic is a threshold functional of the fourth knee, and the
     pre-registered dichotomy holds exactly;
  3. the fourth seed carries exactly one bit: the verdict is constant on
     {160,192} and on {224,256};
  4. both centre summaries (Fermat-Weber optimality of 224, and the median
     breakdown number) are constant across all four outcomes, hence cannot
     predict the tail verdict;
  5. the breakdown number of the k-th order statistic is min(k, n-k+1), with
     matching two-sided attacks, and the lower-median parity law;
  6. confirmation and calibration are mutually exclusive at four seeds
     (every confirming outcome biases the central reading by >= P/16 = 16);
  7. five seeds reconcile them: {256,224,160,192,224} has a stable tail, a
     zero-bias median rung 224, and breakdown 3; {256,224,160,192,160} has
     verdict breakdown 2 and centre breakdown 3;
  8. a confirmed low tail certifies a majority speed-up of at least 32/3.

Run with:  python3 demo.py
No dependencies beyond the Python standard library.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import Iterable, Sequence

# --------------------------------------------------------------------------- #
# Experimental constants
# --------------------------------------------------------------------------- #

D_HEADS: int = 4
CTX: int = 2048
PRODUCT_POINT: int = D_HEADS * CTX // 32          # P = 256
RECORDED: tuple[int, int, int] = (256, 224, 160)  # seeds 1, 2, 3
TAIL_BAR: int = 192                               # tau = (3/4) P
PREREG: tuple[int, ...] = (160, 192, 224, 256)


# --------------------------------------------------------------------------- #
# 1.  The counting primitive and the objects built from it
# --------------------------------------------------------------------------- #

def count_le(sample: Sequence[int], w: int) -> int:
    """Number of sample points at or below w."""
    return sum(1 for k in sample if k <= w)


def count_ge(sample: Sequence[int], w: int) -> int:
    """Number of sample points at or above w."""
    return sum(1 for k in sample if w <= k)


def order_statistic(sample: Sequence[int], k: int) -> int:
    """The k-th smallest value (1-indexed), via the counting definition:
    the least v with count_le(sample, v) >= k."""
    if not 1 <= k <= len(sample):
        raise ValueError(f"quota {k} out of range for sample size {len(sample)}")
    return sorted(sample)[k - 1]


def quota_budget(sample: Sequence[int], m: int) -> int:
    """Least budget b with at least m seeds satisfied: the m-th order statistic."""
    return order_statistic(sample, m)


def l1_cost(sample: Sequence[int], t: int) -> int:
    """Total distance from a candidate budget t to the sample."""
    return sum(abs(t - k) for k in sample)


def is_l1_median(sample: Sequence[int], t: int) -> bool:
    """Counting characterisation of the Fermat-Weber set:
    at least half the sample weakly on each side of t."""
    n = len(sample)
    return n <= 2 * count_le(sample, t) and n <= 2 * count_ge(sample, t)


def breakdown_number(n: int, k: int) -> int:
    """Exact finite-sample breakdown number of the k-th order statistic."""
    return min(k, n - k + 1)


def lower_median_breakdown(n: int) -> int:
    """Breakdown number of the lower median of an n-point sample: ceil(n/2)."""
    return (n + 1) // 2


def tail_verdict(sample: Sequence[int], tau: int, m: int) -> bool:
    """At least m seeds at or below the bar tau."""
    return m <= count_le(sample, tau)


def verdict_breakdown(sample: Sequence[int], tau: int, m: int) -> int:
    """Exact number of seeds an adversary must re-run to flip the verdict."""
    c = count_le(sample, tau)
    return c - m + 1 if m <= c else m - c


def four_seed_reading(x: int) -> Fraction:
    """Conventional even-sample central reading: midpoint of the two middle values."""
    s = sorted(list(RECORDED) + [x])
    return Fraction(s[1] + s[2], 2)


def bias(x: int) -> Fraction:
    """Distance of the four-seed central reading from the recorded centre 224."""
    return abs(four_seed_reading(x) - 224)


def speedup(budget: int) -> Fraction:
    """Attention speed-up certified by a truncation budget."""
    return Fraction(CTX, budget)


# --------------------------------------------------------------------------- #
# 2.  Brute-force checks of the robustness theorems
# --------------------------------------------------------------------------- #

def empirical_breakdown(sample: Sequence[int], k: int, far: int = 10 ** 6) -> int:
    """Smallest number of coordinates an adversary must overwrite (with a common
    extreme value) to push the k-th order statistic outside the honest range.
    Verifies breakdown_number(n, k) by exhaustive search over corruption sets."""
    n = len(sample)
    lo, hi = min(sample), max(sample)
    for m in range(0, n + 1):
        for idx in combinations(range(n), m):
            for c in (-far, far):
                corrupted = list(sample)
                for i in idx:
                    corrupted[i] = c
                v = order_statistic(corrupted, k)
                if v < lo or v > hi:
                    return m
    return n + 1


def empirical_verdict_breakdown(sample: Sequence[int], tau: int, m: int) -> int:
    """Smallest number of coordinates an adversary must overwrite to flip the
    tail verdict.  Corruptions to tau (down) or tau+1 (up) are optimal."""
    n = len(sample)
    truth = tail_verdict(sample, tau, m)
    for c in range(0, n + 1):
        for idx in combinations(range(n), c):
            for targets in product((tau, tau + 1), repeat=len(idx)):
                corrupted = list(sample)
                for i, t in zip(idx, targets):
                    corrupted[i] = t
                if tail_verdict(corrupted, tau, m) != truth:
                    return c
    return n + 1


# --------------------------------------------------------------------------- #
# 3.  Report
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool) -> None:
    status = "OK " if condition else "FAIL"
    print(f"  [{status}] {label}")
    assert condition, label


def section_scale() -> None:
    rule("1.  The measured cell and the tail bar")
    print(f"  d = {D_HEADS} heads, ctx = {CTX}, product point P = d*ctx/32 = {PRODUCT_POINT}")
    print(f"  recorded knees: {RECORDED}")
    for k in RECORDED:
        print(f"    {k:4d} = {Fraction(k, PRODUCT_POINT)} P")
    print(f"  tail bar tau = {TAIL_BAR}")
    check("tau is the midpoint of 160 and 224", 2 * TAIL_BAR == 160 + 224)
    check("tau = (3/4) P", 4 * TAIL_BAR == 3 * PRODUCT_POINT)
    check("low tail = (5/8) P", 8 * 160 == 5 * PRODUCT_POINT)
    check("centre  = (7/8) P", 8 * 224 == 7 * PRODUCT_POINT)
    print(f"  all-seeds speed-up at P: {speedup(PRODUCT_POINT)} = {float(speedup(PRODUCT_POINT)):.2f}x")


def section_dichotomy() -> None:
    rule("2.  The tail statistic and the pre-registered dichotomy")
    print("     x     tail count   stable   replicated   reading    bias")
    for x in PREREG:
        e = list(RECORDED) + [x]
        c = count_le(e, TAIL_BAR)
        print(f"  {x:4d}       {c}          "
              f"{str(tail_verdict(e, TAIL_BAR, 2)):5s}    {str(x <= 160):5s}       "
              f"{str(four_seed_reading(x)):7s}  {str(bias(x)):>5s}")
        check(f"threshold form of the tail count at x={x}",
              c == (2 if x <= TAIL_BAR else 1))
        check(f"dichotomy at x={x}",
              tail_verdict(e, TAIL_BAR, 2) == (x in (160, 192)))
    print("  => stable exactly on {160, 192}; seed-specific exactly on {224, 256}")


def section_one_bit() -> None:
    rule("3.  The fourth seed carries exactly one bit")
    verdicts = {x: tail_verdict(list(RECORDED) + [x], TAIL_BAR, 2) for x in PREREG}
    check("verdict constant on {160, 192}", verdicts[160] == verdicts[192])
    check("verdict constant on {224, 256}", verdicts[224] == verdicts[256])
    check("verdict differs across the pairs", verdicts[160] != verdicts[224])
    check("both verdicts attainable (informative)", set(verdicts.values()) == {True, False})
    print("  the run cannot separate 160 from 192, nor 224 from 256:")
    print("  one training cycle returns one bit.")
    print("  finer three-way reading: replicated iff x <= 160; "
          "stable-but-not-replicated iff x = 192.")


def section_centre_invariance() -> None:
    rule("4.  Both centre summaries are constant across the outcomes")
    print("     x    224 is an l1 centre?   cost at 224   median breakdown")
    for x in PREREG:
        e = list(RECORDED) + [x]
        print(f"  {x:4d}          {str(is_l1_median(e, 224)):5s}              "
              f"{l1_cost(e, 224):5d}              {breakdown_number(4, 2)}")
        check(f"224 is an l1 centre of the sample with x={x}", is_l1_median(e, 224))
        check(f"exhaustive cost check at x={x}",
              all(l1_cost(e, 224) <= l1_cost(e, t) for t in range(0, 1025)))
        check(f"median breakdown is 2 at x={x}", empirical_breakdown(e, 2) == 2)
    print("  both summaries are the SAME for x=160 (tail stable) and x=256 (not stable),")
    print("  so no function of either can reproduce the tail verdict:")
    print("  the fourth seed is diagnostic for the tail, not the centre.")


def section_breakdown_theory() -> None:
    rule("5.  Exact breakdown numbers and the parity law")
    print("  bd(n,k) = min(k, n-k+1), verified by exhaustive adversarial search:")
    print("     n   k   formula   brute force")
    for n in (3, 4, 5, 6):
        base = [256, 224, 160, 192, 208, 240][:n]
        for k in range(1, n + 1):
            f, b = breakdown_number(n, k), empirical_breakdown(base, k)
            print(f"    {n}   {k}      {f}           {b}")
            check(f"bd({n},{k})", f == b)
    print()
    print("  lower-median breakdown ceil(n/2) -- the parity plateau:")
    for n in range(1, 10):
        star = "  <-- no gain over n-1" if n % 2 == 0 and n > 1 else ""
        print(f"    n = {n}:  beta(n) = {lower_median_breakdown(n)}{star}")
    for m in range(1, 6):
        check(f"beta({2*m}) = beta({2*m-1})",
              lower_median_breakdown(2 * m) == lower_median_breakdown(2 * m - 1))
        check(f"beta({2*m+1}) > beta({2*m})",
              lower_median_breakdown(2 * m + 1) > lower_median_breakdown(2 * m))
    print("  design law: least n with median robustness r is 2r-1 (always odd):")
    for r in range(1, 6):
        least = min(n for n in range(1, 40) if r <= lower_median_breakdown(n))
        print(f"    r = {r}:  least n = {least}   (2r-1 = {2*r-1})")
        check(f"least n for r={r}", least == 2 * r - 1)


def section_verdict_fragility() -> None:
    rule("6.  Verdict robustness: the measurable bit is the fragile one")
    print("     x    verdict   count   verdict breakdown   centre breakdown")
    for x in PREREG:
        e = list(RECORDED) + [x]
        vb = verdict_breakdown(e, TAIL_BAR, 2)
        print(f"  {x:4d}     {str(tail_verdict(e, TAIL_BAR, 2)):5s}      "
              f"{count_le(e, TAIL_BAR)}            {vb}                   "
              f"{breakdown_number(4, 2)}")
        check(f"verdict breakdown formula at x={x}",
              vb == empirical_verdict_breakdown(e, TAIL_BAR, 2))
        check(f"verdict breakdown is 1 at x={x}", vb == 1)
        check(f"verdict strictly more fragile than centre at x={x}",
              vb < breakdown_number(4, 2))
    print("  one re-run overturns the verdict whichever way it points,")
    print("  while two are needed to move the centre out of the measured range.")


def section_exclusion() -> None:
    rule("7.  Confirmation versus calibration at four seeds")
    print("  bias of the four-seed central reading against the recorded centre 224:")
    for x in (128, 160, 176, 192, 200, 224, 240, 256, 320):
        conf = "confirms tail" if x <= TAIL_BAR else "refutes tail "
        print(f"    x = {x:4d}   reading = {str(four_seed_reading(x)):7s}   "
              f"bias = {str(bias(x)):>5s}   {conf}")
    check("every confirming outcome has bias >= 16 = P/16",
          all(bias(x) >= 16 for x in range(0, TAIL_BAR + 1)))
    check("bias vanishes only at x = 224",
          [x for x in range(0, 1025) if bias(x) == 0] == [224])
    check("no outcome both confirms and calibrates",
          not any(x <= TAIL_BAR and bias(x) == 0 for x in range(0, 1025)))


def section_fifth_seed() -> None:
    rule("8.  The fifth seed reconciles confirmation and calibration")
    e5 = [256, 224, 160, 192, 224]
    e5p = [256, 224, 160, 192, 160]
    print(f"  E5  = {e5}")
    check("two seeds at or below the tail bar", count_le(e5, TAIL_BAR) == 2)
    check("median rung (quota 3 of 5) is exactly 224", quota_budget(e5, 3) == 224)
    check("zero bias against the recorded centre", quota_budget(e5, 3) - 224 == 0)
    check("centre breakdown 3", empirical_breakdown(e5, 3) == 3)
    check("224 is the unique l1 centre of E5",
          [t for t in range(0, 1025) if is_l1_median(e5, t)] == [224])
    check("160 is not an l1 centre of E5", not is_l1_median(e5, 160))
    print(f"  E5' = {e5p}")
    check("verdict breakdown 2", verdict_breakdown(e5p, TAIL_BAR, 2) == 2)
    check("verdict breakdown 2 (brute force)",
          empirical_verdict_breakdown(e5p, TAIL_BAR, 2) == 2)
    check("centre breakdown 3", empirical_breakdown(e5p, 3) == 3)
    print("  no four-seed ensemble attains either combination:")
    check("no four-seed centre breakdown above 2",
          all(breakdown_number(4, k) <= 2 for k in range(1, 5)))
    check("no four-seed verdict breakdown above 1",
          all(verdict_breakdown(list(RECORDED) + [x], TAIL_BAR, 2) == 1
              for x in range(0, 1025)))
    print("  design law for the tail: with the two recorded above-bar knees fixed,")
    print("  a quota-2 verdict robust to one re-run needs m + r - 1 + |S| = 2+2-1+2 = 5 seeds.")


def section_payoff() -> None:
    rule("9.  The physical payoff")
    print("     x    majority budget (quota 2 of 4)   certified majority speed-up")
    for x in PREREG:
        e = list(RECORDED) + [x]
        b = quota_budget(e, 2)
        s = speedup(b)
        print(f"  {x:4d}              {b:4d}                       "
              f"{s} = {float(s):.2f}x")
        if x <= TAIL_BAR:
            check(f"majority budget <= tau at x={x}", b <= TAIL_BAR)
            check(f"majority speed-up >= 32/3 at x={x}", s >= Fraction(32, 3))
    print(f"  all-seeds guarantee from the product point: {speedup(PRODUCT_POINT)} = 8.00x")
    print(f"  majority guarantee if the tail is confirmed: >= {Fraction(32,3)} "
          f"= {float(Fraction(32,3)):.2f}x")
    print("  caveats (both theorems): the quota-4 certified budget has breakdown 1,")
    print("  and the majority verdict itself has verdict breakdown 1 at four seeds.")


def main() -> None:
    print("LOW-TAIL SEED-ENSEMBLE DEMONSTRATION")
    section_scale()
    section_dichotomy()
    section_one_bit()
    section_centre_invariance()
    section_breakdown_theory()
    section_verdict_fragility()
    section_exclusion()
    section_fifth_seed()
    section_payoff()
    rule("All checks passed.")


if __name__ == "__main__":
    main()
