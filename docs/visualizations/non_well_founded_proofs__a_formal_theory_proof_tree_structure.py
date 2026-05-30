#!/usr/bin/env python3
"""
Visualization 1: Non-Well-Founded Proof Tree Structure

Visualizes the structure of different NWF proof trees,
showing valid vs invalid proofs, self-referential nodes,
and ordinal heights using a tree layout.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_proof_tree(ax, tree_type, title, positions, edges, colors, labels, heights):
    """Draw a proof tree on the given axes."""
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw edges
    for (x1, y1), (x2, y2) in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for (x, y), color, label, h in zip(positions, colors, labels, heights):
        circle = plt.Circle((x, y), 0.3, facecolor=color, edgecolor='black',
                            linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, label, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=3)
        ax.text(x, y - 0.15, f'h={h}', ha='center', va='center', fontsize=7,
                color='gray', zorder=3)


fig, axes = plt.subplots(1, 4, figsize=(16, 5))
fig.suptitle('Non-Well-Founded Proof Trees', fontsize=14, fontweight='bold', y=0.98)

# Tree 1: Axiom (trivial)
draw_proof_tree(axes[0], 'axiom', 'Axiom\n(Well-Founded)',
    positions=[(1.5, 1.5)],
    edges=[],
    colors=['#4CAF50'],
    labels=['Ax(P)'],
    heights=[0])
axes[0].text(1.5, 0.3, 'Valid ✓\nNo self-reference',
             ha='center', fontsize=9, color='green')

# Tree 2: Identity proof (P → P via self-reference)
draw_proof_tree(axes[1], 'identity', 'Identity (P→P)\n(Valid NWF)',
    positions=[(1.5, 2.5), (1.5, 1.0)],
    edges=[((1.5, 2.5), (1.5, 1.0))],
    colors=['#FF9800', '#4CAF50'],
    labels=['Self(P)', 'Ax(P)'],
    heights=[1, 0])
# Draw self-reference arrow
angle = np.linspace(0, 2*np.pi*0.6, 50)
r = 0.6
cx, cy = 2.3, 2.5
ax_arrow_x = cx + r * np.cos(angle)
ax_arrow_y = cy + r * np.sin(angle)
axes[1].plot(ax_arrow_x, ax_arrow_y, 'b--', linewidth=1.5, alpha=0.5)
axes[1].annotate('', xy=(1.8, 2.5), xytext=(2.1, 2.9),
                arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
axes[1].text(1.5, 0.1, 'Valid ✓\nHeight = 1',
             ha='center', fontsize=9, color='green')

# Tree 3: Liar sentence (invalid)
draw_proof_tree(axes[2], 'liar', 'Liar Sentence\n(Invalid NWF)',
    positions=[(1.5, 2.5), (1.5, 1.0)],
    edges=[((1.5, 2.5), (1.5, 1.0))],
    colors=['#FF9800', '#F44336'],
    labels=['Self(P)', '⊥'],
    heights=[1, 0])
axes[2].text(1.5, 0.1, 'Invalid ✗\nBottom has no conclusion',
             ha='center', fontsize=9, color='red')

# Tree 4: Modus Ponens composition
draw_proof_tree(axes[3], 'mp', 'Modus Ponens\n(Composition)',
    positions=[(1.5, 2.8), (0.5, 1.5), (2.5, 1.5),
               (0.5, 0.3), (2.5, 0.3)],
    edges=[((1.5, 2.8), (0.5, 1.5)), ((1.5, 2.8), (2.5, 1.5)),
           ((0.5, 1.5), (0.5, 0.3)), ((2.5, 1.5), (2.5, 0.3))],
    colors=['#2196F3', '#FF9800', '#4CAF50', '#4CAF50', '#4CAF50'],
    labels=['MP', 'Self(Q)', 'Ax(Q)', 'Ax(P)', 'Ax(Q)'],
    heights=[2, 1, 0, 0, 0])
axes[3].text(1.5, -0.4, 'Valid ✓\nHeight = 2',
             ha='center', fontsize=9, color='green')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Axiom'),
    mpatches.Patch(facecolor='#FF9800', edgecolor='black', label='Self-Reference'),
    mpatches.Patch(facecolor='#2196F3', edgecolor='black', label='Modus Ponens'),
    mpatches.Patch(facecolor='#F44336', edgecolor='black', label='Bottom (⊥)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
          fontsize=10, bbox_to_anchor=(0.5, 0.01))

plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_proof_trees.png', dpi=150, bbox_inches='tight')
print("Saved viz_proof_trees.png")
