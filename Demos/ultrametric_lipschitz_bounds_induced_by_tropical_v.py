"""
Numerical demonstrations for:

    Ultrametric Lipschitz Bounds Induced by Tropical Valuations
    on Arithmetic Height Spaces

This script is fully self-contained (standard library only). It illustrates,
with concrete rational numbers:

  1. The arithmetic height  height(q) = |num(q)| + den(q)  and its basic laws.
  2. The FALSIFIER: the height is NOT an ultranorm; the strong (max-form)
     triangle inequality fails already at 1 + 1.
  3. The corrected object: the p-adic absolute value as a rational
     ultravaluation, and the induced ultradistance.
  4. The strong triangle law for the induced ultradistance (every triangle
     is isosceles).
  5. The BRIDGE THEOREM: additive-on-differences + valuation-monotone maps
     are nonexpansive (integer scaling, integer affine maps).
  6. Compositional closure (nonexpansive / Lipschitz constants multiply).
  7. The height/valuation comparison  p^{v_p(|n|)} <= height(n).

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. Arithmetic height
# ---------------------------------------------------------------------------
def arith_height(q: Fraction) -> int:
    """Arithmetic height height(q) = |numerator| + denominator (lowest terms)."""
    q = Fraction(q)  # normalizes to lowest terms with positive denominator
    return abs(q.numerator) + q.denominator


# ---------------------------------------------------------------------------
# 2. p-adic valuation and absolute value
# ---------------------------------------------------------------------------
def p_adic_valuation(n: int, p: int) -> int:
    """v_p(n): exponent of the prime p in |n| (n != 0)."""
    if n == 0:
        raise ValueError("p-adic valuation of 0 is +infinity")
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def p_adic_abs(q: Fraction, p: int) -> Fraction:
    """p-adic absolute value |q|_p = p^{-v_p(q)}, with |0|_p = 0."""
    q = Fraction(q)
    if q == 0:
        return Fraction(0)
    v = p_adic_valuation(q.numerator, p) - p_adic_valuation(q.denominator, p)
    return Fraction(p) ** (-v)


# ---------------------------------------------------------------------------
# 3. Induced ultradistance  dist(x, y) = val(x - y)
# ---------------------------------------------------------------------------
def ultradistance(x: Fraction, y: Fraction, p: int) -> Fraction:
    """p-adic ultradistance dist_p(x, y) = |x - y|_p."""
    return p_adic_abs(Fraction(x) - Fraction(y), p)


# ---------------------------------------------------------------------------
# Regularity predicates
# ---------------------------------------------------------------------------
def is_nonexpansive(
    f: Callable[[Fraction], Fraction], p: int, samples: List[Fraction]
) -> bool:
    """Check dist(f x, f y) <= dist(x, y) on all sample pairs."""
    return all(
        ultradistance(f(x), f(y), p) <= ultradistance(x, y, p)
        for x, y in product(samples, samples)
    )


def lipschitz_constant(
    f: Callable[[Fraction], Fraction], p: int, samples: List[Fraction]
) -> Fraction:
    """Empirical best (smallest) Lipschitz constant over the sample pairs."""
    best = Fraction(0)
    for x, y in product(samples, samples):
        d_in = ultradistance(x, y, p)
        if d_in == 0:
            continue
        ratio = ultradistance(f(x), f(y), p) / d_in
        best = max(best, ratio)
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_height_laws() -> None:
    print("=" * 70)
    print("1. Arithmetic height  height(q) = |num| + den")
    print("=" * 70)
    for q in [Fraction(0), Fraction(1), Fraction(3, 4), Fraction(-3, 4),
              Fraction(1, 1000), Fraction(7, 2)]:
        print(f"  height({str(q):>8}) = {arith_height(q):>4}    "
              f"height(-q) = {arith_height(-q):>4}  (sign-blind: "
              f"{arith_height(q) == arith_height(-q)})")
    print(f"  height(0) = {arith_height(Fraction(0))} (>= 1 always)\n")


def demo_falsifier() -> None:
    print("=" * 70)
    print("2. FALSIFIER: the height is NOT an ultranorm (fails at 1 + 1)")
    print("=" * 70)
    q = Fraction(1)
    r = Fraction(1)
    lhs = arith_height(q + r)
    rhs = max(arith_height(q), arith_height(r))
    print(f"  height(1 + 1) = height(2) = {lhs}")
    print(f"  max(height(1), height(1)) = {rhs}")
    print(f"  strong triangle law  {lhs} <= {rhs}  ?  {lhs <= rhs}")
    print("  --> FALSE. The archimedean height records the growth of 1+1=2,")
    print("      which the ultrametric law forbids.\n")


def demo_padic_ultravaluation() -> None:
    print("=" * 70)
    print("3. Corrected object: the p-adic absolute value is an ultravaluation")
    print("=" * 70)
    p = 2
    print(f"  prime p = {p}")
    for q in [Fraction(8), Fraction(1, 2), Fraction(3), Fraction(1, 8),
              Fraction(12), Fraction(0)]:
        print(f"  |{str(q):>5}|_{p} = {str(p_adic_abs(q, p)):>6}")
    # strong triangle law as an ultravaluation axiom
    print("\n  strong triangle law  |x+y|_p <= max(|x|_p,|y|_p):")
    for x, y in [(Fraction(2), Fraction(6)), (Fraction(1), Fraction(3)),
                 (Fraction(1, 2), Fraction(1, 4))]:
        lhs = p_adic_abs(x + y, p)
        rhs = max(p_adic_abs(x, p), p_adic_abs(y, p))
        print(f"    x={str(x):>5}, y={str(y):>5}:  {str(lhs):>5} <= "
              f"{str(rhs):>5}  -> {lhs <= rhs}")
    print()


def demo_strong_triangle_isosceles() -> None:
    print("=" * 70)
    print("4. Ultradistance: strong triangle law & isosceles triangles")
    print("=" * 70)
    p = 3
    pts = [Fraction(1), Fraction(4), Fraction(13), Fraction(2)]
    ok = True
    for x, y, z in product(pts, pts, pts):
        d_xz = ultradistance(x, z, p)
        d_xy = ultradistance(x, y, p)
        d_yz = ultradistance(y, z, p)
        ok &= d_xz <= max(d_xy, d_yz)
    print(f"  strong triangle law holds on all triples (p={p}): {ok}")
    # demonstrate isosceles property on one triangle
    x, y, z = Fraction(1), Fraction(4), Fraction(13)
    sides = sorted([ultradistance(x, y, p),
                    ultradistance(y, z, p),
                    ultradistance(x, z, p)])
    print(f"  triangle (1,4,13) sides sorted = {[str(s) for s in sides]}")
    print(f"  two largest equal (isosceles)?  {sides[1] == sides[2]}\n")


def demo_bridge_theorem() -> None:
    print("=" * 70)
    print("5. BRIDGE THEOREM: integer maps are certified nonexpansive")
    print("=" * 70)
    p = 5
    samples = [Fraction(a, b) for a in range(-6, 7) for b in (1, 2, 5, 25)]
    # integer scaling: f(q) = m*q
    for m in (5, 25, -3, 1):
        f = (lambda m: (lambda q: m * q))(m)
        print(f"  f(q) = {m:>3}*q          nonexpansive (p={p}): "
              f"{is_nonexpansive(f, p, samples)}")
    # integer affine: f(q) = m*q + c
    for m, c in ((2, 7), (10, -3)):
        f = (lambda m, c: (lambda q: m * q + c))(m, c)
        print(f"  f(q) = {m:>3}*q + {c:<3}    nonexpansive (p={p}): "
              f"{is_nonexpansive(f, p, samples)}")
    # sharpness: scaling by 1/p (val > 1) is NOT nonexpansive
    g = lambda q: q / p
    print(f"  g(q) = q/{p}            nonexpansive (p={p}): "
          f"{is_nonexpansive(g, p, samples)}  (expansive: violates monotonicity)")
    print(f"     -> its Lipschitz constant = {lipschitz_constant(g, p, samples)}\n")


def demo_composition() -> None:
    print("=" * 70)
    print("6. Compositional closure (constants multiply)")
    print("=" * 70)
    p = 2
    samples = [Fraction(a, b) for a in range(-6, 7) for b in (1, 2, 4)]
    f = lambda q: 2 * q + 3          # nonexpansive
    g = lambda q: 4 * q - 1          # nonexpansive
    gf = lambda q: g(f(q))
    print(f"  f nonexpansive: {is_nonexpansive(f, p, samples)}")
    print(f"  g nonexpansive: {is_nonexpansive(g, p, samples)}")
    print(f"  g . f nonexpansive: {is_nonexpansive(gf, p, samples)}")
    # Lipschitz constants multiply for expansive maps
    h1 = lambda q: q / 2             # Lipschitz const 2 at p=2
    h2 = lambda q: q / 4             # Lipschitz const 4 at p=2
    c1 = lipschitz_constant(h1, p, samples)
    c2 = lipschitz_constant(h2, p, samples)
    c12 = lipschitz_constant(lambda q: h2(h1(q)), p, samples)
    print(f"  Lip(h1)={c1}, Lip(h2)={c2}, Lip(h2.h1)={c12}, product={c1*c2}, "
          f"matches: {c12 == c1 * c2}\n")


def demo_height_comparison() -> None:
    print("=" * 70)
    print("7. Height/valuation comparison  p^{v_p(|n|)} <= height(n)")
    print("=" * 70)
    for p in (2, 3, 5):
        ok = True
        for n in range(1, 200):
            lhs = p ** p_adic_valuation(n, p)
            rhs = arith_height(Fraction(n))
            ok &= lhs <= rhs
        print(f"  p={p}: p^v_p(|n|) <= height(n) for n in 1..199 -> {ok}")
    # integer boundedness: dist_p(a,b) <= 1 for integers
    p = 7
    bounded = all(
        ultradistance(Fraction(a), Fraction(b), p) <= 1
        for a in range(-10, 11) for b in range(-10, 11)
    )
    print(f"  integers lie in the unit ball (p={p}): {bounded}\n")


def main() -> None:
    demo_height_laws()
    demo_falsifier()
    demo_padic_ultravaluation()
    demo_strong_triangle_isosceles()
    demo_bridge_theorem()
    demo_composition()
    demo_height_comparison()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""Visualization: the p-adic ultrametric vs the archimedean line.
Generates three panels:
  (a) p-adic distance from 0 vs the archimedean |n| for n = 0..63 (p=2),
  (b) the isosceles property: histogram of (2nd largest - largest) side over
      random triangles (always 0 in an ultrametric),
  (c) nonexpansiveness of f(q)=2q+3 vs expansiveness of g(q)=q/2 (p=2).
Requires matplotlib. Run:  python visualization.py
"""
from fractions import Fraction
from itertools import product
import random
import matplotlib.pyplot as plt


