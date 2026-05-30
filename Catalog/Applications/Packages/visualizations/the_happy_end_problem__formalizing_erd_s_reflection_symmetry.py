"""
Visualization: Reflection Symmetry of Cups and Caps

Demonstrates the key theorem: reflecting points across the x-axis
transforms cups into caps and vice versa. This symmetry is fundamental
to the Erdős–Szekeres theory and connects the two halves of the
cups-caps argument.
"""

import matplotlib.pyplot as plt
import numpy as np

def orient(a, b, c):
    """Signed area of triangle (a, b, c)."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

# Create a clear cup example
cup_points = [(1, 2), (2, 0.5), (3, 0), (4, 0.5), (5, 2)]
reflected = [(x, -y) for x, y in cup_points]

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Left: Cup
ax = axes[0]
xs = [p[0] for p in cup_points]
ys = [p[1] for p in cup_points]
ax.plot(xs, ys, 'o-', color='#2196F3', linewidth=3, markersize=12,
        markeredgecolor='black', markeredgewidth=1.5, label='Cup', zorder=3)

# Fill the area to show convexity
ax.fill(xs + [xs[-1]], ys + [min(ys) - 1], alpha=0.1, color='#2196F3')

# Annotate orientations
for i in range(len(cup_points) - 2):
    o = orient(cup_points[i], cup_points[i+1], cup_points[i+2])
    mid_x = (cup_points[i][0] + cup_points[i+1][0] + cup_points[i+2][0]) / 3
    mid_y = (cup_points[i][1] + cup_points[i+1][1] + cup_points[i+2][1]) / 3
    sign_str = f'orient > 0 ✓' if o > 0 else f'orient < 0'
    color = '#4CAF50' if o > 0 else '#F44336'
    ax.annotate(sign_str, (mid_x, mid_y + 0.3), fontsize=11,
                ha='center', color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor=color))

for i, (x, y) in enumerate(cup_points):
    ax.annotate(f'({x}, {y})', (x, y), textcoords="offset points",
                xytext=(8, 10), fontsize=10)

ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax.set_title('CUP: All triples have orient > 0', fontsize=15, fontweight='bold',
             color='#2196F3')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_ylim(-3, 3.5)
ax.grid(True, alpha=0.2)
ax.legend(fontsize=12, loc='upper left')

# Right: Reflected = Cap
ax = axes[1]
xs_r = [p[0] for p in reflected]
ys_r = [p[1] for p in reflected]
ax.plot(xs_r, ys_r, 's-', color='#FF5722', linewidth=3, markersize=12,
        markeredgecolor='black', markeredgewidth=1.5, label='Cap (reflected)', zorder=3)

ax.fill(xs_r + [xs_r[-1]], ys_r + [max(ys_r) + 1], alpha=0.1, color='#FF5722')

for i in range(len(reflected) - 2):
    o = orient(reflected[i], reflected[i+1], reflected[i+2])
    mid_x = (reflected[i][0] + reflected[i+1][0] + reflected[i+2][0]) / 3
    mid_y = (reflected[i][1] + reflected[i+1][1] + reflected[i+2][1]) / 3
    sign_str = f'orient < 0 ✓' if o < 0 else f'orient > 0'
    color = '#4CAF50' if o < 0 else '#F44336'
    ax.annotate(sign_str, (mid_x, mid_y - 0.3), fontsize=11,
                ha='center', color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor=color))

for i, (x, y) in enumerate(reflected):
    ax.annotate(f'({x}, {y})', (x, y), textcoords="offset points",
                xytext=(8, -15), fontsize=10)

ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax.set_title('CAP: All triples have orient < 0', fontsize=15, fontweight='bold',
             color='#FF5722')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_ylim(-3.5, 3)
ax.grid(True, alpha=0.2)
ax.legend(fontsize=12, loc='lower left')

# Add connecting arrow
fig.text(0.5, 0.02, 'Reflection: (x, y) → (x, −y) transforms cups into caps',
         ha='center', fontsize=13, fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFF9C4', edgecolor='#F57F17'))

plt.tight_layout(rect=[0, 0.06, 1, 1])
plt.savefig('viz_reflection.png', dpi=150, bbox_inches='tight')
print("Saved viz_reflection.png")
