"""
Visualization: Tropical Kernel System Complexity Scaling
========================================================

Plots the relationship between graph size (n), maximum degree (Δ),
and the total tropical linear system size. Demonstrates that the
system size is bounded by n·Δ, enabling polynomial-time algorithms.

This validates the structural prerequisite for the O(n³·Δ) conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def random_bounded_degree_graph(n, max_deg, seed=42):
    """Generate random graph with bounded degree, return edges and degrees."""
    rng = np.random.RandomState(seed)
    edges = []
    degrees = np.zeros(n, dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if degrees[i] < max_deg and degrees[j] < max_deg and rng.random() < 0.5:
                edges.append((i, j))
                degrees[i] += 1
                degrees[j] += 1
    return edges, degrees


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: System size vs n for different Δ
ax1 = axes[0]
deltas = [2, 3, 4, 5]
colors = ['#1565C0', '#2E7D32', '#EF6C00', '#C62828']

for delta, color in zip(deltas, colors):
    ns = range(5, 101, 5)
    system_sizes = []
    bounds = []
    for n in ns:
        _, degrees = random_bounded_degree_graph(n, delta, seed=n+delta)
        system_sizes.append(sum(degrees))
        bounds.append(n * delta)
    ax1.plot(ns, system_sizes, 'o-', color=color, markersize=4,
             label=f'Σdeg (Δ={delta})', alpha=0.8)
    ax1.plot(ns, bounds, '--', color=color, alpha=0.4,
             label=f'n·Δ (Δ={delta})')

ax1.set_xlabel('Number of vertices (n)', fontsize=11)
ax1.set_ylabel('System size (Σ degrees)', fontsize=11)
ax1.set_title('System Size ≤ n·Δ', fontsize=13)
ax1.legend(fontsize=8, ncol=2)
ax1.grid(alpha=0.3)

# Panel 2: Ratio Σdeg / (n·Δ) — always ≤ 1
ax2 = axes[1]
for delta, color in zip(deltas, colors):
    ns = range(5, 101, 5)
    ratios = []
    for n in ns:
        _, degrees = random_bounded_degree_graph(n, delta, seed=n+delta)
        ratio = sum(degrees) / (n * delta) if n * delta > 0 else 0
        ratios.append(ratio)
    ax2.plot(ns, ratios, 'o-', color=color, markersize=4,
             label=f'Δ={delta}', alpha=0.8)

ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, alpha=0.5,
            label='Upper bound')
ax2.set_xlabel('Number of vertices (n)', fontsize=11)
ax2.set_ylabel('Ratio Σdeg / (n·Δ)', fontsize=11)
ax2.set_title('Verified: Ratio ≤ 1', fontsize=13)
ax2.legend(fontsize=9)
ax2.set_ylim(0, 1.2)
ax2.grid(alpha=0.3)

# Panel 3: Cubic bound visualization
ax3 = axes[2]
ns = np.arange(2, 31)
delta = 3
system_per_pass = ns * delta
quadratic = ns * ns * delta
cubic = ns * ns * ns * delta

ax3.semilogy(ns, system_per_pass, 'b-', linewidth=2, label='n·Δ (one pass)')
ax3.semilogy(ns, quadratic, 'g-', linewidth=2, label='n²·Δ (n passes)')
ax3.semilogy(ns, cubic, 'r-', linewidth=2, label='n³·Δ (conjecture)')
ax3.fill_between(ns, system_per_pass, cubic, alpha=0.1, color='orange')

ax3.set_xlabel('Number of vertices (n)', fontsize=11)
ax3.set_ylabel('Operations (log scale)', fontsize=11)
ax3.set_title(f'Algorithm Complexity (Δ={delta})', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('viz_complexity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_complexity.png")
