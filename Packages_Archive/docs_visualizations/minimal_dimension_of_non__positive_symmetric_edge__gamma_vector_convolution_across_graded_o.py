from fractions import Fraction
from typing import List

def poly_mul(a: List[Fraction], b: List[Fraction]) -> List[Fraction]:
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return out

def gamma_convolution(g_m: List[Fraction], g_n: List[Fraction]) -> List[Fraction]:
    """Given gamma-vectors of a gamma-positive polynomial of order m and one of
    order n, return the gamma-vector of their product (order m+n) via the law
    B_{m,i} * B_{n,j} = B_{m+n, i+j}. The result is the nonnegative convolution."""
    out = [Fraction(0)] * (len(g_m) + len(g_n) - 1)
    for i, gi in enumerate(g_m):
        for j, gj in enumerate(g_n):
            out[i + j] += gi * gj
    return out
