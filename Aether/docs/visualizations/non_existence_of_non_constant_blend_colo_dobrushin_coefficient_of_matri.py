"""Visualize Dobrushin coefficient of W^r decaying with r (contraction speed)."""
from __future__ import annotations
import random
import matplotlib.pyplot as plt
from typing import List

def random_strongly_connected(n: int, seed: int = 0) -> List[List[float]]:
    rng = random.Random(seed)
    W = [[0.0] * n for _ in range(n)]
    for i in range(n):
        W[i][(i + 1) % n] += 1.0
        for j in range(n):
            W[i][j] += rng.random()
        s = sum(W[i]); W[i] = [x / s for x in W[i]]
    return W

def matmul(A, B):
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]

def delta(W):
    n = len(W); worst = 1.0
    for i in range(n):
        for ip in range(i + 1, n):
            worst = min(worst, sum(min(W[i][j], W[ip][j]) for j in range(n)))
    return 1 - worst

if __name__ == "__main__":
    n = 8; W = random_strongly_connected(n, seed=2)
    P = [row[:] for row in W]; ds = []
    for r in range(1, 11):
        ds.append(delta(P)); P = matmul(P, W)
    plt.semilogy(range(1, 11), ds, "s-")
    plt.xlabel("power r"); plt.ylabel("Dobrushin coefficient of W^r")
    plt.title("Contraction speed of the averaging map")
    plt.grid(True, which="both"); plt.tight_layout(); plt.savefig("dobrushin.png", dpi=150)
    print("saved dobrushin.png")
