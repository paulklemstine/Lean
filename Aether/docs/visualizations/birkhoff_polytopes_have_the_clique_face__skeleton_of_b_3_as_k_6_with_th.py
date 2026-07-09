"""
Visualization: the 1-skeleton of the Birkhoff polytope B_3 (the complete graph K_6
on the six permutations) with the transposition triangle highlighted, and the
support-union grid showing why that triangle is not a face.

Requires matplotlib. Saves 'birkhoff_b3_skeleton.png'.
"""

from __future__ import annotations

import math
from itertools import combinations, permutations
from typing import List, Tuple

import matplotlib.pyplot as plt

Perm = Tuple[int, ...]


def all_perms(n: int) -> List[Perm]:
    return [tuple(p) for p in permutations(range(n))]


def compose(a: Perm, b: Perm) -> Perm:
    return tuple(a[b[i]] for i in range(len(a)))


def inverse(p: Perm) -> Perm:
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def is_single_cycle(p: Perm) -> bool:
    seen = [False] * len(p)
    cnt = 0
    for s in range(len(p)):
        if seen[s]:
            continue
        length = 0
        j = s
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        if length >= 2:
            cnt += 1
    return cnt == 1


def adjacent(s: Perm, t: Perm) -> bool:
    return s != t and is_single_cycle(compose(inverse(s), t))


def label(p: Perm) -> str:
    if all(p[i] == i for i in range(len(p))):
        return "id"
    return "".join(str(p[i] + 1) for i in range(len(p)))


def main() -> None:
    n = 3
    verts = all_perms(n)
    triangle = {(1, 0, 2), (2, 1, 0), (0, 2, 1)}  # (1 2), (1 3), (2 3)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Left: K_6 skeleton ----
    pos = {v: (math.cos(2 * math.pi * k / 6), math.sin(2 * math.pi * k / 6))
           for k, v in enumerate(verts)}
    for a, b in combinations(verts, 2):
        if adjacent(a, b):
            xa, ya = pos[a]
            xb, yb = pos[b]
            hot = a in triangle and b in triangle
            ax1.plot([xa, xb], [ya, yb],
                     color="crimson" if hot else "0.8",
                     lw=2.4 if hot else 1.0, zorder=1)
    for v in verts:
        x, y = pos[v]
        hot = v in triangle
        ax1.scatter([x], [y], s=420, color="crimson" if hot else "steelblue", zorder=2)
        ax1.text(x, y, label(v), color="white", ha="center", va="center",
                 fontsize=11, fontweight="bold", zorder=3)
    ax1.set_title("Skeleton of $B_3$ = $K_6$\n(transposition triangle in red)")
    ax1.set_aspect("equal")
    ax1.axis("off")

    # ---- Right: support-union grid ----
    union = set()
    for p in triangle:
        for i in range(n):
            union.add((i, p[i]))
    for i in range(n):
        for j in range(n):
            filled = (i, j) in union
            ax2.add_patch(plt.Rectangle((j, n - 1 - i), 1, 1,
                          facecolor="indianred" if filled else "white",
                          edgecolor="black"))
    # identity diagonal markers
    for i in range(n):
        ax2.plot(i + 0.5, n - 1 - i + 0.5, marker="o", color="black", ms=10)
    ax2.set_xlim(0, n)
    ax2.set_ylim(0, n)
    ax2.set_aspect("equal")
    ax2.set_xticks([])
    ax2.set_yticks([])
    ax2.set_title("Support union of the three swaps = full grid\n"
                  "identity diagonal (dots) lies inside it -> not a face")

    fig.tight_layout()
    fig.savefig("birkhoff_b3_skeleton.png", dpi=150)
    print("saved birkhoff_b3_skeleton.png")


if __name__ == "__main__":
    main()
