#!/usr/bin/env python3
"""
Constructive Analysis: Bishop Reals, the Constructive IVT, and Located Suprema
==============================================================================

A self-contained numerical demonstration of the results in the accompanying
paper.  Everything below runs in exact rational arithmetic (``fractions.Fraction``)
wherever the mathematics is rational, so the numbers printed are the numbers
proved -- not floating-point approximations of them.

Contents
--------
1.  Bishop reals: regular sequences of rationals with an explicit modulus.
      |x_m - x_n| <= 1/(m+1) + 1/(n+1),  and  |x_hat - x_n| <= 1/(n+1).
2.  Computable arithmetic: the index shifts 2n+1 (sum) and (B_x+B_y)(n+1)
    (product), with the canonical bound B_x = ceil(|x_0|) + 2.
3.  A computable irrational: sqrt(2) via integer square roots.
4.  Constructive completeness: the shifted diagonal (x_{2n+1})_{2n+1}, and an
    explicit witness family showing the unshifted diagonal fails.
5.  The constructive order: positivity witnesses, cotransitivity by a single
    midpoint comparison, and the non-existence of a uniform witness bound.
6.  The approximate intermediate value theorem: the finite grid search, with
    the sharp root modulus eps/c and the hypothesis-free bracketing bound.
7.  Brouwerian counterexample: the shelf family S_t(x) = min(x-1, max(t, x-2))
    and the unit jump of every root selector at t = 0.
8.  Local non-constancy is insufficient: the dip function.
9.  Located suprema: trisection vs. the faster (2/5, 1/2) one-query search,
    the exact contraction law max(beta, 1-alpha), and the barrier 1/2.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Optional, Tuple

Q = Fraction


# ---------------------------------------------------------------------------
# Section 1.  Bishop reals: regular sequences of rationals
# ---------------------------------------------------------------------------

# A Bishop real is represented as a function n |-> x_n in Q, with the promise
#     |x_m - x_n| <= 1/(m+1) + 1/(n+1)   for all m, n.
Reg = Callable[[int], Q]


def err(n: int) -> Q:
    """The canonical error bar at index ``n``: the number 1/(n+1)."""
    return Q(1, n + 1)


def check_regular(x: Reg, upto: int = 40) -> bool:
    """Verify the regularity inequality for all index pairs below ``upto``."""
    for m in range(upto):
        for n in range(upto):
            if abs(x(m) - x(n)) > err(m) + err(n):
                return False
    return True


def of_rat(q: Q) -> Reg:
    """The Bishop real determined by a rational constant."""
    return lambda _n: q


def neg(x: Reg) -> Reg:
    """Negation; no index shift is required."""
    return lambda n: -x(n)


# ---------------------------------------------------------------------------
# Section 2.  Computable arithmetic with Bishop's index shifts
# ---------------------------------------------------------------------------

def add(x: Reg, y: Reg) -> Reg:
    """Sum, with Bishop's index shift n |-> 2n+1 (each summand to twice the
    required accuracy, so that the two halved error bars sum correctly)."""
    return lambda n: x(2 * n + 1) + y(2 * n + 1)


def bound(x: Reg) -> int:
    """Bishop's canonical bound  B_x = ceil(|x_0|) + 2, which dominates |x_n|
    for every n, because |x_n - x_0| <= 1/(n+1) + 1 <= 2."""
    return math.ceil(abs(x(0))) + 2


def mul(x: Reg, y: Reg) -> Reg:
    """Product, with index shift  n |-> (B_x + B_y)(n+1).  The shift must grow
    with the magnitudes because an error delta in a factor of size B becomes an
    error B*delta in the product."""
    m = bound(x) + bound(y)
    return lambda n: x(m * (n + 1)) * y(m * (n + 1))


# ---------------------------------------------------------------------------
# Section 3.  A concrete computable irrational
# ---------------------------------------------------------------------------

def sqrt_two(n: int) -> Q:
    """The n-th approximation of sqrt(2):  floor(sqrt(2(n+1)^2)) / (n+1).

    Pure integer arithmetic.  The estimate  s <= sqrt(2) m < s+1  for
    s = isqrt(2 m^2)  gives  |s/m - sqrt(2)| <= 1/m,  which is regularity with
    the canonical rate."""
    m = n + 1
    return Q(math.isqrt(2 * m * m), m)


# ---------------------------------------------------------------------------
# Section 4.  Constructive completeness and the diagonal shift
# ---------------------------------------------------------------------------

def diag_witness(k: int) -> Reg:
    """The k-th member of the family that separates the two diagonals:

        (x_k)_n = 1/(k+1) + (-1)^k / (n+1).

    Each member is regular and denotes the real 1/(k+1); the built-in wobble
    sits exactly at the edge of the permitted error, with a sign flipping in k.
    """
    sign = 1 if k % 2 == 0 else -1
    return lambda n: Q(1, k + 1) + sign * Q(1, n + 1)


def shifted_diagonal(family: Callable[[int], Reg]) -> Reg:
    """Bishop's limit construction:  L_n = (x_{2n+1})_{2n+1}."""
    return lambda n: family(2 * n + 1)(2 * n + 1)


