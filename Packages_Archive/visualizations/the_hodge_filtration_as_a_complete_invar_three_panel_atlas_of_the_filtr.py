"""
visualize.py -- Pictures of the filtration <-> bigrading duality (weight two).

Produces a single figure with three panels:

  (A) The Hodge diamond / bigrading  V_C = H20 (+) H11 (+) H02.
  (B) The decreasing Hodge filtration tower  F0 >= F1 >= F2  with the cumulative pieces.
  (C) The reconstruction picture: F1 and its mirror conj(F1) overlap exactly in H11,
      illustrating  H11 = F1 ∩ conj F1.

Depends only on `matplotlib`. Saves `hodge_filtration_duality.png`.
"""

from __future__ import annotations

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch


def panel_bigrading(ax: plt.Axes) -> None:
    ax.set_title("(A) Hodge bigrading  V_C = H20 + H11 + H02", fontsize=11)
    colors = {"H20": "#e74c3c", "H11": "#27ae60", "H02": "#2980b9"}
    # diamond layout: H20 top-left, H11 center, H02 bottom-right
    coords = {"H20": (0.25, 0.75), "H11": (0.5, 0.5), "H02": (0.75, 0.25)}
    for name, (x, y) in coords.items():
        ax.add_patch(plt.Circle((x, y), 0.12, color=colors[name], alpha=0.85))
        ax.text(x, y, name, ha="center", va="center", color="white",
                fontsize=11, fontweight="bold")
    ax.text(0.5, 0.06, "(p,q) with p+q = 2", ha="center", fontsize=9, color="#555")
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def panel_filtration(ax: plt.Axes) -> None:
    ax.set_title("(B) Hodge filtration tower  F0 ⊇ F1 ⊇ F2", fontsize=11)
    # stacked cumulative bars
    ax.add_patch(Rectangle((0.1, 0.1), 0.8, 0.25, color="#e74c3c", alpha=0.85))
    ax.text(0.5, 0.225, "F2 = H20", ha="center", va="center",
            color="white", fontweight="bold")
    ax.add_patch(Rectangle((0.1, 0.35), 0.8, 0.25, color="#27ae60", alpha=0.85))
    ax.text(0.5, 0.475, "F1 = H20 + H11", ha="center", va="center",
            color="white", fontweight="bold")
    ax.add_patch(Rectangle((0.1, 0.60), 0.8, 0.25, color="#2980b9", alpha=0.85))
    ax.text(0.5, 0.725, "F0 = H20 + H11 + H02 = V_C", ha="center", va="center",
            color="white", fontweight="bold")
    ax.annotate("", xy=(0.05, 0.1), xytext=(0.05, 0.85),
                arrowprops=dict(arrowstyle="->", color="#333"))
    ax.text(0.02, 0.5, "p", rotation=90, va="center", fontsize=10)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def panel_reconstruction(ax: plt.Axes) -> None:
    ax.set_title("(C) Reconstruction:  H11 = F1 ∩ conj F1", fontsize=11)
    # two overlapping ellipses: F1 (H20+H11) and conj F1 (H02+H11); overlap = H11
    from matplotlib.patches import Ellipse
    ax.add_patch(Ellipse((0.40, 0.5), 0.5, 0.4, color="#27ae60", alpha=0.45))
    ax.add_patch(Ellipse((0.60, 0.5), 0.5, 0.4, color="#2980b9", alpha=0.45))
    ax.text(0.25, 0.5, "H20", ha="center", va="center", fontweight="bold")
    ax.text(0.75, 0.5, "H02", ha="center", va="center", fontweight="bold")
    ax.text(0.5, 0.5, "H11", ha="center", va="center", fontweight="bold",
            color="#145a32")
    ax.text(0.30, 0.83, "F1 = H20 + H11", ha="center", color="#196f3d", fontsize=9)
    ax.text(0.70, 0.17, "conj F1 = H02 + H11", ha="center", color="#1b4f72", fontsize=9)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    panel_bigrading(axes[0])
    panel_filtration(axes[1])
    panel_reconstruction(axes[2])
    fig.suptitle("The Hodge filtration as a complete invariant (weight two)",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("hodge_filtration_duality.png", dpi=150)
    print("Saved hodge_filtration_duality.png")


if __name__ == "__main__":
    main()
