from typing import List, Sequence

Poly = List[int]

def poly_eval(coeffs: Poly, x: int) -> int:
    result, power = 0, 1
    for c in coeffs:
        result += c * power
        power *= x
    return result

def poly_mul(a: Poly, b: Poly) -> Poly:
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return out

def poly_compose(q: Poly, p: Poly) -> Poly:
    result: Poly = [0]
    for c in reversed(q):
        result = poly_mul(result, p)
        if not result:
            result = [0]
        result[0] += c
    return result

def poly_degree(coeffs: Poly) -> int:
    return max((i for i, c in enumerate(coeffs) if c != 0), default=0)

def verify_composition(p: Poly, q: Poly, A: Sequence[int]) -> int:
    B = {poly_eval(p, a) for a in A}
    C = {poly_eval(q, b) for b in B}
    comp = poly_compose(q, p)
    D = {poly_eval(comp, a) for a in A}
    assert C == D, "(q o p)(A) != q(p(A))"
    k, m = poly_degree(p), poly_degree(q)
    assert len(set(A)) <= k * m * len(D), "multiplicativity violated"
    return len(D)
