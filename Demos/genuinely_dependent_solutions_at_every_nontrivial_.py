"""
Genuinely dependent fibre families of one-variable tropical polynomials
=======================================================================

Numerical demonstrations, in exact rational arithmetic, of the results on the
fibre family of a min-plus (tropical) polynomial

        p(x) = min_{0 <= i <= n} ( c_i + i * x ).

The *fibre* at x is the set of exponents attaining the minimum,

        F(x) = { i <= n : c_i + i*x = p(x) },

and |F(x)| is the local multiplicity at x.  The demonstrations below verify:

  1. the monotone ordering law  (x < y  =>  max F(y) <= min F(x));
  2. corner existence at x* = max_{1<=i<=n} (c_0 - c_i)/i, with F(x*+1) = {0},
     hence genuine dependence of the family, for random coefficient vectors;
  3. realisation of every admissible multiplicity 2 <= k <= n+1 by step
     polynomials;
  4. the generic ("ramp") polynomial with exactly n simple corners, saturating
     both the degree bound and the corner-count bound;
  5. the convex multiplicity formula  |F(-v)| = #{ l < n : d_l = v } + 1  and
     the equality form of the degree bound;
  6. realisation of every composition of n as a multiplicity profile;
  7. the non-convex example c = (0, 5, 1, 7) whose total multiplicity excess is
     2 < 3 = n, and the identification of the defect with the lattice points of
     the lower hull that carry no monomial;
  8. the contrasting min-plus divisor-lattice family, whose argmin is constant.

Everything uses `fractions.Fraction`, so ties -- the events that matter -- are
detected exactly.  Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Rat = Fraction


# ---------------------------------------------------------------------------
# Core: tropical evaluation and fibres
# ---------------------------------------------------------------------------


def trop_value(coeffs: Sequence[Rat], x: Rat) -> Rat:
    """Tropical evaluation min_i (c_i + i*x) of the degree-n polynomial."""
    return min(c + i * x for i, c in enumerate(coeffs))


def fiber(coeffs: Sequence[Rat], x: Rat) -> List[int]:
    """The fibre at x: the sorted list of exponents attaining the minimum."""
    vals = [c + i * x for i, c in enumerate(coeffs)]
    best = min(vals)
    return [i for i, v in enumerate(vals) if v == best]


def multiplicity(coeffs: Sequence[Rat], x: Rat) -> int:
    """Local multiplicity |F(x)|."""
    return len(fiber(coeffs, x))


def corner_point(coeffs: Sequence[Rat]) -> Rat:
    """The explicit corner x* = max_{1<=i<=n} (c_0 - c_i)/i  (needs n >= 1)."""
    n = len(coeffs) - 1
    assert n >= 1, "degree must be at least 1"
    return max((coeffs[0] - coeffs[i]) / Fraction(i) for i in range(1, n + 1))


def lower_hull(points: Sequence[Tuple[int, Rat]]) -> List[Tuple[int, Rat]]:
    """Lower convex hull of points sorted by abscissa (monotone chain, O(n))."""
    hull: List[Tuple[int, Rat]] = []
    for p in points:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            # drop the middle point if it is on or above the segment
            if (y2 - y1) * (p[0] - x1) >= (p[1] - y1) * (x2 - x1):
                hull.pop()
            else:
                break
        hull.append(p)
    return hull


def all_corners(coeffs: Sequence[Rat]) -> List[Tuple[Rat, List[int]]]:
    """All corners of the envelope, as (location, fibre), left to right.

    The corner between consecutive lower-hull vertices (i, c_i), (j, c_j) sits
    at x = -(c_j - c_i)/(j - i), the negative of the hull-edge slope.
    """
    pts = [(i, c) for i, c in enumerate(coeffs)]
    hull = lower_hull(pts)
    corners: List[Tuple[Rat, List[int]]] = []
    for (i, ci), (j, cj) in zip(hull, hull[1:]):
        x = -(cj - ci) / Fraction(j - i)
        corners.append((x, fiber(coeffs, x)))
    corners.sort(key=lambda t: t[0])
    return corners


def total_excess(coeffs: Sequence[Rat]) -> int:
    """Sum over all corners of (|F(x)| - 1)."""
    return sum(len(f) - 1 for _, f in all_corners(coeffs))


# ---------------------------------------------------------------------------
# Distinguished coefficient families
# ---------------------------------------------------------------------------


def step_coeffs(n: int, k: int) -> List[Rat]:
    """Step polynomial of width k: c_i = 0 for i < k, else 1."""
    return [Fraction(0) if i < k else Fraction(1) for i in range(n + 1)]


def ramp_coeffs(n: int) -> List[Rat]:
    """Generic ('ramp') polynomial c_i = i(i-1)/2, increments 0,1,2,..."""
    return [Fraction(i * (i - 1), 2) for i in range(n + 1)]


def from_increments(incr: Sequence[Rat]) -> List[Rat]:
    """Coefficients with prescribed slope increments: c_i = sum_{l<i} d_l."""
    out = [Fraction(0)]
    for d in incr:
        out.append(out[-1] + d)
    return out


def staircase_increments(blocks: Sequence[int]) -> List[Rat]:
    """Staircase of a composition: block index of each position."""
    incr: List[Rat] = []
    for j, m in enumerate(blocks):
        incr.extend([Fraction(j)] * m)
    return incr


def composition_polynomial(blocks: Sequence[int]) -> List[Rat]:
    """Degree-n convex polynomial realising the composition `blocks` of n."""
    return from_increments(staircase_increments(blocks))


def compositions(n: int) -> Iterable[Tuple[int, ...]]:
    """All compositions (ordered tuples of positive integers summing to n)."""
    for r in range(1, n + 1):
        for cut in itertools.combinations(range(1, n), r - 1):
            bounds = (0,) + cut + (n,)
            yield tuple(b - a for a, b in zip(bounds, bounds[1:]))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_ordering_law(trials: int = 300, seed: int = 20260913) -> None:
    banner("1.  Monotone ordering law:  x < y  =>  max F(y) <= min F(x)")
    rng = random.Random(seed)
    worst = None
    for _ in range(trials):
        n = rng.randint(1, 7)
        coeffs = [Fraction(rng.randint(-20, 20), rng.randint(1, 4)) for _ in range(n + 1)]
        x = Fraction(rng.randint(-30, 30), rng.randint(1, 5))
        y = x + Fraction(rng.randint(1, 40), rng.randint(1, 5))
        fx, fy = fiber(coeffs, x), fiber(coeffs, y)
        assert max(fy) <= min(fx), (coeffs, x, y, fx, fy)
        # the two fibres also meet in at most one index
        assert len(set(fx) & set(fy)) <= 1
        worst = (coeffs, x, y, fx, fy)
    print(f"  verified on {trials} random instances (exact rational arithmetic).")
    coeffs, x, y, fx, fy = worst  # type: ignore[misc]
    print(f"  last instance: c = {[str(c) for c in coeffs]}")
    print(f"    F({x}) = {fx},   F({y}) = {fy}   ->  max F(y) = {max(fy)} <= {min(fx)} = min F(x)")


def demo_corner_existence(trials: int = 200, seed: int = 7) -> None:
    banner("2.  Corner existence and genuine dependence, for EVERY coefficient vector")
    rng = random.Random(seed)
    for _ in range(trials):
        n = rng.randint(1, 8)
        coeffs = [Fraction(rng.randint(-25, 25), rng.randint(1, 6)) for _ in range(n + 1)]
        xs = corner_point(coeffs)
        assert multiplicity(coeffs, xs) >= 2, (coeffs, xs)
        assert fiber(coeffs, xs + 1) == [0], (coeffs, xs)
    print(f"  verified on {trials} random instances:")
    print("    |F(x*)| >= 2  and  F(x*+1) = {0}  with  x* = max_i (c_0 - c_i)/i.")
    print("  Hence two fibres of unequal cardinality always exist:")
    print("  no constant family can be pointwise equivalent to the fibre family.")
    demo_c = [Fraction(v) for v in (3, 1, -2, 0, 4)]
    xs = corner_point(demo_c)
    print(f"\n  worked example  c = {[str(c) for c in demo_c]}  (degree 4):")
    print(f"    x*          = {xs}")
    print(f"    F(x*)       = {fiber(demo_c, xs)}   (multiplicity {multiplicity(demo_c, xs)})")
    print(f"    F(x*+1)     = {fiber(demo_c, xs + 1)}   (multiplicity {multiplicity(demo_c, xs + 1)})")


def demo_every_cardinality(n: int = 6) -> None:
    banner(f"3.  Every admissible multiplicity 2 <= k <= n+1 occurs (n = {n})")
    print("     k   |F(0)| for step polynomial   |F(1)|   unequal?")
    for k in range(1, n + 2):
        c = step_coeffs(n, k)
        a, b = multiplicity(c, Fraction(0)), multiplicity(c, Fraction(1))
        assert a == k and b == 1
        print(f"    {k:2d}   {a:^27d}   {b:^6d}   {'yes' if a != b else 'no (k=1)'}")
    print(f"\n  The cap |F(x)| <= n+1 = {n + 1} is attained at k = n+1 and cannot be exceeded.")


def demo_generic_ramp(n: int = 5) -> None:
    banner(f"4.  The generic (ramp) polynomial: n simple corners (n = {n})")
    c = ramp_coeffs(n)
    print(f"  c_i = i(i-1)/2 :  {[str(v) for v in c]}")
    for m in range(n):
        x = Fraction(-m)
        f = fiber(c, x)
        assert f == [m, m + 1]
        print(f"    F({x}) = {f}   multiplicity {len(f)}")
    half = Fraction(-1, 2)
    print(f"    F({half}) = {fiber(c, half)}   (a non-corner: multiplicity 1)")
    exc = total_excess(c)
    print(f"\n  number of corners = {len(all_corners(c))} = n,  total excess = {exc} = n")
    print("  both the corner-count bound and the degree bound are saturated at once.")


def demo_convex_formula(n: int = 8) -> None:
    banner("5.  Convex data:  |F(-v)| = #{ l < n : d_l = v } + 1,  and equality of the bound")
    incr = [Fraction(v) for v in (1, 1, 2, 2, 2, 5, 7, 7)][:n]
    c = from_increments(incr)
    print(f"  increments d = {[str(d) for d in incr]}")
    print(f"  coefficients  = {[str(v) for v in c]}")
    slopes = sorted(set(incr))
    total = 0
    for v in slopes:
        count = sum(1 for d in incr if d == v)
        m = multiplicity(c, -v)
        assert m == count + 1
        total += m - 1
        print(f"    slope v = {v}:  #increments = {count},  |F(-v)| = {m} = count + 1")
    nn = len(incr)
    assert total == nn
    print(f"\n  sum over slopes of (|F(-v)| - 1) = {total} = n = {nn}   (equality form)")
    # a non-slope value has a singleton fibre
    v0 = Fraction(3)
    print(f"  a non-slope value v = {v0}:  F(-v) = {fiber(c, -v0)}  (singleton, as predicted)")


def demo_composition_spectrum(n: int = 5) -> None:
    banner(f"6.  Every composition of n is a multiplicity profile (n = {n})")
    count = 0
    for blocks in compositions(n):
        c = composition_polynomial(blocks)
        profile = tuple(multiplicity(c, Fraction(-j)) - 1 for j in range(len(blocks)))
        assert profile == tuple(blocks), (blocks, profile)
        assert sum(profile) == n
        count += 1
        if count <= 10:
            mult = tuple(m + 1 for m in profile)
            print(f"    composition {blocks!s:<18} -> corner multiplicities {mult}")
    print(f"    ... verified all {count} compositions of {n} "
          f"(there are 2^(n-1) = {2 ** (n - 1)}).")


def demo_nonconvex_defect() -> None:
    banner("7.  Strictness without convexity:  c = (0, 5, 1, 7), degree 3")
    c = [Fraction(v) for v in (0, 5, 1, 7)]
    for x in (Fraction(-1, 2), Fraction(-6)):
        print(f"    F({x}) = {fiber(c, x)}   multiplicity {multiplicity(c, x)}")
    corners = all_corners(c)
    exc = total_excess(c)
    n = len(c) - 1
    print(f"\n  corners found: {[(str(x), f) for x, f in corners]}")
    print(f"  total multiplicity excess = {exc} < {n} = n:  the degree bound is STRICT.")
    hull = lower_hull([(i, v) for i, v in enumerate(c)])
    print(f"  lower hull vertices: {[(i, str(v)) for i, v in hull]}")
    # the monomial i = 1 lies strictly above the hull, so it is never active
    seg_height = Fraction(0) + (Fraction(1) - Fraction(0)) * Fraction(1 - 0, 2 - 0)
    print(f"  the point (1, {c[1]}) lies above the hull segment (0,0)-(2,1), "
          f"whose height at 1 is {seg_height}:")
    print("  the monomial i = 1 is never the strict minimum, and the missing")
    print(f"  lattice point of the hull edge accounts for the defect {n - exc} = n - excess.")
    for x in (Fraction(-4), Fraction(-3), Fraction(-2), Fraction(-1), Fraction(0)):
        assert 1 not in fiber(c, x)
    print("  (checked: index 1 never appears in any fibre sampled along the line.)")


def demo_divisor_contrast(limit: int = 24) -> None:
    banner("8.  A contrasting CONSTANT tropical family: min-plus over the divisor lattice")
    weight: Callable[[int], int] = lambda d: 3 * d + 1  # strictly increasing
    print("  weight w(d) = 3d + 1 (strictly increasing); argmin over divisors of N:")
    rows: Dict[int, List[int]] = {}
    for N in range(1, limit + 1):
        divisors = [d for d in range(1, N + 1) if N % d == 0]
        best = min(weight(d) for d in divisors)
        rows[N] = [d for d in divisors if weight(d) == best]
        assert rows[N] == [1]
    shown = ", ".join(f"N={N}: {rows[N]}" for N in range(1, 9))
    print(f"    {shown}, ...")
    print(f"  argmin fibre = {{1}} for every 1 <= N <= {limit}: cardinality is constant.")
    print("  So min-plus algebra alone does not force dependence -- the polynomial")
    print("  fibre family is non-constant because distinct slopes must cross.")


def demo_degree_bound_sampling(trials: int = 150, seed: int = 99) -> None:
    banner("9.  The degree bound  sum_x (|F(x)| - 1) <= n  over arbitrary finite point sets")
    rng = random.Random(seed)
    worst_ratio = 0.0
    for _ in range(trials):
        n = rng.randint(1, 6)
        coeffs = [Fraction(rng.randint(-15, 15), rng.randint(1, 3)) for _ in range(n + 1)]
        pts = {Fraction(rng.randint(-20, 20), rng.randint(1, 4)) for _ in range(12)}
        pts |= {x for x, _ in all_corners(coeffs)}
        s = sum(multiplicity(coeffs, x) - 1 for x in pts)
        assert s <= n, (coeffs, sorted(pts), s, n)
        worst_ratio = max(worst_ratio, s / n)
        assert len([x for x in pts if multiplicity(coeffs, x) >= 2]) <= n
    print(f"  verified on {trials} random instances, each sampled at 12 random points")
    print("  together with all corners; the bound and the corner count both held.")
    print(f"  largest observed ratio (excess / n) = {worst_ratio:.3f}  (must be <= 1).")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_ordering_law()
    demo_corner_existence()
    demo_every_cardinality()
    demo_generic_ramp()
    demo_convex_formula()
    demo_composition_spectrum()
    demo_nonconvex_defect()
    demo_divisor_contrast()
    demo_degree_bound_sampling()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