def vp(n: int, p: int) -> int:
    n = abs(n); v = 0
    while n and n % p == 0:
        n //= p; v += 1
    return v


def pabs(q: Fraction, p: int) -> Fraction:
    q = Fraction(q)
    if q == 0:
        return Fraction(0)
    return Fraction(p) ** (-(vp(q.numerator, p) - vp(q.denominator, p)))


def dist(x, y, p):
    return float(pabs(Fraction(x) - Fraction(y), p))


p = 2
fig, ax = plt.subplots(1, 3, figsize=(16, 4.5))

# (a) p-adic size vs archimedean size
ns = list(range(1, 64))
ax[0].stem(ns, [float(pabs(Fraction(n), p)) for n in ns])
ax[0].set_title(f"p-adic size |n|_{p} (highly divisible -> tiny)")
ax[0].set_xlabel("n"); ax[0].set_ylabel(f"|n|_{p}")

# (b) isosceles property
pts = [Fraction(n) for n in range(0, 64)]
gaps = []
for _ in range(4000):
    x, y, z = random.sample(pts, 3)
    s = sorted([dist(x, y, p), dist(y, z, p), dist(x, z, p)])
    gaps.append(s[2] - s[1])
ax[1].hist(gaps, bins=20)
ax[1].set_title("Every triangle is isosceles\n(largest - 2nd largest side)")
ax[1].set_xlabel("difference of two largest sides")

# (c) nonexpansive vs expansive
samples = [Fraction(a, b) for a in range(-8, 9) for b in (1, 2, 4)]
f = lambda q: 2 * q + 3
g = lambda q: q / 2
din, dfo, dgo = [], [], []
for x, y in product(samples, samples):
    d = dist(x, y, p)
    if d == 0:
        continue
    din.append(d); dfo.append(dist(f(x), f(y), p)); dgo.append(dist(g(x), g(y), p))
ax[2].scatter(din, dfo, s=8, label="f(q)=2q+3 (nonexpansive)")
ax[2].scatter(din, dgo, s=8, label="g(q)=q/2 (expansive)")
lim = max(din + dfo + dgo)
ax[2].plot([0, lim], [0, lim], "k--", label="y = x")
ax[2].set_xlabel("input distance"); ax[2].set_ylabel("output distance")
ax[2].set_title("Bridge theorem in action"); ax[2].legend()

plt.tight_layout()
plt.savefig("ultrametric_bridge.png", dpi=140)
print("wrote ultrametric_bridge.png")
