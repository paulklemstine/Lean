"""
Visualization: Operadic Composition as Tree Grafting

This script visualizes how operadic composition works by showing the process
of grafting inner operation trees into the leaves of an outer operation tree.
Uses matplotlib to draw the tree structures.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_node(ax, x, y, label, color='#2196F3', size=0.15):
    """Draw a circular node at (x, y) with a label."""
    circle = plt.Circle((x, y), size, color=color, ec='black', linewidth=1.5, zorder=3)
    ax.add_patch(circle)
    ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold',
            color='white', zorder=4)

def draw_edge(ax, x1, y1, x2, y2, color='black'):
    """Draw an edge between two nodes."""
    ax.plot([x1, x2], [y1, y2], color=color, linewidth=1.5, zorder=1)


def draw_outer_tree(ax):
    """Draw the outer operation tree: f(g₁, g₂)."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Outer Operation\nf(●₁, ●₂)', fontsize=12, fontweight='bold')

    # Root
    draw_node(ax, 0, 3, 'f', color='#1565C0', size=0.2)
    # Leaves (holes)
    draw_node(ax, -0.8, 1.5, '●₁', color='#FF9800', size=0.2)
    draw_node(ax, 0.8, 1.5, '●₂', color='#FF9800', size=0.2)
    # Edges
    draw_edge(ax, 0, 2.8, -0.8, 1.7)
    draw_edge(ax, 0, 2.8, 0.8, 1.7)


def draw_inner_trees(ax):
    """Draw the inner operation trees."""
    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Inner Operations\ng₁(a, b), g₂(c)', fontsize=12, fontweight='bold')

    # Tree 1: g₁(a, b)
    draw_node(ax, -1.5, 3, 'g₁', color='#4CAF50', size=0.2)
    draw_node(ax, -2.3, 1.5, 'a', color='#81C784', size=0.18)
    draw_node(ax, -0.7, 1.5, 'b', color='#81C784', size=0.18)
    draw_edge(ax, -1.5, 2.8, -2.3, 1.68)
    draw_edge(ax, -1.5, 2.8, -0.7, 1.68)

    # Tree 2: g₂(c)
    draw_node(ax, 1.5, 3, 'g₂', color='#9C27B0', size=0.2)
    draw_node(ax, 1.5, 1.5, 'c', color='#CE93D8', size=0.18)
    draw_edge(ax, 1.5, 2.8, 1.5, 1.68)


def draw_composed_tree(ax):
    """Draw the composed tree: f(g₁(a,b), g₂(c))."""
    ax.set_xlim(-3, 3)
    ax.set_ylim(-1, 5.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Operadic Composition\nf(g₁(a,b), g₂(c))', fontsize=12, fontweight='bold')

    # Root
    draw_node(ax, 0, 5, 'f', color='#1565C0', size=0.22)

    # g₁ subtree
    draw_node(ax, -1.5, 3.5, 'g₁', color='#4CAF50', size=0.2)
    draw_node(ax, -2.3, 2, 'a', color='#81C784', size=0.18)
    draw_node(ax, -0.7, 2, 'b', color='#81C784', size=0.18)
    draw_edge(ax, -1.5, 3.3, -2.3, 2.18)
    draw_edge(ax, -1.5, 3.3, -0.7, 2.18)

    # g₂ subtree
    draw_node(ax, 1.5, 3.5, 'g₂', color='#9C27B0', size=0.2)
    draw_node(ax, 1.5, 2, 'c', color='#CE93D8', size=0.18)
    draw_edge(ax, 1.5, 3.3, 1.5, 2.18)

    # Root edges
    draw_edge(ax, 0, 4.78, -1.5, 3.7)
    draw_edge(ax, 0, 4.78, 1.5, 3.7)

    # Annotation
    ax.annotate('', xy=(0, -0.3), xytext=(0, 0.5),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(0, -0.7, 'Result: 3 leaves (a, b, c)', ha='center',
            fontsize=10, color='red', style='italic')


# ============================================================================
# Create figure
# ============================================================================

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# Add arrows between subplots
draw_outer_tree(axes[0])
draw_inner_trees(axes[1])
draw_composed_tree(axes[2])

# Add connecting arrows
fig.text(0.35, 0.5, '⊗', fontsize=28, ha='center', va='center',
         color='#F44336', fontweight='bold')
fig.text(0.65, 0.5, '→', fontsize=28, ha='center', va='center',
         color='#F44336', fontweight='bold')

fig.suptitle('Operadic Composition = Tree Grafting', fontsize=16,
             fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('operad_composition.png', dpi=150, bbox_inches='tight')
print("Saved: operad_composition.png")
