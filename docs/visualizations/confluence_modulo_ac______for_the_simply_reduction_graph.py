#!/usr/bin/env python3
"""
Visualization: Reduction Graph for STTC Terms

Shows the complete reduction graph for a small term, illustrating
how different reduction strategies (β-first, dist-first) traverse
different paths but reach AC-equivalent normal forms.

Uses matplotlib to render the reduction DAG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_reduction_graph():
    """Draw the reduction graph for smul (a+b) (u⊕v)."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    ax.set_xlim(-6, 6)
    ax.set_ylim(-8, 2)
    ax.axis('off')
    ax.set_title('Reduction Graph: (a+b) • (u ⊕ v)\nAll paths converge modulo AC',
                 fontsize=15, fontweight='bold', pad=20)

    # Node positions and labels
    nodes = {
        'root': (0, 1, '(a+b) • (u⊕v)', '#2196F3'),
        'left': (-4, -1, '(a•(u⊕v)) ⊕\n(b•(u⊕v))', '#4CAF50'),
        'right': (4, -1, '((a+b)•u) ⊕\n((a+b)•v)', '#FF9800'),
        'left2': (-4, -3.5, '(a•u ⊕ a•v) ⊕\n(b•(u⊕v))', '#66BB6A'),
        'left3': (-4, -5.5, '(a•u ⊕ a•v) ⊕\n(b•u ⊕ b•v)', '#81C784'),
        'right2': (4, -3.5, '(a•u ⊕ b•u) ⊕\n((a+b)•v)', '#FFB74D'),
        'right3': (4, -5.5, '(a•u ⊕ b•u) ⊕\n(a•v ⊕ b•v)', '#FFCC80'),
        'nf': (0, -7.5, '{a•u, a•v, b•u, b•v}\n(AC canonical form)', '#9C27B0'),
    }

    for key, (x, y, label, color) in nodes.items():
        w, h = 2.8, 1.2
        if key == 'nf':
            w, h = 3.5, 1.0
        rect = mpatches.FancyBboxPatch((x - w/2, y - h/2), w, h,
                                        boxstyle="round,pad=0.2",
                                        facecolor=color, alpha=0.85,
                                        edgecolor='#333', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white')

    # Arrows with labels
    def arrow(start, end, label, color='#555', offset=0):
        x1, y1 = nodes[start][0] + offset, nodes[start][1]
        x2, y2 = nodes[end][0] + offset, nodes[end][1]
        ax.annotate('', xy=(x2, y2 + 0.6), xytext=(x1, y1 - 0.6),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2))
        mx, my = (x1+x2)/2 + 0.3, (y1+y2)/2
        ax.text(mx, my, label, fontsize=7, color=color,
                fontweight='bold', ha='left', va='center',
                bbox=dict(boxstyle='round,pad=0.15', facecolor='white',
                         edgecolor=color, alpha=0.9))

    arrow('root', 'left', 'smul_left_dist', '#4CAF50', offset=-0.5)
    arrow('root', 'right', 'smul_right_dist', '#FF9800', offset=0.5)
    arrow('left', 'left2', 'smul_right_dist\n(left child)', '#4CAF50')
    arrow('left2', 'left3', 'smul_right_dist\n(right child)', '#4CAF50')
    arrow('right', 'right2', 'smul_left_dist\n(left child)', '#FF9800')
    arrow('right2', 'right3', 'smul_left_dist\n(right child)', '#FF9800')

    # AC equivalence arrows to canonical form
    for key, color in [('left3', '#4CAF50'), ('right3', '#FF9800')]:
        x1, y1 = nodes[key][0], nodes[key][1]
        x2, y2 = nodes['nf'][0], nodes['nf'][1]
        ax.annotate('', xy=(x2, y2 + 0.5), xytext=(x1, y1 - 0.6),
                    arrowprops=dict(arrowstyle='->', color='#9C27B0',
                                   lw=2, linestyle='dashed'))

    ax.text(0, -6.5, '≡ mod AC', fontsize=12, color='#9C27B0',
            fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#F3E5F5',
                     edgecolor='#9C27B0'))

    # Legend
    legend_items = [
        mpatches.Patch(color='#4CAF50', label='β-first path'),
        mpatches.Patch(color='#FF9800', label='dist-first path'),
        mpatches.Patch(color='#9C27B0', label='AC equivalence'),
    ]
    ax.legend(handles=legend_items, loc='upper right', fontsize=10,
             framealpha=0.9)

    plt.tight_layout()
    plt.savefig('reduction_graph.png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    print("Saved reduction_graph.png")


if __name__ == "__main__":
    draw_reduction_graph()
