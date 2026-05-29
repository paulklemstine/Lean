#!/usr/bin/env python3
"""
Visualization: Complexity Space and Lexicographic vs Scalar Order

Illustrates the three-dimensional complexity space (length, depth, lemmaCount)
and shows how lexicographic ordering provides finer discrimination than
scalar score. Points with equal scalar score but different lex ordering
are highlighted — this is the separation theorem in action.
"""

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np


# ── Generate complexity points ──────────────────────────────────

# All complexity triples with score ≤ 8
points = []
for l in range(9):
    for d in range(9 - l):
        for lc in range(9 - l - d):
            points.append((l, d, lc))

points = np.array(points)
scores = points.sum(axis=1)

# ── Create figure ───────────────────────────────────────────────

fig = plt.figure(figsize=(16, 6))

# Panel 1: 3D scatter colored by score
ax1 = fig.add_subplot(121, projection='3d')
sc = ax1.scatter(points[:, 0], points[:, 1], points[:, 2],
                  c=scores, cmap='viridis', s=40, alpha=0.7,
                  edgecolors='black', linewidth=0.3)
plt.colorbar(sc, ax=ax1, label='Scalar Score', shrink=0.6)
ax1.set_xlabel('Length')
ax1.set_ylabel('Depth')
ax1.set_zlabel('Lemma Count')
ax1.set_title('Complexity Space\n(colored by scalar score)', fontsize=13,
              fontweight='bold')

# Highlight the separation pair
c1 = np.array([2, 0, 1])
c2 = np.array([1, 1, 1])
ax1.scatter(*c1, color='red', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax1.scatter(*c2, color='blue', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
# Draw arrow from c1 to c2
ax1.plot([c1[0], c2[0]], [c1[1], c2[1]], [c1[2], c2[2]],
         'r--', linewidth=2, alpha=0.8)
ax1.text(c1[0]+0.2, c1[1]-0.3, c1[2]+0.3, 'c₁=(2,0,1)\nscore=3',
         fontsize=8, color='red')
ax1.text(c2[0]-0.5, c2[1]+0.3, c2[2]+0.3, 'c₂=(1,1,1)\nscore=3',
         fontsize=8, color='blue')

# Panel 2: 2D projection showing iso-score lines
ax2 = fig.add_subplot(122)

# Plot iso-score curves
for s in range(1, 9):
    iso_points = points[scores == s]
    if len(iso_points) > 0:
        ax2.scatter(iso_points[:, 0], iso_points[:, 1],
                    s=30 + 5*s, alpha=0.5, label=f'score={s}' if s <= 5 else None)

# Highlight separation pair
ax2.scatter(2, 0, color='red', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax2.scatter(1, 1, color='blue', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax2.annotate('c₁=(2,0,1)', (2, 0), textcoords="offset points",
             xytext=(10, -15), fontsize=10, color='red', fontweight='bold')
ax2.annotate('c₂=(1,1,1)', (1, 1), textcoords="offset points",
             xytext=(10, 10), fontsize=10, color='blue', fontweight='bold')

# Draw arrow showing lex direction
ax2.annotate('', xy=(1, 1), xytext=(2, 0),
             arrowprops=dict(arrowstyle='->', color='purple', lw=2))
ax2.text(1.7, 0.7, 'Lex\ndescent', fontsize=9, color='purple',
         ha='center', fontweight='bold')

ax2.set_xlabel('Length', fontsize=13)
ax2.set_ylabel('Depth', fontsize=13)
ax2.set_title('Iso-Score Manifolds\n(same score, different lex order)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

# Add text box explaining the separation theorem
textstr = ('Separation Theorem:\n'
           'c₁ and c₂ have equal score (3)\n'
           'but c₂ <_lex c₁\n'
           '→ Lex order detects finer\n'
           '   simplification structure')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
ax2.text(0.02, 0.98, textstr, transform=ax2.transAxes, fontsize=9,
         verticalalignment='top', bbox=props)

plt.tight_layout()
plt.savefig('viz_complexity_space.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_space.png")
