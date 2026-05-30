#!/usr/bin/env python3
"""
Visualization: Rewrite Semilattice Structure

Visualizes how a confluent terminating rewrite system partitions
terms into equivalence classes, each with a unique normal form.
The normal form map acts as a projection/retraction onto the
set of irreducible elements.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# === Panel 1: Rewrite Graph with Equivalence Classes ===
ax = axes[0]
ax.set_xlim(-0.5, 6.5)
ax.set_ylim(-0.5, 5.5)
ax.set_title('Rewrite Graph & Equivalence Classes', fontsize=14, fontweight='bold')

# Define nodes and edges for a sample rewrite system
# Three equivalence classes converging to different normal forms
classes = {
    'Class A (nf = a)': {
        'nodes': [(1, 4.5, 'a·b·b⁻¹'), (0.5, 3, 'a·e'), (1.5, 3, 'e·a'), (1, 1.5, 'a')],
        'edges': [(0, 3), (1, 3), (2, 3)],
        'color': '#FF6B6B',
        'bg': '#FFE0E0'
    },
    'Class B (nf = b)': {
        'nodes': [(4, 4.5, 'b·a·a⁻¹'), (3.5, 3, 'b·e'), (4.5, 3, 'e·b'), (4, 1.5, 'b')],
        'edges': [(0, 3), (1, 3), (2, 3)],
        'color': '#4ECDC4',
        'bg': '#D0F0ED'
    },
    'Class C (nf = e)': {
        'nodes': [(2.5, 5, 'a·a⁻¹'), (2.5, 3.5, 'e·e'), (2.5, 2, 'e')],
        'edges': [(0, 2), (1, 2)],
        'color': '#45B7D1',
        'bg': '#D0E8F0'
    }
}

for cls_name, cls_data in classes.items():
    nodes = cls_data['nodes']
    edges = cls_data['edges']
    color = cls_data['color']
    bg = cls_data['bg']

    # Draw background ellipse for the class
    xs = [n[0] for n in nodes]
    ys = [n[1] for n in nodes]
    cx, cy = np.mean(xs), np.mean(ys)
    rx = max(0.8, (max(xs) - min(xs)) / 2 + 0.6)
    ry = max(1.0, (max(ys) - min(ys)) / 2 + 0.5)
    ellipse = plt.matplotlib.patches.Ellipse((cx, cy), 2*rx, 2*ry,
                                               alpha=0.2, color=bg,
                                               edgecolor=color, linewidth=2)
    ax.add_patch(ellipse)

    # Draw edges (rewrite steps)
    for src, tgt in edges:
        sx, sy = nodes[src][0], nodes[src][1]
        tx, ty = nodes[tgt][0], nodes[tgt][1]
        ax.annotate('', xy=(tx, ty + 0.2), xytext=(sx, sy - 0.2),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

    # Draw nodes
    for x, y, label in nodes:
        is_nf = (nodes.index((x, y, label)) == len(nodes) - 1)
        marker_size = 12 if is_nf else 8
        edge_width = 3 if is_nf else 1
        ax.plot(x, y, 'o', color=color, markersize=marker_size,
                markeredgecolor='black', markeredgewidth=edge_width)
        offset = 0.3 if not is_nf else -0.35
        ax.text(x, y + offset, label, fontsize=8, ha='center',
                fontweight='bold' if is_nf else 'normal')

# Legend
ax.text(0, 0.5, '● = reducible term', fontsize=9)
ax.text(0, 0, '⬤ = normal form (bold border)', fontsize=9)
ax.text(0, -0.4, '→ = rewrite step', fontsize=9)
ax.axis('off')

# === Panel 2: Normal Form Map as Projection ===
ax = axes[1]
ax.set_xlim(-1, 7)
ax.set_ylim(-1, 6)
ax.set_title('Normal Form Map (Algebraic Projection)', fontsize=14, fontweight='bold')

# Upper level: all terms
upper_y = 4.5
terms = [
    (0.5, upper_y, 'a·e', '#FF6B6B'),
    (1.5, upper_y, 'e·a', '#FF6B6B'),
    (2.5, upper_y, 'a·a⁻¹', '#45B7D1'),
    (3.5, upper_y, 'b·e', '#4ECDC4'),
    (4.5, upper_y, 'e·b', '#4ECDC4'),
    (5.5, upper_y, 'e·e', '#45B7D1'),
]

# Lower level: normal forms
lower_y = 1.5
nfs = [
    (1, lower_y, 'a', '#FF6B6B'),
    (3, lower_y, 'e', '#45B7D1'),
    (5, lower_y, 'b', '#4ECDC4'),
]

# Draw terms
for x, y, label, color in terms:
    ax.plot(x, y, 'o', color=color, markersize=10, markeredgecolor='gray')
    ax.text(x, y + 0.35, label, fontsize=9, ha='center')

# Draw NFs
for x, y, label, color in nfs:
    ax.plot(x, y, 's', color=color, markersize=14, markeredgecolor='black',
            markeredgewidth=2)
    ax.text(x, y - 0.4, label, fontsize=11, ha='center', fontweight='bold')

# Draw projection arrows
projections = [
    (0, 0), (1, 0),  # a·e → a, e·a → a
    (2, 1), (5, 1),  # a·a⁻¹ → e, e·e → e
    (3, 2), (4, 2),  # b·e → b, e·b → b
]
for ti, ni in projections:
    tx, ty = terms[ti][0], terms[ti][1]
    nx, ny = nfs[ni][0], nfs[ni][1]
    ax.annotate('', xy=(nx, ny + 0.3), xytext=(tx, ty - 0.3),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, ls='--'))

# Labels
ax.text(3, 5.3, 'All Terms (reducible)', fontsize=12, ha='center',
        fontweight='bold', color='gray')
ax.text(3, 0.7, 'Normal Forms (irreducible)', fontsize=12, ha='center',
        fontweight='bold', color='black')

# NF map label
ax.annotate('nf', xy=(3, 3), fontsize=16, ha='center', fontweight='bold',
            color='purple', style='italic')
ax.annotate('', xy=(3, 2.3), xytext=(3, 3.7),
            arrowprops=dict(arrowstyle='->', color='purple', lw=3))

# Properties box
props = [
    'nf(nf(x)) = nf(x)     [idempotent]',
    'x →* y ⟹ nf(x) = nf(y)  [canonical]',
    'x ↔* y ⟺ nf(x) = nf(y)  [decidable]',
]
for i, prop in enumerate(props):
    ax.text(0, -0.2 - i * 0.4, prop, fontsize=9, fontfamily='monospace')

ax.axis('off')

plt.suptitle('Rewrite Semilattice: Algebraic Structure of Normalization',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('rewrite_semilattice.png', dpi=150, bbox_inches='tight')
print("Saved rewrite_semilattice.png")
