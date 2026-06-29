"""
demo.py — Numerical demonstrations for
"Spectral Evaluation Elimination for Semiring Congruences".

This file is fully self-contained (standard library only) and illustrates the
key constructions and theorems of the package on small, concrete examples:

  * Multivariate polynomials over a configurable commutative semiring, with the
    retained variables `x` and eliminated variables `y` carried as a tagged
    index `("x", i)` / `("y", j)`.
  * `liftX`   : embed an x-polynomial into the (x, y)-ring (Definition 2.1).
  * `evalXY`  : substitute each y-variable by an x-polynomial (Definition 2.2).
  * The retraction identity  evalXY(phi, liftX(p)) == p  (Theorem 2.3),
    verified over the integer semiring AND the tropical (min, +) semiring.
  * `liftX` injective / `evalXY` surjective (Corollary 2.4).
  * An evaluation contraction recovering an elimination constraint, and a
    finite battery of substitutions separating pairs (Finite Witness Theorem 7.3
    in miniature).

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, Tuple

# A variable is a tagged index: ("x", i) is a retained variable, ("y", j) an
# eliminated one.  A monomial is a frozenset-like map var -> exponent (>=1).
Var = Tuple[str, int]
Monomial = Tuple[Tuple[Var, int], ...]  # sorted tuple of (var, exponent) pairs


# --------------------------------------------------------------------------- #
# Semirings                                                                    #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Semiring:
    """A commutative semiring (S, +, *, 0, 1) given by its operations."""

    add: Callable[[object, object], object]
    mul: Callable[[object, object], object]
    zero: object
    one: object
    name: str

    def is_zero(self, a: object) -> bool:
        return a == self.zero


INT_SEMIRING = Semiring(
    add=lambda a, b: a + b,
    mul=lambda a, b: a * b,
    zero=0,
    one=1,
    name="Integers (+, *)",
)

# Tropical min-plus semiring: "add" is min, "mul" is +, 0 is +inf, 1 is 0.
TROP_INF = float("inf")
TROPICAL_SEMIRING = Semiring(
    add=lambda a, b: min(a, b),
    mul=lambda a, b: (TROP_INF if a == TROP_INF or b == TROP_INF else a + b),
    zero=TROP_INF,
    one=0,
    name="Tropical min-plus (min, +)",
)


# --------------------------------------------------------------------------- #
# Polynomials                                                                  #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Poly:
    """A multivariate polynomial as a dict {monomial: coefficient}."""

    sr: Semiring
    terms: Dict[Monomial, object]

    @staticmethod
    def const(sr: Semiring, c: object) -> "Poly":
        if sr.is_zero(c):
            return Poly(sr, {})
        return Poly(sr, {(): c})

    @staticmethod
    def var(sr: Semiring, v: Var) -> "Poly":
        return Poly(sr, {((v, 1),): sr.one})

    def _normalize(self) -> "Poly":
        cleaned = {m: c for m, c in self.terms.items() if not self.sr.is_zero(c)}
        return Poly(self.sr, cleaned)

    def __add__(self, other: "Poly") -> "Poly":
        out: Dict[Monomial, object] = dict(self.terms)
        for m, c in other.terms.items():
            out[m] = self.sr.add(out.get(m, self.sr.zero), c)
        return Poly(self.sr, out)._normalize()

    def __mul__(self, other: "Poly") -> "Poly":
        out: Dict[Monomial, object] = {}
        for m1, c1 in self.terms.items():
            for m2, c2 in other.terms.items():
                m = _merge_monomials(m1, m2)
                out[m] = self.sr.add(out.get(m, self.sr.zero), self.sr.mul(c1, c2))
        return Poly(self.sr, out)._normalize()

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Poly):
            return NotImplemented
        return self._normalize().terms == other._normalize().terms

    def __hash__(self) -> int:  # allow Polys as dict keys / set members
        return hash(frozenset(self._normalize().terms.items()))

    def __repr__(self) -> str:
        if not self.terms:
            return f"0_[{self.sr.name}]"
        parts = []
        for m, c in sorted(self.terms.items()):
            mon = (
                "*".join(f"{tag}{idx}^{e}" for ((tag, idx), e) in m) if m else "1"
            )
            parts.append(f"{c}*{mon}")
        return " + ".join(parts)


def _merge_monomials(m1: Monomial, m2: Monomial) -> Monomial:
    exps: Dict[Var, int] = {}
    for v, e in m1:
        exps[v] = exps.get(v, 0) + e
    for v, e in m2:
        exps[v] = exps.get(v, 0) + e
    return tuple(sorted((v, e) for v, e in exps.items()))


# --------------------------------------------------------------------------- #
# liftX, evalXY  (Definitions 2.1, 2.2)                                        #
# --------------------------------------------------------------------------- #
def lift_x(p: Poly) -> Poly:
    """Embed an x-only polynomial into the (x, y)-ring (Definition 2.1).

    Structurally this is the identity on the term dictionary; conceptually it
    re-reads each retained variable in the larger ambient ring.  No y-variables
    are introduced.
    """
    return Poly(p.sr, dict(p.terms))


def eval_xy(phi: Dict[int, Poly], p: Poly) -> Poly:
    """Substitute each y-variable j by phi[j] (an x-polynomial); fix x.

    Implements evalXY phi from Definition 2.2.
    """
    sr = p.sr
    result = Poly.const(sr, sr.zero)
    for monomial, coeff in p.terms.items():
        term = Poly.const(sr, coeff)
        for (tag, idx), exp in monomial:
            if tag == "x":
                factor = Poly.var(sr, ("x", idx))
            elif tag == "y":
                factor = phi[idx]
            else:  # pragma: no cover - defensive
                raise ValueError(f"unknown variable tag {tag!r}")
            for _ in range(exp):
                term = term * factor
        result = result + term
    return result


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_retraction_identity() -> None:
    """Theorem 2.3:  evalXY(phi, liftX(p)) == p  for every substitution phi."""
    print("=" * 70)
    print("Demo 1 — Retraction identity  evalXY(phi, liftX(p)) = p  (Thm 2.3)")
    print("=" * 70)
    for sr in (INT_SEMIRING, TROPICAL_SEMIRING):
        x0, x1 = Poly.var(sr, ("x", 0)), Poly.var(sr, ("x", 1))
        # p = x0^2 + 3*x1 (interpret coefficients in the given semiring)
        p = x0 * x0 + Poly.const(sr, 3) * x1
        # A deliberately wild guess for the eliminated variables.
        phi = {0: x0 * x1 + Poly.const(sr, 5), 1: x1 * x1}
        lhs = eval_xy(phi, lift_x(p))
        ok = lhs == p
        print(f"  semiring : {sr.name}")
        print(f"    p                       = {p}")
        print(f"    evalXY(phi, liftX(p))   = {lhs}")
        print(f"    identity holds          = {ok}")
        assert ok, "retraction identity failed"
    print()


def demo_injective_surjective() -> None:
    """Corollary 2.4: liftX injective, evalXY surjective."""
    print("=" * 70)
    print("Demo 2 — liftX injective, evalXY surjective  (Cor 2.4)")
    print("=" * 70)
    sr = INT_SEMIRING
    x0 = Poly.var(sr, ("x", 0))
    p, q = x0 * x0, x0 + Poly.const(sr, 1)
    # Injectivity: distinct p, q have distinct lifts.
    print(f"  liftX(p) != liftX(q) for p={p}, q={q}: {lift_x(p) != lift_x(q)}")
    assert lift_x(p) != lift_x(q)
    # Surjectivity: any x-poly is hit by liftX as a preimage under evalXY.
    phi = {0: x0}
    target = x0 * x0 + Poly.const(sr, 7)
    preimage = lift_x(target)
    print(f"  evalXY(phi, liftX(target)) == target : "
          f"{eval_xy(phi, preimage) == target}")
    assert eval_xy(phi, preimage) == target
    print()


def demo_elimination_constraint() -> None:
    """An evaluation contraction recovers an elimination constraint.

    Upstairs constraint: y0 = x0^2 (the curve y0 - x0^2 collapses to 0 sense).
    Pushing the *defining relation*  F := y0,  G := x0^2  through the
    substitution phi(y0) = x0^2 makes evalXY(phi, F) = evalXY(phi, G), i.e. the
    eliminated variable's defining equation becomes a trivial x-identity, exactly
    as the elimination congruence predicts.
    """
    print("=" * 70)
    print("Demo 3 — Evaluation contraction recovers an elimination constraint")
    print("=" * 70)
    sr = INT_SEMIRING
    x0 = Poly.var(sr, ("x", 0))
    y0 = Poly.var(sr, ("y", 0))
    F, G = y0, x0 * x0           # the relation  y0 ~ x0^2  in C
    phi = {0: x0 * x0}           # admissible guess:  y0 := x0^2
    f, g = eval_xy(phi, F), eval_xy(phi, G)
    print(f"  upstairs relation : F = {F}   ~_C   G = {G}")
    print(f"  substitution      : y0 := {phi[0]}")
    print(f"  evalXY(phi, F)    = {f}")
    print(f"  evalXY(phi, G)    = {g}")
    print(f"  contraction glues them (f == g) : {f == g}")
    assert f == g
    print()


def demo_finite_witnesses() -> None:
    """Finite Witness Theorem (7.3) in miniature.

    A finite battery of substitutions separates pairs that the elimination keeps
    apart.  Here `pairs` are NOT consequences of the (empty) congruence, so some
    evaluation should keep each pair separated.
    """
    print("=" * 70)
    print("Demo 4 — Finite battery of substitutions separates pairs  (Thm 7.3)")
    print("=" * 70)
    sr = INT_SEMIRING
    x0 = Poly.var(sr, ("x", 0))
    # Battery of three guesses for the single eliminated variable y0.
    battery = [
        {0: Poly.const(sr, 0)},
        {0: x0},
        {0: x0 * x0 + Poly.const(sr, 1)},
    ]
    # Pairs in the ambient ring that should remain distinct after some guess.
    y0 = Poly.var(sr, ("y", 0))
    pairs = [(y0, x0), (y0 * y0, x0 + Poly.const(sr, 2))]
    for F, G in pairs:
        separated_by = [
            i for i, phi in enumerate(battery)
            if eval_xy(phi, F) != eval_xy(phi, G)
        ]
        print(f"  pair (F={F}, G={G})")
        print(f"    separated by guesses indices: {separated_by}")
        assert separated_by, "no guess separated a genuinely distinct pair"
    print()


def main() -> None:
    demo_retraction_identity()
    demo_injective_surjective()
    demo_elimination_constraint()
    demo_finite_witnesses()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
