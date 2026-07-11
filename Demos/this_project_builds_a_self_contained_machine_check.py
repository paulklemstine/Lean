"""
Negative-Dimensional Topology: numerical demonstrations.

This self-contained script models *virtual graded spaces* as Laurent
polynomials over the integers, VS = Z[T, T^{-1}], where an integer exponent is
a *dimension* (allowed to be negative) and the integer coefficient in that
degree counts the number of connected components concentrated there.

It demonstrates:
  * the Euler characteristic  chi : VS -> Z,  chi(T) = -1;
  * the negative-dimensional formula  chi(pureSpace(-n, k)) = (-1)^n * k,
    and in particular chi = -k in dimension -1;
  * additivity (disjoint union), multiplicativity (Kunneth), surjectivity;
  * suspension / desuspension sign flips and mutual inverse;
  * Spanier-Whitehead duality D : T^d -> T^{-d}, an involution preserving chi;
  * the non-injectivity of chi and its top-degree refinement.

Everything is exact integer arithmetic; no external dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict


@dataclass(frozen=True)
class VS:
    """A virtual graded space: a Laurent polynomial with integer coefficients.

    `coeffs[d]` is the (signed) number of components in dimension `d`.
    Zero coefficients are never stored, so equality is structural.
    """

    coeffs: Dict[int, int]

    @staticmethod
    def _clean(raw: Dict[int, int]) -> "VS":
        return VS({d: c for d, c in raw.items() if c != 0})

    @staticmethod
    def monomial(dim: int, coeff: int = 1) -> "VS":
        """The pure space of `coeff` components in dimension `dim` (coeff * T^dim)."""
        return VS._clean({dim: coeff})

    @staticmethod
    def const(k: int) -> "VS":
        """The constant space C(k): k components in dimension 0."""
        return VS.monomial(0, k)

    def __add__(self, other: "VS") -> "VS":
        raw: Dict[int, int] = dict(self.coeffs)
        for d, c in other.coeffs.items():
            raw[d] = raw.get(d, 0) + c
        return VS._clean(raw)

    def __mul__(self, other: "VS") -> "VS":
        raw: Dict[int, int] = {}
        for d1, c1 in self.coeffs.items():
            for d2, c2 in other.coeffs.items():
                raw[d1 + d2] = raw.get(d1 + d2, 0) + c1 * c2
        return VS._clean(raw)

    def __repr__(self) -> str:
        if not self.coeffs:
            return "0"
        parts = [f"{c}*T^{d}" for d, c in sorted(self.coeffs.items())]
        return " + ".join(parts)


# ---------------------------------------------------------------------------
# Core operations
# ---------------------------------------------------------------------------

def chi(x: VS) -> int:
    """Euler characteristic: the ring homomorphism T -> -1, i.e. sum (-1)^d a_d."""
    return sum((1 if d % 2 == 0 else -1) * c for d, c in x.coeffs.items())


def pure_space(dim: int, k: int) -> VS:
    """A k-component space concentrated in pure dimension `dim`."""
    return VS.monomial(dim, k)


def susp(x: VS) -> VS:
    """Suspension: raise every dimension by one (multiply by T)."""
    return VS.monomial(1) * x


def desusp(x: VS) -> VS:
    """Desuspension: lower every dimension by one (multiply by T^{-1})."""
    return VS.monomial(-1) * x


def susp_iter(x: VS, m: int) -> VS:
    """Apply suspension m >= 0 times."""
    for _ in range(m):
        x = susp(x)
    return x


def dual(x: VS) -> VS:
    """Spanier-Whitehead dual D: negate every dimension (T^d -> T^{-d})."""
    return VS._clean({-d: c for d, c in x.coeffs.items()})


def top_dim(x: VS) -> int:
    """The top occupied dimension (largest exponent with nonzero coefficient)."""
    if not x.coeffs:
        raise ValueError("top_dim is undefined for the zero space")
    return max(x.coeffs)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_title_question() -> None:
    print("== The title question: dimension -1 ==")
    for k in range(1, 6):
        x = pure_space(-1, k)
        print(f"  {k}-component space in dim -1:  X = {x},  chi = {chi(x)}  (expected {-k})")
        assert chi(x) == -k
    print()


def demo_negative_formula() -> None:
    print("== chi(pureSpace(-n, k)) = (-1)^n * k ==")
    for n in range(0, 5):
        for k in (1, 3):
            x = pure_space(-n, k)
            expected = (-1) ** n * k
            print(f"  dim -{n}, {k} comps:  chi = {chi(x):+d}  (expected {expected:+d})")
            assert chi(x) == expected
    print("  Note: even negative dims give POSITIVE chi.\n")


def demo_ring_homomorphism() -> None:
    print("== chi is a ring homomorphism ==")
    x = pure_space(2, 3) + pure_space(-1, 4)      # 3*T^2 + 4*T^-1
    y = pure_space(0, 5) + pure_space(3, -2)      # 5 - 2*T^3
    print(f"  X = {x},  chi(X) = {chi(x)}")
    print(f"  Y = {y},  chi(Y) = {chi(y)}")
    print(f"  chi(X+Y) = {chi(x + y)}  ==  chi(X)+chi(Y) = {chi(x) + chi(y)}")
    print(f"  chi(X*Y) = {chi(x * y)}  ==  chi(X)*chi(Y) = {chi(x) * chi(y)}  (Kunneth)")
    assert chi(x + y) == chi(x) + chi(y)
    assert chi(x * y) == chi(x) * chi(y)
    print(f"  chi(point) = chi(1) = {chi(VS.const(1))}")
    print()


def demo_surjectivity() -> None:
    print("== Every integer is an Euler characteristic ==")
    for m in (-3, -1, 0, 2, 7):
        assert chi(VS.const(m)) == m
    print("  chi(C(m)) = m verified for m in {-3,-1,0,2,7}\n")


def demo_suspension() -> None:
    print("== Suspension / desuspension ==")
    x = pure_space(0, 1) + pure_space(2, 3)
    print(f"  X = {x},  chi = {chi(x)}")
    print(f"  susp X   = {susp(x)},   chi = {chi(susp(x))}  (= -chi X)")
    print(f"  desusp X = {desusp(x)}, chi = {chi(desusp(x))}  (= -chi X)")
    assert chi(susp(x)) == -chi(x)
    assert chi(desusp(x)) == -chi(x)
    assert desusp(susp(x)) == x and susp(desusp(x)) == x
    for m in range(5):
        assert chi(susp_iter(x, m)) == (-1) ** m * chi(x)
    print("  susp/desusp are mutual inverses; chi(susp^m X) = (-1)^m chi(X)\n")


def demo_duality() -> None:
    print("== Poincare duality: D(T^d) = T^{-d} ==")
    x = pure_space(-1, 4) + pure_space(3, 2) + pure_space(0, -5)
    dx = dual(x)
    print(f"  X    = {x},  chi = {chi(x)}")
    print(f"  D X  = {dx},  chi = {chi(dx)}  (= chi X)")
    assert chi(dual(x)) == chi(x)          # duality preserves chi
    assert dual(dual(x)) == x              # involution
    assert dual(susp(x)) == desusp(dual(x))  # swaps susp / desusp
    print("  D is an involution, swaps susp<->desusp, and preserves chi.\n")


def demo_refined_invariant() -> None:
    print("== chi is not injective; topDim refines it ==")
    a, b = pure_space(0, 1), pure_space(2, 1)   # T^0 and T^2
    print(f"  A = {a},  chi = {chi(a)},  topDim = {top_dim(a)}")
    print(f"  B = {b},  chi = {chi(b)},  topDim = {top_dim(b)}")
    assert chi(a) == chi(b)            # chi collides
    assert a != b                      # but they are different spaces
    assert top_dim(a) != top_dim(b)    # topDim separates them
    print("  chi(A) == chi(B) but A != B; topDim distinguishes them.\n")


def main() -> None:
    demo_title_question()
    demo_negative_formula()
    demo_ring_homomorphism()
    demo_surjectivity()
    demo_suspension()
    demo_duality()
    demo_refined_invariant()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
