"""
Smooth Windows: numerical demonstrations.

Self-contained (standard library only) numerical verification of the main results on
Gaussian versus rectangular windows:

  1. The Weyl commutation relation  M_b T_a = chi(a b) T_a M_b, and the fact that the
     phase cannot be removed.
  2. The Heisenberg group law and the Schroedinger (Gabor) representation property,
     including faithfulness on a Gaussian test vector.
  3. Exact sidelobes of the rectangular window: peak height 4T/(pi(2n+1)) at
     xi_n = (2n+1)/(4T), scale-invariant normalised amplitude 1/pi, divergent total energy.
  4. Sidelobe-free Gaussian transfer function |F gamma_{s,a,b}(xi)| = s g_{1/s}(xi - b).
  5. No false nulls, and the continuous, strictly monotone Gaussian scale space with the
     unwindowed harmonic statistic as its wide-window limit.
  6. Peak localisation: the exact profile factorisation and the Rayleigh criterion.
  7. Explicit Schwartz bounds and Gaussian regularisation of a divergent statistic.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Iterable, List, Sequence, Tuple

Complex = complex
Window = Callable[[float], Complex]

TAU: float = 2.0 * math.pi


# --------------------------------------------------------------------------------------
# 1. The character and the two motions
# --------------------------------------------------------------------------------------

def chi(x: float) -> Complex:
    """The basic additive character chi(x) = exp(2 pi i x)."""
    return cmath.exp(1j * TAU * x)


def translate(a: float, f: Window) -> Window:
    """Translation operator (T_a f)(t) = f(t - a)."""
    return lambda t: f(t - a)


def modulate(b: float, f: Window) -> Window:
    """Modulation operator (M_b f)(t) = chi(b t) f(t)."""
    return lambda t: chi(b * t) * f(t)


def gauss_window(s: float, t: float) -> float:
    """Gaussian window g_s(t) = exp(-pi t^2 / s^2)."""
    return math.exp(-math.pi * t * t / (s * s))


def gauss_c(s: float) -> Window:
    """Complex-valued Gaussian window."""
    return lambda t: complex(gauss_window(s, t), 0.0)


def gabor_atom(s: float, a: float, b: float) -> Window:
    """Gabor atom gamma_{s,a,b} = T_a M_b g_s."""
    return translate(a, modulate(b, gauss_c(s)))


def demo_weyl_relation() -> None:
    print("=" * 78)
    print("1. THE WEYL COMMUTATION RELATION   M_b T_a = chi(a b) T_a M_b")
    print("=" * 78)
    a, b, s = 0.7, 1.3, 1.5
    f = gauss_c(s)
    left = modulate(b, translate(a, f))
    right = translate(a, modulate(b, f))
    worst = 0.0
    for t in [-2.0, -0.5, 0.0, 0.35, 1.9, 4.0]:
        worst = max(worst, abs(left(t) - chi(a * b) * right(t)))
    print(f"  a = {a}, b = {b}, s = {s}")
    print(f"  max |M_b T_a f(t) - chi(ab) T_a M_b f(t)|  =  {worst:.3e}   (should be ~0)")

    # The phase is not removable: a = b = 1/2, evaluated at t = 1/2, differs by chi(1/4) = i.
    a2 = b2 = 0.5
    lhs = modulate(b2, translate(a2, f))(0.5)
    rhs = translate(a2, modulate(b2, f))(0.5)
    print(f"  a = b = 1/2 at t = 1/2:  lhs = {lhs:.6f},  rhs = {rhs:.6f}")
    print(f"  ratio lhs/rhs = {lhs / rhs:.6f}   (equals chi(1/4) = i, so the orders differ)")
    print()


# --------------------------------------------------------------------------------------
# 2. The Heisenberg group and the Gabor representation
# --------------------------------------------------------------------------------------

HeisElt = Tuple[float, float, Complex]


def heis_mul(g: HeisElt, h: HeisElt) -> HeisElt:
    """(a,b,z)(a',b',z') = (a+a', b+b', z z' chi(b a'))."""
    a, b, z = g
    a2, b2, z2 = h
    return (a + a2, b + b2, z * z2 * chi(b * a2))


def heis_inv(g: HeisElt) -> HeisElt:
    """Inverse in the Heisenberg group."""
    a, b, z = g
    return (-a, -b, chi(b * a) / z)


def gabor_act(g: HeisElt, f: Window) -> Window:
    """Schroedinger representation pi(a,b,z) f = z T_a M_b f."""
    a, b, z = g
    return lambda t: z * translate(a, modulate(b, f))(t)


def demo_heisenberg() -> None:
    print("=" * 78)
    print("2. HEISENBERG GROUP AND THE FAITHFUL GABOR REPRESENTATION")
    print("=" * 78)
    g: HeisElt = (0.4, -1.1, chi(0.13))
    h: HeisElt = (-0.9, 0.6, chi(0.41))
    k: HeisElt = (1.7, 0.25, chi(-0.2))

    left = heis_mul(heis_mul(g, h), k)
    right = heis_mul(g, heis_mul(h, k))
    assoc = max(abs(left[0] - right[0]), abs(left[1] - right[1]), abs(left[2] - right[2]))
    print(f"  associativity residual                 = {assoc:.3e}")

    ident = heis_mul(g, heis_inv(g))
    print(f"  g g^{-1} = ({ident[0]:.1e}, {ident[1]:.1e}, {ident[2]:.6f})   (should be (0,0,1))")

    f = gauss_c(1.0)
    resid = 0.0
    for t in [-1.5, 0.0, 0.8, 2.2]:
        resid = max(resid, abs(gabor_act(heis_mul(g, h), f)(t)
                               - gabor_act(g, gabor_act(h, f))(t)))
    print(f"  representation property  pi(gh) = pi(g)pi(h), residual = {resid:.3e}")

    # Faithfulness: a nontrivial element moves the Gaussian test vector.
    test: Window = lambda t: complex(math.exp(-t * t), 0.0)
    for elt, label in [((0.3, 0.0, 1 + 0j), "pure translation"),
                       ((0.0, 0.0, chi(0.25)), "pure phase     "),
                       ((0.0, 0.7, 1 + 0j), "pure modulation")]:
        dev = max(abs(gabor_act(elt, test)(t) - test(t)) for t in [0.0, 0.25, 0.5, 1.0])
        print(f"  {label}: max deviation on Gaussian = {dev:.4f}   (nonzero => detected)")
    print()


# --------------------------------------------------------------------------------------
# 3-4. Transfer functions: Dirichlet sidelobes versus the Gaussian bump
# --------------------------------------------------------------------------------------

def rect_transfer(T: float, xi: float) -> float:
    """|F 1_[-T,T](xi)| = |sin(2 pi T xi)| / (pi |xi|)."""
    if xi == 0.0:
        return 2.0 * T
    return abs(math.sin(TAU * T * xi)) / (math.pi * abs(xi))


def gauss_transfer(s: float, b: float, xi: float) -> float:
    """|F gamma_{s,a,b}(xi)| = s g_{1/s}(xi - b)  (independent of a)."""
    return s * gauss_window(1.0 / s, xi - b)


def sidelobe_freq(T: float, n: int) -> float:
    """xi_n = (2n+1)/(4T)."""
    return (2.0 * n + 1.0) / (4.0 * T)


def demo_sidelobes() -> None:
    print("=" * 78)
    print("3-4. SIDELOBES: RECTANGULAR (DIRICHLET) VERSUS GAUSSIAN")
    print("=" * 78)
    T, s = 2.0, 1.0
    print(f"  half-width T = {T}, Gaussian width s = {s}")
    print()
    print("     n     xi_n      |F rect|    xi_n*|F rect|      |F gauss|   ratio g/r")
    print("   " + "-" * 72)
    for n in [0, 1, 2, 3, 5, 10, 25, 50]:
        xi = sidelobe_freq(T, n)
        r = rect_transfer(T, xi)
        exact = 4.0 * T / (math.pi * (2.0 * n + 1.0))
        assert abs(r - exact) < 1e-12, "exact sidelobe height must match"
        g = gauss_transfer(s, 0.0, xi)
        print(f"   {n:5d} {xi:8.4f}  {r:11.6f}  {xi * r:14.8f}  {g:13.3e}  {g / r:10.2e}")
    print(f"   (the column xi_n*|F rect| is identically 1/pi = {1.0 / math.pi:.8f})")
    print()

    partial_rect = 0.0
    partial_gauss = 0.0
    for n in range(2000):
        xi = sidelobe_freq(T, n)
        partial_rect += rect_transfer(T, xi)
        partial_gauss += gauss_transfer(s, 0.0, xi)
    print(f"  sum of first 2000 rectangular sidelobe peaks = {partial_rect:.4f}  (diverges ~ log N)")
    print(f"  sum of first 2000 Gaussian    responses      = {partial_gauss:.6e}  (converges)")
    print()

    print("  Strict unimodality of the Gaussian transfer function about b = 0.35:")
    b = 0.35
    prev = None
    for xi in [0.35, 0.45, 0.60, 0.90, 1.40, 2.10]:
        v = gauss_transfer(s, b, xi)
        flag = "" if prev is None else ("  strictly smaller" if v < prev else "  !! NOT monotone")
        print(f"    xi = {xi:5.2f}   |F| = {v:.8f}{flag}")
        prev = v
    print()


# --------------------------------------------------------------------------------------
# 5. Windowed statistics, false nulls, and the scale space
# --------------------------------------------------------------------------------------

def window_sum_rect(ordinates: Sequence[float], T: float) -> float:
    """Sharp cutoff statistic: sum over |t| <= T of 1/(1/4 + t^2)."""
    return sum(1.0 / (0.25 + t * t) for t in ordinates if abs(t) <= T)


def gauss_spectral(ordinates: Sequence[float], s: float) -> float:
    """Gaussian scale space Sigma(S, s) = sum_t g_s(t) / (1/4 + t^2)."""
    return sum(gauss_window(s, t) / (0.25 + t * t) for t in ordinates)


def harmonic_statistic(ordinates: Sequence[float]) -> float:
    """Unwindowed statistic sum_t 1/(1/4 + t^2)."""
    return sum(1.0 / (0.25 + t * t) for t in ordinates)


# The first few ordinates of the classical critical-line family, used as realistic data.
ORDINATES: List[float] = [14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
                          37.586178, 40.918719, 43.327073, 48.005151, 49.773832]


def demo_scale_space() -> None:
    print("=" * 78)
    print("5. NO FALSE NULLS, AND THE GAUSSIAN SCALE SPACE")
    print("=" * 78)
    print("  Rectangular cutoff on the first ten ordinates (it jumps, and vanishes early):")
    for T in [5.0, 14.0, 14.134725, 20.0, 21.022040, 100.0]:
        print(f"    T = {T:10.6f}   windowSum = {window_sum_rect(ORDINATES, T):.8f}")
    print()
    print("  Gaussian scale space (continuous, strictly increasing, never zero):")
    prev = None
    for s in [1.0, 5.0, 10.0, 20.0, 40.0, 80.0, 200.0, 1000.0]:
        v = gauss_spectral(ORDINATES, s)
        mono = "" if prev is None else ("  increasing" if v > prev else "  !! NOT increasing")
        print(f"    s = {s:8.1f}   Sigma = {v:.6e}{mono}")
        prev = v
    print(f"  unwindowed limit  sum 1/(1/4 + t^2) = {harmonic_statistic(ORDINATES):.6e}")
    print()
    print("  A single ordinate outside the cutoff is invisible to the sharp window:")
    t_far = 21.02204
    print(f"    windowSum({{{t_far}}}, T = 10) = {window_sum_rect([t_far], 10.0):.10f}")
    for s in [10.0, 20.0, 50.0]:
        print(f"    Gaussian statistic, s = {s:4.1f}   = {gauss_spectral([t_far], s):.3e}  (> 0)")
    # For very narrow windows the value is still strictly positive but underflows binary
    # floating point; its base-10 logarithm is computed exactly instead.
    for s in [0.5, 2.0]:
        log10_val = (-math.pi * t_far * t_far / (s * s)) / math.log(10.0) \
            - math.log10(0.25 + t_far * t_far)
        print(f"    Gaussian statistic, s = {s:4.1f}   = 10^({log10_val:.1f})  (> 0, underflows float)")
    print()


# --------------------------------------------------------------------------------------
# 6. Peak localisation and the Rayleigh criterion
# --------------------------------------------------------------------------------------

def pos_profile(ordinates: Sequence[float], s: float, a: float) -> float:
    """Position profile P_S(a) = sum_t g_s(t - a) / (1/4 + t^2)."""
    return sum(gauss_window(s, t - a) / (0.25 + t * t) for t in ordinates)


def rayleigh_resolved(t1: float, t2: float, s: float) -> bool:
    """Rayleigh criterion 3 g_{2s}(t1 - t2) (1/4 + t1^2) <= 1/4 + t2^2."""
    return 3.0 * gauss_window(2.0 * s, t1 - t2) * (0.25 + t1 * t1) <= 0.25 + t2 * t2


def demo_peaks() -> None:
    print("=" * 78)
    print("6. PEAK LOCALISATION AND THE RAYLEIGH CRITERION")
    print("=" * 78)
    t1, t2 = 14.134725, 21.022040
    for s in [10.0, 6.0, 4.0, 2.0]:
        u = gauss_window(2.0 * s, t1 - t2)
        w1, w2 = 1.0 / (0.25 + t1 * t1), 1.0 / (0.25 + t2 * t2)
        at_t1 = pos_profile([t1, t2], s, t1)
        at_mid = pos_profile([t1, t2], s, (t1 + t2) / 2.0)
        # Exact values from the scale-doubling identities.
        pred_t1 = w1 + u ** 4 * w2
        pred_mid = u * (w1 + w2)
        # Exact factorisation of the difference.
        factored = (1.0 - u) * (w1 - u * (1.0 + u + u * u) * w2)
        print(f"  s = {s:5.1f}:  u = g_2s(d) = {u:.6f}")
        print(f"      P(t1)      = {at_t1:.10f}   (formula w1 + u^4 w2 = {pred_t1:.10f})")
        print(f"      P(midpoint)= {at_mid:.10f}   (formula u(w1 + w2)  = {pred_mid:.10f})")
        print(f"      difference = {at_t1 - at_mid:.10f}   "
              f"(factorisation (1-u)(w1 - u(1+u+u^2)w2) = {factored:.10f})")
        print(f"      sharp criterion u(1+u+u^2)w2 < w1 : "
              f"{u * (1 + u + u * u) * w2:.3e} < {w1:.3e}  -> "
              f"{'RESOLVED' if u * (1 + u + u * u) * w2 < w1 else 'merged'}")
        print(f"      Rayleigh criterion (constant 3)   : "
              f"{'satisfied' if rayleigh_resolved(t1, t2, s) else 'not satisfied'}")
    print()
    print("  Unbiased localisation for a single ordinate (peak exactly at t):")
    t = 14.134725
    for a in [t - 1.0, t - 0.1, t, t + 0.1, t + 1.0]:
        print(f"    a = {a:11.6f}   P(a) = {pos_profile([t], 3.0, a):.10f}")
    print()


# --------------------------------------------------------------------------------------
# 7. Schwartz bounds and regularisation
# --------------------------------------------------------------------------------------

def schwartz_bound(s: float, n: int) -> float:
    """The explicit constant (s^2/pi)^n n! in (t^2)^n g_s(t) <= (s^2/pi)^n n!."""
    return (s * s / math.pi) ** n * math.factorial(n)


def demo_schwartz() -> None:
    print("=" * 78)
    print("7. EXPLICIT SCHWARTZ BOUNDS AND GAUSSIAN REGULARISATION")
    print("=" * 78)
    s = 1.0
    print(f"  Checking (t^2)^n g_s(t) <= (s^2/pi)^n n!   for s = {s}:")
    for n in [0, 1, 2, 3, 4]:
        bound = schwartz_bound(s, n)
        worst = max(((t * t) ** n) * gauss_window(s, t)
                    for t in [i * 0.01 for i in range(0, 2001)])
        ok = "ok" if worst <= bound + 1e-9 else "VIOLATED"
        print(f"    n = {n}:  max_t (t^2)^n g_s(t) = {worst:12.6f} <= {bound:12.6f}   [{ok}]")
    print()
    print("  Regularisation on the threshold family t_k = sqrt(k+1):")
    unwindowed = 0.0
    windowed = 0.0
    checkpoints = {3, 10, 100, 1000, 10000}
    for k in range(10000):
        tk2 = float(k + 1)
        unwindowed += 1.0 / (0.25 + tk2)
        windowed += gauss_window(s, math.sqrt(tk2)) / (0.25 + tk2)
        if k + 1 in checkpoints:
            print(f"    k < {k + 1:6d}:  unwindowed = {unwindowed:10.6f}   "
                  f"Gaussian-windowed = {windowed:.8f}")
    print("    the unwindowed partial sums grow like log k (divergent harmonic series),")
    print("    while the Gaussian-windowed sum is constant to five digits past k = 3.")
    print()
    print("  Uniform decay over the Heisenberg orbit, |t-a|^m |gamma_{s,a,b}(t)| <= 1 + (s^2/pi)^m m!:")
    m = 2
    bound = 1.0 + schwartz_bound(s, m)
    worst = 0.0
    for a in [-3.0, 0.0, 1.7]:
        for b in [-2.0, 0.0, 5.0]:
            atom = gabor_atom(s, a, b)
            for i in range(0, 1200):
                t = a - 6.0 + i * 0.01
                worst = max(worst, abs(t - a) ** m * abs(atom(t)))
    print(f"    m = {m}: worst value over a grid of (a, b, t) = {worst:.6f} <= {bound:.6f}")
    print()


def main() -> None:
    demo_weyl_relation()
    demo_heisenberg()
    demo_sidelobes()
    demo_scale_space()
    demo_peaks()
    demo_schwartz()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
