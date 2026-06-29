"""Visualization: the consistency hierarchy as nested certificates."""
from __future__ import annotations
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse


def plot_hierarchy() -> None:
    fig, ax = plt.subplots(figsize=(8, 6))
    # Three nested ellipses: mathematical > physical > quantum consistency.
    specs = [
        ("Mathematically consistent\n(no proof of falsum)", 9.0, 6.5, "#cfe8ff"),
        ("Physically consistent\n(has a model)", 6.2, 4.4, "#9fccff"),
        ("Quantum consistent\n(superposition-closed)", 3.4, 2.5, "#5fa8ff"),
    ]
    for label, w, h, color in specs:
        ax.add_patch(Ellipse((5, 4), w, h, facecolor=color, edgecolor="navy", lw=1.5))
    ax.text(5, 6.8, specs[0][0], ha="center", va="center", fontsize=10)
    ax.text(5, 5.4, specs[1][0], ha="center", va="center", fontsize=10)
    ax.text(5, 4.0, specs[2][0], ha="center", va="center", fontsize=10)
    # The separation theorem: a consistent theory with no model lives in the gap.
    ax.plot(5, 7.4, marker="*", markersize=18, color="crimson")
    ax.text(5, 7.75, "empty-world theory:\nconsistent but no model\n(separation theorem)",
            ha="center", va="center", fontsize=8, color="crimson")
    ax.set_xlim(0, 10); ax.set_ylim(0, 9); ax.axis("off")
    ax.set_title("Logic-Physics Bridge: nested certificates of possibility")
    plt.tight_layout()
    plt.savefig("logic_physics_hierarchy.png", dpi=150)
    print("wrote logic_physics_hierarchy.png")


if __name__ == "__main__":
    plot_hierarchy()
