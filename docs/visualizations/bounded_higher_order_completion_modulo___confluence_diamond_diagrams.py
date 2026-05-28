#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Diagram

Illustrates the peak/join structure of local confluence:
given a peak t → u, t → v, show how joinability of critical pairs
guarantees the existence of a common reduct w.

Renders multiple peak diagrams showing the structure of the
critical pair theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_diamond(ax, x, y, label_top, label_left, label_right,
                  label_bottom=None, joinable=True, title=""):
    """Draw a confluence diamond diagram."""
    w, h = 1.5, 1.2

    # Nodes
    nodes = {
        'top': (x, y + h),
        'left': (x - w, y),
        'right': (x + w, y),
    }
    if label_bottom is not None:
        nodes['bottom'] = (x, y - h)

    # Draw arrows
    arrow_style = dict(arrowstyle='->', lw=1.5, color='#2c3e50')

    ax.annotate('', xy=nodes['left'], xytext=nodes['top'],
                arrowprops=arrow_style)
    ax.annotate('', xy=nodes['right'], xytext=nodes['top'],
                arrowprops=arrow_style)

    if label_bottom is not None:
        dash_style = dict(arrowstyle='->', lw=1.5,
                          color='#27ae60' if joinable else '#e74c3c',
                          linestyle='dashed')
        ax.annotate('', xy=nodes['bottom'], xytext=nodes['left'],
                    arrowprops=dash_style)
        ax.annotate('', xy=nodes['bottom'], xytext=nodes['right'],
                    arrowprops=dash_style)

    # Node circles
    for key, (nx, ny) in nodes.items():
        color = '#3498db'
        if key == 'bottom':
            color = '#27ae60' if joinable else '#e74c3c'
        circle = plt.Circle((nx, ny), 0.25, color=color, alpha=0.8, zorder=5)
        ax.add_patch(circle)

    # Labels
    fontsize = 9
    ax.text(nodes['top'][0], nodes['top'][1], label_top,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    ax.text(nodes['left'][0], nodes['left'][1], label_left,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    ax.text(nodes['right'][0], nodes['right'][1], label_right,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    if label_bottom is not None:
        ax.text(nodes['bottom'][0], nodes['bottom'][1], label_bottom,
                ha='center', va='center', fontsize=fontsize, fontweight='bold',
                color='white', zorder=6)

    # Title
    if title:
        ax.text(x, y + h + 0.5, title, ha='center', va='center',
                fontsize=11, fontweight='bold', color='#2c3e50')

    # Status
    status_y = y - h - 0.5 if label_bottom else y - 0.5
    if joinable:
        ax.text(x, status_y, '✓ Joinable',
                ha='center', va='center', fontsize=10,
                color='#27ae60', fontweight='bold')
    elif label_bottom is not None:
        ax.text(x, status_y, '✗ Not joinable',
                ha='center', va='center', fontsize=10,
                color='#e74c3c', fontweight='bold')


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Three types of joinable peaks
ax = axes[0, 0]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='β/β Peak\n(Church-Rosser)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[0, 1]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='Disjoint Peak\n(Independent Redexes)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[0, 2]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='Overlap Peak\n(Critical Pair Joinable)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

# Row 2: The full pipeline
ax = axes[1, 0]
# Newman's lemma illustration
draw_diamond(ax, 0, 0, 's', 'a', 'b', 'w', joinable=True,
             title="Newman's Lemma\n(Local → Global)")
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[1, 1]
# Critical pair theorem
draw_diamond(ax, 0, 0, 'CP', 'l', 'r', 'nf', joinable=True,
             title='Critical Pair Theorem\n(All CPs Joinable → LC)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[1, 2]
# Unique normal form
draw_diamond(ax, 0, 0, 't', 'n₁', 'n₂', 'n', joinable=True,
             title='Unique Normal Form\n(Terminating + Confluent)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

fig.suptitle('Higher-Order Confluence: Peak Classification & Pipeline',
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('confluence_diamonds.png', dpi=150, bbox_inches='tight')
print("Saved: confluence_diamonds.png")
