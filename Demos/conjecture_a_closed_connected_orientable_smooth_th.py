"""
Numerical demonstrations for:

  * the Hopf distance identity           D^2 = m (4 - m)
  * sharp linear stability of Hopf fibres, with optimal constant 1/sqrt(2)
  * the dimension-free phase metric on the unit sphere of C^N
  * the area of Hopf-invariant tori,     Area(T_r) = 4 pi^2 r sqrt(1 - r^2)
  * the metabolizer criterion for cyclic linking forms:
        l_{n,q} is metabolic  <=>  n is a perfect square

Everything is self-contained: only the Python standard library is used.

Run with:   python3 demo.py
"""

from __future__ import annotations

import cmath
import math
import random
from typing import Iterator, List, Sequence, Tuple

Complex = complex
Vec2 = Tuple[Complex, Complex]
Vec3 = Tuple[float, float, float]


# ----------------------------------------------------------------------
# 1.  The Hopf map and its two distances
# ----------------------------------------------------------------------


def hopf(p: Vec2) -> Vec3:
    """Hopf image in R^3 of a pair (z, w) of complex numbers.

    H(z, w) = (2 Re(z conj(w)), 2 Im(z conj(w)), |z|^2 - |w|^2).
    For a unit pair this lands on the unit two-sphere.
    """
    z, w = p
    s = z * w.conjugate()
    return (2.0 * s.real, 2.0 * s.imag, abs(z) ** 2 - abs(w) ** 2)


def hermitian_pairing(p: Vec2, q: Vec2) -> Complex:
    """<p, q> = z conj(z') + w conj(w')."""
    z, w = p
    z2, w2 = q
    return z * z2.conjugate() + w * w2.conjugate()


def hopf_dist_sq(p: Vec2, q: Vec2) -> float:
    """Squared Euclidean distance between the Hopf images of p and q."""
    a, b = hopf(p), hopf(q)
    return sum((a[i] - b[i]) ** 2 for i in range(3))


def fibre_dist_sq(p: Vec2, q: Vec2) -> float:
    """Squared distance from p to the whole Hopf fibre (circle orbit) of q."""
    return 2.0 - 2.0 * abs(hermitian_pairing(p, q))


def phase_dist_sq(u: Complex, p: Vec2, q: Vec2) -> float:
    """Squared distance ||p - u.q||^2 for one particular unit phase u."""
    z, w = p
    z2, w2 = q
    return abs(z - u * z2) ** 2 + abs(w - u * w2) ** 2


def optimal_phase(p: Vec2, q: Vec2) -> Complex:
    """The phase realizing the minimum of ||p - u.q|| over the unit circle."""
    s = hermitian_pairing(p, q)
    return 1.0 + 0.0j if s == 0 else s / abs(s)


def random_unit_pair(rng: random.Random) -> Vec2:
    """A uniformly distributed point of the unit three-sphere in C^2."""
    xs = [rng.gauss(0.0, 1.0) for _ in range(4)]
    norm = math.sqrt(sum(x * x for x in xs))
    return (complex(xs[0], xs[1]) / norm, complex(xs[2], xs[3]) / norm)


