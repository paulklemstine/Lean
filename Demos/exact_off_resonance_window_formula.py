#!/usr/bin/env python3
"""
Numerical demonstration of the exact off-resonance window formula.

Everything below is self-contained (standard library only) and verifies,
numerically, the identities and bounds established analytically:

  * the sinc law            W(T, w) = 2T sinc(wT), with W(T,0) = 2T
  * peak dominance          |W| <= 2T
  * sidelobe envelope       |W| <= 2/|w|, with equality at w = (2k+1)pi/(2T)
  * exact zero set          W = 0  <=>  w = k pi / T, k != 0
  * main-lobe lower bound   |W| >= 2T (1 - (wT)^2/4) for |wT| <= 1
  * resolution bound        |W| >= T  =>  |w| <= 2/T
  * Dirichlet law           |S_N(a)| = |sin(pi N a)| / |sin(pi a)|
  * classical bound         |S_N(a)| <= 1/(2 ||a||)
  * Jordan main lobe        |S_N(a)| >= (2/pi) N for |a| <= 1/(2N), sharp
  * sampling bridge         C_N(a) = S_N(a) * C_1(a)
  * recentring invariance   |C_b(a)| = |W(b/2, 2 pi a)|
  * sharp Rayleigh criterion, critical time-bandwidth product c ~ 4.27836
  * Fejer identity, mass and concentration

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Tuple

# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------


def sinc(x: float) -> float:
    """Cardinal sine sin(x)/x, extended continuously by sinc(0) = 1."""
    if x == 0.0:
        return 1.0
    return math.sin(x) / x


def windowed_tone_numeric(T: float, omega: float, n_panels: int = 200_000) -> complex:
    """Numerically integrate int_{-T}^{T} exp(i w t) dt by Simpson's rule.

    Used only to confirm the closed form; every other routine uses the
    closed form directly.
    """
    if n_panels % 2 == 1:
        n_panels += 1
    a, b = -T, T
    h = (b - a) / n_panels
    total = 0.0 + 0.0j
    for k in range(n_panels + 1):
        t = a + k * h
        w = 1.0 if k in (0, n_panels) else (4.0 if k % 2 == 1 else 2.0)
        total += w * cmath.exp(1j * omega * t)
    return total * h / 3.0


def windowed_tone(T: float, omega: float) -> float:
    """Closed form: W(T, w) = 2T sinc(wT). Real-valued for a symmetric window."""
    return 2.0 * T * sinc(omega * T)


def weyl_sum(N: int, alpha: float) -> complex:
    """S_N(a) = sum_{n<N} exp(2 pi i n a), by direct summation."""
    return sum(cmath.exp(2j * math.pi * n * alpha) for n in range(N))


def weyl_sum_modulus_closed(N: int, alpha: float) -> float:
    """Dirichlet law |S_N(a)| = |sin(pi N a)| / |sin(pi a)|, with the
    resonance value N at integer a."""
    den = math.sin(math.pi * alpha)
    if abs(den) < 1e-14:
        return float(N)
    return abs(math.sin(math.pi * N * alpha)) / abs(den)


def cont_tone(b: float, alpha: float) -> complex:
    """C_b(a) = int_0^b exp(2 pi i a s) ds, in closed form."""
    if alpha == 0.0:
        return complex(b, 0.0)
    z = 2j * math.pi * alpha
    return (cmath.exp(z * b) - 1.0) / z


def int_dist(alpha: float) -> float:
    """||a||: distance from a to the nearest integer."""
    return abs(alpha - round(alpha))


def two_tone_response(T: float, delta: float, omega: float) -> float:
    """R(w) = W(T, w - D/2) + W(T, w + D/2), the superposition of two
    equal tones separated by D."""
    return windowed_tone(T, omega - delta / 2.0) + windowed_tone(T, omega + delta / 2.0)


def rayleigh_gap(x: float) -> float:
    """G(x) = sin x (2 - cos x) - x. Two tones with DT = 2x are resolved
    exactly when G(x) < 0."""
    return math.sin(x) * (2.0 - math.cos(x)) - x


def fejer_triangular(N: int, alpha: float) -> float:
    """2 sum_{d<N} (N - d) cos(2 pi d a) - N, which equals |S_N(a)|^2."""
    return 2.0 * sum(
        (N - d) * math.cos(2.0 * math.pi * d * alpha) for d in range(N)
    ) - N


# --------------------------------------------------------------------------
# Small numerical utilities
# --------------------------------------------------------------------------


def bisect(f: Callable[[float], float], lo: float, hi: float, iters: int = 200) -> float:
    """Bisection root finder on a sign-changing bracket."""
    flo = f(lo)
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if flo * f(mid) <= 0.0:
            hi = mid
        else:
            lo, flo = mid, f(mid)
    return 0.5 * (lo + hi)


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 20_000) -> float:
    """Composite Simpson quadrature of a real function."""
    if n % 2 == 1:
        n += 1
    h = (b - a) / n
    s = f(a) + f(b)
    for k in range(1, n):
        s += (4.0 if k % 2 == 1 else 2.0) * f(a + k * h)
    return s * h / 3.0


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# --------------------------------------------------------------------------
# 1. The sinc law
# --------------------------------------------------------------------------


def demo_sinc_law() -> None:
    banner("1. THE SINC LAW:  W(T, w) = 2T sinc(wT)")
    T = 3.0
    print(f"window half-width T = {T}   (total observation length 2T = {2*T})")
    print()
    print(f"{'omega':>10} {'closed form':>16} {'quadrature (re)':>18} "
          f"{'quadrature (im)':>18}")
    for omega in [0.0, 0.1, 0.5, 1.0, math.pi / T, 2.0, 5.0]:
        exact = windowed_tone(T, omega)
        num = windowed_tone_numeric(T, omega, 20_000)
        print(f"{omega:10.5f} {exact:16.10f} {num.real:18.10f} {num.imag:18.3e}")
    print()
    print("At resonance the response is exactly the window length 2T:")
    print(f"  W(T, 0) = {windowed_tone(T, 0.0):.10f}   2T = {2*T:.10f}")
    print("The imaginary part vanishes identically: the symmetric rectangular")
    print("window produces a purely real response.")


# --------------------------------------------------------------------------
# 2. Peak, sidelobes, sharpness
# --------------------------------------------------------------------------


def demo_peak_and_sidelobes() -> None:
    banner("2. PEAK DOMINANCE, SIDELOBE ENVELOPE, AND ITS SHARPNESS")
    T = 2.5
    peak = 2.0 * T
    worst = 0.0
    for i in range(1, 40_001):
        omega = i * 0.001
        worst = max(worst, abs(windowed_tone(T, omega)) - peak)
    print(f"T = {T}, peak 2T = {peak}")
    print(f"max over a fine sweep of ( |W| - 2T ) = {worst:.3e}  (must be <= 0)")
    print()
    print("Sidelobe envelope |W| <= 2/|w|, and equality at w = (2k+1)pi/(2T):")
    print(f"{'k':>3} {'omega_k':>12} {'|W|':>14} {'2/|omega_k|':>14} {'gap':>12}")
    for k in range(0, 6):
        omega_k = (2 * k + 1) * math.pi / (2 * T)
        lhs = abs(windowed_tone(T, omega_k))
        rhs = 2.0 / abs(omega_k)
        print(f"{k:3d} {omega_k:12.6f} {lhs:14.10f} {rhs:14.10f} {lhs-rhs:12.3e}")
    print()
    print("The envelope is touched exactly, once inside every sidelobe:")
    print("no bound c/|w| with c < 2 can hold.")
    print()
    print("Note the envelope does not involve T at all -- this is spectral")
    print("leakage: listening longer raises the peak but never lowers a far")
    print("sidelobe.  Compare T = 2.5 and T = 250 at w = 10:")
    for TT in (2.5, 250.0):
        print(f"  T = {TT:7.1f}:  |W| = {abs(windowed_tone(TT, 10.0)):.6f}"
              f"   peak 2T = {2*TT:.1f}   bound 2/|w| = {2/10.0:.6f}")


# --------------------------------------------------------------------------
# 3. Zeros and main lobe
# --------------------------------------------------------------------------


def demo_zeros_and_main_lobe() -> None:
    banner("3. EXACT ZERO SET, MAIN-LOBE POSITIVITY, AND WIDTH")
    T = 4.0
    print(f"T = {T}: zeros of W are exactly w = k pi / T, k != 0")
    print(f"{'k':>3} {'omega = k pi / T':>18} {'W':>16}")
    for k in range(1, 6):
        omega = k * math.pi / T
        print(f"{k:3d} {omega:18.10f} {windowed_tone(T, omega):16.3e}")
    print()
    print("Strict positivity throughout the main lobe 0 < wT < pi means")
    print("pi/T is genuinely the FIRST zero -- nothing hides before it:")
    mn = min(windowed_tone(T, s * (math.pi / T) / 1000.0) for s in range(1, 1000))
    print(f"  min of W over 0 < wT < pi  = {mn:.10f}  > 0")
    print()
    print("Quantitative main lobe:  |W| >= 2T (1 - (wT)^2/4) for |wT| <= 1")
    print(f"{'wT':>8} {'|W|/(2T)':>14} {'1 - (wT)^2/4':>16} {'slack':>12}")
    for xt in [0.0, 0.25, 0.5, 0.75, 1.0]:
        omega = xt / T
        lhs = abs(windowed_tone(T, omega)) / (2 * T)
        rhs = 1.0 - xt ** 2 / 4.0
        print(f"{xt:8.2f} {lhs:14.10f} {rhs:16.10f} {lhs-rhs:12.3e}")
    print()
    print("Resolution bound: |W| >= T (half the peak) forces |w| <= 2/T.")
    edge = bisect(lambda w: abs(windowed_tone(T, w)) - T, 0.0, math.pi / T)
    print(f"  largest |w| with |W| >= T  ~ {edge:.10f}")
    print(f"  guaranteed bound      2/T  = {2.0/T:.10f}")
    print("  (the bound is a valid, non-vacuous over-estimate of the true")
    print("   half-amplitude half-width)")


# --------------------------------------------------------------------------
# 4. The arithmetic shadow
# --------------------------------------------------------------------------


def demo_weyl_sums() -> None:
    banner("4. THE ARITHMETIC SHADOW: EXPONENTIAL SUMS")
    N = 12
    print(f"N = {N}.  Dirichlet law |S_N(a)| = |sin(pi N a)| / |sin(pi a)|")
    print(f"{'alpha':>10} {'direct sum':>16} {'closed form':>16} {'error':>12}")
    for alpha in [0.0, 1.0, 0.01, 1.0 / (2 * N), 1.0 / N, 0.137, 0.5]:
        direct = abs(weyl_sum(N, alpha))
        closed = weyl_sum_modulus_closed(N, alpha)
        print(f"{alpha:10.6f} {direct:16.10f} {closed:16.10f} "
              f"{abs(direct-closed):12.3e}")
    print()
    print("Classical bound |S_N(a)| <= 1/(2||a||), uniformly in N:")
    print(f"{'alpha':>10} {'||alpha||':>12} {'max_N |S_N|':>14} {'1/(2||a||)':>14}")
    for alpha in [0.1, 0.2, 0.3333, 0.45]:
        mx = max(abs(weyl_sum(n, alpha)) for n in range(1, 400))
        print(f"{alpha:10.4f} {int_dist(alpha):12.6f} {mx:14.8f} "
              f"{1.0/(2*int_dist(alpha)):14.8f}")
    print()
    print("Weyl cancellation for irrational a:  |S_N(a)| / N -> 0")
    alpha = math.sqrt(2.0)
    for N in (10, 100, 1000, 10_000, 100_000):
        print(f"  N = {N:7d}:  |S_N(sqrt2)|/N = "
              f"{weyl_sum_modulus_closed(N, alpha)/N:.8f}")
    print("  (this is exactly the input Weyl's criterion needs to conclude")
    print("   that {n sqrt2} is equidistributed modulo 1)")
    print()
    print("Jordan main lobe: |S_N(a)| >= (2/pi) N throughout |a| <= 1/(2N),")
    print("and the constant 2/pi = 0.63661977 is attained in the limit.")
    print(f"{'N':>8} {'|S_N(1/(2N))|/N':>20} {'2/pi':>12} {'excess':>12}")
    for N in (2, 5, 20, 100, 1000, 100_000):
        r = weyl_sum_modulus_closed(N, 1.0 / (2 * N)) / N
        print(f"{N:8d} {r:20.10f} {2/math.pi:12.8f} {r-2/math.pi:12.3e}")


# --------------------------------------------------------------------------
# 5. The sampling bridge
# --------------------------------------------------------------------------


def demo_sampling_bridge() -> None:
    banner("5. THE SAMPLING BRIDGE:  C_N(a) = S_N(a) * C_1(a)")
    print("The continuous window over [0,N] factors EXACTLY as the exponential")
    print("sum (a Dirichlet comb) times one sampling cell (a sinc envelope).")
    print()
    print(f"{'N':>4} {'alpha':>10} {'|C_N|':>16} {'|S_N| * |C_1|':>18} {'error':>12}")
    for N, alpha in [(1, 0.3), (5, 0.07), (8, 0.19), (13, 0.4), (20, 1.0 / 7)]:
        lhs = abs(cont_tone(float(N), alpha))
        rhs = abs(weyl_sum(N, alpha)) * abs(cont_tone(1.0, alpha))
        print(f"{N:4d} {alpha:10.6f} {lhs:16.10f} {rhs:18.10f} "
              f"{abs(lhs-rhs):12.3e}")
    print()
    print("Recentring invariance: |C_b(a)| = |W(b/2, 2 pi a)|.")
    print(f"{'b':>6} {'alpha':>10} {'|C_b|':>16} {'|W(b/2, 2 pi a)|':>20} {'error':>12}")
    for b, alpha in [(3.0, 0.2), (7.5, 0.13), (10.0, 0.4), (1.0, 0.9)]:
        lhs = abs(cont_tone(b, alpha))
        rhs = abs(windowed_tone(b / 2.0, 2 * math.pi * alpha))
        print(f"{b:6.2f} {alpha:10.6f} {lhs:16.10f} {rhs:20.10f} "
              f"{abs(lhs-rhs):12.3e}")


# --------------------------------------------------------------------------
# 6. The sharp Rayleigh criterion
# --------------------------------------------------------------------------


def demo_rayleigh() -> None:
    banner("6. THE SHARP RAYLEIGH CRITERION")
    print("Two equal tones separated by D, seen through a window of half-width T.")
    print("Resolved  <=>  midpoint darker than a tone centre  <=>  G(x) < 0,")
    print("where x = DT/2 and G(x) = sin x (2 - cos x) - x.")
    print()
    print(f"{'x':>8} {'G(x)':>14}   sign")
    for x in [0.5, 1.0, math.pi / 2, 2.0, 2.1, 2.13918, 2.2, 3.0, math.pi, 5.0]:
        g = rayleigh_gap(x)
        print(f"{x:8.5f} {g:14.8f}   {'+' if g > 0 else ('0' if g == 0 else '-')}")
    print()
    xc = bisect(rayleigh_gap, 1.0, 3.0)
    c = 2.0 * xc
    print(f"critical scale         xc = {xc:.10f}   (proved to lie in [2.1, 2.2))")
    print(f"critical time-bandwidth c = 2 xc = {c:.10f}  (proved in [4.2, 4.4))")
    print()
    T = 1.0
    print(f"Direct check at T = {T}: compare midpoint and tone-centre response.")
    print(f"{'D*T':>8} {'R(0)':>14} {'R(D/2)':>14}  verdict")
    for dt in [2.0, 3.0, 4.0, 4.2, 4.27836, 4.4, 5.0, 2 * math.pi, 8.0]:
        delta = dt / T
        r_mid = two_tone_response(T, delta, 0.0)
        r_ctr = two_tone_response(T, delta, delta / 2.0)
        if r_mid < r_ctr:
            verdict = "RESOLVED   (dip at the midpoint)"
        elif r_mid > r_ctr:
            verdict = "unresolved (bulge at the midpoint)"
        else:
            verdict = "exactly critical"
        print(f"{dt:8.5f} {r_mid:14.8f} {r_ctr:14.8f}  {verdict}")
    print()
    print("Perfect resolution at DT = 2 pi: each tone sits on the other's")
    print("first zero, so the midpoint response is exactly 0 and each tone")
    print("centre reaches the full unattenuated peak 2T:")
    delta = 2 * math.pi / T
    print(f"  R(0)     = {two_tone_response(T, delta, 0.0):.12f}   (exactly 0)")
    print(f"  R(pi/T)  = {two_tone_response(T, delta, math.pi/T):.12f}"
          f"   (2T = {2*T:.1f})")
    print()
    print(f"Since 2 pi = {2*math.pi:.5f} > c = {c:.5f}, tones become resolvable")
    print(f"a factor {2*math.pi/c:.4f} earlier than the textbook first-null rule.")


# --------------------------------------------------------------------------
# 7. The Fejer identity
# --------------------------------------------------------------------------


def demo_fejer() -> None:
    banner("7. FEJER'S TRIANGULAR IDENTITY, MASS, AND CONCENTRATION")
    print("|S_N(a)|^2 = 2 sum_{d<N} (N-d) cos(2 pi d a) - N")
    print()
    print(f"{'N':>4} {'alpha':>10} {'|S_N|^2':>16} {'triangular sum':>18} {'error':>12}")
    for N, alpha in [(3, 0.1), (7, 0.23), (10, 1.0 / 3), (15, 0.4), (20, 0.05)]:
        lhs = abs(weyl_sum(N, alpha)) ** 2
        rhs = fejer_triangular(N, alpha)
        print(f"{N:4d} {alpha:10.6f} {lhs:16.10f} {rhs:18.10f} "
              f"{abs(lhs-rhs):12.3e}")
    print()
    print("Positivity: a triangularly weighted cosine polynomial is >= 0")
    print("(false for constant weights -- that is the Dirichlet kernel, and")
    print("that difference is exactly why Cesaro means of Fourier series")
    print("converge where partial sums may not).")
    worst = min(fejer_triangular(9, i / 5000.0) for i in range(5000))
    print(f"  N = 9: min over a fine sweep = {worst:.3e}  (must be >= 0)")
    print()
    for N in (1, 4, 9, 16):
        mass = simpson(lambda a: fejer_triangular(N, a), 0.0, 1.0, 4000)
        print(f"  total mass over one period, N = {N:2d}:  {mass:.8f}   (= N)")
    print()
    print("Uniform-in-N concentration: ||a|| >= delta  =>  |S_N(a)|^2 <= 1/(4 delta^2)")
    for delta in (0.05, 0.1, 0.25):
        mx = 0.0
        for N in range(1, 300):
            for i in range(1, 1000):
                a = i / 1000.0
                if int_dist(a) >= delta:
                    mx = max(mx, abs(weyl_sum_modulus_closed(N, a)) ** 2)
        print(f"  delta = {delta:5.2f}:  observed max = {mx:12.4f}   "
              f"bound 1/(4 delta^2) = {1/(4*delta**2):12.4f}")
    print()
    print("Mass N concentrated in a window of width ~1/N about each integer,")
    print("bounded by a constant elsewhere: an approximate identity.")


# --------------------------------------------------------------------------
# 8. ASCII portrait of the response
# --------------------------------------------------------------------------


def demo_ascii_profile() -> None:
    banner("8. THE SHAPE OF THE RESPONSE (ASCII)")
    T = 1.0
    width = 68
    print("W(T, w) / (2T) for wT in [-4 pi, 4 pi];  '|' marks the axis,")
    print("'z' marks an exact zero w = k pi / T, '*' a sidelobe crest.")
    rows = 33
    for r in range(rows):
        xt = math.pi * (-4.0 + 0.25 * r)
        v = windowed_tone(T, xt / T) / (2 * T)
        col = int(round((v + 0.35) / 1.35 * (width - 1)))
        col = max(0, min(width - 1, col))
        axis = int(round(0.35 / 1.35 * (width - 1)))
        line: List[str] = [" "] * width
        line[axis] = "|"
        line[col] = "#"
        mark = " "
        if abs(math.sin(xt)) < 2e-2 and abs(xt) > 1e-6:
            mark = "z"
        elif abs(abs(math.sin(xt)) - 1.0) < 2e-2 and abs(xt) > 1e-6:
            mark = "*"
        print(f"{xt/math.pi:+6.2f} pi {''.join(line)} {mark}  {v:+.4f}")


# --------------------------------------------------------------------------


def main() -> None:
    print("EXACT OFF-RESONANCE WINDOW FORMULA -- NUMERICAL DEMONSTRATION")
    demo_sinc_law()
    demo_peak_and_sidelobes()
    demo_zeros_and_main_lobe()
    demo_weyl_sums()
    demo_sampling_bridge()
    demo_rayleigh()
    demo_fejer()
    demo_ascii_profile()
    banner("ALL DEMONSTRATIONS COMPLETE")


if __name__ == "__main__":
    main()
