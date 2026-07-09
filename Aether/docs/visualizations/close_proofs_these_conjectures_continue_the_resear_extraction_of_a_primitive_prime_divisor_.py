from typing import Dict


def factorize(m: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def least_primitive_divisor(prim_part_value: int) -> int:
    """Given primPart(n) > 1, return its least prime factor. By
    `primPart_implies_primitive` this is a primitive prime divisor of F(n)."""
    if prim_part_value <= 1:
        raise ValueError("primPart(n) must exceed 1")
    return min(factorize(prim_part_value))