def demo_hopf_identity(trials: int = 20000, seed: int = 20260816) -> None:
    print("=" * 74)
    print("1.  Hopf distance identity   D^2 = m (4 - m),   and  m <= D^2 / 2")
    print("=" * 74)
    rng = random.Random(seed)
    worst_residual = 0.0
    worst_ratio = 0.0
    best_ratio = 1.0
    worst_phase_gap = 0.0
    for _ in range(trials):
        p, q = random_unit_pair(rng), random_unit_pair(rng)
        d2 = hopf_dist_sq(p, q)
        m = fibre_dist_sq(p, q)
        worst_residual = max(worst_residual, abs(d2 - m * (4.0 - m)))
        if d2 > 1e-12:
            worst_ratio = max(worst_ratio, m / d2)
            best_ratio = min(best_ratio, m / d2)
        # the closed-form optimal phase really attains the fibre distance
        u = optimal_phase(p, q)
        worst_phase_gap = max(worst_phase_gap, abs(phase_dist_sq(u, p, q) - m))

    print(f"  random unit pairs tested             : {trials}")
    print(f"  max |D^2 - m(4-m)|                   : {worst_residual:.3e}")
    print(f"  max |min_u ||p-u.q||^2 - m|          : {worst_phase_gap:.3e}")
    print(f"  observed range of m / D^2            : "
          f"[{best_ratio:.6f}, {worst_ratio:.6f}]   (theory: [0.25, 0.5])")
    print()

    print("  Extremal configuration (orthogonal pair p=(1,0), q=(0,1)):")
    p, q = (1 + 0j, 0j), (0j, 1 + 0j)
    d2, m = hopf_dist_sq(p, q), fibre_dist_sq(p, q)
    print(f"    D^2 = {d2:.6f}   m = {m:.6f}   m/D^2 = {m / d2:.6f}  -> constant 1/sqrt2")
    sampled = [phase_dist_sq(cmath.exp(1j * k * math.pi / 12), p, q) for k in range(24)]
    print(f"    ||p - u.q||^2 over 24 phases: min {min(sampled):.6f}, "
          f"max {max(sampled):.6f}  (constant: no alignment possible)")
    print()

    print("  Near-fibre family q_x = (1-x, sqrt(1-(1-x)^2)) against p = (1,0):")
    print("      x           D^2            m          m/D^2      (theory D^2=8x-4x^2, m=2x)")
    for x in (0.5, 0.2, 0.05, 0.01, 0.001):
        q = (complex(1 - x, 0.0), complex(math.sqrt(1 - (1 - x) ** 2), 0.0))
        d2, m = hopf_dist_sq(p, q), fibre_dist_sq(p, q)
        print(f"   {x:8.4f}   {d2:11.7f}   {m:11.7f}   {m / d2:9.6f}")
    print("    -> ratio tends to 1/4, so no exponent alpha > 1 can work:")
    print("       m = 2x decays linearly while (C D^alpha)^2 ~ x^alpha = o(x).")
    print()


# ----------------------------------------------------------------------
# 2.  The dimension-free phase metric
# ----------------------------------------------------------------------


def inner_cn(p: Sequence[Complex], q: Sequence[Complex]) -> Complex:
    return sum(a * b.conjugate() for a, b in zip(p, q))


def phase_dist(p: Sequence[Complex], q: Sequence[Complex]) -> float:
    """sqrt(2 - 2|<p,q>|) = min over unit phases u of ||p - u q||."""
    return math.sqrt(max(0.0, 2.0 - 2.0 * abs(inner_cn(p, q))))


def random_unit_vector(n: int, rng: random.Random) -> List[Complex]:
    xs = [complex(rng.gauss(0, 1), rng.gauss(0, 1)) for _ in range(n)]
    norm = math.sqrt(sum(abs(x) ** 2 for x in xs))
    return [x / norm for x in xs]


def demo_phase_metric(dim: int = 5, trials: int = 20000, seed: int = 271828) -> None:
    print("=" * 74)
    print(f"2.  The phase-minimized metric on the unit sphere of C^{dim}")
    print("=" * 74)
    rng = random.Random(seed)
    worst_triangle = math.inf
    worst_min_gap = 0.0
    worst_identity = 0.0
    worst_stability = 0.0
    for _ in range(trials):
        p = random_unit_vector(dim, rng)
        q = random_unit_vector(dim, rng)
        r = random_unit_vector(dim, rng)

        # triangle inequality
        slack = phase_dist(p, q) + phase_dist(q, r) - phase_dist(p, r)
        worst_triangle = min(worst_triangle, slack)

        # the closed formula is really the minimum over phases
        s = inner_cn(p, q)
        u = 1.0 + 0j if s == 0 else s / abs(s)
        aligned = math.sqrt(sum(abs(a - u * b) ** 2 for a, b in zip(p, q)))
        worst_min_gap = max(worst_min_gap, abs(aligned - phase_dist(p, q)))

        # dimension-free identity m(4-m) = 4(1 - t^2)
        m = phase_dist(p, q) ** 2
        t = abs(s)
        worst_identity = max(worst_identity, abs(m * (4 - m) - 4 * (1 - t * t)))

        # sharp linear stability m <= chordal^2 / 2
        chordal_sq = 4 * (1 - t * t)
        worst_stability = max(worst_stability, m - chordal_sq / 2)

    print(f"  random triples tested                     : {trials}")
    print(f"  minimum triangle-inequality slack         : {worst_triangle:.3e}  (>= 0)")
    print(f"  max |closed form - min over phases|       : {worst_min_gap:.3e}")
    print(f"  max |m(4-m) - 4(1-t^2)|                   : {worst_identity:.3e}")
    print(f"  max (m - chordal^2/2)                     : {worst_stability:.3e}  (<= 0)")
    print("  Rigidity: d_ph(p, u p) for a random phase u :", end=" ")
    p = random_unit_vector(dim, rng)
    u = cmath.exp(1j * rng.uniform(0, 2 * math.pi))
    print(f"{phase_dist(p, [u * x for x in p]):.3e}  (exactly 0 in theory)")
    print()


