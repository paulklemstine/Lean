#!/usr/bin/env python3
"""
Visualization: Turán Graph Structure

Visualizes the Turán graph T(n,2) showing its bipartite structure
and the edge count approaching n²/4.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def turan_edge_count(n, r):
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if i % r != j % r:
                count += 1
    return count

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Edge count vs n²/4
ax1 = axes[0]
ns = range(2, 31)
actual = [turan_edge_count(n, 2) for n in ns]
formula = [n*n/4 for n in ns]
floor_formula = [n*n//4 for n in ns]

ax1.plot(list(ns), actual, 'bo-', markersize=5, label='T(n,2) edge count')
ax1.plot(list(ns), formula, 'r--', linewidth=2, label='n²/4 (continuous)')
ax1.plot(list(ns), floor_formula, 'g^', markersize=4, label='⌊n²/4⌋')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('Number of edges', fontsize=14)
ax1.set_title("Turán Graph T(n,2): Edge Count", fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Edge density approaching 1/2
ax2 = axes[1]
ns_large = range(2, 101)
densities = []
for n in ns_large:
    e = turan_edge_count(n, 2)
    max_edges = n * (n - 1) / 2
    densities.append(e / max_edges if max_edges > 0 else 0)

ax2.plot(list(ns_large), densities, 'b-', linewidth=2)
ax2.axhline(y=0.5, color='red', linestyle='--', linewidth=1.5, label='Density limit = 1/2')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('Edge density |E|/C(n,2)', fontsize=14)
ax2.set_title("Turán Graph Density → 1/2", fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.35, 0.55)

plt.tight_layout()
plt.savefig('turan_graph.png', dpi=150, bbox_inches='tight')
print("Saved turan_graph.png")
