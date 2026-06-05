#!/usr/bin/env python3
"""
Visualization: Voice-Leading Quiver of First-Species Counterpoint

Draws the directed graph of allowed voice-leading transitions between
consonant intervals, with perfect and imperfect consonances distinguished
by color and self-loops highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Consonant intervals and their properties
CONSONANT = [0, 3, 4, 7, 8, 9]
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

NAMES = {0: "Unison\n(0)", 3: "m3\n(3)", 4: "M3\n(4)",
         7: "P5\n(7)", 8: "m6\n(8)", 9: "M6\n(9)"}

# Layout: arrange on a circle
n = len(CONSONANT)
angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]
positions = {CONSONANT[i]: (1.5 * np.cos(angles[i]), 1.5 * np.sin(angles[i]))
             for i in range(n)}

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# ---- Panel 1: Full Voice-Leading Quiver ----
ax = axes[0]
ax.set_title("Voice-Leading Quiver\n(34 edges: 6×6 − 2 forbidden)", fontsize=13, fontweight='bold')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

# Draw edges (cross-transitions)
for i in CONSONANT:
    for j in CONSONANT:
        if i == j:
            continue
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrows to not overlap with nodes
        shrink = 0.35
        ax.annotate("", xy=(x2 - shrink * dx / length, y2 - shrink * dy / length),
                     xytext=(x1 + shrink * dx / length, y1 + shrink * dy / length),
                     arrowprops=dict(arrowstyle="->", color="#888888", lw=0.5,
                                     connectionstyle="arc3,rad=0.1"))

# Draw self-loops (only imperfect)
for i in IMPERFECT:
    x, y = positions[i]
    angle = np.arctan2(y, x)
    loop_x = x + 0.4 * np.cos(angle)
    loop_y = y + 0.4 * np.sin(angle)
    circle = plt.Circle((loop_x, loop_y), 0.2, fill=False,
                         edgecolor='#2ecc71', linewidth=2, linestyle='-')
    ax.add_patch(circle)

# Draw forbidden self-loops (perfect) with X marks
for i in PERFECT:
    x, y = positions[i]
    angle = np.arctan2(y, x)
    loop_x = x + 0.4 * np.cos(angle)
    loop_y = y + 0.4 * np.sin(angle)
    circle = plt.Circle((loop_x, loop_y), 0.2, fill=False,
                         edgecolor='#e74c3c', linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.text(loop_x, loop_y, '✗', ha='center', va='center',
            fontsize=10, color='#e74c3c', fontweight='bold')

# Draw nodes
for i in CONSONANT:
    x, y = positions[i]
    color = '#e74c3c' if i in PERFECT else '#3498db'
    circle = plt.Circle((x, y), 0.3, facecolor=color, edgecolor='white',
                         linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, NAMES[i], ha='center', va='center',
            fontsize=8, color='white', fontweight='bold', zorder=6)

# Legend
perfect_patch = mpatches.Patch(color='#e74c3c', label='Perfect consonance')
imperfect_patch = mpatches.Patch(color='#3498db', label='Imperfect consonance')
ax.legend(handles=[perfect_patch, imperfect_patch], loc='lower right', fontsize=9)

# ---- Panel 2: Complement Structure ----
ax2 = axes[1]
ax2.set_title("Complement Duality\n(imperfect: closed; perfect: breaks at P4)", fontsize=13, fontweight='bold')
ax2.set_xlim(-3, 3)
ax2.set_ylim(-2.5, 2.5)
ax2.set_aspect('equal')
ax2.axis('off')

# Draw all 12 intervals on a circle
all_angles = [2 * np.pi * i / 12 - np.pi / 2 for i in range(12)]
all_pos = {i: (2 * np.cos(all_angles[i]), 2 * np.sin(all_angles[i])) for i in range(12)}

interval_names_short = {
    0: "U", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
    6: "TT", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7"
}

# Draw complement arrows
complement_pairs = [(3, 9), (4, 8)]  # imperfect pairs
for a, b in complement_pairs:
    x1, y1 = all_pos[a]
    x2, y2 = all_pos[b]
    ax2.annotate("", xy=(x2 * 0.85, y2 * 0.85), xytext=(x1 * 0.85, y1 * 0.85),
                 arrowprops=dict(arrowstyle="<->", color='#2ecc71', lw=2.5))

# Draw the broken complement pair (5, 7)
x1, y1 = all_pos[7]
x2, y2 = all_pos[5]
ax2.annotate("", xy=(x2 * 0.85, y2 * 0.85), xytext=(x1 * 0.85, y1 * 0.85),
             arrowprops=dict(arrowstyle="<->", color='#e74c3c', lw=2.5, linestyle='--'))

# Draw nodes
for i in range(12):
    x, y = all_pos[i]
    if i in PERFECT:
        color = '#e74c3c'
    elif i in IMPERFECT:
        color = '#3498db'
    elif i == 5:
        color = '#f39c12'  # highlight the breaking point
    else:
        color = '#bdc3c7'  # dissonant
    circle = plt.Circle((x, y), 0.25, facecolor=color, edgecolor='white',
                         linewidth=1.5, zorder=5)
    ax2.add_patch(circle)
    ax2.text(x, y, interval_names_short[i], ha='center', va='center',
            fontsize=7, color='white', fontweight='bold', zorder=6)

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    mpatches.Patch(color='#e74c3c', label='Perfect consonance'),
    mpatches.Patch(color='#3498db', label='Imperfect consonance'),
    mpatches.Patch(color='#f39c12', label='P4 (breaking point)'),
    mpatches.Patch(color='#bdc3c7', label='Dissonant'),
    Line2D([0], [0], color='#2ecc71', lw=2.5, label='Complement (preserved)'),
    Line2D([0], [0], color='#e74c3c', lw=2.5, linestyle='--', label='Complement (broken)'),
]
ax2.legend(handles=legend_elements, loc='lower right', fontsize=7)

plt.tight_layout()
plt.savefig('counterpoint_quiver.png', dpi=150, bbox_inches='tight')
plt.savefig('counterpoint_quiver.svg', bbox_inches='tight')
print("Saved: counterpoint_quiver.png, counterpoint_quiver.svg")
