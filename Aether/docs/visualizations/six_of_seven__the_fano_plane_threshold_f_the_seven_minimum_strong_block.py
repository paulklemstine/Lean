"""Standalone visualization of the Fano plane and its 7 minimum strong blocking
sets (the single-point complements). Saves a PNG grid."""
import math
from itertools import combinations
import matplotlib.pyplot as plt

POINTS = list(range(7))


def fano_line(i):
    return frozenset((i % 7, (i + 1) % 7, (i + 3) % 7))


LINES = [fano_line(i) for i in POINTS]


def is_strong_blocking(s):
    return all(len(line & set(s)) >= 2 for line in LINES)


# Place the 7 points on a circle for a clean cyclic-model layout.
def coords():
    pos = {}
    for p in POINTS:
        ang = 2 * math.pi * p / 7 - math.pi / 2
        pos[p] = (math.cos(ang), math.sin(ang))
    return pos


def draw(ax, chosen):
    pos = coords()
    # draw lines as chords connecting their 3 points (pairwise)
    for line in LINES:
        pts = sorted(line)
        for a, b in combinations(pts, 2):
            xa, ya = pos[a]
            xb, yb = pos[b]
            ax.plot([xa, xb], [ya, yb], color="#cccccc", lw=0.8, zorder=1)
    for p in POINTS:
        x, y = pos[p]
        inS = p in chosen
        ax.scatter([x], [y], s=260,
                   color=("#2b6cb0" if inS else "#e53e3e"),
                   edgecolors="black", zorder=3)
        ax.text(x, y, str(p), ha="center", va="center",
                color="white", fontsize=10, zorder=4)
    ax.set_aspect("equal")
    ax.axis("off")


def main():
    mins = [frozenset(c) for c in combinations(POINTS, 6) if is_strong_blocking(c)]
    fig, axes = plt.subplots(2, 4, figsize=(14, 7))
    axes = axes.ravel()
    for k, s in enumerate(mins):
        missing = (set(POINTS) - s).pop()
        draw(axes[k], s)
        axes[k].set_title(f"Z/7Z \\ {{{missing}}}  (size 6)")
    axes[-1].axis("off")
    fig.suptitle("The 7 minimum strong blocking sets of the Fano plane "
                 "(blue in S, red removed)", fontsize=13)
    fig.tight_layout()
    fig.savefig("fano_strong_blocking.png", dpi=150)
    print("saved fano_strong_blocking.png")


if __name__ == "__main__":
    main()
