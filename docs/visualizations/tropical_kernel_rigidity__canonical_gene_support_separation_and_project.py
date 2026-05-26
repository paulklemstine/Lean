"""
Visualization: Support Separation and Tropical Kernel Generators

Illustrates the core mathematical concept: when generators of a tropical
kernel have pairwise disjoint supports, they are uniquely determined up
to tropical projective equivalence (permutation + constant shifts).

The heatmap shows generator values on vertices, with disjoint support
regions clearly visible as non-overlapping nonzero blocks.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Create a family of generators with disjoint supports
# Simulating a graph with 8 vertices and 3 generators
n_vertices = 8
n_generators = 3

# Generator 1: nonzero on vertices 0, 1, 2
g1 = np.array([3, 1, 2, 0, 0, 0, 0, 0])
# Generator 2: nonzero on vertices 3, 4
g2 = np.array([0, 0, 0, 4, 2, 0, 0, 0])
# Generator 3: nonzero on vertices 5, 6, 7
g3 = np.array([0, 0, 0, 0, 0, 1, 5, 3])

generators = np.array([g1, g2, g3])

# Shifted versions (tropically projectively equivalent)
g1_shifted = g1 + 2  # shift by constant 2
g2_shifted = g2 + (-1)  # shift by constant -1
g3_shifted = g3 + 3  # shift by constant 3

generators_shifted = np.array([g3_shifted, g1_shifted, g2_shifted])  # also permuted

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Tropical Kernel Generators: Support Separation & Projective Equivalence',
             fontsize=14, fontweight='bold')

# Plot 1: Original generators as heatmap
ax1 = axes[0, 0]
im1 = ax1.imshow(generators, cmap='YlOrRd', aspect='auto', vmin=-2, vmax=6)
ax1.set_title('Canonical Generators F', fontsize=12)
ax1.set_xlabel('Vertex')
ax1.set_ylabel('Generator index')
ax1.set_xticks(range(n_vertices))
ax1.set_yticks(range(n_generators))
ax1.set_yticklabels([f'g₁', f'g₂', f'g₃'])
for i in range(n_generators):
    for j in range(n_vertices):
        color = 'white' if generators[i, j] > 3 else 'black'
        ax1.text(j, i, str(generators[i, j]), ha='center', va='center',
                fontsize=11, color=color, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='Value')

# Highlight disjoint support regions
for region, color in [((0, 2), '#2196F3'), ((3, 4), '#4CAF50'), ((5, 7), '#FF9800')]:
    rect = mpatches.FancyBboxPatch((region[0] - 0.5, -0.5), region[1] - region[0] + 1, 3,
                                     boxstyle="round,pad=0.05", linewidth=2,
                                     edgecolor=color, facecolor='none', linestyle='--')
    ax1.add_patch(rect)

# Plot 2: Shifted generators (tropically equivalent)
ax2 = axes[0, 1]
im2 = ax2.imshow(generators_shifted, cmap='YlOrRd', aspect='auto', vmin=-2, vmax=9)
ax2.set_title('Alternative Generators G (equivalent!)', fontsize=12)
ax2.set_xlabel('Vertex')
ax2.set_ylabel('Generator index')
ax2.set_xticks(range(n_vertices))
ax2.set_yticks(range(n_generators))
ax2.set_yticklabels([f'g₃+3', f'g₁+2', f'g₂-1'])
for i in range(n_generators):
    for j in range(n_vertices):
        color = 'white' if generators_shifted[i, j] > 4 else 'black'
        ax2.text(j, i, str(generators_shifted[i, j]), ha='center', va='center',
                fontsize=11, color=color, fontweight='bold')
plt.colorbar(im2, ax=ax2, label='Value')

# Plot 3: Support diagram
ax3 = axes[1, 0]
support_matrix = np.zeros((n_generators, n_vertices))
for i, g in enumerate(generators):
    for j in range(n_vertices):
        if g[j] != 0:
            support_matrix[i, j] = i + 1

colors = ['#FFFFFF', '#2196F3', '#4CAF50', '#FF9800']
from matplotlib.colors import ListedColormap
cmap = ListedColormap(colors)
ax3.imshow(support_matrix, cmap=cmap, aspect='auto', vmin=0, vmax=3)
ax3.set_title('Support Regions (Pairwise Disjoint)', fontsize=12)
ax3.set_xlabel('Vertex')
ax3.set_ylabel('Generator')
ax3.set_xticks(range(n_vertices))
ax3.set_yticks(range(n_generators))
ax3.set_yticklabels([f'g₁', f'g₂', f'g₃'])
for i in range(n_generators):
    for j in range(n_vertices):
        if support_matrix[i, j] > 0:
            ax3.text(j, i, '■', ha='center', va='center', fontsize=16,
                    color=colors[int(support_matrix[i, j])])
        else:
            ax3.text(j, i, '·', ha='center', va='center', fontsize=14, color='gray')

legend_patches = [
    mpatches.Patch(color='#2196F3', label='Support of g₁'),
    mpatches.Patch(color='#4CAF50', label='Support of g₂'),
    mpatches.Patch(color='#FF9800', label='Support of g₃'),
]
ax3.legend(handles=legend_patches, loc='upper right', fontsize=8)

# Plot 4: The theorem statement
ax4 = axes[1, 1]
ax4.axis('off')
theorem_text = (
    "MAIN THEOREM\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "If generators have:\n"
    "  ✓ Pairwise disjoint supports\n"
    "  ✓ Nontrivial variation on each support\n\n"
    "Then every alternative minimal generating\n"
    "family G is obtained from F by:\n\n"
    "  G(σ(i), v) = F(i, v) + cᵢ\n\n"
    "for some permutation σ and constants c.\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "This is TROPICAL PROJECTIVE\n"
    "EQUIVALENCE — the canonical form\n"
    "for tropical kernel generators."
)
ax4.text(0.5, 0.5, theorem_text, transform=ax4.transAxes,
         fontsize=11, verticalalignment='center', horizontalalignment='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('support_separation.png', dpi=150, bbox_inches='tight')
print("Saved: support_separation.png")
