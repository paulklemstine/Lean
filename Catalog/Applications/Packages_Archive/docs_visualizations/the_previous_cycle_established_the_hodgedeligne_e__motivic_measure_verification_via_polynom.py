from fractions import Fraction
from typing import Callable, Dict, Tuple

Poly = Dict[Tuple[int, int], Fraction]

def poly_mul(a: Poly, b: Poly) -> Poly:
    out: Poly = {}
    for (p1, q1), c1 in a.items():
        for (p2, q2), c2 in b.items():
            k = (p1 + p2, q1 + q2)
            out[k] = out.get(k, Fraction(0)) + c1 * c2
    return {k: v for k, v in out.items() if v != 0}

def verify_kunneth(e_x: Poly, e_y: Poly, e_xy: Poly) -> bool:
    """Executable witness of epoly_kunneth: check E(X⊗Y) == E(X)·E(Y).

    Independently forms the polynomial product E(X)·E(Y) via the Cauchy product
    (the `cauchy_prod_2D` engine) and compares, term by term, with the directly
    computed E(X⊗Y).  Returns True iff the motivic-measure law holds exactly.
    """
    return poly_mul(e_x, e_y) == e_xy