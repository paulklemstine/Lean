#!/usr/bin/env python3
"""
The baby-step leg of Harvey's N^{1/5} factoring cost is a closed variable,
and "adding a floor" is the weight lever in disguise -- numerical companion.

Everything here uses only the Python standard library and exact rational
arithmetic (fractions.Fraction), so every printed equality is exact.

Sections
  1. Exact minimax solver for max-of-affine exponent costs.
  2. Harvey's three-leg cost: optimum 1/5, dual certificate (1/5, 2/5, 2/5).
  3. Pin 1: A*C is invariant under re-splitting m; optimising out m gives the M-leg.
  4. Pin 2: output counting for straight-line programs; the baby-step chain is optimal.
  5. Pin 3: injectivity of baby steps iff m <= ord(alpha) (sharp boundary).
  6. Exact LP sensitivity: shadow prices (1/5, 2/5, 2/5).
  7. "Add a floor": optimum (gamma+delta)/(2+alpha+w); break-even delta < w/5.
  8. Faithful model: 1/(5+4 theta) and 1/(5+2w) bounds; 1/6 iff theta>=1/4, w>=1/2.
"""
from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction as F
from typing import Callable, Optional, Sequence

Vec = list[F]
# An affine leg in variables x_0..x_{d-1}:  (coefficients, constant)  ->  c.x + k
Leg = tuple[Sequence[F], F]


# ---------------------------------------------------------------------------
# 1. Exact minimax of affine functions (vertex enumeration of the epigraph LP)
# ---------------------------------------------------------------------------
def solve_linear(mat: list[list[F]], rhs: list[F]) -> Optional[list[F]]:
    """Gauss-Jordan elimination over Q. Returns the unique solution or None."""
    n = len(mat)
    a = [row[:] + [rhs[i]] for i, row in enumerate(mat)]
    for col in range(n):
        piv = next((r for r in range(col, n) if a[r][col] != 0), None)
        if piv is None:
            return None
        a[col], a[piv] = a[piv], a[col]
        p = a[col][col]
        a[col] = [v / p for v in a[col]]
        for r in range(n):
            if r != col and a[r][col] != 0:
                f = a[r][col]
                a[r] = [vr - f * vc for vr, vc in zip(a[r], a[col])]
    return [a[i][n] for i in range(n)]


def leg_value(leg: Leg, x: Sequence[F]) -> F:
    coeffs, const = leg
    return sum((c * xi for c, xi in zip(coeffs, x)), F(0)) + const


def minimax_affine(legs: Sequence[Leg], dim: int) -> tuple[F, list[F]]:
    """
    Minimise T(x) = max_i (c_i . x + k_i) over x in Q^dim, exactly.

    The epigraph LP  min t  s.t.  c_i.x + k_i <= t  has an optimal vertex where
    dim+1 legs are tight.  We enumerate all (dim+1)-subsets, solve the square
    system "all chosen legs equal t", and keep the best feasible point.
    Complexity: O(C(L, dim+1) * dim^3) -- tiny for the costs in this paper.
    """
    best: Optional[tuple[F, list[F]]] = None
    for subset in itertools.combinations(range(len(legs)), dim + 1):
        mat: list[list[F]] = []
        rhs: list[F] = []
        for i in subset:
            coeffs, const = legs[i]
            mat.append([F(c) for c in coeffs] + [F(-1)])  # c.x - t = -k
            rhs.append(-F(const))
        sol = solve_linear(mat, rhs)
        if sol is None:
            continue
        x, t = sol[:dim], sol[dim]
        if all(leg_value(l, x) <= t for l in legs):
            if best is None or t < best[0]:
                best = (t, x)
    assert best is not None, "unbounded or degenerate cost"
    return best


# ---------------------------------------------------------------------------
# 2. Harvey's three-leg cost in exponent form
# ---------------------------------------------------------------------------
HALF = F(1, 2)


def cost_exp(a: F, b: F) -> F:
    """max{ a (pair leg r=N^a), b (baby-step leg m=N^b), 1/2 - a/2 - b (interior) }."""
    return max(a, b, HALF - a / 2 - b)


HARVEY_LEGS: list[Leg] = [
    ([F(1), F(0)], F(0)),            # r       : a
    ([F(0), F(1)], F(0)),            # m       : b
    ([F(-1, 2), F(-1)], HALF),       # interior: 1/2 - a/2 - b
]


