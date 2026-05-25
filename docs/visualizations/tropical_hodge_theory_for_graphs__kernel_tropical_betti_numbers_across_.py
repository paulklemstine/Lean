#!/usr/bin/env python3
"""
Visualization 2: Tropical Betti Numbers Across Graph Families

Shows how the tropical first Betti number β₁ = |E| - |V| + 1 varies
across different graph families, illustrating the relationship between
graph structure and topological complexity.
"""

import matplotlib.pyplot as plt
import numpy as np

def cycle_rank(n, m, components=1):
    """β₁ = |E| - |V| + c"""
    return m - n + components

# Graph families
ns = list(range(3, 16))

# Path graphs: n-1 edges, β₁ = 0
path_beta = [0] * len(ns)

# Cycle graphs: n edges, β₁ = 1
cycle_beta = [1] * len(ns)

# Complete graphs: n(n-1)/2 edges, β₁ = n(n-1)/2 - n + 1
complete_beta = [n*(n-1)//2 - n + 1 for n in ns]

# Grid graphs (2 rows): 2n vertices, 3n-2 edges, β₁ = n-1
grid_beta = [n - 1 for n in ns]

# Petersen-like (3-regular): 3n/2 edges, β₁ = 3n/2 - n + 1 = n/2 + 1
regular3_beta = [3*n//2 - n + 1 if n % 2 == 0 else 0 for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Betti numbers
ax1.plot(ns, path_beta, 'o-', label='Path Pₙ (β₁=0)', linewidth=2, markersize=6)
ax1.plot(ns, cycle_beta, 's-', label='Cycle Cₙ (β₁=1)', linewidth=2, markersize=6)
ax1.plot(ns, grid_beta, '^-', label='2×n Grid (β₁=n-1)', linewidth=2, markersize=6)
ax1.plot(ns, complete_beta, 'D-', label='Complete Kₙ', linewidth=2, markersize=6)
ax1.set_xlabel('Number of vertices n', fontsize=12)
ax1.set_ylabel('Tropical Betti number β₁', fontsize=12)
ax1.set_title('Tropical β₁ Across Graph Families', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')
ax1.set_ylim(0.5, 200)

# Plot 2: Ratio β₁/|E| (redundancy ratio)
path_edges = [n-1 for n in ns]
cycle_edges = ns
complete_edges = [n*(n-1)//2 for n in ns]
grid_edges = [3*n-2 for n in ns]

ax2.plot(ns, [0/(n-1) for n in ns], 'o-', label='Path (0%)', linewidth=2, markersize=6)
ax2.plot(ns, [1/n for n in ns], 's-', label='Cycle', linewidth=2, markersize=6)
ax2.plot(ns, [(n-1)/(3*n-2) for n in ns], '^-', label='2×n Grid', linewidth=2, markersize=6)
ax2.plot(ns, [(n*(n-1)//2 - n + 1)/(n*(n-1)//2) for n in ns], 'D-',
         label='Complete Kₙ', linewidth=2, markersize=6)

ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel('Redundancy ratio β₁/|E|', fontsize=12)
ax2.set_title('Network Redundancy Across Families', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_betti_numbers.png', dpi=150, bbox_inches='tight')
print("Saved viz_betti_numbers.png")
