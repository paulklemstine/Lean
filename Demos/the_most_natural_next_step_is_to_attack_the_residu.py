"""
demo.py -- Numerical and symbolic demonstrations of the Riccati linearization.

This script illustrates the four main results proved (and machine-verified) for the
Riccati equation  v' + v^2 + p*v + q = 0  in a differential field:

  1. riccati_oneSolution_identity     -- the cleared algebraic identity
  2. riccati_solvable_iff_linear      -- v = v0 + 1/u solves Riccati  iff  u' = (2 v0 + p) u + 1
  3. riccati_solution_gives_linear    -- u = 1/(v - v0) solves the linear equation
  4. riccati_secondSolution_diff_logDeriv -- (v - v0)'/(v - v0) = -(v + v0 + p)

and the differential-Galois context:

  riccati_crossRatio_isConstant       -- the cross-ratio of four solutions is constant.

We realize the differential field as C(x) (rational/elementary functions of one
variable) with derivation d/dx, using sympy for exact symbolic differentiation.

Run:  python demo.py
Requires: sympy  (pip install sympy)
"""

from __future__ import annotations

from typing import Callable, List, Tuple

import sympy as sp

x = sp.symbols("x")
D = lambda f: sp.diff(f, x)  # the derivation '  (d/dx)


# ---------------------------------------------------------------------------
# Core Riccati expressions
# ---------------------------------------------------------------------------
def riccati_expr(v: sp.Expr, p: sp.Expr, q: sp.Expr) -> sp.Expr:
    """The Riccati left-hand side  v' + v^2 + p*v + q."""
    return D(v) + v**2 + p * v + q


def is_zero(expr: sp.Expr) -> bool:
    """Decide whether a symbolic expression is identically zero."""
    return sp.simplify(sp.together(expr)) == 0


# ---------------------------------------------------------------------------
# Demo 1 -- The cleared identity (Theorem riccati_oneSolution_identity)
# ---------------------------------------------------------------------------
def demo_cleared_identity() -> None:
    """Verify  [Riccati(v0 + 1/u)] * u^2 = (2 v0 + p) u + 1 - u'  symbolically.

    We keep v0 a *generic* Riccati solution by using the hypothesis
    v0' + v0^2 + p v0 + q = 0 to substitute q = -(v0' + v0^2 + p v0)."""
    print("=" * 72)
    print("Demo 1: cleared identity  riccati_oneSolution_identity")
    print("=" * 72)

    # Generic ingredients as unknown functions of x.
    v0 = sp.Function("v0")(x)
    p = sp.Function("p")(x)
    u = sp.Function("u")(x)
    # Enforce that v0 solves the Riccati equation by choosing q accordingly.
    q = -(D(v0) + v0**2 + p * v0)

    v = v0 + 1 / u
    lhs = riccati_expr(v, p, q) * u**2
    rhs = (2 * v0 + p) * u + 1 - D(u)

    diff = sp.simplify(sp.together(lhs - rhs))
    print("  LHS - RHS simplifies to:", diff)
    assert diff == 0, "cleared identity FAILED"
    print("  PASS: the cleared identity holds for a generic Riccati solution v0.\n")


# ---------------------------------------------------------------------------
# Demo 2 -- A concrete solvable example (Theorems iff + converse)
# ---------------------------------------------------------------------------
def demo_concrete_solution() -> None:
    """Solve a concrete Riccati equation from one known solution.

    Take p = 0, q = -1, so the equation is  v' + v^2 - 1 = 0.
    A known solution is v0 = 1 (constant): 0 + 1 - 1 = 0.
    Linearized equation:  u' = (2*1 + 0) u + 1 = 2u + 1.
    General solution: u = C e^{2x} - 1/2; then v = 1 + 1/u solves Riccati."""
    print("=" * 72)
    print("Demo 2: concrete reduction  riccati_solvable_iff_linear (p=0, q=-1)")
    print("=" * 72)

    p, q = sp.Integer(0), sp.Integer(-1)
    v0 = sp.Integer(1)
    assert is_zero(riccati_expr(v0, p, q)), "v0 should solve the Riccati equation"
    print("  Known solution v0 = 1 verified.")

    C = sp.symbols("C")
    coeff = 2 * v0 + p  # = 2
    u = C * sp.exp(coeff * x) - sp.Rational(1, 2)

    # Check u solves the affine linear equation u' = 2u + 1.
    lin_residual = sp.simplify(D(u) - (coeff * u + 1))
    print("  Linear residual  u' - (2u+1) =", lin_residual)
    assert lin_residual == 0

    v = v0 + 1 / u
    ric_residual = sp.simplify(sp.together(riccati_expr(v, p, q)))
    print("  Riccati residual at v = 1 + 1/u =", ric_residual)
    assert ric_residual == 0
    print("  PASS: v = 1 + 1/u solves v' + v^2 - 1 = 0 for every constant C.")

    # tanh is the C -> special case: with C = 1, evaluate at a point.
    val = sp.nsimplify(v.subs({C: 1, x: sp.Rational(1, 2)}))
    print(f"  Sample value v(1/2) with C=1: {sp.N(val, 8)}\n")


