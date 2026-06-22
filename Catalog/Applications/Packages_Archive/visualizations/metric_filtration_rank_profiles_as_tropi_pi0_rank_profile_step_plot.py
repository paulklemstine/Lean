"""Visualize the single-linkage dendrogram and the pi0 rank profile.

Requires matplotlib (pip install matplotlib). Standalone: builds its own data.
"""
from typing import Callable, Dict, List, Tuple
import matplotlib.pyplot as plt

Dissimilarity = Callable[[int, int], float]


class UnionFind:
    def __init__(self, n: int) -> None:
        self.parent = list(range(n))

    def find(self, a: int) -> int:
        while self.parent[a] != a:
            self.parent[a] = self.parent[self.parent[a]]
            a = self.parent[a]
        return a

    def union(self, a: int, b: int) -> None:
        self.parent[self.find(a)] = self.find(b)


def component_count(n: int, d: Dissimilarity, eps: float) -> int:
    uf = UnionFind(n)
    for a in range(n):
        for b in range(a + 1, n):
            if a != b and (d(a, b) <= eps or d(b, a) <= eps):
                uf.union(a, b)
    return len({uf.find(i) for i in range(n)})


def main() -> None:
    m = [
        [0.0, 1.0, 4.0, 4.5, 6.0],
        [1.0, 0.0, 3.8, 4.2, 5.5],
        [4.0, 3.8, 0.0, 1.2, 5.0],
        [4.5, 4.2, 1.2, 0.0, 4.8],
        [6.0, 5.5, 5.0, 4.8, 0.0],
    ]
    d: Dissimilarity = lambda x, y: m[x][y]
    n = 5
    scales = sorted({0.0} | {m[a][b] for a in range(n) for b in range(n)})
    counts = [component_count(n, d, e) for e in scales]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(scales, counts, where="post", color="#1f77b4", linewidth=2)
    ax.scatter(scales, counts, color="#d62728", zorder=3)
    ax.set_xlabel("scale  (epsilon)")
    ax.set_ylabel("number of connected components  (pi0)")
    ax.set_title("pi0 rank profile of the Rips filtration (antitone step function)")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("rank_profile.png", dpi=150)
    print("Saved rank_profile.png")


if __name__ == "__main__":
    main()