def unshifted_diagonal(family: Callable[[int], Reg]) -> Reg:
    """The naive diagonal  n |-> (x_n)_n,  which need not be regular."""
    return lambda n: family(n)(n)


def first_regularity_violation(x: Reg, upto: int = 20) -> Optional[Tuple[int, int, Q, Q]]:
    """Return the first (m, n, observed gap, permitted gap) violating regularity."""
    for m in range(upto):
        for n in range(upto):
            gap = abs(x(m) - x(n))
            allowed = err(m) + err(n)
            if gap > allowed:
                return (m, n, gap, allowed)
    return None


# ---------------------------------------------------------------------------
# Section 5.  The constructive order
# ---------------------------------------------------------------------------

def lt_witness(x: Reg, y: Reg, search: int = 500) -> Optional[int]:
    """Search for a witness index n for  x < y,  i.e. an n with
    x_n + 2/(n+1) < y_n.  A witness is a *certificate*, not a mere assertion:
    from it one reads off the rational lower bound gap_n(x, y) on y - x."""
    for n in range(search):
        if x(n) + 2 * err(n) < y(n):
            return n
    return None


def gap_at(x: Reg, y: Reg, n: int) -> Q:
    """The certified rational gap  g_n = y_n - x_n - 2/(n+1)."""
    return y(n) - x(n) - 2 * err(n)


def cotransitivity_index(g: Q) -> int:
    """The index m guaranteed by the cotransitivity theorem: any m with
    1/(m+1) <= g/8, i.e. m = ceil(8/g) - 1."""
    return max(0, math.ceil(Q(8, 1) / g) - 1)


def cotransitive_decide(x: Reg, y: Reg, z: Reg, n: int) -> Tuple[str, int]:
    """Given a witness index ``n`` for x < y, decide  x < z  or  z < y  by a
    single rational comparison of z_m against the midpoint (x_m + y_m)/2."""
    g = gap_at(x, y, n)
    if g <= 0:
        raise ValueError("index n is not a witness for x < y")
    m = cotransitivity_index(g)
    midpoint = (x(m) + y(m)) / 2
    if z(m) >= midpoint:
        return ("x < z", m)
    return ("z < y", m)


# ---------------------------------------------------------------------------
# Section 6.  The intermediate value theorem
# ---------------------------------------------------------------------------

def grid(a: float, b: float, N: int, k: int) -> float:
    """The k-th point of the uniform grid of N subintervals of [a, b]."""
    return a + k * (b - a) / N


def grid_search(f: Callable[[float], float], a: float, b: float, N: int) -> int:
    """The sign-change search: return the largest grid index k with f <= 0.

    This single index is simultaneously
      * an eps-approximate root whenever the mesh is at most omega(eps), and
      * within one mesh (b-a)/N of a genuine root, with no hypotheses at all.
    """
    best = 0
    for k in range(N + 1):
        if f(grid(a, b, N, k)) <= 0:
            best = k
    return best


def approximate_ivt(
    f: Callable[[float], float],
    a: float,
    b: float,
    omega: Callable[[float], float],
    eps: float,
) -> Tuple[int, float, float]:
    """Approximate IVT with explicit modulus.  Choose N with mesh <= omega(eps),
    run the grid search, and return (N, x, f(x)) with |f(x)| <= eps guaranteed."""
    N = max(1, math.ceil((b - a) / omega(eps)) + 1)
    k = grid_search(f, a, b, N)
    x = grid(a, b, N, k)
    return (N, x, f(x))


