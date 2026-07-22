from __future__ import annotations
from math import isqrt
from typing import Tuple

Matrix = Tuple[int, int, int, int]

def _mul(x: Matrix, y: Matrix) -> Matrix:
    a, b, c, d = x; e, f, g, h = y
    return (a*e + b*g, a*f + b*h, c*e + d*g, c*f + d*h)

def _fib(k: int) -> int:
    if k == 0:
        return 0
    r: Matrix = (1, 0, 0, 1); base: Matrix = (1, 1, 1, 0); n = k + 1
    while n:
        if n & 1: r = _mul(r, base)
        base = _mul(base, base); n >>= 1
    return r[3]

def primitive_prime_divisor(n: int) -> int:
    """Smallest primitive prime divisor of F_n for prime n >= 13."""
    x = _fib(n)
    d = 2
    while d <= isqrt(x):
        if x % d == 0:
            return d
        d += 1 if d == 2 else 2
    return x  # F_n is prime
