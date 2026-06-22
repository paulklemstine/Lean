"""
Visualization of Boltzmann Bridge X: the geodesic ruler of filtration space.

Generates a two-panel figure:
  (left)  the constant-speed geodesic identity d(F, lerp t) = t * d(F,G) and
          the far-endpoint mirror d(lerp t, G) = (1-t) * d(F,G), whose sum is
          the constant d(F,G) -- the universal additive split (bisection).
  (right) exact additive betweenness for ordered s <= u <= t, shown as stacked
          segment lengths on the geodesic ruler.
"""
from __future__ import annotations

from typing import Dict, FrozenSet, List
import matplotlib.pyplot as plt

Weight = Dict[FrozenSet[int], float]


def interleaving_distance(F: Weight, G: Weight) -> float:
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)


def lerp(F: Weight, G: Weight, t: float) -> Weight:
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def main() -> None:
    # A small filtration pair (weights on three simplices).
    F: Weight = {frozenset(): 0.0, frozenset({0}): 0.0, frozenset({0, 1}): 1.0}
    G: Weight = {frozenset(): 0.0, frozenset({0}): 0.0, frozenset({0, 1}): 4.0}
    d = interleaving_distance(F, G)

    ts = [i / 100.0 for i in range(101)]
    d_from_F = [interleaving_distance(F, lerp(F, G, t)) for t in ts]
    d_to_G = [interleaving_distance(lerp(F, G, t), G) for t in ts]
    total = [a + b for a, b in zip(d_from_F, d_to_G)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(ts, d_from_F, label="d(F, lerp t) = t·d(F,G)", lw=2)
    ax1.plot(ts, d_to_G, label="d(lerp t, G) = (1−t)·d(F,G)", lw=2)
    ax1.plot(ts, total, "k--", label="sum = d(F,G) (constant)", lw=2)
    ax1.set_xlabel("geodesic parameter t")
    ax1.set_ylabel("interleaving distance")
    ax1.set_title("Constant-speed geodesic & universal additive split")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Betweenness as stacked ruler segments for s=0.2, u=0.55, t=0.9.
    s, u, t = 0.2, 0.55, 0.9
    Fs, Fu, Ft = lerp(F, G, s), lerp(F, G, u), lerp(F, G, t)
    seg1 = interleaving_distance(Fs, Fu)
    seg2 = interleaving_distance(Fu, Ft)
    whole = interleaving_distance(Fs, Ft)
    ax2.barh(["d(s,u)+d(u,t)"], [seg1], color="#4c72b0", label="d(s,u)")
    ax2.barh(["d(s,u)+d(u,t)"], [seg2], left=[seg1], color="#dd8452", label="d(u,t)")
    ax2.barh(["d(s,t)"], [whole], color="#55a868", label="d(s,t)")
    ax2.set_xlabel("interleaving distance")
    ax2.set_title(f"Exact betweenness: d(s,u)+d(u,t)=d(s,t)  ({seg1:.2f}+{seg2:.2f}={whole:.2f})")
    ax2.legend()
    ax2.grid(alpha=0.3, axis="x")

    fig.suptitle("Boltzmann Bridge X — gluing of interleaving geodesics", fontsize=14)
    fig.tight_layout()
    fig.savefig("bridge_x_geodesic.png", dpi=150)
    print("saved bridge_x_geodesic.png")


if __name__ == "__main__":
    main()
