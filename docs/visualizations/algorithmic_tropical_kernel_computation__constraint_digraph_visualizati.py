"""
Visualization 2: Constraint Digraph from Tropical Balance

Visualizes the difference-constraint system derived from a tropical kernel
element on a cycle graph. Shows the original graph alongside the induced
constraint digraph, illustrating the bridge from tropical harmonicity to
classical shortest-path optimization (Theorem 5).

Each arrow in the constraint digraph represents a difference inequality
φ(tgt) - φ(src) ≤ bound, derived from the minimizer at each vertex.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product as iproduct


def wnv(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced_at(adj, w_dict, phi, v):
    nbrs = adj[v]
    if len(nbrs) < 2:
        return False
    values = [(wnv(w_dict, phi, v, j), j) for j in nbrs]
    min_val = min(val for val, _ in values)
    return sum(1 for val, _ in values if val == min_val) >= 2


def get_minimizer(adj, w_dict, phi, u):
    nbrs = adj[u]
    return min(nbrs, key=lambda j: wnv(w_dict, phi, u, j))


# Build C5 with specific weights
n = 5
adj = {i: [(i - 1) % n, (i + 1) % n] for i in range(n)}
weights = [2, 2, 2, 2, 2]
w_dict = {}
for i in range(n):
    j = (i + 1) % n
    w_dict[(i, j)] = w_dict[(j, i)] = weights[i]

phi = {v: 0 for v in range(n)}

# Vertex positions (regular pentagon)
angles = [np.pi / 2 + 2 * np.pi * k / n for k in range(n)]
pos = {v: (np.cos(angles[v]), np.sin(angles[v])) for v in range(n)}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Original graph
ax1 = axes[0]
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Original Weighted Graph (C₅)', fontsize=14)

for i in range(n):
    j = (i + 1) % n
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    ax1.plot(x, y, 'b-', linewidth=2)
    mx, my = (x[0] + x[1]) / 2, (y[0] + y[1]) / 2
    # Offset label slightly outward
    cx, cy = np.mean([p[0] for p in pos.values()]), np.mean([p[1] for p in pos.values()])
    dx, dy = mx - cx, my - cy
    norm = np.sqrt(dx**2 + dy**2) + 1e-9
    ax1.text(mx + 0.15 * dx / norm, my + 0.15 * dy / norm,
             str(weights[i]), fontsize=12, ha='center', va='center',
             bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

for v in range(n):
    balanced = is_balanced_at(adj, w_dict, phi, v)
    color = 'green' if balanced else 'red'
    ax1.plot(*pos[v], 'o', markersize=25, color=color, zorder=5)
    ax1.text(*pos[v], str(v), fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)
    ax1.text(pos[v][0], pos[v][1] - 0.25, f'φ={phi[v]}',
             fontsize=10, ha='center', va='top')

ax1.axis('off')

# Right: Constraint digraph
ax2 = axes[1]
ax2.set_xlim(-1.8, 1.8)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Induced Constraint Digraph', fontsize=14)

# Draw constraints as directed edges
constraint_edges = []
for u in range(n):
    j = get_minimizer(adj, w_dict, phi, u)
    for v in adj[u]:
        bound = w_dict[(u, v)] - w_dict[(u, j)]
        constraint_edges.append((v, j, bound, u))

# Draw nodes
for v in range(n):
    ax2.plot(*pos[v], 'o', markersize=25, color='steelblue', zorder=5)
    ax2.text(*pos[v], str(v), fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)

# Draw constraint arrows
colors = plt.cm.Set1(np.linspace(0, 1, n))
drawn = set()
for src, tgt, bound, origin in constraint_edges:
    if src == tgt:
        continue
    key = (src, tgt)
    if key in drawn:
        continue
    drawn.add(key)

    x1, y1 = pos[src]
    x2, y2 = pos[tgt]

    # Shorten arrows to not overlap nodes
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    shrink = 0.18
    sx, sy = x1 + shrink * dx / length, y1 + shrink * dy / length
    ex, ey = x2 - shrink * dx / length, y2 - shrink * dy / length

    ax2.annotate('', xy=(ex, ey), xytext=(sx, sy),
                 arrowprops=dict(arrowstyle='->', color=colors[origin],
                                linewidth=1.5, shrinkA=0, shrinkB=0))

    mx, my = (sx + ex) / 2, (sy + ey) / 2
    # Perpendicular offset
    px, py = -dy / length * 0.12, dx / length * 0.12
    ax2.text(mx + px, my + py, f'≤{bound}',
             fontsize=9, ha='center', va='center',
             bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.9))

ax2.axis('off')

plt.suptitle('Tropical Balance → Difference Constraints (Theorem 5)',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('constraint_digraph.png', dpi=150)
print("Saved: constraint_digraph.png")
