#!/usr/bin/env python3
"""
Divisibility is a rate dial, not a position dial
================================================

Numerical demonstration of the results of the accompanying paper.

Setting.  A sieve scans the polynomial values v(j) = j^2 - N over a window of
consecutive j and records which values are smooth.  A Dickman-weighted
reference profile B(t) predicts the hit density at normalized window position
t in [0, 1].  The measured residual R(t) = T(t)/B(t) shows a mid-window peak of
relative amplitude 0.1774 +- 0.0432 at t = 0.65.

The corrective model under test stratifies candidates by the divisibility
pattern (2|v, 3|v, 5|v, 7|v) -- 16 cells -- and gives each cell its own free
rate kappa_c, fitting on the flanks only:

    PRED(t) = sum_c kappa_c * S_c(t).

This script demonstrates, numerically:

  1. The divisibility cell of j^2 - N is 210-periodic in j.
  2. Every window of 210 consecutive j has *identical* cell populations
     (flat composition), at every window start, for every N.
  3. The per-cell rates are nonetheless strongly modulated (0, 1/p or 2/p
     according to the Legendre symbol of N mod p).
  4. Flat composition collapses the 16-parameter mixture family onto the ray
     {K * B}: the fitted mixture is a scalar multiple of B, so the residual
     excess and its argmax are exactly invariant and removal is exactly 0%.
  5. The robust drift bound: with drift delta, the excess ratio rho shrinks by
     at most (1-delta)/(1+delta); absorbing rho - 1 needs delta >= (rho-1)/(rho+1).
  6. The whole residue family dies: Legendre-symbol carriers at p > 7 and
     bit-pattern carriers are periodic too, so they also remove 0%.
  7. Sharpness: a positional reference family removes 100% of the same excess,
     and the aperiodic step carrier has maximal composition drift.

Pure standard library: no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple

Cell = Tuple[bool, bool, bool, bool]

SMALL_PRIMES: Tuple[int, int, int, int] = (2, 3, 5, 7)
GRID_PERIOD: int = 210  # 2 * 3 * 5 * 7


# ---------------------------------------------------------------------------
# 1.  The divisibility grid
# ---------------------------------------------------------------------------

def cell_of(v: int) -> Cell:
    """Divisibility pattern of v with respect to 2, 3, 5, 7 (one of 16 cells)."""
    return (v % 2 == 0, v % 3 == 0, v % 5 == 0, v % 7 == 0)


def cell(n: int, j: int) -> Cell:
    """The cell of the sieve value v = j^2 - N."""
    return cell_of(j * j - n)


def window_count(n: int, a: int, length: int = GRID_PERIOD) -> Dict[Cell, int]:
    """Cell populations of the window {a, a+1, ..., a+length-1}."""
    counts: Dict[Cell, int] = {}
    for i in range(length):
        c = cell(n, a + i)
        counts[c] = counts.get(c, 0) + 1
    return counts


def demo_periodicity(n: int = 8051) -> None:
    print("=" * 78)
    print("1.  The cell label of j^2 - N is 210-periodic in j")
    print("=" * 78)
    ok = all(cell(n, j) == cell(n, j + GRID_PERIOD) for j in range(-500, 500))
    print(f"    N = {n}")
    print("    cell(j + 210) == cell(j) for all j in [-500, 500):", ok)
    print("    reason: (j+210)^2 - N = (j^2 - N) + 210*(2j + 210),")
    print("            and 210 = 2*3*5*7 is divisible by each of 2, 3, 5, 7.")
    print()


def demo_flat_composition(n: int = 8051) -> None:
    print("=" * 78)
    print("2.  Flat composition: window populations do not depend on position")
    print("=" * 78)
    starts = [0, 1, 7, 1234, -77777, 10**6 + 3]
    base = window_count(n, 0)
    same = all(window_count(n, a) == base for a in starts)
    print(f"    N = {n} = 83 * 97   (odd; 8051 = 2 mod 3, a quadratic non-residue)")
    print(f"    identical cell populations at starts {starts}: {same}")
    print()
    print("    cell (2|v, 3|v, 5|v, 7|v)      population in every 210-window")
    print("    " + "-" * 62)
    total = 0
    for c in sorted(base, key=lambda t: (t[0], t[1], t[2], t[3])):
        bits = "(" + ", ".join("1" if b else "0" for b in c) + ")"
        print(f"    {bits:<32} {base[c]:>6}")
        total += base[c]
    print(f"    {'TOTAL':<32} {total:>6}")
    empty_three = [c for c in base if c[1]]
    print(f"    cells with 3|v that are nonempty: {empty_three}  (none: 3 is dead)")
    odd_j = sum(v for c, v in base.items() if c[0])
    print(f"    candidates with 2|v (equivalently, odd j since N is odd): {odd_j}")
    print()


def demo_rate_modulation(n: int = 8051) -> None:
    print("=" * 78)
    print("3.  The rates ARE real: quadratic-residue modulation of each prime")
    print("=" * 78)
    print("    #{j mod p : j^2 = N mod p} = 1 + legendre(N, p) in {0, 1, 2}")
    print()
    print("    p     roots of j^2 = N (mod p)     rate of p | v")
    print("    " + "-" * 54)
    for p in (2, 3, 5, 7, 11, 13):
        roots = sum(1 for j in range(p) if (j * j - n) % p == 0)
        print(f"    {p:<5} {roots:<28} {roots}/{p} = {roots / p:.4f}")
    print()
    print("    So divisibility genuinely modulates HOW MANY smooth values appear")
    print("    (a rate of exactly 0 for p = 3 here).  Section 2 shows it says")
    print("    nothing at all about WHERE they appear.")
    print()


# ---------------------------------------------------------------------------
# 2.  The mixture baseline collapses to a ray
# ---------------------------------------------------------------------------

def dickman_rho(u: float, steps: int = 4000) -> float:
    """Dickman rho(u) by numerical integration of u*rho'(u) = -rho(u-1)."""
    if u <= 0.0:
        return 0.0
    if u <= 1.0:
        return 1.0
    grid_max = max(2.0, math.ceil(u) + 1.0)
    h = grid_max / steps
    vals = [1.0 if i * h <= 1.0 else 0.0 for i in range(steps + 1)]

    def interp(x: float) -> float:
        if x <= 0.0:
            return 0.0
        if x <= 1.0:
            return 1.0
        k = x / h
        i = int(k)
        if i >= steps:
            return vals[steps]
        frac = k - i
        return vals[i] * (1.0 - frac) + vals[i + 1] * frac

    for i in range(1, steps + 1):
        x = i * h
        if x <= 1.0:
            continue
        # rho(x) = rho(x-h) - (h / x) * rho(x - 1)   (midpoint-free Euler step)
        vals[i] = vals[i - 1] - (h / x) * interp(x - 1.0)
        if vals[i] < 0.0:
            vals[i] = 0.0
    return interp(u)


