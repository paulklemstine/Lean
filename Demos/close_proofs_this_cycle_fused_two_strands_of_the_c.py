"""
Numerical demonstrations for the Hodge-Deligne E-polynomial bridge.

This module is fully self-contained (standard library only) and illustrates,
on concrete Hodge diamonds, the four main results:

  (T1)  E(X; 1, 1) = chi(X)                          [specialization]
  (T2)  E(mirror X; u, v) = (-1)^n u^n E(X; 1/u, v)  [mirror equation]
  (T3)  E(X; u, v) = (uv)^n E(X; 1/u, 1/v)           [Serre equation, if SerreDual]
  (C4)  chi(mirror X) = (-1)^n chi(X)                [numerical mirror sign]
  (C5)  total_dim(mirror X) = total_dim(X)           [mirror invariance]

A Hodge diamond is represented as a dimension n and a function h(p, q) giving
the integer Hodge number h^{p,q} for 0 <= p, q <= n.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable
from fractions import Fraction


# --------------------------------------------------------------------------- #
# Core data type and invariants                                               #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class HodgeDiamond:
    """A Hodge diamond: complex dimension n and Hodge numbers h(p, q)."""
    n: int
    h: Callable[[int, int], int]


def mirror(X: HodgeDiamond) -> HodgeDiamond:
    """Mirror involution: (p, q) |-> (n - p, q)."""
    return HodgeDiamond(n=X.n, h=lambda p, q: X.h(X.n - p, q))


def epoly(X: HodgeDiamond, u: Fraction, v: Fraction) -> Fraction:
    """Hodge-Deligne E-polynomial E(X; u, v) = sum (-1)^{p+q} h^{p,q} u^p v^q."""
    total = Fraction(0)
    for p in range(X.n + 1):
        for q in range(X.n + 1):
            total += Fraction((-1) ** (p + q) * X.h(p, q)) * u ** p * v ** q
    return total


def euler_char(X: HodgeDiamond) -> int:
    """Topological Euler characteristic chi(X) = sum (-1)^{p+q} h^{p,q}."""
    return sum(
        (-1) ** (p + q) * X.h(p, q)
        for p in range(X.n + 1)
        for q in range(X.n + 1)
    )


def total_dim(X: HodgeDiamond) -> int:
    """Total Hodge dimension (total Betti number) sum h^{p,q}."""
    return sum(
        X.h(p, q) for p in range(X.n + 1) for q in range(X.n + 1)
    )


def is_serre_dual(X: HodgeDiamond) -> bool:
    """Check Serre duality h^{p,q} = h^{n-p, n-q} on the support."""
    return all(
        X.h(p, q) == X.h(X.n - p, X.n - q)
        for p in range(X.n + 1)
        for q in range(X.n + 1)
    )


# --------------------------------------------------------------------------- #
# Example diamonds                                                            #
# --------------------------------------------------------------------------- #
def diamond_from_table(table: list[list[int]]) -> HodgeDiamond:
    """Build a diamond from an (n+1) x (n+1) table with table[p][q] = h^{p,q}."""
    n = len(table) - 1
    return HodgeDiamond(n=n, h=lambda p, q: table[p][q])


# Elliptic curve (n = 1): h^{0,0}=h^{1,1}=1, h^{1,0}=h^{0,1}=1.  chi = 0.
ELLIPTIC_CURVE = diamond_from_table([[1, 1],
                                     [1, 1]])

# A K3 surface (n = 2).  Hodge diamond:
#   h^{0,0}=1, h^{2,0}=h^{0,2}=1, h^{1,1}=20, h^{2,2}=1, ...   chi = 24.
K3_SURFACE = diamond_from_table([[1, 0, 1],
                                 [0, 20, 0],
                                 [1, 0, 1]])

# The quintic Calabi-Yau threefold (n = 3): h^{1,1}=1, h^{2,1}=101.
#   Full diamond (Serre-dual, Hodge-symmetric).  chi = 2(1 - 101) = -200.
QUINTIC = diamond_from_table([[1, 0, 0, 1],
                              [0, 1, 101, 0],
                              [0, 101, 1, 0],
                              [1, 0, 0, 1]])


# --------------------------------------------------------------------------- #
# Verification routines                                                       #
# --------------------------------------------------------------------------- #
def check_specialization(X: HodgeDiamond) -> bool:
    """T1: E(X; 1, 1) = chi(X)."""
    return epoly(X, Fraction(1), Fraction(1)) == Fraction(euler_char(X))


def check_mirror_equation(X: HodgeDiamond, u: Fraction, v: Fraction) -> bool:
    """T2: E(mirror X; u, v) = (-1)^n u^n E(X; 1/u, v)."""
    lhs = epoly(mirror(X), u, v)
    rhs = Fraction((-1) ** X.n) * u ** X.n * epoly(X, 1 / u, v)
    return lhs == rhs


def check_serre_equation(X: HodgeDiamond, u: Fraction, v: Fraction) -> bool:
    """T3: E(X; u, v) = (uv)^n E(X; 1/u, 1/v), assuming SerreDual."""
    lhs = epoly(X, u, v)
    rhs = (u * v) ** X.n * epoly(X, 1 / u, 1 / v)
    return lhs == rhs


def check_mirror_sign(X: HodgeDiamond) -> bool:
    """C4: chi(mirror X) = (-1)^n chi(X)."""
    return euler_char(mirror(X)) == (-1) ** X.n * euler_char(X)


def check_total_dim_invariance(X: HodgeDiamond) -> bool:
    """C5: total_dim(mirror X) = total_dim(X)."""
    return total_dim(mirror(X)) == total_dim(X)


# --------------------------------------------------------------------------- #
# Driver                                                                      #
# --------------------------------------------------------------------------- #
def report(name: str, X: HodgeDiamond) -> None:
    print(f"=== {name}  (n = {X.n}) ===")
    print(f"  chi(X)            = {euler_char(X)}")
    print(f"  total_dim(X)      = {total_dim(X)}")
    print(f"  Serre-dual?       = {is_serre_dual(X)}")
    print(f"  chi(mirror X)     = {euler_char(mirror(X))}")
    print(f"  expected (-1)^n*chi = {(-1) ** X.n * euler_char(X)}")

    u, v = Fraction(2), Fraction(3)  # arbitrary nonzero test point
    print(f"  [T1] E(X;1,1)=chi(X)                : {check_specialization(X)}")
    print(f"  [T2] mirror eq at (u,v)=(2,3)       : {check_mirror_equation(X, u, v)}")
    if is_serre_dual(X):
        print(f"  [T3] Serre eq at (u,v)=(2,3)        : {check_serre_equation(X, u, v)}")
    print(f"  [C4] chi(mirror)=(-1)^n chi         : {check_mirror_sign(X)}")
    print(f"  [C5] total_dim mirror-invariant     : {check_total_dim_invariance(X)}")
    print()


def main() -> None:
    print("Hodge-Deligne E-polynomial: numerical verification of the main results\n")
    report("Elliptic curve", ELLIPTIC_CURVE)
    report("K3 surface", K3_SURFACE)
    report("Quintic Calabi-Yau threefold", QUINTIC)

    # Spot-check the mirror equation at several points and several diamonds.
    print("Stress test: mirror equation over many points")
    points = [(Fraction(a), Fraction(b))
              for a in (1, 2, -3, Fraction(1, 2))
              for b in (1, 5, -2, Fraction(2, 3))]
    for name, X in [("elliptic", ELLIPTIC_CURVE),
                    ("K3", K3_SURFACE),
                    ("quintic", QUINTIC)]:
        ok = all(check_mirror_equation(X, u, v) for u, v in points)
        print(f"  {name:8s}: all {len(points)} points pass mirror eq = {ok}")

    # Highlight the odd-dimensional sign flip for the quintic (n = 3).
    print("\nMirror sign flip (Calabi-Yau threefold, n = 3 is odd):")
    print(f"  chi(quintic)        = {euler_char(QUINTIC)}")
    print(f"  chi(mirror quintic) = {euler_char(mirror(QUINTIC))}")
    print("  -> mirror partners have opposite Euler characteristics.")


if __name__ == "__main__":
    main()
