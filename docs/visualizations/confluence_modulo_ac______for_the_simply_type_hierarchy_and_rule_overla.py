#!/usr/bin/env python3
"""
Visualization: Type Hierarchy and Rule Stratification in STTC

Shows how the STTC type system stratifies reduction rules by type level,
preventing interference between β-reduction and distributivity.

Includes a heatmap showing which rule combinations can overlap.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# ============================================================================
# Left: Rule Overlap Matrix
# ============================================================================
ax = axes[0]

rules = [
    'smul_left\n_dist',
    'smul_right\n_dist',
    'vmul_right\n_dist',
    'dot_left\n_dist',
    'dot_right\n_dist',
    'smul\n_zero',
    'vmul\n_zero',
    'smul\n_szero',
    'β-reduce'
]

n = len(rules)
# 0 = impossible overlap, 1 = possible overlap (joinable), 2 = same rule
overlap = np.zeros((n, n))
np.fill_diagonal(overlap, 2)

# Possible overlaps between dist rules
overlap_pairs = [
    (0, 1),  # smul_left_dist + smul_right_dist
    (0, 5),  # smul_left_dist + smul_zero
    (1, 7),  # smul_right_dist + smul_szero
    (5, 7),  # smul_zero + smul_szero
    (3, 4),  # dot_left_dist + dot_right_dist
]

for i, j in overlap_pairs:
    overlap[i, j] = 1
    overlap[j, i] = 1

# β never overlaps with dist (type level separation!)
# Row/col 8 stays 0 (except diagonal)

cmap = plt.cm.colors.ListedColormap(['#E8F5E9', '#FFF9C4', '#C8E6C9'])
im = ax.imshow(overlap, cmap=cmap, aspect='equal')

ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels(rules, fontsize=7, rotation=45, ha='right')
ax.set_yticklabels(rules, fontsize=7)
ax.set_title('Rule Overlap Matrix\n(STTC Rewrite System)', fontsize=13, fontweight='bold')

# Add text annotations
for i in range(n):
    for j in range(n):
        if overlap[i, j] == 2:
            text = '='
            color = '#2E7D32'
        elif overlap[i, j] == 1:
            text = '✓'
            color = '#F57F17'
        else:
            text = '✗'
            color = '#C8E6C9'
        ax.text(j, i, text, ha='center', va='center', fontsize=10,
                fontweight='bold', color=color)

# Highlight the β row/column
for i in range(n-1):
    rect = mpatches.Rectangle((n-1.5, i-0.5), 1, 1,
                               linewidth=0, facecolor='#E3F2FD', alpha=0.5)
    ax.add_patch(rect)
    rect2 = mpatches.Rectangle((i-0.5, n-1.5), 1, 1,
                                linewidth=0, facecolor='#E3F2FD', alpha=0.5)
    ax.add_patch(rect2)

ax.text(n-1, -1.5, '← β never overlaps\n    with dist!',
        fontsize=9, color='#1565C0', fontweight='bold', ha='center')

# Legend
legend = [
    mpatches.Patch(facecolor='#C8E6C9', label='Same rule (trivial)'),
    mpatches.Patch(facecolor='#FFF9C4', label='Overlap (joinable mod AC)'),
    mpatches.Patch(facecolor='#E8F5E9', label='No overlap possible'),
    mpatches.Patch(facecolor='#E3F2FD', label='β column (type separation)'),
]
ax.legend(handles=legend, loc='upper left', fontsize=7, framealpha=0.9)

# ============================================================================
# Right: Type Stratification
# ============================================================================
ax2 = axes[1]
ax2.set_xlim(-1, 10)
ax2.set_ylim(-1, 8)
ax2.axis('off')
ax2.set_title('Type Stratification\n(Decreasing Diagram Labels)', fontsize=13, fontweight='bold')

# Draw levels with different widths
levels_data = [
    (0, 8, 'Level 0: Base Types', '#E3F2FD', '#1565C0',
     ['ℝ (scalar)', 'Vec n', 'Mat m×n'],
     ['• smul distributes over vadd', '• dot distributes over vadd',
      '• vmul distributes over vadd', '• Zero elimination rules']),
    (3.5, 5, 'Level 1: Simple Arrows', '#FFF3E0', '#E65100',
     ['ℝ → Vec n', 'Vec n → ℝ'],
     ['• β-reduction fires here', '• η-expansion applies']),
    (5.5, 3, 'Level 2+: Higher Order', '#F3E5F5', '#6A1B9A',
     ['(ℝ → Vec) → Vec'],
     ['• β-reduction only', '• No dist interaction']),
]

for y_base, width, title, bg, text_color, types, rules_list in levels_data:
    x_start = (9 - width) / 2
    rect = mpatches.FancyBboxPatch((x_start, y_base - 0.3), width, 1.8,
                                    boxstyle="round,pad=0.15",
                                    facecolor=bg, edgecolor=text_color,
                                    linewidth=2)
    ax2.add_patch(rect)
    ax2.text(x_start + 0.2, y_base + 1.2, title,
            fontsize=9, color=text_color, fontweight='bold')
    ax2.text(x_start + 0.3, y_base + 0.7, '  '.join(types),
            fontsize=8, color=text_color)
    for k, rule in enumerate(rules_list):
        ax2.text(x_start + 0.3, y_base + 0.3 - k*0.25, rule,
                fontsize=7, color=text_color, alpha=0.8)

# Key insight annotation
ax2.text(4.5, -0.5,
         'Key: β at level k creates dist-redexes at level 0 < k\n'
         '→ Decreasing diagram condition satisfied\n'
         '→ Confluence follows!',
         fontsize=9, ha='center', va='center',
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#FFEBEE',
                  edgecolor='#C62828', linewidth=2),
         color='#C62828', fontweight='bold')

plt.tight_layout()
plt.savefig('type_hierarchy.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved type_hierarchy.png")


if __name__ == "__main__":
    pass  # Figure is created at import time
