"""
Arithmetic on the Möbius Band: numerical demonstrations.

We model the Möbius band as the quotient of R x R by the gluing
    (0, y) ~ (1, -y),
and study the value map
    phi(x, y) = y * (2*x - 1).

This script demonstrates, purely numerically, the four core facts:

  1. phi descends to the quotient (well-definedness across the gluing).
  2. phi is surjective onto R.
  3. The twist  tau([x, y]) = [1 - x, y]  acts as exact negation on values,
     is an involution, and fixes exactly the central circle x = 1/2.
  4. The proposed integer embedding  n -> (1/2 + 1/(2n), |n|)  COLLAPSES:
     its value is sign(n), so Z maps onto the two-point set {-1, +1}.

Everything is self-contained; run with:  python demo.py
"""

from __future__ import annotations

from typing import List, Tuple


# ----------------------------------------------------------------------
# Core maps
# ----------------------------------------------------------------------

def value(x: float, y: float) -> float:
    """The value function phi(x, y) = y * (2x - 1) on a representative."""
    return y * (2.0 * x - 1.0)


def glue_partner(x: float, y: float) -> Tuple[float, float]:
    """
    Return the glued partner of a boundary representative, if any.
    (0, y) ~ (1, -y) and (1, y) ~ (0, -y). Interior points return themselves.
    """
    if x == 0.0:
        return (1.0, -y)
    if x == 1.0:
        return (0.0, -y)
    return (x, y)


def twist(x: float, y: float) -> Tuple[float, float]:
    """The twist involution on representatives: (x, y) -> (1 - x, y)."""
    return (1.0 - x, y)


def sign_int(n: int) -> int:
    """Integer sign function: -1, 0, or +1."""
    return (n > 0) - (n < 0)


def embed(n: int) -> Tuple[float, float]:
    """
    The proposed integer embedding  n -> (1/2 + 1/(2n), |n|)  for n != 0.
    """
    if n == 0:
        raise ValueError("embedding is defined for nonzero integers")
    return (0.5 + 1.0 / (2.0 * n), float(abs(n)))


# ----------------------------------------------------------------------
# Demonstration 1: well-definedness across the gluing
# ----------------------------------------------------------------------

def demo_well_defined() -> None:
    print("=" * 66)
    print("1. Well-definedness: phi agrees on glued boundary partners")
    print("=" * 66)
    for y in (-3.0, -1.0, 0.0, 2.5, 7.0):
        x = 0.0
        xp, yp = glue_partner(x, y)
        v1, v2 = value(x, y), value(xp, yp)
        print(f"  phi(0, {y:+.1f}) = {v1:+.3f}   "
              f"phi(1, {-y:+.1f}) = {v2:+.3f}   match={abs(v1 - v2) < 1e-12}")
    print()


# ----------------------------------------------------------------------
# Demonstration 2: surjectivity
# ----------------------------------------------------------------------

def preimage(r: float) -> Tuple[float, float]:
    """A representative whose value is r: (1, r) if r >= 0 else (0, -r)."""
    return (1.0, r) if r >= 0.0 else (0.0, -r)


def demo_surjective() -> None:
    print("=" * 66)
    print("2. Surjectivity: every real r is hit by an explicit point")
    print("=" * 66)
    for r in (-4.2, -1.0, 0.0, 0.7, 3.14159):
        x, y = preimage(r)
        v = value(x, y)
        print(f"  r = {r:+.5f}  ->  point ({x:.1f}, {y:+.5f})  ->  phi = {v:+.5f}"
              f"   ok={abs(v - r) < 1e-12}")
    print()


# ----------------------------------------------------------------------
# Demonstration 3: the twist is negation, an involution, fixes x = 1/2
# ----------------------------------------------------------------------

def demo_twist() -> None:
    print("=" * 66)
    print("3. Twist: phi(twist(z)) = -phi(z); twist^2 = id; fixes x = 1/2")
    print("=" * 66)
    samples: List[Tuple[float, float]] = [
        (0.2, 3.0), (0.75, -1.5), (0.5, 4.0), (0.9, 2.0), (0.1, -6.0)
    ]
    for (x, y) in samples:
        tx, ty = twist(x, y)
        v, tv = value(x, y), value(tx, ty)
        ttx, tty = twist(tx, ty)
        neg_ok = abs(tv + v) < 1e-12
        inv_ok = abs(ttx - x) < 1e-12 and abs(tty - y) < 1e-12
        fixed = abs(x - 0.5) < 1e-12
        print(f"  z=({x:.2f},{y:+.1f})  phi={v:+.2f}  phi(tw)={tv:+.2f}  "
              f"neg={neg_ok}  involutive={inv_ok}  fixed_by_twist={fixed}")
    print("  -> the only fixed points are those with x = 1/2 (the central circle),")
    print("     where phi = 0.\n")


# ----------------------------------------------------------------------
# Demonstration 4: the collapse of the "Möbius integers"
# ----------------------------------------------------------------------

def demo_collapse() -> None:
    print("=" * 66)
    print("4. Collapse: value(embed(n)) = sign(n), so Z -> {-1, +1}")
    print("=" * 66)
    ns = [-100, -6, -3, -2, -1, 1, 2, 3, 6, 100]
    image = set()
    for n in ns:
        x, y = embed(n)
        v = value(x, y)
        image.add(round(v))
        print(f"  n = {n:+4d}  ->  ({x:.6f}, {y:6.1f})  ->  phi = {v:+.3f}"
              f"   sign(n) = {sign_int(n):+d}   match={abs(v - sign_int(n)) < 1e-9}")
    print(f"\n  image of the embedding over these integers: {sorted(image)}")
    v1, v2 = value(*embed(1)), value(*embed(2))
    print(f"  value(embed(1)) = {v1:+.1f}, value(embed(2)) = {v2:+.1f}"
          f"  ->  equal though 1 != 2  =>  NOT injective")
    print("  Consequence: magnitude is erased; 2, 3, 6 are indistinguishable,")
    print("  so there is no ring, no factorization, and no 'twist prime'.\n")


# ----------------------------------------------------------------------
# Demonstration 5: the zero fibre
# ----------------------------------------------------------------------

def demo_zero_fibre() -> None:
    print("=" * 66)
    print("5. Zero fibre: phi([x,y]) = 0  iff  y = 0  or  x = 1/2")
    print("=" * 66)
    tests: List[Tuple[float, float]] = [
        (0.3, 0.0), (0.5, 9.0), (0.5, 0.0), (0.8, 2.0), (0.0, 5.0)
    ]
    for (x, y) in tests:
        v = value(x, y)
        predicted_zero = (y == 0.0) or (x == 0.5)
        print(f"  ({x:.1f}, {y:+.1f})  phi = {v:+.2f}  is_zero={abs(v) < 1e-12}"
              f"  predicted_zero={predicted_zero}")
    print()


def main() -> None:
    demo_well_defined()
    demo_surjective()
    demo_twist()
    demo_collapse()
    demo_zero_fibre()
    print("All demonstrations complete: the twist is negation (a Z/2 grading),")
    print("but the integer embedding collapses to the sign, so no number system.")


if __name__ == "__main__":
    main()
