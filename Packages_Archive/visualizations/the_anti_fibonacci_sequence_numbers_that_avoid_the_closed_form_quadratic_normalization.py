from __future__ import annotations
from fractions import Fraction

def normalized_value(n: int) -> Fraction:
    if n <= 0:
        raise ValueError("n must be positive")
    return Fraction(1, n * n)

if __name__ == "__main__":
    for n in (1, 10, 100, 1000, 1_000_000):
        q = normalized_value(n)
        print(f"n={n:>7,}: exact={q}, decimal={float(q):.12g}")
