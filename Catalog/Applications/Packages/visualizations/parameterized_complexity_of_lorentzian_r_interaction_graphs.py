"""
Visualization: Variable Interaction Graphs and Tree Decompositions

This script illustrates how the interaction structure of a polynomial
determines the complexity of Lorentzian recognition. Path-structured
polynomials (treewidth 1) have dramatically fewer Hessian checks
than densely-interacting polynomials.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb


def bounded_support_count_exact(n, d, k):
    if d == 0:
        return 1
    return sum(comb(n, j) * comb(d - 1, j - 1)
               for j in range(1, min(k, n) + 1) if d >= j)


def general_multiindex_count(n, d):
    return comb(n + d - 1, d)


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# --- Plot 1: Path interaction graph ---
ax = axes[0, 0]
n = 8
# Draw vertices in a line
positions = [(i * 1.2, 0) for i in range(n)]
for i, (x, y) in enumerate(positions):
    circle = plt.Circle((x, y), 0.3, color='#3498db', ec='#2c3e50', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y, f'x{i+1}', ha='center', va='center', fontsize=9,
            fontweight='bold', color='white')

# Draw edges (path)
for i in range(n - 1):
    ax.plot([positions[i][0] + 0.3, positions[i+1][0] - 0.3],
            [0, 0], 'k-', linewidth=2)

ax.set_xlim(-0.8, (n-1) * 1.2 + 0.8)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Path Interaction Graph (treewidth = 1)', fontsize=13,
             fontweight='bold')
ax.text((n-1)*0.6, -1.0,
        'Each monomial involves ≤ 2 adjacent variables\n'
        'Hessian checks: O(n · d) — polynomial',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1'))
ax.axis('off')

# --- Plot 2: Complete interaction graph ---
ax = axes[0, 1]
n_complete = 6
angle_offset = np.pi / 2
angles = [angle_offset + 2 * np.pi * i / n_complete for i in range(n_complete)]
positions_c = [(2 * np.cos(a), 2 * np.sin(a)) for a in angles]

# Draw edges (complete graph)
for i in range(n_complete):
    for j in range(i + 1, n_complete):
        ax.plot([positions_c[i][0], positions_c[j][0]],
                [positions_c[i][1], positions_c[j][1]],
                color='#e74c3c', linewidth=1, alpha=0.4)

# Draw vertices
for i, (x, y) in enumerate(positions_c):
    circle = plt.Circle((x, y), 0.35, color='#e74c3c', ec='#c0392b', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y, f'x{i+1}', ha='center', va='center', fontsize=9,
            fontweight='bold', color='white')

ax.set_xlim(-3.5, 3.5)
ax.set_ylim(-3.5, 3.5)
ax.set_aspect('equal')
ax.set_title(f'Complete Interaction Graph (treewidth = {n_complete-1})',
             fontsize=13, fontweight='bold')
ax.text(0, -3.0,
        'Every pair of variables interacts\n'
        'Hessian checks: O(n^d) — exponential',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#fadbd8'))
ax.axis('off')

# --- Plot 3: Tree decomposition visualization ---
ax = axes[1, 0]
# Show bags for the path decomposition
bag_colors = ['#1abc9c', '#16a085', '#2ecc71', '#27ae60',
              '#3498db', '#2980b9', '#9b59b6']

n_bags = 5
bag_width = 1.8
for i in range(n_bags):
    x = i * 2.2
    rect = mpatches.FancyBboxPatch((x - bag_width/2, -0.8), bag_width, 1.6,
                                     boxstyle="round,pad=0.1",
                                     facecolor=bag_colors[i % len(bag_colors)],
                                     edgecolor='#2c3e50', linewidth=2, alpha=0.7)
    ax.add_patch(rect)
    ax.text(x, 0, f'{{x{i+1}, x{i+2}}}', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')

    if i < n_bags - 1:
        ax.annotate('', xy=((i+1)*2.2 - bag_width/2, 0),
                    xytext=(i*2.2 + bag_width/2, 0),
                    arrowprops=dict(arrowstyle='->', lw=2, color='#2c3e50'))

ax.set_xlim(-1.5, n_bags * 2.2)
ax.set_ylim(-2, 2)
ax.set_title('Tree Decomposition (width = 1)', fontsize=13, fontweight='bold')
ax.text(n_bags * 1.1, -1.5,
        'Each bag has ≤ 2 variables\n'
        'Hessian factorizes along bags',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#d5f4e6'))
ax.axis('off')

# --- Plot 4: Complexity comparison bar chart ---
ax = axes[1, 1]
configs = [
    ('Path\n(tw=1)', 10, 8, 2),
    ('Cycle\n(tw=2)', 10, 8, 3),
    ('Grid\n(tw=3)', 10, 8, 4),
    ('Dense\n(tw=9)', 10, 8, 10),
]

labels = []
bounded_counts = []
general_counts_list = []

for label, n_val, d_val, k_val in configs:
    labels.append(label)
    bc = bounded_support_count_exact(n_val, d_val - 2, k_val)
    gc = general_multiindex_count(n_val, d_val - 2)
    bounded_counts.append(max(bc, 1))
    general_counts_list.append(gc)

x_pos = np.arange(len(labels))
width = 0.35

bars1 = ax.bar(x_pos - width/2, [np.log10(max(c, 1)) for c in bounded_counts],
               width, label='Bounded support', color='#2ecc71', edgecolor='#27ae60')
bars2 = ax.bar(x_pos + width/2, [np.log10(max(c, 1)) for c in general_counts_list],
               width, label='Unrestricted', color='#e74c3c', edgecolor='#c0392b')

ax.set_xlabel('Interaction Structure', fontsize=12)
ax.set_ylabel('log₁₀(leaf count)', fontsize=12)
ax.set_title(f'Complexity by Interaction Type (n={10}, d={8})',
             fontsize=13, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(labels, fontsize=10)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('interaction_graphs.png', dpi=150, bbox_inches='tight')
print("Saved interaction_graphs.png")
