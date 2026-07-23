from fractions import Fraction
from typing import Callable, List

Matrix = List[List[Fraction]]


def identity(d: int) -> Matrix:
    """Return the d x d identity matrix over Q."""
    return [[Fraction(1) if r == c else Fraction(0) for c in range(d)]
            for r in range(d)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Exact matrix product a @ b over Q."""
    n, k, m = len(a), len(b), len(b[0])
    out = [[Fraction(0) for _ in range(m)] for _ in range(n)]
    for i in range(n):
        for t in range(k):
            if a[i][t] == 0:
                continue
            for j in range(m):
                out[i][j] += a[i][t] * b[t][j]
    return out


def trans_endo(f: Callable[[int], Matrix], i: int, n: int, d: int) -> Matrix:
    """
    Assemble the transition endomorphism Phi(i, n) = f(i+n-1) @ ... @ f(i)
    by the defining recursion M_0 = I, M_{t+1} = f(i+t) @ M_t.
    Complexity: O(n * d^3) with schoolbook multiplication.
    """
    m = identity(d)
    for t in range(n):
        m = matmul(f(i + t), m)
    return m
