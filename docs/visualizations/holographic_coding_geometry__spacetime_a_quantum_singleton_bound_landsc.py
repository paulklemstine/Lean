#!/usr/bin/env python3
"""
Visualization: Quantum Singleton Bound Landscape

Visualizes the quantum Singleton bound N - K ≤ 2(D - 1) as a 2D plot
showing the feasible region in the (rate K/N, relative distance D/N) plane.

The boundary of this region is the "Singleton limit" — codes achieving
equality are maximum distance separable (MDS) codes, which are the
holographic analogues of maximally efficient spacetime encodings.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ─── Plot 1: Feasible region in (K/N, D/N) plane ───

ax = axes[0]
N_vals = range(4, 21)
for n in N_vals:
    rates = []
    distances = []
    for k in range(0, n + 1):
        for d in range(1, n + 1):
            if n - k <= 2 * (d - 1):
                rates.append(k / n)
                distances.append(d / n)

    ax.scatter(rates, distances, s=3, alpha=0.15, c="steelblue")

# MDS boundary: K/N = 1 - 2(D/N - 1/N), i.e., rate = 1 - 2*rel_dist + 2/N
# In the limit: rate + 2*rel_dist ≤ 1 + 2/N
r_line = np.linspace(0, 1, 200)
d_line = (1 - r_line + 0.01) / 2  # approximate MDS boundary for large N
d_line = np.clip(d_line, 0, 1)
ax.plot(r_line, d_line, "r-", linewidth=2, label="Singleton limit (N→∞)")
ax.fill_between(r_line, d_line, 0, alpha=0.1, color="red", label="Forbidden region")

# Known quantum codes
known_codes = [
    (5, 1, 3, "[[5,1,3]]"),
    (7, 1, 3, "[[7,1,3]]"),
    (9, 1, 3, "[[9,1,3]]"),
    (4, 2, 2, "[[4,2,2]]"),
]
for n, k, d, label in known_codes:
    ax.plot(k/n, d/n, "ko", markersize=8, zorder=5)
    ax.annotate(label, (k/n, d/n), textcoords="offset points",
                xytext=(8, 5), fontsize=8, fontweight="bold")

ax.set_xlabel("Rate K/N (information density)", fontsize=11)
ax.set_ylabel("Relative distance D/N (error tolerance)", fontsize=11)
ax.set_title("Quantum Singleton Bound\nFeasible Code Parameters", fontsize=12, fontweight="bold")
ax.legend(loc="upper right", fontsize=9)
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 0.85)
ax.grid(True, alpha=0.3)

# ─── Plot 2: Entropy lower bound K ≥ N - 2(D-1) ───

ax2 = axes[1]
N = 15
d_vals = range(1, N + 1)

for d in [2, 3, 4, 5]:
    k_bounds = []
    n_vals = list(range(d, 20))
    for n in n_vals:
        lb = n - 2 * (d - 1)
        k_bounds.append(max(lb, 0))
    ax2.plot(n_vals, k_bounds, "o-", markersize=4, label=f"D = {d}")

ax2.fill_between(range(1, 20), 0, [n for n in range(1, 20)],
                  alpha=0.05, color="gray")
ax2.plot(range(1, 20), range(1, 20), "k--", alpha=0.3, label="K = N (trivial)")

ax2.set_xlabel("Physical qubits N (boundary area)", fontsize=11)
ax2.set_ylabel("Minimum logical qubits K (entropy)", fontsize=11)
ax2.set_title("Entropy Lower Bound from Singleton\nK ≥ N − 2(D−1)", fontsize=12, fontweight="bold")
ax2.legend(loc="upper left", fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 19)
ax2.set_ylim(-1, 19)

plt.tight_layout()
plt.savefig("viz_singleton_bound.png", dpi=150, bbox_inches="tight")
print("Saved: viz_singleton_bound.png")
