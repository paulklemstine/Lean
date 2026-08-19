"""
Numerical demonstration of the geometry of a knee distribution.

This script is fully self-contained (standard library only, exact rational
arithmetic where it matters) and verifies, numerically, every quantitative
claim of the accompanying article and paper:

  1. Fermat-Weber cost on a line, its minimiser set, and the balance
     characterisation of optimality (any sample size, either parity).
  2. The measured three-value knee distributions at two context lengths, their
     geometric medians, and the 7/8 law  median = (7/8) * (d*ctx/32).
  3. The median of three as a nearest-point projection (clamp): monotonicity,
     nonexpansiveness, firm nonexpansiveness, fibre structure, range;
     the refutation of the informal claim "only values >= 256 move the centre".
  4. Scaling geometry: rays through the origin, the doubling dilation, the
     low-tail defect P/8, and the exact 3/2 spread ratio.
  5. The median level set in R^3: a maximal flat edge, the segment joining the
     two normalised measurements, and non-convexity of the level set.
  6. The pre-registered prediction for a pending fourth measurement: the centre
     224 stays optimal for every fourth value, the cost law 96 + |224 - x|,
     the two regimes, and the uniqueness knife edge.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, List, Sequence, Tuple

Num = Fraction


# ---------------------------------------------------------------------------
# 1. Fermat-Weber cost, minimiser set, and the balance certificate
# ---------------------------------------------------------------------------


def fw_cost(sample: Sequence[Num], t: Num) -> Num:
    """Total distance from the candidate centre `t` to every sample point."""
    return sum((abs(t - x) for x in sample), Fraction(0))


def is_balanced(sample: Sequence[Num], m: Num) -> bool:
    """`m` is balanced: neither open side of `m` holds more than half the sample."""
    n_le = sum(1 for x in sample if x <= m)
    n_lt = sum(1 for x in sample if x < m)
    n = len(sample)
    return (n - n_le) <= n_le and n_lt <= (n - n_lt)


def fermat_weber_set(sample: Sequence[Num]) -> Tuple[Num, Num]:
    """Endpoints of the interval of minimisers of the total distance.

    Odd size 2k+1: the singleton [x_(k+1), x_(k+1)].
    Even size 2k : the middle segment [x_(k), x_(k+1)].
    """
    xs = sorted(sample)
    n = len(xs)
    if n % 2 == 1:
        mid = xs[n // 2]
        return (mid, mid)
    return (xs[n // 2 - 1], xs[n // 2])


def fw_optimal_cost(sample: Sequence[Num]) -> Num:
    """Sum of nested spreads: the optimal total distance."""
    xs = sorted(sample)
    n = len(xs)
    return sum((xs[n - 1 - i] - xs[i] for i in range(n // 2)), Fraction(0))


def brute_force_min(sample: Sequence[Num], grid: Iterable[Num]) -> Num:
    """Smallest cost attained on an explicit grid of candidate centres."""
    return min(fw_cost(sample, t) for t in grid)


# ---------------------------------------------------------------------------
# 2. Median of three, and the clamp (nearest-point projection)
# ---------------------------------------------------------------------------


def med3(a: Num, b: Num, c: Num) -> Num:
    """Median of three, in the (max, min) lattice-polynomial form."""
    return max(min(a, b), min(b, c), min(a, c))


def clamp(a: Num, b: Num, x: Num) -> Num:
    """Projection of `x` onto the segment spanned by `a` and `b`."""
    return max(min(a, b), min(max(a, b), x))


def mean3(a: Num, b: Num, x: Num) -> Fraction:
    return Fraction(a + b + x, 1) / 3


# ---------------------------------------------------------------------------
# 3. Plane geometry: rays and dilations
# ---------------------------------------------------------------------------


def cross(p: Tuple[Num, Num], q: Tuple[Num, Num]) -> Num:
    """Twice the signed area of the triangle O, p, q."""
    return p[0] * q[1] - p[1] * q[0]


def on_common_ray(p: Tuple[Num, Num], q: Tuple[Num, Num]) -> bool:
    return cross(p, q) == 0


def triangle_area(p: Tuple[Num, Num], q: Tuple[Num, Num]) -> Fraction:
    return abs(Fraction(cross(p, q))) / 2


# ---------------------------------------------------------------------------
# The measured data
# ---------------------------------------------------------------------------

F = Fraction

KNEES_8X: List[Num] = [F(96), F(112), F(128)]     # ctx = 1024
KNEES_16X: List[Num] = [F(160), F(224), F(256)]   # ctx = 2048
P8, P16 = F(128), F(256)                          # product points d*ctx/32, d = 4

R8 = (F(3, 4), F(7, 8), F(1))                     # normalised 8x triple
R16 = (F(5, 8), F(7, 8), F(1))                    # normalised 16x triple


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, ok: bool, detail: str = "") -> None:
    mark = "OK  " if ok else "FAIL"
    print(f"  [{mark}] {label}" + (f"   {detail}" if detail else ""))
    assert ok, label


# ---------------------------------------------------------------------------
# Demonstration 1: the 7/8 median law as a variational statement
# ---------------------------------------------------------------------------


def demo_median_law() -> None:
    rule("1. The 7/8 median law: the centre minimises total distance")

    for name, knees, P in (("8x  (ctx=1024)", KNEES_8X, P8),
                           ("16x (ctx=2048)", KNEES_16X, P16)):
        lo, hi = fermat_weber_set(knees)
        cost = fw_optimal_cost(knees)
        print(f"\n  {name}: knees {[int(k) for k in knees]}, product point P = {int(P)}")
        print(f"    Fermat-Weber set   : [{lo}, {hi}]  (a single point: odd sample)")
        print(f"    optimal cost       : {cost}  (= the spread)")
        print(f"    ratios k*/P        : {[str(k / P) for k in knees]}")
        check("median equals (7/8) * P", lo == F(7, 8) * P, f"{lo} = 7/8 * {int(P)}")
        check("cost at the centre matches the optimum", fw_cost(knees, lo) == cost)
        check("the centre is balanced", is_balanced(knees, lo))

        # strict minimality on a fine grid around the sample
        grid = [F(i, 2) for i in range(int(2 * (min(knees) - 40)), int(2 * (max(knees) + 40)))]
        worse = [t for t in grid if t != lo and fw_cost(knees, t) <= cost]
        check("no other grid point attains the optimum", not worse)
        check("grid minimum equals the theoretical optimum",
              brute_force_min(knees, grid) == cost)


# ---------------------------------------------------------------------------
# Demonstration 2: the balance characterisation, all parities
# ---------------------------------------------------------------------------


def demo_balance_characterisation() -> None:
    rule("2. Balanced points are exactly the minimisers (any size, any parity)")

    samples: List[List[Num]] = [
        [F(160), F(224), F(256)],
        [F(160), F(224), F(256), F(192)],
        [F(160), F(224), F(256), F(240)],
        [F(5), F(5), F(5), F(9), F(100)],
        [F(0), F(1)],
        [F(7)],
    ]
    for s in samples:
        lo, hi = fermat_weber_set(s)
        grid = [F(i, 2) for i in range(int(2 * (min(s) - 20)), int(2 * (max(s) + 20)) + 1)]
        best = brute_force_min(s, grid)
        minimisers = [t for t in grid if fw_cost(s, t) == best]
        balanced = [t for t in grid if is_balanced(s, t)]
        print(f"\n  sample {[str(x) for x in s]}")
        print(f"    predicted optimal interval : [{lo}, {hi}]")
        print(f"    grid minimisers            : [{min(minimisers)}, {max(minimisers)}]")
        check("minimiser set equals the balanced set", minimisers == balanced)
        check("endpoints match the order-statistic formula",
              (min(minimisers), max(minimisers)) == (lo, hi))
        check("optimal cost equals the nested-spread formula", best == fw_optimal_cost(s))
        # convexity of the minimiser set on the grid
        check("minimiser set is an interval",
              all(fw_cost(s, t) == best for t in grid if lo <= t <= hi))


# ---------------------------------------------------------------------------
# Demonstration 3: the median as a projection, and its robustness
# ---------------------------------------------------------------------------


def demo_projection() -> None:
    rule("3. The median of three is a nearest-point projection onto a segment")

    a, b = F(224), F(256)   # the two earlier 16x measurements
    print(f"  fixed measurements span the segment [{a}, {b}]")

    xs = [F(i, 2) for i in range(2 * 100, 2 * 400)]
    check("median of three equals the clamp",
          all(med3(a, b, x) == clamp(a, b, x) for x in xs))
    check("the projection lands in the segment",
          all(a <= clamp(a, b, x) <= b for x in xs))
    check("monotone", all(clamp(a, b, xs[i]) <= clamp(a, b, xs[i + 1])
                          for i in range(len(xs) - 1)))
    check("nonexpansive",
          all(abs(clamp(a, b, x) - clamp(a, b, y)) <= abs(x - y)
              for x in xs[::37] for y in xs[::41]))
    check("firmly nonexpansive",
          all((clamp(a, b, x) - clamp(a, b, y)) ** 2
              <= (x - y) * (clamp(a, b, x) - clamp(a, b, y))
              for x in xs[::37] for y in xs[::41]))

    # fibre structure
    stable = [x for x in xs if med3(b, a, x) == F(224)]
    print(f"    values leaving the centre at 224: from {min(stable)} up to {max(stable)}")
    check("the stability fibre is exactly the ray x <= 224",
          all((med3(b, a, x) == F(224)) == (x <= F(224)) for x in xs))
    check("interior fibres are singletons",
          [x for x in xs if clamp(a, b, x) == F(240)] == [F(240)])

    # the measured third value, and the false informal claim
    check("the measured value 160 keeps the centre", med3(b, a, F(160)) == F(224))
    check("its excursion below the segment is 64",
          abs(clamp(a, b, F(160)) - F(160)) == F(64))
    check("every segment point is at least 64 away from 160",
          all(abs(y - F(160)) >= 64 for y in [F(i, 4) for i in range(4 * 224, 4 * 256 + 1)]))
    check("informal claim 'only >= 256 moves the centre' is FALSE",
          med3(b, a, F(240)) == F(240) and F(240) < F(256))

    # contrast with the mean
    m = mean3(b, a, F(160))
    print(f"    mean of the measured triple: {m} = {float(m):.4f}  (not 224)")
    check("the mean is moved off the centre", m != F(224))
    check("the mean is surjective in the free value",
          mean3(b, a, 3 * F(1000) - b - a) == F(1000))
    check("the median's range is the compact segment",
          {med3(a, b, x) for x in xs} == {clamp(a, b, x) for x in xs}
          and min(med3(a, b, x) for x in xs) == a
          and max(med3(a, b, x) for x in xs) == b)


# ---------------------------------------------------------------------------
# Demonstration 4: scaling geometry
# ---------------------------------------------------------------------------


def demo_scaling() -> None:
    rule("4. Scaling geometry: two rays, one defect, an exact 3/2 spread ratio")

    top8, top16 = (F(1024), F(128)), (F(2048), F(256))
    med8, med16 = (F(1024), F(112)), (F(2048), F(224))
    low8, low16 = (F(1024), F(96)), (F(2048), F(160))

    check("top edge lies on a ray through the origin", on_common_ray(top8, top16),
          f"slope {top8[1] / top8[0]}")
    check("median lies on a ray through the origin", on_common_ray(med8, med16),
          f"slope {med8[1] / med8[0]} = 7/8 * 1/8")
    check("median slope is 7/8 of the top slope",
          med8[1] / med8[0] == F(7, 8) * (top8[1] / top8[0]))
    check("the slope is forced by one context and confirmed by the other",
          med8[1] / med8[0] == F(7, 64) and F(7, 64) * med16[0] == med16[1])

    check("low tail lies on NO ray", not on_common_ray(low8, low16),
          f"determinant {cross(low8, low16)}, origin triangle area {triangle_area(low8, low16)}")

    check("doubling is equivariant on the top edge", (2 * top8[0], 2 * top8[1]) == top16)
    check("doubling is equivariant on the median", (2 * med8[0], 2 * med8[1]) == med16)
    defect = 2 * low8[1] - low16[1]
    check("low-tail defect equals P/8", defect == F(32) and defect == P16 / 8,
          f"2*96 - 160 = {defect} = {int(P16)}/8")

    factors = {"top": top16[1] / top8[1], "low": low16[1] / low8[1]}
    print(f"    dilation factor forced by the top edge : {factors['top']}")
    print(f"    dilation factor forced by the low tail : {factors['low']}")
    check("no single dilation matches the whole configuration",
          factors["top"] != factors["low"])

    cost8 = fw_optimal_cost(list(R8))
    cost16 = fw_optimal_cost(list(R16))
    print(f"    normalised optimal costs: {cost8} (8x) and {cost16} (16x)")
    check("the 16x spread is exactly 3/2 times the 8x spread",
          cost16 == F(3, 2) * cost8)
    check("the widening is carried entirely by the low coordinate",
          cost16 - cost8 == R8[0] - R16[0] == F(1, 8))
    check("top two normalised coordinates agree at both contexts",
          R8[1:] == R16[1:])


# ---------------------------------------------------------------------------
# Demonstration 5: the median level set in R^3
# ---------------------------------------------------------------------------


def demo_level_set() -> None:
    rule("5. A maximal flat face inside a non-convex level set")

    check("both normalised triples have median 7/8",
          med3(*R8) == F(7, 8) and med3(*R16) == F(7, 8))

    edge = [F(i, 32) for i in range(-32, int(32 * F(7, 8)) + 1)]
    check("the whole half-line {(t, 7/8, 1) : t <= 7/8} lies in the level set",
          all(med3(t, F(7, 8), F(1)) == F(7, 8) for t in edge))
    exits = [F(7, 8) + F(i, 64) for i in range(1, 9)]
    check("the edge is maximal: above 7/8 the median moves with t",
          all(med3(t, F(7, 8), F(1)) == t for t in exits))

    for i in range(-8, 17):
        s = F(i, 8)
        pt = tuple(s * u + (1 - s) * v for u, v in zip(R8, R16))
        if s <= 1:
            assert med3(*pt) == F(7, 8)
    check("the segment joining the two contexts stays in the level set "
          "(and extends past it, for all s <= 1)", True)

    u, v = (F(5, 8), F(7, 8), F(1)), (F(7, 8), F(1), F(5, 8))
    mid = tuple((p + q) / 2 for p, q in zip(u, v))
    print(f"    midpoint of two level-set points: {tuple(str(c) for c in mid)}"
          f" has median {med3(*mid)}")
    check("the level set is NOT convex",
          med3(*u) == F(7, 8) and med3(*v) == F(7, 8) and med3(*mid) == F(13, 16))


# ---------------------------------------------------------------------------
# Demonstration 6: the pending fourth measurement
# ---------------------------------------------------------------------------


def cost16_four(x: Num, t: Num) -> Num:
    return abs(t - 160) + abs(t - 224) + abs(t - 256) + abs(t - x)


def demo_fourth_value() -> None:
    rule("6. The pending fourth measurement: the centre cannot be moved")

    candidates = [F(c) for c in (96, 128, 160, 176, 192, 208, 224, 240, 256, 288, 384)]
    grid = [F(i, 2) for i in range(2 * 50, 2 * 500)]

    print("\n     x    optimal cost    predicted 96+|224-x|    optimal segment")
    for x in candidates:
        best = min(cost16_four(x, t) for t in grid)
        predicted = 96 + abs(224 - x)
        minimisers = [t for t in grid if cost16_four(x, t) == best]
        lo, hi = fermat_weber_set([F(160), F(224), F(256), x])
        print(f"   {int(x):>4}    {str(best):>10}      {str(predicted):>14}"
              f"            [{lo}, {hi}]")
        check(f"224 is optimal for x = {int(x)}",
              all(cost16_four(x, 224) <= cost16_four(x, t) for t in grid))
        check(f"cost law holds for x = {int(x)}", cost16_four(x, F(224)) == predicted)
        check(f"grid optimum matches the law for x = {int(x)}", best == predicted)
        check(f"optimal segment endpoints for x = {int(x)}",
              (min(minimisers), max(minimisers)) == (lo, hi))
        check(f"224 is balanced for x = {int(x)}",
              is_balanced([F(160), F(224), F(256), x], F(224)))
        if F(160) <= x <= F(224):
            check("low regime: the optimal set is [x, 224]", (lo, hi) == (x, F(224)))
        if F(224) <= x <= F(256):
            check("high regime: the optimal set is [224, x]", (lo, hi) == (F(224), x))
        check("uniqueness holds exactly at the knife edge x = 224",
              (lo == hi) == (x == F(224)))


def main() -> None:
    print(__doc__)
    demo_median_law()
    demo_balance_characterisation()
    demo_projection()
    demo_scaling()
    demo_level_set()
    demo_fourth_value()
    rule("All checks passed.")


if __name__ == "__main__":
    main()
