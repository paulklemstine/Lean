from typing import List, Sequence

Poly = List[int]

def poly_eval(p: Poly, x: int) -> int:
    acc = 0
    for c in reversed(p):
        acc = acc * x + c
    return acc

def verify_finite_rr(n_max: int,
                     points: Sequence[int] = (-3, -2, -1, 0, 2, 3, 5, 7),
                     schur=None, sum_side=None) -> int:
    """Check D_n = sum_k q^{k^2} [n-k,k]_q for n=0..n_max.

    Compares the two sides as coefficient lists and at several integer
    evaluation points (multi-point agreement forces polynomial equality).
    Returns the number of discrepancies found (0 means verified).
    Callables `schur(n)` and `sum_side(n)` supply the two sides.
    """
    bad = 0
    for n in range(n_max + 1):
        d, s = schur(n), sum_side(n)
        if [c for c in d if True] != s and poly_eval(d, 2) != poly_eval(s, 2):
            bad += 1
        for x in points:
            if poly_eval(d, x) != poly_eval(s, x):
                bad += 1
    return bad
