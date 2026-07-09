"""Visualize the hollow square (a hole) versus the filled square (contractible).

Draws two unit squares side by side. The left square is hollow: its boundary
loop cannot be contracted and the fundamental group is Z. The right square is
filled with a shaded 2-cell: the boundary loop contracts and the group is
trivial. Saves 'square_hollow_vs_filled.png'.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def draw_square(ax, filled: bool, title: str) -> None:
    corners = [(0, 0), (1, 0), (1, 1), (0, 1), (0, 0)]
    xs, ys = zip(*corners)
    if filled:
        ax.add_patch(patches.Polygon(corners[:-1], closed=True,
                                     facecolor="#6fbf73", alpha=0.5,
                                     edgecolor="none"))
    ax.plot(xs, ys, color="#1f3b73", linewidth=3)
    labels = {0: (0.5, -0.08), 1: (1.08, 0.5), 2: (0.5, 1.08), 3: (-0.08, 0.5)}
    for e, (x, y) in labels.items():
        ax.text(x, y, f"e{e}", ha="center", va="center", fontsize=11,
                color="#b03030")
    group = r"$\pi_1 = 1$" if filled else r"$\pi_1 = \mathbb{Z}$"
    ax.text(0.5, 0.5, group, ha="center", va="center", fontsize=16)
    ax.set_title(title)
    ax.set_xlim(-0.3, 1.4)
    ax.set_ylim(-0.3, 1.4)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(9, 4.5))
    draw_square(axes[0], filled=False, title="Hollow square: a real hole")
    draw_square(axes[1], filled=True, title="Filled square: contractible")
    fig.suptitle("Filling a square kills its boundary loop", fontsize=14)
    fig.tight_layout()
    fig.savefig("square_hollow_vs_filled.png", dpi=150)
    print("saved square_hollow_vs_filled.png")


if __name__ == "__main__":
    main()
