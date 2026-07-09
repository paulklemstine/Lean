"""Visualize the q-Pascal triangle and the geometric-series point counts.

Generates two figures:
  1. heatmaps of log10([n,k]_q) for q in {1,2,3}, showing how the subspace
     counts inflate relative to ordinary binomials (q=1);
  2. the point counts [n,1]_q = 1+q+...+q^{n-1} on a log scale.
"""
from functools import lru_cache
import numpy as np
import matplotlib.pyplot as plt


@lru_cache(maxsize=None)
def q_binom(q: int, n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    if k == 0:
        return 1
    if n == 0:
        return 0
    return q_binom(q, n - 1, k - 1) + (q ** k) * q_binom(q, n - 1, k)


def main() -> None:
    N = 9
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    for ax, q in zip(axes, (1, 2, 3)):
        M = np.full((N + 1, N + 1), np.nan)
        for n in range(N + 1):
            for k in range(n + 1):
                M[n, k] = np.log10(q_binom(q, n, k) + 1)
        im = ax.imshow(M, origin="upper", cmap="viridis")
        ax.set_title(f"log10([n,k]_{q} + 1)")
        ax.set_xlabel("k")
        ax.set_ylabel("n")
        fig.colorbar(im, ax=ax, shrink=0.8)
    fig.suptitle("Gaussian binomial triangles: q=1 (Johnson) vs q=2,3 (Grassmann)")
    fig.tight_layout()
    fig.savefig("qpascal_heatmaps.png", dpi=150)

    plt.figure(figsize=(7, 5))
    ns = list(range(1, 10))
    for q in (2, 3, 4, 5):
        ys = [q_binom(q, n, 1) for n in ns]
        plt.semilogy(ns, ys, marker="o", label=f"q={q}")
    plt.xlabel("n")
    plt.ylabel("[n,1]_q  (number of points)")
    plt.title("Point counts [n,1]_q = 1 + q + ... + q^(n-1)")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("point_counts.png", dpi=150)


if __name__ == "__main__":
    main()
