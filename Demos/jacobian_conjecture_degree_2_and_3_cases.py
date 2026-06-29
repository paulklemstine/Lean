"""
Numerical and symbolic demonstrations for the Jacobian Conjecture framework.

This file is fully self-contained: it implements a minimal exact (integer
coefficient) multivariate polynomial algebra from scratch — no external
dependencies — and uses it to reproduce every verified result of the Lean
development:

  * Definitions: pcomp (substitution / composition), polyJacobian, jacDet,
    induced (evaluation on a base ring), and the IsPolyAut check.
  * Bridge Theorem (illustrated numerically): an algebraic two-sided inverse
    induces a genuine bijection on the base ring Z (we check round-trips).
  * Triangular degree-2 automorphism:  F(x,y) = (x + y^2, y), jacDet = 1.
  * Druzkowski cubic-linear automorphism: F(x,y) = (x + y^3, y), with
    nilpotent Jacobian of the homogeneous part (J(H)^2 = 0) and jacDet = 1.
  * Falsified candidates:
        (x + y^2, y + x^2)  ->  jacDet = 1 - 4xy        (not constant)
        (x + y^3, y + x^3)  ->  jacDet = 1 - 9 x^2 y^2   (not constant)

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

# A monomial in n variables is an exponent tuple, e.g. (2, 1) = X0^2 * X1.
Monomial = Tuple[int, ...]
# A polynomial is a dict {monomial: coefficient}, with zero coeffs pruned.
PolyDict = Dict[Monomial, int]


class Poly:
    """Exact multivariate polynomial over the integers in `nvars` variables."""

    def __init__(self, nvars: int, terms: PolyDict | None = None) -> None:
        self.nvars: int = nvars
        self.terms: PolyDict = {}
        if terms:
            for mono, coeff in terms.items():
                if coeff != 0:
                    self.terms[mono] = coeff

    # ---- constructors -------------------------------------------------
    @staticmethod
    def const(nvars: int, c: int) -> "Poly":
        zero: Monomial = tuple(0 for _ in range(nvars))
        return Poly(nvars, {zero: c}) if c != 0 else Poly(nvars, {})

    @staticmethod
    def var(nvars: int, i: int) -> "Poly":
        exps = [0] * nvars
        exps[i] = 1
        return Poly(nvars, {tuple(exps): 1})

    # ---- ring operations ----------------------------------------------
    def __add__(self, other: "Poly") -> "Poly":
        result: PolyDict = dict(self.terms)
        for mono, coeff in other.terms.items():
            result[mono] = result.get(mono, 0) + coeff
        return Poly(self.nvars, result)

    def __sub__(self, other: "Poly") -> "Poly":
        result: PolyDict = dict(self.terms)
        for mono, coeff in other.terms.items():
            result[mono] = result.get(mono, 0) - coeff
        return Poly(self.nvars, result)

    def __mul__(self, other: "Poly") -> "Poly":
        result: PolyDict = {}
        for m1, c1 in self.terms.items():
            for m2, c2 in other.terms.items():
                mono = tuple(a + b for a, b in zip(m1, m2))
                result[mono] = result.get(mono, 0) + c1 * c2
        return Poly(self.nvars, result)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Poly):
            return NotImplemented
        return self.terms == other.terms

    def is_zero(self) -> bool:
        return len(self.terms) == 0

    # ---- calculus / evaluation ----------------------------------------
    def pderiv(self, j: int) -> "Poly":
        """Formal partial derivative with respect to variable X_j."""
        result: PolyDict = {}
        for mono, coeff in self.terms.items():
            e = mono[j]
            if e > 0:
                new_mono = list(mono)
                new_mono[j] = e - 1
                key = tuple(new_mono)
                result[key] = result.get(key, 0) + coeff * e
        return Poly(self.nvars, result)

    def eval_at(self, point: List[int]) -> int:
        """Evaluate the polynomial at an integer point (the `induced` map on Z)."""
        total = 0
        for mono, coeff in self.terms.items():
            term = coeff
            for var_index, exp in enumerate(mono):
                term *= point[var_index] ** exp
            total += term
        return total

    def subst(self, g: List["Poly"]) -> "Poly":
        """Substitute the tuple g (one Poly per variable) into this polynomial."""
        result = Poly.const(self.nvars, 0)
        for mono, coeff in self.terms.items():
            term = Poly.const(self.nvars, coeff)
            for var_index, exp in enumerate(mono):
                for _ in range(exp):
                    term = term * g[var_index]
            result = result + term
        return result

    # ---- display ------------------------------------------------------
    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        parts: List[str] = []
        for mono in sorted(self.terms, key=lambda m: (sum(m), m), reverse=True):
            coeff = self.terms[mono]
            factors: List[str] = []
            for var_index, exp in enumerate(mono):
                if exp == 1:
                    factors.append(f"X{var_index}")
                elif exp > 1:
                    factors.append(f"X{var_index}^{exp}")
            mono_str = "*".join(factors)
            if not mono_str:
                parts.append(f"{coeff}")
            elif coeff == 1:
                parts.append(mono_str)
            elif coeff == -1:
                parts.append(f"-{mono_str}")
            else:
                parts.append(f"{coeff}*{mono_str}")
        out = " + ".join(parts).replace("+ -", "- ")
        return out


# ---- framework-level operations (mirroring the Lean definitions) -------
PolyMap = List[Poly]


def identity_map(nvars: int) -> PolyMap:
    """The identity tuple X = (X0, ..., X_{n-1})."""
    return [Poly.var(nvars, i) for i in range(nvars)]


def pcomp(f: PolyMap, g: PolyMap) -> PolyMap:
    """Composition: substitute g into each component of f."""
    return [fi.subst(g) for fi in f]


def is_poly_aut(f: PolyMap, g: PolyMap) -> bool:
    """IsPolyAut: f and g are mutual two-sided substitution inverses."""
    nvars = len(f)
    ident = identity_map(nvars)
    return pcomp(f, g) == ident and pcomp(g, f) == ident


def poly_jacobian(f: PolyMap) -> List[List[Poly]]:
    """Jacobian matrix J(F)_{i,j} = d F_i / d X_j."""
    nvars = len(f)
    return [[f[i].pderiv(j) for j in range(nvars)] for i in range(nvars)]


def jac_det_2x2(f: PolyMap) -> Poly:
    """Jacobian determinant for a 2-variable map: ad - bc."""
    j = poly_jacobian(f)
    return j[0][0] * j[1][1] - j[0][1] * j[1][0]


def induced(f: PolyMap, point: List[int]) -> List[int]:
    """The set-theoretic map on Z induced by evaluating f at an integer point."""
    return [fi.eval_at(point) for fi in f]


def is_constant(p: Poly) -> bool:
    """True iff p is a constant polynomial."""
    return all(sum(mono) == 0 for mono in p.terms)


# ---- demonstrations ---------------------------------------------------
def demo_triangular_degree2() -> None:
    print("=" * 64)
    print("Triangular degree-2 automorphism:  F(x,y) = (x + y^2, y)")
    print("=" * 64)
    n = 2
    x, y = Poly.var(n, 0), Poly.var(n, 1)
    F = [x + y * y, y]
    G = [x - y * y, y]  # explicit inverse
    print(f"  F = ({F[0]}, {F[1]})")
    print(f"  G = ({G[0]}, {G[1]})  (claimed inverse)")
    print(f"  pcomp(F, G) == X : {pcomp(F, G) == identity_map(n)}")
    print(f"  pcomp(G, F) == X : {pcomp(G, F) == identity_map(n)}")
    print(f"  IsPolyAut(F, G)  : {is_poly_aut(F, G)}")
    print(f"  jacDet F         : {jac_det_2x2(F)}  (expected: 1)")
    # Bridge theorem in action: induced map is a bijection on Z (round-trips).
    print("  Bridge Theorem (round-trips on Z):")
    for pt in ([3, -2], [0, 5], [-4, 1]):
        out = induced(F, pt)
        back = induced(G, out)
        print(f"    {pt} --F--> {out} --G--> {back}   ok={back == pt}")


def demo_druzkowski() -> None:
    print("=" * 64)
    print("Druzkowski cubic-linear automorphism:  F(x,y) = (x + y^3, y)")
    print("  (A = [[0,1],[0,0]], A^2 = 0,  H = (y^3, 0))")
    print("=" * 64)
    n = 2
    x, y = Poly.var(n, 0), Poly.var(n, 1)
    F = [x + y * y * y, y]
    G = [x - y * y * y, y]
    H = [y * y * y, Poly.const(n, 0)]
    print(f"  F = ({F[0]}, {F[1]})")
    print(f"  IsPolyAut(F, G)  : {is_poly_aut(F, G)}")
    print(f"  jacDet F         : {jac_det_2x2(F)}  (expected: 1)")
    # Nilpotency of the Jacobian of the homogeneous part H: J(H)^2 = 0.
    jh = poly_jacobian(H)
    print(f"  J(H) = [[{jh[0][0]}, {jh[0][1]}], [{jh[1][0]}, {jh[1][1]}]]")
    sq00 = jh[0][0] * jh[0][0] + jh[0][1] * jh[1][0]
    sq01 = jh[0][0] * jh[0][1] + jh[0][1] * jh[1][1]
    sq10 = jh[1][0] * jh[0][0] + jh[1][1] * jh[1][0]
    sq11 = jh[1][0] * jh[0][1] + jh[1][1] * jh[1][1]
    nilpotent = all(p.is_zero() for p in (sq00, sq01, sq10, sq11))
    print(f"  J(H)^2 == 0 (nilpotent): {nilpotent}")


def demo_falsified_candidates() -> None:
    print("=" * 64)
    print("Falsified counterexample candidates (fail the hypothesis)")
    print("=" * 64)
    n = 2
    x, y = Poly.var(n, 0), Poly.var(n, 1)

    F2 = [x + y * y, y + x * x]
    d2 = jac_det_2x2(F2)
    print(f"  cand2: F = ({F2[0]}, {F2[1]})")
    print(f"    jacDet = {d2}   (expected: 1 - 4*X0*X1)")
    print(f"    constant? {is_constant(d2)}   "
          f"[eval(0,0)={d2.eval_at([0, 0])}, eval(1,1)={d2.eval_at([1, 1])}]")

    F3 = [x + y * y * y, y + x * x * x]
    d3 = jac_det_2x2(F3)
    print(f"  cand3: F = ({F3[0]}, {F3[1]})")
    print(f"    jacDet = {d3}   (expected: 1 - 9*X0^2*X1^2)")
    print(f"    constant? {is_constant(d3)}   "
          f"[eval(0,0)={d3.eval_at([0, 0])}, eval(1,1)={d3.eval_at([1, 1])}]")


def main() -> None:
    demo_triangular_degree2()
    print()
    demo_druzkowski()
    print()
    demo_falsified_candidates()


if __name__ == "__main__":
    main()
