"""Standalone visualization: the two ladders and the Ordinal Collapsing Bridge.

Generates a figure showing
  (left)  the finite depth spectrum of research objects collapsing below omega;
  (right) the strength ladder  omega < epsilon_0 < Gamma_0 < Gamma_1 < ...
and an arrow depicting the exponential lift omega^depth landing safely
below epsilon_0.

Run:  python ordinal_bridge_viz.py   (writes ordinal_bridge.png)
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    # Left: finite depths of sample research objects (all < omega).
    labels = ["atom", "bs^3", "compose", "oracle", "deep"]
    depths = [1, 4, 3, 4, 8]
    ax1.bar(labels, depths, color="#4C72B0")
    ax1.axhline(y=max(depths) + 2, color="red", linestyle="--")
    ax1.text(0.1, max(depths) + 2.2, "omega (unreachable)", color="red")
    ax1.set_title("Finite Branching Collapse: depth < omega")
    ax1.set_ylabel("ordinal depth (a natural number)")

    # Right: the strength ladder on a symbolic log-like scale.
    rungs = ["omega", "e0 (=PA)", "Gamma_0", "Gamma_1", "Gamma_2"]
    heights = [1, 2, 3, 4, 5]
    ax2.plot(heights, range(len(rungs)), "o-", color="#55A868", markersize=10)
    for h, name in zip(heights, rungs):
        ax2.text(h + 0.05, heights.index(h), name, va="center")
    ax2.axhline(y=1, color="orange", linestyle=":")
    ax2.annotate("omega^depth lands here (< e0)",
                 xy=(2, 0.6), xytext=(2.5, -0.4),
                 arrowprops=dict(arrowstyle="->", color="purple"),
                 color="purple")
    ax2.set_title("Strength ladder & the bridge ceiling e0")
    ax2.set_xlim(0.5, 6)
    ax2.set_yticks([])

    fig.suptitle("The Ordinal Collapsing Bridge", fontsize=14)
    fig.tight_layout()
    fig.savefig("ordinal_bridge.png", dpi=150)
    print("wrote ordinal_bridge.png")


if __name__ == "__main__":
    main()
