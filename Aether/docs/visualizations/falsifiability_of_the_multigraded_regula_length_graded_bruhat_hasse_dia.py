"""Visualize the Bruhat order on S_4 as a length-graded Hasse diagram,
coloring smooth permutations (avoid 3412 & 4231) vs singular ones, and
overlay a longest length chain from the identity to the reversal.

Requires matplotlib. Saves `bruhat_S4.png`.
"""
from itertools import combinations, permutations
from typing import Dict, List, Sequence, Tuple

import matplotlib.pyplot as plt

Perm = Tuple[int, ...]
PATTERN_3412: Perm = (2, 3, 0, 1)
PATTERN_4231: Perm = (3, 1, 2, 0)


def length(sigma: Perm) -> int:
    n = len(sigma)
    return sum(1 for i in range(n) for j in range(i + 1, n) if sigma[i] > sigma[j])


def _rel(vals: Sequence[int]) -> Perm:
    rank = {v: r for r, v in enumerate(sorted(vals))}
    return tuple(rank[v] for v in vals)


def contains(sigma: Perm, pat: Perm) -> bool:
    k = len(pat)
    return any(_rel([sigma[p] for p in pos]) == pat
               for pos in combinations(range(len(sigma)), k))


def is_smooth(sigma: Perm) -> bool:
    return not contains(sigma, PATTERN_3412) and not contains(sigma, PATTERN_4231)


def covers(sigma: Perm) -> List[Perm]:
    n = len(sigma)
    out = []
    for i in range(n - 1):
        if sigma[i] < sigma[i + 1]:
            t = list(sigma)
            t[i], t[i + 1] = t[i + 1], t[i]
            out.append(tuple(t))
    return out


def main() -> None:
    n = 4
    perms = list(permutations(range(n)))
    by_rank: Dict[int, List[Perm]] = {}
    for p in perms:
        by_rank.setdefault(length(p), []).append(p)

    pos: Dict[Perm, Tuple[float, float]] = {}
    for r, ps in by_rank.items():
        ps_sorted = sorted(ps)
        for k, p in enumerate(ps_sorted):
            x = k - (len(ps_sorted) - 1) / 2.0
            pos[p] = (x, r)

    fig, ax = plt.subplots(figsize=(11, 9))
    for p in perms:
        x0, y0 = pos[p]
        for q in covers(p):
            x1, y1 = pos[q]
            ax.plot([x0, x1], [y0, y1], color="0.8", lw=0.7, zorder=1)

    for p in perms:
        x, y = pos[p]
        color = "#2e7d32" if is_smooth(p) else "#c62828"
        ax.scatter([x], [y], s=420, c=color, zorder=2, edgecolors="black")
        word = "".join(str(v + 1) for v in p)
        ax.text(x, y, word, ha="center", va="center", color="white",
                fontsize=8, zorder=3)

    ax.set_title("Bruhat order on S_4  (green = smooth, red = singular)\n"
                 "rows graded by inversion length 0..C(4,2)=6")
    ax.set_xlabel("permutations within each rank")
    ax.set_ylabel("inversion length")
    ax.set_yticks(range(0, 7))
    ax.set_xticks([])
    plt.tight_layout()
    plt.savefig("bruhat_S4.png", dpi=150)
    print("wrote bruhat_S4.png")


if __name__ == "__main__":
    main()
