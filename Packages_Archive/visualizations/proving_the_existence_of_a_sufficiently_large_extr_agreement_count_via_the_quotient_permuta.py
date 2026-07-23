from __future__ import annotations
from typing import Tuple

Perm = Tuple[int, ...]

def inverse(sigma: Perm) -> Perm:
    inv = [0] * len(sigma)
    for i, s in enumerate(sigma):
        inv[s] = i
    return tuple(inv)

def agreement_count(sigma: Perm, tau: Perm) -> int:
    """Number of agreements, computed via the quotient sigma^{-1} tau."""
    n = len(sigma)
    inv = inverse(sigma)
    quotient = tuple(inv[tau[i]] for i in range(n))
    fixed = sum(1 for i in range(n) if quotient[i] == i)
    direct = sum(1 for i in range(n) if sigma[i] == tau[i])
    assert fixed == direct == n - sum(1 for i in range(n) if quotient[i] != i)
    return fixed
