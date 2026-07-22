from typing import Dict, List, Tuple

Monomial = Tuple[int, ...]
PolyDict = Dict[Monomial, int]


def pderiv(p: PolyDict, j: int) -> PolyDict:
    """Formal partial derivative of a multivariate polynomial wrt variable j."""
    out: PolyDict = {}
    for mono, coeff in p.items():
        e = mono[j]
        if e > 0:
            m = list(mono)
            m[j] = e - 1
            key = tuple(m)
            out[key] = out.get(key, 0) + coeff * e
    return {m: c for m, c in out.items() if c != 0}


def poly_mul(a: PolyDict, b: PolyDict) -> PolyDict:
    out: PolyDict = {}
    for m1, c1 in a.items():
        for m2, c2 in b.items():
            m = tuple(x + y for x, y in zip(m1, m2))
            out[m] = out.get(m, 0) + c1 * c2
    return {m: c for m, c in out.items() if c != 0}


def poly_sub(a: PolyDict, b: PolyDict) -> PolyDict:
    out: PolyDict = dict(a)
    for m, c in b.items():
        out[m] = out.get(m, 0) - c
    return {m: c for m, c in out.items() if c != 0}


def jacobian_determinant_2d(f0: PolyDict, f1: PolyDict) -> PolyDict:
    """Jacobian determinant of a 2-variable polynomial map (f0, f1):
    det = (d f0/d x0)(d f1/d x1) - (d f0/d x1)(d f1/d x0)."""
    a = pderiv(f0, 0)
    d = pderiv(f1, 1)
    b = pderiv(f0, 1)
    c = pderiv(f1, 0)
    return poly_sub(poly_mul(a, d), poly_mul(b, c))
