"""
Visualization 2: Pattern Classification by Genus

Shows the genus-degree formula and how algebraic genus classifies
biological patterns into spots, stripes, and labyrinths.
Includes the motivic density curve showing why spots are most common.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def genus_degree(d):
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def motivic_density(g):
    if g == 0:
        return 1.5
    elif g == 1:
        return 1.0
    elif g >= 2:
        return 1.0 / (2 * g - 2)
    return 0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Genus-Degree Formula
ax = axes[0]
degrees = list(range(1, 10))
genera = [genus_degree(d) for d in degrees]

colors = []
for g in genera:
    if g == 0:
        colors.append('#2196F3')  # blue for spots
    elif g == 1:
        colors.append('#4CAF50')  # green for stripes
    else:
        colors.append('#FF5722')  # red for labyrinths

bars = ax.bar(degrees, genera, color=colors, edgecolor='black', linewidth=0.8)
ax.set_xlabel('Algebraic Degree $d$', fontsize=12)
ax.set_ylabel('Genus $g = (d-1)(d-2)/2$', fontsize=12)
ax.set_title('Genus-Degree Formula', fontsize=13)
ax.set_xticks(degrees)

# Legend
spots_patch = mpatches.Patch(color='#2196F3', label='Spots (g=0)')
stripes_patch = mpatches.Patch(color='#4CAF50', label='Stripes (g=1)')
lab_patch = mpatches.Patch(color='#FF5722', label='Labyrinth (g≥2)')
ax.legend(handles=[spots_patch, stripes_patch, lab_patch], fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Motivic Density
ax2 = axes[1]
g_vals = list(range(0, 12))
densities = [motivic_density(g) for g in g_vals]

ax2.plot(g_vals, densities, 'ko-', linewidth=2, markersize=8)
ax2.fill_between(g_vals, densities, alpha=0.15, color='blue')

# Highlight spots and stripes
ax2.plot(0, motivic_density(0), 'o', color='#2196F3', markersize=14, zorder=5)
ax2.plot(1, motivic_density(1), 'o', color='#4CAF50', markersize=14, zorder=5)
for g in range(2, 12):
    ax2.plot(g, motivic_density(g), 'o', color='#FF5722', markersize=10, zorder=5)

ax2.annotate('Spots\n(most common)', xy=(0, 1.5), xytext=(1.5, 1.4),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='#2196F3'),
             color='#2196F3', fontweight='bold')
ax2.annotate('Stripes', xy=(1, 1.0), xytext=(2.5, 1.05),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='#4CAF50'),
             color='#4CAF50', fontweight='bold')

ax2.set_xlabel('Genus $g$', fontsize=12)
ax2.set_ylabel('Motivic Density', fontsize=12)
ax2.set_title('Why Spots Are Most Common', fontsize=13)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.8)

# Panel 3: Euler characteristic
ax3 = axes[2]
euler_chars = [2 - 2 * g for g in g_vals]
ax3.plot(g_vals, euler_chars, 's-', color='purple', linewidth=2, markersize=8)
ax3.axhline(y=0, color='k', linewidth=0.8, linestyle='-')

ax3.fill_between(g_vals, euler_chars, 0,
                 where=[e > 0 for e in euler_chars],
                 alpha=0.2, color='green', label='χ > 0 (sphere-like)')
ax3.fill_between(g_vals, euler_chars, 0,
                 where=[e <= 0 for e in euler_chars],
                 alpha=0.2, color='red', label='χ ≤ 0 (complex)')

ax3.set_xlabel('Genus $g$', fontsize=12)
ax3.set_ylabel('Euler Characteristic $\\chi = 2 - 2g$', fontsize=12)
ax3.set_title('Topology of Pattern Curves', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Annotate key points
ax3.annotate('Sphere (spots)\nχ = 2', xy=(0, 2), xytext=(2, 1.5),
             fontsize=9, arrowprops=dict(arrowstyle='->', color='purple'))
ax3.annotate('Torus (stripes)\nχ = 0', xy=(1, 0), xytext=(3, 0.5),
             fontsize=9, arrowprops=dict(arrowstyle='->', color='purple'))

plt.tight_layout()
plt.savefig('viz_genus_classification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_genus_classification.png")
