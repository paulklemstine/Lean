"""
Visualization: Confluence and Unique Normal Forms

This script visualizes the concept of confluence in rewriting systems:
how different reduction paths from the same source converge to a unique
normal form. It shows a diamond-shaped confluence diagram.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_term_box(ax, x, y, text, color='#E3F2FD', border='#1565C0'):
    """Draw a term in a rounded box."""
    width = max(len(text) * 0.12, 0.8)
    height = 0.4
    rect = patches.FancyBboxPatch((x - width/2, y - height/2), width, height,
                                   boxstyle="round,pad=0.05",
                                   facecolor=color, edgecolor=border, linewidth=2)
    ax.add_patch(rect)
    ax.text(x, y, text, ha='center', va='center', fontsize=10, fontweight='bold')

def draw_arrow(ax, x1, y1, x2, y2, label='', color='#333333', style='-'):
    """Draw an arrow from (x1,y1) to (x2,y2) with optional label."""
    dx = x2 - x1
    dy = y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    # Shorten to avoid overlap with boxes
    shrink = 0.25
    ax.annotate('', xy=(x2 - shrink*dx/length, y2 - shrink*dy/length),
                xytext=(x1 + shrink*dx/length, y1 + shrink*dy/length),
                arrowprops=dict(arrowstyle='->', color=color, lw=2,
                               linestyle=style))
    if label:
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        offset = 0.15
        ax.text(mx + offset, my, label, fontsize=9, color=color, style='italic')


# ============================================================================
# Create figure with two panels
# ============================================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Confluent system (diamond)
ax1.set_xlim(-2.5, 2.5)
ax1.set_ylim(-1, 5)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title('Confluent System:\nUnique Normal Form', fontsize=14, fontweight='bold',
              color='#2E7D32')

# Source term
draw_term_box(ax1, 0, 4.5, '(λx.x)(f a)', color='#FFF3E0', border='#E65100')

# Two reductions
draw_term_box(ax1, -1.5, 3, 'f a', color='#E8F5E9', border='#2E7D32')
draw_term_box(ax1, 1.5, 3, '(λx.x)(f a)', color='#E3F2FD', border='#1565C0')

# Further reductions
draw_term_box(ax1, 1.5, 1.5, 'f a', color='#E8F5E9', border='#2E7D32')

# Normal form
draw_term_box(ax1, 0, 0, 'f a ✓', color='#C8E6C9', border='#1B5E20')

# Arrows
draw_arrow(ax1, 0, 4.3, -1.5, 3.2, 'β', '#E65100')
draw_arrow(ax1, 0, 4.3, 1.5, 3.2, '', '#1565C0')
draw_arrow(ax1, -1.5, 2.8, 0, 0.2, '', '#2E7D32', style='--')
draw_arrow(ax1, 1.5, 2.8, 1.5, 1.7, 'β', '#1565C0')
draw_arrow(ax1, 1.5, 1.3, 0, 0.2, '', '#2E7D32', style='--')

# Labels
ax1.text(-1.8, 3.7, 'Path 1', fontsize=10, color='#E65100', fontweight='bold')
ax1.text(1.7, 3.7, 'Path 2', fontsize=10, color='#1565C0', fontweight='bold')
ax1.text(0, -0.5, 'Both paths converge to\nthe same normal form',
         ha='center', fontsize=10, color='#1B5E20', style='italic')

# Panel 2: The general diamond property
ax2.set_xlim(-2.5, 2.5)
ax2.set_ylim(-1.5, 5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('The Diamond Property\n(Confluence)', fontsize=14, fontweight='bold',
              color='#1565C0')

# Nodes
draw_term_box(ax2, 0, 4.5, 't', color='#FFF3E0', border='#E65100')
draw_term_box(ax2, -1.5, 2.5, 'u₁', color='#E3F2FD', border='#1565C0')
draw_term_box(ax2, 1.5, 2.5, 'u₂', color='#F3E5F5', border='#7B1FA2')
draw_term_box(ax2, 0, 0.5, 'v', color='#C8E6C9', border='#1B5E20')

# Solid arrows (given)
draw_arrow(ax2, 0, 4.3, -1.5, 2.7, '', '#1565C0')
draw_arrow(ax2, 0, 4.3, 1.5, 2.7, '', '#7B1FA2')

# Dashed arrows (conclusion)
draw_arrow(ax2, -1.5, 2.3, 0, 0.7, '', '#1B5E20', style='--')
draw_arrow(ax2, 1.5, 2.3, 0, 0.7, '', '#1B5E20', style='--')

# Labels
ax2.text(-1.8, 3.5, 't →* u₁', fontsize=10, color='#1565C0')
ax2.text(1.8, 3.5, 't →* u₂', fontsize=10, color='#7B1FA2')
ax2.text(-1.8, 1.2, '∃v: u₁ →* v', fontsize=10, color='#1B5E20')
ax2.text(1.2, 1.2, 'u₂ →* v', fontsize=10, color='#1B5E20')

# Theorem statement
ax2.text(0, -1, 'Theorem: If R is confluent and\nnf₁, nf₂ are normal forms of t,\nthen nf₁ = nf₂',
         ha='center', fontsize=11, color='#333', style='italic',
         bbox=dict(boxstyle='round', facecolor='#FFFDE7', edgecolor='#F9A825'))

plt.tight_layout()
plt.savefig('confluence_diamond.png', dpi=150, bbox_inches='tight')
print("Saved: confluence_diamond.png")
