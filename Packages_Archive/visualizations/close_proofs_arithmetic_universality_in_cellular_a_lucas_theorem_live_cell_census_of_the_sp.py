from __future__ import annotations
from typing import List

def base_p_digits(n: int, p: int) -> List[int]:
    """Digits of n in base p, least significant first."""
    if n == 0:
        return [0]
    digits: List[int] = []
    while n > 0:
        digits.append(n % p)
        n //= p
    return digits

def lucas_live_cell_count(t: int, p: int) -> int:
    """Number of nonzero cells of (caOp)^t via Lucas' theorem.

    By the generating function (caOp)^t = sum_k C(t,k) T^{2k-t}, a cell is live
    iff C(t,k) != 0 mod p.  Lucas' theorem makes this a digit-wise product:
    if t = sum_i d_i p^i then the count is prod_i (d_i + 1).
    Runs in O(log_p t) time."""
    product = 1
    for d in base_p_digits(t, p):
        product *= (d + 1)
    return product
