"""Standalone visualization: independence ratio vs. the quarter barrier.
Plots |V|/alpha for a family of graphs and marks the chi_f = 4 threshold.
Requires matplotlib."""
from fractions import Fraction
from itertools import combinations
from typing import Dict, List, Set, Tuple
import matplotlib.pyplot as plt

Graph = Dict[int, Set[int]]


def make_disjoint_cliques(sizes: List[int]) -> Graph:
    g: Graph = {}
    base = 0
    for s in sizes:
        block = list(range(base, base + s))
        for v in block:
            g[v] = set()
        for u, w in combinations(block, 2):
            g[u].add(w)
            g[w].add(u)
        base += s
    return g


def independence_number(g: Graph) -> int:
    verts = sorted(g)
    n = len(verts)
    best = 0

    def expand(idx: int, chosen: List[int]) -> None:
        nonlocal best
        if len(chosen) + (n - idx) <= best:
            return
        if idx == n:
            best = max(best, len(chosen))
            return
        v = verts[idx]
        if all(v not in g[c] for c in chosen):
            expand(idx + 1, chosen + [v])
        expand(idx + 1, chosen)

    expand(0, [])
    return best


def main() -> None:
    labels: List[str] = []
    bounds: List[float] = []
    for k in range(2, 7):  # k disjoint copies of K5
        g = make_disjoint_cliques([5] * k)
        alpha = independence_number(g)
        bounds.append(len(g) / alpha)
        labels.append(f"{k}xK5")
    plt.figure(figsize=(8, 5))
    plt.bar(labels, bounds, color="#3b6fb0")
    plt.axhline(4.0, color="crimson", linestyle="--", label="chi_f = 4 barrier")
    plt.ylabel("certified lower bound |V| / alpha")
    plt.title("Independence-ratio lower bounds vs. the quarter barrier")
    plt.legend()
    plt.tight_layout()
    plt.savefig("quarter_barrier.png", dpi=150)
    print("Saved quarter_barrier.png")


if __name__ == "__main__":
    main()
