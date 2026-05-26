#!/usr/bin/env python3
"""
Visualization: Tropical Filtration Heatmap for Grid Graphs.

Shows how the topology of a 5×5 grid graph changes as edges are added
in weight order. Each cell represents the β₁ (cycle rank) of the
subgraph induced by edges with weight ≤ t.

The heatmap reveals the "tropical landscape" — the pattern of cycle
births across the filtration, which determines code distance and
logical qubit count.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.nc = n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        self.nc -= 1
        return True


def main():
    n = 5  # 5×5 grid

    # Create grid edges with position-dependent weights
    # Weight = distance from center, creating an interesting filtration
    edges = []
    center_r, center_c = (n-1)/2, (n-1)/2

    for r in range(n):
        for c in range(n):
            if c + 1 < n:
                # Horizontal edge
                mid_r = r
                mid_c = c + 0.5
                dist = np.sqrt((mid_r - center_r)**2 + (mid_c - center_c)**2)
                edges.append((r*n+c, r*n+c+1, round(dist, 2)))
            if r + 1 < n:
                # Vertical edge
                mid_r = r + 0.5
                mid_c = c
                dist = np.sqrt((mid_r - center_r)**2 + (mid_c - center_c)**2)
                edges.append((r*n+c, (r+1)*n+c, round(dist, 2)))

    sorted_edges = sorted(edges, key=lambda e: e[2])

    # Compute filtration
    uf = UnionFind(n*n)
    thresholds = []
    beta1_values = []
    beta0_values = []
    cycle_count = 0

    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            cycle_count += 1
        thresholds.append(w)
        beta1_values.append(cycle_count)
        beta0_values.append(uf.nc)

    # Create figure
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Tropical Filtration of 5×5 Grid (center-distance weights)',
                 fontsize=13, fontweight='bold')

    # ── Panel 1: Edge weight heatmap ──
    ax = axes[0]
    # Create weight matrix for visualization
    weight_grid = np.full((2*n-1, 2*n-1), np.nan)

    # Place vertices
    for r in range(n):
        for c in range(n):
            weight_grid[2*r, 2*c] = 0  # vertices

    # Place edges
    for u, v, w in edges:
        r1, c1 = u // n, u % n
        r2, c2 = v // n, v % n
        er = r1 + r2
        ec = c1 + c2
        weight_grid[er, ec] = w

    im = ax.imshow(weight_grid, cmap='YlOrRd', interpolation='nearest')
    ax.set_title('Edge Weights\n(distance from center)')
    plt.colorbar(im, ax=ax, label='Weight')
    ax.set_xticks([])
    ax.set_yticks([])

    # ── Panel 2: β₁ growth ──
    ax = axes[1]
    ax.step(range(len(beta1_values)), beta1_values, where='post',
            color='#F44336', linewidth=2)
    ax.fill_between(range(len(beta1_values)), beta1_values,
                    step='post', alpha=0.15, color='#F44336')
    ax.set_xlabel('Edge addition step')
    ax.set_ylabel('β₁ (cycle rank)')
    ax.set_title('Cycle Rank Growth\n(logical qubit accumulation)')
    ax.grid(True, alpha=0.3)

    # Mark cycle events
    cycle_steps = []
    uf2 = UnionFind(n*n)
    for i, (u, v, w) in enumerate(sorted_edges):
        if not uf2.union(u, v):
            cycle_steps.append(i)
            ax.axvline(x=i, color='#F44336', alpha=0.2, linestyle='--')

    ax.annotate(f'β₁ = {beta1_values[-1]}',
               xy=(len(beta1_values)-1, beta1_values[-1]),
               fontsize=12, fontweight='bold', color='#F44336')

    # ── Panel 3: Component decay ──
    ax = axes[2]
    ax.step(range(len(beta0_values)), beta0_values, where='post',
            color='#2196F3', linewidth=2)
    ax.fill_between(range(len(beta0_values)), beta0_values,
                    step='post', alpha=0.15, color='#2196F3')
    ax.set_xlabel('Edge addition step')
    ax.set_ylabel('β₀ (components)')
    ax.set_title('Component Merging\n(connectivity buildup)')
    ax.grid(True, alpha=0.3)

    ax.annotate(f'β₀ = {beta0_values[-1]}',
               xy=(len(beta0_values)-1, beta0_values[-1]),
               fontsize=12, fontweight='bold', color='#2196F3')

    plt.tight_layout()
    plt.savefig('filtration_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved: filtration_heatmap.png")


if __name__ == "__main__":
    main()
