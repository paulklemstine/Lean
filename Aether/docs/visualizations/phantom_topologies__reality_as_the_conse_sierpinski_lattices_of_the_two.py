"""Visualization 3: the Sierpinski refutation on two points.

Shows the open-set lattices of the two Sierpinski observers and their consensus
(the indiscrete topology), the non-metrizable two-point space with phantom
number two.
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def draw_lattice(ax, title: str, opens: list[str]) -> None:
    positions = {
        "{}": (0.5, 0.0),
        "{true}": (0.2, 0.5),
        "{false}": (0.8, 0.5),
        "{true,false}": (0.5, 1.0),
    }
    for name, (x, y) in positions.items():
        present = name in opens
        ax.scatter([x], [y], s=1400,
                   c=("mediumseagreen" if present else "white"),
                   edgecolors="black", zorder=3)
        ax.text(x, y, name, ha="center", va="center", fontsize=8, zorder=4)
    edges = [("{}", "{true}"), ("{}", "{false}"),
             ("{true}", "{true,false}"), ("{false}", "{true,false}")]
    for a, b in edges:
        (xa, ya), (xb, yb) = positions[a], positions[b]
        ax.plot([xa, xb], [ya, yb], color="lightgray", zorder=1)
    ax.set_title(title, fontsize=11)
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.2, 1.2)
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))
    draw_lattice(axes[0], "S_true (opens filled)", ["{}", "{true}", "{true,false}"])
    draw_lattice(axes[1], "S_false (opens filled)", ["{}", "{false}", "{true,false}"])
    draw_lattice(axes[2], "consensus = indiscrete", ["{}", "{true,false}"])
    fig.suptitle("Non-metrizable two-point space as a two-observer consensus",
                 fontsize=13)
    plt.tight_layout()
    plt.savefig("phantom_sierpinski.png", dpi=150)
    print("saved phantom_sierpinski.png")


if __name__ == "__main__":
    main()
