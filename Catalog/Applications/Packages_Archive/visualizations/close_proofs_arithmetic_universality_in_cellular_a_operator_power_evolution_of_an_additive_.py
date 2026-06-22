from __future__ import annotations
from typing import Dict

LaurentPoly = Dict[int, int]

def poly_mul(a: LaurentPoly, b: LaurentPoly, p: int) -> LaurentPoly:
    """Multiply two Laurent polynomials over F_p (a discrete convolution)."""
    out: LaurentPoly = {}
    for ea, ca in a.items():
        for eb, cb in b.items():
            out[ea + eb] = (out.get(ea + eb, 0) + ca * cb) % p
    return {e: c for e, c in out.items() if c != 0}

def ca_evolve(state: LaurentPoly, t: int, p: int) -> LaurentPoly:
    """Evolve a finite-support configuration t steps over F_p.

    Implements multiplication by (T + T^{-1})^t using fast exponentiation
    by repeated squaring of the operator polynomial."""
    op: LaurentPoly = {1: 1 % p, -1: 1 % p}      # caOp = T + T^{-1}
    acc: LaurentPoly = {0: 1 % p}                # identity polynomial
    e = t
    base = op
    while e > 0:
        if e & 1:
            acc = poly_mul(acc, base, p)
        base = poly_mul(base, base, p)
        e >>= 1
    return poly_mul(state, acc, p)
