from __future__ import annotations
from typing import Dict, Tuple

Var = Tuple[str, int]                       # ("x", i) or ("y", j)
Monomial = Tuple[Tuple[Var, int], ...]      # sorted ((var, exp), ...)
Poly = Dict[Monomial, int]                  # monomial -> integer coefficient


def poly_add(a: Poly, b: Poly) -> Poly:
    out: Poly = dict(a)
    for m, c in b.items():
        out[m] = out.get(m, 0) + c
    return {m: c for m, c in out.items() if c != 0}


def poly_mul(a: Poly, b: Poly) -> Poly:
    out: Poly = {}
    for m1, c1 in a.items():
        for m2, c2 in b.items():
            exps: Dict[Var, int] = {}
            for v, e in m1 + m2:
                exps[v] = exps.get(v, 0) + e
            m = tuple(sorted(exps.items()))
            out[m] = out.get(m, 0) + c1 * c2
    return {m: c for m, c in out.items() if c != 0}


def eval_xy(phi: Dict[int, Poly], p: Poly) -> Poly:
    """Evaluation homomorphism evalXY(phi): substitute each y-variable j by
    phi[j] (an x-polynomial) while fixing the x-variables (Definition 2.2)."""
    result: Poly = {}
    for monomial, coeff in p.items():
        term: Poly = {(): coeff}
        for (tag, idx), exp in monomial:
            factor = phi[idx] if tag == "y" else {(((tag, idx), 1),): 1}
            for _ in range(exp):
                term = poly_mul(term, factor)
        result = poly_add(result, term)
    return result


def lift_x(p: Poly) -> Poly:
    """liftX: re-read an x-only polynomial in the ambient (x, y)-ring."""
    return dict(p)
