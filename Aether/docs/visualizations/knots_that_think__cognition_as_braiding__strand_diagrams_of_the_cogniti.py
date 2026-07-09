"""Visualization: strand diagrams of the three cognitive braids."""
import matplotlib.pyplot as plt


def draw_braid(ax, crossings, strands, title):
    # crossings: list of generator indices i (with sign for over/under)
    n_steps = max(1, len(crossings))
    ax.set_title(title)
    ax.set_xlim(-0.5, strands - 0.5)
    ax.set_ylim(0, n_steps)
    positions = list(range(strands))
    for step, c in enumerate(crossings):
        i = abs(c) - 1
        y0, y1 = n_steps - step, n_steps - step - 1
        for s in range(strands):
            if s == i:
                ax.plot([i, i + 1], [y0, y1], color="#2ca02c")
            elif s == i + 1:
                ax.plot([i + 1, i], [y0, y1], color="#d62728")
            else:
                ax.plot([s, s], [y0, y1], color="#888888")
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(11, 4))
    draw_braid(axes[0], [], 2, "trivial: 1")
    draw_braid(axes[1], [1, 1, 1], 2, "creative: s0^3")
    draw_braid(axes[2], [1, -2, 1, -2], 3, "confused: (s0 s1^-1)^2")
    fig.tight_layout()
    fig.savefig("braid_diagrams.png", dpi=150)
    print("saved braid_diagrams.png")


if __name__ == "__main__":
    main()
