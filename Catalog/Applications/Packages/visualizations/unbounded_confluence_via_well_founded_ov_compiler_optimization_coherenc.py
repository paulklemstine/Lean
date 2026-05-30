#!/usr/bin/env python3
"""
Visualization: Compiler Optimization Coherence

Illustrates how confluence guarantees that different compiler optimization
strategies (rewrite orderings) all converge to the same optimized program.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, ax = plt.subplots(figsize=(12, 8))
ax.set_xlim(-6, 6)
ax.set_ylim(-7, 4)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Compiler Optimization Coherence\nAll Paths Lead to the Same Optimized Program',
             fontsize=16, fontweight='bold', pad=20)

# Source program at top
source = (0, 3)
ax.add_patch(mpatches.FancyBboxPatch(
    (-2.2, 2.3), 4.4, 1.4, boxstyle="round,pad=0.1",
    facecolor='#FFD54F', edgecolor='#F57F17', linewidth=2))
ax.text(0, 3, 'Source Program\n(x * 2) + (3 + 0)', ha='center', va='center',
        fontsize=12, fontweight='bold')

# Three optimization paths
paths = [
    {
        'name': 'Strategy A',
        'color': '#2196F3',
        'steps': [
            (-4, 0.5, 'Constant Fold\n(x * 2) + 3'),
            (-4, -2, 'Strength Reduce\n(x + x) + 3'),
        ],
        'x_final': -4,
    },
    {
        'name': 'Strategy B',
        'color': '#F44336',
        'steps': [
            (0, 0.5, 'Strength Reduce\n(x + x) + (3 + 0)'),
            (0, -2, 'Algebraic Simplify\n(x + x) + 3'),
        ],
        'x_final': 0,
    },
    {
        'name': 'Strategy C',
        'color': '#4CAF50',
        'steps': [
            (4, 0.5, 'Algebraic Simplify\n(x * 2) + 3'),
            (4, -2, 'Strength Reduce\n(x + x) + 3'),
        ],
        'x_final': 4,
    },
]

# Draw paths
for path in paths:
    color = path['color']
    # Arrow from source to first step
    x_step = path['steps'][0][0]
    ax.annotate('', xy=(x_step, 1.3), xytext=(0, 2.3),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5,
                               connectionstyle='arc3,rad=0.1'))

    # Draw intermediate steps
    for i, (x, y, label) in enumerate(path['steps']):
        ax.add_patch(mpatches.FancyBboxPatch(
            (x-2, y-0.6), 4, 1.2, boxstyle="round,pad=0.1",
            facecolor=color, edgecolor=color, linewidth=1.5, alpha=0.15))
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                color=color, fontweight='bold')

        # Arrow to next step
        if i < len(path['steps']) - 1:
            next_x, next_y = path['steps'][i+1][0], path['steps'][i+1][1]
            ax.annotate('', xy=(next_x, next_y + 0.6), xytext=(x, y - 0.6),
                        arrowprops=dict(arrowstyle='->', color=color, lw=2))

    # Arrow from last step to normal form
    last_x, last_y = path['steps'][-1][0], path['steps'][-1][1]
    ax.annotate('', xy=(0, -4.2), xytext=(last_x, last_y - 0.6),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5,
                               connectionstyle='arc3,rad=0.1',
                               linestyle='dashed'))

    # Path label
    ax.text(x_step, 1.8, path['name'], ha='center', va='center',
            fontsize=10, color=color, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                     edgecolor=color, alpha=0.9))

# Normal form at bottom
ax.add_patch(mpatches.FancyBboxPatch(
    (-2.2, -5.5), 4.4, 1.4, boxstyle="round,pad=0.1",
    facecolor='#A5D6A7', edgecolor='#2E7D32', linewidth=3))
ax.text(0, -4.8, 'Optimized Program\n(x + x) + 3', ha='center', va='center',
        fontsize=13, fontweight='bold', color='#1B5E20')

# Star burst around normal form
for angle in np.linspace(0, 2*np.pi, 12, endpoint=False):
    r1, r2 = 2.8, 3.2
    ax.plot([0 + r1*np.cos(angle), 0 + r2*np.cos(angle)],
            [-4.8 + r1*np.sin(angle), -4.8 + r2*np.sin(angle)],
            color='#FFD54F', lw=2, alpha=0.5)

# Legend box
legend_text = (
    "Confluence Theorem:\n"
    "If the rewrite system is terminating\n"
    "and all critical pairs are joinable,\n"
    "then ALL optimization strategies\n"
    "produce the SAME result."
)
ax.text(0, -6.5, legend_text, ha='center', va='center', fontsize=10,
        style='italic', color='#333',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFF9C4',
                 edgecolor='#FBC02D', alpha=0.9))

plt.tight_layout()
plt.savefig('compiler_coherence.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved compiler_coherence.png")
