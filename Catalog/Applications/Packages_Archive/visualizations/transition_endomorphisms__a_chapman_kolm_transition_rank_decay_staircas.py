"""Plot the antitone, eventually-constant transition-rank sequence."""
from __future__ import annotations
from typing import Callable
import numpy as np
import matplotlib.pyplot as plt

Matrix = np.ndarray

def main() -> None:
    n = 8
    rng = np.random.default_rng(11)
    g = rng.integers(-2, 3, size=(n, n)).astype(float)
    g[:, -1] = 0.0          # force rank collapse
    g[:, -2] = g[:, 0]

    acc = np.eye(n)
    ms, ranks = [0], [int(np.linalg.matrix_rank(acc, tol=1e-9))]
    for m in range(1, 2 * n + 1):
        acc = g @ acc
        ms.append(m)
        ranks.append(int(np.linalg.matrix_rank(acc, tol=1e-9)))

    plt.figure(figsize=(8, 5))
    plt.step(ms, ranks, where="post", color="#2c7fb8", linewidth=2)
    plt.axhline(ranks[-1], color="#d95f0e", ls="--",
                label=f"stable rank = {ranks[-1]}")
    plt.axhline(n, color="gray", ls=":", label=f"finrank V = {n}")
    plt.title("Transition rank rankSeq(f,0,m) is antitone and stabilizes")
    plt.xlabel("window length m")
    plt.ylabel("rank of transEndo(f,0,m)")
    plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
    plt.savefig("transition_rank_decay.png", dpi=150)
    print("saved transition_rank_decay.png")

if __name__ == "__main__":
    main()
