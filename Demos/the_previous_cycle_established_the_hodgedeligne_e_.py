"""
demo.py — The Hodge–Deligne E-polynomial as a Motivic Measure
=============================================================

Self-contained numerical demonstrations of the structural laws proved in
`Catalog/Bridges/HodgeEPolynomial.lean`:

    E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} u^p v^q

We model an abstract Hodge diamond as (dim, h) with h : (p, q) -> int, and we
verify, on explicit examples, every headline theorem:

    * epoly_directSum            E(X ⊕ Y) = E(X) + E(Y)
    * epoly_kunneth              E(X ⊗ Y) = E(X) · E(Y)
    * eulerChar_kunneth          χ(X ⊗ Y) = χ(X) · χ(Y)
    * epoly_tateTwist            E(X(1)) = uv · E(X)
    * epoly_serre_functional_eq  E(X; u, v) = (uv)^n E(X; 1/u, 1/v)
    * poincare_serre_palindrome  P(X; t) = t^{2n} P(X; 1/t)

Everything is exact: E-polynomials are represented as dictionaries
{(p, q): integer coefficient}, and equality is exact dictionary equality.
No third-party dependencies; standard library only.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, Tuple

# A bivariate polynomial is a map (p, q) -> coefficient (Fraction), with zero
# coefficients omitted by convention.
Poly = Dict[Tuple[int, int], Fraction]


@dataclass(frozen=True)
class HodgeDiamond:
    """An abstract Hodge diamond: complex dimension `dim` and Hodge numbers `h`.

    `h(p, q)` returns the integer Hodge number h^{p,q}; entries outside the
    range 0..dim are expected to be 0 for a *supported* diamond.
    """

    dim: int
    h: Callable[[int, int], int]

    def is_supported(self) -> bool:
        """Check support: h^{p,q} = 0 whenever p > dim or q > dim (within a margin)."""
        for p in range(0, self.dim + 4):
            for q in range(0, self.dim + 4):
                if (p > self.dim or q > self.dim) and self.h(p, q) != 0:
                    return False
        return True


# --------------------------------------------------------------------------- #
# Core invariants                                                             #
# --------------------------------------------------------------------------- #
def epoly(x: HodgeDiamond) -> Poly:
    """The Hodge–Deligne E-polynomial E(X; u, v) as a coefficient dictionary."""
    result: Poly = {}
    for p in range(x.dim + 1):
        for q in range(x.dim + 1):
            coeff = ((-1) ** (p + q)) * x.h(p, q)
            if coeff != 0:
                key = (p, q)
                result[key] = result.get(key, Fraction(0)) + Fraction(coeff)
    return {k: v for k, v in result.items() if v != 0}


def euler_char(x: HodgeDiamond) -> int:
    """The Euler characteristic χ(X) = E(X; 1, 1) = Σ (-1)^{p+q} h^{p,q}."""
    return sum(((-1) ** (p + q)) * x.h(p, q)
               for p in range(x.dim + 1) for q in range(x.dim + 1))


def eval_poly(poly: Poly, u: Fraction, v: Fraction) -> Fraction:
    """Evaluate a bivariate polynomial at (u, v)."""
    return sum((c * (u ** p) * (v ** q) for (p, q), c in poly.items()),
               start=Fraction(0))


# --------------------------------------------------------------------------- #
# Polynomial arithmetic (exact)                                              #
# --------------------------------------------------------------------------- #
def poly_add(a: Poly, b: Poly) -> Poly:
    out: Poly = dict(a)
    for key, c in b.items():
        out[key] = out.get(key, Fraction(0)) + c
    return {k: v for k, v in out.items() if v != 0}


def poly_mul(a: Poly, b: Poly) -> Poly:
    """Cauchy product of two bivariate polynomials (the engine `cauchy_prod_2D`)."""
    out: Poly = {}
    for (p1, q1), c1 in a.items():
        for (p2, q2), c2 in b.items():
            key = (p1 + p2, q1 + q2)
            out[key] = out.get(key, Fraction(0)) + c1 * c2
    return {k: v for k, v in out.items() if v != 0}


def poly_scale_monomial(a: Poly, du: int, dv: int) -> Poly:
    """Multiply a polynomial by the monomial u^{du} v^{dv}."""
    return {(p + du, q + dv): c for (p, q), c in a.items()}


# --------------------------------------------------------------------------- #
# The three universal operations on Hodge diamonds                          #
# --------------------------------------------------------------------------- #
def direct_sum(x: HodgeDiamond, y: HodgeDiamond) -> HodgeDiamond:
    """X ⊕ Y: dim = max, Hodge numbers add cell by cell."""
    return HodgeDiamond(dim=max(x.dim, y.dim),
                        h=lambda p, q: x.h(p, q) + y.h(p, q))


def tensor_prod(x: HodgeDiamond, y: HodgeDiamond) -> HodgeDiamond:
    """X ⊗ Y: dim = sum, Künneth convolution of Hodge numbers."""
    def conv(p: int, q: int) -> int:
        return sum(x.h(i, k) * y.h(p - i, q - k)
                   for i in range(p + 1) for k in range(q + 1))
    return HodgeDiamond(dim=x.dim + y.dim, h=conv)


def tate_twist(x: HodgeDiamond) -> HodgeDiamond:
    """X(1): diagonal shift (p, q) -> (p+1, q+1); zero on the p=0 or q=0 edge."""
    return HodgeDiamond(dim=x.dim + 1,
                        h=lambda p, q: x.h(p - 1, q - 1) if p >= 1 and q >= 1 else 0)


# --------------------------------------------------------------------------- #
# Example diamonds                                                           #
# --------------------------------------------------------------------------- #
def point() -> HodgeDiamond:
    """The point: dim 0, h^{0,0} = 1.  Multiplicative unit for ⊗."""
    return HodgeDiamond(dim=0, h=lambda p, q: 1 if (p, q) == (0, 0) else 0)


def projective_line() -> HodgeDiamond:
    """P^1: dim 1, h^{0,0} = h^{1,1} = 1.  E = 1 + uv,  χ = 2."""
    return HodgeDiamond(dim=1,
                        h=lambda p, q: 1 if (p, q) in {(0, 0), (1, 1)} else 0)


def elliptic_curve() -> HodgeDiamond:
    """Genus-1 curve: dim 1, h^{0,0}=h^{1,1}=1, h^{1,0}=h^{0,1}=1.
    E = 1 - u - v + uv = (1-u)(1-v),  χ = 0."""
    table = {(0, 0): 1, (1, 0): 1, (0, 1): 1, (1, 1): 1}
    return HodgeDiamond(dim=1, h=lambda p, q: table.get((p, q), 0))


def k3_surface() -> HodgeDiamond:
    """A K3 surface: dim 2, h^{0,0}=h^{2,2}=1, h^{1,1}=20, h^{2,0}=h^{0,2}=1.
    χ = 24 (the classical Euler characteristic of a K3)."""
    table = {(0, 0): 1, (2, 2): 1, (1, 1): 20, (2, 0): 1, (0, 2): 1}
    return HodgeDiamond(dim=2, h=lambda p, q: table.get((p, q), 0))


def fmt_poly(poly: Poly) -> str:
    """Pretty-print a bivariate polynomial."""
    if not poly:
        return "0"
    parts = []
    for (p, q) in sorted(poly):
        c = poly[(p, q)]
        mono = ""
        if p:
            mono += f"u^{p}" if p != 1 else "u"
        if q:
            mono += f"v^{q}" if q != 1 else "v"
        if not mono:
            mono = "1"
        parts.append(f"({c}){mono}")
    return " + ".join(parts)


# --------------------------------------------------------------------------- #
# Demonstrations of the theorems                                            #
# --------------------------------------------------------------------------- #
def demo_directSum() -> None:
    print("=== epoly_directSum: E(X ⊕ Y) = E(X) + E(Y) ===")
    x, y = projective_line(), elliptic_curve()
    lhs = epoly(direct_sum(x, y))
    rhs = poly_add(epoly(x), epoly(y))
    print(f"  E(P^1 ⊕ E) = {fmt_poly(lhs)}")
    print(f"  E(P^1)+E(E) = {fmt_poly(rhs)}")
    assert lhs == rhs, "additivity failed"
    print("  OK additivity holds.\n")


def demo_kunneth() -> None:
    print("=== epoly_kunneth: E(X ⊗ Y) = E(X) · E(Y) ===")
    x, y = projective_line(), elliptic_curve()
    lhs = epoly(tensor_prod(x, y))
    rhs = poly_mul(epoly(x), epoly(y))
    print(f"  E(P^1 ⊗ E)   = {fmt_poly(lhs)}")
    print(f"  E(P^1)·E(E)  = {fmt_poly(rhs)}")
    assert lhs == rhs, "Künneth multiplicativity failed"
    print("  OK multiplicativity holds.\n")


def demo_eulerChar_kunneth() -> None:
    print("=== eulerChar_kunneth: χ(X ⊗ Y) = χ(X) · χ(Y) ===")
    x, y = projective_line(), k3_surface()
    lhs = euler_char(tensor_prod(x, y))
    rhs = euler_char(x) * euler_char(y)
    print(f"  χ(P^1)={euler_char(x)}, χ(K3)={euler_char(y)}")
    print(f"  χ(P^1 ⊗ K3) = {lhs},  χ(P^1)·χ(K3) = {rhs}")
    assert lhs == rhs, "Euler characteristic product law failed"
    print("  OK numerical product law holds.\n")


def demo_tateTwist() -> None:
    print("=== epoly_tateTwist: E(X(1)) = uv · E(X) ===")
    x = k3_surface()
    lhs = epoly(tate_twist(x))
    rhs = poly_scale_monomial(epoly(x), 1, 1)  # multiply by uv
    print(f"  E(K3(1))   = {fmt_poly(lhs)}")
    print(f"  uv · E(K3) = {fmt_poly(rhs)}")
    assert lhs == rhs, "Tate twist law failed"
    print("  OK the Tate twist is multiplication by 𝕃 = uv.\n")


def demo_serre_functional_equation() -> None:
    print("=== epoly_serre_functional_equation: E(X;u,v) = (uv)^n E(X;1/u,1/v) ===")
    for name, x in [("P^1", projective_line()),
                    ("elliptic", elliptic_curve()),
                    ("K3", k3_surface())]:
        n = x.dim
        poly = epoly(x)
        u, v = Fraction(3, 1), Fraction(5, 2)
        lhs = eval_poly(poly, u, v)
        rhs = (u * v) ** n * eval_poly(poly, 1 / u, 1 / v)
        print(f"  {name}: E={lhs},  (uv)^{n} E(1/u,1/v)={rhs}")
        assert lhs == rhs, f"Serre functional equation failed for {name}"
    print("  OK functional equation holds (these diamonds obey Serre duality).\n")


def demo_palindrome() -> None:
    print("=== poincare_serre_palindrome: P(X;t) = t^{2n} P(X;1/t) ===")
    for name, x in [("P^1", projective_line()), ("K3", k3_surface())]:
        n = x.dim
        poly = epoly(x)
        t = Fraction(7, 3)
        lhs = eval_poly(poly, t, t)                       # P(X; t)
        rhs = t ** (2 * n) * eval_poly(poly, 1 / t, 1 / t)  # t^{2n} P(X; 1/t)
        print(f"  {name}: P(t)={lhs},  t^{2*n} P(1/t)={rhs}")
        assert lhs == rhs, f"palindrome failed for {name}"
    print("  OK Poincaré polynomial is palindromic.\n")


def main() -> None:
    print("Hodge–Deligne E-polynomial — motivic measure demonstrations\n")
    for name, x in [("point", point()), ("P^1", projective_line()),
                    ("elliptic curve", elliptic_curve()), ("K3", k3_surface())]:
        print(f"  E({name}) = {fmt_poly(epoly(x))},  χ = {euler_char(x)},"
              f"  supported = {x.is_supported()}")
    print()
    demo_directSum()
    demo_kunneth()
    demo_eulerChar_kunneth()
    demo_tateTwist()
    demo_serre_functional_equation()
    demo_palindrome()
    print("All structural laws verified numerically.")


if __name__ == "__main__":
    main()
