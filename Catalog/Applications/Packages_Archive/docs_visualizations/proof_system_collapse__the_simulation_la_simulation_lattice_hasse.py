"""Visualization: the simulation lattice as the powerset of theorems.

Draws the Hasse diagram of proof systems modulo simulation over a small formula
universe {a, b, c}.  By the duality theorem (every subset is realized as some
system's provable set), this lattice is exactly the powerset lattice ordered by
inclusion.  Edges are covers; nodes are labelled by provable sets.  The join of
two nodes is their union, the meet is their intersection.

Run:  python visualization.py   ->   writes simulation_lattice.png
"""

from __future__ import annotations

from itertools import combinations

import matplotlib.pyplot as plt


def powerset(elems: list[str]) -> list[frozenset[str]]:
    out: list[frozenset[str]] = []
    for r in range(len(elems) + 1):
        for c in combinations(elems, r):
            out.append(frozenset(c))
    return out


def covers(a: frozenset[str], b: frozenset[str]) -> bool:
    """b covers a: a < b and |b| = |a| + 1."""
    return a < b and len(b) == len(a) + 1


def label(s: frozenset[str]) -> str:
    return "{" + ",".join(sorted(s)) + "}" if s else "{}"


def main() -> None:
    elems = ["a", "b", "c"]
    nodes = powerset(elems)
    # layout by rank (cardinality) on the y-axis
    by_rank: dict[int, list[frozenset[str]]] = {}
    for n in nodes:
        by_rank.setdefault(len(n), []).append(n)
    pos: dict[frozenset[str], tuple[float, float]] = {}
    for rank, group in by_rank.items():
        group = sorted(group, key=lambda s: sorted(s))
        for i, n in enumerate(group):
            x = i - (len(group) - 1) / 2.0
            pos[n] = (x, float(rank))

    fig, ax = plt.subplots(figsize=(8, 7))
    for a in nodes:
        for b in nodes:
            if covers(a, b):
                (x0, y0), (x1, y1) = pos[a], pos[b]
                ax.plot([x0, x1], [y0, y1], color="#9bb7d4", lw=1.3, zorder=1)
    for n in nodes:
        x, y = pos[n]
        ax.scatter([x], [y], s=1400, color="#1f4e79", zorder=2)
        ax.text(x, y, label(n), color="white", ha="center", va="center",
                fontsize=9, zorder=3)

    ax.set_title("Simulation lattice = powerset of theorems  (universe {a,b,c})",
                 fontsize=12)
    ax.text(0, -0.6, "bottom = setSys(empty)   top = setSys(univ)   "
                     "join = union, meet = intersection",
            ha="center", fontsize=9, color="#444")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("simulation_lattice.png", dpi=150)
    print("wrote simulation_lattice.png")


if __name__ == "__main__":
    main()
