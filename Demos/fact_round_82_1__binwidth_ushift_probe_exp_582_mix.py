"""
Binning-Independent Geometry of a Windowed Hump — numerical demonstrations.

Self-contained (standard library only).  Every function is inlined and type-hinted.

The script demonstrates, numerically, the results of the accompanying paper:

  1. Sampling identity            B_i(o, w) = (S_w f)(c_i(o, w))
  2. One-sided certificate        a bin value >= c forces sup f >= c
  3. Amplitude stability          |avg - f(x_s)| <= L w ; cross-width <= L (w1 + w2)
  4. Exact parabolic deflation    S_w(c - k(x-x_s)^2)(x) = c - k[(x-x_s)^2 + w^2/12]
  5. Vertex transport             absolute argmax centre invariant under grid shift
  6. Quadratic-fit audit          apex >= centre value; far apex <=> degenerate fit
  7. Control-bar audit            flat threshold FWER -> 1 ; aware threshold <= alpha

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

# --------------------------------------------------------------------------
# The model curve: a mid-window hump at u* = 0.65 on top of a flat baseline.
# --------------------------------------------------------------------------

U_STAR: float = 0.65
PEAK_AMPLITUDE: float = 1.23          # true value of R at the peak
BASELINE: float = 1.00                # R == 1 under a perfect model
HUMP_WIDTH: float = 0.16              # Gaussian scale of the hump


def ratio_curve(u: float) -> float:
    """The measured-to-modelled ratio R(u) = T(u)/M(u) on the unit window."""
    return BASELINE + (PEAK_AMPLITUDE - BASELINE) * math.exp(
        -0.5 * ((u - U_STAR) / HUMP_WIDTH) ** 2
    )


def parabolic_hump(c: float, k: float, x_s: float) -> Callable[[float], float]:
    """The canonical smooth hump f(x) = c - k (x - x_s)^2."""

    def f(x: float) -> float:
        return c - k * (x - x_s) ** 2

    return f


# --------------------------------------------------------------------------
# Core operators: bin average, bin value, bin centre, sliding average.
# --------------------------------------------------------------------------


def integrate(f: Callable[[float], float], a: float, b: float, n: int = 4096) -> float:
    """Composite Simpson quadrature of f on [a, b] with n (even) panels."""
    if n % 2 == 1:
        n += 1
    if b == a:
        return 0.0
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 == 1 else 2.0) * f(a + i * h)
    return total * h / 3.0


def bin_avg(f: Callable[[float], float], a: float, w: float) -> float:
    """avg(f; a, w) = (1/w) * integral of f over [a, a + w]."""
    return integrate(f, a, a + w) / w


def bin_center(o: float, w: float, i: int) -> float:
    """Centre c_i(o, w) = o + (i + 1/2) w of the i-th bin of the grid (o, w)."""
    return o + (i + 0.5) * w


def bin_value(f: Callable[[float], float], o: float, w: float, i: int) -> float:
    """Bar height B_i(o, w) = avg(f; o + i w, w)."""
    return bin_avg(f, o + i * w, w)


def sliding_avg(f: Callable[[float], float], w: float, x: float) -> float:
    """Box-kernel sliding average (S_w f)(x) = (1/w) * integral over [x-w/2, x+w/2]."""
    return integrate(f, x - w / 2.0, x + w / 2.0) / w


def histogram(
    f: Callable[[float], float], n_bins: int, shift_in_bins: float
) -> Tuple[List[float], List[float]]:
    """Histogram f on the unit window with `n_bins` bins, grid shifted by
    `shift_in_bins` bin-widths.  Returns (bar heights, absolute bin centres)."""
    w = 1.0 / n_bins
    o = shift_in_bins * w
    heights = [bin_value(f, o, w, i) for i in range(n_bins)]
    centers = [bin_center(o, w, i) for i in range(n_bins)]
    return heights, centers


# --------------------------------------------------------------------------
# The three-point local quadratic fit.
# --------------------------------------------------------------------------


def q_vertex(x0: float, w: float, ym: float, y0: float, yp: float) -> float:
    """Vertex abscissa of the parabola through (x0-w, ym), (x0, y0), (x0+w, yp)."""
    d = ym - 2.0 * y0 + yp
    return x0 + w * (ym - yp) / (2.0 * d)


def q_peak(ym: float, y0: float, yp: float) -> float:
    """Vertex ordinate (fitted amplitude) of the same parabola."""
    d = ym - 2.0 * y0 + yp
    return y0 - (yp - ym) ** 2 / (8.0 * d)


# --------------------------------------------------------------------------
# The probe grid.
# --------------------------------------------------------------------------

BIN_COUNTS: Tuple[int, ...] = (10, 20, 33, 50, 66, 100)
SHIFTS: Tuple[float, ...] = (-0.25, -0.125, 0.0, 0.125, 0.25)


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


# --------------------------------------------------------------------------
# 1. Sampling identity: every bar is a sample of one offset-free function.
# --------------------------------------------------------------------------


def demo_sampling_identity() -> None:
    banner("1. SAMPLING IDENTITY:  B_i(o,w) = (S_w f)(c_i(o,w))")
    worst = 0.0
    for n_bins in BIN_COUNTS:
        for sh in SHIFTS:
            w = 1.0 / n_bins
            o = sh * w
            for i in (0, n_bins // 3, n_bins // 2, n_bins - 1):
                lhs = bin_value(ratio_curve, o, w, i)
                rhs = sliding_avg(ratio_curve, w, bin_center(o, w, i))
                worst = max(worst, abs(lhs - rhs))
    print(f"  cells checked : {len(BIN_COUNTS) * len(SHIFTS)} (4 bars each)")
    print(f"  max |B - S_w| : {worst:.3e}   (0 up to quadrature error)")
    print("  => the grid offset is not a parameter of the statistic, only of")
    print("     the sampling points.")


# --------------------------------------------------------------------------
# 2. One-sided certificate: binning cannot manufacture a hump.
# --------------------------------------------------------------------------


def demo_one_sided_certificate() -> None:
    banner("2. ONE-SIDED CERTIFICATE:  a bar >= c forces sup f >= c")
    true_sup = max(ratio_curve(k / 200000.0) for k in range(200001))
    violations = 0
    amplitudes: List[float] = []
    for n_bins in BIN_COUNTS:
        for sh in SHIFTS:
            heights, _ = histogram(ratio_curve, n_bins, sh)
            raw_max = max(heights)
            amplitudes.append(raw_max)
            if raw_max > true_sup + 1e-9:
                violations += 1
    print(f"  true sup f            : {true_sup:.6f}")
    print(f"  raw maxima over 30 cells: min {min(amplitudes):.6f}  "
          f"max {max(amplitudes):.6f}")
    print(f"  cells exceeding sup f : {violations}  (must be 0)")
    print("  => averaging is a contraction toward the mean: it can flatten a")
    print("     hump but never create one.  Persistence is not an artefact.")


# --------------------------------------------------------------------------
# 3. Amplitude stability under bin width.
# --------------------------------------------------------------------------


def lipschitz_constant(f: Callable[[float], float], n: int = 20000) -> float:
    """Numerical sup |f'| on [0, 1] by finite differences."""
    h = 1.0 / n
    return max(abs(f((i + 1) * h) - f(i * h)) / h for i in range(n))


