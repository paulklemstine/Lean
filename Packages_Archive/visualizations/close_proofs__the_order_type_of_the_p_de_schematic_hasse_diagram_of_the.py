"""Render a schematic Hasse-style diagram of the established p-degree skeleton:
bottom (zeroSys), the chain linSystem < fibSystem, the power ladder with density
witnesses, an antichain near the bottom, and the absence of a top.
Requires matplotlib."""
from __future__ import annotations
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(7, 9))
    ax.axis("off")

    def node(x: float, y: float, label: str) -> None:
        ax.scatter([x], [y], s=60, color="#2c3e50", zorder=3)
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(8, 0), fontsize=9)

    def edge(p, q) -> None:
        ax.plot([p[0], q[0]], [p[1], q[1]], color="#95a5a6", zorder=1)

    bot = (0.0, 0.0); node(*bot, "zeroSys (bottom)")
    lin = (-1.0, 1.0); fibd = (-1.0, 2.2)
    node(*lin, "linSystem"); node(*fibd, "fibSystem")
    edge(bot, lin); edge(lin, fibd)

    # power ladder with density witnesses on the right
    rungs = [(1.0, 1.0 + 1.3 * i) for i in range(4)]
    for i, r in enumerate(rungs):
        node(*r, f"powSystem {i+1}")
        if i > 0:
            edge(rungs[i-1], r)
            mid = ((rungs[i-1][0] + r[0]) / 2 + 0.6, (rungs[i-1][1] + r[1]) / 2)
            node(*mid, f"interPowSys {i}")
            edge(rungs[i-1], mid); edge(mid, r)
    edge(bot, rungs[0])

    # antichain near the bottom
    for j, dx in enumerate((-0.4, 0.0, 0.4)):
        a = (dx, 0.55)
        node(*a, "")
        edge(bot, a)
    ax.annotate("bounded antichain (infinite width, low in the order)",
                (-0.4, 0.55), textcoords="offset points", xytext=(-10, -16),
                fontsize=8, color="#7f8c8d")

    ax.annotate("... no greatest element (no top) ...", (0.5, 6.4),
                fontsize=10, color="#c0392b")
    ax.set_title("Schematic order type of the p-degrees", fontsize=12)
    fig.tight_layout()
    fig.savefig("pdegree_hasse.png", dpi=140)
    print("wrote pdegree_hasse.png")


if __name__ == "__main__":
    main()
