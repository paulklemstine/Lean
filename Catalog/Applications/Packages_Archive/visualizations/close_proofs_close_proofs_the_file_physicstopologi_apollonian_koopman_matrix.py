from __future__ import annotations
from itertools import product
from typing import Dict, List, Tuple

Exp = Tuple[int, int, int, int]
MPoly = Dict[Exp, float]

def apollonian_generator(i: int) -> List[List[int]]:
    """4x4 Descartes reflection S_i (i in {0,1,2,3})."""
    S = [[1 if r == c else 0 for c in range(4)] for r in range(4)]
    for c in range(4):
        S[i][c] = 2 if c != i else -1
    return S

def _mul(a: MPoly, b: MPoly) -> MPoly:
    out: MPoly = {}
    for ea, ca in a.items():
        for eb, cb in b.items():
            e = (ea[0]+eb[0], ea[1]+eb[1], ea[2]+eb[2], ea[3]+eb[3])
            out[e] = out.get(e, 0.0) + ca * cb
    return {e: c for e, c in out.items() if c != 0}

def linear_form(i: int, j: int) -> MPoly:
    """Lambda_{i,j} = sum_l S_i[j,l] X_l  (total degree <= 1)."""
    S = apollonian_generator(i)
    f: MPoly = {}
    for l in range(4):
        if S[j][l]:
            f[tuple(1 if t == l else 0 for t in range(4))] = float(S[j][l])  # type: ignore
    return f

def precompose(i: int, p: MPoly) -> MPoly:
    """Koopman action K_i p = p(Lambda_{i,0},...,Lambda_{i,3})."""
    forms = [linear_form(i, j) for j in range(4)]
    out: MPoly = {}
    for exp, c in p.items():
        term: MPoly = {(0, 0, 0, 0): c}
        for j in range(4):
            for _ in range(exp[j]):
                term = _mul(term, forms[j])
        for e, cc in term.items():
            out[e] = out.get(e, 0.0) + cc
    return {e: c for e, c in out.items() if c != 0}

def koopman_matrix(i: int, k: int) -> List[List[float]]:
    """Matrix of K_i on the basis of monomials of total degree <= k.

    Theorem 5.2 guarantees the image stays within this finite basis, so the
    matrix is square of size C(k+4, 4).
    """
    basis: List[Exp] = [e for e in product(range(k + 1), repeat=4) if sum(e) <= k]  # type: ignore
    index = {e: r for r, e in enumerate(basis)}
    M = [[0.0] * len(basis) for _ in basis]
    for col, e in enumerate(basis):
        img = precompose(i, {e: 1.0})
        for mono, coeff in img.items():
            M[index[mono]][col] = coeff
    return M
