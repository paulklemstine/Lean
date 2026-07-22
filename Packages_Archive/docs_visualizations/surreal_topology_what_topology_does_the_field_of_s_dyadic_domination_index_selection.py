from __future__ import annotations

def dyadic_index_above(n: int) -> int:
    if n < 0: raise ValueError("n must be nonnegative")
    k=0
    while n >= 2**k: k += 1
    return k
