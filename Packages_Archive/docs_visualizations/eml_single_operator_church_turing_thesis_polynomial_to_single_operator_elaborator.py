from __future__ import annotations
from typing import List, Sequence, Tuple

Monomial = Tuple[float, Tuple[int, ...]]

def elaborate_polynomial(monomials: Sequence[Monomial]) -> "EMLOnlyExpr":
    """Emit an EML-only expression computing a multivariate polynomial,
    realizing the polynomial-completeness theorem constructively via
    finite-sum and finite-product closure (no exp/log node is needed)."""
    def power(i: int, k: int):
        acc = Const(1.0)              # empty product
        for _ in range(k):
            acc = Mul(acc, Var(i))
        return acc
    total = Const(0.0)               # empty sum
    for coeff, exps in monomials:
        term = Const(1.0)
        for i, di in enumerate(exps):
            if di > 0:
                term = Mul(term, power(i, di))
        total = Add(total, Mul(Const(coeff), term))
    return total