def section_harvey() -> None:
    print("=" * 72)
    print("2. Harvey's three-leg cost  max{ a, b, 1/2 - a/2 - b }")
    t, x = minimax_affine(HARVEY_LEGS, 2)
    print(f"   exact optimum exponent = {t}   at (a, b) = ({x[0]}, {x[1]})")
    lam = [F(1, 5), F(2, 5), F(2, 5)]
    # the certificate: sum lam_i * leg_i is the constant 1/5, identically in (a,b)
    coeff_a = sum(l * leg[0][0] for l, leg in zip(lam, HARVEY_LEGS))
    coeff_b = sum(l * leg[0][1] for l, leg in zip(lam, HARVEY_LEGS))
    const = sum(l * leg[1] for l, leg in zip(lam, HARVEY_LEGS))
    print(f"   dual certificate lambda = (1/5, 2/5, 2/5): combination = "
          f"{coeff_a}*a + {coeff_b}*b + {const}")
    rng = random.Random(1)
    worst = min(cost_exp(F(rng.randint(-50, 80), 100), F(rng.randint(-50, 80), 100))
                for _ in range(20000))
    print(f"   min of cost over 20000 random rational points = {worst}  (never < 1/5)")


# ---------------------------------------------------------------------------
# 3. Pin 1: A*C is one degree of freedom
# ---------------------------------------------------------------------------
def section_pin1() -> None:
    print("=" * 72)
    print("3. Pin 1: the m-leg C and the interior A are two halves of one quantity")
    N, r = 10.0 ** 30, 10.0 ** 6
    target = math.sqrt(N) / math.sqrt(r)
    m_leg = (N / r) ** 0.25
    print(f"   N = 1e30, r = 1e6:  A*C should equal N^(1/2)/r^(1/2) = {target:.6e}")
    for m in [1e3, 1e5, m_leg, 1e8, 1e10]:
        A = math.sqrt(N) / (math.sqrt(r) * m)
        print(f"     m = {m:10.4e}:  A = {A:10.4e}  A*C = {A * m:.6e}  "
              f"max(A,C) = {max(A, m):10.4e}  >= (N/r)^(1/4) = {m_leg:.4e}")
    print("   Exponent form: min_b max{a, b, 1/2-a/2-b} = max{a, (1-a)/4} (the M-leg):")
    for a in [F(0), F(1, 10), F(1, 5), F(3, 10), F(1, 2)]:
        grid = min(cost_exp(a, F(k, 400)) for k in range(-200, 400))
        print(f"     a = {str(a):5s}: grid-min over b = {str(grid):6s}  "
              f"max(a,(1-a)/4) = {max(a, (1 - a) / 4)}")


# ---------------------------------------------------------------------------
# 4. Pin 2: output counting for straight-line programs
# ---------------------------------------------------------------------------
def slp_run(g0: int, prog: Sequence[tuple[int, int]], mul: Callable[[int, int], int],
            one: int) -> list[int]:
    """Each instruction (i, j) appends acc[i]*acc[j] (out-of-range index reads 1)."""
    acc = [g0]
    for i, j in prog:
        x = acc[i] if i < len(acc) else one
        y = acc[j] if j < len(acc) else one
        acc.append(mul(x, y))
    return acc


def baby_prog(k: int) -> list[tuple[int, int]]:
    """Step j multiplies entry j (= alpha^{j+1}) by entry 0 (= alpha)."""
    return [(j, 0) for j in range(k)]


def section_pin2() -> None:
    print("=" * 72)
    print("4. Pin 2: a program with t multiplications outputs at most t+1 distinct values")
    n = 1009 * 1013
    mul = lambda x, y: (x * y) % n  # noqa: E731
    rng = random.Random(7)
    worst_ratio = 0.0
    for _ in range(2000):
        t = rng.randint(0, 40)
        prog = [(rng.randint(0, k + 1), rng.randint(0, k + 1)) for k in range(t)]
        out = slp_run(rng.randint(2, n - 1), prog, mul, 1)
        assert len(out) == t + 1 and len(set(out)) <= t + 1
        worst_ratio = max(worst_ratio, len(set(out)) / (t + 1))
    print(f"   2000 random programs mod {n}: distinct/(t+1) never exceeds {worst_ratio:.3f}")
    alpha, m = 2, 12
    out = slp_run(alpha, baby_prog(m - 1), mul, 1)
    expect = [pow(alpha, i + 1, n) for i in range(m)]
    print(f"   baby chain with m-1 = {m - 1} multiplications = [alpha^1..alpha^{m}]: "
          f"{out == expect}; distinct = {len(set(out))} = m  -> lower bound m-1 is met")


# ---------------------------------------------------------------------------
# 5. Pin 3: injectivity iff m <= ord(alpha)
# ---------------------------------------------------------------------------
def mult_order(alpha: int, n: int) -> int:
    x, k = alpha % n, 1
    while x != 1:
        x = (x * alpha) % n
        k += 1
    return k


