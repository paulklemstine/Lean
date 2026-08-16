"""
Numerical demonstrations for the metric geometry of the moduli space of flat tori.

Everything in this file is self-contained (standard library only) and verifies,
numerically, the results of the accompanying paper:

  1.  Dilatation of a real-linear map z |-> a z + b conj(z), the determinant
      identity |A|^2 - |B|^2 = (|a|^2-|b|^2)(|c|^2-|d|^2) for composites, and
      submultiplicativity K(f o g) <= K(f) K(g).
  2.  The extremal marked affine map between two tori, its closed-form
      dilatation, and the main identification d_T = d_H / 2, i.e. K = exp(d_H).
  3.  The stretch line i e^{2t} as a unit-speed Teichmuller geodesic.
  4.  Reduction to the standard fundamental domain of the modular group.
  5.  The systole sys(tau) = min |m+n tau|^2 / Im tau, Hermite's constant
      gamma_2 = 2/sqrt(3) attained at the hexagonal torus, and sys(i) = 1.
  6.  The second successive minimum and Minkowski's second theorem
      1 <= sys * sys2 <= 4/3, with the extremal loci.
  7.  The collar lemma and uniqueness of the shortest geodesic on the thin part.
  8.  Teichmuller translation lengths of Anosov classes, log lambda(g), the
      spectral gap 2 log(golden ratio), and the length spectrum arcosh(n/2).
  9.  The moduli distance: proper discontinuity (finite search is exact), the
      separation of the two cone points, and the exhaustion comparison
      |d_M(rho, tau) - (1/2) log(1/sys tau)| <= (1/2) log 5.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Iterator, List, Optional, Tuple

Complex = complex
Matrix = Tuple[int, int, int, int]  # (a, b, c, d) with a d - b c = 1

SQRT3: float = math.sqrt(3.0)
GOLDEN: float = (1.0 + math.sqrt(5.0)) / 2.0
RHO: Complex = complex(-0.5, SQRT3 / 2.0)
I: Complex = complex(0.0, 1.0)


# --------------------------------------------------------------------------
# 1.  Real-linear maps of the plane and their dilatation
# --------------------------------------------------------------------------


def lin_apply(a: Complex, b: Complex, z: Complex) -> Complex:
    """The real-linear map z |-> a z + b conj(z)."""
    return a * z + b * z.conjugate()


def jacobian(a: Complex, b: Complex) -> float:
    """Jacobian determinant |a|^2 - |b|^2 (positive iff orientation preserving)."""
    return abs(a) ** 2 - abs(b) ** 2


def dilatation(a: Complex, b: Complex) -> float:
    """K = (|a|+|b|) / (|a|-|b|), the eccentricity of the image of the unit circle."""
    if abs(b) >= abs(a):
        raise ValueError("map is singular or orientation reversing")
    return (abs(a) + abs(b)) / (abs(a) - abs(b))


def beltrami(a: Complex, b: Complex) -> Complex:
    """The Beltrami coefficient mu = b / a; K = (1+|mu|)/(1-|mu|)."""
    return b / a


def lin_compose(
    a: Complex, b: Complex, c: Complex, d: Complex
) -> Tuple[Complex, Complex]:
    """Coefficients of (a,b) composed with (c,d): A = a c + b conj(d), B = a d + b conj(c)."""
    return a * c + b * d.conjugate(), a * d + b * c.conjugate()


def lin_inverse(a: Complex, b: Complex) -> Tuple[Complex, Complex]:
    """Coefficients of the inverse map: (conj(a)/J, -b/J)."""
    j = jacobian(a, b)
    return a.conjugate() / j, -b / j


# --------------------------------------------------------------------------
# 2.  Teichmuller space of the torus
# --------------------------------------------------------------------------


def affine_coeffs(tau: Complex, tau2: Complex) -> Tuple[Complex, Complex]:
    """The unique real-linear map with 1 |-> 1 and tau |-> tau2."""
    den = tau - tau.conjugate()
    return (tau2 - tau.conjugate()) / den, (tau - tau2) / den


def extremal_dilatation(tau: Complex, tau2: Complex) -> float:
    """K(tau, tau') = (|tau'-conj tau| + |tau'-tau|)^2 / (4 Im tau Im tau')."""
    p = abs(tau2 - tau.conjugate())
    q = abs(tau2 - tau)
    return (p + q) ** 2 / (4.0 * tau.imag * tau2.imag)


def hyperbolic_distance(z: Complex, w: Complex) -> float:
    """Poincare distance of curvature -1 on the upper half plane."""
    arg = 1.0 + abs(z - w) ** 2 / (2.0 * z.imag * w.imag)
    return math.acosh(max(arg, 1.0))


def teich_distance(tau: Complex, tau2: Complex) -> float:
    """Teichmuller distance = (1/2) log (extremal dilatation)."""
    return 0.5 * math.log(extremal_dilatation(tau, tau2))


def stretch_line(t: float) -> Complex:
    """The unit-speed Teichmuller geodesic through the square torus."""
    return complex(0.0, math.exp(2.0 * t))


# --------------------------------------------------------------------------
# 3.  The modular group: reduction, systole, successive minima
# --------------------------------------------------------------------------


def mobius(g: Matrix, z: Complex) -> Complex:
    a, b, c, d = g
    return (a * z + b) / (c * z + d)


def mat_mul(g: Matrix, h: Matrix) -> Matrix:
    a, b, c, d = g
    e, f, p, q = h
    return (a * e + b * p, a * f + b * q, c * e + d * p, c * f + d * q)


def reduce_to_fundamental_domain(tau: Complex) -> Tuple[Complex, Matrix]:
    """Return (w, g) with w = g . tau in {|Re w| <= 1/2, |w| >= 1}."""
    g: Matrix = (1, 0, 0, 1)
    w = tau
    for _ in range(10_000):
        n = math.floor(w.real + 0.5)
        if n != 0:
            g = mat_mul((1, -int(n), 0, 1), g)
            w = w - n
        if abs(w) < 1.0 - 1e-15:
            g = mat_mul((0, -1, 1, 0), g)
            w = -1.0 / w
        else:
            return w, g
    raise RuntimeError("reduction did not terminate")


def lattice_value(tau: Complex, m: int, n: int) -> float:
    """Q_{m,n}(tau) = |m + n tau|^2 / Im tau, the normalized squared length."""
    return abs(m + n * tau) ** 2 / tau.imag


def _index_candidates(tau: Complex, bound: float) -> Iterator[Tuple[int, int]]:
    """All nonzero (m, n) with |m + n tau|^2 <= bound * Im tau (plus slack)."""
    y = tau.imag
    n_max = int(math.floor(math.sqrt(max(bound * y, 0.0)) / y)) + 2
    for n in range(-n_max, n_max + 1):
        centre = -n * tau.real
        radius = math.sqrt(max(bound * y, 0.0)) + 1.0
        for m in range(int(math.floor(centre - radius)), int(math.ceil(centre + radius)) + 1):
            if (m, n) != (0, 0):
                yield (m, n)


def systole(tau: Complex) -> Tuple[float, Tuple[int, int]]:
    """min over nonzero (m,n) of Q_{m,n}(tau), with a realizing index vector."""
    bound = lattice_value(tau, 1, 0) + 1e-9
    best = (float("inf"), (0, 0))
    for (m, n) in _index_candidates(tau, bound):
        v = lattice_value(tau, m, n)
        if v < best[0] - 1e-15:
            best = (v, (m, n))
    return best


def second_minimum(tau: Complex) -> Tuple[float, Tuple[int, int]]:
    """The shortest normalized lattice vector independent of a shortest one."""
    _, (m0, n0) = systole(tau)
    bound = 4.0 * lattice_value(tau, 1, 0) + 4.0
    best = (float("inf"), (0, 0))
    for (m, n) in _index_candidates(tau, bound):
        if m0 * n - n0 * m == 0:
            continue
        v = lattice_value(tau, m, n)
        if v < best[0] - 1e-15:
            best = (v, (m, n))
    return best


def shortest_vectors(tau: Complex, tol: float = 1e-9) -> List[Tuple[int, int]]:
    """All index vectors realizing the systole (each geodesic appears twice, +/-)."""
    s, _ = systole(tau)
    out: List[Tuple[int, int]] = []
    for (m, n) in _index_candidates(tau, s + 1.0):
        if abs(lattice_value(tau, m, n) - s) < tol:
            out.append((m, n))
    return out


# --------------------------------------------------------------------------
# 4.  Moduli distance
# --------------------------------------------------------------------------


def _modular_elements(depth: int) -> List[Matrix]:
    """All products of at most `depth` generators S, T, T^{-1} of SL(2,Z)."""
    gens: List[Matrix] = [(0, -1, 1, 0), (1, 1, 0, 1), (1, -1, 0, 1)]
    frontier: List[Matrix] = [(1, 0, 0, 1)]
    seen = {(1, 0, 0, 1)}
    for _ in range(depth):
        new: List[Matrix] = []
        for g in frontier:
            for h in gens:
                k = mat_mul(h, g)
                if k not in seen:
                    seen.add(k)
                    new.append(k)
        frontier = new
    return list(seen)


def moduli_distance(tau: Complex, tau2: Complex, depth: int = 7) -> float:
    """min over g in SL(2,Z) of d_T(tau, g . tau'); the search is finite by
    proper discontinuity, and reduction makes a shallow search exact."""
    w1, _ = reduce_to_fundamental_domain(tau)
    w2, _ = reduce_to_fundamental_domain(tau2)
    return min(teich_distance(w1, mobius(g, w2)) for g in _modular_elements(depth))


# --------------------------------------------------------------------------
# 5.  Anosov classes and the length spectrum
# --------------------------------------------------------------------------


def stretch_factor(g: Matrix) -> float:
    """lambda(g) = (|tr| + sqrt(tr^2 - 4)) / 2, defined for |tr| > 2."""
    a, b, c, d = g
    t = abs(a + d)
    if t <= 2:
        raise ValueError("not an Anosov class")
    return (t + math.sqrt(t * t - 4.0)) / 2.0


def translation_length(g: Matrix) -> float:
    """Teichmuller translation length of an Anosov class: log lambda(g)."""
    return math.log(stretch_factor(g))


def displacement(g: Matrix, z: Complex) -> float:
    """d_T(z, g . z)."""
    return teich_distance(z, mobius(g, z))


def displacement_identity_rhs(g: Matrix, z: Complex) -> float:
    """cosh d_H(z, g z) via the exact identity, for cross-checking."""
    a, b, c, d = g
    x, y = z.real, z.imag
    return ((a + d) ** 2 - 2.0) / 2.0 + (c * (x * x + y * y) - (a - d) * x - b) ** 2 / (
        2.0 * y * y
    )


def spectrum_value(n: int) -> float:
    """arcosh(n/2) = log((n + sqrt(n^2-4))/2), the spectral value of trace n."""
    return math.log((n + math.sqrt(n * n - 4.0)) / 2.0)


def length_spectrum_below(bound: float) -> List[float]:
    """The exact set of translation lengths <= bound."""
    n_max = int(math.floor(2.0 * math.cosh(bound) + 1e-12))
    return [spectrum_value(n) for n in range(3, max(n_max, 2) + 1)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def _hdr(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_dilatation() -> None:
    _hdr("1.  Dilatation: determinant identity and submultiplicativity")
    a, b = complex(1.3, 0.4), complex(0.5, -0.2)
    c, d = complex(0.9, -1.1), complex(0.3, 0.6)
    A, B = lin_compose(a, b, c, d)
    lhs = abs(A) ** 2 - abs(B) ** 2
    rhs = jacobian(a, b) * jacobian(c, d)
    print(f"  |A|^2-|B|^2 = {lhs:.12f}   J(f) J(g) = {rhs:.12f}   diff = {abs(lhs-rhs):.2e}")

    kf, kg, kfg = dilatation(a, b), dilatation(c, d), dilatation(A, B)
    print(f"  K(f) = {kf:.6f}   K(g) = {kg:.6f}   K(f o g) = {kfg:.6f}   product = {kf*kg:.6f}")
    print(f"  submultiplicativity K(f o g) <= K(f) K(g):  {kfg <= kf * kg + 1e-12}")

    mu = beltrami(a, b)
    print(f"  Beltrami check  (1+|mu|)/(1-|mu|) = {(1+abs(mu))/(1-abs(mu)):.12f}  vs K = {kf:.12f}")

    ai, bi = lin_inverse(a, b)
    print(f"  K(f^-1) = {dilatation(ai, bi):.12f}   (equals K(f))")
    z = complex(0.7, -1.9)
    print(f"  inverse check  f(f^-1(z)) - z = {abs(lin_apply(a,b,lin_apply(ai,bi,z)) - z):.2e}")

    # the triangle inequality alone loses the term 2|b||d| on the minor axis
    lost = 2.0 * abs(b) * abs(d)
    triangle_lb = (abs(a) - abs(b)) * (abs(c) - abs(d)) - lost
    true_lb = (abs(a) - abs(b)) * (abs(c) - abs(d))
    print(f"  minor axis |A|-|B| = {abs(A)-abs(B):.6f};  triangle inequality only gives "
          f"{triangle_lb:.6f}")
    print(f"  the determinant identity gives the sharp {true_lb:.6f}"
          f"  (the lost term is 2|b||d| = {lost:.6f})")


def demo_main_identification() -> None:
    _hdr("2.  Main identification:  d_T = d_H / 2,  i.e.  K = exp(d_H)")
    pairs = [
        (complex(0.0, 1.0), complex(0.0, 3.0)),
        (complex(0.0, 1.0), complex(0.4, 2.2)),
        (RHO, complex(0.0, 1.0)),
        (complex(-0.3, 0.7), complex(1.8, 4.1)),
    ]
    print(f"  {'tau':>18} {'tau2':>18} {'K':>12} {'d_T':>10} {'d_H/2':>10} {'gap':>10}")
    for tau, tau2 in pairs:
        k = extremal_dilatation(tau, tau2)
        dt = teich_distance(tau, tau2)
        dh = hyperbolic_distance(tau, tau2) / 2.0
        print(f"  {tau!s:>18} {tau2!s:>18} {k:12.6f} {dt:10.6f} {dh:10.6f} {abs(dt-dh):10.2e}")

    tau, tau2 = complex(0.2, 1.4), complex(-0.6, 2.9)
    a, b = affine_coeffs(tau, tau2)
    print(f"\n  affine map check:  f(1) = {lin_apply(a,b,1+0j)},  "
          f"f(tau) - tau2 = {abs(lin_apply(a,b,tau)-tau2):.2e}")
    print(f"  its dilatation {dilatation(a,b):.9f} = closed form {extremal_dilatation(tau,tau2):.9f}")

    # triangle inequality from submultiplicativity
    t0, t1, t2 = complex(0.0, 1.0), complex(0.5, 1.7), complex(-0.4, 3.3)
    print(f"  triangle: d(t0,t2) = {teich_distance(t0,t2):.6f} <= "
          f"{teich_distance(t0,t1)+teich_distance(t1,t2):.6f}")


def demo_geodesic() -> None:
    _hdr("3.  The stretch line i e^{2t} is a unit-speed Teichmuller geodesic")
    print(f"  {'s':>6} {'t':>6} {'d_T':>10} {'|t-s|':>10} {'K':>14} {'e^{2|t-s|}':>14}")
    for s, t in [(0.0, 1.0), (-1.5, 0.5), (0.3, 2.8)]:
        ss, tt = stretch_line(s), stretch_line(t)
        print(f"  {s:6.2f} {t:6.2f} {teich_distance(ss,tt):10.6f} {abs(t-s):10.6f}"
              f" {extremal_dilatation(ss,tt):14.6f} {math.exp(2*abs(t-s)):14.6f}")
    r, s, t = -0.7, 0.4, 2.1
    lhs = teich_distance(stretch_line(r), stretch_line(t))
    rhs = teich_distance(stretch_line(r), stretch_line(s)) + teich_distance(
        stretch_line(s), stretch_line(t)
    )
    print(f"  additivity along the line: {lhs:.9f} = {rhs:.9f}")


def demo_systole() -> None:
    _hdr("4.  Systole, Hermite's constant gamma_2 = 2/sqrt(3), successive minima")
    hermite = 2.0 / SQRT3
    print(f"  Hermite constant 2/sqrt(3) = {hermite:.9f}")
    samples = [
        ("square torus i", I),
        ("hexagonal torus rho", RHO),
        ("rectangular 2i", complex(0.0, 2.0)),
        ("sheared 0.5+i", complex(0.5, 1.0)),
        ("thin 0.1+8i", complex(0.1, 8.0)),
        ("random 1.3+0.4i", complex(1.3, 0.4)),
    ]
    print(f"  {'torus':>20} {'sys':>10} {'sys2':>10} {'product':>10} {'in [1,4/3]':>12}")
    for name, tau in samples:
        s, _ = systole(tau)
        s2, _ = second_minimum(tau)
        prod = s * s2
        ok = 1.0 - 1e-9 <= prod <= 4.0 / 3.0 + 1e-9
        print(f"  {name:>20} {s:10.6f} {s2:10.6f} {prod:10.6f} {str(ok):>12}")

    print(f"\n  max of sys over a grid of the fundamental domain (should be 2/sqrt3):")
    best = 0.0
    best_pt: Optional[Complex] = None
    for jx in range(-50, 51):
        for jy in range(0, 200):
            w = complex(jx / 100.0, SQRT3 / 2.0 + jy / 100.0)
            if abs(w) < 1.0:
                continue
            s, _ = systole(w)
            if s > best:
                best, best_pt = s, w
    print(f"    max sys = {best:.9f} at {best_pt}   (2/sqrt3 = {hermite:.9f})")

    print("\n  invariance of sys under the mapping class group:")
    tau = complex(0.37, 1.21)
    for g in [(1, 1, 0, 1), (0, -1, 1, 0), (2, 1, 1, 1), (3, -1, 1, 0)]:
        print(f"    g = {g}:  sys(g.tau) = {systole(mobius(g, tau))[0]:.9f} "
              f"vs sys(tau) = {systole(tau)[0]:.9f}")


def demo_collar() -> None:
    _hdr("5.  Collar lemma and uniqueness of the shortest geodesic on the thin part")
    print(f"  {'torus':>18} {'sys':>10} {'1/sys':>10} {'sys2':>10} {'#shortest':>10}")
    for tau in [complex(0.0, 3.0), complex(0.2, 5.0), I, RHO]:
        s, _ = systole(tau)
        s2, _ = second_minimum(tau)
        shorts = shortest_vectors(tau)
        print(f"  {tau!s:>18} {s:10.6f} {1.0/s:10.6f} {s2:10.6f} {len(shorts):10d}")
    print("  (thin tori sys<1: exactly two shortest index vectors, i.e. one geodesic;")
    print("   the square torus has sys=1 and four, the hexagonal torus six.)")

    print("\n  extremal loci of the product sys * sys2:")
    print(f"    hexagonal rho:      {systole(RHO)[0]*second_minimum(RHO)[0]:.9f}  (= 4/3)")
    for Y in [1.0, 1.5, 4.0]:
        w = complex(0.0, Y)
        print(f"    rectangular i*{Y:<4}   {systole(w)[0]*second_minimum(w)[0]:.9f}  (= 1)")


def demo_translation_lengths() -> None:
    _hdr("6.  Anosov translation lengths and the length spectrum")
    cat: Matrix = (2, 1, 1, 1)
    print(f"  cat map (2,1;1,1): lambda = {stretch_factor(cat):.9f} "
          f"= phi^2 = {GOLDEN**2:.9f}")
    print(f"  translation length = {translation_length(cat):.9f} "
          f"= 2 log phi = {2*math.log(GOLDEN):.9f}")

    print("\n  minimizing the displacement numerically over a grid (should hit log lambda):")
    best = float("inf")
    best_z: Optional[Complex] = None
    for jx in range(-300, 301):
        for jy in range(1, 400):
            z = complex(jx / 100.0, jy / 100.0)
            d = displacement(cat, z)
            if d < best:
                best, best_z = d, z
    print(f"    numeric min = {best:.6f} at {best_z};  theory = {translation_length(cat):.6f}")

    print("\n  displacement identity cross-check (cosh d_H via identity vs direct):")
    for g in [(2, 1, 1, 1), (1, 1, 0, 1), (0, -1, 1, 0), (5, -1, 1, 0)]:
        z = complex(0.31, 1.77)
        direct = math.cosh(hyperbolic_distance(z, mobius(g, z)))
        ident = displacement_identity_rhs(g, z)
        print(f"    g = {g!s:>14}: {direct:.9f}  vs  {ident:.9f}  diff {abs(direct-ident):.2e}")

    print("\n  realization of every integer trace n >= 3 by (n,-1;1,0):")
    for n in range(3, 9):
        g: Matrix = (n, -1, 1, 0)
        print(f"    n = {n}: translation length {translation_length(g):.9f} "
              f"= arcosh(n/2) = {math.acosh(n/2.0):.9f}")

    L = 2.0
    spec = length_spectrum_below(L)
    print(f"\n  spectrum below L = {L}: {len(spec)} values, counting function "
          f"floor(2 cosh L) - 2 = {math.floor(2*math.cosh(L))-2}")
    print("    " + ", ".join(f"{v:.5f}" for v in spec))
    print(f"  spectral gap: no Anosov class moves any torus less than "
          f"{min(spec):.6f} = 2 log phi")


def demo_moduli() -> None:
    _hdr("7.  Moduli space: pseudometric, cone points, cusp, exhaustion")
    print(f"  d_M(i, i+1) = {moduli_distance(I, I+1):.2e}  (same unmarked torus)")
    sep = 0.5 * math.log(2.0 / SQRT3)
    dm = moduli_distance(RHO, I)
    print(f"  d_M(rho, i)  = {dm:.9f}   >=  (1/2) log(2/sqrt3) = {sep:.9f}: {dm >= sep - 1e-9}")

    print("\n  the parabolic tau -> tau+1: positive displacement, infimum zero")
    for y in [1.0, 3.0, 10.0, 100.0]:
        z = complex(0.0, y)
        print(f"    Im = {y:7.1f}:  d_T(z, z+1) = {displacement((1,1,0,1), z):.8f} > 0")

    print("\n  exhaustion comparison  |d_M(rho,tau) - (1/2) log(1/sys tau)| <= (1/2) log 5"
          f" = {0.5*math.log(5.0):.6f}")
    print(f"  {'tau':>18} {'sys':>10} {'d_M(rho,.)':>12} {'(1/2)log(1/sys)':>17} {'gap':>10}")
    for tau in [I, complex(0.0, 2.0), complex(0.0, 6.0), complex(0.3, 12.0), RHO]:
        s, _ = systole(tau)
        d = moduli_distance(RHO, tau)
        approx = 0.5 * math.log(1.0 / s)
        print(f"  {tau!s:>18} {s:10.6f} {d:12.6f} {approx:17.6f} {abs(d-approx):10.6f}")

    print("\n  reduction to the fundamental domain and sys = 1/Im there:")
    for tau in [complex(3.7, 0.13), complex(-2.4, 0.05), complex(0.9, 0.9)]:
        w, g = reduce_to_fundamental_domain(tau)
        s, _ = systole(w)
        print(f"    {tau} -> {w:.6f}  (|Re|<=1/2: {abs(w.real)<=0.5+1e-12}, "
              f"|w|>=1: {abs(w)>=1-1e-12}),  sys = {s:.6f}, 1/Im = {1/w.imag:.6f}")


def demo_stabilizers() -> None:
    _hdr("8.  The two orbifold points: stabilizers of orders two and three")
    S: Matrix = (0, -1, 1, 0)
    ST: Matrix = (0, -1, 1, 1)
    print(f"  S . i   = {mobius(S, I)}          (S fixes the square torus)")
    print(f"  ST . rho= {mobius(ST, RHO):.9f}   (ST fixes the hexagonal torus)")
    s2 = mat_mul(S, S)
    st3 = mat_mul(ST, mat_mul(ST, ST))
    print(f"  S^2 = {s2}  (= -1, so order 2 projectively)")
    print(f"  (ST)^3 = {st3}  (= -1, so order 3 projectively), (ST)^2 = {mat_mul(ST,ST)}")
    print("  integral solutions of a^2 + c^2 = 1: "
          f"{[(a,c) for a in range(-2,3) for c in range(-2,3) if a*a+c*c==1]}")
    print("  -> the stabilizer of i has order 2, that of rho order 3, so the two cone")
    print("     points lie in different orbits: cone angles pi and 2 pi / 3.")
    print(f"  sys distinguishes them too: sys(i) = {systole(I)[0]:.9f}, "
          f"sys(rho) = {systole(RHO)[0]:.9f}")


def main() -> None:
    print("Metric geometry of the moduli space of flat tori -- numerical demonstrations")
    demo_dilatation()
    demo_main_identification()
    demo_geodesic()
    demo_systole()
    demo_collar()
    demo_translation_lengths()
    demo_moduli()
    demo_stabilizers()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
