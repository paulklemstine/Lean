from fractions import Fraction
from typing import List

def poly_mul(a: List[Fraction], b: List[Fraction], N: int) -> List[Fraction]:
    r = [Fraction(0)] * N
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            if i + j < N and bj != 0:
                r[i + j] += ai * bj
    return r

def poly_inv(a: List[Fraction], N: int) -> List[Fraction]:
    """Reciprocal of a power series with invertible constant term, mod q^N."""
    r = [Fraction(0)] * N
    r[0] = 1 / a[0]
    for n in range(1, N):
        s = sum((a[k] if k < len(a) else Fraction(0)) * r[n - k]
                for k in range(1, n + 1))
        r[n] = -s / a[0]
    return r

def f_coefficients(N: int) -> List[int]:
    """Coefficients of f(q) = sum_n q^{n^2} / prod_{k=1}^n (1+q^k)^2, mod q^N."""
    f = [Fraction(0)] * N
    n = 0
    while n * n < N:
        term = [Fraction(0)] * N
        term[n * n] = Fraction(1)
        denom = [Fraction(0)] * N
        denom[0] = Fraction(1)
        for k in range(1, n + 1):
            factor = [Fraction(0)] * N
            factor[0] = Fraction(1)
            if k < N:
                factor[k] = Fraction(1)
            denom = poly_mul(poly_mul(denom, factor, N), factor, N)
        term = poly_mul(term, poly_inv(denom, N), N)
        f = [f[i] + term[i] for i in range(N)]
        n += 1
    return [int(c) for c in f]
