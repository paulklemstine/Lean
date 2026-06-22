"""Visualization: ordinal rank as height in a GL frame (ASCII + matplotlib).

Draws a small branching GL frame, colouring each world by its ordinal rank and
annotating the layer box^k(empty) = {rank < k}. Falls back to ASCII if
matplotlib is unavailable.
"""
from __future__ import annotations
from typing import Dict, List, Tuple

def rank_of(worlds, edges) -> Dict[str, int]:
    memo: Dict[str, int] = {}
    def succ(w): return [v for (u, v) in edges if u == w]
    def go(w):
        if w in memo: return memo[w]
        s = succ(w)
        memo[w] = 0 if not s else 1 + max(go(v) for v in s)
        return memo[w]
    return {w: go(w) for w in worlds}

def main() -> None:
    worlds = ["top", "a", "b", "leaf"]
    edges = [("top","a"),("top","b"),("top","leaf"),("a","leaf")]
    ranks = rank_of(worlds, edges)
    try:
        import matplotlib.pyplot as plt
        pos = {"leaf": (0,0), "b": (2,0), "a": (0,1), "top": (1,2)}
        fig, ax = plt.subplots(figsize=(6,5))
        for (u,v) in edges:
            ax.annotate("", xy=pos[v], xytext=pos[u],
                        arrowprops=dict(arrowstyle="->", color="gray"))
        for w,(x,y) in pos.items():
            ax.scatter([x],[y], s=1200, c=[ranks[w]], cmap="viridis",
                       vmin=0, vmax=max(ranks.values()))
            ax.text(x, y, f"{w}\nrank {ranks[w]}", ha="center", va="center")
        ax.set_title("Ordinal rank in a GL frame (box^k(empty)={rank<k})")
        ax.axis("off")
        plt.tight_layout(); plt.savefig("gl_rank_tree.png", dpi=120)
        print("wrote gl_rank_tree.png")
    except Exception:
        for w in sorted(worlds, key=lambda x: -ranks[x]):
            print(f"{w:>5}: " + "#" * (ranks[w] + 1) + f"  rank={ranks[w]}")

if __name__ == "__main__":
    main()