def base_shape(t: float) -> float:
    """A Dickman-weighted reference shape B(t): smooth, featureless, decreasing."""
    u = 2.0 + 0.8 * t          # u grows mildly across the window
    return dickman_rho(u)


def measured_profile(t: float, amp: float = 0.1774, peak: float = 0.65,
                     width: float = 0.10) -> float:
    """A synthetic measurement: the shape B times a mid-window bump."""
    bump = 1.0 + amp * math.exp(-0.5 * ((t - peak) / width) ** 2)
    return base_shape(t) * bump


def cell_refs(n: int, grid: Sequence[float]) -> Dict[Cell, List[float]]:
    """Per-cell reference sums S_c(t) = (population of cell c) * B(t).

    The populations are the exact 210-window populations, which by flat
    composition do not depend on t at all -- this is the whole point.
    """
    pops = window_count(n, 0)
    return {c: [pops[c] * base_shape(t) for t in grid] for c in pops}


def fit_rates_on_flanks(grid: Sequence[float], target: Sequence[float],
                        refs: Dict[Cell, List[float]],
                        score_lo: float = 0.45, score_hi: float = 0.85,
                        lam: float = 5.0) -> Dict[Cell, float]:
    """Ridge-shrunk least-squares fit of the per-cell rates on the flanks only.

    Because the design matrix has rank 1 under flat composition, the fit is
    solved here in the equivalent well-posed form: shrink every rate toward a
    common value g determined by the flank ratio.  (Any solver returns a point
    on the same one-dimensional solution ray; this one picks the ridge minimum.)
    """
    flank = [i for i, t in enumerate(grid) if not (score_lo <= t <= score_hi)]
    pops = {c: refs[c][0] / base_shape(grid[0]) for c in refs}
    total_pop = sum(pops.values())
    num = sum(target[i] * base_shape(grid[i]) * total_pop for i in flank)
    den = sum((base_shape(grid[i]) * total_pop) ** 2 for i in flank)
    g = num / den if den else 0.0
    # ridge shrinkage toward g leaves every rate at g on a rank-1 design
    _ = lam
    return {c: g for c in refs}


def mix_pred(rates: Dict[Cell, float], refs: Dict[Cell, List[float]],
             n_pts: int) -> List[float]:
    return [sum(rates[c] * refs[c][i] for c in refs) for i in range(n_pts)]


def rel_excess(resid: Sequence[float], i0: int, i1: int) -> float:
    return resid[i0] / resid[i1] - 1.0


