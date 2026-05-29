#!/usr/bin/env python3
"""
Visualization: Orbits and Equivariant Maps Under Group Actions

This script visualizes the core concepts of equivariant impossibility theory:
1. Orbit structures of cyclic group actions
2. Equivariant self-maps as translations
3. The impossibility of constant equivariant maps

Uses matplotlib to create a multi-panel figure showing how group symmetry
constrains the space of equivariant functions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch

# Configure style
plt.rcParams.update({
    'font.size': 11,
    'font.family': 'serif',
    'axes.titlesize': 13,
    'axes.labelsize': 11,
    'figure.facecolor': 'white',
})

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle('Equivariant Impossibility: Orbits, Maps, and Obstructions',
             fontsize=16, fontweight='bold', y=0.98)

# Color palettes
orbit_colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800', '#00BCD4']
map_colors = ['#1565C0', '#C62828', '#2E7D32', '#6A1B9A', '#E65100']

# ============================================================
# Panel 1: C₃ orbit structure
# ============================================================
ax = axes[0, 0]
ax.set_title('C₃ Action on {0,1,2}\n(Free & Transitive)')
n = 3
angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
x_pts = np.cos(angles) * 0.6
y_pts = np.sin(angles) * 0.6

for i in range(n):
    ax.plot(x_pts[i], y_pts[i], 'o', color=orbit_colors[0], markersize=20, zorder=5)
    ax.text(x_pts[i], y_pts[i], str(i), ha='center', va='center',
            fontsize=12, fontweight='bold', color='white', zorder=6)

# Draw orbit arrows
for i in range(n):
    j = (i + 1) % n
    dx = x_pts[j] - x_pts[i]
    dy = y_pts[j] - y_pts[i]
    ax.annotate('', xy=(x_pts[j] - 0.08*dx, y_pts[j] - 0.08*dy),
                xytext=(x_pts[i] + 0.08*dx, y_pts[i] + 0.08*dy),
                arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2))

ax.text(0, -0.95, 'Single orbit: {0,1,2}\nNo fixed points',
        ha='center', va='center', fontsize=9, style='italic',
        bbox=dict(boxstyle='round', facecolor='#E3F2FD', alpha=0.8))
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.15, 1.1)
ax.set_aspect('equal')
ax.axis('off')

# ============================================================
# Panel 2: C₄ orbit structure
# ============================================================
ax = axes[0, 1]
ax.set_title('C₄ Action on {0,1,2,3}\n(Free & Transitive)')
n = 4
angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/4
x_pts = np.cos(angles) * 0.6
y_pts = np.sin(angles) * 0.6

for i in range(n):
    ax.plot(x_pts[i], y_pts[i], 'o', color=orbit_colors[1], markersize=20, zorder=5)
    ax.text(x_pts[i], y_pts[i], str(i), ha='center', va='center',
            fontsize=12, fontweight='bold', color='white', zorder=6)

for i in range(n):
    j = (i + 1) % n
    dx = x_pts[j] - x_pts[i]
    dy = y_pts[j] - y_pts[i]
    ax.annotate('', xy=(x_pts[j] - 0.08*dx, y_pts[j] - 0.08*dy),
                xytext=(x_pts[i] + 0.08*dx, y_pts[i] + 0.08*dy),
                arrowprops=dict(arrowstyle='->', color='#C62828', lw=2))

ax.text(0, -0.95, 'Single orbit: {0,1,2,3}\nNo fixed points',
        ha='center', va='center', fontsize=9, style='italic',
        bbox=dict(boxstyle='round', facecolor='#FFEBEE', alpha=0.8))
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.15, 1.1)
ax.set_aspect('equal')
ax.axis('off')

# ============================================================
# Panel 3: S₃ stabilizer structure
# ============================================================
ax = axes[0, 2]
ax.set_title('S₃ Action on {0,1,2}\n(Transitive, NOT Free)')
n = 3
angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
x_pts = np.cos(angles) * 0.6
y_pts = np.sin(angles) * 0.6

for i in range(n):
    ax.plot(x_pts[i], y_pts[i], 'o', color=orbit_colors[2], markersize=20, zorder=5)
    ax.text(x_pts[i], y_pts[i], str(i), ha='center', va='center',
            fontsize=12, fontweight='bold', color='white', zorder=6)

# Draw stabilizer loops
for i in range(n):
    circle = plt.Circle((x_pts[i], y_pts[i]), 0.18, fill=False,
                        color='#C62828', lw=2, linestyle='--')
    ax.add_patch(circle)

ax.text(0, -0.95, 'Stab(0) = {id, (1 2)} ≠ {id}\nNOT free!',
        ha='center', va='center', fontsize=9, style='italic',
        bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.15, 1.1)
ax.set_aspect('equal')
ax.axis('off')

# ============================================================
# Panel 4: Equivariant self-maps of C₃
# ============================================================
ax = axes[1, 0]
ax.set_title('All Equivariant Self-Maps of C₃\n(3 translations, 0 constant)')

for k, shift in enumerate([0, 1, 2]):
    y_offset = 0.7 - k * 0.7
    label = f'f(x) = x+{shift}' if shift > 0 else 'f(x) = x (id)'

    for i in range(3):
        # Source
        ax.plot(-0.5, y_offset + i*0.15 - 0.15, 's', color='#2196F3',
                markersize=10)
        ax.text(-0.65, y_offset + i*0.15 - 0.15, str(i), ha='center',
                va='center', fontsize=9)

        # Target
        j = (i + shift) % 3
        ax.plot(0.5, y_offset + i*0.15 - 0.15, 's', color='#FF5722',
                markersize=10)
        ax.text(0.65, y_offset + i*0.15 - 0.15, str(j), ha='center',
                va='center', fontsize=9)

        # Arrow
        ax.annotate('', xy=(0.42, y_offset + i*0.15 - 0.15),
                    xytext=(-0.42, y_offset + i*0.15 - 0.15),
                    arrowprops=dict(arrowstyle='->', color='#666', lw=1.5))

    ax.text(0, y_offset + 0.3, label, ha='center', va='center',
            fontsize=10, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#FFF9C4', alpha=0.8))

ax.text(0, -0.95, '✓ All injective (bijective)\n✗ None constant → Theorem A',
        ha='center', va='center', fontsize=9, style='italic',
        bbox=dict(boxstyle='round', facecolor='#FFF3E0', alpha=0.8))
ax.set_xlim(-1, 1)
ax.set_ylim(-1.15, 1.1)
ax.axis('off')

# ============================================================
# Panel 5: Impossibility illustration
# ============================================================
ax = axes[1, 1]
ax.set_title('Why Constant Maps Fail\n(Theorem A: Core Impossibility)')

# Show the contradiction
y_positions = [0.6, 0.0, -0.6]
labels = ['Equivariance:\nf(g·x) = g·f(x)', 'Constancy:\nf(x) = c for all x',
          'Combined:\ng·c = c for all g']

colors_bg = ['#E3F2FD', '#E8F5E9', '#FFCDD2']
for i, (y, label, bg) in enumerate(zip(y_positions, labels, colors_bg)):
    ax.text(0, y, label, ha='center', va='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.5', facecolor=bg, alpha=0.9))
    if i < 2:
        ax.annotate('', xy=(0, y - 0.2), xytext=(0, y_positions[i+1] + 0.2),
                    arrowprops=dict(arrowstyle='<-', color='#333', lw=2))

ax.text(0, -0.95, '⚡ CONTRADICTION ⚡\nFree action: g·c ≠ c for g ≠ 1',
        ha='center', va='center', fontsize=10, fontweight='bold',
        color='#C62828',
        bbox=dict(boxstyle='round', facecolor='#FFCDD2', alpha=0.9))
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.15, 1.1)
ax.axis('off')

# ============================================================
# Panel 6: Task solvability landscape
# ============================================================
ax = axes[1, 2]
ax.set_title('Task Solvability Landscape\nSolvable vs. Impossible Tasks')

# Create a grid showing different task types
tasks = [
    ('Identity\nTask', True, '#4CAF50'),
    ('Translation\nTask', True, '#8BC34A'),
    ('Constant\nTask', False, '#F44336'),
    ('Fixed-Point\nTask', False, '#E91E63'),
    ('Retraction\nTask', False, '#FF5722'),
    ('Social Choice\nTask', False, '#FF9800'),
]

for i, (name, solvable, color) in enumerate(tasks):
    row = i // 3
    col = i % 3
    x = -0.7 + col * 0.7
    y = 0.4 - row * 0.9

    rect = mpatches.FancyBboxPatch((x - 0.28, y - 0.25), 0.56, 0.5,
                                    boxstyle='round,pad=0.05',
                                    facecolor=color, alpha=0.3,
                                    edgecolor=color, lw=2)
    ax.add_patch(rect)
    ax.text(x, y + 0.05, name, ha='center', va='center', fontsize=8,
            fontweight='bold')
    symbol = '✓' if solvable else '✗'
    symbol_color = '#2E7D32' if solvable else '#C62828'
    ax.text(x, y - 0.15, symbol, ha='center', va='center', fontsize=14,
            fontweight='bold', color=symbol_color)

ax.text(0, -0.95, 'On C₃ (free, transitive, nontrivial)',
        ha='center', va='center', fontsize=9, style='italic',
        bbox=dict(boxstyle='round', facecolor='#F3E5F5', alpha=0.8))
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.15, 1.1)
ax.axis('off')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('equivariant_impossibility.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved visualization to equivariant_impossibility.png")
