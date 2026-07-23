from __future__ import annotations
from typing import List


def laplacian(f: List[List[float]], i: int, j: int, n: int) -> float:
    return (f[(i+1) % n][j] + f[(i-1) % n][j]
            + f[i][(j+1) % n] + f[i][(j-1) % n] - 4.0 * f[i][j])


def gray_scott(n: int = 48, steps: int = 2000, Du: float = 0.16,
               Dv: float = 0.08, F: float = 0.035, k: float = 0.065
               ) -> List[List[float]]:
    u = [[1.0] * n for _ in range(n)]
    v = [[0.0] * n for _ in range(n)]
    c = n // 2
    for i in range(c - 3, c + 3):
        for j in range(c - 3, c + 3):
            u[i][j], v[i][j] = 0.5, 0.25
    for _ in range(steps):
        nu = [row[:] for row in u]
        nv = [row[:] for row in v]
        for i in range(n):
            for j in range(n):
                uvv = u[i][j] * v[i][j] ** 2
                nu[i][j] = u[i][j] + Du*laplacian(u, i, j, n) - uvv + F*(1-u[i][j])
                nv[i][j] = v[i][j] + Dv*laplacian(v, i, j, n) + uvv - (F+k)*v[i][j]
        u, v = nu, nv
    return v