def demo_collapse_and_zero_removal(n: int = 8051, n_pts: int = 201) -> None:
    print("=" * 78)
    print("4.  Collapse to a ray  =>  removal is exactly 0%")
    print("=" * 78)
    grid = [i / (n_pts - 1) for i in range(n_pts)]
    target = [measured_profile(t) for t in grid]
    b_vals = [base_shape(t) for t in grid]
    refs = cell_refs(n, grid)

    rates = fit_rates_on_flanks(grid, target, refs)
    pred = mix_pred(rates, refs, n_pts)

    # the mixture is a scalar multiple of B, to machine precision
    ratios = [pred[i] / b_vals[i] for i in range(n_pts)]
    spread = max(ratios) - min(ratios)
    print(f"    16-cell mixture PRED(t)/B(t):  min {min(ratios):.10f}"
          f"  max {max(ratios):.10f}")
    print(f"    spread over the whole window:  {spread:.3e}   (a constant K)")

    i0 = min(range(n_pts), key=lambda i: abs(grid[i] - 0.65))
    i1 = min(range(n_pts), key=lambda i: abs(grid[i] - 0.05))

    resid_b = [target[i] / b_vals[i] for i in range(n_pts)]
    resid_m = [target[i] / pred[i] for i in range(n_pts)]
    exc_b = rel_excess(resid_b, i0, i1)
    exc_m = rel_excess(resid_m, i0, i1)
    print()
    print(f"    relative excess over the plain shape B :  {exc_b:.10f}")
    print(f"    relative excess over the 16-cell mixture: {exc_m:.10f}")
    print(f"    removal fraction                        : {exc_m - exc_b:.3e}"
          "   (exactly 0)")

    argmax_b = max(range(n_pts), key=lambda i: resid_b[i])
    argmax_m = max(range(n_pts), key=lambda i: resid_m[i])
    print(f"    peak position over B      : t = {grid[argmax_b]:.4f}")
    print(f"    peak position over mixture: t = {grid[argmax_m]:.4f}   (unmoved)")
    print()


# ---------------------------------------------------------------------------
# 3.  The robust drift bound
# ---------------------------------------------------------------------------

def surviving_excess_lower_bound(rho: float, delta: float) -> float:
    """Lower bound on the mixture-residual excess ratio: rho*(1-delta)/(1+delta)."""
    return rho * (1.0 - delta) / (1.0 + delta)


def required_drift(rho: float) -> float:
    """Drift budget: absorbing a relative excess rho - 1 requires this drift."""
    return (rho - 1.0) / (rho + 1.0)


def demo_drift_budget() -> None:
    print("=" * 78)
    print("5.  Robust form: the drift budget")
    print("=" * 78)
    rho = 1.1774
    measured_delta = 0.00269
    se_registered = 0.0432
    se_calibrated = 0.0411

    surviving = surviving_excess_lower_bound(rho, measured_delta) - 1.0
    need = required_drift(rho)
    print(f"    raw excess ratio            rho     = {rho:.4f}"
          f"   (amplitude {rho - 1:.4f})")
    print(f"    measured composition drift  delta   = {measured_delta:.5f}"
          f"   ({100 * measured_delta:.3f}%)")
    print(f"    guaranteed surviving excess         >= {surviving:.4f}")
    print(f"    registered bar 2*SE                 =  {2 * se_registered:.4f}"
          f"   -> cleared: {surviving > 2 * se_registered}")
    print(f"    null-calibrated 2*SE                =  {2 * se_calibrated:.4f}"
          f"   -> cleared: {surviving > 2 * se_calibrated}")
    print()
    print(f"    drift required to absorb it entirely: (rho-1)/(rho+1) ="
          f" {need:.4f}  ({100 * need:.1f}%)")
    print(f"    ratio required / measured           : {need / measured_delta:.1f}x")
    print()
    print("    delta      max shrinkage factor    surviving excess")
    print("    " + "-" * 56)
    for d in (0.0, 0.001, 0.00269, 0.01, 0.05, 0.081, 0.15):
        factor = (1.0 - d) / (1.0 + d)
        print(f"    {d:<10.5f} {factor:<22.6f} {rho * factor - 1:.6f}")
    print()


# ---------------------------------------------------------------------------
# 4.  The whole residue family
# ---------------------------------------------------------------------------

