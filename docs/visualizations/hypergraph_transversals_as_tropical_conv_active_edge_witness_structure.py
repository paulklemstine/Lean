#!/usr/bin/env python3
"""
Visualization: Active-Edge Witness Structure

This script visualizes the unique active witness property that forces
integrality in fractional transversals. It shows:
1. A hypergraph with active edges highlighted
2. The witness structure linking support vertices to isolating edges
3. A heatmap of edge-vertex incidence with active constraints marked
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ──────────────────────────────────────────────────────────────────────────────
# Example hypergraph with unique active witnesses
# ──────────────────────────────────────────────────────────────────────────────

# Vertices: 0,1,2,3,4
# Edges: e0={0,1}, e1={2,3}, e2={0,2,4}, e3={3,4}
# Assignment: x = (1, 0, 1, 0, 0) — integral with support {0, 2}
# Active edges for vertex 0: e0 (sum=1, only support vertex is 0)
# Active edges for vertex 2: e1... no. Let's redesign.

# Better example:
# Vertices: 0,1,2,3,4
# Edges: e0={0,1}, e1={1,2}, e2={2,3}, e3={3,4}, e4={4,0}
# x = (1, 0, 1, 0, 1) — support = {0, 2, 4}
# e0={0,1}: sum = 1+0 = 1, active, isolates 0 (only supp vertex)
# e2={2,3}: sum = 1+0 = 1, active, isolates 2
# e3={3,4}: sum = 0+1 = 1, active, isolates 4

vertices = [0, 1, 2, 3, 4]
edges = [
    frozenset({0, 1}),  # e0
    frozenset({1, 2}),  # e1
    frozenset({2, 3}),  # e2
    frozenset({3, 4}),  # e3
    frozenset({4, 0}),  # e4
]
edge_labels = ['e₀', 'e₁', 'e₂', 'e₃', 'e₄']
x_vals = {0: 1, 1: 0, 2: 1, 3: 0, 4: 1}
support_verts = {v for v, xv in x_vals.items() if xv != 0}

# Witness mapping
witnesses = {0: 0, 2: 2, 4: 3}  # vertex -> witness edge index

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Incidence heatmap with active constraints
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Edge-Vertex Incidence & Active Constraints", fontsize=12, fontweight='bold')

n_edges = len(edges)
n_verts = len(vertices)
incidence = np.zeros((n_edges, n_verts))
for i, e in enumerate(edges):
    for v in e:
        incidence[i, v] = x_vals[v]

# Custom colormap
cmap = plt.cm.Blues
im = ax.imshow(incidence, cmap=cmap, aspect='auto', vmin=0, vmax=1)

# Mark active edges
for i, e in enumerate(edges):
    edge_sum = sum(x_vals[v] for v in e)
    if edge_sum == 1:
        # Highlight active row
        for j in range(n_verts):
            if j in e:
                ax.add_patch(patches.Rectangle((j-0.5, i-0.5), 1, 1,
                             linewidth=3, edgecolor='red', facecolor='none'))

# Mark witness relationships
for v, ei in witnesses.items():
    ax.annotate('★', (v, ei), ha='center', va='center', fontsize=16,
                color='gold', fontweight='bold')

ax.set_xticks(range(n_verts))
ax.set_xticklabels([f'v{v}\nx={x_vals[v]}' for v in vertices], fontsize=9)
ax.set_yticks(range(n_edges))
ax.set_yticklabels([f'{el} = {set(e)}' for el, e in zip(edge_labels, edges)], fontsize=9)
ax.set_xlabel('Vertices (with assignment values)', fontsize=11)
ax.set_ylabel('Edges', fontsize=11)

# Legend
ax.text(0.5, -0.18, 'Red border = active constraint (Σ = 1)\n★ = unique witness edge',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

plt.colorbar(im, ax=ax, label='x(v) contribution', shrink=0.8)

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Witness structure diagram
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Witness Structure Forces Integrality", fontsize=12, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)

# Draw vertices in a circle
angles = np.linspace(0, 2*np.pi, n_verts, endpoint=False) - np.pi/2
vx = np.cos(angles)
vy = np.sin(angles)

# Draw edges as colored arcs/regions
edge_colors = ['#ffcccc', '#ccffcc', '#ccccff', '#ffffcc', '#ffccff']
for i, e in enumerate(edges):
    vs = sorted(e)
    # Draw edge as line between vertices
    for j in range(len(vs)):
        for k in range(j+1, len(vs)):
            v1, v2 = vs[j], vs[k]
            is_active = sum(x_vals[v] for v in e) == 1
            lw = 4 if is_active else 1
            color = 'red' if is_active else 'gray'
            alpha = 0.8 if is_active else 0.3
            ax.plot([vx[v1], vx[v2]], [vy[v1], vy[v2]], '-',
                    color=color, linewidth=lw, alpha=alpha, zorder=1)
            if is_active:
                mid_x = (vx[v1] + vx[v2]) / 2
                mid_y = (vy[v1] + vy[v2]) / 2
                # Offset label slightly
                offset = 0.15
                ax.text(mid_x + offset * np.cos(angles[vs[0]] + np.pi/4),
                       mid_y + offset * np.sin(angles[vs[0]] + np.pi/4),
                       edge_labels[i], fontsize=8, ha='center', color='red')

# Draw vertices
for v in vertices:
    in_support = v in support_verts
    color = '#2185a8' if in_support else '#e8f4f8'
    edgecolor = '#2185a8' if in_support else 'gray'
    size = 600 if in_support else 400
    ax.scatter(vx[v], vy[v], s=size, c=color, edgecolors=edgecolor,
              linewidth=2, zorder=3)
    ax.text(vx[v], vy[v], f'v{v}\n{x_vals[v]}', ha='center', va='center',
            fontsize=9, fontweight='bold' if in_support else 'normal',
            color='white' if in_support else 'gray', zorder=4)

# Draw witness arrows
for v, ei in witnesses.items():
    e = edges[ei]
    other = [u for u in e if u != v]
    if other:
        u = other[0]
        mid_x = (vx[v] + vx[u]) / 2
        mid_y = (vy[v] + vy[u]) / 2
        ax.annotate('', xy=(mid_x, mid_y),
                   xytext=(vx[v]*0.7, vy[v]*0.7),
                   arrowprops=dict(arrowstyle='->', color='gold', lw=2))

ax.text(0, -1.4, 'Blue = support vertex (x(v) = 1)\nRed edges = active (Σ = 1)\n'
        'Each support vertex isolated by its witness edge',
        ha='center', fontsize=9, style='italic')
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('witness_visualization.png', dpi=150, bbox_inches='tight')
print("Saved witness_visualization.png")
