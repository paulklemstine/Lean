from math import isqrt
from typing import List

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True

def even_perfects(p_max: int) -> List[int]:
    """All even perfect numbers 2^(p-1)(2^p-1) with prime exponent up to p_max."""
    out: List[int] = []
    for p in range(2, p_max + 1):
        mersenne: int = (1 << p) - 1
        if is_prime(mersenne):
            out.append((1 << (p - 1)) * mersenne)
    return out