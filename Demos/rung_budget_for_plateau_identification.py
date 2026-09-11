"""
The Rung Budget for Plateau Identification -- numerical demonstrations.

A *fade* is a nonincreasing sequence s_0 >= s_1 >= ... whose decrements
d_n = s_n - s_{n+1} satisfy a certified deceleration bound d_{n+1} <= r * d_n
for some ratio r in [0, 1).  Such a sequence converges; its limit is its
*plateau*.

This script demonstrates, purely numerically, the results of the accompanying
paper:

  1. Exact identifiability: after measuring the prefix p_0, ..., p_{m+1}, the set
     of admissible plateaus is exactly [p_{m+1} - r*d_m/(1-r), p_{m+1}], where
     d_m = p_m - p_{m+1} is the LAST measured step.  Only the last step matters.
  2. Contraction: each further rung multiplies the interval width by exactly r on
     the extremal geometric ladder, and by at most r in general.
  3. The rung budget: m further rungs suffice for a target eps iff
     m >= ceil(log(eps*(1-r)/d0)/log r) - 1.
  4. The impossible branch: with the trivial certificate r = 1 the admissible set
     is the whole half-line below the last measured value.
  5. The noise floor: with rung uncertainty eta the admissible set always has
     diameter at least 2*eta, whatever the prefix length.
  6. Two-sided certificates: certifying rmin as well as rmax shortens the
     interval to d_m*(rmax-rmin)/((1-rmax)*(1-rmin)).

Everything is self-contained; no third-party dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core constructions
# ----------------------------------------------------------------------------


def geometric_ladder(s0: float, d0: float, r: float, n_terms: int) -> List[float]:
    """The extremal ladder with p_n - p_{n+1} = d0 * r**n exactly.

    p_n = s0 - d0 * (1 - r**n) / (1 - r).
    """
    if not 0.0 <= r < 1.0:
        raise ValueError("ratio r must lie in [0, 1)")
    return [s0 - d0 * (1.0 - r**n) / (1.0 - r) for n in range(n_terms)]


def steps(p: Sequence[float]) -> List[float]:
    """Decrements d_n = p_n - p_{n+1} of a measured prefix."""
    return [p[n] - p[n + 1] for n in range(len(p) - 1)]


def is_admissible_prefix(p: Sequence[float], r: float, tol: float = 1e-12) -> bool:
    """Check antitonicity and the deceleration certificate on measured indices."""
    d = steps(p)
    if any(x < -tol for x in d):
        return False
    return all(d[k + 1] <= r * d[k] + tol for k in range(len(d) - 1))


def plateau_interval(p: Sequence[float], r: float) -> Tuple[float, float]:
    """Exact admissible plateau interval [p_{m+1} - r*d_m/(1-r), p_{m+1}].

    `p` is the measured prefix p_0, ..., p_{m+1}; only its last two entries and
    the ratio r enter the answer.
    """
    if not 0.0 <= r < 1.0:
        raise ValueError("ratio r must lie in [0, 1)")
    last = p[-1]
    d_m = p[-2] - p[-1]
    width = r * d_m / (1.0 - r)
    return (last - width, last)


def plateau_width(p: Sequence[float], r: float) -> float:
    """Width r*d_m/(1-r) of the admissible plateau interval."""
    lo, hi = plateau_interval(p, r)
    return hi - lo


def spliced_fade(p: Sequence[float], q: float, L: float) -> Callable[[int], float]:
    """The witness fade: follow the prefix, then decay geometrically at ratio q to L.

    With M = len(p) - 1 the index of the last measured rung,
        s_n = p_n                              for n <= M,
        s_n = L + (p_M - L) * q**(n - M)       for n >  M.
    """
    M = len(p) - 1
    p_M = p[M]

    def s(n: int) -> float:
        if n <= M:
            return p[n]
        return L + (p_M - L) * q ** (n - M)

    return s


def fade_is_admissible(s: Callable[[int], float], r: float, n_check: int,
                       tol: float = 1e-12) -> bool:
    """Check antitonicity and the deceleration bound for indices 0..n_check."""
    vals = [s(n) for n in range(n_check + 3)]
    return is_admissible_prefix(vals, r, tol)


def rung_budget(d0: float, r: float, eps: float) -> int:
    """ceil(log(eps*(1-r)/d0)/log r) - 1, the number of further rungs required."""
    if d0 <= 0.0:
        raise ValueError("d0 must be positive")
    if not 0.0 < r < 1.0:
        raise ValueError("ratio r must lie in (0, 1)")
    if eps <= 0.0:
        raise ValueError("eps must be positive")
    return math.ceil(math.log(eps * (1.0 - r) / d0) / math.log(r)) - 1


def rung_budget_exact(d0: Fraction, r: Fraction, eps: Fraction) -> int:
    """Budget by exact rational search: least m >= 0 with d0*r**(m+1)/(1-r) <= eps.

    Returns the *clamped* budget max(0, B); agrees with `rung_budget` whenever the
    latter is nonnegative, and avoids all floating-point ceiling ambiguity.
    """
    m = 0
    while d0 * r ** (m + 1) / (1 - r) > eps:
        m += 1
    return m


def two_sided_interval(p: Sequence[float], rmin: float, rmax: float
                       ) -> Tuple[float, float]:
    """Exact two-sided admissible interval when ratios are certified in [rmin, rmax]."""
    if not 0.0 <= rmin <= rmax < 1.0:
        raise ValueError("need 0 <= rmin <= rmax < 1")
    last = p[-1]
    d_m = p[-2] - p[-1]
    return (last - rmax * d_m / (1.0 - rmax), last - rmin * d_m / (1.0 - rmin))


def two_sided_width(p: Sequence[float], rmin: float, rmax: float) -> float:
    """d_m*(rmax - rmin)/((1 - rmax)*(1 - rmin))."""
    d_m = p[-2] - p[-1]
    return d_m * (rmax - rmin) / ((1.0 - rmax) * (1.0 - rmin))


def noise_floor(eta: float) -> float:
    """Minimum achievable diameter of the admissible plateau set under noise eta."""
    return 2.0 * eta


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

RULE = "=" * 76


def demo_exact_interval() -> None:
    print(RULE)
    print("1. Exact identifiability: the admissible plateau interval")
    print(RULE)
    s0, d0, r = 0.488, 0.0259, 0.5
    p = geometric_ladder(s0, d0, r, 8)
    print(f"  extremal ladder  s0={s0}, d0={d0}, r={r}")
    print("  rungs:", ", ".join(f"{x:.6f}" for x in p[:6]))
    print("  steps:", ", ".join(f"{x:.6f}" for x in steps(p)[:5]))
    print(f"  prefix admissible for r={r}: {is_admissible_prefix(p, r)}")
    print()
    for m in range(5):
        prefix = p[: m + 2]
        lo, hi = plateau_interval(prefix, r)
        print(f"  m={m}: prefix p_0..p_{m+1}  ->  [{lo:.6f}, {hi:.6f}]"
              f"   width {hi - lo:.6f}")
    true_limit = s0 - d0 / (1.0 - r)
    print(f"\n  true plateau of this ladder: {true_limit:.6f}")
    lo, hi = plateau_interval(p[:2], r)
    print(f"  and indeed {lo:.6f} <= {true_limit:.6f} <= {hi:.6f}")


def demo_only_last_step_matters() -> None:
    print()
    print(RULE)
    print("2. Only the LAST measured step matters")
    print(RULE)
    r = 0.5
    # Two admissible prefixes with wildly different histories but the same
    # final value and final step.
    a = [10.0, 5.0, 2.5, 1.25, 1.0]        # steps 5, 2.5, 1.25, 0.25
    b = [15.25, 7.25, 3.25, 1.25, 1.0]     # steps 8, 4, 2, 0.25
    for name, q in (("A", a), ("B", b)):
        ok = is_admissible_prefix(q, r)
        lo, hi = plateau_interval(q, r)
        print(f"  prefix {name}: {['%.3f' % x for x in q]}")
        print(f"     steps {['%.3f' % x for x in steps(q)]}, admissible={ok}")
        print(f"     interval [{lo:.6f}, {hi:.6f}], width {hi - lo:.6f}")
    print("\n  Both share last value 1.0 and last step 0.25, hence share the")
    print("  interval [1.0 - 0.5*0.25/0.5, 1.0] = [0.75, 1.0]: the earlier")
    print("  history is informationally irrelevant.")


def demo_endpoints_attained() -> None:
    print()
    print(RULE)
    print("3. Both endpoints are attained (witness ladders)")
    print(RULE)
    r = 0.5
    p = geometric_ladder(0.488, 0.0259, r, 4)     # prefix p_0..p_3
    lo, hi = plateau_interval(p, r)
    print(f"  prefix {['%.6f' % x for x in p]}")
    print(f"  admissible interval [{lo:.6f}, {hi:.6f}]")
    for label, L, q in (("lower endpoint", lo, r), ("upper endpoint", hi, 0.0),
                        ("midpoint", 0.5 * (lo + hi), None)):
        if q is None:
            D = p[-1] - L
            d_m = p[-2] - p[-1]
            q = D / (D + d_m) if D + d_m > 0 else 0.0
        s = spliced_fade(p, q, L)
        ok = fade_is_admissible(s, r, 40)
        tail = s(60)
        print(f"  {label:15s} L={L:.6f}  tail ratio q={q:.4f}  "
              f"admissible={ok}  s(60)={tail:.8f}")


def demo_contraction() -> None:
    print()
    print(RULE)
    print("4. Contraction per rung: exactly r on the extremal ladder")
    print(RULE)
    for r in (0.3, 0.5, 0.8):
        p = geometric_ladder(1.0, 0.1, r, 8)
        widths = [plateau_width(p[: m + 2], r) for m in range(6)]
        ratios = [widths[i + 1] / widths[i] for i in range(len(widths) - 1)]
        print(f"  r={r}: widths " + ", ".join(f"{w:.6f}" for w in widths))
        print(f"        ratios " + ", ".join(f"{x:.6f}" for x in ratios))
    print()
    print("  ... but the factor r is only a worst-case guarantee:")
    r, d0 = 0.5, 1.0
    p = [d0, 0.0, 0.0]
    print(f"  prefix {p} is admissible for r={r}: {is_admissible_prefix(p, r)}")
    print(f"  width after 1 rung : {plateau_width(p[:2], r):.6f}")
    print(f"  width after 2 rungs: {plateau_width(p, r):.6f}  "
          f"(collapsed to a point, faster than the factor r)")


def demo_budget() -> None:
    print()
    print(RULE)
    print("5. The rung budget, and the reference ladder")
    print(RULE)
    d0, r = 0.0259, 0.5
    for eps in (0.0445, 0.01, 0.005, 0.001, 0.0001):
        B = rung_budget(d0, r, eps)
        Bc = max(0, B)
        Be = rung_budget_exact(Fraction(259, 10000), Fraction(1, 2),
                               Fraction(eps).limit_denominator(10**9))
        width = d0 * r ** (Bc + 1) / (1.0 - r)
        prev = d0 * r ** Bc / (1.0 - r) if Bc > 0 else None
        print(f"  eps={eps:<8g} budget={B:<3d} clamped={Bc:<3d} exact-search={Be:<3d}"
              f"  width at m={Bc}: {width:.8f}"
              + (f"  (at m={Bc-1}: {prev:.8f} > eps)" if prev else ""))
    print()
    print("  The reference ladder: d0=0.0259, r=1/2, CI half-width eps=0.0445.")
    print(f"  one-rung width = {d0 * r / (1 - r):.6f} < 0.0445  ->  budget "
          f"{rung_budget(d0, r, 0.0445)}")
    print("  The prior estimate of THREE further rungs is refuted: zero are needed.")
    print(f"  For eps = 0.001 the honest price is {max(0, rung_budget(d0, r, 0.001))}"
          " further rungs:")
    for m in (4, 5):
        print(f"     width at m={m}: {d0 * r**(m+1) / (1-r):.8f}")


def demo_impossible_branch() -> None:
    print()
    print(RULE)
    print("6. The impossible branch: r = 1 gives the whole half-line")
    print(RULE)
    p = [1.0, 0.75, 0.5]      # steps .25, .25 -- admissible for r = 1, not for r < 1
    d_m = p[-2] - p[-1]
    print(f"  prefix {p}, last step d_m = {d_m}")
    print("  target plateaus far below the last measured value, and the tail")
    print("  ratio q = 1 - min(1, d_m/D) that realises each of them:")
    for L in (0.4, 0.0, -5.0, -100.0):
        D = p[-1] - L
        c = min(1.0, d_m / D) if D > 0 else 1.0
        q = 1.0 - c
        s = spliced_fade(p, q, L)
        ok = fade_is_admissible(s, 1.0, 60)
        print(f"     L={L:>8.2f}  D={D:>8.2f}  q={q:.6f}  admissible(r=1)={ok}"
              f"  s(4000)={s(4000):.4f}")
    print("  Every value below 0.5 is an admissible plateau, for any prefix length.")
    print("  With a certificate r=1/2 instead, the interval would be just "
          f"[{plateau_interval(p, 0.5)[0]:.4f}, {plateau_interval(p, 0.5)[1]:.4f}].")


def demo_noise_floor() -> None:
    print()
    print(RULE)
    print("7. The noise floor: 2*eta, whatever the ladder length")
    print(RULE)
    d0, r, eta = 0.0259, 0.5, 0.0445
    print(f"  rung uncertainty eta = {eta}  ->  floor 2*eta = {noise_floor(eta):.4f}")
    p = geometric_ladder(0.488, d0, r, 12)
    print(f"  {'m':>3s}  {'exact-data width':>17s}  {'noise floor':>12s}   verdict")
    for m in range(0, 9, 2):
        w = plateau_width(p[: m + 2], r)
        verdict = "rung-limited" if w > noise_floor(eta) else "noise-limited"
        print(f"  {m:>3d}  {w:>17.8f}  {noise_floor(eta):>12.4f}   {verdict}")
    print("\n  The reference ladder is noise-limited from the very first rung:")
    print(f"  the one-rung width {plateau_width(p[:2], r):.4f} is already well below")
    print(f"  the floor {noise_floor(eta):.4f}, so further rungs cannot help at all.")
    print("  Witness: rigidly shifting the whole prefix by +eta or -eta leaves every")
    print("  decrement unchanged, hence stays admissible, and freezing the tail puts")
    print(f"  the plateau at {p[-1]:.4f} +/- {eta}, two points {2*eta:.4f} apart.")


def demo_two_sided() -> None:
    print()
    print(RULE)
    print("8. Two-sided certificates shorten the interval")
    print(RULE)
    p = geometric_ladder(0.488, 0.0259, 0.5, 3)
    rmax = 0.5
    print(f"  prefix {['%.6f' % x for x in p]}, d_m = {p[-2]-p[-1]:.6f}")
    print(f"  one-sided (rmax={rmax}): width {plateau_width(p, rmax):.6f}")
    for rmin in (0.0, 0.2, 0.4, 0.45):
        lo, hi = two_sided_interval(p, rmin, rmax)
        print(f"  rmin={rmin:<5g}: [{lo:.6f}, {hi:.6f}]  width "
              f"{two_sided_width(p, rmin, rmax):.6f}")
    print("\n  At the reference numbers with ratios certified in [0.4, 0.5] the")
    print("  window is 0.0259/3 ~ 0.00863 -- a threefold gain, no further rung.")


def demo_certificate_vs_rungs() -> None:
    print()
    print(RULE)
    print("9. Certificate quality versus ladder length")
    print(RULE)
    print(f"  {'r':>6s}  {'r/(1-r)':>10s}  {'rungs to gain 10x':>18s}")
    for r in (0.3, 0.5, 0.8, 0.9, 0.98, 0.99):
        factor = r / (1.0 - r)
        rungs = math.ceil(math.log(0.1) / math.log(r))
        print(f"  {r:>6g}  {factor:>10.3f}  {rungs:>18d}")
    r_old, r_new = 0.98, 0.49
    gain = (r_old / (1 - r_old)) / (r_new / (1 - r_new))
    print(f"\n  Sharpening the certificate from r={r_old} to r={r_new} shrinks the")
    print(f"  interval by a factor {gain:.1f}; buying that by measurement at r={r_old}")
    print(f"  would take {math.ceil(math.log(1/gain)/math.log(r_old))} further rungs.")


def main() -> None:
    demo_exact_interval()
    demo_only_last_step_matters()
    demo_endpoints_attained()
    demo_contraction()
    demo_budget()
    demo_impossible_branch()
    demo_noise_floor()
    demo_two_sided()
    demo_certificate_vs_rungs()
    print()
    print(RULE)
    print("Summary: the admissible plateau interval is [p_{m+1} - r*d_m/(1-r),")
    print("p_{m+1}]; it contracts by at most r per rung; the budget is")
    print("ceil(log(eps*(1-r)/d0)/log r) - 1; with r = 1 nothing is identifiable;")
    print("and measurement noise eta imposes an unbreakable floor of 2*eta.")
    print(RULE)


if __name__ == "__main__":
    main()
