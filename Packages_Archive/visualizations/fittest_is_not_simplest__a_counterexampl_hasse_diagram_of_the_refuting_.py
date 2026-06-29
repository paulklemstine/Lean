"""Visualize the two-theory fitness landscape and the counterexample.

Renders the sub-theory order as a Hasse diagram with nodes annotated by
fitness, highlighting that the fitness optimum (ext) sits ABOVE a proper
sub-theory (base) -- hence is terminal/maximal but not primitive.
"""
from __future__ import annotations
from fractions import Fraction
import matplotlib.pyplot as plt


def main() -> None:
    # node: (x, y, fitness, primitive)
    nodes = {
        "base": (0.0, 0.0, Fraction(1), True),
        "ext": (0.0, 1.0, Fraction(2), False),
    }
    edges = [("base", "ext")]  # base < ext (proper sub-theory)

    fig, ax = plt.subplots(figsize=(5, 6))
    for s, t in edges:
        x0, y0, *_ = nodes[s]
        x1, y1, *_ = nodes[t]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle="-|>", lw=2, color="#555"))
        ax.text(0.06, 0.5, "ProperSub\n(extension)", color="#555", fontsize=9)

    for name, (x, y, f, prim) in nodes.items():
        color = "#d62728" if not prim else "#2ca02c"
        ax.scatter([x], [y], s=2600, color=color, zorder=3, alpha=0.9)
        label = f"{name}\nf = {f}\n{'primitive' if prim else 'NOT primitive'}"
        ax.text(x, y, label, ha="center", va="center", color="white",
                fontsize=10, fontweight="bold", zorder=4)

    ax.set_title("Maximal fitness need not mean primitive\n"
                 "ext: max-fitness, rank-minimal, terminal -- but reducible",
                 fontsize=11)
    ax.set_xlim(-0.6, 0.9)
    ax.set_ylim(-0.4, 1.4)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("landscape.png", dpi=150)
    print("wrote landscape.png")


if __name__ == "__main__":
    main()