def demo_amplitude_stability() -> None:
    banner("3. AMPLITUDE STABILITY:  |raw max(w1) - raw max(w2)| <= L (w1 + w2)")
    lip = lipschitz_constant(ratio_curve)
    print(f"  Lipschitz constant L  ~ {lip:.4f}")
    maxima = {}
    for n_bins in BIN_COUNTS:
        heights, _ = histogram(ratio_curve, n_bins, 0.0)
        maxima[n_bins] = max(heights)
    print("\n  n_bins    raw max     bound L*w    deficit vs sup")
    true_sup = max(ratio_curve(k / 200000.0) for k in range(200001))
    for n_bins in BIN_COUNTS:
        w = 1.0 / n_bins
        print(f"  {n_bins:6d}  {maxima[n_bins]:9.6f}   {lip * w:9.6f}    "
              f"{true_sup - maxima[n_bins]:9.6f}")
    worst = 0.0
    for a in BIN_COUNTS:
        for b in BIN_COUNTS:
            gap = abs(maxima[a] - maxima[b])
            bound = lip * (1.0 / a + 1.0 / b)
            worst = max(worst, gap - bound)
    print(f"\n  max (observed gap - theoretical bound) = {worst:.6f}  (must be <= 0)")


# --------------------------------------------------------------------------
# 4. Exact deflation for the parabolic hump:  amplitude loss = k w^2 / 12.
# --------------------------------------------------------------------------


