from fractions import Fraction
from typing import Tuple

Mat = Tuple[Fraction, Fraction, Fraction, Fraction]  # [[a,b],[c,d]]
A: Mat = (Fraction(1), Fraction(1), Fraction(1), Fraction(1))
I2: Mat = (Fraction(1), Fraction(0), Fraction(0), Fraction(1))


def mat_mul(M: Mat, N: Mat) -> Mat:
    a, b, c, d = M
    e, f, g, h = N
    return (a*e + b*g, a*f + b*h, c*e + d*g, c*f + d*h)


def trace(M: Mat) -> Fraction:
    a, _b, _c, d = M
    return a + d


def point_count_naive(r: int) -> Fraction:
    """O(r) matrix powers: trace(A**r) by repeated multiplication."""
    P: Mat = I2
    for _ in range(r):
        P = mat_mul(P, A)
    return trace(P)


def point_count_closed(r: int) -> int:
    """O(log r) closed form from the theorems:
       trace(A**0) = 2 (boundary anomaly); trace(A**r) = 2**r for r >= 1."""
    if r == 0:
        return 2          # trace(I2) = 2  != 2**0 = 1
    return 1 << r         # 2**r via bit shift
