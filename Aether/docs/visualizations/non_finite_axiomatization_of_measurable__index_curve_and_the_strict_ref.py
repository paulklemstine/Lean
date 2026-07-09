"""
Visualization: the incoherence index across cyclic frames and the strict-refinement
staircase.

Produces two panels:
  (left)  index({1} in Z/nZ) = n vs. n, with the index({1,3} in Z/4Z) = 2 outlier
          highlighting the saturation collapse.
  (right) the strict-refinement staircase: for each budget B, the maximal frame
          {1} in Z/(B+1)Z passes width B (green) but fails width B+1 (red),
          visualizing why no finite width certifies coherence.

Requires matplotlib and numpy. Saves 'incoherence_index.png'.
"""

from __future__ import annotations

from itertools import product
from typing import FrozenSet, Optional, List

import matplotlib.pyplot as plt
import numpy as np


def shortest_balanced_length(n: int, frame: FrozenSet[int]) -> Optional[int]:
    if not frame:
        return None
    atoms = sorted(frame)
    for length in range(1, n + 1):
        for combo in product(atoms, repeat=length):
            if sum(combo) % n == 0:
                return length
    return None


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: index of {1} in Z/nZ
    ns: List[int] = list(range(2, 14))
    idx_singleton = [shortest_balanced_length(n, frozenset({1})) for n in ns]
    ax1.plot(ns, idx_singleton, "o-", color="#2b6cb0", lw=2, label="index({1}) = n")
    sat = shortest_balanced_length(4, frozenset({1, 3}))
    ax1.scatter([4], [sat], color="#c53030", s=120, zorder=5,
                label="index({1,3} in Z/4Z) = 2")
    ax1.annotate("saturation collapse\n(adding atom 3)", xy=(4, sat),
                 xytext=(6, 3.0), color="#c53030",
                 arrowprops=dict(arrowstyle="->", color="#c53030"))
    ax1.set_xlabel("number of social states n")
    ax1.set_ylabel("incoherence index")
    ax1.set_title("Extremal index is the privilege of the sparse generator {1}")
    ax1.grid(alpha=0.3)
    ax1.legend()

    # Panel 2: strict-refinement staircase
    Bs = list(range(0, 10))
    ax2.bar([b - 0.18 for b in Bs], [b for b in Bs], width=0.36,
            color="#38a169", label="largest loop the width-B audit allows")
    ax2.bar([b + 0.18 for b in Bs], [b + 1 for b in Bs], width=0.36,
            color="#c53030", label="hidden violation length (B+1) in {1} in Z/(B+1)Z")
    ax2.set_xlabel("audit budget B")
    ax2.set_ylabel("loop length")
    ax2.set_title("Strict refinement: a fresh violation just past every budget")
    ax2.set_xticks(Bs)
    ax2.grid(alpha=0.3, axis="y")
    ax2.legend()

    fig.suptitle("Non-Finite-Axiomatization of Measurable Majorities "
                 "via the Incoherence Index", fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("incoherence_index.png", dpi=150)
    print("Saved incoherence_index.png")


if __name__ == "__main__":
    main()
