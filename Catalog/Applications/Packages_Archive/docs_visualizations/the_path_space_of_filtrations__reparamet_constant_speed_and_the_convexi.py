"""
Visualization for the Path Space of Filtrations.

Produces a figure with two panels:
  (left)  the constant-speed geodesic identity: interleaving distance grows
          exactly linearly along the lerp path (a perfectly straight line);
  (right) Busemann convexity: distance from an external observer H to the
          moving point lerp(F,G,t) stays under the straight-line chord,
          with the shaded convexity defect.

Self-contained; requires only matplotlib + numpy.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List

import numpy as np
import matplotlib.pyplot as plt

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def all_simplices(vertices: List[int]) -> List[Simplex]:
    out: List[Simplex] = [frozenset()]
    for k in range(1, len(vertices) + 1):
        out += [frozenset(c) for c in combinations(vertices, k)]
    return out


def fil(vertex_weights: Dict[int, float]) -> Filtration:
    verts = list(vertex_weights)
    return {s: (0.0 if not s else max(vertex_weights[v] for v in s))
            for s in all_simplices(verts)}


def dist(F: Filtration, G: Filtration) -> float:
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def main() -> None:
    F = fil({0: 0.5, 1: 1.0, 2: 1.5, 3: 2.0})
    G = fil({0: 1.2, 1: 0.3, 2: 2.4, 3: 0.9})
    H = fil({0: 2.0, 1: 1.7, 2: 0.4, 3: 1.1})

    ts = np.linspace(0.0, 1.0, 101)
    d_FG = dist(F, G)

    # Panel 1: constant speed (distance from F along the path)
    dF = [dist(F, lerp(F, G, t)) for t in ts]

    # Panel 2: convexity
    dHlerp = [dist(H, lerp(F, G, t)) for t in ts]
    dHF, dHG = dist(H, F), dist(H, G)
    chord = [(1 - t) * dHF + t * dHG for t in ts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ts, dF, lw=2.5, color="#2c7fb8")
    ax1.plot([0, 1], [0, d_FG], "--", color="gray", lw=1)
    ax1.set_title("Constant-speed geodesic\n d(F, lerp(F,G,t)) = t · d(F,G)")
    ax1.set_xlabel("parameter t")
    ax1.set_ylabel("interleaving distance from F")
    ax1.grid(alpha=0.3)

    ax2.plot(ts, dHlerp, lw=2.5, color="#d95f0e", label="d(H, lerp(F,G,t))")
    ax2.plot(ts, chord, "--", color="black", lw=1.5,
             label="(1−t)·d(H,F) + t·d(H,G)")
    ax2.fill_between(ts, dHlerp, chord, color="#fec44f", alpha=0.4,
                     label="convexity defect")
    ax2.set_title("Busemann convexity\n distance to an external observer H")
    ax2.set_xlabel("parameter t")
    ax2.set_ylabel("interleaving distance from H")
    ax2.legend(loc="upper center")
    ax2.grid(alpha=0.3)

    fig.suptitle("The Path Space of Filtrations", fontsize=14)
    fig.tight_layout()
    fig.savefig("path_space_filtrations.png", dpi=150)
    print("Saved path_space_filtrations.png")


if __name__ == "__main__":
    main()
