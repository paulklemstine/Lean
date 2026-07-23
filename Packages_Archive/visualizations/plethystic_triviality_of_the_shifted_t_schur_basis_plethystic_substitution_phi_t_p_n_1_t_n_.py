from typing import Dict, Tuple
from fractions import Fraction

Monomial = Tuple[Tuple[int, int], ...]
# A t-coefficient is a dict {power_of_t: rational}.
TCoeff = Dict[int, Fraction]
TPoly = Dict[Monomial, TCoeff]


def apply_phi_t(qpoly: Dict[Monomial, Fraction]) -> TPoly:
    """Apply the plethysm phi_t: p_{2k+1} -> (1 - t^{2k+1}) p_{2k+1}.

    For each monomial prod_k p_{2k+1}^{e_k} with rational coefficient c, multiply
    c by prod_k (1 - t^{2k+1})^{e_k}, producing a coefficient that is a polynomial
    in t (stored as {t-power: rational}). The monomial itself is unchanged. This
    realizes S^t_lambda = phi_t(Q_lambda) given Q_lambda in odd power sums.
    """
    def tmul(a: TCoeff, b: TCoeff) -> TCoeff:
        out: TCoeff = {}
        for da, va in a.items():
            for db, vb in b.items():
                out[da + db] = out.get(da + db, Fraction(0)) + va * vb
        return {d: v for d, v in out.items() if v != 0}

    def one_minus_tpow(n: int) -> TCoeff:
        return {0: Fraction(1), n: Fraction(-1)}

    result: TPoly = {}
    for mon, c in qpoly.items():
        factor: TCoeff = {0: c}
        for idx, e in mon:
            for _ in range(e):
                factor = tmul(factor, one_minus_tpow(2 * idx + 1))
        result[mon] = factor
    return result
