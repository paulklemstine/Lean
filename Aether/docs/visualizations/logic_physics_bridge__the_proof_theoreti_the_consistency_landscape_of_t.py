"""Visualization: the standard GL frame and the consistency landscape.

Draws the two-world standard Kripke frame 1 -> 0 and annotates each world with
the truth values of `box i bot` and the consistency sentence `Con_i`, making the
independence of Con visually explicit: Con is false at the terminal world 0 and
true at the non-terminal world 1, so it is valid at neither.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def standard_frame() -> Tuple[List[int], List[Tuple[int, int]]]:
    """Worlds and accessibility edges of the standard GL frame (1 sees 0)."""
    return [0, 1], [(1, 0)]


def sat_box_bot(succ: Dict[int, List[int]], w: int) -> bool:
    """box i bot holds at w iff w is terminal (no successors)."""
    return len(succ[w]) == 0


def main() -> None:
    worlds, edges = standard_frame()
    succ: Dict[int, List[int]] = {w: [] for w in worlds}
    for a, b in edges:
        succ[a].append(b)

    pos: Dict[int, Tuple[float, float]] = {0: (0.0, 0.0), 1: (0.0, 2.0)}

    fig, ax = plt.subplots(figsize=(5, 6))

    # edges (accessibility), drawn as arrows
    for a, b in edges:
        xa, ya = pos[a]
        xb, yb = pos[b]
        ax.annotate(
            "", xy=(xb, yb + 0.45), xytext=(xa, ya - 0.45),
            arrowprops=dict(arrowstyle="-|>", lw=2, color="#333"),
        )

    # worlds
    for w in worlds:
        x, y = pos[w]
        box_bot = sat_box_bot(succ, w)
        con_val = not box_bot  # Con_i = box bot -> bot ; true iff box bot false
        color = "#d7eaff" if con_val else "#ffd7d7"
        circ = plt.Circle((x, y), 0.45, color=color, ec="#333", lw=2, zorder=3)
        ax.add_patch(circ)
        ax.text(x, y + 0.08, f"w{w}", ha="center", va="center",
                fontsize=14, fontweight="bold", zorder=4)
        ax.text(x, y - 0.16, "terminal" if box_bot else "internal",
                ha="center", va="center", fontsize=8, style="italic", zorder=4)
        label = (f"$\\Box\\bot$ = {box_bot}\n$\\mathrm{{Con}}$ = {con_val}")
        ax.text(x + 0.8, y, label, ha="left", va="center", fontsize=11)

    ax.set_title("Standard GL frame: Con is true at w1, false at w0\n"
                 "=> neither Con nor ¬Con is valid (independence)",
                 fontsize=11)
    ax.set_xlim(-1.5, 3.2)
    ax.set_ylim(-1.2, 3.2)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("gl_frame_consistency.png", dpi=150)
    print("wrote gl_frame_consistency.png")


if __name__ == "__main__":
    main()
