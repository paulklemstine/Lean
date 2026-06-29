"""
Visualization: the Lucas-Penrose reflection ladder.

Plots each system F_n as a horizontal band of provable sentences, with the
Godel sentence of each level highlighted as it becomes provable one rung up,
and a fresh diagonal sentence escaping the entire tower.

Run:  python viz_ladder.py   (requires matplotlib)
"""
from typing import List, Set
import matplotlib.pyplot as plt


def reflection_tower(levels: int) -> List[Set[int]]:
    tower: List[Set[int]] = [set()]
    for n in range(levels):
        tower.append(tower[-1] | {n})
    return tower


def main() -> None:
    levels = 6
    tower = reflection_tower(levels)
    fig, ax = plt.subplots(figsize=(9, 5))
    maxs = max(max(s) for s in tower if s) + 2
    for n, sys in enumerate(tower):
        for s in range(maxs):
            color = "#2b8cbe" if s in sys else "#ece7f2"
            ax.add_patch(plt.Rectangle((s, n), 0.9, 0.9, color=color))
        if n < len(tower) - 1:
            ax.text(n + 0.45, n + 0.45, "G", ha="center", va="center",
                    color="white", fontweight="bold")
    ax.text(maxs - 1 + 0.45, len(tower) - 1 + 0.45, "?", ha="center",
            va="center", color="#d7301f", fontweight="bold", fontsize=14)
    ax.set_xlim(0, maxs)
    ax.set_ylim(0, len(tower))
    ax.set_xlabel("sentence index (n encodes Con(F_n))")
    ax.set_ylabel("system level F_n")
    ax.set_title("Reflective ladder: each Godel sentence falls one rung up;\n"
                 "a fresh diagonal (red ?) escapes the whole tower")
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("reflection_ladder.png", dpi=150)
    print("wrote reflection_ladder.png")


if __name__ == "__main__":
    main()
