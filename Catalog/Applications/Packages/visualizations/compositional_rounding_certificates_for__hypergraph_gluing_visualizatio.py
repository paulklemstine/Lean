"""
Visualization: Hypergraph Gluing and Compositional Rounding
============================================================

Visualizes a hypergraph decomposition with two regions sharing a boundary,
showing the fractional transversal values and threshold rounding result.
Uses matplotlib to produce a static heatmap/network diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection

# ---- Inline all needed functions ----

def solve_simple_fractional(vertices, edges):
    """Simple greedy fractional transversal (no scipy needed)."""
    values = {v: 0.0 for v in vertices}
    for e in edges:
        s = sum(values[v] for v in e)
        if s < 1.0:
            deficit = 1.0 - s
            per_vertex = deficit / len(e)
            for v in e:
                values[v] += per_vertex
    return values

def threshold_round(values, vertices, d):
    """Threshold rounding at 1/d."""
    if d <= 0:
        return set()
    threshold = 1.0 / d
    return {v for v in vertices if values.get(v, 0) >= threshold - 1e-9}

# ---- Create example hypergraph gluing ----

# Region 1 (left): vertices 0-7
V1 = set(range(8))
edges1 = [
    frozenset({0, 1, 2}),
    frozenset({1, 3, 4}),
    frozenset({4, 5, 6}),
    frozenset({5, 6, 7}),
]

# Region 2 (right): vertices 5-12
V2 = set(range(5, 13))
edges2 = [
    frozenset({5, 6, 7}),
    frozenset({7, 8, 9}),
    frozenset({9, 10, 11}),
    frozenset({10, 11, 12}),
]

boundary = V1 & V2  # {5, 6, 7}

# Solve fractional transversals
x1 = solve_simple_fractional(V1, edges1)
x2 = solve_simple_fractional(V2, edges2)

# Ensure boundary agreement (take max)
for v in boundary:
    val = max(x1.get(v, 0), x2.get(v, 0))
    x1[v] = val
    x2[v] = val

# Glue
x_glued = {}
for v in V1 | V2:
    if v in V1:
        x_glued[v] = x1[v]
    else:
        x_glued[v] = x2[v]

# Threshold rounding
d = 3  # max edge size
S = threshold_round(x_glued, V1 | V2, d)

# ---- Visualization ----

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Vertex positions (arranged in two rows)
positions = {}
for i, v in enumerate(sorted(V1 | V2)):
    if v < 5:
        positions[v] = (v * 1.5, 0)
    elif v < 8:
        positions[v] = (v * 1.5, 0)
    else:
        positions[v] = (v * 1.5, 0)

# Better layout: arc
all_verts = sorted(V1 | V2)
n = len(all_verts)
for i, v in enumerate(all_verts):
    angle = np.pi * (1 - i / (n - 1))
    positions[v] = (5 * np.cos(angle), 3 * np.sin(angle))

def draw_hypergraph(ax, vertices, edges, values, selected, title, boundary_set):
    """Draw a hypergraph with vertex colors based on fractional values."""
    ax.set_xlim(-6.5, 6.5)
    ax.set_ylim(-1.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')

    # Draw edges as colored convex hulls
    colors = plt.cm.Set3(np.linspace(0, 1, len(edges)))
    for i, e in enumerate(edges):
        pts = np.array([positions[v] for v in e])
        if len(pts) >= 3:
            from matplotlib.patches import Polygon
            # Sort by angle from centroid
            centroid = pts.mean(axis=0)
            angles = np.arctan2(pts[:, 1] - centroid[1], pts[:, 0] - centroid[0])
            order = np.argsort(angles)
            pts_sorted = pts[order]
            # Expand slightly
            expanded = centroid + 1.15 * (pts_sorted - centroid)
            poly = Polygon(expanded, alpha=0.15, facecolor=colors[i],
                          edgecolor=colors[i], linewidth=2)
            ax.add_patch(poly)
        elif len(pts) == 2:
            ax.plot(pts[:, 0], pts[:, 1], '-', color=colors[i],
                   linewidth=3, alpha=0.3)

    # Draw vertices
    for v in sorted(vertices):
        x, y = positions[v]
        val = values.get(v, 0)

        # Color based on value
        if v in boundary_set:
            edge_color = 'orange'
            lw = 3
        else:
            edge_color = 'black'
            lw = 1.5

        if v in selected:
            face_color = plt.cm.Reds(0.3 + 0.7 * val)
            marker_size = 500
        else:
            face_color = plt.cm.Blues(0.1 + 0.6 * val)
            marker_size = 350

        ax.scatter(x, y, s=marker_size, c=[face_color],
                  edgecolors=edge_color, linewidths=lw, zorder=5)
        ax.annotate(f'{v}\n({val:.2f})', (x, y),
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   zorder=6)

    ax.axis('off')

# Panel 1: H1 with x1
draw_hypergraph(axes[0], V1, edges1, x1, set(), 'Region 1 (H₁)', boundary)

# Panel 2: H2 with x2
draw_hypergraph(axes[1], V2, edges2, x2, set(), 'Region 2 (H₂)', boundary)

# Panel 3: Glued with threshold rounding
all_edges = list(set(edges1) | set(edges2))
draw_hypergraph(axes[2], V1 | V2, all_edges, x_glued, S,
               f'Composed (threshold 1/{d})', boundary)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='lightblue', edgecolor='black', label='Unselected vertex'),
    mpatches.Patch(facecolor='salmon', edgecolor='black', label='Selected (threshold)'),
    mpatches.Patch(facecolor='white', edgecolor='orange', linewidth=2, label='Boundary vertex'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=11,
          bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Compositional Rounding: Hypergraph Gluing',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gluing.png', dpi=150, bbox_inches='tight')
print("Saved viz_gluing.png")
