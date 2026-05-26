#!/usr/bin/env python3
"""
Visualization: Critical Pair Joinability Heatmap

Shows which pairs of rewrite rules can overlap (creating critical pairs)
and whether the critical pairs are joinable exactly or modulo AC.

This is a standalone script - no local imports.
"""

import matplotlib.pyplot as plt
import numpy as np

# Rule names
rules = ["R1\nmulVec\nvecAdd", "R2\nmatAdd\nmulVec", "R3\nsmulMat\nmulVec",
         "R4\nsmulVec\nvecAdd", "R5\nsmulMat\nmatAdd",
         "R6\ndot\nvecAdd_L", "R7\ndot\nvecAdd_R",
         "R8\ndot\nsmulVec", "R9\nscalMul\nscalAdd"]

n = len(rules)

# Root constructor of each rule's LHS
# R1: mulVec, R2: mulVec, R3: mulVec, R4: smulVec, R5: smulMat
# R6: dot, R7: dot, R8: dot, R9: scalMul
lhs_roots = ["mulVec", "mulVec", "mulVec", "smulVec", "smulMat",
             "dot", "dot", "dot", "scalMul"]

# Overlap matrix:
# 0 = impossible (different root constructors)
# 1 = same rule (trivially joinable)
# 2 = joinable exactly
# 3 = joinable modulo AC
# Only root-level overlaps considered
overlap = np.zeros((n, n), dtype=int)

for i in range(n):
    for j in range(n):
        if lhs_roots[i] != lhs_roots[j]:
            overlap[i][j] = 0  # Different roots, no overlap
        elif i == j:
            overlap[i][j] = 1  # Same rule
        else:
            overlap[i][j] = -1  # Potentially overlapping, check below

# Specific overlaps (from critical pair analysis):
# R1 & R2: mulVec (matAdd A B) (vecAdd v w) → joinable mod vecAdd AC
overlap[0][1] = overlap[1][0] = 3
# R1 & R3: mulVec (smulMat a A) (vecAdd v w) → joinable exactly
overlap[0][2] = overlap[2][0] = 2
# R2 & R3: mulVec first arg is matAdd vs smulMat → impossible
overlap[1][2] = overlap[2][1] = 0
# R6 & R7: dot (vecAdd v w) (vecAdd v' w') → joinable mod scalAdd AC
overlap[5][6] = overlap[6][5] = 3
# R6 & R8: dot first arg vecAdd vs smulVec → impossible
overlap[5][7] = overlap[7][5] = 0
# R7 & R8: dot (smulVec a v) (vecAdd v' w') → joinable exactly (via R9)
overlap[6][7] = overlap[7][6] = 2

# Create figure
fig, ax = plt.subplots(figsize=(10, 8))

# Color map: 0=gray (no overlap), 1=green (same rule), 2=blue (exact), 3=orange (mod AC)
colors = {0: '#E0E0E0', 1: '#4CAF50', 2: '#2196F3', 3: '#FF9800'}
cmap_data = np.zeros((n, n, 3))

for i in range(n):
    for j in range(n):
        hex_color = colors[overlap[i][j]]
        rgb = tuple(int(hex_color[k:k+2], 16)/255 for k in (1, 3, 5))
        cmap_data[i][j] = rgb

ax.imshow(cmap_data, aspect='equal')

# Add text labels
labels = {0: '✗', 1: '≡', 2: '✓', 3: 'AC'}
for i in range(n):
    for j in range(n):
        text = labels[overlap[i][j]]
        color = 'white' if overlap[i][j] in [1, 2] else 'black'
        ax.text(j, i, text, ha='center', va='center', fontsize=12,
                fontweight='bold', color=color)

ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels(rules, fontsize=8, ha='center')
ax.set_yticklabels(rules, fontsize=8)
ax.set_title('Critical Pair Overlap Matrix\n(9 Tensor Distributivity Rules)',
             fontsize=14, fontweight='bold')

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#E0E0E0', label='✗  No overlap (different roots)'),
    Patch(facecolor='#4CAF50', label='≡  Same rule (trivially joinable)'),
    Patch(facecolor='#2196F3', label='✓  Joinable exactly'),
    Patch(facecolor='#FF9800', label='AC Joinable modulo addition AC'),
]
ax.legend(handles=legend_elements, loc='upper center', bbox_to_anchor=(0.5, -0.08),
          ncol=2, fontsize=10)

plt.tight_layout()
plt.savefig('viz_critical_pairs.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_pairs.png")
