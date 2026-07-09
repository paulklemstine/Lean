"""Visualize the winding-number homomorphism onto the integer number line.

Powers of the boundary generator g3 map to the integers; the filling map crushes
the whole line to the single point 0. Saves 'winding_number_line.png'.
"""
import matplotlib.pyplot as plt


def main() -> None:
    ks = list(range(-4, 5))
    fig, ax = plt.subplots(figsize=(9, 3))
    ax.axhline(0, color="#1f3b73", linewidth=2)
    for k in ks:
        ax.plot(k, 0, "o", color="#b03030", markersize=9)
        ax.annotate(f"$g_3^{{{k}}}$", (k, 0), textcoords="offset points",
                    xytext=(0, 12), ha="center", fontsize=10)
    ax.annotate("filling: everything $\\mapsto 0$", (0, 0),
                textcoords="offset points", xytext=(0, -40), ha="center",
                fontsize=12, color="#6a3d9a",
                arrowprops=dict(arrowstyle="->", color="#6a3d9a"))
    ax.set_yticks([])
    ax.set_xticks(ks)
    ax.set_title(r"Winding number: $\pi_1(\mathrm{hollow}) \cong \mathbb{Z}$"
                 r" $\twoheadrightarrow$ $1$")
    ax.set_xlim(-4.6, 4.6)
    ax.set_ylim(-1.2, 1.0)
    fig.tight_layout()
    fig.savefig("winding_number_line.png", dpi=150)
    print("saved winding_number_line.png")


if __name__ == "__main__":
    main()
