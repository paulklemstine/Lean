"""Entropic optimal transport via the Sinkhorn-Knopp algorithm."""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]


def transport_cost(d: Matrix, pi: Matrix) -> float:
    return sum(pi[i][j] * d[i][j] for i in range(len(pi)) for j in range(len(pi[0])))


def sinkhorn(
    d: Matrix,
    a: Vector,
    b: Vector,
    epsilon: float = 0.05,
    iters: int = 500,
) -> Tuple[Matrix, float]:
    """Return (entropic plan, its transport cost).

    Minimizes transportCost(d, pi) + epsilon * sum pi_ij log pi_ij over the
    transportation polytope. The optimum is pi = diag(u) K diag(v) with
    K = exp(-d/epsilon), found by alternately rescaling rows to `a` and columns
    to `b`. As epsilon -> 0 the cost converges to the true Kantorovich optimum.
    """
    n, m = len(a), len(b)
    K: Matrix = [[math.exp(-d[i][j] / epsilon) for j in range(m)] for i in range(n)]
    u: Vector = [1.0] * n
    v: Vector = [1.0] * m
    for _ in range(iters):
        for i in range(n):
            denom = sum(K[i][j] * v[j] for j in range(m))
            u[i] = a[i] / denom if denom > 0 else 0.0
        for j in range(m):
            denom = sum(K[i][j] * u[i] for i in range(n))
            v[j] = b[j] / denom if denom > 0 else 0.0
    pi: Matrix = [[u[i] * K[i][j] * v[j] for j in range(m)] for i in range(n)]
    return pi, transport_cost(d, pi)


if __name__ == "__main__":
    n = 4
    d = [[(i - j) ** 2 for j in range(n)] for i in range(n)]
    a = [1.0 / n] * n
    b = [1.0 / n] * n
    for eps in (1.0, 0.1, 0.01):
        _, cost = sinkhorn(d, a, b, epsilon=eps)
        print(f"epsilon = {eps:5.2f}  ->  entropic cost = {cost:.4f}")
