"""Visualization 3 -- The impossibility hierarchy as nested regions."""
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse

def hierarchy() -> None:
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.add_patch(Ellipse((0.5, 0.5), 0.9, 0.7, fc="#ffe0e0", ec="k"))
    ax.add_patch(Ellipse((0.55, 0.5), 0.5, 0.45, fc="#ffb0b0", ec="k"))
    ax.add_patch(Ellipse((0.3, 0.5), 0.18, 0.22, fc="#b0ffb0", ec="k"))
    ax.text(0.3, 0.5, "trivial\n(solvable)", ha="center", va="center", fontsize=9)
    ax.text(0.62, 0.5, "free\n(sharpest)", ha="center", va="center", fontsize=9)
    ax.text(0.5, 0.85, "all non-trivial actions = impossible",
            ha="center", fontsize=10)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    ax.set_title("The frontier of impossibility")
    plt.tight_layout(); plt.savefig("viz_hierarchy.png", dpi=150)

if __name__ == "__main__":
    hierarchy()
