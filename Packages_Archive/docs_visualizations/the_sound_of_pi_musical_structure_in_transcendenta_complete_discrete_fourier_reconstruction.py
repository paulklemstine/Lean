from __future__ import annotations
import cmath
import math
from typing import Sequence

def dft(x: Sequence[float]) -> list[complex]:
    n = len(x)
    return [sum(x[j]*cmath.exp(-2j*math.pi*r*j/n) for j in range(n)) for r in range(n)]

def idft(y: Sequence[complex]) -> list[complex]:
    n = len(y)
    return [sum(y[r]*cmath.exp(2j*math.pi*r*j/n) for r in range(n))/n for j in range(n)]

if __name__ == "__main__":
    x = [3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0]
    z = idft(dft(x))
    print("maximum reconstruction error:", max(abs(a-b) for a,b in zip(x,z)))
