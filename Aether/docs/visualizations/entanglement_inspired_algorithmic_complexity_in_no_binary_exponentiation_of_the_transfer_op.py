from __future__ import annotations
from typing import Tuple

Matrix = Tuple[int, int, int, int]

def mat_mul(x: Matrix, y: Matrix, mod: int) -> Matrix:
    a, b, c, d = x
    e, f, g, h = y
    return ((a*e + b*g) % mod, (a*f + b*h) % mod,
            (c*e + d*g) % mod, (c*f + d*h) % mod)

def fib_mod(k: int, mod: int) -> int:
    """F_k mod `mod` in O(log k) via binary exponentiation of [[1,1],[1,0]]."""
    if k == 0:
        return 0
    result: Matrix = (1 % mod, 0, 0, 1 % mod)
    base: Matrix = (1, 1, 1, 0)
    n = k + 1
    while n:
        if n & 1:
            result = mat_mul(result, base, mod)
        base = mat_mul(base, base, mod)
        n >>= 1
    return result[3]
