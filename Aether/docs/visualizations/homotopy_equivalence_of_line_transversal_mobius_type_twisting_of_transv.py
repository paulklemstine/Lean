"""Visualization: a Mobius-type twisting of geometric permutations around a
loop of directions, the discrete picture behind cgh_no_section. Saves a PNG."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def main() -> None:
    n = 200
    fig, axes = plt.subplots(1, 2, figsize=(11, 5), subplot_kw={"aspect": "equal"})
    for ax, twist, title in (
        (axes[0], 2, "Even twist: section exists (sphere type)"),
        (axes[1], 1, "Odd twist: no section (CGH obstruction)"),
    ):
        ts = [2 * math.pi * k / n for k in range(n + 1)]
        xs = [math.cos(t) for t in ts]
        ys = [math.sin(t) for t in ts]
        # the "ribbon" half-width flips sign according to the twist
        off = [0.18 * math.cos(twist * t / 2) for t in ts]
        ox = [(1 + o) * math.cos(t) for t, o in zip(ts, off)]
        oy = [(1 + o) * math.sin(t) for t, o in zip(ts, off)]
        ax.plot(xs, ys, "k--", lw=1, alpha=0.5, label="direction loop")
        ax.plot(ox, oy, "C3", lw=2, label="chosen transversal label")
        ax.set_title(title)
        ax.legend(loc="lower center", fontsize=8)
        ax.axis("off")
    fig.suptitle("Section existence around a loop of directions")
    fig.tight_layout()
    fig.savefig("transversal_monodromy.png", dpi=150)
    print("saved transversal_monodromy.png")

if __name__ == "__main__":
    main()