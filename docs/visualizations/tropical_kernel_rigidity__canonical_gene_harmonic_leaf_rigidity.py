"""
Visualization: Harmonic Leaf Rigidity and Value Propagation

Illustrates how harmonic functions on graphs are constrained by the
leaf rigidity theorem: on pendant (degree-1) vertices, harmonic function
values are forced to equal their unique neighbor's value.

This is the propagation engine that converts local structure (leaves)
into global constraints on tropical kernel generators.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def graph_laplacian(adj):
    n = adj.shape[0]
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = int(np.sum(adj[i]))
            elif adj[i, j]:
                L[i, j] = -1
    return L


# Create a graph with pendant vertices (leaves)
# Graph: a triangle (0-1-2) with leaves attached
#   3 -- 0 -- 1 -- 4
#             |
#             2
#             |
#             5

n = 6
adj = np.zeros((n, n), dtype=int)
edges = [(0, 1), (1, 2), (0, 2), (0, 3), (1, 4), (2, 5)]
for i, j in edges:
    adj[i, j] = adj[j, i] = 1

L = graph_laplacian(adj)

# Vertex positions for visualization
pos = {
    0: (1, 1),
    1: (2, 1),
    2: (1.5, 0),
    3: (0, 1.5),
    4: (3, 1.5),
    5: (1.5, -1),
}

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))
fig.suptitle('Harmonic Leaf Rigidity: Values Propagate from Core to Leaves',
             fontsize=13, fontweight='bold')

# === Panel 1: The graph structure ===
ax = axes[0]
ax.set_title('Graph Structure', fontsize=11)

# Draw edges
for i, j in edges:
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    edge_style = '-' if (i in [0,1,2] and j in [0,1,2]) else '--'
    color = '#333333' if (i in [0,1,2] and j in [0,1,2]) else '#999999'
    ax.plot(x, y, edge_style, color=color, linewidth=2, zorder=1)

# Draw vertices
for v in range(n):
    x, y = pos[v]
    is_leaf = int(np.sum(adj[v])) == 1
    color = '#FF6B6B' if is_leaf else '#4ECDC4'
    size = 600
    label = f'v{v}'
    if is_leaf:
        label += '\n(leaf)'
    ax.scatter(x, y, s=size, c=color, zorder=3, edgecolors='black', linewidth=2)
    ax.text(x, y, str(v), ha='center', va='center', fontsize=12, fontweight='bold', zorder=4)

legend_patches = [
    mpatches.Patch(color='#4ECDC4', label='Core vertices (cycle)'),
    mpatches.Patch(color='#FF6B6B', label='Leaf vertices (degree 1)'),
]
ax.legend(handles=legend_patches, loc='upper left', fontsize=8)
ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-1.5, 2)
ax.set_aspect('equal')
ax.axis('off')

# === Panel 2: Harmonic function values ===
ax = axes[1]
ax.set_title('S-Harmonic Function (S = all vertices)', fontsize=11)

# The only harmonic functions on a connected graph with all vertices in S
# are constants. Let's use S = {0, 1, 2} (cycle core only).
S = [0, 1, 2]

# A function harmonic on S = {0, 1, 2}
# At vertex 0: deg=3, neighbors 1, 2, 3
# L*f at 0: 3*f(0) - f(1) - f(2) - f(3) = 0
# At vertex 1: deg=3, neighbors 0, 2, 4
# L*f at 1: 3*f(1) - f(0) - f(2) - f(4) = 0
# At vertex 2: deg=3, neighbors 0, 1, 5
# L*f at 2: 3*f(2) - f(0) - f(1) - f(5) = 0

# Choose f(3) = f(0), f(4) = f(1), f(5) = f(2) and f constant on {0,1,2}
# Then constant f satisfies all three.
# For a nonconstant example: f(0)=2, f(1)=2, f(2)=2, f(3)=2, f(4)=2, f(5)=2
f_values = [2, 2, 2, 2, 2, 2]

for i, j in edges:
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    ax.plot(x, y, '-', color='#666666', linewidth=1.5, zorder=1)

for v in range(n):
    x, y = pos[v]
    is_leaf = int(np.sum(adj[v])) == 1
    color = '#FF6B6B' if is_leaf else '#4ECDC4'
    ax.scatter(x, y, s=700, c=color, zorder=3, edgecolors='black', linewidth=2)
    ax.text(x, y, f'f={f_values[v]}', ha='center', va='center',
            fontsize=10, fontweight='bold', zorder=4)

# Add arrows showing forced values
for leaf, neighbor in [(3, 0), (4, 1), (5, 2)]:
    lx, ly = pos[leaf]
    nx, ny = pos[neighbor]
    mx, my = (lx + nx) / 2, (ly + ny) / 2
    ax.annotate('forced!', xy=(mx, my), fontsize=8, color='red',
                ha='center', va='bottom', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.7))

ax.text(1.5, -1.4, 'Constant function: trivially harmonic', ha='center',
        fontsize=9, style='italic')
ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-1.5, 2)
ax.set_aspect('equal')
ax.axis('off')

# === Panel 3: Non-constant harmonic function ===
ax = axes[2]
ax.set_title('Leaf Rigidity Theorem', fontsize=11)

# Show that f(leaf) = f(neighbor) is forced
# Use a non-constant function on S = {0, 1, 2} only
# f(0) = a, f(1) = b, f(2) = c, f(3) = ?, f(4) = ?, f(5) = ?
# If f is S-harmonic:
# 3a - b - c - f(3) = 0 => f(3) = 3a - b - c
# 3b - a - c - f(4) = 0 => f(4) = 3b - a - c
# 3c - a - b - f(5) = 0 => f(5) = 3c - a - b
# Leaf rigidity says: f(3) = f(0) iff degree(3)=1 and only neighbor in S is 0
# But here vertex 3's only neighbor IS 0, and 3 has degree 1!
# So f(3) = f(0) = a. Then 3a - b - c = a => 2a = b + c.
# Similarly f(4) = f(1) = b => 2b = a + c.
# And f(5) = f(2) = c => 2c = a + b.
# These three: 2a = b+c, 2b = a+c, 2c = a+b => a = b = c.

# So on THIS graph, all S-harmonic functions are constant!
# That's the power of leaf rigidity.

# Show the deduction chain
steps = [
    "LEAF RIGIDITY THEOREM:",
    "",
    "If v is a leaf (deg = 1) in S,",
    "with unique neighbor w,",
    "then for any S-harmonic f:",
    "",
    "    f(v) = f(w)",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━",
    "",
    "On this graph:",
    "• v=3 is a leaf, neighbor w=0",
    "  → f(3) = f(0)  ✓",
    "• v=4 is a leaf, neighbor w=1",
    "  → f(4) = f(1)  ✓",
    "• v=5 is a leaf, neighbor w=2",
    "  → f(5) = f(2)  ✓",
    "",
    "Combined with harmonicity",
    "on the core triangle,",
    "this forces f = constant!",
    "",
    "Leaves propagate rigidity",
    "from the cycle core outward.",
]

text = '\n'.join(steps)
ax.text(0.5, 0.5, text, transform=ax.transAxes,
        fontsize=9, verticalalignment='center', horizontalalignment='center',
        fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
ax.axis('off')

plt.tight_layout()
plt.savefig('leaf_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved: leaf_rigidity.png")
