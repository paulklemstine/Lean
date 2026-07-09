from __future__ import annotations

def trop_add(a: float, b: float) -> float:
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    return a + b

def trop_pow(a: float, n: int) -> float:
    r: float = 0.0  # tropical multiplicative unit
    for _ in range(n):
        r = trop_mul(r, a)
    return r

def check_freshman_dream(a: float, b: float, n: int) -> bool:
    lhs = trop_pow(trop_add(a, b), n)
    rhs = trop_add(trop_pow(a, n), trop_pow(b, n))
    return lhs == rhs  # holds for all n >= 0
