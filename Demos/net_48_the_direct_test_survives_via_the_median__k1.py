"""
Tropical order statistics of seed distributions -- numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type-hinted.

The demonstrations verify, on the measured two-context / six-seed knee dataset and on
synthetic curves:

  1. The max-of-mins normal form of the median, for 3 and for 2k+1 samples.
  2. Threshold duality: thresholding a median is a majority vote.
  3. Median-knee commutation: the knee of the pointwise median curve equals the
     median of the individual knees (and the same fails for the arithmetic mean).
  4. Robustness: 1-Lipschitzness, the majority breakdown interval, the exact
     stability ray, and the mean's breakdown point of zero.
  5. The measured NET-48 data: the derived knee k* = 160, the horn analysis, the
     7/8 median law at two contexts, its uniqueness, its failure for the mean, the
     order-reversal reading of speed-ups, and the pinned-ceiling / sinking-floor
     geometry.
  6. The axiomatic characterisation of the median and the independence of the
     tropical (translation-equivariance) axiom, checked on a random grid of inputs.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Number = Fraction

# ---------------------------------------------------------------------------
# 1. The median as a tropical (max-of-mins) polynomial
# ---------------------------------------------------------------------------


def trop_median(sample: Sequence[Number]) -> Number:
    """Max-of-mins tropical polynomial: max over all (k+1)-subsets of the min there.

    For a sample of odd size 2k+1 this equals the median.  Complexity O(C(2k+1,k+1)*k),
    i.e. exponential in k -- it is a normal form, not an algorithm; `sorted_median`
    below is the O(n log n) route and the two are asserted equal.
    """
    n: int = len(sample)
    if n % 2 == 0:
        raise ValueError("tropical median normal form requires an odd sample size")
    k: int = (n - 1) // 2
    return max(min(subset) for subset in combinations(sample, k + 1))


def trop_med3(a: Number, b: Number, c: Number) -> Number:
    """The classical three-argument normal form (a AND b) OR (b AND c) OR (a AND c)."""
    return max(min(a, b), min(b, c), min(a, c))


def trop_med3_dual(a: Number, b: Number, c: Number) -> Number:
    """The dual min-of-maxes normal form; equal to `trop_med3` by self-duality."""
    return min(max(a, b), max(b, c), max(a, c))


def sorted_median(sample: Sequence[Number]) -> Number:
    """The middle order statistic of an odd sample."""
    ordered: List[Number] = sorted(sample)
    return ordered[len(ordered) // 2]


def majority_at_least(sample: Sequence[Number], v: Number) -> bool:
    """True iff at least k+1 of the 2k+1 entries are >= v."""
    k: int = (len(sample) - 1) // 2
    return sum(1 for x in sample if x >= v) >= k + 1


def majority_at_most(sample: Sequence[Number], v: Number) -> bool:
    """True iff at least k+1 of the 2k+1 entries are <= v."""
    k: int = (len(sample) - 1) // 2
    return sum(1 for x in sample if x <= v) >= k + 1


# ---------------------------------------------------------------------------
# 2. Retention curves, knees, aggregation pipelines
# ---------------------------------------------------------------------------


def step_curve(switch_on: int) -> Callable[[int], Number]:
    """The monotone unit step curve that jumps from 0 to 1 at `switch_on`."""

    def curve(t: int) -> Number:
        return Fraction(1) if t >= switch_on else Fraction(0)

    return curve


def knee(curve: Callable[[int], Number], grid: Sequence[int], bar: Number) -> Optional[int]:
    """The least grid point at which `curve` clears `bar` (None if it never does)."""
    for g in sorted(grid):
        if curve(g) >= bar:
            return g
    return None


def median_curve(curves: Sequence[Callable[[int], Number]]) -> Callable[[int], Number]:
    """The pointwise median of an odd family of curves."""

    def aggregate(t: int) -> Number:
        return trop_median([c(t) for c in curves])

    return aggregate


def mean_curve(curves: Sequence[Callable[[int], Number]]) -> Callable[[int], Number]:
    """The pointwise arithmetic mean of a family of curves."""

    def aggregate(t: int) -> Number:
        return sum((c(t) for c in curves), Fraction(0)) / len(curves)

    return aggregate


# ---------------------------------------------------------------------------
# 3. The measured NET-48 dataset
# ---------------------------------------------------------------------------

GRID_48: List[int] = [96, 128, 160, 192, 224, 240, 256, 288, 384, 512, 768, 1024]

SWEEP_48: Dict[int, Number] = {
    96: Fraction(963, 1000),
    128: Fraction(973, 1000),
    160: Fraction(981, 1000),
    192: Fraction(984, 1000),
    224: Fraction(986, 1000),
    240: Fraction(987, 1000),
    256: Fraction(990, 1000),
    288: Fraction(993, 1000),
    384: Fraction(999, 1000),
    512: Fraction(1000, 1000),
    768: Fraction(1003, 1000),
    1024: Fraction(1003, 1000),
}

BAR_48: Number = Fraction(98, 100)
HORNS: List[int] = [192, 224, 240, 256]

KNEES_8: List[Number] = [Fraction(128), Fraction(112), Fraction(96)]
KNEES_16: List[Number] = [Fraction(256), Fraction(224), Fraction(160)]
P8: Number = Fraction(128)
P16: Number = Fraction(256)


def sweep_curve(t: int) -> Number:
    """The measured retention curve, extended to all budgets by last-value-hold."""
    value: Number = Fraction(0)
    for g in GRID_48:
        if t >= g:
            value = SWEEP_48[g]
    return value


def product_point(width: int, context: int) -> Fraction:
    """P = d * ctx / 32."""
    return Fraction(width * context, 32)


# ---------------------------------------------------------------------------
# 4. Aggregator axioms (for the characterisation demo)
# ---------------------------------------------------------------------------


def sum_sign_agg(a: Number, b: Number, c: Number) -> Number:
    """Max if the inputs sum positive, min if negative, median on the zero-sum wall."""
    s: Number = a + b + c
    if s > 0:
        return max(a, b, c)
    if s < 0:
        return min(a, b, c)
    return trop_med3(a, b, c)


def check_axioms(
    agg: Callable[[Number, Number, Number], Number], values: Sequence[Number]
) -> Dict[str, bool]:
    """Exhaustively check the five aggregator axioms on a finite grid of inputs."""
    triples: List[Tuple[Number, Number, Number]] = list(product(values, repeat=3))
    monotone: bool = True
    for (a, b, c), (x, y, z) in product(triples, repeat=2):
        if a <= x and b <= y and c <= z and agg(a, b, c) > agg(x, y, z):
            monotone = False
            break
    symmetric: bool = all(
        agg(a, b, c) == agg(b, a, c) and agg(a, b, c) == agg(a, c, b) for a, b, c in triples
    )
    conservative: bool = all(agg(a, b, c) in (a, b, c) for a, b, c in triples)
    translation: bool = all(
        agg(a + t, b + t, c + t) == agg(a, b, c) + t for a, b, c in triples for t in values
    )
    self_dual: bool = all(agg(-a, -b, -c) == -agg(a, b, c) for a, b, c in triples)
    return {
        "monotone": monotone,
        "symmetric": symmetric,
        "conservative": conservative,
        "translation-equivariant": translation,
        "self-dual": self_dual,
    }


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_normal_form() -> None:
    banner("1. The median is a max-of-mins tropical polynomial")
    triple: Tuple[Number, Number, Number] = (Fraction(256), Fraction(224), Fraction(160))
    print(f"  sample                        : {[int(x) for x in triple]}")
    print(f"  max-of-mins  (a^b)v(b^c)v(a^c): {int(trop_med3(*triple))}")
    print(f"  min-of-maxes (avb)^(bvc)^(avc): {int(trop_med3_dual(*triple))}")
    print(f"  sorted middle order statistic : {int(sorted_median(list(triple)))}")
    assert trop_med3(*triple) == trop_med3_dual(*triple) == sorted_median(list(triple))

    five: List[Number] = [Fraction(v) for v in (17, 3, 11, 29, 5)]
    print(f"\n  five-sample                   : {[int(x) for x in five]}")
    print(f"  max over 3-subsets of the min : {int(trop_median(five))}")
    print(f"  sorted middle order statistic : {int(sorted_median(five))}")
    assert trop_median(five) == sorted_median(five)
    print("\n  Normal form verified for k = 1 and k = 2.")


def demo_threshold_duality() -> None:
    banner("2. Threshold duality: thresholding a median is a majority vote")
    sample: List[Number] = [Fraction(v) for v in (160, 224, 256)]
    m: Number = trop_median(sample)
    print(f"  sample {[int(x) for x in sample]}, median {int(m)}\n")
    print("     v      v <= med   majority(>= v)    med <= v   majority(<= v)")
    for v_int in (150, 160, 200, 224, 240, 256, 300):
        v: Number = Fraction(v_int)
        lo: bool = v <= m
        lo_maj: bool = majority_at_least(sample, v)
        hi: bool = m <= v
        hi_maj: bool = majority_at_most(sample, v)
        assert lo == lo_maj and hi == hi_maj
        print(f"  {v_int:5d}   {str(lo):>8}   {str(lo_maj):>13}    {str(hi):>8}   {str(hi_maj):>13}")
    print("\n  Both columns agree at every threshold: duality verified.")


def demo_commutation() -> None:
    banner("3. Median-knee commutation (and its failure for the mean)")
    grid: List[int] = [1, 2, 3]
    bar: Number = Fraction(1)
    curves: List[Callable[[int], Number]] = [step_curve(1), step_curve(2), step_curve(3)]
    knees: List[Number] = [Fraction(knee(c, grid, bar) or 0) for c in curves]
    print(f"  three monotone step curves with knees {[int(k) for k in knees]}")
    print(f"  median of the knees                 : {int(trop_median(knees))}")
    print(f"  knee of the MEDIAN curve            : {knee(median_curve(curves), grid, bar)}")
    print(f"  knee of the MEAN curve              : {knee(mean_curve(curves), grid, bar)}")
    assert knee(median_curve(curves), grid, bar) == int(trop_median(knees)) == 2
    assert knee(mean_curve(curves), grid, bar) == 3
    print("  -> the median commutes (2 = 2); the mean does not (3 != 2).")

    print("\n  The measured NET-48 triple {256, 224, 160}:")
    grid16: List[int] = [160, 224, 256]
    curves16: List[Callable[[int], Number]] = [step_curve(256), step_curve(224), step_curve(160)]
    print(f"    knee of the median curve          : {knee(median_curve(curves16), grid16, bar)}")
    assert knee(median_curve(curves16), grid16, bar) == 224
    print("    -> the reported centre 224 is itself an operating point.")

    print("\n  Five seeds (k = 2), knees 5, 9, 12, 20, 31 on their own grid:")
    ks: List[int] = [5, 9, 12, 20, 31]
    curves5: List[Callable[[int], Number]] = [step_curve(k) for k in ks]
    got: Optional[int] = knee(median_curve(curves5), ks, bar)
    print(f"    median of the knees               : {int(trop_median([Fraction(k) for k in ks]))}")
    print(f"    knee of the median curve          : {got}")
    assert got == 12

    print("\n  Monotonicity is necessary.  Take c0 = 1 except c0(2) = 0 (knee 1),")
    print("  together with the step curves at 2 and 3:")

    def dip(t: int) -> Number:
        return Fraction(0) if t == 2 else Fraction(1)

    bad: List[Callable[[int], Number]] = [dip, step_curve(2), step_curve(3)]
    print(f"    knees                             : {[knee(c, grid, bar) for c in bad]}")
    print(f"    median of the knees               : 2")
    print(f"    knee of the median curve          : {knee(median_curve(bad), grid, bar)}")
    assert knee(median_curve(bad), grid, bar) == 3
    print("    -> commutation fails without monotonicity.")


def demo_robustness() -> None:
    banner("4. Robustness: Lipschitz, breakdown, and the exact stability ray")
    a, b, c = Fraction(256), Fraction(224), Fraction(160)
    perturbed = (a + Fraction(3), b - Fraction(2), c + Fraction(3))
    move: Number = abs(trop_med3(a, b, c) - trop_med3(*perturbed))
    bound: Number = max(Fraction(3), Fraction(2), Fraction(3))
    print(f"  median before {int(trop_med3(a, b, c))}, after {int(trop_med3(*perturbed))}")
    print(f"  moved by {move} <= sup-norm perturbation {bound}: 1-Lipschitz confirmed.")
    assert move <= bound

    print("\n  Breakdown: seeds 1 and 2 pinned at 256 and 224, third seed arbitrary.")
    print("     t        median(256, 224, t)     inside [224, 256]?")
    for t_int in (-10 ** 6, 0, 100, 160, 224, 240, 300, 10 ** 6):
        t: Number = Fraction(t_int)
        m: Number = trop_med3(a, b, t)
        inside: bool = Fraction(224) <= m <= Fraction(256)
        assert inside
        print(f"  {t_int:>9}   {str(int(m)):>18}     {inside}")
    print("  -> no single corrupted seed can move the centre out of [224, 256].")

    print("\n  Exact stability ray: median(x, 224, 256) == 224 iff x <= 224.")
    for x_int in (160, 192, 224, 225, 240, 256):
        x: Number = Fraction(x_int)
        stays: bool = trop_med3(x, Fraction(224), Fraction(256)) == Fraction(224)
        assert stays == (x <= Fraction(224))
        print(f"    x = {x_int:4d} -> centre {int(trop_med3(x, Fraction(224), Fraction(256))):4d}"
              f"   (stays: {stays})")
    print("  -> the informal claim 'only x >= 256 moves the centre' is FALSE: 240 moves it.")

    print("\n  Mean pipeline breakdown point is zero:")
    for n in (10, 1000, 10 ** 6):
        curves: List[Callable[[int], Number]] = [step_curve(1), step_curve(1), step_curve(n)]
        g: List[int] = [1, n]
        print(f"    clean knees (1, 1), corrupted knee {n:>8}"
              f" -> mean-curve knee {knee(mean_curve(curves), g, Fraction(1))}"
              f", median-curve knee {knee(median_curve(curves), g, Fraction(1))}")
        assert knee(mean_curve(curves), g, Fraction(1)) == n
        assert knee(median_curve(curves), g, Fraction(1)) == 1


def demo_measured_sweep() -> None:
    banner("5. The measured sweep: derived knee, and the horn analysis")
    print("     k      retention   clears bar 0.98?")
    for g in GRID_48:
        print(f"  {g:5d}     {float(SWEEP_48[g]):.3f}        {SWEEP_48[g] >= BAR_48}")
    k_star: Optional[int] = knee(sweep_curve, GRID_48, BAR_48)
    print(f"\n  derived knee k* = {k_star}")
    print(f"  margin          = {float(SWEEP_48[160] - BAR_48):.4f}  (razor-thin)")
    assert k_star == 160

    print("\n  Pre-registered point predictions (horns):")
    for h in HORNS:
        passes: bool = SWEEP_48[h] >= BAR_48
        is_knee: bool = h == k_star
        assert passes and not is_knee
        print(f"    k = {h:4d}   clears the bar: {passes}    is the knee: {is_knee}")
    print("  -> all four are sound (sufficient) and all four are wrong (non-minimal).")


def demo_seven_eighths_law() -> None:
    banner("6. The 7/8 median law at two contexts")
    rows: List[Tuple[int, List[Number], Number]] = [
        (1024, KNEES_8, P8),
        (2048, KNEES_16, P16),
    ]
    print("   ctx     knees               P    median   median/P    mean/P")
    for ctx, ks, p in rows:
        assert p == product_point(4, ctx)
        med: Number = trop_median(ks)
        mean: Number = sum(ks, Fraction(0)) / 3
        print(f"  {ctx:5d}   {[int(x) for x in sorted(ks)]}   {int(p):5d}"
              f"    {int(med):5d}     {med / p}       {mean / p}")
        assert med == Fraction(7, 8) * p

    print("\n  Uniqueness of the constant: a*128 = 112 and a*256 = 224 force a = 7/8.")
    a_from_8: Number = Fraction(112) / P8
    a_from_16: Number = Fraction(224) / P16
    assert a_from_8 == a_from_16 == Fraction(7, 8)
    print(f"    from ctx=1024: a = {a_from_8};  from ctx=2048: a = {a_from_16}")

    print("\n  The mean admits NO two-context constant:")
    mean8: Number = sum(KNEES_8, Fraction(0)) / 3
    mean16: Number = sum(KNEES_16, Fraction(0)) / 3
    print(f"    mean/P at ctx=1024 = {mean8 / P8}   (= 7/8 by coincidence)")
    print(f"    mean/P at ctx=2048 = {mean16 / P16}   (= 5/6, not 7/8)")
    assert mean8 / P8 != mean16 / P16

    print("\n  Geometry of the normalised distributions (min, median, max):")
    for ctx, ks, p in rows:
        prof: List[str] = [str(r) for r in sorted(k / p for k in ks)]
        print(f"    ctx={ctx:5d}:  ({', '.join(prof)})")
    spread8: Number = (max(KNEES_8) - min(KNEES_8)) / P8
    spread16: Number = (max(KNEES_16) - min(KNEES_16)) / P16
    print(f"\n    normalised spread: {spread8} -> {spread16}, a factor of {spread16 / spread8}")
    assert spread16 / spread8 == Fraction(3, 2)
    print("    ceiling pinned at 1, median stationary at 7/8, floor sinking 3/4 -> 5/8.")


def demo_speedups() -> None:
    banner("7. Order reversal: speed-ups, medians and guarantees")
    ctx: int = 2048
    speedups: List[Number] = [Fraction(ctx) / k for k in KNEES_16]
    print(f"  knees      {[int(k) for k in sorted(KNEES_16)]}")
    print(f"  speed-ups  {[str(s) for s in sorted(speedups)]}"
          f"  ~ {[round(float(s), 2) for s in sorted(speedups)]}")
    med_speedup: Number = trop_median(speedups)
    print(f"\n  median speed-up            : {med_speedup} ~ {float(med_speedup):.3f}")
    print(f"  speed-up of the median knee: {Fraction(ctx) / trop_median(KNEES_16)}")
    assert med_speedup == Fraction(ctx) / trop_median(KNEES_16)
    print("  -> antitone equivariance: the median of the speed-ups is the speed-up of the median.")

    print(f"\n  guaranteed (worst) speed-up: {min(speedups)}"
          f"  -- image of the LARGEST knee {int(max(KNEES_16))}")
    print(f"  best speed-up              : {max(speedups)}"
          f"  -- image of the SMALLEST knee {int(min(KNEES_16))}")
    assert min(speedups) == Fraction(ctx) / max(KNEES_16)
    print("  -> order reversal exchanges the extremes but fixes the median.")

    print("\n  Product-law bound k* <= P and the resulting guarantee:")
    for k in sorted(KNEES_16):
        assert k <= P16
        print(f"    k* = {int(k):4d} <= P = {int(P16)}   =>  speed-up {float(Fraction(ctx)/k):.2f}x >= 8x")


def demo_axioms() -> None:
    banner("8. The axiomatic characterisation, and independence of the tropical axiom")
    grid: List[Number] = [Fraction(v) for v in (-2, -1, 0, 1, 2)]
    for name, agg in (("median (max-of-mins)", trop_med3), ("sum-sign aggregator", sum_sign_agg)):
        flags: Dict[str, bool] = check_axioms(agg, grid)
        print(f"\n  {name}:")
        for axiom, holds in flags.items():
            print(f"    {axiom:26s}: {holds}")
    print("\n  The sum-sign aggregator satisfies four of the five axioms but not translation")
    print("  equivariance, and it differs from the median:")
    print(f"    sum-sign(0, 0, 1) = {int(sum_sign_agg(Fraction(0), Fraction(0), Fraction(1)))},"
          f"   median(0, 0, 1) = {int(trop_med3(Fraction(0), Fraction(0), Fraction(1)))}")
    assert sum_sign_agg(Fraction(0), Fraction(0), Fraction(1)) != trop_med3(
        Fraction(0), Fraction(0), Fraction(1)
    )
    print("  -> the tropical axiom is exactly what pins the median down.")


def main() -> None:
    demo_normal_form()
    demo_threshold_duality()
    demo_commutation()
    demo_robustness()
    demo_measured_sweep()
    demo_seven_eighths_law()
    demo_speedups()
    demo_axioms()
    print("\n" + "=" * 78)
    print("All demonstrations completed; every assertion held.")
    print("=" * 78)


if __name__ == "__main__":
    main()
