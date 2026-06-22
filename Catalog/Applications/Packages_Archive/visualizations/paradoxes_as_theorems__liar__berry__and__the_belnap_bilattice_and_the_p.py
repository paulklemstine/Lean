"""Visualization: the Belnap bilattice and the paradox locus.

Renders the four-valued bilattice with the truth order on one axis and the
information order on the other, highlighting the negation-fixed-point locus
{B, N} where the Liar and Russell paradoxes come to rest.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def draw_bilattice() -> None:
    # Coordinates: information order (x), truth order (y)
    coords = {
        "N": (0.0, 0.0),   # neither: bottom information, middle truth
        "F": (-1.0, -1.0),  # false only
        "T": (1.0, 1.0),    # true only (we lay it out diagonally for clarity)
        "B": (0.0, 2.0),    # both: top information
    }
    # Re-layout as the classic diamond: x = information, y = truth
    coords = {
        "F": (-1.0, 0.0),
        "T": (1.0, 0.0),
        "N": (0.0, -1.0),
        "B": (0.0, 1.0),
    }
    designated = {"T", "B"}
    fixed = {"B", "N"}

    fig, ax = plt.subplots(figsize=(7, 7))

    # truth-order edges (F < N,B < T): meet/join lattice
    edges = [("F", "N"), ("N", "T"), ("F", "B"), ("B", "T")]
    for a, b in edges:
        xa, ya = coords[a]
        xb, yb = coords[b]
        ax.plot([xa, xb], [ya, yb], color="#888", lw=1.5, zorder=1)

    for label, (x, y) in coords.items():
        face = "#e74c3c" if label in fixed else "#3498db"
        edge = "#f1c40f" if label in designated else "#2c3e50"
        ax.scatter([x], [y], s=2600, c=face, edgecolors=edge, linewidths=4, zorder=2)
        ax.text(x, y, label, ha="center", va="center",
                fontsize=22, fontweight="bold", color="white", zorder=3)

    ax.set_title("Belnap bilattice: paradox locus {B, N} (red),\n"
                 "designated values {T, B} (gold ring)",
                 fontsize=13)
    ax.set_xlabel("information order  →")
    ax.set_ylabel("truth order  ↑")
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect("equal")
    ax.grid(alpha=0.2)
    plt.tight_layout()
    plt.savefig("belnap_bilattice.png", dpi=150)
    print("wrote belnap_bilattice.png")


if __name__ == "__main__":
    draw_bilattice()
