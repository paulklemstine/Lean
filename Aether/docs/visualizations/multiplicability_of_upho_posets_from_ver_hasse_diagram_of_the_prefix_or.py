"""Hasse diagram of the prefix (left-divisibility) partial order on short walks.

Draws all walks of length <= L over a 2-letter step alphabet, with an edge from a
walk to each one-step extension. The result is the finite top of the prototype upho
poset (the free monoid prefix order).
"""
from __future__ import annotations
from itertools import product
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt

def words_up_to(letters: str, L: int) -> List[str]:
    out = [""]
    for k in range(1, L+1):
        out += ["".join(t) for t in product(letters, repeat=k)]
    return out

def main() -> None:
    letters, L = "ab", 3
    words = words_up_to(letters, L)
    pos: Dict[str, Tuple[float, float]] = {}
    by_len: Dict[int, List[str]] = {}
    for w in words:
        by_len.setdefault(len(w), []).append(w)
    for lvl, ws in by_len.items():
        m = len(ws)
        for i, w in enumerate(sorted(ws)):
            pos[w] = ((i - (m-1)/2), -lvl)
    fig, ax = plt.subplots(figsize=(10, 6))
    for w in words:
        if len(w) < L:
            for c in letters:
                child = w + c
                x0, y0 = pos[w]; x1, y1 = pos[child]
                ax.plot([x0, x1], [y0, y1], color="#bbbbbb", lw=0.8, zorder=1)
    for w in words:
        x, y = pos[w]
        ax.scatter([x], [y], s=420, color="#264653", zorder=2)
        ax.text(x, y, "()" if w == "" else w, color="white", ha="center",
                va="center", fontsize=8, zorder=3)
    ax.set_title("Prefix (left-divisibility) order on walks of length <= 3")
    ax.axis("off")
    plt.tight_layout(); plt.savefig("prefix_order_hasse.png", dpi=150)
    print("wrote prefix_order_hasse.png")

if __name__ == "__main__":
    main()
