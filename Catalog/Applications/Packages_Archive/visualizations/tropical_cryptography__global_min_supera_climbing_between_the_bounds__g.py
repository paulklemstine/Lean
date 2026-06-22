"""Visualization: gmin(A^m) growth vs. the linear lower bound and cycle mean.

Generates a matplotlib figure showing, for a tropical matrix A, the sequence
gmin(A^m), the linear lower bound m*gmin(A), and the asymptote m*mcm(A).
Saves to gmin_growth.png.
"""
from typing import List
import matplotlib.pyplot as plt

Matrix = List[List[float]]
INF = float("inf")


def trop_matmul(a: Matrix, b: Matrix) -> Matrix:
    n = len(a)
    return [[min(a[i][k] + b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def trop_matpow(a: Matrix, e: int) -> Matrix:
    result, base, t = a, a, e - 1
    while t > 0:
        if t & 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        t >>= 1
    return result


def gmin(a: Matrix) -> float:
    return min(a[i][j] for i in range(len(a)) for j in range(len(a)))


def minimum_cycle_mean(a: Matrix) -> float:
    n = len(a)
    best = INF
    for start in range(n):
        dist = [[INF] * n for _ in range(n + 1)]
        dist[0][start] = 0.0
        for L in range(1, n + 1):
            for u in range(n):
                if dist[L - 1][u] == INF:
                    continue
                for v in range(n):
                    dist[L][v] = min(dist[L][v], dist[L - 1][u] + a[u][v])
        for L in range(1, n + 1):
            if dist[L][start] < INF:
                best = min(best, dist[L][start] / L)
    return best


def main() -> None:
    A: Matrix = [[2.0, 5.0], [1.0, 4.0]]
    ms = list(range(1, 41))
    g = [gmin(trop_matpow(A, m)) for m in ms]
    gA = gmin(A)
    mcm = minimum_cycle_mean(A)
    plt.figure(figsize=(8, 5))
    plt.plot(ms, g, "o-", label="gmin(A^m)")
    plt.plot(ms, [m * gA for m in ms], "--", label="linear lower bound  m*gmin(A)")
    plt.plot(ms, [m * mcm for m in ms], ":", label="asymptote  m*mcm(A)")
    plt.xlabel("exponent m")
    plt.ylabel("global minimum entry")
    plt.title("Global-min superadditivity: gmin(A^m) climbs between the bounds")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("gmin_growth.png", dpi=130)
    print("saved gmin_growth.png")


if __name__ == "__main__":
    main()
