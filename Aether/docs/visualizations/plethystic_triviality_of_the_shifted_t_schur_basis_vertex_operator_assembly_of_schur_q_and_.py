from fractions import Fraction
from typing import Dict, List, Tuple

Monomial = Tuple[Tuple[int, int], ...]
SymFunc = Dict[Monomial, Fraction]
PolyU = Dict[int, SymFunc]

def ann_gen(d: List[Fraction], f: SymFunc, kmax: int,
            sf_add, sf_mul, sf_const, sf_gen) -> PolyU:
    """Annihilation A_d : X_k -> X_k - d_k u^{2k+1}, an algebra map into Gamma[u]."""
    gen_img: List[PolyU] = [
        {0: sf_gen(k), 2 * k + 1: sf_const(-d[k])} for k in range(kmax + 1)
    ]
    def pu_mul(p: PolyU, q: PolyU) -> PolyU:
        out: PolyU = {}
        for du, fu in p.items():
            for dv, gv in q.items():
                out[du + dv] = sf_add(out.get(du + dv, {}), sf_mul(fu, gv))
        return out
    out: PolyU = {0: {}}
    for m, c in f.items():
        term: PolyU = {0: sf_const(c)}
        for k, e in m:
            for _ in range(e):
                term = pu_mul(term, gen_img[k])
        for du, fu in term.items():
            out[du] = sf_add(out.get(du, {}), fu)
    return out

def tsum(qf: List[SymFunc], n: int, p: PolyU, sf_add, sf_mul) -> SymFunc:
    out: SymFunc = {}
    for du, coeff in p.items():
        if n + du < len(qf):
            out = sf_add(out, sf_mul(qf[n + du], coeff))
    return out

def schur(parts: List[int], q: List[SymFunc], d: List[Fraction], kmax: int,
          sf_add, sf_mul, sf_const, sf_gen) -> SymFunc:
    """Q_lambda (resp. S^t_lambda) as the right fold of vertex components B_n over parts."""
    f: SymFunc = sf_const(Fraction(1))
    for n in reversed(parts):
        f = tsum(q, n, ann_gen(d, f, kmax, sf_add, sf_mul, sf_const, sf_gen), sf_add, sf_mul)
    return f
