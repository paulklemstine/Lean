"""Visualize how the spanning-tree count grows as a fixed N is squared up.

Produces a bar chart, for each N, of tau across all 2D factorizations ordered
by spread (max - min), making the "balance wins" trend visually obvious.
Requires matplotlib.
"""
from __future__ import annotations

import itertools
from fractions import Fraction
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt


def spanning_tree_count(sides: Sequence[int]) -> int:
    verts = list(itertools.product(*[range(s) for s in sides]))
    idx = {v: i for i, v in enumerate(verts)}
    n = len(verts)
    lap = [[0] * n for _ in range(n)]
    for v in verts:
        i = idx[v]
        for d in range(len(sides)):
            for step in (-1, 1):
                w = list(v); w[d] += step
                if 0 <= w[d] < sides[d]:
                    lap[i][i] += 1; lap[i][idx[tuple(w)]] -= 1
    m = [[Fraction(x) for x in row[:-1]] for row in lap[:-1]]
    det = Fraction(1)
    for c in range(len(m)):
        piv = next((r for r in range(c, len(m)) if m[r][c] != 0), None)
        if piv is None:
            return 0
        if piv != c:
            m[c], m[piv] = m[piv], m[c]; det = -det
        det *= m[c][c]; inv = m[c][c]
        for r in range(c + 1, len(m)):
            f = m[r][c] / inv
            if f:
                for k in range(c, len(m)):
                    m[r][k] -= f * m[c][k]
    return int(det)


def factor_pairs(n: int) -> List[Tuple[int, int]]:
    return [(a, n // a) for a in range(1, int(n ** 0.5) + 1) if n % a == 0]


def main() -> None:
    Ns = [12, 16, 24, 36]
    fig, axes = plt.subplots(1, len(Ns), figsize=(4 * len(Ns), 4))
    for ax, N in zip(axes, Ns):
        pairs = sorted(factor_pairs(N), key=lambda p: p[1] - p[0], reverse=True)
        labels = [f"{a}x{b}" for a, b in pairs]
        taus = [spanning_tree_count((a, b)) for a, b in pairs]
        colors = ["#cf5c36" if (b - a) > 1 else "#2a9d8f" for a, b in pairs]
        ax.bar(labels, taus, color=colors)
        ax.set_yscale("log")
        ax.set_title(f"N = {N}")
        ax.set_ylabel("spanning trees tau (log scale)")
        ax.tick_params(axis="x", rotation=45)
    fig.suptitle("Balanced shapes (green) dominate: tau rises as spread falls")
    fig.tight_layout()
    fig.savefig("spanning_tree_balance.png", dpi=150)
    print("wrote spanning_tree_balance.png")


if __name__ == "__main__":
    main()
