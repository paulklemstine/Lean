#!/usr/bin/env python3
"""
Visualization 1: Tropical Morse Filtration

Visualizes the weight filtration process on two WL1-equivalent graphs
(C₆ vs 2×C₃), showing how the sublevel set evolves as the threshold
increases. The key insight: identical degree sequences but different
topological event sequences.

Output: A figure with two rows (one per graph) showing the sublevel
set at each critical threshold, with Betti numbers annotated.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True


def compute_tms(n, edges):
    events = []
    uf = UnionFind(n)
    sorted_edges = sorted(edges, key=lambda e: e[2])
    cycle_rank = 0
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(("merge", w, uf.num_components, cycle_rank))
        else:
            cycle_rank += 1
            events.append(("cycle_death", w, uf.num_components, cycle_rank))
    return events


# ──── Graph definitions ────

def get_c6():
    """C₆ with positions and edges."""
    n = 6
    angles = [np.pi/2 + 2*np.pi*i/6 for i in range(6)]
    pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}
    edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
    return n, pos, edges, "C₆ (6-cycle)"


def get_2tri():
    """2×C₃ with positions and edges."""
    n = 6
    # Triangle 1 on the left
    cx1, cy1 = -1.5, 0
    angles1 = [np.pi/2 + 2*np.pi*i/3 for i in range(3)]
    # Triangle 2 on the right
    cx2, cy2 = 1.5, 0
    angles2 = [np.pi/2 + 2*np.pi*i/3 for i in range(3)]

    pos = {}
    for i in range(3):
        pos[i] = (cx1 + 0.8*np.cos(angles1[i]), cy1 + 0.8*np.sin(angles1[i]))
        pos[i+3] = (cx2 + 0.8*np.cos(angles2[i]), cy2 + 0.8*np.sin(angles2[i]))

    edges = [
        (0, 1, 1.0), (1, 2, 3.0), (0, 2, 5.0),
        (3, 4, 2.0), (4, 5, 4.0), (3, 5, 6.0)
    ]
    return n, pos, edges, "2×C₃ (two triangles)"


# ──── Drawing ────

def draw_graph_at_threshold(ax, n, pos, edges, threshold, title=""):
    """Draw graph showing only edges with weight ≤ threshold."""
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=9)

    # Draw inactive edges (dashed, gray)
    for u, v, w in edges:
        if w > threshold:
            x = [pos[u][0], pos[v][0]]
            y = [pos[u][1], pos[v][1]]
            ax.plot(x, y, '--', color='lightgray', linewidth=1, zorder=1)

    # Draw active edges (solid, colored)
    for u, v, w in edges:
        if w <= threshold:
            x = [pos[u][0], pos[v][0]]
            y = [pos[u][1], pos[v][1]]
            ax.plot(x, y, '-', color='#2196F3', linewidth=2.5, zorder=2)
            # Weight label
            mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
            ax.text(mx, my+0.15, f'{w:.0f}', ha='center', fontsize=7, color='#1565C0')

    # Draw vertices
    for i in range(n):
        circle = plt.Circle(pos[i], 0.12, color='#FF5722', zorder=3)
        ax.add_patch(circle)
        ax.text(pos[i][0], pos[i][1], str(i), ha='center', va='center',
                fontsize=7, fontweight='bold', color='white', zorder=4)

    ax.axis('off')


# ──── Main visualization ────

fig, axes = plt.subplots(2, 7, figsize=(18, 6))
fig.suptitle("Tropical Morse Filtration: C₆ vs 2×C₃\n"
             "Both are 2-regular (1-WL equivalent), but TMS reveals different topology",
             fontsize=13, fontweight='bold')

graphs = [get_c6(), get_2tri()]
thresholds = [0, 1, 2, 3, 4, 5, 6]

for row, (n, pos, edges, name) in enumerate(graphs):
    events = compute_tms(n, edges)

    for col, t in enumerate(thresholds):
        ax = axes[row, col]

        # Compute Betti numbers at this threshold
        uf = UnionFind(n)
        n_edges_added = 0
        cycle_rank = 0
        for u, v, w in sorted(edges, key=lambda e: e[2]):
            if w <= t:
                if not uf.union(u, v):
                    cycle_rank += 1
                n_edges_added += 1

        beta0 = uf.num_components
        beta1 = cycle_rank

        title = f"t={t}"
        if col == 0:
            title = f"{name}\n{title}"
        title += f"\nβ₀={beta0}, β₁={beta1}"

        draw_graph_at_threshold(ax, n, pos, edges, t, title)

# Add event type legend at bottom
merge_patch = mpatches.Patch(color='#4CAF50', label='Merge (β₀ ↓)')
cycle_patch = mpatches.Patch(color='#F44336', label='Cycle Death (β₁ ↑)')
active_line = plt.Line2D([0], [0], color='#2196F3', linewidth=2.5, label='Active edge')
inactive_line = plt.Line2D([0], [0], color='lightgray', linewidth=1, linestyle='--', label='Inactive edge')

fig.legend(handles=[active_line, inactive_line], loc='lower center', ncol=4, fontsize=10)

plt.tight_layout(rect=[0, 0.05, 1, 0.92])
plt.savefig('vis_filtration.png', dpi=150, bbox_inches='tight')
print("Saved vis_filtration.png")
