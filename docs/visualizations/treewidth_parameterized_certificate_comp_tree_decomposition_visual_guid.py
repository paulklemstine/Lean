"""
Visualization: Tree Decomposition and Certificate Structure

Shows how a bounded-treewidth graph is decomposed into bags,
and how the deletion/contraction certificate tree branches
at each bag, illustrating the FPT bound visually.

Output: Saves to viz_tree_decomp.png via plt.savefig()
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def bell_number(n):
    if n == 0: return 1
    tri = [[0] * (n + 1) for _ in range(n + 1)]
    tri[0][0] = 1
    for i in range(1, n + 1):
        tri[i][0] = tri[i - 1][i - 1]
        for j in range(1, i + 1):
            tri[i][j] = tri[i][j - 1] + tri[i - 1][j - 1]
    return tri[n][0]


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Treewidth Certificate Compilation: Visual Guide',
             fontsize=16, fontweight='bold')

# ============================================================
# Plot 1: Example graph with tree decomposition bags
# ============================================================
ax1 = axes[0, 0]

# Draw a small graph with treewidth 2
# Vertices: 0,1,2,3,4
positions = {
    0: (0.2, 0.8), 1: (0.5, 0.9), 2: (0.8, 0.8),
    3: (0.3, 0.4), 4: (0.7, 0.4)
}
edges = [(0, 1), (1, 2), (0, 3), (1, 3), (2, 4), (1, 4), (3, 4)]

# Draw bags as colored regions
bags = [
    ({0, 1, 3}, 'lightblue', 'Bag 1'),
    ({1, 2, 4}, 'lightyellow', 'Bag 2'),
    ({1, 3, 4}, 'lightgreen', 'Bag 3'),
]

for bag_verts, color, label in bags:
    xs = [positions[v][0] for v in bag_verts]
    ys = [positions[v][1] for v in bag_verts]
    cx, cy = np.mean(xs), np.mean(ys)
    circle = plt.Circle((cx, cy), 0.22, fill=True, alpha=0.2,
                        facecolor=color, edgecolor='gray', linewidth=1.5)
    ax1.add_patch(circle)
    ax1.text(cx, cy - 0.25, label, ha='center', fontsize=8, style='italic')

# Draw edges
for u, v in edges:
    x1, y1 = positions[u]
    x2, y2 = positions[v]
    ax1.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.6)

# Draw vertices
for v, (x, y) in positions.items():
    ax1.plot(x, y, 'ko', markersize=15, zorder=5)
    ax1.text(x, y, str(v), ha='center', va='center',
            fontsize=10, color='white', fontweight='bold', zorder=6)

ax1.set_xlim(-0.05, 1.05)
ax1.set_ylim(0.05, 1.05)
ax1.set_title('Graph with Tree Decomposition (tw=2)', fontsize=12)
ax1.set_aspect('equal')
ax1.axis('off')

# ============================================================
# Plot 2: Certificate tree branching
# ============================================================
ax2 = axes[0, 1]

def draw_cert_tree(ax, x, y, depth, max_depth, width):
    """Draw a binary certificate tree."""
    if depth >= max_depth:
        ax.plot(x, y, 'gs', markersize=8, zorder=5)
        return

    # Draw node
    ax.plot(x, y, 'ro', markersize=10, zorder=5)

    # Draw children
    dx = width / (2 ** (depth + 1))
    dy = 0.15

    # Left child (delete)
    x_left = x - dx
    y_child = y - dy
    ax.plot([x, x_left], [y, y_child], 'b-', linewidth=1.5, alpha=0.7)
    ax.text((x + x_left) / 2 - 0.02, (y + y_child) / 2, 'D',
           fontsize=7, color='blue', ha='center')
    draw_cert_tree(ax, x_left, y_child, depth + 1, max_depth, width)

    # Right child (contract)
    x_right = x + dx
    ax.plot([x, x_right], [y, y_child], 'r-', linewidth=1.5, alpha=0.7)
    ax.text((x + x_right) / 2 + 0.02, (y + y_child) / 2, 'C',
           fontsize=7, color='red', ha='center')
    draw_cert_tree(ax, x_right, y_child, depth + 1, max_depth, width)

draw_cert_tree(ax2, 0.5, 0.95, 0, 4, 1.0)

ax2.set_xlim(-0.05, 1.05)
ax2.set_ylim(0.2, 1.05)
ax2.set_title('Certificate Tree (D=delete, C=contract)', fontsize=12)
ax2.axis('off')

# Legend
del_patch = mpatches.Patch(color='blue', alpha=0.5, label='Delete edge')
con_patch = mpatches.Patch(color='red', alpha=0.5, label='Contract edge')
leaf_patch = mpatches.Patch(color='green', alpha=0.5, label='Base case (leaf)')
ax2.legend(handles=[del_patch, con_patch, leaf_patch], loc='lower right', fontsize=9)

# ============================================================
# Plot 3: Active edges per bag
# ============================================================
ax3 = axes[1, 0]

ks = list(range(1, 11))
active = [k * (k + 1) // 2 for k in ks]
k_sq = [k ** 2 for k in ks]
k_sq_k = [k ** 2 + k for k in ks]

ax3.bar([k - 0.2 for k in ks], active, 0.2, label='k(k+1)/2 (active edges)',
        color='steelblue', alpha=0.8)
ax3.bar(ks, k_sq, 0.2, label='k² (tight bound)',
        color='orange', alpha=0.8)
ax3.bar([k + 0.2 for k in ks], k_sq_k, 0.2, label='k²+k (our exponent)',
        color='tomato', alpha=0.8)

ax3.set_xlabel('Treewidth k', fontsize=12)
ax3.set_ylabel('Exponent', fontsize=12)
ax3.set_title('Certificate Exponent: Active Edges ≤ k² ≤ k²+k', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')
ax3.set_xticks(ks)

# ============================================================
# Plot 4: Application domain comparison
# ============================================================
ax4 = axes[1, 1]

domains = ['Trees\n(VLSI paths)', 'Series-Parallel\n(VLSI circuits)',
           'Outerplanar\n(phylogenetics)', 'Treewidth 3\n(Halin graphs)',
           'Treewidth 5\n(sparse networks)']
tw = [1, 2, 2, 3, 5]
multipliers = [2 ** (k ** 2 + k) for k in tw]

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
bars = ax4.bar(range(len(domains)), [np.log2(m) for m in multipliers],
               color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)

# Add value labels
for bar, mult in zip(bars, multipliers):
    height = bar.get_height()
    if mult < 10000:
        label = f'{mult}'
    else:
        label = f'2^{int(np.log2(mult))}'
    ax4.text(bar.get_x() + bar.get_width() / 2., height + 0.3,
            label, ha='center', va='bottom', fontsize=10, fontweight='bold')

ax4.set_xticks(range(len(domains)))
ax4.set_xticklabels(domains, fontsize=9)
ax4.set_ylabel('log₂(multiplier per edge)', fontsize=12)
ax4.set_title('FPT Multiplier by Application Domain', fontsize=12)
ax4.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_tree_decomp.png', dpi=150, bbox_inches='tight')
print("Saved: viz_tree_decomp.png")