# ---------------------------------------------------------------------------
# Demo 3 -- The converse extraction map (Theorem riccati_solution_gives_linear)
# ---------------------------------------------------------------------------
def demo_converse_extraction() -> None:
    """Given two Riccati solutions v0, v, show u = 1/(v - v0) solves the linear eq.

    Equation:  v' + v^2 - 1 = 0  (p=0, q=-1).
    Two solutions: v0 = 1 and v = (e^{2x} + 1)/(e^{2x} - 1) = coth(x) shifted.
    Actually use v = 1 + 1/(e^{2x} - 1/2) (from Demo 2 with C=1)."""
    print("=" * 72)
    print("Demo 3: converse extraction  riccati_solution_gives_linear")
    print("=" * 72)

    p, q = sp.Integer(0), sp.Integer(-1)
    v0 = sp.Integer(1)
    v = 1 + 1 / (sp.exp(2 * x) - sp.Rational(1, 2))
    assert is_zero(riccati_expr(v, p, q))
    assert is_zero(riccati_expr(v0, p, q))

    u = 1 / (v - v0)
    coeff = 2 * v0 + p
    residual = sp.simplify(sp.together(D(u) - (coeff * u + 1)))
    print("  u = 1/(v - v0);  u' - ((2 v0 + p) u + 1) =", residual)
    assert residual == 0
    print("  PASS: the reciprocal gap u = 1/(v - v0) solves u' = (2 v0 + p) u + 1.\n")


# ---------------------------------------------------------------------------
# Demo 4 -- Bernoulli companion (Theorem riccati_secondSolution_diff_logDeriv)
# ---------------------------------------------------------------------------
def demo_bernoulli_companion() -> None:
    """Verify  (v - v0)'/(v - v0) = -(v + v0 + p)  for two solutions."""
    print("=" * 72)
    print("Demo 4: Bernoulli companion  riccati_secondSolution_diff_logDeriv")
    print("=" * 72)

    p, q = sp.Integer(0), sp.Integer(-1)
    v0 = sp.Integer(1)
    v = 1 + 1 / (sp.exp(2 * x) - sp.Rational(1, 2))
    assert is_zero(riccati_expr(v, p, q)) and is_zero(riccati_expr(v0, p, q))

    log_deriv = sp.simplify(sp.together(D(v - v0) / (v - v0)))
    target = sp.simplify(-(v + v0 + p))
    print("  (v - v0)'/(v - v0) =", log_deriv)
    print("  -(v + v0 + p)      =", target)
    assert sp.simplify(log_deriv - target) == 0
    print("  PASS: the logarithmic derivative of the gap equals -(v + v0 + p).\n")


# ---------------------------------------------------------------------------
# Demo 5 -- Cross-ratio constancy (Theorem riccati_crossRatio_isConstant)
# ---------------------------------------------------------------------------
def cross_ratio(v1: sp.Expr, v2: sp.Expr, v3: sp.Expr, v4: sp.Expr) -> sp.Expr:
    """((v1 - v3)(v2 - v4)) / ((v1 - v4)(v2 - v3))."""
    return ((v1 - v3) * (v2 - v4)) / ((v1 - v4) * (v2 - v3))


def demo_cross_ratio_constant() -> None:
    """Build four solutions of v' + v^2 - 1 = 0 and verify their cross-ratio is
    constant (its derivative is identically zero)."""
    print("=" * 72)
    print("Demo 5: projective invariant  riccati_crossRatio_isConstant")
    print("=" * 72)

    p, q = sp.Integer(0), sp.Integer(-1)
    v0 = sp.Integer(1)
    # Family v_C = 1 + 1/(C e^{2x} - 1/2), one solution per constant C, plus v0.
    def sol(C: sp.Expr) -> sp.Expr:
        return 1 + 1 / (C * sp.exp(2 * x) - sp.Rational(1, 2))

    v1, v2, v3, v4 = sol(1), sol(2), sol(3), v0
    for v in (v1, v2, v3, v4):
        assert is_zero(riccati_expr(v, p, q))

    cr = cross_ratio(v1, v2, v3, v4)
    dcr = sp.simplify(sp.together(D(cr)))
    cr_val = sp.simplify(sp.together(cr))
    print("  cross-ratio simplifies to constant:", cr_val)
    print("  d/dx (cross-ratio) =", dcr)
    assert dcr == 0
    print("  PASS: the cross-ratio of four Riccati solutions is constant.\n")


def main() -> None:
    print("\nRiccati linearization -- numerical/symbolic demonstrations\n")
    demo_cleared_identity()
    demo_concrete_solution()
    demo_converse_extraction()
    demo_bernoulli_companion()
    demo_cross_ratio_constant()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
