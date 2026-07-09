from fractions import Fraction
from typing import Callable, List

Matrix = List[List[Fraction]]
Stream = Callable[[int], Matrix]


def identity(d: int) -> Matrix:
    return [[Fraction(1 if r == c else 0) for c in range(d)] for r in range(d)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, m = len(a), len(b), len(b[0])
    out = [[Fraction(0) for _ in range(m)] for _ in range(n)]
    for r in range(n):
        for c in range(m):
            out[r][c] = sum((a[r][t] * b[t][c] for t in range(k)), Fraction(0))
    return out


def comp_from(f: Stream, i: int, n: int, d: int) -> Matrix:
    """compFrom f i n = f(i+n-1) @ ... @ f(i), built by the compFrom_succ recursion."""
    acc = identity(d)
    for step in range(n):
        acc = matmul(f(i + step), acc)
    return acc


def trans_endo(f: Stream, i: int, j: int, d: int) -> Matrix:
    """transEndo f i j = compFrom f i (j - i) with truncated subtraction."""
    return comp_from(f, i, max(j - i, 0), d)
