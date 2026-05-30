#!/usr/bin/env python3
"""
Visualization: Normalization as Tree Transformation

This script visualizes how distributive normalization transforms the
structure of a quantum tensor expression. The left panel shows the
original expression tree, and the right panel shows the normalized
(distributive normal form) tree.

The key visual insight: normalization pushes all Add nodes to the top
of the tree, creating a flat sum of add-free products.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ============================================================
# Self-contained expression types
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx
    def __repr__(self): return f"G{self.idx}"

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left};{self.right})"

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}⊗{self.right})"

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}+{self.right})"


def distribute_seq(a, b):
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def distribute_par(a, b):
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)

def normalize(e):
    if isinstance(e, Gate): return e
    if isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    if isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))
    if isinstance(e, Par): return distribute_par(normalize(e.left), normalize(e.right))


# ============================================================
# Tree layout computation
# ============================================================

def compute_layout(e, x=0, y=0, dx=1.0, depth=0):
    """Compute positions for tree nodes."""
    positions = []
    edges = []

    node_type = type(e).__name__
    if isinstance(e, Gate):
        label = f"G{e.idx}"
    elif isinstance(e, Seq):
        label = ";"
    elif isinstance(e, Par):
        label = "⊗"
    elif isinstance(e, Add):
        label = "+"

    positions.append((x, y, label, node_type))

    if not isinstance(e, Gate):
        child_dx = dx * 0.5
        # Left child
        lx, ly = x - dx, y - 1.2
        edges.append((x, y, lx, ly))
        lpos, ledges = compute_layout(e.left, lx, ly, child_dx, depth + 1)
        positions.extend(lpos)
        edges.extend(ledges)
        # Right child
        rx, ry = x + dx, y - 1.2
        edges.append((x, y, rx, ry))
        rpos, redges = compute_layout(e.right, rx, ry, child_dx, depth + 1)
        positions.extend(rpos)
        edges.extend(redges)

    return positions, edges


def draw_tree(ax, e, title, dx=2.5):
    """Draw an expression tree on the given axes."""
    positions, edges = compute_layout(e, x=0, y=0, dx=dx)

    # Draw edges
    for x1, y1, x2, y2 in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.6)

    # Draw nodes
    colors = {
        'Gate': '#4CAF50',  # green
        'Seq': '#2196F3',   # blue
        'Par': '#FF9800',   # orange
        'Add': '#F44336',   # red
    }

    for x, y, label, ntype in positions:
        color = colors.get(ntype, 'gray')
        circle = plt.Circle((x, y), 0.3, color=color, ec='black',
                            linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    # Compute bounds
    xs = [p[0] for p in positions]
    ys = [p[1] for p in positions]
    margin = 1
    ax.set_xlim(min(xs) - margin, max(xs) + margin)
    ax.set_ylim(min(ys) - margin, max(ys) + margin)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=10)
    ax.axis('off')


# ============================================================
# Build and visualize
# ============================================================

g0, g1, g2, g3 = Gate(0), Gate(1), Gate(2), Gate(3)

# Example: (G0 + G1) ; (G2 ⊗ G3)
# Demonstrates how seq distributes over add, creating
# (G0;(G2⊗G3)) + (G1;(G2⊗G3))
expr = Seq(Add(g0, g1), Par(g2, g3))
nf = normalize(expr)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

draw_tree(ax1, expr, f"Original: {expr}", dx=2.0)
draw_tree(ax2, nf, f"Normalized: {nf}", dx=2.5)

# Add arrow between panels
fig.patches.append(mpatches.FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    linewidth=3, color='purple', zorder=10
))
fig.text(0.50, 0.55, 'normalize', ha='center', va='bottom',
         fontsize=14, color='purple', fontweight='bold',
         transform=fig.transFigure)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Gate'),
    mpatches.Patch(facecolor='#2196F3', edgecolor='black', label='Seq (;)'),
    mpatches.Patch(facecolor='#FF9800', edgecolor='black', label='Par (⊗)'),
    mpatches.Patch(facecolor='#F44336', edgecolor='black', label='Add (+)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
           fontsize=12, frameon=True, fancybox=True)

fig.suptitle('Distributive Normalization: Add Nodes Rise to the Top',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('normalization_tree.png', dpi=150, bbox_inches='tight')
print("Saved normalization_tree.png")
