#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Property

Visualizes how confluence guarantees that all rewrite paths from a common
source converge to a unique normal form, using a diamond-shaped diagram
with multiple rewrite paths shown as colored arrows.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Diamond property ---
ax = axes[0]
ax.set_xlim(-3, 3)
ax.set_ylim(-3.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The Diamond Property\n(Local Confluence)', fontsize=14, fontweight='bold')

# Nodes
nodes = {
    't': (0, 2),
    'u': (-2, 0),
    'v': (2, 0),
    'w': (0, -2),
}

for label, (x, y) in nodes.items():
    circle = plt.Circle((x, y), 0.35, fill=True, facecolor='lightblue',
                        edgecolor='navy', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y, label, ha='center', va='center', fontsize=16,
            fontweight='bold', color='navy')

# Arrows: t → u (blue, solid)
ax.annotate('', xy=(-1.65, 0.35), xytext=(-0.35, 1.65),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2.5))
ax.text(-1.5, 1.3, 'rewrite₁', fontsize=10, color='#2196F3', rotation=45,
        ha='center', va='center')

# Arrows: t → v (red, solid)
ax.annotate('', xy=(1.65, 0.35), xytext=(0.35, 1.65),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2.5))
ax.text(1.5, 1.3, 'rewrite₂', fontsize=10, color='#F44336', rotation=-45,
        ha='center', va='center')

# Arrows: u →* w (blue, dashed)
ax.annotate('', xy=(-0.35, -1.65), xytext=(-1.65, -0.35),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2, linestyle='dashed'))
ax.text(-1.5, -1.3, '→*', fontsize=12, color='#2196F3', rotation=-45,
        ha='center', va='center')

# Arrows: v →* w (red, dashed)
ax.annotate('', xy=(0.35, -1.65), xytext=(1.65, -0.35),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2, linestyle='dashed'))
ax.text(1.5, -1.3, '→*', fontsize=12, color='#F44336', rotation=45,
        ha='center', va='center')

ax.text(0, -3.2, 'Every peak (u ← t → v) can be\ncompleted to a diamond (u →* w ←* v)',
        ha='center', va='center', fontsize=10, style='italic')

# --- Right panel: Newman's lemma ---
ax2 = axes[1]
ax2.set_xlim(-4, 4)
ax2.set_ylim(-5, 3)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title("Newman's Lemma\n(Local → Global Confluence)", fontsize=14, fontweight='bold')

# Show a more complex rewrite graph
nodes2 = {
    't': (0, 2),
    'a': (-2, 0.5),
    'b': (2, 0.5),
    'c': (-3, -1.5),
    'd': (0, -1),
    'e': (3, -1.5),
    'nf': (0, -3.5),
}

colors = {
    't': '#FFD54F',  # gold (source)
    'a': '#90CAF9', 'b': '#EF9A9A',
    'c': '#90CAF9', 'd': '#CE93D8',
    'e': '#EF9A9A',
    'nf': '#A5D6A7',  # green (normal form)
}

for label, (x, y) in nodes2.items():
    circle = plt.Circle((x, y), 0.35, fill=True,
                        facecolor=colors[label],
                        edgecolor='#333', linewidth=2)
    ax2.add_patch(circle)
    display = 'nf' if label == 'nf' else label
    ax2.text(x, y, display, ha='center', va='center', fontsize=13,
            fontweight='bold', color='#333')

# Arrows showing the confluence argument
arrows = [
    ('t', 'a', '#2196F3'),
    ('t', 'b', '#F44336'),
    ('a', 'c', '#2196F3'),
    ('a', 'd', '#9C27B0'),
    ('b', 'd', '#9C27B0'),
    ('b', 'e', '#F44336'),
    ('c', 'nf', '#2196F3'),
    ('d', 'nf', '#9C27B0'),
    ('e', 'nf', '#F44336'),
]

for src, dst, color in arrows:
    x1, y1 = nodes2[src]
    x2, y2 = nodes2[dst]
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    ux, uy = dx/length, dy/length
    ax2.annotate('', xy=(x2 - ux*0.4, y2 - uy*0.4),
                xytext=(x1 + ux*0.4, y1 + uy*0.4),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

ax2.text(0, -4.7,
         'Termination + local confluence → all paths\nconverge to the unique normal form',
         ha='center', va='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('confluence_diamond.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved confluence_diamond.png")
