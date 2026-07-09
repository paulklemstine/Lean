"""Visualize the Cameron-Liebler parameter line for J_q(4,2): trivial parameters,
the non-trivial window, and the self-complementary Bruen-Drudge midpoint, across q."""
from typing import List
import matplotlib.pyplot as plt


def bd_param(q: int) -> int:
    return (q * q + 1) // 2


def plot_parameter_lines(qs: List[int]) -> None:
    fig, ax = plt.subplots(figsize=(11, 6))
    for i, q in enumerate(qs):
        maxp = q * q + 1
        trivial = {0, 1, 2, q * q - 1, q * q, maxp}
        y = len(qs) - i
        # full range as a thin grey bar
        ax.plot([0, maxp], [y, y], color="0.85", lw=8, solid_capstyle="round",
                zorder=1)
        # non-trivial window in light blue
        ax.plot([2, q * q - 1], [y, y], color="#9ecae1", lw=8,
                solid_capstyle="round", zorder=2)
        # trivial parameters as red dots
        ax.scatter(sorted(trivial), [y] * len(trivial), color="#d62728",
                   s=45, zorder=4, label="trivial" if i == 0 else None)
        # midpoint as a gold star
        bd = bd_param(q)
        odd = (q % 2 == 1)
        ax.scatter([bd], [y], marker="*", s=320,
                   color=("#f1c40f" if odd else "#bbbbbb"),
                   edgecolor="black", zorder=5,
                   label="self-compl. midpoint (odd q)" if i == 0 else None)
        ax.text(maxp + 1.5, y, f"q={q}", va="center", fontsize=11)
    ax.set_yticks([])
    ax.set_xlabel("Cameron-Liebler parameter x  (0 .. q^2+1)")
    ax.set_title("Parameter lines of J_q(4,2): trivial values, non-trivial window, "
                 "and the Bruen-Drudge midpoint")
    ax.legend(loc="upper right")
    ax.set_xlim(-2, max(q * q + 1 for q in qs) + 8)
    plt.tight_layout()
    plt.savefig("parameter_lines.png", dpi=150)
    print("wrote parameter_lines.png")


if __name__ == "__main__":
    plot_parameter_lines([2, 3, 4, 5, 7])
