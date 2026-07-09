"""Standalone visualization: cubic bound vs. actual copy counts and the
threshold gap. Generates two PNG panels with matplotlib."""
from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt


def common_neighborhood(verts, adj, s) -> FrozenSet[int]:
    result: Set[int] = set(verts)
    for u in s:
        result &= set(adj[u])
    return frozenset(result)


def count_k33_copies(verts, adj) -> int:
    total = 0
    for A in combinations(verts, 3):
        cand = sorted(common_neighborhood(verts, adj, A) - set(A))
        total += comb(len(cand), 3)
    return total


def complete_bipartite(m: int):
    n = 2 * m
    left, right = range(m), range(m, 2 * m)
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for u in left:
        for v in right:
            adj[u].add(v)
            adj[v].add(u)
    return tuple(range(n)), {v: frozenset(s) for v, s in adj.items()}


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: actual K_{3,3} copies in K_{m,m} vs. cubic bound (t = m+1).
    ms = list(range(3, 9))
    actual, sharp, cubic = [], [], []
    for m in ms:
        verts, adj = complete_bipartite(m)
        n, t = 2 * m, m + 1
        actual.append(count_k33_copies(verts, adj))
        sharp.append(comb(n, 3) * comb(t - 1, 3) * comb(t - 1, 0))
        cubic.append(comb(t - 1, 3) * comb(t - 1, 0) * n ** 3)
    ns = [2 * m for m in ms]
    ax1.plot(ns, actual, "o-", label="actual K(3,3) copies")
    ax1.plot(ns, sharp, "s--", label="sharp bound C(n,3)C(t-1,3)")
    ax1.plot(ns, cubic, "^:", label="cubic bound C(t-1,3) n^3")
    ax1.set_xlabel("n = number of vertices")
    ax1.set_ylabel("count")
    ax1.set_yscale("log")
    ax1.set_title("Cubic upper bound vs. actual counts (host K(m,m))")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: threshold gap as a function of b.
    bs = list(range(6, 21))
    nec = [b + 1 for b in bs]
    proved = [2 * max(3, (b + 1) // 2) + 1 for b in bs]
    gap = [p - q for p, q in zip(proved, nec)]
    colors = ["tab:blue" if g == 0 else "tab:red" for g in gap]
    ax2.bar(bs, gap, color=colors)
    ax2.set_xlabel("b")
    ax2.set_ylabel("tau_proved - tau_nec")
    ax2.set_title("Threshold gap = b mod 2 (red = odd, open frontier)")
    ax2.set_yticks([0, 1])
    ax2.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig("genturan_visualization.png", dpi=150)
    print("Saved genturan_visualization.png")


if __name__ == "__main__":
    main()
