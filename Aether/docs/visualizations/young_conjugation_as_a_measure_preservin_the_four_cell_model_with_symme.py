"""Draw the four-cell natural-extension model with symmetry action arrows."""
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def draw() -> None:
    fig, ax = plt.subplots(figsize=(6, 6))
    colors = {"D1": "#8ecae6", "D2": "#ffb703",
              "D3": "#219ebc", "D4": "#fb8500"}
    coords = {"D1": (0, 0), "D2": (0, 0.5), "D3": (0.5, 0.5), "D4": (0.5, 0)}
    for name, (x0, y0) in coords.items():
        ax.add_patch(patches.Rectangle((x0, y0), 0.5, 0.5,
                     facecolor=colors[name], edgecolor="black"))
        ax.text(x0 + 0.25, y0 + 0.25, name, ha="center", va="center",
                fontsize=16, fontweight="bold")
    ax.plot([0, 1], [0, 1], "k--", lw=1)   # main diagonal (sigma axis)
    ax.plot([0, 1], [1, 0], "r--", lw=1)   # anti-diagonal (alpha axis)
    ax.plot(0.5, 0.5, "ko", ms=6)          # center (tau)
    ax.set_xlim(-0.05, 1.05); ax.set_ylim(-0.05, 1.05)
    ax.set_aspect("equal"); ax.set_title("Four equal-mass cells (each area 1/4)")
    plt.savefig("cells.png", dpi=150, bbox_inches="tight")


if __name__ == "__main__":
    draw()
