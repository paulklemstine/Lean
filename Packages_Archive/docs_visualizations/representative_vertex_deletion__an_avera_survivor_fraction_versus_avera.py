"""
Visualization: survivor fraction vs. average degree for random 3-uniform
hypergraphs, overlaid with the certified guarantee (1 − δ).

Generates 'deletion_bound.png'. Requires matplotlib and numpy.
"""

from __future__ import annotations

from fractions import Fraction
from typing import FrozenSet, Set
import random

import matplotlib.pyplot as plt
import numpy as np

Edge = FrozenSet[int]
Hypergraph = Set[Edge]
Pool = FrozenSet[int]


def contained_edges(E: Hypergraph, S: Pool) -> Set[Edge]:
    return {e for e in E if e <= S}


def deterministic_deletion(E: Hypergraph, S: Pool) -> FrozenSet[int]:
    reps = {min(e) for e in contained_edges(E, S) if e}
    return frozenset(S - reps)


def degree(E: Hypergraph, v: int) -> int:
    return sum(1 for e in E if v in e)


def average_degree(E: Hypergraph, S: Pool) -> float:
    if not S:
        return 0.0
    return sum(degree(E, v) for v in S) / len(S)


def sample_point(n: int, m: int, rng: random.Random) -> tuple[float, float]:
    S = frozenset(range(1, n + 1))
    E: Hypergraph = set()
    while len(E) < m:
        E.add(frozenset(rng.sample(range(1, n + 1), 3)))
    delta = average_degree(E, S)
    ratio = len(deterministic_deletion(E, S)) / n
    return delta, ratio


def main() -> None:
    rng = random.Random(2026)
    n = 40
    deltas, ratios = [], []
    for m in range(0, 60):
        for _ in range(12):
            d, r = sample_point(n, m, rng)
            deltas.append(d)
            ratios.append(r)

    deltas = np.array(deltas)
    ratios = np.array(ratios)

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.scatter(deltas, ratios, s=14, alpha=0.45,
               label="actual survivor fraction |I|/|S|", color="#2c7fb8")
    xs = np.linspace(0, deltas.max(), 200)
    ax.plot(xs, np.clip(1 - xs, 0, 1), color="#d95f0e", lw=2.5,
            label="certified guarantee max(1 − δ, 0)")
    ax.set_xlabel("average degree δ over the pool S", fontsize=12)
    ax.set_ylabel("independent-set fraction", fontsize=12)
    ax.set_title("Representative-vertex deletion: actual vs. guaranteed\n"
                 "independent-set size for random 3-uniform hypergraphs",
                 fontsize=13)
    ax.axhline(0, color="gray", lw=0.6)
    ax.legend(fontsize=11)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("deletion_bound.png", dpi=150)
    print("Saved deletion_bound.png")


if __name__ == "__main__":
    main()
