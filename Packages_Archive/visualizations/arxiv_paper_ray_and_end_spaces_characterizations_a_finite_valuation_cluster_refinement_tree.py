from __future__ import annotations
from fractions import Fraction
from typing import Sequence
def valuation(q: Fraction, p: int) -> int:
    if q == 0: raise ValueError("zero")
    a, b, v = abs(q.numerator), q.denominator, 0
    while a % p == 0: a //= p; v += 1
    while b % p == 0: b //= p; v -= 1
    return v
def hierarchy(points: Sequence[Fraction], p: int, levels: Sequence[int]) -> dict[int, list[list[Fraction]]]:
    result: dict[int, list[list[Fraction]]] = {}
    for k in sorted(set(levels)):
        unseen = set(points); blocks: list[list[Fraction]] = []
        while unseen:
            x = min(unseen)
            block = sorted(y for y in points if y == x or valuation(y-x, p) >= k)
            blocks.append(block); unseen.difference_update(block)
        result[k] = blocks
    return result
