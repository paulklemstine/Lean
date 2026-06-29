"""
Numerical demonstrations for:

    "Density of the Quadratic-Irrational Restriction Class in the Ratio Spectrum"

This script illustrates, with concrete numbers, the verified topological floor of
the ratio-spectrum density program:

  * the Moebius (linear-fractional) action  M.x = (p x + q) / (r x + s);
  * the explicit quadratic-irrational family  q + sqrt(2)  (Theorem
    `quadIrr_rat_add_sqrt_two`) and its density in R (`quadIrr_dense`);
  * the adjugate inverse map and the inversion identity
    M . (adj M . w) = w  (`mobius_adjugate_left_inverse`);
  * image density: realizing any target window via the adjugate construction
    (`mobius_image_dense`);
  * the determinant structure of the target interval [1/|D|, |D|]
    (`one_le_absDet`, `spectrum_endpoints_mul`, ...);
  * a finite-window numerical Lagrange constant  k(x) = liminf q*||q x||,
    and the Lagarias-Shallit ratio bound  1/|D| <= k(Mx)/k(x) <= |D|.

Everything is self-contained and uses only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable


# --------------------------------------------------------------------------
# Moebius action and the adjugate inverse
# --------------------------------------------------------------------------

def mobius(p: int, q: int, r: int, s: int, x: float) -> float:
    """The Moebius action  M . x = (p x + q) / (r x + s)  of M = [[p,q],[r,s]]."""
    return (p * x + q) / (r * x + s)


def det(p: int, q: int, r: int, s: int) -> int:
    """Determinant of M = [[p,q],[r,s]]."""
    return p * s - q * r


def adjugate(p: int, q: int, r: int, s: int) -> tuple[int, int, int, int]:
    """Adjugate matrix adj M = [[s,-q],[-r,p]] (the inverse Moebius map's matrix)."""
    return (s, -q, -r, p)


def mobius_adjugate(p: int, q: int, r: int, s: int, w: float) -> float:
    """Apply the adjugate Moebius map: (adj M) . w = (s w - q) / (-r w + p)."""
    s2, mq, mr, p2 = adjugate(p, q, r, s)
    return mobius(s2, mq, mr, p2, w)


# --------------------------------------------------------------------------
# Quadratic irrationals: the explicit family q + sqrt(2)
# --------------------------------------------------------------------------

def rat_add_sqrt2(q: Fraction) -> float:
    """The quadratic irrational  q + sqrt(2)  (Theorem quadIrr_rat_add_sqrt_two)."""
    return float(q) + math.sqrt(2.0)


def quad_coeffs_of_rat_add_sqrt2(q: Fraction) -> tuple[int, int, int]:
    """
    Integer quadratic (a, b, c) with a != 0 satisfied by x = q + sqrt(2):
        f^2 x^2 - 2 e f x + (e^2 - 2 f^2) = 0,   where q = e / f.
    """
    e, f = q.numerator, q.denominator
    return (f * f, -2 * e * f, e * e - 2 * f * f)


def verify_quadratic(a: int, b: int, c: int, x: float) -> float:
    """Residual a x^2 + b x + c (should be ~0 for a genuine root)."""
    return a * x * x + b * x + c


def quad_irr_between(u: float, v: float) -> float:
    """
    A quadratic irrational strictly inside (u, v) (constructive quadIrr_dense):
    pick a rational q in (u - sqrt2, v - sqrt2) and return q + sqrt(2).
    """
    lo, hi = u - math.sqrt(2.0), v - math.sqrt(2.0)
    # A simple rational strictly between lo and hi.
    q = Fraction(lo + hi).limit_denominator(10**6)
    if not (lo < float(q) < hi):
        q = (Fraction(lo).limit_denominator(10**6)
             + Fraction(hi).limit_denominator(10**6)) / 2
    return rat_add_sqrt2(q)


# --------------------------------------------------------------------------
# Numerical Lagrange constant  k(x) = liminf_{q->inf} q * ||q x||
# --------------------------------------------------------------------------

def frac_dist_to_int(t: float) -> float:
    """||t|| = distance from t to the nearest integer."""
    return abs(t - round(t))


def cf_quadratic_surd(P0: int, N: int, Q0: int, n_terms: int = 200) -> list[int]:
    """
    Exact integer partial quotients of the quadratic surd x = (P0 + sqrt(N)) / Q0
    (with N not a perfect square), via the classical algorithm
        a_i = floor((P_i + sqrt N)/Q_i),  P_{i+1} = a_i Q_i - P_i,
        Q_{i+1} = (N - P_{i+1}^2)/Q_i.
    The leading coefficient is normalized so that Q0 | (N - P0^2).
    """
    # Normalize so that Q0 divides N - P0^2 (keeps x unchanged).
    if (N - P0 * P0) % Q0 != 0:
        P0, N, Q0 = P0 * abs(Q0), N * Q0 * Q0, Q0 * abs(Q0)
    a: list[int] = []
    P, Q = P0, Q0
    sqrtN = math.isqrt(N)  # floor(sqrt(N)), exact integer
    for _ in range(n_terms):
        # floor((P + sqrt N)/Q) using the integer floor of sqrt(N)
        ai = (P + sqrtN) // Q if Q > 0 else -((-P - sqrtN - 1) // (-Q))
        a.append(ai)
        P = ai * Q - P
        Q = (N - P * P) // Q
    return a


def cf_of_rat_add_sqrt2(q: Fraction, n_terms: int = 200) -> list[int]:
    """Exact partial quotients of x = q + sqrt(2), q = e/f, f > 0."""
    e, f = q.numerator, q.denominator
    # x = (e + f*sqrt(2)) / f = (e + sqrt(2 f^2)) / f
    return cf_quadratic_surd(P0=e, N=2 * f * f, Q0=f, n_terms=n_terms)


def _tail_value(a: list[int]) -> float:
    """Evaluate the continued fraction [a0; a1, a2, ...] from a finite list."""
    val = float(a[-1])
    for ai in reversed(a[:-1]):
        val = ai + 1.0 / val
    return val


def lagrange_constant_from_cf(a: list[int]) -> float:
    """
    Lagrange constant  k(x) = liminf_{q->inf} q * ||q x|| = 1 / L(x)  with
        L(x) = limsup_i ( [a_i; a_{i+1}, ...] + [0; a_{i-1}, ..., a_1] ),
    evaluated from exact (eventually periodic) partial quotients a.
    """
    best = 0.0
    for i in range(len(a) // 4, 3 * len(a) // 4):
        forward = _tail_value(a[i:])              # [a_i; a_{i+1}, ...]
        backward = _tail_value([0] + a[1:i][::-1])  # [0; a_{i-1}, ..., a_1]
        best = max(best, forward + backward)
    return 1.0 / best


def lagrange_constant_rat_add_sqrt2(q: Fraction, scale: int = 1) -> float:
    """k(x) for x = (q + sqrt(2)) / scale, computed from exact partial quotients."""
    e, f = q.numerator, q.denominator
    # (q + sqrt2)/scale = (e + sqrt(2 f^2)) / (f * scale)
    a = cf_quadratic_surd(P0=e, N=2 * f * f, Q0=f * scale)
    return lagrange_constant_from_cf(a)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_adjugate_inversion() -> None:
    """M . (adj M . w) = w  for irrational w and det M != 0."""
    print("=" * 70)
    print("Adjugate inversion:  M . (adj M . w) = w   (mobius_adjugate_left_inverse)")
    print("=" * 70)
    M = (2, 1, 1, 3)  # det = 5
    print(f"M = [[{M[0]},{M[1]}],[{M[2]},{M[3]}]],  det M = {det(*M)}")
    for w in [math.sqrt(2.0), math.sqrt(3.0), (1 + math.sqrt(5.0)) / 2]:
        x = mobius_adjugate(*M, w)
        back = mobius(*M, x)
        print(f"  w = {w:.10f}  ->  adj.w = {x:.10f}  ->  M.(adj.w) = {back:.10f}"
              f"   |error| = {abs(back - w):.2e}")
    print()


def demo_quad_irr_family() -> None:
    """q + sqrt(2) is a root of f^2 x^2 - 2ef x + (e^2 - 2 f^2)."""
    print("=" * 70)
    print("Explicit quadratic irrationals q + sqrt(2)  (quadIrr_rat_add_sqrt_two)")
    print("=" * 70)
    for q in [Fraction(0), Fraction(1, 2), Fraction(-3, 7), Fraction(22, 7)]:
        x = rat_add_sqrt2(q)
        a, b, c = quad_coeffs_of_rat_add_sqrt2(q)
        res = verify_quadratic(a, b, c, x)
        print(f"  q = {str(q):>6}  x = {x:.10f}  quadratic ({a},{b},{c})"
              f"  residual = {res:+.2e}")
    print()


def demo_domain_density() -> None:
    """A quadratic irrational lands strictly inside any window (quadIrr_dense)."""
    print("=" * 70)
    print("Domain density: a quadratic irrational inside (u, v)  (quadIrr_dense)")
    print("=" * 70)
    for u, v in [(0.0, 1e-3), (3.14159, 3.14160), (-2.0, -1.9999)]:
        x = quad_irr_between(u, v)
        print(f"  window ({u}, {v}):  x = {x:.12f}   inside = {u < x < v}")
    print()


def demo_image_density() -> None:
    """Realize a target window for M.x via the adjugate construction (mobius_image_dense)."""
    print("=" * 70)
    print("Image density: a quadratic irrational x with M.x in (u, v)  (mobius_image_dense)")
    print("=" * 70)
    M = (3, 1, 2, 1)  # det = 1 here; use a higher-det example too
    for M in [(3, 1, 2, 1), (2, 0, 0, 5), (4, 1, 1, 2)]:
        u, v = 0.5000, 0.5001
        w = quad_irr_between(u, v)            # target quadratic irrational in (u,v)
        x = mobius_adjugate(*M, w)            # pull back through the adjugate
        img = mobius(*M, x)                   # M.x should equal w in (u,v)
        print(f"  M=[[{M[0]},{M[1]}],[{M[2]},{M[3]}]] det={det(*M):>3}  "
              f"x={x:.8f}  M.x={img:.8f}  in ({u},{v}) = {u < img < v}")
    print()


def demo_interval_structure() -> None:
    """Endpoints 1/|D| and |D| are reciprocal and bracket 1 (determinant structure)."""
    print("=" * 70)
    print("Target interval [1/|D|, |D|]: reciprocal endpoints  (spectrum_endpoints_mul)")
    print("=" * 70)
    for M in [(2, 1, 1, 3), (1, 0, 0, 7), (5, 2, 2, 1)]:
        D = abs(det(*M))
        lo, hi = 1.0 / D, float(D)
        print(f"  det M = {det(*M):>3}  |D| = {D}  interval = [{lo:.6f}, {hi:.6f}]"
              f"   product = {lo * hi:.6f}   contains 1 = {lo <= 1 <= hi}")
    print()


def demo_ratio_bound() -> None:
    """
    The Lagarias-Shallit ratio bound  1/|D| <= k(Mx)/k(x) <= |D|  numerically,
    sampling quadratic irrational inputs.
    """
    print("=" * 70)
    print("Lagrange-constant ratio k(Mx)/k(x) inside [1/|D|, |D|]  (Lagarias-Shallit)")
    print("=" * 70)
    D = 3              # M = x -> x/3 = diag(1,3) normal form, det = 3
    print(f"M = x -> x/{D} (diag(1,{D})),  interval = [{1/D:.4f}, {D:.4f}]")
    qs = [Fraction(1, 3), Fraction(2, 5), Fraction(7, 11),
          Fraction(1, 9), Fraction(13, 4)]
    for q in qs:
        kx = lagrange_constant_rat_add_sqrt2(q, scale=1)    # k(x),  x = q + sqrt2
        kMx = lagrange_constant_rat_add_sqrt2(q, scale=D)   # k(x/D)
        ratio = kMx / kx
        ok = (1.0 / D - 1e-6) <= ratio <= (D + 1e-6)
        print(f"  x = q+sqrt2, q={str(q):>6}  k(x)={kx:.5f}  k(x/{D})={kMx:.5f}"
              f"  ratio={ratio:.5f}  in-bounds={ok}")
    print()


def main() -> None:
    demo_quad_irr_family()
    demo_domain_density()
    demo_adjugate_inversion()
    demo_image_density()
    demo_interval_structure()
    demo_ratio_bound()


if __name__ == "__main__":
    main()


"""
Visualization: the ratio spectrum k(x/D)/k(x) filling the interval [1/D, D].

Samples many quadratic irrationals x = q + sqrt(2) (q rational), computes the
exact Lagrange-constant ratio k(x/D)/k(x) for each via continued fractions, and
plots a histogram showing the ratios densely populating [1/D, D] with the
reciprocal endpoints and the central value 1 marked.

Self-contained except for matplotlib/numpy. Saves 'ratio_spectrum.png'.
"""

from __future__ import annotations

import math
from fractions import Fraction

import matplotlib.pyplot as plt
import numpy as np


def cf_quadratic_surd(P0: int, N: int, Q0: int, n_terms: int = 200) -> list[int]:
    """Exact partial quotients of (P0 + sqrt N)/Q0 (N not a perfect square)."""
    if (N - P0 * P0) % Q0 != 0:
        P0, N, Q0 = P0 * abs(Q0), N * Q0 * Q0, Q0 * abs(Q0)
    a: list[int] = []
    P, Q = P0, Q0
    sqrtN = math.isqrt(N)
    for _ in range(n_terms):
        ai = (P + sqrtN) // Q if Q > 0 else -((-P - sqrtN - 1) // (-Q))
        a.append(ai)
        P = ai * Q - P
        Q = (N - P * P) // Q
    return a


def _tail(a: list[int]) -> float:
    v = float(a[-1])
    for ai in reversed(a[:-1]):
        v = ai + 1.0 / v
    return v


def lagrange_constant(a: list[int]) -> float:
    """k(x) = 1 / limsup_i ([a_i; ...] + [0; a_{i-1}, ..., a_1])."""
    best = 0.0
    for i in range(len(a) // 4, 3 * len(a) // 4):
        best = max(best, _tail(a[i:]) + _tail([0] + a[1:i][::-1]))
    return 1.0 / best


def ratio_for(q: Fraction, D: int) -> float:
    """k((q+sqrt2)/D) / k(q+sqrt2)."""
    e, f = q.numerator, q.denominator
    k_x = lagrange_constant(cf_quadratic_surd(e, 2 * f * f, f))
    k_xD = lagrange_constant(cf_quadratic_surd(e, 2 * f * f, f * D))
    return k_xD / k_x


def main() -> None:
    D = 3
    ratios: list[float] = []
    for num in range(-40, 41):
        for den in range(1, 30):
            q = Fraction(num, den)
            try:
                ratios.append(ratio_for(q, D))
            except Exception:
                pass
    ratios = [r for r in ratios if 1.0 / D - 1e-6 <= r <= D + 1e-6]

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.hist(ratios, bins=60, range=(1.0 / D, D), color="#3b6ea5", alpha=0.85,
            edgecolor="white")
    ax.axvline(1.0 / D, color="#c0392b", lw=2, ls="--", label=f"1/D = {1/D:.3f}")
    ax.axvline(D, color="#c0392b", lw=2, ls="--", label=f"D = {D}")
    ax.axvline(1.0, color="#27ae60", lw=2, label="1 (k-invariant)")
    ax.set_xscale("log")
    ax.set_xlabel("ratio  k(x/D) / k(x)")
    ax.set_ylabel("count among sampled quadratic irrationals")
    ax.set_title(f"Ratio spectrum of x -> x/{D} filling [1/{D}, {D}]")
    ax.legend()
    fig.tight_layout()
    fig.savefig("ratio_spectrum.png", dpi=140)
    print(f"Sampled {len(ratios)} ratios in [{1/D:.3f}, {D}]; saved ratio_spectrum.png")


if __name__ == "__main__":
    main()
