from math import isqrt
from typing import List, Tuple

Matrix = Tuple[int, int, int, int]

def mobius(M: Matrix, x: float) -> float:
    p, q, r, s = M
    return (p * x + q) / (r * x + s)

def sample_ratio_spectrum(M: Matrix, radicands: List[int]) -> List[Tuple[int, float]]:
    # placeholder Lagrange-constant proxy: see Algorithm 1 for the exact routine
    from math import sqrt
    samples: List[Tuple[int, float]] = []
    p, q, r, s = M
    for D in radicands:
        if isqrt(D) ** 2 == D:
            continue
        x = sqrt(D)
        if r * x + s == 0:
            continue
        samples.append((D, mobius(M, x)))
    return samples
