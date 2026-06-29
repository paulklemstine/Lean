"""
Numerical demonstrations of the Hodge-Deligne E-polynomial functional equations.

This self-contained script realizes, in exact rational/symbolic arithmetic, the
objects and theorems of the accompanying paper:

  * HodgeDiamond           -- a complex dimension n and Hodge numbers h^{p,q}
  * E(X; u, v)             -- the Hodge-Deligne E-polynomial
  * mirror X               -- the involution (p,q) |-> (n-p, q)
  * Serre duality          -- h^{p,q} = h^{n-p, n-q}

and verifies, as *exact polynomial identities* (coefficient by coefficient):

  Theorem 3.1  E(X; 1, 1) = chi(X)
  Theorem 3.2  E(mirror X; u, v) = (-1)^n u^n E(X; 1/u, v)          [unconditional]
  Theorem 3.3  E(X; u, v) = (u v)^n E(X; 1/u, 1/v)                  [Serre-dual X]
  Theorem 3.4  chi(mirror X) = (-1)^n chi(X)
  Theorem 3.5  totalDim(mirror X) = totalDim(X)

No external libraries are required: bivariate polynomials are represented as
dictionaries from integer-exponent pairs to Fraction coefficients, so that
substituting u -> 1/u is simply negating the first exponent.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, Tuple

# A bivariate Laurent polynomial: {(i, j): coeff} meaning sum coeff * u^i * v^j.
Poly = Dict[Tuple[int, int], Fraction]


def poly_clean(p: Poly) -> Poly:
    """Drop zero coefficients so equality testing is canonical."""
    return {k: c for k, c in p.items() if c != 0}


def poly_add(a: Poly, b: Poly) -> Poly:
    out: Poly = dict(a)
    for k, c in b.items():
        out[k] = out.get(k, Fraction(0)) + c
    return poly_clean(out)


def poly_scale(a: Poly, factor: Fraction) -> Poly:
    return poly_clean({k: c * factor for k, c in a.items()})


def poly_shift(a: Poly, di: int, dj: int) -> Poly:
    """Multiply by u^di * v^dj (di, dj may be negative)."""
    return {(i + di, j + dj): c for (i, j), c in a.items()}


def poly_sub_inverse(a: Poly, invert_u: bool, invert_v: bool) -> Poly:
    """Substitute u -> 1/u and/or v -> 1/v by negating the relevant exponents."""
    out: Poly = {}
    for (i, j), c in a.items():
        ni = -i if invert_u else i
        nj = -j if invert_v else j
        out[(ni, nj)] = out.get((ni, nj), Fraction(0)) + c
    return poly_clean(out)


def poly_eq(a: Poly, b: Poly) -> bool:
    return poly_clean(a) == poly_clean(b)


@dataclass(frozen=True)
class HodgeDiamond:
    """A Hodge diamond: complex dimension n and Hodge numbers h^{p,q}."""
    n: int
    h: Callable[[int, int], int]

    def mirror(self) -> "HodgeDiamond":
        """The mirror involution (p, q) |-> (n - p, q)."""
        n = self.n
        base = self.h
        return HodgeDiamond(n=n, h=lambda p, q: base(n - p, q))

    def e_polynomial(self) -> Poly:
        """E(X; u, v) = sum_{p,q<=n} (-1)^{p+q} h^{p,q} u^p v^q."""
        out: Poly = {}
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                coeff = Fraction((-1) ** (p + q) * self.h(p, q))
                if coeff != 0:
                    out[(p, q)] = out.get((p, q), Fraction(0)) + coeff
        return poly_clean(out)

    def euler_char(self) -> int:
        """chi(X) = sum (-1)^{p+q} h^{p,q}."""
        return sum((-1) ** (p + q) * self.h(p, q)
                   for p in range(self.n + 1) for q in range(self.n + 1))

    def total_dim(self) -> int:
        """totalDim(X) = sum h^{p,q} (the total Betti number)."""
        return sum(self.h(p, q)
                   for p in range(self.n + 1) for q in range(self.n + 1))

    def is_serre_dual(self) -> bool:
        """Check h^{p,q} = h^{n-p, n-q} on the support."""
        n = self.n
        return all(self.h(p, q) == self.h(n - p, n - q)
                   for p in range(n + 1) for q in range(n + 1))


def check_mirror_functional_equation(x: HodgeDiamond) -> bool:
    """Theorem 3.2: E(mirror X) = (-1)^n u^n E(X; 1/u, v) as Laurent polynomials."""
    lhs = x.mirror().e_polynomial()
    e_inv_u = poly_sub_inverse(x.e_polynomial(), invert_u=True, invert_v=False)
    rhs = poly_shift(poly_scale(e_inv_u, Fraction((-1) ** x.n)), x.n, 0)
    return poly_eq(lhs, rhs)


def check_serre_functional_equation(x: HodgeDiamond) -> bool:
    """Theorem 3.3: E(X) = (u v)^n E(X; 1/u, 1/v) for Serre-dual X."""
    assert x.is_serre_dual(), "Theorem 3.3 requires a Serre-dual diamond"
    lhs = x.e_polynomial()
    e_inv = poly_sub_inverse(x.e_polynomial(), invert_u=True, invert_v=True)
    rhs = poly_shift(e_inv, x.n, x.n)
    return poly_eq(lhs, rhs)


def check_specialization_at_one(x: HodgeDiamond) -> bool:
    """Theorem 3.1: E(X; 1, 1) = chi(X)."""
    value_at_one = sum(x.e_polynomial().values())
    return value_at_one == Fraction(x.euler_char())


# ----------------------------------------------------------------------------
# Example Hodge diamonds (all Serre-dual).
# ----------------------------------------------------------------------------

def projective_plane() -> HodgeDiamond:
    """P^2: h^{0,0}=h^{1,1}=h^{2,2}=1, all else 0. chi = 3."""
    def h(p: int, q: int) -> int:
        return 1 if p == q and p in (0, 1, 2) else 0
    return HodgeDiamond(n=2, h=h)


def k3_surface() -> HodgeDiamond:
    """K3 surface: h^{0,0}=h^{2,2}=1, h^{2,0}=h^{0,2}=1, h^{1,1}=20. chi = 24."""
    table = {(0, 0): 1, (2, 2): 1, (2, 0): 1, (0, 2): 1, (1, 1): 20}
    return HodgeDiamond(n=2, h=lambda p, q: table.get((p, q), 0))


def quintic_threefold() -> HodgeDiamond:
    """Quintic Calabi-Yau 3-fold: h^{1,1}=1, h^{2,1}=h^{1,2}=101. chi = -200."""
    table = {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return HodgeDiamond(n=3, h=lambda p, q: table.get((p, q), 0))


def mirror_quintic() -> HodgeDiamond:
    """Mirror quintic: h^{1,1}=101, h^{2,1}=1. chi = +200."""
    table = {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 101, (2, 2): 101,
        (2, 1): 1, (1, 2): 1,
    }
    return HodgeDiamond(n=3, h=lambda p, q: table.get((p, q), 0))


def poly_to_str(p: Poly) -> str:
    if not p:
        return "0"
    terms = []
    for (i, j) in sorted(p):
        c = p[(i, j)]
        mono = ""
        if i:
            mono += f" u^{i}"
        if j:
            mono += f" v^{j}"
        terms.append(f"({c}){mono}".strip())
    return " + ".join(terms)


def main() -> None:
    examples = [
        ("Projective plane P^2", projective_plane()),
        ("K3 surface", k3_surface()),
        ("Quintic Calabi-Yau 3-fold", quintic_threefold()),
        ("Mirror quintic", mirror_quintic()),
    ]

    for name, x in examples:
        print("=" * 70)
        print(f"{name}   (complex dimension n = {x.n})")
        print(f"  E(X; u, v)        = {poly_to_str(x.e_polynomial())}")
        print(f"  chi(X)            = {x.euler_char()}")
        print(f"  totalDim(X)       = {x.total_dim()}")
        print(f"  Serre-dual?       = {x.is_serre_dual()}")
        print("  --- Theorem checks ---")
        print(f"  3.1  E(X;1,1)=chi(X)          : {check_specialization_at_one(x)}")
        print(f"  3.2  mirror functional eq.    : {check_mirror_functional_equation(x)}")
        if x.is_serre_dual():
            print(f"  3.3  Serre functional eq.     : {check_serre_functional_equation(x)}")
        sign = (-1) ** x.n
        print(f"  3.4  chi(mirror)= (-1)^n chi  : "
              f"{x.mirror().euler_char() == sign * x.euler_char()}  "
              f"({x.mirror().euler_char()} = {sign} * {x.euler_char()})")
        print(f"  3.5  totalDim mirror-invariant: "
              f"{x.mirror().total_dim() == x.total_dim()}")

    print("=" * 70)
    print("Mirror-pair consistency (quintic vs mirror quintic):")
    q, mq = quintic_threefold(), mirror_quintic()
    print(f"  chi(quintic)        = {q.euler_char()}")
    print(f"  chi(mirror quintic) = {mq.euler_char()}")
    print(f"  predicted by Thm 3.4 ((-1)^3 chi) = {(-1) ** 3 * q.euler_char()}")
    print(f"  match: {mq.euler_char() == (-1) ** 3 * q.euler_char()}")


if __name__ == "__main__":
    main()
