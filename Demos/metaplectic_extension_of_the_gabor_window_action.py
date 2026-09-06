"""
Metaplectic Extension of the Gabor Window Action -- numerical demonstrations.

Self-contained: only numpy is required (a pure-Python fallback is not provided,
but every routine below is a short quadrature or an algebraic identity).

Conventions used throughout
---------------------------
    chi(x)          = exp(2*pi*i*x)
    g_s(t)          = exp(-pi t^2 / s^2)                 Gaussian window of width s
    (T_a f)(t)      = f(t - a)                           translation
    (M_b f)(t)      = chi(b t) f(t)                      modulation
    (C_c f)(t)      = chi(c t^2) f(t)                    chirp
    (D_u f)(t)      = f(exp(-u) t)                       dilation
    g_{s,a,b}(t)    = chi(b (t - a)) g_s(t - a)          Gabor atom at (a, b)
    G_{alpha,beta}  = exp(-pi (alpha + i beta) t^2)      chirped Gaussian, alpha > 0
    Fourier:  (F f)(xi) = int f(t) exp(-2 pi i t xi) dt
    Siegel parameter of G_{alpha,beta}:  z = i / (alpha + i beta)  in the upper half plane

The demonstrations below verify, numerically:

  1. the chirp/translation relation   C_c T_a = chi(-c a^2) M_{2ac} T_a C_c;
  2. the Heisenberg group law and that the chirp shear
         sigma_c(a,b,z) = (a, b + 2 c a, z chi(c a^2))
     is an automorphism -- and that dropping the phase chi(c a^2) breaks it;
  3. that the chirp shear is outer (conjugation never changes b);
  4. the Fourier transform of a chirped Gaussian, F G_tau = tau^{-1/2} G_{1/tau};
  5. equivariance: chirp = shear, dilation = diagonal, Fourier = rotation by pi/2,
     acting by Moebius transformations on the Siegel parameter;
  6. Borel transitivity: G_{alpha,beta} = C_{-beta/2} D_{-log(alpha)/2} G_{1,0},
     and the commutation relation D_u C_c D_u^{-1} = C_{exp(-2u) c};
  7. transversality: a nonzero chirp leaves the imaginary geodesic of widths;
  8. scale-space monotonicity as the diagonal flow;
  9. the metaplectic anomaly: F^2 is parity on Gabor atoms, F^4 = identity,
     while S^2 = -I acts trivially on the upper half plane;
 10. the projective anomaly: no complex constant kappa makes kappa * F^2 the identity;
 11. the discrete anomaly: the shear preserves the integer lattice iff 2c is an integer.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Tuple

import numpy as np

Complex = complex
Signal = Callable[[np.ndarray], np.ndarray]

TWO_PI_I = 2j * math.pi


# ----------------------------------------------------------------------------
# Basic objects
# ----------------------------------------------------------------------------

def chi(x: np.ndarray | float) -> np.ndarray | Complex:
    """The additive character chi(x) = exp(2 pi i x)."""
    return np.exp(TWO_PI_I * np.asarray(x, dtype=float))


def gauss_window(s: float, t: np.ndarray) -> np.ndarray:
    """The real Gaussian window g_s(t) = exp(-pi t^2 / s^2)."""
    return np.exp(-math.pi * t ** 2 / s ** 2)


def gauss_chirp(alpha: float, beta: float, t: np.ndarray) -> np.ndarray:
    """The chirped Gaussian G_{alpha,beta}(t) = exp(-pi (alpha + i beta) t^2)."""
    return np.exp(-math.pi * (alpha + 1j * beta) * t ** 2)


def gabor_atom(s: float, a: float, b: float, t: np.ndarray) -> np.ndarray:
    """The Gabor atom g_{s,a,b}(t) = chi(b (t - a)) g_s(t - a)."""
    return chi(b * (t - a)) * gauss_window(s, t - a)


def translate(f: Signal, a: float) -> Signal:
    return lambda t: f(t - a)


def modulate(f: Signal, b: float) -> Signal:
    return lambda t: chi(b * t) * f(t)


def chirp(f: Signal, c: float) -> Signal:
    return lambda t: chi(c * t ** 2) * f(t)


def dilate(f: Signal, u: float) -> Signal:
    return lambda t: f(math.exp(-u) * t)


# ----------------------------------------------------------------------------
# Numerical Fourier transform by high-accuracy trapezoidal quadrature
# ----------------------------------------------------------------------------

def fourier(f: Signal, xi: np.ndarray, half_width: float = 24.0,
            n: int = 1 << 16) -> np.ndarray:
    """(F f)(xi) = int f(t) exp(-2 pi i t xi) dt, by the trapezoidal rule.

    For Gaussian-type integrands the trapezoidal rule on a symmetric interval is
    spectrally accurate, so modest grids give near machine precision.
    """
    t = np.linspace(-half_width, half_width, n)
    dt = t[1] - t[0]
    vals = f(t)
    xi = np.atleast_1d(np.asarray(xi, dtype=float))
    kernel = np.exp(-TWO_PI_I * np.outer(xi, t))
    return (kernel @ vals) * dt


# ----------------------------------------------------------------------------
# Heisenberg group and the chirp shear
# ----------------------------------------------------------------------------

HeisElt = Tuple[float, float, Complex]


def heis_mul(g: HeisElt, h: HeisElt) -> HeisElt:
    """(a,b,z)(a',b',z') = (a + a', b + b', z z' chi(b a'))."""
    a, b, z = g
    ap, bp, zp = h
    return (a + ap, b + bp, z * zp * complex(chi(b * ap)))


def heis_inv(g: HeisElt) -> HeisElt:
    a, b, z = g
    return (-a, -b, (1.0 / z) * complex(chi(-b * a)))


def chirp_shear(c: float, g: HeisElt) -> HeisElt:
    """sigma_c(a,b,z) = (a, b + 2 c a, z chi(c a^2)) -- the correct automorphism."""
    a, b, z = g
    return (a, b + 2 * c * a, z * complex(chi(c * a ** 2)))


def chirp_shear_naive(c: float, g: HeisElt) -> HeisElt:
    """The same map WITHOUT the correction phase -- not an automorphism."""
    a, b, z = g
    return (a, b + 2 * c * a, z)


def dil_shear(u: float, g: HeisElt) -> HeisElt:
    """delta_u(a,b,z) = (e^u a, e^{-u} b, z) -- no phase correction needed."""
    a, b, z = g
    return (math.exp(u) * a, math.exp(-u) * b, z)


def heis_dist(g: HeisElt, h: HeisElt) -> float:
    return max(abs(g[0] - h[0]), abs(g[1] - h[1]), abs(g[2] - h[2]))


# ----------------------------------------------------------------------------
# SL2(R): matrices, Moebius action, Siegel parameter
# ----------------------------------------------------------------------------

def shear_mat(c: float) -> np.ndarray:
    return np.array([[1.0, 0.0], [-2.0 * c, 1.0]])


def dil_mat(u: float) -> np.ndarray:
    return np.array([[math.exp(u), 0.0], [0.0, math.exp(-u)]])


def fourier_mat() -> np.ndarray:
    return np.array([[0.0, -1.0], [1.0, 0.0]])


def moebius(m: np.ndarray, z: Complex) -> Complex:
    (p, q), (r, w) = m
    return (p * z + q) / (r * z + w)


def siegel(alpha: float, beta: float) -> Complex:
    """z = i / (alpha + i beta), a point of the upper half plane when alpha > 0."""
    return 1j / (alpha + 1j * beta)


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def head(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def report(label: str, err: float, tol: float = 1e-9) -> None:
    verdict = "OK " if err <= tol else "FAIL"
    print(f"  [{verdict}] {label:<58s} error = {err:.3e}")


# ----------------------------------------------------------------------------
# 1. The chirp/translation relation
# ----------------------------------------------------------------------------

def demo_chirp_translation() -> None:
    head("1. Chirp/translation relation:  C_c T_a = chi(-c a^2) M_{2ac} T_a C_c")
    t = np.linspace(-4.0, 4.0, 2001)
    worst = 0.0
    for (a, c, s) in [(0.7, 0.35, 1.0), (-1.3, 1.1, 0.6), (2.0, -0.4, 1.7)]:
        f: Signal = lambda x, s=s: gauss_window(s, x).astype(complex)
        lhs = chirp(translate(f, a), c)(t)
        rhs = complex(chi(-c * a ** 2)) * modulate(translate(chirp(f, c), a),
                                                   2 * a * c)(t)
        err = float(np.max(np.abs(lhs - rhs)))
        worst = max(worst, err)
        print(f"    a = {a:+.2f}, c = {c:+.2f}: sup|LHS - RHS| = {err:.3e}")
    report("chirp/translation relation holds pointwise", worst, 1e-12)
    print("    Reading: conjugating a translation by a chirp creates a modulation,")
    print("    i.e. the phase-space shear (a, b) -> (a, b + 2 c a).")


# ----------------------------------------------------------------------------
# 2. The extended Weyl cocycle
# ----------------------------------------------------------------------------

def demo_cocycle() -> None:
    head("2. The Weyl cocycle extends: sigma_c is an automorphism of the "
         "Heisenberg group")
    rng = np.random.default_rng(20260906)
    worst_good = 0.0
    worst_naive = 0.0
    for _ in range(200):
        a, b, ap, bp, c = rng.uniform(-2.0, 2.0, size=5)
        th1, th2 = rng.uniform(0.0, 2 * math.pi, size=2)
        g: HeisElt = (a, b, cmath.exp(1j * th1))
        h: HeisElt = (ap, bp, cmath.exp(1j * th2))
        lhs = chirp_shear(c, heis_mul(g, h))
        rhs = heis_mul(chirp_shear(c, g), chirp_shear(c, h))
        worst_good = max(worst_good, heis_dist(lhs, rhs))
        lhs_n = chirp_shear_naive(c, heis_mul(g, h))
        rhs_n = heis_mul(chirp_shear_naive(c, g), chirp_shear_naive(c, h))
        worst_naive = max(worst_naive, heis_dist(lhs_n, rhs_n))
    report("sigma_c(gh) = sigma_c(g) sigma_c(h)  [with phase chi(c a^2)]",
           worst_good, 1e-12)
    print(f"    Without the correction phase the same test fails by up to "
          f"{worst_naive:.3f}")
    print("    -- the phase chi(c a^2) is forced by c(a+a')^2 = c a^2 + 2c a a' "
          "+ c a'^2.")

    # one-parameter group property
    worst = 0.0
    for _ in range(100):
        a, b, c, cp = rng.uniform(-2.0, 2.0, size=4)
        g = (a, b, cmath.exp(1j * rng.uniform(0, 2 * math.pi)))
        worst = max(worst, heis_dist(chirp_shear(c, chirp_shear(cp, g)),
                                     chirp_shear(c + cp, g)))
    report("sigma_c o sigma_c' = sigma_{c+c'}", worst, 1e-12)

    # the dilation automorphism needs no phase at all
    worst = 0.0
    for _ in range(100):
        a, b, ap, bp, u = rng.uniform(-1.5, 1.5, size=5)
        g = (a, b, cmath.exp(1j * rng.uniform(0, 2 * math.pi)))
        h = (ap, bp, cmath.exp(1j * rng.uniform(0, 2 * math.pi)))
        worst = max(worst, heis_dist(dil_shear(u, heis_mul(g, h)),
                                     heis_mul(dil_shear(u, g), dil_shear(u, h))))
    report("delta_u is an automorphism with NO phase correction", worst, 1e-11)


# ----------------------------------------------------------------------------
# 3. The chirp shear is outer
# ----------------------------------------------------------------------------

def demo_outer() -> None:
    head("3. The chirp shear is outer: conjugation inside the group never "
         "changes b")
    rng = np.random.default_rng(7)
    g: HeisElt = (1.0, 0.0, 1.0 + 0j)
    print("    Test element g = (a, b, z) = (1, 0, 1); sigma_c(g) has b-coordinate 2c.")
    for c in (0.25, 0.5, 1.0):
        target_b = chirp_shear(c, g)[1]
        best = math.inf
        for _ in range(2000):
            a0, b0 = rng.uniform(-5.0, 5.0, size=2)
            h: HeisElt = (a0, b0, cmath.exp(1j * rng.uniform(0, 2 * math.pi)))
            conj = heis_mul(heis_mul(h, g), heis_inv(h))
            best = min(best, abs(conj[1] - target_b))
        print(f"    c = {c:.2f}: best |b(h g h^-1) - b(sigma_c g)| over 2000 "
              f"random h  =  {best:.3f}")
    print("    The b-coordinate of a conjugate is always 0, while sigma_c pushes it")
    print("    to 2c != 0: the automorphism is outer, so Heis x| R is not a direct")
    print("    product.")


# ----------------------------------------------------------------------------
# 4. Fourier transform of a chirped Gaussian
# ----------------------------------------------------------------------------

def demo_fourier_chirped() -> None:
    head("4. Fourier transform of a chirped Gaussian:  F G_tau = tau^{-1/2} "
         "G_{1/tau}")
    xi = np.linspace(-2.5, 2.5, 41)
    worst = 0.0
    for (alpha, beta) in [(1.0, 0.0), (1.0, 1.5), (0.4, -0.9), (2.3, 0.7)]:
        tau = alpha + 1j * beta
        numeric = fourier(lambda t: gauss_chirp(alpha, beta, t), xi)
        inv = 1.0 / tau
        predicted = (tau ** -0.5) * gauss_chirp(inv.real, inv.imag, xi)
        err = float(np.max(np.abs(numeric - predicted)))
        worst = max(worst, err)
        print(f"    tau = {tau:+.2f}: sup|numeric - tau^(-1/2) G_(1/tau)| "
              f"= {err:.3e}")
    report("width inversion tau -> 1/tau with scalar tau^(-1/2)", worst, 1e-10)
    print("    Specialising beta = 0, alpha = 1/s^2 gives the classical "
          "F g_s = s g_{1/s}.")


# ----------------------------------------------------------------------------
# 5. Equivariance on the Siegel parameter
# ----------------------------------------------------------------------------

def demo_equivariance() -> None:
    head("5. Equivariance: chirp = shear, dilation = diagonal, Fourier = "
         "rotation by pi/2")
    cases = [(1.0, 0.0), (0.5, 1.2), (2.0, -0.6)]
    worst = 0.0
    for (alpha, beta) in cases:
        z = siegel(alpha, beta)
        for c in (0.3, -1.1):
            lhs = siegel(alpha, beta - 2 * c)
            rhs = moebius(shear_mat(c), z)
            worst = max(worst, abs(lhs - rhs))
        for u in (0.4, -0.8):
            lhs = siegel(math.exp(-2 * u) * alpha, math.exp(-2 * u) * beta)
            rhs = moebius(dil_mat(u), z)
            worst = max(worst, abs(lhs - rhs))
        d = alpha ** 2 + beta ** 2
        lhs = siegel(alpha / d, -beta / d)
        rhs = moebius(fourier_mat(), z)
        worst = max(worst, abs(lhs - rhs))
        print(f"    (alpha, beta) = ({alpha:.2f}, {beta:+.2f}) -> z = "
              f"{z:.4f}   (Im z = {z.imag:.4f} > 0)")
    report("all three Moebius identities", worst, 1e-12)
    print("    S^2 = -I and S^4 = I:")
    s = fourier_mat()
    print(f"      max|S^2 + I| = {np.max(np.abs(s @ s + np.eye(2))):.1e}, "
          f"max|S^4 - I| = {np.max(np.abs(np.linalg.matrix_power(s, 4) - np.eye(2))):.1e}")


# ----------------------------------------------------------------------------
# 6. Borel transitivity and the commutation relation
# ----------------------------------------------------------------------------

def demo_borel() -> None:
    head("6. Borel subgroup: transitivity on the family, and D_u C_c D_u^{-1} "
         "= C_{e^{-2u} c}")
    t = np.linspace(-4.0, 4.0, 1601)
    worst = 0.0
    for (alpha, beta) in [(1.0, 0.0), (0.3, 2.0), (3.1, -1.4)]:
        u = -math.log(alpha) / 2.0
        c = -beta / 2.0
        base: Signal = lambda x: gauss_chirp(1.0, 0.0, x)
        built = chirp(dilate(base, u), c)(t)
        target = gauss_chirp(alpha, beta, t)
        err = float(np.max(np.abs(built - target)))
        worst = max(worst, err)
        print(f"    G_({alpha:.2f},{beta:+.2f}) = C_({c:+.3f}) D_({u:+.3f}) "
              f"G_(1,0):  error = {err:.3e}")
    report("Borel transitivity (one dilation + one chirp reaches everything)",
           worst, 1e-12)

    worst = 0.0
    for (u, c) in [(0.5, 0.8), (-1.2, -0.3)]:
        f: Signal = lambda x: gauss_window(1.0, x).astype(complex)
        lhs = dilate(chirp(dilate(f, -u), c), u)(t)
        rhs = chirp(f, math.exp(-2 * u) * c)(t)
        worst = max(worst, float(np.max(np.abs(lhs - rhs))))
        m_lhs = dil_mat(u) @ shear_mat(c) @ dil_mat(-u)
        m_rhs = shear_mat(math.exp(-2 * u) * c)
        worst = max(worst, float(np.max(np.abs(m_lhs - m_rhs))))
    report("operator relation AND matrix relation agree exactly", worst, 1e-12)
    print("    On the Borel subgroup the lift is honest -- no sign appears anywhere.")


# ----------------------------------------------------------------------------
# 7. Transversality of the chirp direction
# ----------------------------------------------------------------------------

def demo_transversality() -> None:
    head("7. Transversality: plain windows are the imaginary geodesic; a chirp "
         "leaves it")
    for s in (0.7, 1.0, 2.0):
        z = siegel(1.0 / s ** 2, 0.0)
        print(f"    g_s with s = {s:.2f}:  z = {z:.4f}   (Re z = {z.real:.1e}, "
              f"should be 0; note z = i s^2)")
    for c in (0.25, -1.0):
        z = siegel(1.0, -2 * c)
        print(f"    C_c g_1 with c = {c:+.2f}:  z = {z:.4f}   "
              f"(Re z = {z.real:+.4f} != 0)")
    print("    No change of width can imitate a chirp: the width family is a")
    print("    geodesic and the chirp direction is transverse to it.")


# ----------------------------------------------------------------------------
# 8. Scale-space monotonicity as the diagonal flow
# ----------------------------------------------------------------------------

def spectral_response(ordinates: np.ndarray, s: float) -> float:
    """Sigma(S, s) = sum over t in S of exp(-pi t^2 / s^2)."""
    return float(np.sum(np.exp(-math.pi * ordinates ** 2 / s ** 2)))


def demo_scale_space() -> None:
    head("8. Scale-space monotonicity is the diagonal one-parameter subgroup")
    ordinates = np.array([0.0, 0.35, -0.9, 1.6, 2.4])
    s0 = 0.8
    us = np.linspace(-1.5, 1.5, 13)
    vals = [spectral_response(ordinates, math.exp(u) * s0) for u in us]
    increasing = all(vals[i] < vals[i + 1] for i in range(len(vals) - 1))
    for u, v in zip(us[::3], vals[::3]):
        z = siegel(1.0 / (math.exp(u) * s0) ** 2, 0.0)
        print(f"    u = {u:+.2f}:  Sigma = {v:.6f},  Siegel point = {z:.4f} "
              f"(on the imaginary axis)")
    print(f"    strictly increasing along the flow: {increasing}")
    print("    The parameter u is the time of the diagonal flow, so monotonicity is")
    print("    the statement that a one-parameter subgroup moves the window point")
    print("    steadily up the imaginary geodesic.")


# ----------------------------------------------------------------------------
# 9-10. The metaplectic anomaly
# ----------------------------------------------------------------------------

def fourier_twice_numeric(f: Signal, xi: np.ndarray, half_width: float = 16.0,
                          n: int = 2048) -> np.ndarray:
    """Numerically apply the Fourier transform twice, by two quadratures.

    The first transform is evaluated on an auxiliary grid; the second is the
    trapezoidal quadrature of those samples against the kernel at the points xi.
    """
    grid = np.linspace(-half_width, half_width, n)
    dt = grid[1] - grid[0]
    first = (np.exp(-TWO_PI_I * np.outer(grid, grid)) @ f(grid)) * dt
    xi = np.atleast_1d(np.asarray(xi, dtype=float))
    return (np.exp(-TWO_PI_I * np.outer(xi, grid)) @ first) * dt


def demo_anomaly() -> None:
    head("9. The metaplectic anomaly: S^2 = -I acts trivially, but F^2 is parity")
    s = fourier_mat()
    s2 = s @ s
    pts = [1j, 0.3 + 0.9j, -1.2 + 2.0j]
    worst = max(abs(moebius(s2, z) - z) for z in pts)
    report("S^2 fixes every point of the upper half plane", worst, 1e-12)

    xi = np.linspace(-3.0, 3.0, 41)
    for (s_w, a, b) in [(1.0, 0.8, 0.0), (1.0, 0.0, 0.7), (1.3, 0.6, -0.5)]:
        atom: Signal = lambda t, s_w=s_w, a=a, b=b: gabor_atom(s_w, a, b, t)
        # one transform: the atom at (a, b) goes to the width-1/s atom at (b, -a)
        once = fourier(atom, xi)
        once_pred = s_w * chi(-a * xi) * gauss_window(1.0 / s_w, xi - b)
        twice = fourier_twice_numeric(atom, xi)
        parity = gabor_atom(s_w, -a, -b, xi)
        original = gabor_atom(s_w, a, b, xi)
        print(f"    s = {s_w:.2f}, (a, b) = ({a:+.2f}, {b:+.2f}):")
        print(f"        sup|F atom - s * M_(-a) T_b g_(1/s)| = "
              f"{float(np.max(np.abs(once - once_pred))):.3e}   (rotation by pi/2)")
        print(f"        sup|F^2 atom - parity atom|          = "
              f"{float(np.max(np.abs(twice - parity))):.3e}   (theorem: exactly 0)")
        print(f"        sup|F^2 atom - original atom|        = "
              f"{float(np.max(np.abs(twice - original))):.3e}   (theorem: nonzero)")

    print()
    print("    Order four is exact: applying the parity twice returns the atom.")
    s_w, a, b = 1.0, 0.8, 0.4
    parity_atom: Signal = lambda t: gabor_atom(s_w, -a, -b, t)
    fourth = fourier_twice_numeric(parity_atom, xi)
    report("F^4 atom = atom (matching S^4 = I)",
           float(np.max(np.abs(fourth - gabor_atom(s_w, a, b, xi)))), 1e-8)

    head("10. The anomaly is projective: no constant kappa repairs it")
    xig = np.linspace(-3.0, 3.0, 401)
    for (s_w, a, b) in [(1.0, 0.8, 0.0), (1.0, 0.0, 0.7)]:
        parity = gabor_atom(s_w, -a, -b, xig)
        original = gabor_atom(s_w, a, b, xig)
        kappa = np.vdot(parity, original) / np.vdot(parity, parity)
        residual = float(np.max(np.abs(kappa * parity - original)))
        rel = residual / float(np.max(np.abs(original)))
        print(f"    (a, b) = ({a:+.2f}, {b:+.2f}): least-squares optimal kappa = "
              f"{kappa:.4f},")
        print(f"        relative sup-norm residual of kappa * (parity atom) - atom "
              f"= {rel:.3f}")
    print("    Even the best possible constant leaves a large residual: the two")
    print("    atoms are not proportional, so no normalisation of the lift removes")
    print("    the sign. (For a != 0 the two envelopes are bells centred at -a and")
    print("    +a; for a = 0 evaluating at t = 0 forces kappa = 1.)")


# ----------------------------------------------------------------------------
# 11. The discrete (lattice) anomaly
# ----------------------------------------------------------------------------

def shear_preserves_lattice(c: float, bound: int = 6, tol: float = 1e-12) -> bool:
    """Test whether sigma_c maps the integer Heisenberg lattice into itself."""
    for m in range(-bound, bound + 1):
        for k in range(-bound, bound + 1):
            b_new = k + 2 * c * m
            if abs(b_new - round(b_new)) > tol:
                return False
    return True


def demo_lattice() -> None:
    head("11. Discrete anomaly: the shear preserves the integer lattice iff "
         "2c is an integer")
    print("      c        2c        2c integer?    preserves lattice?")
    for c in [0.0, 0.25, 1.0 / 3, 0.5, 0.75, 1.0, 1.5, 2.0, math.pi / 8]:
        two_c = 2 * c
        is_int = abs(two_c - round(two_c)) < 1e-12
        preserved = shear_preserves_lattice(c)
        flag = "OK " if is_int == preserved else "FAIL"
        print(f"    [{flag}] {c:7.4f}  {two_c:8.4f}      "
              f"{str(is_int):<10s}     {preserved}")
    print("    The continuous theory has a full real line of chirp rates; the")
    print("    discrete one keeps only the lattice (1/2) Z. The surviving symmetry")
    print("    group is arithmetic rather than continuous.")


# ----------------------------------------------------------------------------

def main() -> None:
    print("Metaplectic Extension of the Gabor Window Action")
    print("Numerical demonstrations of the main results")
    demo_chirp_translation()
    demo_cocycle()
    demo_outer()
    demo_fourier_chirped()
    demo_equivariance()
    demo_borel()
    demo_transversality()
    demo_scale_space()
    demo_anomaly()
    demo_lattice()
    print()
    print("=" * 78)
    print("Summary: the chirp extends the Weyl cocycle and normalises the")
    print("Heisenberg group; chirped Gaussians carry an SL2(R)-equivariant")
    print("structure through the Siegel parameter; the Borel subgroup lifts")
    print("honestly; and the rotation does not -- F^2 is parity, not the")
    print("identity, projectively as well, which is the metaplectic anomaly.")
    print("=" * 78)


if __name__ == "__main__":
    main()