# ----------------------------------------------------------------------
# 3.  Hopf-invariant tori and the Clifford refutation
# ----------------------------------------------------------------------


def torus_area_closed_form(r: float) -> float:
    """Area of T_r = { |z| = r, |w| = sqrt(1-r^2) }:  4 pi^2 r sqrt(1-r^2)."""
    return 4.0 * math.pi ** 2 * r * math.sqrt(max(0.0, 1.0 - r * r))


def torus_area_numeric(r: float, n: int = 400) -> float:
    """Riemann-sum of sqrt(EG - F^2) over the fundamental square [0,2pi]^2,
    with E, F, G computed from the parametrization (s,t) -> (r e^{is}, s e^{it}).
    """
    sigma = math.sqrt(max(0.0, 1.0 - r * r))
    h = 2.0 * math.pi / n
    total = 0.0
    for i in range(n):
        s = (i + 0.5) * h
        for j in range(n):
            t = (j + 0.5) * h
            ds = (1j * r * cmath.exp(1j * s), 0j)          # partial_s Phi
            dt = (0j, 1j * sigma * cmath.exp(1j * t))       # partial_t Phi
            E = abs(ds[0]) ** 2 + abs(ds[1]) ** 2
            G = abs(dt[0]) ** 2 + abs(dt[1]) ** 2
            F = (ds[0] * dt[0].conjugate()).real + (ds[1] * dt[1].conjugate()).real
            total += math.sqrt(max(0.0, E * G - F * F)) * h * h
    return total


def golden_section_maximize(lo: float, hi: float, iters: int = 200) -> float:
    """Golden-section search for the maximum of the unimodal area functional."""
    invphi = (math.sqrt(5.0) - 1.0) / 2.0
    a, b = lo, hi
    c, d = b - invphi * (b - a), a + invphi * (b - a)
    for _ in range(iters):
        if torus_area_closed_form(c) > torus_area_closed_form(d):
            b, d = d, c
            c = b - invphi * (b - a)
        else:
            a, c = c, d
            d = a + invphi * (b - a)
    return 0.5 * (a + b)


