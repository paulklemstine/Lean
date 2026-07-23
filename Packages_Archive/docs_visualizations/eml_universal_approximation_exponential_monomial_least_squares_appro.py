from __future__ import annotations
from math import exp
from typing import Callable, List, Tuple

def design_matrix(xs: List[float], k_max: int) -> List[List[float]]:
    return [[exp(k * x) for k in range(k_max + 1)] for x in xs]

def solve_normal_equations(A: List[List[float]], y: List[float]) -> List[float]:
    n = len(A[0])
    ata = [[sum(A[r][i] * A[r][j] for r in range(len(A))) for j in range(n)] for i in range(n)]
    aty = [sum(A[r][i] * y[r] for r in range(len(A))) for i in range(n)]
    M = [row[:] + [aty[i]] for i, row in enumerate(ata)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(M[r][col]))
        M[col], M[piv] = M[piv], M[col]
        pivot = M[col][col]
        if abs(pivot) < 1e-15:
            continue
        for r in range(n):
            if r != col:
                factor = M[r][col] / pivot
                for c in range(col, n + 1):
                    M[r][c] -= factor * M[col][c]
    return [M[i][n] / M[i][i] if abs(M[i][i]) > 1e-15 else 0.0 for i in range(n)]

def approximate(target: Callable[[float], float], a: float, b: float,
                k_max: int, n_samples: int = 200) -> Tuple[List[float], float]:
    xs = [a + (b - a) * i / (n_samples - 1) for i in range(n_samples)]
    ys = [target(x) for x in xs]
    A = design_matrix(xs, k_max)
    coeffs = solve_normal_equations(A, ys)
    max_err = max(abs(sum(coeffs[k] * exp(k * x) for k in range(k_max + 1)) - target(x)) for x in xs)
    return coeffs, max_err
