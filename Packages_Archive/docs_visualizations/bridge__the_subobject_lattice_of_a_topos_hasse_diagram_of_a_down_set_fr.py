"""Hasse diagram of a down-set frame, regular elements highlighted."""
from __future__ import annotations
from itertools import combinations
from typing import Callable, FrozenSet, List, Set
import matplotlib.pyplot as plt

Elt = FrozenSet[int]

def downsets(points, leq):
    out = []
    for r in range(len(points) + 1):
        for combo in combinations(points, r):
            s = set(combo)
            if all(p in s for q in s for p in points if leq(p, q)):
                out.append(frozenset(s))
    return out

def compl(E, a):
    acc: Set[int] = set()
    for x in E:
        if not (a & x):
            acc |= x
    return frozenset(acc)

def dneg(E, a):
    return compl(E, compl(E, a))

def main():
    pts = [0, 1, 2, 3]
    edges = {(0, 1), (0, 2), (1, 3), (2, 3), (0, 3)}
    leq = lambda p, q: p == q or (p, q) in edges
    E = sorted(downsets(pts, leq), key=lambda s: (len(s), tuple(sorted(s))))
    levels: dict = {}
    for a in E:
        levels.setdefault(len(a), []).append(a)
    pos = {}
    for lev, row in levels.items():
        for i, a in enumerate(row):
            pos[a] = (i - (len(row) - 1) / 2, lev)
    fig, ax = plt.subplots(figsize=(7, 6))
    for a in E:
        for b in E:
            if a < b and len(b) == len(a) + 1:
                (x1, y1), (x2, y2) = pos[a], pos[b]
                ax.plot([x1, x2], [y1, y2], color="gray", zorder=1)
    for a in E:
        x, y = pos[a]
        reg = dneg(E, a) == a
        ax.scatter([x], [y], s=900,
                   color="#2ca02c" if reg else "#d62728", zorder=2)
        ax.text(x, y, "{" + ",".join(map(str, sorted(a))) + "}" if a else "∅",
                ha="center", va="center", color="white", fontsize=8)
    ax.set_title("Frame of down-sets — green = regular (aᶜᶜ=a)")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("frame_hasse.png", dpi=140)
    print("wrote frame_hasse.png")

if __name__ == "__main__":
    main()
