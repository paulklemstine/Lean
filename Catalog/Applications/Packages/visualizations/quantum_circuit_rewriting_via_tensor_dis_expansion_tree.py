#!/usr/bin/env python3
"""
Visualization 1: Distributive Expansion Tree

Visualizes how a quantum circuit expression expands into its sum-of-products
normal form through distributive rewriting. Shows the tree structure of the
original expression and the resulting flat list of monomials, with color-coded
paths through the computation.

This illustrates the core theorem: distributive expansion preserves semantics
while producing a canonical representation.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# ─── Left panel: Expression tree ───
ax1 = axes[0]
ax1.set_xlim(-3, 3)
ax1.set_ylim(-0.5, 5.5)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title('Expression Tree\n(H⊗I + I⊗H) ; (T⊗I + I⊗T)', fontsize=14, fontweight='bold')

# Draw tree nodes
def draw_node(ax, x, y, text, color='#2196F3', size=0.35):
    circle = plt.Circle((x, y), size, color=color, alpha=0.85, zorder=3)
    ax.add_patch(circle)
    ax.text(x, y, text, ha='center', va='center', fontsize=10,
            fontweight='bold', color='white', zorder=4)

def draw_edge(ax, x1, y1, x2, y2, color='#666', lw=2):
    ax.plot([x1, x2], [y1, y2], color=color, linewidth=lw, zorder=1)

# Tree: seq(add(H⊗I, I⊗H), add(T⊗I, I⊗T))
# Root: ;
draw_node(ax1, 0, 5, ';', '#FF5722', 0.4)

# Left child: +
draw_edge(ax1, 0, 5, -1.5, 3.5)
draw_node(ax1, -1.5, 3.5, '+', '#4CAF50', 0.4)

# Right child: +
draw_edge(ax1, 0, 5, 1.5, 3.5)
draw_node(ax1, 1.5, 3.5, '+', '#4CAF50', 0.4)

# Leaves of left +
draw_edge(ax1, -1.5, 3.5, -2.3, 2)
draw_node(ax1, -2.3, 2, 'H⊗I', '#2196F3', 0.45)
draw_edge(ax1, -1.5, 3.5, -0.7, 2)
draw_node(ax1, -0.7, 2, 'I⊗H', '#9C27B0', 0.45)

# Leaves of right +
draw_edge(ax1, 1.5, 3.5, 0.7, 2)
draw_node(ax1, 0.7, 2, 'T⊗I', '#FF9800', 0.45)
draw_edge(ax1, 1.5, 3.5, 2.3, 2)
draw_node(ax1, 2.3, 2, 'I⊗T', '#E91E63', 0.45)

# Legend
ax1.text(0, 0.3, 'Sequential composition distributes\nover addition (superposition)',
         ha='center', va='center', fontsize=11, style='italic', color='#555')

# ─── Right panel: Normal form (sum of products) ───
ax2 = axes[1]
ax2.set_xlim(-1, 5)
ax2.set_ylim(-0.5, 5.5)
ax2.axis('off')
ax2.set_title('Distributive Normal Form\n(Sum of Products)', fontsize=14, fontweight='bold')

monomials = [
    ('H⊗I · T⊗I', '#2196F3', '#FF9800'),
    ('H⊗I · I⊗T', '#2196F3', '#E91E63'),
    ('I⊗H · T⊗I', '#9C27B0', '#FF9800'),
    ('I⊗H · I⊗T', '#9C27B0', '#E91E63'),
]

y_positions = [4.5, 3.3, 2.1, 0.9]

for i, (label, c1, c2) in enumerate(monomials):
    y = y_positions[i]

    # Draw monomial box
    rect = mpatches.FancyBboxPatch((0.3, y-0.25), 3.4, 0.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor='#f5f5f5',
                                     edgecolor='#999', linewidth=1.5)
    ax2.add_patch(rect)

    # Draw colored gate indicators
    gate1 = plt.Circle((1.2, y), 0.18, color=c1, alpha=0.9, zorder=3)
    gate2 = plt.Circle((2.8, y), 0.18, color=c2, alpha=0.9, zorder=3)
    ax2.add_patch(gate1)
    ax2.add_patch(gate2)

    ax2.text(2.0, y, label, ha='center', va='center', fontsize=11,
             fontweight='bold', color='#333')

    if i < len(monomials) - 1:
        ax2.text(2.0, y - 0.55, '+', ha='center', va='center',
                fontsize=16, color='#4CAF50', fontweight='bold')

# Arrow from left to right
fig.patches.append(mpatches.FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    color='#FF5722', linewidth=3,
    connectionstyle='arc3,rad=0'))

fig.text(0.50, 0.53, 'expand', ha='center', va='bottom',
         fontsize=13, fontweight='bold', color='#FF5722',
         transform=fig.transFigure)

# Bottom annotation
fig.text(0.5, 0.02,
         'Quantum linearity is distributivity: each path through the superposition becomes a separate monomial',
         ha='center', va='bottom', fontsize=11, style='italic', color='#666',
         transform=fig.transFigure)

plt.tight_layout()
plt.savefig('viz_expansion_tree.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved viz_expansion_tree.png")
