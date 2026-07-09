from __future__ import annotations
from typing import Tuple
import sympy as sp

def riccati_reduce(p: sp.Expr, q: sp.Expr, v0: sp.Expr, x: sp.Symbol
                   ) -> Tuple[sp.Expr, sp.Expr]:
    """Given a known solution v0 of v' + v^2 + p v + q = 0, return the general
    Riccati solution v(x; C) and the affine coefficient a = 2 v0 + p.

    Steps:
      1. a := 2 v0 + p                               (Jacobian at v0)
      2. w := exp(integral a dx)                     (homogeneous solution)
      3. u_p := w * integral(1/w dx)                 (variation of constants)
      4. u := u_p + C w ; v := v0 + 1/u              (general solution)
    """
    C = sp.symbols("C")
    D = lambda f: sp.diff(f, x)
    # sanity: v0 must solve the Riccati equation
    assert sp.simplify(sp.together(D(v0) + v0**2 + p * v0 + q)) == 0
    a = 2 * v0 + p
    w = sp.exp(sp.integrate(a, x))
    u_p = w * sp.integrate(1 / w, x)
    u = u_p + C * w
    v = v0 + 1 / u
    return sp.simplify(v), sp.simplify(a)

if __name__ == "__main__":
    x = sp.symbols("x")
    v, a = riccati_reduce(sp.Integer(0), sp.Integer(-1), sp.Integer(1), x)
    print("general solution v =", v)
    print("affine coefficient a =", a)
