"""
Visualization: Graph Laplacian and Harmonic Functions

Shows the Laplacian matrix structure, harmonic functions, and the
leaf rigidity phenomenon for various graph types.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def graph_laplacian(adj):
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# ── Row 1: Graph types and their Laplacians ──

# Path P5
adj_path = np.zeros((5, 5), dtype=int)
for i in range(4):
    adj_path[i, i+1] = adj_path[i+1, i] = 1

# Cycle C5
adj_cycle = np.zeros((5, 5), dtype=int)
for i in range(5):
    adj_cycle[i, (i+1) % 5] = adj_cycle[(i+1) % 5, i] = 1

# Star S4 (center at 0)
adj_star = np.zeros((5, 5), dtype=int)
for i in range(1, 5):
    adj_star[0, i] = adj_star[i, 0] = 1

for idx, (adj, name) in enumerate([(adj_path, "Path P₅"),
                                     (adj_cycle, "Cycle C₅"),
                                     (adj_star, "Star S₄")]):
    ax = axes[0, idx]
    L = graph_laplacian(adj)

    # Plot Laplacian as heatmap
    im = ax.imshow(L, cmap='RdBu_r', vmin=-2, vmax=4, aspect='equal')
    ax.set_title(f"{name}\nLaplacian", fontsize=12, fontweight='bold')

    # Annotate values
    for i in range(5):
        for j in range(5):
            color = 'white' if abs(L[i, j]) > 1 else 'black'
            ax.text(j, i, str(L[i, j]), ha='center', va='center',
                    fontsize=11, color=color, fontweight='bold')

    ax.set_xticks(range(5))
    ax.set_yticks(range(5))
    ax.set_xlabel("Column (vertex)")
    ax.set_ylabel("Row (vertex)")

# ── Row 2: Harmonic functions and leaf rigidity ──

# Panel 4: Harmonic function on path
ax = axes[1, 0]
ax.set_title("Harmonic Function on Path\n(Linear = Harmonic)", fontsize=12, fontweight='bold')

vertices = np.arange(5)
# On a path, linear functions are harmonic at interior vertices
f_harmonic = np.array([0, 1, 2, 3, 4])
f_not_harmonic = np.array([0, 1, 3, 2, 4])

ax.plot(vertices, f_harmonic, 'bo-', markersize=10, linewidth=2, label='Harmonic (linear)')
ax.plot(vertices, f_not_harmonic, 'r^--', markersize=8, linewidth=1.5, label='Not harmonic')
ax.set_xlabel("Vertex")
ax.set_ylabel("f(v)")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 5: Leaf rigidity
ax = axes[1, 1]
ax.set_title("Leaf Rigidity\nf(leaf) = f(neighbor)", fontsize=12, fontweight='bold')

# Tree with leaves
#     0
#    / \
#   1   2
#  /
# 3
tree_pos = {0: (1, 2), 1: (0, 1), 2: (2, 1), 3: (-0.5, 0)}
tree_edges = [(0, 1), (0, 2), (1, 3)]

for u, v in tree_edges:
    ax.plot([tree_pos[u][0], tree_pos[v][0]],
            [tree_pos[u][1], tree_pos[v][1]], 'k-', linewidth=2)

# Color vertices by function value
f_vals = [5, 5, 5, 5]  # All forced to be equal by leaf rigidity!
colors_map = {5: '#4CAF50'}

for v, (x, y) in tree_pos.items():
    color = '#4CAF50'
    ax.plot(x, y, 'o', markersize=25, color=color, zorder=5)
    ax.text(x, y, f'{f_vals[v]}', ha='center', va='center',
            fontsize=12, fontweight='bold', color='white', zorder=6)
    ax.text(x, y - 0.35, f'v{v}', ha='center', va='top', fontsize=9)

# Annotations
ax.annotate('leaf (deg 1)\nf(3) = f(1)', xy=tree_pos[3],
            xytext=(-1.5, -0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')
ax.annotate('leaf (deg 1)\nf(2) = f(0)', xy=tree_pos[2],
            xytext=(3, 0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

ax.set_xlim(-2, 3.5)
ax.set_ylim(-1, 3)
ax.axis('off')

# Panel 6: Matroidal invariance
ax = axes[1, 2]
ax.set_title("Matroidal Invariance\nSame Induced Structure → Same Kernel", fontsize=12, fontweight='bold')

# Two different graphs with same induced structure on S={0,1,2}
# Graph 1: 0-1-2 + extra vertex 3 connected to 2
# Graph 2: 0-1-2 + extra vertex 3 connected to 0

# Draw both
for gy_offset, label, extra_edge in [(1.5, "Graph G₁", (2, 3)),
                                       (-0.5, "Graph G₂", (0, 3))]:
    positions = {0: (0, gy_offset), 1: (1, gy_offset),
                 2: (2, gy_offset), 3: (3, gy_offset + 0.5)}

    # S = {0, 1, 2} edges
    for u, v in [(0, 1), (1, 2)]:
        ax.plot([positions[u][0], positions[v][0]],
                [positions[u][1], positions[v][1]], 'b-', linewidth=2.5)

    # Extra edge (outside S interaction)
    u, v = extra_edge
    ax.plot([positions[u][0], positions[v][0]],
            [positions[u][1], positions[v][1]], 'gray', linewidth=1.5, linestyle='--')

    # Vertices
    for vid, (x, y) in positions.items():
        color = '#2196F3' if vid < 3 else '#BDBDBD'
        ax.plot(x, y, 'o', markersize=18, color=color, zorder=5)
        ax.text(x, y, str(vid), ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)

    ax.text(-0.5, gy_offset, label, fontsize=10, fontweight='bold', va='center')

ax.text(1, 0.5, 'S = {0,1,2}: same adjacency\n→ same restricted Laplacian\n→ same harmonic kernel',
        fontsize=9, ha='center', va='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(-1, 4)
ax.set_ylim(-1.5, 3)
ax.axis('off')

plt.tight_layout()
plt.savefig('viz_laplacian_harmonics.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_harmonics.png")
