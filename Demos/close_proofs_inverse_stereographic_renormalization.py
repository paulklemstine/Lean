"""
Inverse Stereographic Renormalization — Numerical Demonstrations
================================================================

A self-contained, dependency-free demonstration of the results in
"Inverse Stereographic Renormalization: Scaling Flows, the Energy Sphere,
and a Number-Theoretic Rosetta Stone".

The single map at the center of everything is the inverse stereographic
projection that wraps the real "energy line" R onto the unit circle S^1:

        sigma(t) = ( 2t / (1 + t^2) ,  (1 - t^2) / (1 + t^2) ).

Every function below is inlined and fully type-hinted. Run with:

        python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, sin, pi, isclose
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Core map: inverse stereographic projection sigma : R -> S^1
# ---------------------------------------------------------------------------

def inv_stereo(t: float) -> Tuple[float, float]:
    """sigma(t) = (2t/(1+t^2), (1-t^2)/(1+t^2)). Maps the energy line onto S^1."""
    d: float = 1.0 + t * t
    return (2.0 * t / d, (1.0 - t * t) / d)


def inv_stereo_exact(t: Fraction) -> Tuple[Fraction, Fraction]:
    """Exact rational version of sigma, for rational energy scales."""
    d: Fraction = 1 + t * t
    return (2 * t / d, (1 - t * t) / d)


def stereo_proj(x: float, y: float) -> float:
    """Forward projection sigma^{-1}(x,y) = x/(1+y) (inverse of inv_stereo)."""
    return x / (1.0 + y)


# ---------------------------------------------------------------------------
# Demo 1 — Theorem 2.3: the image always lies exactly on the unit circle
# ---------------------------------------------------------------------------

def demo_on_circle() -> None:
    print("=" * 70)
    print("DEMO 1  -  sigma(t) lies on S^1 for every t   (Theorem 'Sigma.1')")
    print("=" * 70)
    for t in [-5.0, -1.0, -0.3, 0.0, 0.5, 1.0, 2.0, 17.0]:
        x, y = inv_stereo(t)
        norm = x * x + y * y
        print(f"  t = {t:6.2f}  ->  ({x:+.6f}, {y:+.6f})   x^2+y^2 = {norm:.12f}")
    print("  All norms equal 1 to machine precision.\n")


# ---------------------------------------------------------------------------
# Demo 2 — Theorem 2.7 / Prop 3.2: injectivity and exact reversibility
# ---------------------------------------------------------------------------

def demo_reversibility() -> None:
    print("=" * 70)
    print("DEMO 2  -  one RG step is information-lossless (sigma is injective)")
    print("=" * 70)
    for t in [-3.7, -0.5, 0.0, 0.25, 1.0, 4.2]:
        x, y = inv_stereo(t)
        t_back = stereo_proj(x, y)
        ok = isclose(t, t_back, abs_tol=1e-12)
        print(f"  t={t:+7.3f} -> sigma -> ({x:+.4f},{y:+.4f}) -> proj -> "
              f"{t_back:+7.3f}   recovered={ok}")
    print("  sigma^{-1}(sigma(t)) = t exactly: no information lost.\n")


# ---------------------------------------------------------------------------
# Demo 3 — Cor 3.5: RG flow = iterated dilation.  (RG_lambda)^n sigma(t)=sigma(lambda^n t)
# ---------------------------------------------------------------------------

def rg_flow_step(point: Tuple[float, float], lam: float) -> Tuple[float, float]:
    """One RG step on the circle: unwrap, scale by lam, re-wrap."""
    t: float = stereo_proj(point[0], point[1])
    return inv_stereo(lam * t)


def demo_rg_iteration() -> None:
    print("=" * 70)
    print("DEMO 3  -  RG flow iteration:  (RG_lambda)^n sigma(t) = sigma(lambda^n t)")
    print("=" * 70)
    t0: float = 0.3
    lam: float = 1.7
    p: Tuple[float, float] = inv_stereo(t0)
    print(f"  start t0 = {t0}, lambda = {lam}")
    for n in range(7):
        direct: Tuple[float, float] = inv_stereo((lam ** n) * t0)
        err: float = abs(p[0] - direct[0]) + abs(p[1] - direct[1])
        print(f"  n={n}: flow=({p[0]:+.6f},{p[1]:+.6f})  "
              f"sigma(lambda^n t)=({direct[0]:+.6f},{direct[1]:+.6f})  err={err:.2e}")
        p = rg_flow_step(p, lam)
    print("  The two agree: iterating the circle flow = scaling the line.\n")


# ---------------------------------------------------------------------------
# Demo 4 — Theorems 3.6/3.7: UV fixed point (0,1) and IR fixed point (0,-1)
# ---------------------------------------------------------------------------

def demo_fixed_points() -> None:
    print("=" * 70)
    print("DEMO 4  -  UV fixed point (0,1) is frozen; orbits flow to IR (0,-1)")
    print("=" * 70)
    lam: float = 2.0
    print("  UV pole sigma(0) = (0,1):")
    p: Tuple[float, float] = inv_stereo(0.0)
    for _ in range(4):
        p = rg_flow_step(p, lam)
    print(f"    after 4 RG steps: ({p[0]:+.6f},{p[1]:+.6f})  (still (0,1))")
    print("  Orbit of sigma(0.1) under lambda=2 streaming toward IR pole (0,-1):")
    p = inv_stereo(0.1)
    for n in [0, 5, 10, 20, 40]:
        q: Tuple[float, float] = inv_stereo((lam ** n) * 0.1)
        print(f"    n={n:3d}: ({q[0]:+.8f}, {q[1]:+.8f})")
    print("    -> approaches (0,-1), the infrared fixed point.\n")


# ---------------------------------------------------------------------------
# Demo 5 — Theorems 4.1-4.3: Euclid's Pythagorean triples from sigma(p/q)
# ---------------------------------------------------------------------------

def euclid_triple(m: int, n: int) -> Tuple[int, int, int]:
    """(2mn, m^2-n^2, m^2+n^2): a Pythagorean triple = sigma(n/m) cleared."""
    return (2 * m * n, m * m - n * n, m * m + n * n)


def demo_pythagorean() -> None:
    print("=" * 70)
    print("DEMO 5  -  rational sigma(p/q) IS Euclid's Pythagorean parametrization")
    print("=" * 70)
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2), (4, 3)]:
        a, b, c = euclid_triple(m, n)
        # Cross-check against sigma(n/m) cleared of denominators.
        x, y = inv_stereo_exact(Fraction(n, m))
        print(f"  (m,n)=({m},{n}): triple ({a:3d},{b:3d},{c:3d})  "
              f"check a^2+b^2-c^2={a*a + b*b - c*c}  "
              f"sigma({n}/{m})=({x},{y})")
    x, y = inv_stereo_exact(Fraction(1, 2))
    print(f"  Famous case: sigma(1/2) = ({x},{y}) = (4/5, 3/5) -> (3,4,5).\n")


# ---------------------------------------------------------------------------
# Demo 6 — Theorems 4.6/4.7: Gaussian / quantum-gate norm multiplicativity
# ---------------------------------------------------------------------------

def gaussian_mul(a: int, b: int, c: int, d: int) -> Tuple[int, int]:
    """Multiply (a+bi)(c+di) = (ac-bd) + (ad+bc)i  (Gaussian matrix compose)."""
    return (a * c - b * d, a * d + b * c)


def demo_two_square_identity() -> None:
    print("=" * 70)
    print("DEMO 6  -  (a^2+b^2)(c^2+d^2) = e^2+f^2  (Gaussian/quantum-gate norms)")
    print("=" * 70)
    for (a, b, c, d) in [(2, 1, 3, 2), (1, 4, 5, 1), (3, 3, 2, 5)]:
        e, f = gaussian_mul(a, b, c, d)
        lhs: int = (a * a + b * b) * (c * c + d * d)
        rhs: int = e * e + f * f
        print(f"  ({a}^2+{b}^2)({c}^2+{d}^2) = {lhs:5d} = {e}^2+{f}^2 = {rhs:5d}  "
              f"-> {lhs == rhs}")
    print("  Composition of Gaussian gates multiplies determinants (norms).\n")


# ---------------------------------------------------------------------------
# Demo 7 — Theorem 4.8: prime census below 100, sorted by residue mod 4
# ---------------------------------------------------------------------------

def is_prime(k: int) -> bool:
    if k < 2:
        return False
    i: int = 2
    while i * i <= k:
        if k % i == 0:
            return False
        i += 1
    return True


def demo_prime_census() -> None:
    print("=" * 70)
    print("DEMO 7  -  primes <= 100 split by residue mod 4 (Fermat two squares)")
    print("=" * 70)
    primes: List[int] = [p for p in range(101) if is_prime(p)]
    one_mod4: List[int] = [p for p in primes if p % 4 == 1]
    three_mod4: List[int] = [p for p in primes if p % 4 == 3]
    print(f"  total primes <= 100        : {len(primes)}   (theorem: 25)")
    print(f"  p = 1 mod 4 (sum of squares): {len(one_mod4)}   (theorem: 11)  {one_mod4}")
    print(f"  p = 3 mod 4 (invisible)     : {len(three_mod4)}   (theorem: 13)  {three_mod4}")
    print("  '1 mod 4' primes have rational preimages on S^1; '3 mod 4' do not.\n")


# ---------------------------------------------------------------------------
# Demo 8 — Theorem 4.13: integer crystallization loss sin^2(pi m)
# ---------------------------------------------------------------------------

def crystallization_loss(m: float) -> float:
    """L(m) = sin^2(pi m): zero exactly at integers, in [0,1] always."""
    return sin(pi * m) ** 2


def demo_crystallization() -> None:
    print("=" * 70)
    print("DEMO 8  -  crystallization loss L(m)=sin^2(pi m): 0 at integers, <=1")
    print("=" * 70)
    for m in [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.999, 4.0]:
        print(f"  m={m:6.3f}  L={crystallization_loss(m):.6f}")
    params: List[float] = [0.1, 0.7, 1.3, 2.0, 2.9]
    total: float = sum(crystallization_loss(p) for p in params)
    print(f"  total over {len(params)} params = {total:.4f}  (bounded by k={len(params)})")
    print("  Crystallized integer weights land on S^1 (Pythagorean-rational).\n")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("\nINVERSE STEREOGRAPHIC RENORMALIZATION — NUMERICAL DEMONSTRATIONS\n")
    demo_on_circle()
    demo_reversibility()
    demo_rg_iteration()
    demo_fixed_points()
    demo_pythagorean()
    demo_two_square_identity()
    demo_prime_census()
    demo_crystallization()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