def section_pin3() -> None:
    print("=" * 72)
    print("5. Pin 3: baby steps alpha^1..alpha^m are distinct  <=>  m <= ord(alpha)")
    n = 7 * 11 * 13  # 1001
    for alpha in [2, 3, 10]:
        o = mult_order(alpha, n)
        for m in [o - 1, o, o + 1]:
            steps = [pow(alpha, i + 1, n) for i in range(m)]
            nodup = len(set(steps)) == len(steps)
            print(f"   alpha = {alpha:2d}, ord = {o:3d}, m = {m:3d}: distinct = {nodup}"
                  + ("" if nodup else f"   (collision alpha^1 = alpha^{o + 1} = {steps[0]})"))


# ---------------------------------------------------------------------------
# 6. Exact LP sensitivity / shadow prices
# ---------------------------------------------------------------------------
def section_sensitivity() -> None:
    print("=" * 72)
    print("6. Shadow prices: cheapening (r, m, interior) by (e1, e2, e3) lowers 1/5 by")
    print("   exactly (e1 + 2 e2 + 2 e3)/5")
    for e in [(F(1, 10), F(0), F(0)), (F(0), F(1, 10), F(0)), (F(0), F(0), F(1, 10)),
              (F(1, 20), F(1, 30), F(1, 40)), (F(0), F(-1, 10), F(0))]:
        legs = [([F(1), F(0)], -e[0]), ([F(0), F(1)], -e[1]), ([F(-1, 2), F(-1)], HALF - e[2])]
        t, _ = minimax_affine(legs, 2)
        pred = F(1, 5) - (e[0] + 2 * e[1] + 2 * e[2]) / 5
        print(f"   e = ({str(e[0]):5s},{str(e[1]):5s},{str(e[2]):5s}): optimum = {str(t):8s} "
              f"prediction = {pred}")
    print("   (m-leg closed: if e2 <= 0 and e3 = 0, the only gain is e1/5 via the pair leg)")


# ---------------------------------------------------------------------------
# 7. Add a floor
# ---------------------------------------------------------------------------
def floor_optimum(gamma: F, delta: F, alpha: F, w: F) -> F:
    legs: list[Leg] = [([F(1), F(0), F(0)], F(0)), ([F(0), F(1), F(0)], F(0)),
                       ([F(0), F(0), F(1)], F(0)), ([-alpha, F(-1), -w], gamma + delta)]
    return minimax_affine(legs, 3)[0]


def section_floor() -> None:
    print("=" * 72)
    print("7. Add a floor c (interior weight w, overhead delta):")
    print("   optimum = (1/2 + delta)/(5/2 + w); beats 1/5 iff delta < w/5")
    for w, d in [(F(0), F(0)), (F(0), F(1, 100)), (F(1, 2), F(0)), (F(1, 2), F(1, 10)),
                 (F(1, 2), F(1, 11)), (F(1), F(1, 5)), (F(1), F(1, 6))]:
        t = floor_optimum(HALF, d, HALF, w)
        formula = (HALF + d) / (F(5, 2) + w)
        print(f"   w = {str(w):4s} delta = {str(d):5s}: optimum = {str(t):7s} "
              f"(formula {formula}); beats 1/5: {t < F(1, 5)}; delta < w/5: {d < w / 5}")


# ---------------------------------------------------------------------------
# 8. Faithful model
# ---------------------------------------------------------------------------
def faithful_optimum(theta: F, w: F) -> tuple[F, list[F]]:
    # variables (a, b, c)
    legs: list[Leg] = [
        ([F(-1, 4), F(0), -theta], F(1, 4)),       # M-leg (1-a)/4 - theta c
        ([F(1), F(0), F(0)], F(0)),                # a
        ([F(0), F(1), F(0)], F(0)),                # b
        ([F(0), F(0), F(1)], F(0)),                # c
        ([F(-1, 2), F(-1), -w], HALF),             # interior
    ]
    return minimax_affine(legs, 3)


def section_faithful() -> None:
    print("=" * 72)
    print("8. Faithful model: optimum = max{1/(5+4 theta), 1/(5+2w)}")
    for theta, w in [(F(0), F(1)), (F(1), F(0)), (F(1, 4), F(1, 2)), (F(1, 8), F(1, 2)),
                     (F(1, 4), F(1, 4)), (F(1, 2), F(1))]:
        t, x = faithful_optimum(theta, w)
        bound = max(1 / (5 + 4 * theta), 1 / (5 + 2 * w))
        print(f"   theta = {str(theta):4s} w = {str(w):4s}: optimum = {str(t):6s} "
              f"bound = {str(bound):6s} below 1/5: {t < F(1, 5)}  <= 1/6: {t <= F(1, 6)}")
    t, x = faithful_optimum(F(1, 4), F(1, 2))
    print(f"   at theta=1/4, w=1/2 the optimum 1/6 is reached at (a,b,c) = {tuple(map(str, x))}")


if __name__ == "__main__":
    section_harvey()
    section_pin1()
    section_pin2()
    section_pin3()
    section_sensitivity()
    section_floor()
    section_faithful()
