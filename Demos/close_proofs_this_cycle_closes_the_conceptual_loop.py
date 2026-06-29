"""
demo.py — Numerical demonstrations of the Hodge–Deligne E-polynomial bridge.

This script is fully self-contained (standard library only) and uses exact
rational arithmetic (`fractions.Fraction`) so that every identity is verified
*exactly*, not up to floating-point error.

It demonstrates, on a combinatorial model of a Hodge diamond:

  * Definition of the two-variable E-polynomial
        E(X; u, v) = sum_{p,q=0..n} (-1)^(p+q) h^{p,q} u^p v^q
  * The collapse identity              E(X; 1, 1) = chi(X)
  * The mirror functional equation     E(X^; u, v) = (-1)^n u^n E(X; 1/u, v)
  * The Serre functional equation      E(X; u, v) = (uv)^n E(X; 1/u, 1/v)
  * The mirror sign law                chi(X^) = (-1)^n chi(X)
  * Mirror-invariance of total dim     td(X^) = td(X)

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Tuple

# A Hodge diamond is modeled as (n, h) where
#   n : complex dimension
#   h : dict mapping (p, q) -> Hodge number (int), defaulting to 0.
HodgeNumbers = Dict[Tuple[int, int], int]
HodgeDiamond = Tuple[int, HodgeNumbers]


# --------------------------------------------------------------------------- #
# Core definitions (inlined)                                                   #
# --------------------------------------------------------------------------- #
def h_of(diamond: HodgeDiamond, p: int, q: int) -> int:
    """Hodge number h^{p,q}; 0 outside the recorded support."""
    _n, h = diamond
    return h.get((p, q), 0)


def epoly(diamond: HodgeDiamond, u: Fraction, v: Fraction) -> Fraction:
    """E(X; u, v) = sum_{p,q=0..n} (-1)^(p+q) h^{p,q} u^p v^q."""
    n, _h = diamond
    total = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * h_of(diamond, p, q) * (u ** p) * (v ** q)
    return total


def euler_char(diamond: HodgeDiamond) -> int:
    """chi(X) = sum_{p,q=0..n} (-1)^(p+q) h^{p,q}."""
    n, _h = diamond
    total = 0
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * h_of(diamond, p, q)
    return total


def total_dim(diamond: HodgeDiamond) -> int:
    """td(X) = sum_{p,q=0..n} h^{p,q} (total Betti number)."""
    n, _h = diamond
    return sum(h_of(diamond, p, q) for p in range(n + 1) for q in range(n + 1))


def mirror(diamond: HodgeDiamond) -> HodgeDiamond:
    """Mirror diamond X^: (p,q) -> h^{n-p, q}."""
    n, _h = diamond
    new_h: HodgeNumbers = {}
    for p in range(n + 1):
        for q in range(n + 1):
            val = h_of(diamond, n - p, q)
            if val != 0:
                new_h[(p, q)] = val
    return (n, new_h)


def is_serre_dual(diamond: HodgeDiamond) -> bool:
    """Check h^{p,q} = h^{n-p, n-q} on the support 0 <= p,q <= n."""
    n, _h = diamond
    return all(
        h_of(diamond, p, q) == h_of(diamond, n - p, n - q)
        for p in range(n + 1)
        for q in range(n + 1)
    )


# --------------------------------------------------------------------------- #
# Example Hodge diamonds                                                       #
# --------------------------------------------------------------------------- #
def elliptic_curve() -> HodgeDiamond:
    """Genus-1 curve (complex torus), n = 1, chi = 0."""
    return (1, {(0, 0): 1, (1, 0): 1, (0, 1): 1, (1, 1): 1})


def k3_surface() -> HodgeDiamond:
    """K3 surface, n = 2, chi = 24."""
    return (2, {(0, 0): 1, (2, 0): 1, (0, 2): 1, (2, 2): 1, (1, 1): 20})


def quintic_threefold() -> HodgeDiamond:
    """Quintic Calabi-Yau 3-fold, n = 3, chi = -200."""
    h: HodgeNumbers = {
        (0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,   # h^{0,0}, h^{3,3}, h^{0,3}, h^{3,0}
        (1, 1): 1, (2, 2): 1,                          # h^{1,1} = h^{2,2} = 1
        (2, 1): 101, (1, 2): 101,                      # h^{2,1} = h^{1,2} = 101
    }
    return (3, h)


# --------------------------------------------------------------------------- #
# Verification helpers                                                         #
# --------------------------------------------------------------------------- #
SAMPLE_POINTS: List[Tuple[Fraction, Fraction]] = [
    (Fraction(2), Fraction(3)),
    (Fraction(5), Fraction(-7)),
    (Fraction(1, 2), Fraction(4)),
    (Fraction(-3), Fraction(2, 5)),
    (Fraction(7), Fraction(7)),
]


def check_collapse(diamond: HodgeDiamond) -> bool:
    """E(X; 1, 1) == chi(X)."""
    return epoly(diamond, Fraction(1), Fraction(1)) == euler_char(diamond)


def check_mirror_equation(diamond: HodgeDiamond) -> bool:
    """E(X^; u, v) == (-1)^n u^n E(X; 1/u, v) at all sample points (u != 0)."""
    n, _h = diamond
    Xv = mirror(diamond)
    sign = -1 if n % 2 else 1
    for u, v in SAMPLE_POINTS:
        if u == 0:
            continue
        lhs = epoly(Xv, u, v)
        rhs = sign * (u ** n) * epoly(diamond, 1 / u, v)
        if lhs != rhs:
            return False
    return True


def check_serre_equation(diamond: HodgeDiamond) -> bool:
    """E(X; u, v) == (uv)^n E(X; 1/u, 1/v) at all sample points (u,v != 0)."""
    n, _h = diamond
    if not is_serre_dual(diamond):
        return False
    for u, v in SAMPLE_POINTS:
        if u == 0 or v == 0:
            continue
        lhs = epoly(diamond, u, v)
        rhs = ((u * v) ** n) * epoly(diamond, 1 / u, 1 / v)
        if lhs != rhs:
            return False
    return True


def check_sign_law(diamond: HodgeDiamond) -> bool:
    """chi(X^) == (-1)^n chi(X)."""
    n, _h = diamond
    sign = -1 if n % 2 else 1
    return euler_char(mirror(diamond)) == sign * euler_char(diamond)


def check_total_dim_invariant(diamond: HodgeDiamond) -> bool:
    """td(X^) == td(X)."""
    return total_dim(mirror(diamond)) == total_dim(diamond)


# --------------------------------------------------------------------------- #
# Driver                                                                       #
# --------------------------------------------------------------------------- #
def report(name: str, diamond: HodgeDiamond) -> None:
    n, _h = diamond
    print(f"=== {name}  (n = {n}) ===")
    print(f"  chi(X)            = {euler_char(diamond)}")
    print(f"  chi(mirror X)     = {euler_char(mirror(diamond))}")
    print(f"  total dim td(X)   = {total_dim(diamond)}")
    print(f"  td(mirror X)      = {total_dim(mirror(diamond))}")
    print(f"  Serre self-dual   = {is_serre_dual(diamond)}")
    print(f"  [Thm 3.1] E(X;1,1) = chi(X)          : {check_collapse(diamond)}")
    print(f"  [Thm 3.2] mirror functional equation : {check_mirror_equation(diamond)}")
    serre_ok = check_serre_equation(diamond) if is_serre_dual(diamond) else None
    print(f"  [Thm 3.3] Serre  functional equation : {serre_ok}")
    print(f"  [Thm 3.4] mirror sign law            : {check_sign_law(diamond)}")
    print(f"  [Prop 3.5] td mirror-invariant       : {check_total_dim_invariant(diamond)}")
    print()


def main() -> None:
    examples: List[Tuple[str, HodgeDiamond]] = [
        ("Elliptic curve", elliptic_curve()),
        ("K3 surface", k3_surface()),
        ("Quintic threefold", quintic_threefold()),
    ]
    for name, diamond in examples:
        report(name, diamond)

    # Spotlight: the quintic / mirror sign reversal (-200 -> +200).
    X = quintic_threefold()
    Xv = mirror(X)
    print("Spotlight — quintic mirror pair:")
    print(f"  chi(quintic)        = {euler_char(X)}")
    print(f"  chi(mirror quintic) = {euler_char(Xv)}")
    print(f"  (-1)^3 * chi(X)     = {(-1) ** 3 * euler_char(X)}")
    print(f"  h^(1,1), h^(2,1) of X  : {h_of(X, 1, 1)}, {h_of(X, 2, 1)}")
    print(f"  h^(1,1), h^(2,1) of X^ : {h_of(Xv, 1, 1)}, {h_of(Xv, 2, 1)}")


if __name__ == "__main__":
    main()
