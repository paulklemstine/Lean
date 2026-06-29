from fractions import Fraction
from typing import Dict, Tuple

def epoly(n: int, h: Dict[Tuple[int, int], int],
          u: Fraction, v: Fraction) -> Fraction:
    total = Fraction(0)
    up = Fraction(1)
    for p in range(n + 1):
        vq = Fraction(1)
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * h.get((p, q), 0) * up * vq
            vq *= v
        up *= u
    return total
