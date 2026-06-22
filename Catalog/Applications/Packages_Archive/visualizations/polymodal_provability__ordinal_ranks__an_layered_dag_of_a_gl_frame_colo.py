"""
Visualization: the ordinal rank of a GL frame as a layered DAG.

Draws the canonical GL frame (ℕ_{<n}, >) with worlds placed on horizontal
levels by their ordinal rank, and arrows (accessibility) always pointing
strictly downward in rank — a picture of `gl_rank_lt_of_R`.

Requires: matplotlib.   Run:  python _viz_rank.py
"""

from __future__ import annotations

from typing import Dict, List, Set, Tuple

import matplotlib.pyplot as plt


def strict_order_frame(n: int) -> Tuple[List[int], Set[Tuple[int, int]]]:
    worlds = list(range(n))
    R = {(a, b) for a in worlds for b in worlds if a > b}
    return worlds, R


def rank(worlds: List[int], R: Set[Tuple[int, int]]) -> Dict[int, int]:
    memo: Dict[int, int] = {}

    def succ(w: int) -> Set[int]:
        return {v for (a, v) in R if a == w}

    def r(w: int) -> int:
        if w in memo:
            return memo[w]
        s = succ(w)
        memo[w] = 0 if not s else 1 + max(r(v) for v in s)
        return memo[w]

    return {w: r(w) for w in worlds}


def main() -> None:
    n = 5
    worlds, R = strict_order_frame(n)
    rk = rank(worlds, R)

    pos: Dict[int, Tuple[float, float]] = {w: (0.0, float(rk[w])) for w in worlds}

    fig, ax = plt.subplots(figsize=(6, 7))
    for (w, v) in R:
        x0, y0 = pos[w]
        x1, y1 = pos[v]
        ax.annotate("", xy=(x1, y1 + 0.12), xytext=(x0, y0 - 0.12),
                    arrowprops=dict(arrowstyle="-|>", color="#888",
                                    lw=1.0, alpha=0.6,
                                    connectionstyle="arc3,rad=0.25"))
    for w in worlds:
        x, y = pos[w]
        ax.scatter([x], [y], s=900, color="#2b6cb0", zorder=3)
        ax.text(x, y, str(w), ha="center", va="center",
                color="white", fontsize=13, fontweight="bold", zorder=4)
        ax.text(x + 0.55, y, f"rank = {rk[w]}", ha="left", va="center",
                fontsize=11, color="#333")

    ax.set_title("GL frame (ℕ$_{<5}$, >):  rank strictly drops along every arrow",
                 fontsize=12)
    ax.set_xlim(-1.5, 2.5)
    ax.set_ylim(-0.8, n - 0.2)
    ax.set_xticks([])
    ax.set_ylabel("ordinal rank (= longest accessibility chain)")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    plt.tight_layout()
    plt.savefig("gl_rank.png", dpi=150)
    print("wrote gl_rank.png")


if __name__ == "__main__":
    main()
