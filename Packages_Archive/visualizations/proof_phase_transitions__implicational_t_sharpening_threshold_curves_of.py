"""
Visualization: the sharp threshold of derivability in random implicational theories.

For each density p we estimate P[0 reaches n-1] in a random directed theory on n
atoms, for several n, and overlay the curves. As n grows the transition steepens
toward a sharp threshold (the Friedgut regime), while the chain theory marks the
minimal-density extremal benchmark.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import random
from collections import deque
from typing import Dict, List, Set

import matplotlib.pyplot as plt
import numpy as np


def derivable(edges: Set[tuple[int, int]], a: int, b: int) -> bool:
    adj: Dict[int, List[int]] = {}
    for x, y in edges:
        adj.setdefault(x, []).append(y)
    seen = {a}
    q = deque([a])
    while q:
        x = q.popleft()
        if x == b:
            return True
        for y in adj.get(x, ()):
            if y not in seen:
                seen.add(y)
                q.append(y)
    return b in seen


def reach_prob(n: int, p: float, trials: int, rng: random.Random) -> float:
    hits = 0
    for _ in range(trials):
        edges = {
            (a, b)
            for a in range(n)
            for b in range(n)
            if a != b and rng.random() < p
        }
        if derivable(edges, 0, n - 1):
            hits += 1
    return hits / trials


def main() -> None:
    rng = random.Random(7)
    ps = np.linspace(0.0, 0.12, 25)
    plt.figure(figsize=(9, 6))
    for n in (15, 30, 60):
        ys = [reach_prob(n, float(p), 150, rng) for p in ps]
        plt.plot(ps, ys, marker="o", label=f"n = {n}")
    plt.axhline(0.5, color="gray", ls="--", lw=1)
    plt.xlabel("edge density p")
    plt.ylabel("P[ 0 derives n-1 ]")
    plt.title("Proof Phase Transition: sharpening threshold as n grows")
    plt.legend()
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("proof_phase_transition.png", dpi=150)
    print("saved proof_phase_transition.png")


if __name__ == "__main__":
    main()