def demo_clifford() -> None:
    print("=" * 74)
    print("3.  Hopf-invariant tori:  Area(T_r) = 4 pi^2 r sqrt(1 - r^2)")
    print("=" * 74)
    print("      r        closed form     numeric quadrature      relative error")
    for r in (0.9, math.sqrt(2) / 2, 0.5, 0.25, 0.1, 0.01):
        exact = torus_area_closed_form(r)
        approx = torus_area_numeric(r, n=200)
        rel = abs(exact - approx) / max(exact, 1e-15)
        print(f"   {r:8.6f}   {exact:12.6f}   {approx:16.6f}   {rel:14.3e}")
    print()
    r_star = golden_section_maximize(1e-9, 1 - 1e-9)
    print(f"  golden-section maximizer      : r* = {r_star:.10f}")
    print(f"  closed-form Clifford parameter: sqrt(2)/2 = {math.sqrt(2) / 2:.10f}")
    print(f"  area there                    : {torus_area_closed_form(r_star):.8f}")
    print(f"  2 pi^2                        : {2 * math.pi ** 2:.8f}")
    print()
    print("  The minimality conjecture fails: thin tori have arbitrarily small area.")
    for r in (1e-1, 1e-2, 1e-3, 1e-4):
        print(f"    r = {r:.0e}:  Area(T_r) = {torus_area_closed_form(r):.8f}"
              f"   <  2 pi^2 = {2 * math.pi ** 2:.6f}")
    print()
    print("  Derivative 4 pi^2 (1 - 2 r^2)/sqrt(1 - r^2): unique zero at r = sqrt(2)/2.")
    for r in (0.3, 0.6, math.sqrt(2) / 2, 0.8, 0.95):
        deriv = 4 * math.pi ** 2 * (1 - 2 * r * r) / math.sqrt(1 - r * r)
        print(f"    r = {r:8.6f}   A'(r) = {deriv:+12.6f}")
    print()


# ----------------------------------------------------------------------
# 4.  Cyclic linking forms and metabolizers
# ----------------------------------------------------------------------


def divisors(n: int) -> List[int]:
    """All positive divisors of n, in increasing order (trial division)."""
    small, large = [], []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def annihilator_divisor(n: int, d: int) -> int:
    """Generator of the annihilator of H_d under l_{n,q} with gcd(q,n)=1: it is n/d."""
    return n // d


def link_vanishes(n: int, q: int, x: int, y: int) -> bool:
    """l_{n,q}(x, y) = q x y / n  is zero in Q/Z, i.e. n | q x y."""
    return (q * x * y) % n == 0


def brute_force_annihilator(n: int, q: int, d: int) -> List[int]:
    """Annihilator of the subgroup generated by d, computed by exhaustive search."""
    subgroup = sorted({(d * k) % n for k in range(n)})
    return [x for x in range(n) if all(link_vanishes(n, q, x, y) for y in subgroup)]


def find_metabolizer(n: int, q: int) -> int | None:
    """Return d with H_d = H_d^perp, or None. By the criterion, d exists iff n = d^2."""
    for d in divisors(n):
        if annihilator_divisor(n, d) == d:
            return d
    return None


def demo_linking_forms(limit: int = 26) -> None:
    print("=" * 74)
    print("4.  Cyclic linking forms:  metabolizer exists  <=>  n is a perfect square")
    print("=" * 74)
    print("     n   q   divisors            metabolizer   perfect square?  brute force check")
    for n in range(1, limit):
        q = next((c for c in range(1, n + 1) if math.gcd(c, n) == 1), 1)
        d = find_metabolizer(n, q)
        is_sq = int(math.isqrt(n)) ** 2 == n
        # independent check: brute-force annihilators of every subgroup
        brute = None
        for e in divisors(n):
            sub = sorted({(e * k) % n for k in range(n)})
            if brute_force_annihilator(n, q, e) == sub:
                brute = e
                break
        flag = "OK" if (d == brute) else "MISMATCH"
        print(f"   {n:3d} {q:3d}   {str(divisors(n)):<18}  "
              f"{str(d):<12}  {str(is_sq):<15}  {flag} (d={brute})")
    print()
    print("  Consequences (with the classical fact that an embedded three-manifold")
    print("  has metabolic linking form):")
    for n in (2, 3, 5, 6, 7, 8):
        print(f"    L({n}, q) does not embed smoothly in the four-sphere "
              f"(for every q coprime to {n}).")
    print("    L(4, q) and L(9, q) pass this test: metabolizers H_2 and H_3 exist,")
    print("    so the linking form alone is not a complete obstruction.")
    print()
    print("  Doubling shadow: |G + G| = |G|^2 is a perfect square, so Z/3 is not a")
    print("  double; Z/4 is a square order with a metabolizer but is NOT G + G,")
    print("  which separates the two halves of the coupled obstruction.")
    print()


# ----------------------------------------------------------------------


def main() -> None:
    demo_hopf_identity()
    demo_phase_metric()
    demo_clifford()
    demo_linking_forms()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
