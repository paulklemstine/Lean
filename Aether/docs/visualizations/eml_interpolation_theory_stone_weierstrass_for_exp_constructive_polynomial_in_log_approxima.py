from __future__ import annotations
import math
from typing import Callable, List, Sequence


def solve_linear_system(matrix: List[List[float]], rhs: List[float]) -> List[float]:
    """Gaussian elimination with partial pivoting for A x = b."""
    n = len(matrix)
    aug: List[List[float]] = [row[:] + [rhs[i]] for i, row in enumerate(matrix)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(aug[r][col]))
        aug[col], aug[pivot] = aug[pivot], aug[col]
        pivot_val = aug[col][col]
        for r in range(n):
            if r == col:
                continue
            factor = aug[r][col] / pivot_val
            for c in range(col, n + 1):
                aug[r][c] -= factor * aug[col][c]
    return [aug[i][n] / aug[i][i] for i in range(n)]


def fit_polynomial_in_log(
    target: Callable[[float], float], degree: int, num_nodes: int = 200
) -> List[float]:
    """Least-squares fit of p(u), u = log(1+t), to target on [0,1] via the
    change of variables t = e^u - 1 on [0, log 2]."""
    log2 = math.log(2.0)
    us: List[float] = []
    vals: List[float] = []
    for k in range(num_nodes):
        cheb = math.cos(math.pi * (k + 0.5) / num_nodes)
        u = 0.5 * log2 * (cheb + 1.0)
        us.append(u)
        vals.append(target(math.exp(u) - 1.0))
    m = degree + 1
    ata = [[0.0] * m for _ in range(m)]
    atb = [0.0] * m
    for u, v in zip(us, vals):
        powers = [u ** j for j in range(m)]
        for i in range(m):
            atb[i] += powers[i] * v
            for j in range(m):
                ata[i][j] += powers[i] * powers[j]
    return solve_linear_system(ata, atb)


def eml_approximant(coeffs: Sequence[float]) -> Callable[[float], float]:
    """Build the EML network t |-> p(log(1+t)) from polynomial coefficients."""
    def g(t: float) -> float:
        u = math.log(1.0 + t)
        acc = 0.0
        for c in reversed(coeffs):
            acc = acc * u + c
        return acc
    return g