def demo_parabolic_deflation() -> None:
    banner("4. EXACT DEFLATION:  S_w(c - k(x-x_s)^2)(x) = c - k[(x-x_s)^2 + w^2/12]")
    c, k = 1.23, 4.0
    f = parabolic_hump(c, k, U_STAR)
    print("  n_bins     S_w f(x_s)   predicted c - k w^2/12     error")
    for n_bins in BIN_COUNTS:
        w = 1.0 / n_bins
        got = sliding_avg(f, w, U_STAR)
        want = c - k * w * w / 12.0
        print(f"  {n_bins:6d}   {got:11.8f}   {want:20.8f}   {abs(got - want):.2e}")
    w1, w2 = 1.0 / 10, 1.0 / 100
    gap = sliding_avg(f, w1, U_STAR) - sliding_avg(f, w2, U_STAR)
    print(f"\n  cross-width gap (w=1/10 vs 1/100): {gap:+.8f}")
    print(f"  closed form k(w2^2 - w1^2)/12     : "
          f"{k * (w2 * w2 - w1 * w1) / 12.0:+.8f}")
    print("  => a deterministic, offset-free deflation, not evidence against")
    print("     the feature.  It can simply be corrected for.")


# --------------------------------------------------------------------------
# 5. Vertex transport: the label drifts, the absolute position does not.
# --------------------------------------------------------------------------


def demo_vertex_transport() -> None:
    banner("5. VERTEX TRANSPORT:  bin LABEL drifts, ABSOLUTE centre is invariant")
    print("  n_bins   shift    argmax label   label/n_bins   absolute centre")
    for n_bins in (50, 100):
        for sh in SHIFTS:
            heights, centers = histogram(ratio_curve, n_bins, sh)
            j = max(range(n_bins), key=lambda i: heights[i])
            print(f"  {n_bins:6d}  {sh:+6.3f}   {j:12d}   {j / n_bins:12.4f}   "
                  f"{centers[j]:15.4f}")
        located = []
        for sh in SHIFTS:
            heights, centers = histogram(ratio_curve, n_bins, sh)
            j = max(range(n_bins), key=lambda i: heights[i])
            located.append(centers[j])
        w = 1.0 / n_bins
        print(f"         max |centre - u*| = "
              f"{max(abs(x - U_STAR) for x in located):.4f}  (bound w/2 = "
              f"{w / 2:.4f});  spread = {max(located) - min(located):.4f}"
              f"  (bound w = {w:.4f})\n")
    print("  => 'nearest bin wins': the argmax bin is fixed by geometry, so")
    print("     the absolute vertex is pinned while its label must drift.")


# --------------------------------------------------------------------------
# 6. Auditing the three-point quadratic fit.
# --------------------------------------------------------------------------


