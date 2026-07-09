"""Visualize geometric decay of coloring spread under averaging dynamics."""
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

def step(W, c):
    n = len(W); return [sum(W[i][j] * c[j] for j in range(n)) for i in range(n)]

if __name__ == "__main__":
    n = 10; W = random_strongly_connected(n, seed=3)
    c = [float(i) for i in range(n)]
    spreads = [max(c) - min(c)]
    for _ in range(40):
        c = step(W, c); spreads.append(max(c) - min(c))
    plt.semilogy(spreads, "o-")
    plt.xlabel("iteration"); plt.ylabel("coloring spread (max - min)")
    plt.title("Blend collapse: geometric decay of spread to consensus")
    plt.grid(True, which="both"); plt.tight_layout(); plt.savefig("spread_decay.png", dpi=150)
    print("saved spread_decay.png")
