"""
Visualization: the convexity gap along synchronized geodesics.

Plots, for a pair of synchronized interleaving geodesics lerp(F,G,.) and
lerp(F',G',.), the actual distance d(lerp(F,G,t), lerp(F',G',t)) (solid) against
the convex (Busemann) bound (1-t) d(F,F') + t d(G,G') (dashed). The shaded region
between them is the curvature slack; that it is always non-negative is the
geometric content of Busemann non-positive curvature. Requires matplotlib.
"""
from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Hashable, List, Sequence

import matplotlib.pyplot as plt

Simplex = FrozenSet[Hashable]
Filtration = Dict[Simplex, float]


def vr(points: Sequence[Sequence[float]], max_dim: int = 2) -> Filtration:
    n = len(points)
    simplices: List[Simplex] = [frozenset()]
    for k in range(1, max_dim + 2):
        simplices += [frozenset(c) for c in combinations(range(n), k)]
    w: Filtration = {}
    for s in simplices:
        v = sorted(s)
        w[s] = 0.0 if len(v) <= 1 else max(
            sum((points[i][d] - points[j][d]) ** 2 for d in range(len(points[0]))) ** 0.5
            for i, j in combinations(v, 2)
        )
    return w


def dist(F: Filtration, G: Filtration) -> float:
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def main() -> None:
    F = vr([(0, 0), (1, 0), (0, 1)])
    G = vr([(0, 0), (2, 0), (0, 2)])
    Fp = vr([(0, 0), (1, 0), (0.5, 1)])
    Gp = vr([(0, 0), (3, 0), (0, 1)])

    ts = [i / 200 for i in range(201)]
    actual = [dist(lerp(F, G, t), lerp(Fp, Gp, t)) for t in ts]
    dFFp, dGGp = dist(F, Fp), dist(G, Gp)
    bound = [(1 - t) * dFFp + t * dGGp for t in ts]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ts, actual, color="#1f77b4", lw=2.4,
            label=r"$d(\mathrm{lerp}(F,G,t),\,\mathrm{lerp}(F',G',t))$")
    ax.plot(ts, bound, color="#d62728", lw=2.0, ls="--",
            label=r"convex bound $(1-t)\,d(F,F')+t\,d(G,G')$")
    ax.fill_between(ts, actual, bound, color="#ffcc80", alpha=0.6,
                    label="curvature slack (>= 0)")
    ax.set_xlabel("geodesic parameter  t")
    ax.set_ylabel("interleaving distance")
    ax.set_title("Busemann convexity of the interleaving metric")
    ax.legend(loc="upper left")
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("bicombing_convexity.png", dpi=150)
    print("wrote bicombing_convexity.png")


if __name__ == "__main__":
    main()
