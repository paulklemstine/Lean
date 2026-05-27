#!/usr/bin/env python3
"""
Visualization: Peak and Join Diagrams

Visualizes the key concepts of rewriting theory:
- Local peaks (divergent rewrites from a common source)
- Joinability (convergence to a common target)
- The critical pair theorem structure
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_peak_join_diagram(ax, title, labels, joinable=True):
    """Draw a peak/join diamond diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.8, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)

    # Node positions
    top = (0, 1.2)
    left = (-1, 0)
    right = (1, 0)
    bottom = (0, -1.2)

    node_color = '#E3F2FD'
    node_edge = '#1565C0'

    # Draw nodes
    for pos, label in [(top, labels[0]), (left, labels[1]),
                       (right, labels[2])]:
        circle = plt.Circle(pos, 0.3, facecolor=node_color,
                           edgecolor=node_edge, linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=4)

    # Draw arrows (top to left, top to right)
    arrow_props = dict(arrowstyle='->', color='#D32F2F', lw=2,
                      connectionstyle='arc3,rad=0.1')
    ax.annotate('', xy=(-0.75, 0.25), xytext=(-0.2, 0.95),
                arrowprops=arrow_props)
    ax.annotate('', xy=(0.75, 0.25), xytext=(0.2, 0.95),
                arrowprops=arrow_props)

    # Labels on arrows
    ax.text(-0.7, 0.75, 'r₁', fontsize=10, color='#D32F2F',
            fontweight='bold')
    ax.text(0.55, 0.75, 'r₂', fontsize=10, color='#D32F2F',
            fontweight='bold')

    if joinable:
        # Draw join arrows and bottom node
        circle = plt.Circle(bottom, 0.3, facecolor='#E8F5E9',
                           edgecolor='#2E7D32', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(bottom[0], bottom[1], labels[3] if len(labels) > 3 else 'w',
                ha='center', va='center', fontsize=11, fontweight='bold',
                zorder=4)

        join_props = dict(arrowstyle='->', color='#2E7D32', lw=2,
                         connectionstyle='arc3,rad=0.1', linestyle='dashed')
        ax.annotate('', xy=(-0.2, -0.95), xytext=(-0.75, -0.25),
                    arrowprops=join_props)
        ax.annotate('', xy=(0.2, -0.95), xytext=(0.75, -0.25),
                    arrowprops=join_props)

        ax.text(-0.7, -0.65, '*', fontsize=14, color='#2E7D32',
                fontweight='bold')
        ax.text(0.55, -0.65, '*', fontsize=14, color='#2E7D32',
                fontweight='bold')

        ax.text(0, -1.7, '✓ Joinable', fontsize=11, ha='center',
                color='#2E7D32', fontweight='bold')
    else:
        ax.text(-1, -0.6, '?', fontsize=20, ha='center', color='#FF6F00')
        ax.text(1, -0.6, '?', fontsize=20, ha='center', color='#FF6F00')
        ax.text(0, -1.2, '✗ Non-joinable', fontsize=11, ha='center',
                color='#D32F2F', fontweight='bold')


fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# Diagram 1: Disjoint peak (always joinable)
draw_peak_join_diagram(axes[0],
    'Disjoint Peak\n(Always Joinable)',
    ['f(s,t)', 'f(s\',t)', 'f(s,t\')', 'f(s\',t\')'],
    joinable=True)

# Diagram 2: Critical pair peak (joinable if CP joins)
draw_peak_join_diagram(axes[1],
    'Critical Pair Peak\n(Joinable iff CP Joins)',
    ['σ(l)', 'σ(r₁)', 'σ(r₂)', 'w'],
    joinable=True)

# Diagram 3: Non-confluent peak
draw_peak_join_diagram(axes[2],
    'Non-Confluent Peak\n(System Defect)',
    ['t', 'u', 'v'],
    joinable=False)

plt.suptitle('Peak Classification in Higher-Order Rewriting',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('peak_diagrams.png', dpi=150, bbox_inches='tight')
print("Saved: peak_diagrams.png")
