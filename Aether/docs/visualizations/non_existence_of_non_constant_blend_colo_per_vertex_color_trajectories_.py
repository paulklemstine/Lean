"""Visualize per-vertex color trajectories converging to a single value."""
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
    n = 7; W = random_strongly_connected(n, seed=5)
    c = [float(i) for i in range(n)]
    hist = [c[:]]
    for _ in range(30):
        c = step(W, c); hist.append(c[:])
    for v in range(n):
        plt.plot([row[v] for row in hist], label=f"vertex {v}")
    plt.xlabel("iteration"); plt.ylabel("color value")
    plt.title("Every vertex's color converges to the global mean")
    plt.legend(fontsize=7); plt.tight_layout(); plt.savefig("trajectories.png", dpi=150)
    print("saved trajectories.png")