def legendre_carrier(n: int, p: int) -> Callable[[int], int]:
    """Quadratic-character carrier j -> chi_p(j^2 - N), values in {-1, 0, 1}."""
    def f(j: int) -> int:
        v = (j * j - n) % p
        if v == 0:
            return 0
        return 1 if pow(v, (p - 1) // 2, p) == 1 else -1
    return f


def bit_carrier(n: int, k: int) -> Callable[[int], int]:
    """Low-k-bit carrier j -> (j^2 - N) mod 2^k."""
    m = 1 << k
    return lambda j: (j * j - n) % m


def class_counts(f: Callable[[int], int], a: int, length: int) -> Dict[int, int]:
    counts: Dict[int, int] = {}
    for i in range(length):
        c = f(a + i)
        counts[c] = counts.get(c, 0) + 1
    return counts


def max_relative_drift(f: Callable[[int], int], starts: Sequence[int],
                       length: int) -> float:
    tables = [class_counts(f, a, length) for a in starts]
    classes = set().union(*tables)
    worst = 0.0
    for c in classes:
        vals = [t.get(c, 0) for t in tables]
        lo, hi = min(vals), max(vals)
        worst = max(worst, (hi - lo) / max(1, lo))
    return worst


def demo_residue_family(n: int = 8051) -> None:
    print("=" * 78)
    print("6.  The entire residue family is flat, hence removes 0%")
    print("=" * 78)
    starts = [0, 1, 500, -4321, 98765]
    print("    carrier                          period   window   max drift")
    print("    " + "-" * 66)
    for p in (11, 13, 17, 23):
        f = legendre_carrier(n, p)
        drift = max_relative_drift(f, starts, length=p * 40)
        print(f"    Legendre chi_{p}(j^2 - N){'':<12} {p:<8} {p * 40:<8} {drift:.3e}")
    for k in (3, 4, 5):
        f = bit_carrier(n, k)
        m = 1 << k
        drift = max_relative_drift(f, starts, length=m * 40)
        print(f"    low {k} bits of (j^2 - N){'':<11} {m:<8} {m * 40:<8} {drift:.3e}")
    print()
    print("    Every classifier factoring through Z/mZ is m-periodic, because")
    print("    (j+m)^2 - N = j^2 - N (mod m).  Flat composition on any window")
    print("    length that is a multiple of m; hence a rank-1 mixture; hence 0%.")
    print()
    print("    Incommensurate windows: two windows of length L differ in any")
    print("    class population by at most L mod m, a relative drift below m/L.")
    print("    Absorbing the measured excess needs 8.1% drift, so it needs")
    print("    m / L >= 0.081 -- a period comparable to the whole window.")
    print()
    print("    modulus m   window L   bound m/L   can absorb 8.1%?")
    print("    " + "-" * 56)
    for m, L in ((7, 100_000), (23, 100_000), (1009, 100_000), (10_007, 100_000)):
        print(f"    {m:<11} {L:<10} {m / L:<11.6f} {m / L >= 0.081}")
    print()


# ---------------------------------------------------------------------------
# 5.  Sharpness
# ---------------------------------------------------------------------------

def demo_sharpness(n_pts: int = 201) -> None:
    print("=" * 78)
    print("7.  Sharpness: positional families remove 100%; step carrier is aperiodic")
    print("=" * 78)
    grid = [i / (n_pts - 1) for i in range(n_pts)]
    target = [measured_profile(t) for t in grid]
    b_vals = [base_shape(t) for t in grid]

    # positional two-cell family: cell False carries B, cell True carries T
    pred_pos = [0.0 * b_vals[i] + 1.0 * target[i] for i in range(n_pts)]
    i0 = min(range(n_pts), key=lambda i: abs(grid[i] - 0.65))
    i1 = min(range(n_pts), key=lambda i: abs(grid[i] - 0.05))
    resid_b = [target[i] / b_vals[i] for i in range(n_pts)]
    resid_p = [target[i] / pred_pos[i] for i in range(n_pts)]
    exc_b = rel_excess(resid_b, i0, i1)
    exc_p = rel_excess(resid_p, i0, i1)
    print(f"    excess over the flat shape B      : {exc_b:.10f}")
    print(f"    excess over a POSITIONAL family   : {exc_p:.3e}")
    removal = 100.0 * (1.0 - exc_p / exc_b) if exc_b else float("nan")
    print(f"    removal                           : {removal:.4f}%")
    print()

    step = lambda j: 1 if j >= 0 else 0  # noqa: E731  (the aperiodic step carrier)
    for L in (10, 210, 1000):
        left = class_counts(step, -L, L).get(1, 0)
        right = class_counts(step, 0, L).get(1, 0)
        print(f"    step carrier, L = {L:<6} count(class 1) at a = 0: {right:<6}"
              f" at a = -L: {left}")
    print("    maximal composition drift -> not m-periodic for any m >= 1.")
    print()
    print("    Conclusion: the 0% is a fact about the arithmetic grid, not about")
    print("    the mixture formalism.  The carrier of the t = 0.65 excess must be")
    print("    aperiodic in j -- size, valuation or boundary effects, not residues.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("DIVISIBILITY IS A RATE DIAL, NOT A POSITION DIAL")
    print("numerical demonstration")
    print()
    demo_periodicity()
    demo_flat_composition()
    demo_rate_modulation()
    demo_collapse_and_zero_removal()
    demo_drift_budget()
    demo_residue_family()
    demo_sharpness()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
