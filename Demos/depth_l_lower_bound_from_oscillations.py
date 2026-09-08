"""
Oscillation counting and the depth-width trade-off for rectifier networks
=========================================================================

Numerical demonstrations of the results of the accompanying paper.

Everything is self-contained: pure Python, exact rational arithmetic where it
matters (via `fractions.Fraction`), no third-party dependencies.

The objects
-----------
    relu(t)          = max(t, 0)
    tau(y)           = 2 relu(y) - 4 relu(y - 1/2) + 2 relu(y - 1)      (tent map)
    tau_iter(k, y)   = tau applied k times                              (sawtooth tower)

The results demonstrated
------------------------
    1.  tau^k alternates between 0 and 1 at the 2^k + 1 dyadic points i/2^k.
    2.  Knot budget:  a depth-L, width-w network has at most kappa(w, L) knots,
        and kappa(w, L) + 2 <= 2 (2w + 2)^L.
    3.  Master inequality:  a depth-L, width-w network within 1/4 of tau^k on
        [0,1] forces 2^k <= 4 (2w+2)^L.
    4.  Depth separation:  with k = L^2 + 4 the width must be >= 2^(L-1) - 1,
        while tau^k itself is a width-3 network of depth k.
    5.  Collapse:  tau(tau(y)) is ONE relu layer of width 5, and more generally
        tau^c is one relu layer of width 2^c + 1.
    6.  Tower-height bracket:  at depth L and width 2^c + 1 the exactly
        computable tower height k satisfies cL <= k <= (c+3)L + 2.
    7.  L^1 separation:  integrated error >= (2^(k-1) - |S|) / (16 * 2^k).
    8.  Density of failure:  a piecewise affine function with |S| knots is wrong
        by more than 1/4 at >= (2^k - 2)/3 - |S| of the dyadic sample points.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Num = Fraction


# ----------------------------------------------------------------------------
# 1. The primitives
# ----------------------------------------------------------------------------

def relu(t: Num) -> Num:
    """Rectified linear unit: max(t, 0)."""
    return t if t > 0 else Fraction(0)


def tau(y: Num) -> Num:
    """The tent map, written exactly as a width-3 rectifier layer."""
    return (2 * relu(y)
            - 4 * relu(y - Fraction(1, 2))
            + 2 * relu(y - 1))


def tau_iter(k: int, y: Num) -> Num:
    """The sawtooth tower tau^k (k-fold composite of the tent map)."""
    out = Fraction(y)
    for _ in range(k):
        out = tau(out)
    return out


def dyad_coef(c: int, i: int) -> Num:
    """Coefficient a_i^{(c)} of the single-layer realisation of tau^c."""
    if i == 0 or i == 2 ** c:
        return Fraction(2 ** c)
    return Fraction((-1) ** i * 2 ** (c + 1))


def tower_one_layer(c: int, y: Num) -> Num:
    """One rectifier layer of width 2^c + 1 that computes tau^c exactly."""
    return sum((dyad_coef(c, i) * relu(y - Fraction(i, 2 ** c))
                for i in range(2 ** c + 1)), Fraction(0))


# ----------------------------------------------------------------------------
# 2. Knot budgets and the master inequality
# ----------------------------------------------------------------------------

def knot_budget(w: int, L: int) -> int:
    """kappa(w, L): kappa(w,0) = 0, kappa(w,L+1) = w (2 kappa(w,L) + 4)."""
    k = 0
    for _ in range(L):
        k = w * (2 * k + 4)
    return k


def knot_budget_closed_form(w: int, L: int) -> int:
    """The closed-form majorant 2 (2w + 2)^L of kappa(w, L) + 2."""
    return 2 * (2 * w + 2) ** L


def approximation_is_impossible(w: int, L: int, k: int) -> bool:
    """True iff 2^k > 4 (2w+2)^L, i.e. no depth-L width-w network of ANY weights
    can stay within 1/4 of tau^k on [0,1]."""
    return 2 ** k > 4 * (2 * w + 2) ** L


def min_width_forced(L: int) -> int:
    """The width lower bound 2^(L-1) - 1 for approximating tau^(L^2+4) at depth L."""
    return 2 ** (L - 1) - 1


# ----------------------------------------------------------------------------
# 3. Piecewise affine utilities used by the checks
# ----------------------------------------------------------------------------

def count_knots(f: Callable[[Num], Num], breakpoints: Sequence[Num]) -> int:
    """Count slope changes of a piecewise affine f, sampling midpoints of the
    intervals cut out by `breakpoints` (assumed to include all true knots)."""
    slopes: List[Num] = []
    for a, b in zip(breakpoints, breakpoints[1:]):
        mid_l = a + (b - a) / 4
        mid_r = b - (b - a) / 4
        slopes.append((f(mid_r) - f(mid_l)) / (mid_r - mid_l))
    return sum(1 for s, t in zip(slopes, slopes[1:]) if s != t)


def l1_error(f: Callable[[Num], Num], g: Callable[[Num], Num],
             grid: Sequence[Num]) -> Num:
    """Trapezoidal integral of |f - g| over the given (piecewise-affine-aware) grid.

    Exact when the grid refines the knot set of both functions, because then
    |f - g| is affine on each cell up to at most one sign change; we subdivide
    each cell once to control that.
    """
    total = Fraction(0)
    for a, b in zip(grid, grid[1:]):
        m = (a + b) / 2
        for u, v in ((a, m), (m, b)):
            fa, fb = abs(f(u) - g(u)), abs(f(v) - g(v))
            total += (v - u) * (fa + fb) / 2
    return total


def dyadic_grid(k: int) -> List[Num]:
    """The 2^k + 1 dyadic points i / 2^k of [0, 1]."""
    return [Fraction(i, 2 ** k) for i in range(2 ** k + 1)]


# ----------------------------------------------------------------------------
# 4. The demonstrations
# ----------------------------------------------------------------------------

def demo_alternation(max_k: int = 8) -> None:
    print("=" * 74)
    print("1.  tau^k alternates between 0 and 1 at the dyadic points i/2^k")
    print("=" * 74)
    for k in range(1, max_k + 1):
        ok = all(tau_iter(k, Fraction(i, 2 ** k)) == (i % 2)
                 for i in range(2 ** k + 1))
        print(f"    k = {k:2d}:  2^k + 1 = {2**k + 1:4d} points checked -> "
              f"{'alternation confirmed' if ok else 'FAILED'}")
    print()


def demo_knot_growth(max_k: int = 8) -> None:
    print("=" * 74)
    print("2.  The tower tau^k really has 2^k affine pieces (2^k - 1 knots)")
    print("=" * 74)
    print(f"    {'k':>3} {'knots found':>12} {'2^k - 1':>10}")
    for k in range(1, max_k + 1):
        grid = dyadic_grid(k)
        n = count_knots(lambda y, k=k: tau_iter(k, y), grid)
        print(f"    {k:>3} {n:>12} {2**k - 1:>10}")
    print()


def demo_budget_table(widths: Sequence[int] = (1, 3, 5, 10),
                      depths: Sequence[int] = (1, 2, 3, 4, 5)) -> None:
    print("=" * 74)
    print("3.  Knot budget kappa(w,L) versus its closed form 2(2w+2)^L")
    print("=" * 74)
    print(f"    {'w':>3} {'L':>3} {'kappa(w,L)':>14} {'2(2w+2)^L':>16}  ok?")
    for w in widths:
        for L in depths:
            k = knot_budget(w, L)
            c = knot_budget_closed_form(w, L)
            print(f"    {w:>3} {L:>3} {k:>14} {c:>16}  {k + 2 <= c}")
    print()


def demo_separation_table(max_L: int = 10) -> None:
    print("=" * 74)
    print("4.  Depth separation for the witness tau^(L^2+4)")
    print("=" * 74)
    print(f"    {'L':>3} {'k = L^2+4':>10} {'deep size 3k':>13} "
          f"{'width >= 2^(L-1)-1':>20} {'shallow size':>14}")
    for L in range(1, max_L + 1):
        k = L * L + 4
        w = min_width_forced(L)
        print(f"    {L:>3} {k:>10} {3 * k:>13} {w:>20} {L * w:>14}")
    print("\n    The deep witness costs O(L^2) neurons; any depth-L approximator")
    print("    within 1/4 needs at least L (2^(L-1) - 1) neurons.\n")


def demo_certified_infeasibility() -> None:
    print("=" * 74)
    print("5.  Certified non-existence (no weights whatsoever can succeed)")
    print("=" * 74)
    cases: List[Tuple[int, int, int]] = [(5, 3, 13), (5, 3, 40), (50, 2, 30),
                                         (1000, 2, 60), (3, 29, 85)]
    for w, L, k in cases:
        verdict = ("IMPOSSIBLE" if approximation_is_impossible(w, L, k)
                   else "not excluded by the counting bound")
        print(f"    depth {L:>3}, width {w:>5}, target tau^{k:<3} : {verdict}")
    print()


def demo_collapse(samples: int = 401) -> None:
    print("=" * 74)
    print("6.  Collapse: tau^c is ONE rectifier layer of width 2^c + 1")
    print("=" * 74)
    for c in range(1, 6):
        worst = Fraction(0)
        for j in range(samples):
            y = Fraction(j, samples - 1)
            worst = max(worst, abs(tower_one_layer(c, y) - tau_iter(c, y)))
        coeffs = [dyad_coef(c, i) for i in range(2 ** c + 1)]
        shown = coeffs if len(coeffs) <= 9 else coeffs[:5] + ["..."]
        print(f"    c = {c}: width {2**c + 1:>3}, max |one-layer - tau^c| = {float(worst):.1e}")
        print(f"           coefficients {shown}")
    print("\n    Consequence: tau^(L+1) is an EXACT depth-L width-5 network,")
    print("    so the one-step form of the separation conjecture fails.\n")


def demo_bracket(max_L: int = 6) -> None:
    print("=" * 74)
    print("7.  Tower-height bracket at depth L and width 2^c + 1:  cL <= k <= (c+3)L+2")
    print("=" * 74)
    print(f"    {'c':>3} {'width':>7} {'L':>3} {'achieved cL':>12} {'max allowed':>13}")
    for c in (1, 2, 3):
        for L in range(1, max_L + 1):
            print(f"    {c:>3} {2**c + 1:>7} {L:>3} {c * L:>12} {(c + 3) * L + 2:>13}")
    print("\n    Achievability check (exact composition of one-layer towers):")
    for c in (1, 2):
        for L in (1, 2, 3):
            ok = True
            for j in range(0, 65):
                y = Fraction(j, 64)
                z = y
                for _ in range(L):
                    z = tower_one_layer(c, z)
                ok = ok and (z == tau_iter(c * L, y))
            print(f"        c={c}, L={L}: depth-{L} width-{2**c+1} net equals "
                  f"tau^{c*L} on the grid -> {ok}")
    print()


def demo_l1_and_density(k: int = 10, shallow_height: int = 4) -> None:
    print("=" * 74)
    print("8.  L^1 error and density of failure for a genuinely shallow model")
    print("=" * 74)
    target = lambda y: tau_iter(k, y)
    # A concrete "shallow" competitor: the tower of much smaller height, which is
    # itself an exact network of small depth. It has 2^shallow_height - 1 knots.
    approx = lambda y: tau_iter(shallow_height, y)
    S = 2 ** shallow_height - 1

    grid = dyadic_grid(k + 1)          # refine so both are affine on each cell
    err = l1_error(approx, target, grid)
    bound = Fraction(2 ** (k - 1) - S, 16 * 2 ** k)
    print(f"    target tau^{k}, competitor tau^{shallow_height} with |S| = {S} knots")
    print(f"    measured  int_0^1 |f - tau^k| = {float(err):.6f}")
    print(f"    guaranteed lower bound        = {float(bound):.6f}"
          f"   ({'satisfied' if err >= bound else 'VIOLATED'})")

    bad = sum(1 for i in range(2 ** k + 1)
              if abs(approx(Fraction(i, 2 ** k)) - target(Fraction(i, 2 ** k)))
              > Fraction(1, 4))
    guaranteed = Fraction(2 ** k - 2, 3) - S
    print(f"    bad dyadic points: {bad} out of {2**k + 1} "
          f"(fraction {bad / (2 ** k + 1):.3f})")
    print(f"    guaranteed at least {float(guaranteed):.1f} "
          f"({'satisfied' if bad >= guaranteed else 'VIOLATED'})")
    print()


def demo_oscillation_receipt(k: int = 6) -> None:
    print("=" * 74)
    print("9.  Oscillation is a receipt for knots: 2^k <= 2|S| + 1")
    print("=" * 74)
    for kk in range(1, k + 1):
        grid = dyadic_grid(kk)
        S = count_knots(lambda y, kk=kk: tau_iter(kk, y), grid)
        print(f"    k = {kk}: knots |S| = {S:>3}, "
              f"2^k = {2**kk:>3} <= 2|S| + 1 = {2 * S + 1:>3}  -> {2**kk <= 2*S+1}")
    print()


def main() -> None:
    print()
    print("Oscillation counting and the depth-width trade-off for rectifier networks")
    print()
    demo_alternation()
    demo_knot_growth()
    demo_budget_table()
    demo_separation_table()
    demo_certified_infeasibility()
    demo_collapse()
    demo_bracket()
    demo_l1_and_density()
    demo_oscillation_receipt()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
