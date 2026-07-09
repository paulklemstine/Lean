"""Visualize the filling surjection Z ->> 1 as a mapping diagram.

Left column: integer homotopy classes of the hollow square. Right column: the
single class of the filled square. Every arrow lands on the same point, showing
that the surjection merges classes but never invents new ones. Saves
'filling_surjection.png'.
"""
import matplotlib.pyplot as plt


def main() -> None:
    ks = list(range(-3, 4))
    fig, ax = plt.subplots(figsize=(6, 6))
    for k in ks:
        ax.plot(0, k, "o", color="#b03030", markersize=9)
        ax.text(-0.15, k, f"{k}", ha="right", va="center", fontsize=10)
        ax.annotate("", xy=(1, 0), xytext=(0, k),
                    arrowprops=dict(arrowstyle="->", color="#6a3d9a", alpha=0.6))
    ax.plot(1, 0, "s", color="#6fbf73", markersize=14)
    ax.text(1.15, 0, "1 (trivial)", ha="left", va="center", fontsize=11)
    ax.text(0, 4.2, r"$\pi_1(\mathrm{hollow})=\mathbb{Z}$", ha="center", fontsize=12)
    ax.text(1, 4.2, r"$\pi_1(\mathrm{filled})=1$", ha="center", fontsize=12)
    ax.set_title("Filling collapses: a generator-preserving surjection")
    ax.set_xlim(-0.8, 2.0)
    ax.set_ylim(-4.0, 4.8)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("filling_surjection.png", dpi=150)
    print("saved filling_surjection.png")


if __name__ == "__main__":
    main()
