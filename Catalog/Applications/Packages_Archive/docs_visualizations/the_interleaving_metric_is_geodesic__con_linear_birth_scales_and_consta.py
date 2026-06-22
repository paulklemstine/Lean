"""Visualization: the constant-speed geodesic in the space of filtrations.

Generates a two-panel figure:
  (left)  per-simplex weights sliding linearly from F to G along lerp(F,G,t);
  (right) the interleaving distance d(F, lerp_t) growing exactly linearly in t,
          overlaid with the theoretical line t * d(F, G), confirming the
          constant-speed geodesic identity.

Requires matplotlib. Saves 'geodesic_filtrations.png'.
"""
from __future__ import annotations
from typing import Dict, FrozenSet, List
import matplotlib.pyplot as plt

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]

def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}

def interleaving_distance(F: Filtration, G: Filtration) -> float:
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)

F: Filtration = {frozenset({0, 1}): 1.0, frozenset({0, 2}): 2.0,
                 frozenset({1, 2}): 3.0, frozenset({0, 1, 2}): 4.0}
G: Filtration = {frozenset({0, 1}): 2.5, frozenset({0, 2}): 2.0,
                 frozenset({1, 2}): 5.0, frozenset({0, 1, 2}): 6.0}

ts: List[float] = [i / 100 for i in range(101)]
d_FG = interleaving_distance(F, G)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

for sigma in sorted(F, key=lambda x: tuple(sorted(x))):
    ys = [lerp(F, G, t)[sigma] for t in ts]
    label = "{" + ",".join(map(str, sorted(sigma))) + "}"
    ax1.plot(ts, ys, label=label)
ax1.set_title("Per-simplex birth scales along lerp(F, G, t)")
ax1.set_xlabel("t"); ax1.set_ylabel("weight")
ax1.legend(title="simplex", fontsize=8)
ax1.grid(alpha=0.3)

dists = [interleaving_distance(F, lerp(F, G, t)) for t in ts]
ax2.plot(ts, dists, lw=2, label="d(F, lerp(F,G,t))  (computed)")
ax2.plot(ts, [t * d_FG for t in ts], "k--", label="t * d(F, G)  (theory)")
ax2.scatter([0.5], [0.5 * d_FG], color="red", zorder=5, label="midpoint")
ax2.set_title("Constant-speed geodesic: distance grows linearly")
ax2.set_xlabel("t"); ax2.set_ylabel("interleaving distance")
ax2.legend(fontsize=9); ax2.grid(alpha=0.3)

fig.suptitle("The interleaving metric is geodesic", fontsize=14)
fig.tight_layout()
fig.savefig("geodesic_filtrations.png", dpi=150)
print("saved geodesic_filtrations.png")