def constructive_ivt(
    f: Callable[[float], float],
    a: float,
    b: float,
    omega: Callable[[float], float],
    c: float,
    delta: float,
) -> Tuple[int, float]:
    """Exact IVT under a positive slope bound ``c``.  The modulus of the root is
    delta |-> omega(c * delta): run the grid search at value-accuracy c*delta and
    the returned point is within ``delta`` of the unique root."""
    N, x, _fx = approximate_ivt(f, a, b, omega, c * delta)
    return (N, x)


# ---------------------------------------------------------------------------
# Section 7.  The shelf family (Brouwerian counterexample)
# ---------------------------------------------------------------------------

def shelf(t: float, x: float) -> float:
    """Bishop's shelf function  S_t(x) = min(x-1, max(t, x-2))  on [0, 3].

    1-Lipschitz for every t, with S_t(0) <= 0 <= S_t(3).  Its root is 1 for
    t > 0 and 2 for t < 0, so it teleports as t crosses zero."""
    return min(x - 1.0, max(t, x - 2.0))


def shelf_exact_root(t: float) -> float:
    """The exact root of S_t, which exists classically for every t."""
    if t > 0:
        return 1.0
    if t < 0:
        return 2.0
    return 1.0  # at t = 0 the whole interval [1, 2] consists of roots


# ---------------------------------------------------------------------------
# Section 8.  Local non-constancy is insufficient
# ---------------------------------------------------------------------------

def dip(eta: float, x: float) -> float:
    """D_eta(x) = min(x - 1, |x - 3| + eta) on [0, 4].

    1-Lipschitz, unique root x = 1, satisfies local non-constancy with the
    explicit modulus nu(h) = h/8 -- and yet D_eta(3) = eta is arbitrarily small
    at distance 2 from the only root."""
    return min(x - 1.0, abs(x - 3.0) + eta)


# ---------------------------------------------------------------------------
# Section 9.  Located suprema
# ---------------------------------------------------------------------------

Oracle = Callable[[Q, Q], bool]


def located_iic(c: Q) -> Oracle:
    """A located datum for the half-line (-inf, c] with rational endpoint c:
    the decidable test  L(p, q) = (c <= q).

      * true  => q is an upper bound of the half-line;
      * false => q < c, so the member c itself exceeds p (since p < q < c).
    """
    return lambda _p, q: c <= q


def search_step(alpha: Q, beta: Q, L: Oracle, pq: Tuple[Q, Q]) -> Tuple[Q, Q]:
    """One step of the general one-query search with query fractions alpha < beta.
    On ``true`` keep the left beta-portion; on ``false`` the right (1-alpha)-portion."""
    p, q = pq
    w = q - p
    if L(p + alpha * w, p + beta * w):
        return (p, p + beta * w)
    return (p + alpha * w, q)


def search(alpha: Q, beta: Q, L: Oracle, a0: Q, b0: Q, n: int) -> List[Tuple[Q, Q]]:
    """The first ``n+1`` enclosures produced by the one-query search."""
    out = [(a0, b0)]
    for _ in range(n):
        out.append(search_step(alpha, beta, L, out[-1]))
    return out


def contraction_factor(alpha: Q, beta: Q) -> Q:
    """The exact worst-case contraction factor of a one-query scheme:
    max(beta, 1 - alpha)."""
    return max(beta, 1 - alpha)


# ===========================================================================
# Demonstrations
# ===========================================================================