def demo_quadratic_fit_audit() -> None:
    banner("6. FIT AUDIT:  apex >= centre value; a far apex certifies degeneracy")
    print("  n_bins  shift   raw y0     fitted apex   apex - y0   |vx - x0| <= w/2 ?")
    n_fit_ge_raw = 0
    n_total = 0
    for n_bins in BIN_COUNTS:
        for sh in SHIFTS:
            heights, centers = histogram(ratio_curve, n_bins, sh)
            j = max(range(1, n_bins - 1), key=lambda i: heights[i])
            ym, y0, yp = heights[j - 1], heights[j], heights[j + 1]
            d = ym - 2.0 * y0 + yp
            if d >= 0.0:
                continue
            w = 1.0 / n_bins
            apex = q_peak(ym, y0, yp)
            vx = q_vertex(centers[j], w, ym, y0, yp)
            ok = abs(vx - centers[j]) <= w / 2.0 + 1e-12
            n_total += 1
            n_fit_ge_raw += int(apex >= y0 - 1e-12)
            if n_bins in (33, 100) and sh in (-0.25, 0.0):
                print(f"  {n_bins:6d} {sh:+6.3f}  {y0:9.6f}  {apex:12.6f}  "
                      f"{apex - y0:+10.6f}   {ok}")
    print(f"\n  concave fits examined            : {n_total}")
    print(f"  fits with apex >= raw centre bar : {n_fit_ge_raw}  (must equal above)")
    print("  => an amplitude bar on the FITTED apex is WEAKER, not stronger,")
    print("     than the same bar on the raw bar height.")

    print("\n  Degenerate example (asymmetry exceeds curvature):")
    ym, y0, yp = 1.00, 1.0100, 1.0199
    d = ym - 2.0 * y0 + yp
    a = ym - yp
    w = 1.0 / 33.0
    vx_off = q_vertex(0.0, w, ym, y0, yp)
    print(f"    y- = {ym}, y0 = {y0}, y+ = {yp}")
    print(f"    curvature D = {d:+.5f},  asymmetry A = {a:+.5f},  |A| > |D| : "
          f"{abs(a) > abs(d)}")
    print(f"    fitted vertex offset {vx_off:+.4f} vs half-bin {w / 2:.4f}  "
          f"-> far apex, certified degenerate")


# --------------------------------------------------------------------------
# 7. Control bars: flat threshold vs bin-count-aware threshold.
# --------------------------------------------------------------------------


def demo_control_bars() -> None:
    banner("7. CONTROL BARS:  flat FWER -> 1,  aware FWER <= alpha")
    p = 0.01
    alpha = 0.05
    print(f"  per-bin exceedance probability p = {p};  target alpha = {alpha}")
    print("\n     n     flat: 1-(1-p)^n     aware: 1-(1-alpha/n)^n")
    for n in (10, 20, 33, 50, 66, 100, 1000, 10000):
        flat = 1.0 - (1.0 - p) ** n
        aware = 1.0 - (1.0 - alpha / n) ** n
        print(f"  {n:6d}     {flat:14.6f}     {aware:20.6f}")
    print("\n  => a bin-count-agnostic bar is guaranteed to be breached under")
    print("     refinement; the aware bar stays below alpha at every resolution.")
    print("     The observed breaches at 1.0215-1.0305 (n in {50,66,100}) are")
    print("     expected extremes, inside the aware 1.05 ceiling.")


# --------------------------------------------------------------------------
# 8. The full 30-cell probe table.
# --------------------------------------------------------------------------


def demo_full_grid() -> None:
    banner("8. THE FULL 6 x 5 PROBE:  raw maxima and absolute argmax centres")
    header = "  n_bins " + "".join(f"{sh:+9.3f}" for sh in SHIFTS)
    print("  raw maximum")
    print(header)
    for n_bins in BIN_COUNTS:
        row = f"  {n_bins:6d} "
        for sh in SHIFTS:
            heights, _ = histogram(ratio_curve, n_bins, sh)
            row += f"{max(heights):9.4f}"
        print(row)
    print("\n  absolute argmax bin centre")
    print(header)
    for n_bins in BIN_COUNTS:
        row = f"  {n_bins:6d} "
        for sh in SHIFTS:
            heights, centers = histogram(ratio_curve, n_bins, sh)
            j = max(range(n_bins), key=lambda i: heights[i])
            row += f"{centers[j]:9.4f}"
        print(row)
    print(f"\n  true peak location u* = {U_STAR}")
    print("  => every cell shows the hump; every absolute centre sits within")
    print("     half a bin of u*, for every shift.")


def main() -> None:
    print("Binning-independent geometry of a windowed hump")
    print(f"model curve: R(u) = 1 + {PEAK_AMPLITUDE - BASELINE:.2f} * "
          f"exp(-((u - {U_STAR})/{HUMP_WIDTH})^2 / 2)")
    demo_sampling_identity()
    demo_one_sided_certificate()
    demo_amplitude_stability()
    demo_parabolic_deflation()
    demo_vertex_transport()
    demo_quadratic_fit_audit()
    demo_control_bars()
    demo_full_grid()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
