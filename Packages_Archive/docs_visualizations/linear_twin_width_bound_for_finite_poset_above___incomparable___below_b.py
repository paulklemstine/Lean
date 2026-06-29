"""
Visualization: the Above / Incomparable / Below banding of a chain seen from an
observer x, illustrating posType_mono and incomp_ord_convex (two thresholds, one
incomparable block).  Produces 'twinwidth_bands.png'.
"""
from __future__ import annotations

from typing import Callable, List

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

Leq = Callable[[int, int], bool]
ABOVE, INCOMP, BELOW = "Above", "Incomp", "Below"
COLOR = {ABOVE: "#1f77b4", INCOMP: "#bdbdbd", BELOW: "#d62728"}


def pos_type(leq: Leq, x: int, c: int) -> str:
    if c != x and leq(c, x):
        return ABOVE
    if c != x and leq(x, c):
        return BELOW
    return INCOMP


def main() -> None:
    chain: List[int] = list(range(12))  # 0 < 1 < ... < 11
    x = 99

    def leq(a: int, b: int) -> bool:
        if a == b:
            return True
        if a in chain and b in chain:
            return a <= b
        # observer above 0..3, incomparable to 4..7, below 8..11
        if b == x:
            return a in (0, 1, 2, 3)
        if a == x:
            return b in (8, 9, 10, 11)
        return False

    seq = [pos_type(leq, x, c) for c in chain]
    fig, ax = plt.subplots(figsize=(10, 2.4))
    for i, t in enumerate(seq):
        ax.add_patch(Rectangle((i, 0), 1, 1, color=COLOR[t]))
        ax.text(i + 0.5, 0.5, str(i), ha="center", va="center", color="white")
    ax.set_xlim(0, len(chain))
    ax.set_ylim(0, 1)
    ax.set_yticks([])
    ax.set_xlabel("chain elements, bottom -> top")
    ax.set_title("Observer's view of a chain: Above (blue) | Incomp (grey) | Below (red)")
    handles = [Rectangle((0, 0), 1, 1, color=COLOR[t]) for t in (ABOVE, INCOMP, BELOW)]
    ax.legend(handles, [ABOVE, INCOMP, BELOW], loc="upper center",
              bbox_to_anchor=(0.5, -0.3), ncol=3)
    fig.tight_layout()
    fig.savefig("twinwidth_bands.png", dpi=150, bbox_inches="tight")
    print("wrote twinwidth_bands.png")


if __name__ == "__main__":
    main()
