"""
Visualization: Conflict Graph of Uncovered Edges

Creates a visual representation of the conflict graph structure:
- Shows a hypergraph with its edges
- Highlights uncovered edges after threshold rounding
- Draws the conflict graph (edges sharing ≥ 2 vertices)
- Shows the greedy coloring of the conflict graph

Uses matplotlib for static visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
from math import cos, sin, pi


def draw_hypergraph_and_conflict():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Define a hypergraph
    n_vertices = 9
    edges = [
        {0, 1, 2}, {1, 2, 3}, {3, 4, 5},
        {5, 6, 7}, {6, 7, 8}, {0, 4, 8}
    ]
    edge_colors_base = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

    # Vertex positions on a circle
    angles = [2 * pi * i / n_vertices - pi/2 for i in range(n_vertices)]
    pos = {i: (1.5 * cos(a), 1.5 * sin(a)) for i, a in enumerate(angles)}

    # ── Panel 1: The hypergraph ──
    ax = axes[0]
    ax.set_title('Hypergraph H\n(3-uniform, 6 edges)', fontsize=13, fontweight='bold')

    for idx, e in enumerate(edges):
        verts = [pos[v] for v in sorted(e)]
        cx = np.mean([v[0] for v in verts])
        cy = np.mean([v[1] for v in verts])
        # Draw triangle
        triangle = plt.Polygon(verts, alpha=0.15, color=edge_colors_base[idx],
                               edgecolor=edge_colors_base[idx], linewidth=2)
        ax.add_patch(triangle)
        ax.text(cx, cy, f'e{idx}', fontsize=8, ha='center', va='center',
                color=edge_colors_base[idx], fontweight='bold')

    for v, (x, y) in pos.items():
        ax.plot(x, y, 'ko', markersize=10, zorder=5)
        ax.text(x + 0.15, y + 0.15, str(v), fontsize=10, fontweight='bold', zorder=6)

    ax.set_xlim(-2.2, 2.2)
    ax.set_ylim(-2.2, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 2: Threshold rounding ──
    ax = axes[1]
    ax.set_title('After Threshold Rounding\n(θ = 1/3, S₁ shown in green)', fontsize=13, fontweight='bold')

    # Simulate fractional values
    x_frac = {0: 0.4, 1: 0.35, 2: 0.1, 3: 0.15, 4: 0.5,
              5: 0.3, 6: 0.1, 7: 0.1, 8: 0.4}
    theta = 1/3
    S1 = {v for v, val in x_frac.items() if val >= theta}

    # Find uncovered edges
    uncovered = [i for i, e in enumerate(edges) if not (e & S1)]
    covered = [i for i, e in enumerate(edges) if (e & S1)]

    for idx, e in enumerate(edges):
        verts = [pos[v] for v in sorted(e)]
        color = '#ff6b6b' if idx in uncovered else '#c8e6c9'
        alpha = 0.3 if idx in uncovered else 0.15
        lw = 2.5 if idx in uncovered else 1
        triangle = plt.Polygon(verts, alpha=alpha, color=color,
                               edgecolor='#ff6b6b' if idx in uncovered else '#4caf50',
                               linewidth=lw, linestyle='--' if idx in uncovered else '-')
        ax.add_patch(triangle)

    for v, (x, y) in pos.items():
        color = '#4caf50' if v in S1 else '#bbb'
        size = 12 if v in S1 else 8
        ax.plot(x, y, 'o', color=color, markersize=size, zorder=5,
                markeredgecolor='black', markeredgewidth=1)
        label = f'{v}\nx={x_frac[v]:.2f}'
        ax.text(x + 0.2, y + 0.2, label, fontsize=7, zorder=6)

    ax.text(-2, -1.9, f'S₁ = {sorted(S1)}', fontsize=10, color='#4caf50', fontweight='bold')
    ax.text(-2, -2.1, f'Uncovered: {[f"e{i}" for i in uncovered]}',
            fontsize=9, color='#ff6b6b')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 3: Conflict graph with coloring ──
    ax = axes[2]
    ax.set_title('Conflict Graph on Uncovered Edges\n(colored by greedy algorithm)', fontsize=13, fontweight='bold')

    # Build conflict graph
    conflicts = []
    for i in range(len(edges)):
        for j in range(i+1, len(edges)):
            if len(edges[i] & edges[j]) >= 2:
                conflicts.append((i, j))

    # Position edges as nodes
    edge_pos = {}
    n_e = len(edges)
    for i in range(n_e):
        angle = 2 * pi * i / n_e - pi/2
        edge_pos[i] = (1.2 * cos(angle), 1.2 * sin(angle))

    # Greedy coloring
    adj = {i: set() for i in range(n_e)}
    for i, j in conflicts:
        adj[i].add(j)
        adj[j].add(i)

    coloring = {}
    color_palette = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    for v in range(n_e):
        used = {coloring[u] for u in adj[v] if u in coloring}
        c = 0
        while c in used:
            c += 1
        coloring[v] = c

    # Draw conflict edges
    for i, j in conflicts:
        x_vals = [edge_pos[i][0], edge_pos[j][0]]
        y_vals = [edge_pos[i][1], edge_pos[j][1]]
        ax.plot(x_vals, y_vals, 'k-', linewidth=1.5, alpha=0.4, zorder=1)
        # Label intersection
        inter = edges[i] & edges[j]
        mx = (x_vals[0] + x_vals[1]) / 2
        my = (y_vals[0] + y_vals[1]) / 2
        ax.text(mx, my, f'∩={sorted(inter)}', fontsize=6, ha='center',
                alpha=0.7, style='italic')

    # Draw edge nodes
    for i in range(n_e):
        x, y = edge_pos[i]
        c = coloring[i]
        ax.plot(x, y, 'o', color=color_palette[c % len(color_palette)],
                markersize=25, zorder=3, markeredgecolor='black', markeredgewidth=1.5)
        ax.text(x, y, f'e{i}', fontsize=9, ha='center', va='center',
                fontweight='bold', zorder=4)

    n_colors = max(coloring.values()) + 1
    max_deg = max(len(adj[v]) for v in range(n_e))
    ax.text(-1.8, -1.7, f'χ = {n_colors} colors', fontsize=11, fontweight='bold')
    ax.text(-1.8, -2.0, f'Δ = {max_deg} (max degree)', fontsize=10)
    ax.text(-1.8, -2.3, f'Bound: Δ+1 = {max_deg+1}', fontsize=10, color='#666')

    ax.set_xlim(-2.3, 2.3)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_conflict_graph.png', dpi=150, bbox_inches='tight')
    print("Saved viz_conflict_graph.png")


draw_hypergraph_and_conflict()