def line(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_regular_sequences() -> None:
    line("1.  Bishop reals: the index IS the error bar")
    print("A regular sequence satisfies  |x_m - x_n| <= 1/(m+1) + 1/(n+1),")
    print("from which  |x_hat - x_n| <= 1/(n+1)  follows by letting m -> infinity.")
    print()
    print("  n |   sqrt2_n     |  1/(n+1)   |  actual |sqrt2_n - sqrt2|")
    print("  " + "-" * 62)
    for n in [0, 1, 4, 9, 99, 999]:
        approx = sqrt_two(n)
        actual = abs(float(approx) - math.sqrt(2))
        print(f"{n:5d} | {str(approx):13s} | {float(err(n)):.6f} | {actual:.10f}")
    print()
    ok = check_regular(sqrt_two, upto=40)
    print(f"Regularity verified for all index pairs below 40:  {ok}")
    print(f"Certified values:  sqrt2_4 = {sqrt_two(4)},  sqrt2_99 = {sqrt_two(99)}")


def demo_arithmetic() -> None:
    line("2.  Computable arithmetic and Bishop's index shifts")
    x = sqrt_two
    y = of_rat(Q(3, 2))

    s = add(x, y)
    p = mul(x, x)

    print("Sum uses the shift n -> 2n+1; product uses n -> (B_x + B_y)(n+1).")
    print(f"Canonical bound of sqrt2:  B = ceil(|x_0|) + 2 = {bound(x)}")
    print(f"Canonical bound of 3/2:    B = ceil(|x_0|) + 2 = {bound(y)}")
    print()
    print("  n |  (sqrt2 + 3/2)_n   | error vs true      |  (sqrt2 * sqrt2)_n  | err vs 2")
    print("  " + "-" * 76)
    true_sum = math.sqrt(2) + 1.5
    for n in [0, 2, 9, 49]:
        sv, pv = s(n), p(n)
        print(
            f"{n:5d} | {str(sv)[:18]:18s} | {abs(float(sv) - true_sum):.10f} "
            f"| {str(pv)[:19]:19s} | {abs(float(pv) - 2.0):.10f}"
        )
    print()
    print(f"Sum regular (checked to index 40):     {check_regular(s, 40)}")
    print(f"Product regular (checked to index 25): {check_regular(p, 25)}")
    print()
    print("Note the price of multiplication: to get accuracy 1/(n+1) in the product")
    print(f"one must evaluate each factor at index {bound(x)+bound(x)}(n+1) -- the precision")
    print("blow-up is linear in the magnitude bound.  That is what makes the")
    print("constructive reals a ring: the bound must be computed from the data.")


def demo_completeness() -> None:
    line("3.  Constructive completeness: why the diagonal must be shifted")
    print("Witness family:   (x_k)_n = 1/(k+1) + (-1)^k / (n+1),   x_k denotes 1/(k+1).")
    print("These reals form a regular sequence of reals converging to 0.")
    print()

    naive = unshifted_diagonal(diag_witness)
    good = shifted_diagonal(diag_witness)

    print("Unshifted diagonal  n -> (x_n)_n :")
    for n in range(4):
        print(f"    n = {n}:  {naive(n)}")
    v = first_regularity_violation(naive, upto=8)
    assert v is not None
    m, n, observed, allowed = v
    print(f"  --> REGULARITY FAILS at (m, n) = ({m}, {n}):")
    print(f"      observed |difference| = {observed},  permitted = {allowed}")
    print("      The naive diagonal is not a real number at all.")
    print()
    print("Bishop's shifted diagonal  n -> (x_{2n+1})_{2n+1} :")
    for n in range(4):
        print(f"    n = {n}:  {good(n)}   (|value| <= 1/(n+1) = {err(n)}:"
              f" {abs(good(n)) <= err(n)})")
    print(f"  --> regular (checked to index 40): {check_regular(good, 40)}")
    print(f"  --> converges to the correct limit 0;  L_50 = {float(good(50)):+.6f}")
    print()
    print("Doubling the index halves the wobble, and that is exactly enough:")
    print("each of the two chains in the proof consumes one half.")


def demo_order() -> None:
    line("4.  The constructive order: witnesses, cotransitivity, non-uniformity")

    x = of_rat(Q(0))
    y = of_rat(Q(1, 3))
    n = lt_witness(x, y)
    assert n is not None
    g = gap_at(x, y, n)
    print(f"x = 0,  y = 1/3.   First witness index for x < y:  n = {n}")
    print(f"  certified rational gap  g = y_n - x_n - 2/(n+1) = {g}")
    print(f"  so  y - x >= {g}  is proved, not merely asserted.")
    print()

    print("Cotransitivity: one midpoint comparison decides x < z or z < y.")
    m = cotransitivity_index(g)
    print(f"  computed index  m = ceil(8/g) - 1 = {m}")
    for name, z in [("z = 1/10", of_rat(Q(1, 10))),
                    ("z = 1/4 ", of_rat(Q(1, 4))),
                    ("z = 0   ", of_rat(Q(0)))]:
        verdict, mm = cotransitive_decide(x, y, z, n)
        print(f"    {name} -> decided '{verdict}' at index {mm}")
    print("  (Both alternatives may be true; the test always returns a true one.)")
    print()

    print("No uniform witness bound: for x = 0, y = 1/(N+1) the inequality holds")
    print("but no index n <= N certifies it.")
    print()
    print("     N | first witness index | is it > N?")
    print("     " + "-" * 44)
    for N in [1, 3, 10, 30, 100]:
        yN = of_rat(Q(1, N + 1))
        w = lt_witness(of_rat(Q(0)), yN, search=4000)
        print(f"  {N:5d} | {str(w):19s} | {w is not None and w > N}")
    print()
    print("Hence no algorithm inspecting only x_0..x_N and y_0..y_N can decide")
    print("the order: it is decidable eventually, and never uniformly.")


def demo_ivt() -> None:
    line("5.  The intermediate value theorem: approximate, exact, and bracketing")

    # f(x) = x^2 - 2 on [1, 2]: 4-Lipschitz there, slope bound 2 (since
    # f(y) - f(x) = (y+x)(y-x) >= 2(y-x) for 1 <= x <= y <= 2).
    def f(x: float) -> float:
        return x * x - 2.0

    a, b = 1.0, 2.0
    omega = lambda e: e / 4.0  # 4-Lipschitz on [1, 2]
    c = 2.0                    # slope bound
    root = math.sqrt(2.0)

    print("f(x) = x^2 - 2 on [1, 2];  modulus omega(eps) = eps/4;  slope bound c = 2.")
    print("Exact root:  sqrt(2) = %.12f" % root)
    print()
    print("Approximate IVT (value accuracy eps):")
    print("     eps    |    N   |     x found    |    |f(x)|    | <= eps?")
    print("  " + "-" * 68)
    for eps in [1e-1, 1e-2, 1e-3, 1e-4]:
        N, x, fx = approximate_ivt(f, a, b, omega, eps)
        print(f"  {eps:.1e} | {N:6d} | {x:.12f} | {abs(fx):.3e} | {abs(fx) <= eps}")
    print()

    print("Exact IVT via the root modulus  delta -> omega(c*delta),")
    print("using the sharp conversion  |x - r| <= |f(x)| / c :")
    print("    delta   |    N   |     x found    |   |x - r|   | <= delta?")
    print("  " + "-" * 68)
    for delta in [1e-1, 1e-2, 1e-3, 1e-4]:
        N, x = constructive_ivt(f, a, b, omega, c, delta)
        print(f"  {delta:.1e} | {N:6d} | {x:.12f} | {abs(x-root):.3e} "
              f"| {abs(x - root) <= delta}")
    print()

    print("Sharpness of the constant eps/c:  for f(x) = c*x on [-1, 1] with root 0,")
    print("the point x = eps/c has |f(x)| = eps and |x - 0| = eps/c EXACTLY.")
    for cc, ee in [(1.0, 0.5), (2.0, 0.25), (0.5, 0.5)]:
        xx = ee / cc
        print(f"    c = {cc:4.2f}, eps = {ee:4.2f}:  |f(x)| = {abs(cc*xx):.4f},"
              f"  |x - r| = {abs(xx):.4f},  eps/c = {ee/cc:.4f}")
    print("  So no factor kappa < 1 can improve the bound.")
    print()

    print("Bracketing (NO non-degeneracy hypothesis): the sign-change search")
    print("lands within one mesh of a genuine root.")
    print("       N |  mesh (b-a)/N |  |x - r|   | within one mesh?")
    print("  " + "-" * 62)
    for N in [8, 64, 512, 4096]:
        k = grid_search(f, a, b, N)
        x = grid(a, b, N, k)
        mesh = (b - a) / N
        print(f"  {N:6d} | {mesh:.10f} | {abs(x-root):.3e} | {abs(x-root) <= mesh}")


def demo_shelf() -> None:
    line("6.  The shelf family: the exact IVT has no effective solution")
    print("S_t(x) = min(x - 1, max(t, x - 2))  on [0, 3],  1-Lipschitz for every t,")
    print("with S_t(0) <= 0 <= S_t(3).  The approximate IVT applies uniformly in t.")
    print()
    print("      t     | exact root(s) | approx root (N=3000) | |S_t| at that point")
    print("  " + "-" * 76)
    for t in [1.0, 0.1, 0.01, 0.001, 0.0, -0.001, -0.01, -0.1, -1.0]:
        N = 3000
        k = grid_search(lambda x, t=t: shelf(t, x), 0.0, 3.0, N)
        x = grid(0.0, 3.0, N, k)
        exact = "all of [1,2]" if t == 0.0 else f"{shelf_exact_root(t):.4f}"
        print(f"  {t:+9.4f} | {exact:>13s} | {x:20.6f} "
              f"| {abs(shelf(t, x)):.3e}")
    print()
    print("The APPROXIMATE root is found effectively for every t (all |S_t| tiny).")
    print("The EXACT root jumps from 1 to 2 as t crosses 0 -- no continuous rule")
    print("can track it, and since every constructive function is continuous, no")
    print("constructive rule can either.")
    print()
    print("Quantitative failure: EVERY selector, continuous or not, has")
    print("oscillation at least 1 on every window |t| <= eta.")
    print("      eta    | r(+min(eta,1)) | r(-min(eta,1)) | oscillation >= ")
    print("  " + "-" * 68)
    for eta in [1.0, 0.1, 1e-3, 1e-6, 1e-12]:
        s = min(eta, 1.0)
        lo, hi = shelf_exact_root(s), shelf_exact_root(-s)
        print(f"  {eta:.1e} | {lo:14.1f} | {hi:14.1f} | {abs(hi-lo):.1f}")
    print()
    print("And the missing hypothesis is identified exactly: S_0 is constant on")
    print("[1, 2], so it admits no positive slope bound --")
    print(f"    S_0(1) = {shelf(0.0, 1.0)},  S_0(2) = {shelf(0.0, 2.0)}"
          "  =>  c * 1 <= 0.")


def demo_dip() -> None:
    line("7.  Local non-constancy is not enough")
    print("D_eta(x) = min(x - 1, |x - 3| + eta)  on [0, 4]:  1-Lipschitz, unique")
    print("root x = 1, local non-constancy with the explicit modulus nu(h) = h/8.")
    print()
    print("     delta  |    eta    |  |D(3)|  |  nu(delta)/2 |  distance 3 to root")
    print("  " + "-" * 74)
    for delta in [1.0, 0.5, 0.1, 0.01]:
        eta = delta / 32.0
        print(f"  {delta:8.4f} | {eta:9.6f} | {abs(dip(eta, 3.0)):.6f} "
              f"| {delta/16:12.6f} | {abs(3.0 - 1.0):.1f}")
    print()
    print("The value at x = 3 is as small as one likes, yet x = 3 is at distance 2")
    print("from the only root.  So 'small |f|' does NOT imply 'near a root' under")
    print("local non-constancy alone: the slope bound is genuinely needed.")
    print()
    print("Verification of local non-constancy nu(h) = h/8 by sampling intervals:")
    eta = 0.01
    worst = None
    for i in range(400):
        p = 4.0 * i / 400.0
        for h in [0.05, 0.2, 1.0]:
            q = min(4.0, p + h)
            if q - p < h - 1e-12:
                continue
            best = max(abs(dip(eta, p + j * (q - p) / 60.0)) for j in range(61))
            ratio = best / (h / 8.0)
            if worst is None or ratio < worst:
                worst = ratio
    print(f"  minimum observed  max|D| / nu(h)  over sampled intervals: {worst:.3f}")
    print("  (>= 1 everywhere, as the theorem asserts)")


def demo_located_sup() -> None:
    line("8.  Located suprema: trisection is not optimal, and 1/2 is the barrier")
    c = Q(1, 2)
    L = located_iic(c)
    a0, b0 = Q(0), Q(1)

    print(f"Set S = (-inf, {c}], oracle L(p, q) = (c <= q), initial bracket [0, 1].")
    print()
    print("Bishop's trisection  (alpha, beta) = (1/3, 2/3):")
    tri = search(Q(1, 3), Q(2, 3), L, a0, b0, 10)
    for n, (p, q) in enumerate(tri[:5]):
        print(f"    n = {n}: [{str(p):>9s}, {str(q):>9s}]   width = {q - p}"
              f"   contains 1/2: {p < c <= q}")
    p, q = tri[10]
    print(f"    n = 10: width = {q-p} = (2/3)^10 = {Q(2,3)**10}"
          f"   exact: {q - p == Q(2,3)**10}")
    print()

    print("The faster scheme  (alpha, beta) = (2/5, 1/2):")
    fast = search(Q(2, 5), Q(1, 2), L, a0, b0, 10)
    for n, (p, q) in enumerate(fast[:5]):
        print(f"    n = {n}: [{str(p):>11s}, {str(q):>11s}]   width = {q - p}"
              f"   contains 1/2: {p < c <= q}")
    p, q = fast[10]
    print(f"    n = 10: width = {float(q-p):.8f} <= (3/5)^10 = {float(Q(3,5)**10):.8f}"
          f"   holds: {q - p <= Q(3,5)**10}")
    print()

    print("Contraction factors  max(beta, 1 - alpha):")
    print("     alpha  |  beta   | factor  | factor^10  | note")
    print("  " + "-" * 68)
    schemes = [
        (Q(1, 3), Q(2, 3), "Bishop's trisection"),
        (Q(2, 5), Q(1, 2), "strictly faster"),
        (Q(9, 20), Q(1, 2), "closer to the barrier"),
        (Q(49, 100), Q(1, 2), "closer still"),
        (Q(499, 1000), Q(1, 2), "approaching 1/2"),
    ]
    for alpha, beta, note in schemes:
        fct = contraction_factor(alpha, beta)
        print(f"  {str(alpha):>8s} | {str(beta):>7s} | {float(fct):.5f} "
              f"| {float(fct**10):.3e} | {note}")
    print()
    print(f"Every factor is strictly greater than 1/2: "
          f"{all(contraction_factor(a, b) > Q(1,2) for a, b, _ in schemes)}")
    print("but the infimum 1/2 is approached: taking alpha = 1/2 - t/2, beta = 1/2 + t/2")
    print("gives factor 1/2 + t/2, below 1/2 + eta for any eta > 0.")
    print()
    print("Oracle calls to reach accuracy tau, starting from width 1:")
    print("        tau    | trisection (2/3) | faster (3/5) | calls saved")
    print("  " + "-" * 66)
    for tau in [1e-3, 1e-6, 1e-9, 1e-12]:
        n23 = math.ceil(math.log(tau) / math.log(2 / 3))
        n35 = math.ceil(math.log(tau) / math.log(3 / 5))
        print(f"  {tau:.1e} | {n23:16d} | {n35:12d} | {n23 - n35:11d}")
    print()
    print("The reason 1/2 cannot be reached: a legitimate query needs alpha < beta,")
    print("so the 'true' region [0, beta] and the 'false' region [alpha, 1] overlap")
    print("in [alpha, beta].  That overlap is the price of the oracle's freedom to")
    print("answer either way in the ambiguous zone, and it is never zero.")


def main() -> None:
    print(__doc__)
    demo_regular_sequences()
    demo_arithmetic()
    demo_completeness()
    demo_order()
    demo_ivt()
    demo_shelf()
    demo_dip()
    demo_located_sup()
    line("Summary")
    print("Every theorem in this development carries a number, and the numbers")
    print("above are those numbers:")
    print("  * approximation error of the n-th term:      exactly 1/(n+1)")
    print("  * completeness diagonal:                     shift 2n+1, necessary")
    print("  * root modulus under slope bound c:          eps/c, attained")
    print("  * location accuracy of the sign search:      one mesh, no hypotheses")
    print("  * shelf-selector oscillation near t = 0:     at least 1, always")
    print("  * one-query supremum contraction:            max(beta, 1 - alpha)")
    print("  * best possible one-query contraction:       infimum 1/2, unattained")
    print()


if __name__ == "__main__":
    main()
