from fractions import Fraction
from typing import Dict, List, Tuple

Monomial = Tuple[Tuple[int, int], ...]
SymFunc = Dict[Monomial, Fraction]

def sf_add(f: SymFunc, g: SymFunc) -> SymFunc:
    out: SymFunc = dict(f)
    for m, c in g.items():
        out[m] = out.get(m, Fraction(0)) + c
    return {m: c for m, c in out.items() if c != 0}

def sf_scale(c: Fraction, f: SymFunc) -> SymFunc:
    return {} if c == 0 else {m: c * v for m, v in f.items()}

def sf_mul(f: SymFunc, g: SymFunc) -> SymFunc:
    out: SymFunc = {}
    for m1, c1 in f.items():
        for m2, c2 in g.items():
            e: Dict[int, int] = {}
            for k, ee in m1 + m2:
                e[k] = e.get(k, 0) + ee
            m = tuple(sorted((k, v) for k, v in e.items() if v > 0))
            out[m] = out.get(m, Fraction(0)) + c1 * c2
    return {m: c for m, c in out.items() if c != 0}

def creation(cf: List[SymFunc], n_max: int) -> List[SymFunc]:
    """One-row Schur Q creation functions q_0..q_{n_max} (Newton recursion qGen)."""
    q: List[SymFunc] = [{(): Fraction(1)}]
    for m in range(0, n_max):
        acc: SymFunc = {}
        for k in range(0, m // 2 + 1):
            acc = sf_add(acc, sf_scale(Fraction(2), sf_mul(cf[k], q[m - 2 * k])))
        q.append(sf_scale(Fraction(1, m + 1), acc))
    return q
