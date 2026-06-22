"""
visualization.py
================================================================================
Visualize the bridge between the observation pseudometric and the behavior
congruence on a small algebraic neural observation system.

Two panels:
  (left)  The pairwise observation pseudometric obsDist as a 0/1 heatmap over a
          finite state sample. Distance-zero blocks are exactly the congruence
          classes (the keystone identity, visualized).
  (right) The depth-k partition-refinement curve: number of distinguishable
          classes as the observation depth k grows, stabilizing at the number of
          behavior-congruence classes.

Requires: matplotlib, numpy.  Run:  python visualization.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np

Vec = Tuple[int, ...]
Word = List[int]


def apply_selector(selector: List[Optional[int]], x: Vec) -> Vec:
    return tuple(0 if j is None else x[j] for j in selector)


class AlgNeuralSystem:
    def __init__(self, n: int, m: int,
                 step_selectors: List[List[Optional[int]]],
                 observe_selector: List[Optional[int]]) -> None:
        self.n, self.m = n, m
        self.step_selectors = step_selectors
        self.observe_selector = observe_selector
        self.num_symbols = len(step_selectors)

    def step(self, x: Vec, a: int) -> Vec:
        return apply_selector(self.step_selectors[a], x)

    def observe(self, x: Vec) -> Vec:
        return apply_selector(self.observe_selector, x)

    def behavior(self, x: Vec, w: Word) -> Vec:
        s = x
        for a in w:
            s = self.step(s, a)
        return self.observe(s)


def words_upto(num_symbols: int, k: int) -> List[Word]:
    out: List[Word] = []
    for ell in range(k + 1):
        out += [list(t) for t in product(range(num_symbols), repeat=ell)]
    return out


def equiv_upto(N: AlgNeuralSystem, x: Vec, y: Vec, k: int) -> bool:
    return all(N.behavior(x, w) == N.behavior(y, w) for w in words_upto(N.num_symbols, k))


def num_classes(N: AlgNeuralSystem, states: List[Vec], k: int) -> int:
    reps: List[Vec] = []
    for x in states:
        if not any(equiv_upto(N, x, r, k) for r in reps):
            reps.append(x)
    return len(reps)


def main() -> None:
    # A shift-register algebraic neural system: each step shifts coordinates
    # left (delaying the read-out by one symbol), the last coordinate is held.
    # The read-out observes coordinate 0 only, so depth-k observation reveals
    # coordinate min(k, n-1): states separate progressively as depth grows.
    N = AlgNeuralSystem(
        n=4, m=1,
        step_selectors=[[1, 2, 3, 3]],
        observe_selector=[0],
    )
    states: List[Vec] = [
        (1, 1, 1, 1), (1, 1, 1, 2), (1, 1, 2, 2),
        (1, 2, 2, 2), (2, 2, 2, 2), (1, 2, 3, 4),
    ]
    depth = 4

    # Distance matrix.
    D = np.zeros((len(states), len(states)))
    for i, x in enumerate(states):
        for j, y in enumerate(states):
            D[i, j] = 0.0 if equiv_upto(N, x, y, depth) else 1.0

    # Refinement curve.
    ks = list(range(0, depth + 1))
    classes = [num_classes(N, states, k) for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    im = ax1.imshow(D, cmap="viridis", vmin=0, vmax=1)
    ax1.set_title("Observation pseudometric  obsDist(x, y)\n"
                  "(dark = distance 0 = congruent)")
    labels = [str(s) for s in states]
    ax1.set_xticks(range(len(states)))
    ax1.set_yticks(range(len(states)))
    ax1.set_xticklabels(labels, rotation=90, fontsize=7)
    ax1.set_yticklabels(labels, fontsize=7)
    fig.colorbar(im, ax=ax1, fraction=0.046, pad=0.04, label="distance")

    ax2.plot(ks, classes, "o-", color="crimson", linewidth=2, markersize=8)
    ax2.set_title("Partition refinement: distinguishable classes vs depth k")
    ax2.set_xlabel("observation depth k")
    ax2.set_ylabel("number of classes")
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(ks)

    fig.suptitle("Neural observation pseudometric  ==  behavior congruence kernel",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("bridge_visualization.png", dpi=150)
    print("Saved bridge_visualization.png")


if __name__ == "__main__":
    main()
