#!/usr/bin/env python3
"""
Visualization: Constructibility of the Tropical Kernel Sheaf

Shows the active subgraph evolving through the filtration, with the
constructibility property highlighted: between critical values, the
active subgraph (and all its invariants) remain constant.

Produces a multi-panel figure showing the active subgraph at each
critical threshold and in between.

This visualizes: activeVerts_eq_of_sameCritGap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)


n = 6
edges = path_graph_edges(n)
filt = list(range(n))

# Create figure: show active graph at t = -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, ...
thresholds = [-0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
crit_set = set(filt)

fig, axes = plt.subplots(3, 4, figsize=(16, 10))

for idx, t in enumerate(thresholds):
    row, col = idx // 4, idx % 4
    ax = axes[row][col]

    is_critical = t in crit_set
    is_between = not is_critical and t > -1

    # Active vertices
    active = [v for v, fv in enumerate(filt) if fv <= t]
    active_set = set(active)

    # Draw all vertices
    positions = {v: (v * 1.5, 0) for v in range(n)}
    for v in range(n):
        x, y = positions[v]
        if v in active_set:
            ax.plot(x, y, 'o', markersize=20, color='#2c3e50', zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                   color='white', fontsize=10, fontweight='bold', zorder=6)
        else:
            ax.plot(x, y, 'o', markersize=20, color='#bdc3c7', zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                   color='#7f8c8d', fontsize=10, zorder=6)

    # Draw edges
    for (a, b) in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        if a in active_set and b in active_set:
            ax.plot([xa, xb], [ya, yb], '-', color='#2c3e50', linewidth=2.5, zorder=3)
        else:
            ax.plot([xa, xb], [ya, yb], '-', color='#ecf0f1', linewidth=1.5, zorder=2)

    # Profile value
    profile = sum(degree(n, edges, v) + 1 for v in active)

    # Styling
    if is_critical:
        ax.set_facecolor('#ffeaa7')
        title_color = '#e74c3c'
        label = f't = {t:.0f} (CRITICAL)'
    elif is_between:
        ax.set_facecolor('#dfe6e9')
        title_color = '#27ae60'
        label = f't = {t:.1f} (between)'
    else:
        ax.set_facecolor('#f5f6fa')
        title_color = '#636e72'
        label = f't = {t:.1f}'

    ax.set_title(label, fontsize=10, fontweight='bold', color=title_color)
    ax.text(0.02, 0.95, f'Profile = {profile}', transform=ax.transAxes,
           fontsize=9, verticalalignment='top',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    ax.set_xlim(-1, (n-1)*1.5 + 1)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

fig.suptitle('Constructibility: Active Subgraph is Constant Between Critical Values\n'
            '(Yellow = critical threshold, Gray = between critical values)',
            fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_constructibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_constructibility.png")
