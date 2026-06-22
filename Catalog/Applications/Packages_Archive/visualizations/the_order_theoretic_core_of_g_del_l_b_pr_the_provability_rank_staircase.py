"""
visualize.py -- The provability-rank staircase of Gödel-Löb logic.

Generates a figure illustrating the central computation
    box^k(bot) = Iio k = {0, 1, ..., k-1}
in the concrete model (Set N, natBox), the box of the converse well-founded
frame (N, >). Each application of the provability operator advances the
"falsity rank" by exactly one world -- a staircase with no top step, the
geometric face of an endless hierarchy of unprovable consistency strengths.

Requires matplotlib. Saves 'godel_lob_staircase.png'.
"""

from __future__ import annotations

from typing import FrozenSet, List, Set

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

Prop = FrozenSet[int]


def nat_box(s: Prop, n: int) -> Prop:
    """natBox S = { k < n | for all m < k, m in S }."""
    result: Set[int] = set()
    prefix_ok = True
    for k in range(n):
        if prefix_ok:
            result.add(k)
        if k not in s:
            prefix_ok = False
    return frozenset(result)


def box_iterate(k: int, s: Prop, n: int) -> Prop:
    cur = s
    for _ in range(k):
        cur = nat_box(cur, n)
    return cur


def main() -> None:
    n = 12
    levels: List[Prop] = [box_iterate(k, frozenset(), n) for k in range(n + 1)]

    fig, ax = plt.subplots(figsize=(11, 7))
    for k, lvl in enumerate(levels):
        for w in range(n):
            in_set = w in lvl
            ax.add_patch(
                Rectangle(
                    (w, k),
                    1.0,
                    1.0,
                    facecolor="#2b6cb0" if in_set else "#edf2f7",
                    edgecolor="#a0aec0",
                    linewidth=0.6,
                )
            )
        ax.text(-0.6, k + 0.5, f"$\\Box^{{{k}}}\\bot$", va="center", ha="right",
                fontsize=11)

    ax.set_xlim(-3.0, n + 0.2)
    ax.set_ylim(-0.5, n + 1.2)
    ax.set_xticks([w + 0.5 for w in range(n)])
    ax.set_xticklabels([str(w) for w in range(n)])
    ax.set_yticks([])
    ax.set_xlabel("world / frame depth", fontsize=12)
    ax.set_title(
        "Provability rank in Gödel-Löb logic:  $\\Box^k\\bot = \\mathrm{Iio}\\,k$\n"
        "each box advances the falsity rank by exactly one world",
        fontsize=13,
    )
    ax.set_aspect("equal")
    for spine in ax.spines.values():
        spine.set_visible(False)

    handles = [
        Rectangle((0, 0), 1, 1, facecolor="#2b6cb0", edgecolor="#a0aec0",
                  label="world in $\\Box^k\\bot$ (consistency-strength content)"),
        Rectangle((0, 0), 1, 1, facecolor="#edf2f7", edgecolor="#a0aec0",
                  label="world not yet reached (unprovable)"),
    ]
    ax.legend(handles=handles, loc="lower right", fontsize=10, framealpha=0.95)

    fig.tight_layout()
    fig.savefig("godel_lob_staircase.png", dpi=150)
    print("Saved godel_lob_staircase.png")


if __name__ == "__main__":
    main()
