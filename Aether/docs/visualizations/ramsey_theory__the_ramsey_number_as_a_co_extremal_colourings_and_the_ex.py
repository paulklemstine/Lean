"""
Visualization: the three extremal Ramsey colourings and the bound corridor.

Draws (1) the pentagon C_5 witnessing R(3,3) > 5, (2) the Mobius ladder
C_8(1,4) witnessing R(3,4) > 8, (3) the Paley graph on Z/17 witnessing
R(4,4) > 17, and (4) the exponential bound corridor 2^(m-1) < R(2m,2m) <= 4^(2m-1).
Requires matplotlib. Saves ramsey_figures.png.
"""
from math import cos, sin, pi
import matplotlib.pyplot as plt


def circular_positions(n: int):
    return [(cos(2 * pi * i / n - pi / 2), sin(2 * pi * i / n - pi / 2)) for i in range(n)]


def draw_graph(ax, n: int, adj, title: str) -> None:
    pos = circular_positions(n)
    for i in range(n):
        for j in range(i + 1, n):
            color = "crimson" if adj(i, j) else "#c8d6e5"
            lw = 1.6 if adj(i, j) else 0.5
            ax.plot([pos[i][0], pos[j][0]], [pos[i][1], pos[j][1]],
                    color=color, lw=lw, zorder=1)
    xs, ys = zip(*pos)
    ax.scatter(xs, ys, s=140, color="#222f3e", zorder=2)
    ax.set_title(title, fontsize=11)
    ax.set_aspect("equal"); ax.axis("off")


def main() -> None:
    QR17 = {1, 2, 4, 8, 9, 13, 15, 16}
    pent = lambda a, b: (a - b) % 5 in (1, 4)
    mob = lambda a, b: (a - b) % 8 in (1, 4, 7)
    paley = lambda a, b: (a - b) % 17 in QR17

    fig, axes = plt.subplots(2, 2, figsize=(11, 11))
    draw_graph(axes[0, 0], 5, pent, "Pentagon C_5:  R(3,3) > 5")
    draw_graph(axes[0, 1], 8, mob, "Mobius ladder C_8(1,4):  R(3,4) > 8")
    draw_graph(axes[1, 0], 17, paley, "Paley graph on Z/17:  R(4,4) > 17")

    ax = axes[1, 1]
    ms = list(range(4, 9))
    lower = [2 ** (m - 1) for m in ms]
    upper = [4 ** (2 * m - 1) for m in ms]
    ax.semilogy(ms, lower, "o-", color="navy", label="lower 2^(m-1)")
    ax.semilogy(ms, upper, "s-", color="crimson", label="upper 4^(2m-1)")
    ax.fill_between(ms, lower, upper, color="gold", alpha=0.3)
    ax.set_title("Diagonal sandwich: 2^(m-1) < R(2m,2m) <= 4^(2m-1)")
    ax.set_xlabel("m"); ax.set_ylabel("bound (log scale)"); ax.legend()

    fig.tight_layout()
    fig.savefig("ramsey_figures.png", dpi=130)
    print("wrote ramsey_figures.png")


if __name__ == "__main__":
    main()
