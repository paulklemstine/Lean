#!/usr/bin/env python3
"""
Visualization 2: Confluence Diamond

Visualizes the confluence property of distributive rewriting: two different
rewrite paths from the same expression converge to the same normal form
(modulo reordering of summands).

This illustrates the central theorem: distributive normalization is confluent.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(-6, 6)
ax.set_ylim(-1, 11)
ax.axis('off')

def draw_box(ax, x, y, text, color='#2196F3', width=4.5, height=0.7, fontsize=10):
    rect = mpatches.FancyBboxPatch(
        (x - width/2, y - height/2), width, height,
        boxstyle="round,pad=0.15", facecolor=color, alpha=0.15,
        edgecolor=color, linewidth=2)
    ax.add_patch(rect)
    ax.text(x, y, text, ha='center', va='center', fontsize=fontsize,
            fontweight='bold', color=color)

def draw_arrow(ax, x1, y1, x2, y2, color='#666', label='', label_side='left'):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5,
                               connectionstyle='arc3,rad=0.1'))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        offset = -0.6 if label_side == 'left' else 0.6
        ax.text(mx + offset, my, label, ha='center', va='center',
                fontsize=9, color=color, style='italic')

# Title
ax.text(0, 10.5, 'Confluence of Distributive Rewriting',
        ha='center', va='center', fontsize=16, fontweight='bold', color='#333')
ax.text(0, 9.9, 'Two rewrite paths from the same source converge to AC-equivalent normal forms',
        ha='center', va='center', fontsize=11, color='#666', style='italic')

# Top: original expression
draw_box(ax, 0, 9, '(H⊗I + I⊗H) ; (T⊗I + I⊗T)', '#FF5722', width=5)

# Left path: distribute left first
draw_arrow(ax, -1.5, 8.6, -3, 7.5, '#2196F3', 'dist_left', 'left')
draw_box(ax, -3, 7, '(H⊗I;(T⊗I+I⊗T)) + (I⊗H;(T⊗I+I⊗T))', '#2196F3', width=5.5, fontsize=8)

draw_arrow(ax, -3, 6.6, -3, 5.5, '#2196F3', 'dist_right ×2', 'left')
draw_box(ax, -3, 5, '(H⊗I·T⊗I + H⊗I·I⊗T)\n+ (I⊗H·T⊗I + I⊗H·I⊗T)', '#2196F3', width=5, height=1.0, fontsize=9)

# Right path: distribute right first
draw_arrow(ax, 1.5, 8.6, 3, 7.5, '#4CAF50', 'dist_right', 'right')
draw_box(ax, 3, 7, '((H⊗I+I⊗H);T⊗I) + ((H⊗I+I⊗H);I⊗T)', '#4CAF50', width=5.5, fontsize=8)

draw_arrow(ax, 3, 6.6, 3, 5.5, '#4CAF50', 'dist_left ×2', 'right')
draw_box(ax, 3, 5, '(H⊗I·T⊗I + I⊗H·T⊗I)\n+ (H⊗I·I⊗T + I⊗H·I⊗T)', '#4CAF50', width=5, height=1.0, fontsize=9)

# Convergence arrows
draw_arrow(ax, -3, 4.4, -1, 3.2, '#FF9800', '', 'left')
draw_arrow(ax, 3, 4.4, 1, 3.2, '#FF9800', '', 'right')

# Normal form
draw_box(ax, 0, 2.8, 'Same multiset of monomials (mod AC)', '#FF9800', width=5.5, fontsize=10)

# The canonical form
ax.text(0, 1.8, '{ H⊗I·T⊗I ,  H⊗I·I⊗T ,  I⊗H·T⊗I ,  I⊗H·I⊗T }',
        ha='center', va='center', fontsize=12, fontweight='bold',
        color='#333',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF3E0',
                  edgecolor='#FF9800', linewidth=2))

# Bottom annotation
ax.text(0, 0.5, 'The order of summands may differ, but the multiset is identical.\n'
        'This is ParallelACEq: permutation equivalence of monomials.',
        ha='center', va='center', fontsize=10, color='#666', style='italic')

# Key insight box
key_box = mpatches.FancyBboxPatch(
    (-5, -0.8), 10, 0.9,
    boxstyle="round,pad=0.2", facecolor='#E8F5E9',
    edgecolor='#4CAF50', linewidth=2)
ax.add_patch(key_box)
ax.text(0, -0.35, 'Key Theorem: Distributive normalization is confluent modulo AC —\n'
        'every quantum expression has a unique canonical sum-of-products representation.',
        ha='center', va='center', fontsize=10, fontweight='bold', color='#2E7D32')

plt.tight_layout()
plt.savefig('viz_confluence.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved viz_confluence.png")
