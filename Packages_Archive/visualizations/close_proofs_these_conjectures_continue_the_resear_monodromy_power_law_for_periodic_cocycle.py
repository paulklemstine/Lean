from fractions import Fraction
from typing import Callable, List

Matrix = List[List[Fraction]]


def identity(d: int) -> Matrix:
    return [[Fraction(1) if r == c else Fraction(0) for c in range(d)]
            for r in range(d)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, m = len(a), len(b), len(b[0])
    out = [[Fraction(0) for _ in range(m)] for _ in range(n)]
    for i in range(n):
        for t in range(k):
            if a[i][t] == 0:
                continue
            for j in range(m):
                out[i][j] += a[i][t] * b[t][j]
    return out


def mat_pow(base: Matrix, e: int) -> Matrix:
    """Fast exponentiation of a matrix: O(log e) matrix products."""
    result = identity(len(base))
    b = [row[:] for row in base]
    while e > 0:
        if e & 1:
            result = matmul(result, b)
        b = matmul(b, b)
        e >>= 1
    return result


def periodic_transition(f: Callable[[int], Matrix], p: int, n: int,
                        d: int) -> Matrix:
    """
    For a p-periodic sequence f, Phi(0, p*n) = M^n where M = Phi(0, p) is the
    monodromy operator. Using fast exponentiation gives
    O(p * d^3 + log(n) * d^3) versus O(p * n * d^3) for the naive product.
    """
    monodromy = identity(d)
    for t in range(p):
        monodromy = matmul(f(t), monodromy)
    return mat_pow(monodromy, n)
