"""Standalone visualization: independence ratio vs. 1/k coloring bound.

Plots the sharp coloring lower bound 1/k against the exact independence ratio
of the complete graphs K_k (which meet it), and marks the equilateral-triangle
witness at (3, 1/3) sitting strictly above the quarter line.
"""
from __future__ import annotations
import matplotlib.pyplot as plt

ks = list(range(1, 9))
bound = [1.0 / k for k in ks]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ks, bound, "o-", label="coloring bound 1/k  (= rho of K_k)")
ax.axhline(0.25, color="crimson", ls="--", label="quarter threshold 1/4")
ax.scatter([3], [1 / 3], color="green", zorder=5, s=90,
           label="unit triangle witness (rho = 1/3)")
ax.set_xlabel("number of colors k")
ax.set_ylabel("independence ratio")
ax.set_title("Coloring-Independence Bound: 1/k is sharp on K_k")
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("independence_ratio_bound.png", dpi=150)
print("Saved independence_ratio_bound.png")
