from __future__ import annotations
from fractions import Fraction

def uncertainty_factor(q: int, a: int, b: int, depth: int) -> Fraction:
    if q <= 0 or min(a, b, depth) < 0:
        raise ValueError("invalid parameter")
    return Fraction((a * b) ** depth, q ** depth)

if __name__ == "__main__":
    for n in range(1, 11):
        rho = uncertainty_factor(5, 2, 2, n)
        print(n, rho, float(rho))
