"""Visualise the colour-class decomposition of K_6 as a stack of perfect
matchings (the round-robin schedule). Requires matplotlib."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt
from typing import Dict, FrozenSet

Edge = FrozenSet[int]


def round_robin(n: int) -> Dict[Edge, int]:
    m = n
    fixed = m - 1
    rot = list(range(m - 1))
    col: Dict[Edge, int] = {}
    for r in range(m - 1):
        arr = [rot[(r + i) % (m - 1)] for i in range(m - 1)]
        pairs = [(fixed, arr[0])] + [(arr[i], arr[m - 1 - i]) for i in range(1, m // 2)]
        for u, v in pairs:
            col[frozenset((u, v))] = r
    return col


def main() -> None:
    n = 6
    col = round_robin(n)
    rounds = sorted(set(col.values()))
    pos = {v: (math.cos(2 * math.pi * v / n), math.sin(2 * math.pi * v / n))
           for v in range(n)}
    fig, axes = plt.subplots(1, len(rounds), figsize=(3 * len(rounds), 3))
    for ax, r in zip(axes, rounds):
        ax.set_title(f"Round {r}")
        for v, (x, y) in pos.items():
            ax.plot(x, y, "o", color="black")
            ax.annotate(str(v), (x, y), textcoords="offset points", xytext=(4, 4))
        for e, c in col.items():
            if c == r:
                a, b = tuple(e)
                ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]],
                        color=f"C{r}", lw=2)
        ax.set_aspect("equal"); ax.axis("off")
    fig.suptitle("K_6 as a stack of perfect matchings (colour classes)")
    fig.tight_layout()
    fig.savefig("matching_stack.png", dpi=140)
    print("wrote matching_stack.png")


if __name__ == "__main__":
    main()
