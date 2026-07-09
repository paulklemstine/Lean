from __future__ import annotations
import sympy as sp

def is_riccati_solution_certificate(v0: sp.Expr, u: sp.Expr,
                                    p: sp.Expr, x: sp.Symbol) -> bool:
    """Cheap, division-free certificate (Theorem riccati_solvable_iff_linear):
    v = v0 + 1/u solves the Riccati equation  iff  u' = (2 v0 + p) u + 1.
    Checking the *linear* identity is far cheaper than re-substituting into the
    quadratic equation."""
    D = lambda f: sp.diff(f, x)
    return sp.simplify(sp.together(D(u) - ((2 * v0 + p) * u + 1))) == 0

if __name__ == "__main__":
    x, C = sp.symbols("x C")
    v0 = sp.Integer(1)
    u = C * sp.exp(2 * x) - sp.Rational(1, 2)
    print("certificate holds:", is_riccati_solution_certificate(v0, u, sp.Integer(0), x))
