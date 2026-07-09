from fractions import Fraction
from typing import Dict, List, Tuple

Monomial = Tuple[Tuple[int, int], ...]
SymFunc = Dict[Monomial, Fraction]

def diag_hom(a: List[Fraction], f: SymFunc) -> SymFunc:
    """Diagonal plethysm Phi_a : multiply the coefficient of each monomial by prod a_k^{e_k}."""
    out: SymFunc = {}
    for m, c in f.items():
        factor = Fraction(1)
        for k, e in m:
            factor *= a[k] ** e
        out[m] = out.get(m, Fraction(0)) + c * factor
    return {m: c for m, c in out.items() if c != 0}

def phi_t(t: Fraction, f: SymFunc, kmax: int) -> SymFunc:
    """phi_t : p_{2k+1} -> (1 - t^{2k+1}) p_{2k+1}.  Sends Q_lambda to S^t_lambda."""
    return diag_hom([Fraction(1) - t ** (2 * k + 1) for k in range(kmax + 1)], f)

def psi_t(t: Fraction, f: SymFunc, kmax: int) -> SymFunc:
    """psi_t = phi_t^{-1} : p_{2k+1} -> p_{2k+1} / (1 - t^{2k+1}).  Sends S^t_lambda to Q_lambda."""
    return diag_hom([Fraction(1) / (Fraction(1) - t ** (2 * k + 1)) for k in range(kmax + 1)], f)
