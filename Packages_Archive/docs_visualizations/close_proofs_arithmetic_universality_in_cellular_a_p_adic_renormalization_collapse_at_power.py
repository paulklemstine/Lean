from __future__ import annotations
from typing import Dict

LaurentPoly = Dict[int, int]

def ca_op_renorm(p: int, k: int) -> LaurentPoly:
    """Closed-form time-p^k state of a single seed via p-adic renormalization.

    By the Frobenius identity (a+b)^{p^k} = a^{p^k}+b^{p^k} in characteristic p,
    (T+T^{-1})^{p^k} = T^{p^k} + T^{-p^k}.  Returns it in O(1) ring operations,
    bypassing the p^k-step iteration entirely."""
    e = p ** k
    return {e: 1 % p, -e: 1 % p}

def ca_op_renorm_seed(p: int, k: int, a: int) -> LaurentPoly:
    """Translation-covariant seed: (caOp)^{p^k} * T^a = T^{a+p^k} + T^{a-p^k}."""
    e = p ** k
    return {a + e: 1 % p, a - e: 1 % p}
