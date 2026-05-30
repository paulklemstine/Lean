#!/usr/bin/env python3
"""
Visualization: The Kesten Duality Triangle

Illustrates the triangle of equivalences at the heart of hyperbolic number theory:
  Exponential Growth ↔ Spectral Gap ↔ Non-Amenability

Shows how these three properties vary together as the number of generators changes,
demonstrating they are three faces of a single phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle
import matplotlib.patches as mpatches

fig = plt.figure(figsize=(12, 7))

# Create main axes for the triangle diagram
ax_main = fig.add_axes([0.05, 0.35, 0.55, 0.6])
ax_main.set_xlim(-1.8, 1.8)
ax_main.set_ylim(-1.2, 1.5)
ax_main.set_aspect('equal')
ax_main.axis('off')

# Triangle vertices
vertices = {
    'growth': (0, 1.2),
    'spectral': (-1.3, -0.6),
    'amenability': (1.3, -0.6),
}

# Draw triangle edges with arrows
edge_style = dict(arrowstyle='<->', color='#333333', linewidth=2.5, 
                  connectionstyle='arc3,rad=0.1')

for (v1, v2) in [('growth', 'spectral'), ('spectral', 'amenability'), ('amenability', 'growth')]:
    p1, p2 = vertices[v1], vertices[v2]
    ax_main.annotate('', xy=p2, xytext=p1, arrowprops=edge_style)

# Draw vertex circles
for name, (x, y) in vertices.items():
    circle = Circle((x, y), 0.35, fill=True, facecolor='white', edgecolor='#1565C0', 
                    linewidth=3, zorder=5)
    ax_main.add_patch(circle)

# Vertex labels
labels = {
    'growth': ('Exponential\nGrowth', '#E53935'),
    'spectral': ('Spectral\nGap', '#1565C0'),
    'amenability': ('Non-\nAmenability', '#2E7D32'),
}

for name, ((x, y), (text, color)) in zip(vertices.items(), 
    [(vertices[k], labels[k]) for k in vertices]):
    ax_main.text(x, y, text, ha='center', va='center', fontsize=11, 
                fontweight='bold', color=color, zorder=6)

# Edge labels (the key formulas)
edge_labels = [
    ((-0.9, 0.5), 'ρ = √λ/k', '#333'),
    ((0, -0.85), 'h ≥ (1−ρ)/2', '#333'),
    ((0.9, 0.5), 'λ = 2k−1', '#333'),
]

for (x, y), text, color in edge_labels:
    ax_main.text(x, y, text, ha='center', va='center', fontsize=10, 
                color=color, style='italic',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='#FFF9C4', 
                         edgecolor='#F9A825', alpha=0.9))

# Title
ax_main.text(0, 1.7, 'The Kesten Duality Triangle', ha='center', va='center',
            fontsize=16, fontweight='bold', color='#1A237E')

# Center label
ax_main.text(0, 0.15, 'KESTEN\nDUALITY', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#FF6F00', alpha=0.7)

# --- Right panel: Quantitative comparison ---
ax_right = fig.add_axes([0.63, 0.12, 0.33, 0.82])

ks = np.arange(2, 12)
growth_rates = 2 * ks - 1
spectral_radii = np.sqrt(growth_rates) / ks
spectral_gaps = 1 - spectral_radii
cheeger_bounds = spectral_gaps / 2

x = np.arange(len(ks))
width = 0.25

bars1 = ax_right.bar(x - width, np.log(growth_rates), width, color='#E53935', alpha=0.8, label='log(λ)')
bars2 = ax_right.bar(x, spectral_gaps, width, color='#1565C0', alpha=0.8, label='1 − ρ')
bars3 = ax_right.bar(x + width, cheeger_bounds, width, color='#2E7D32', alpha=0.8, label='h ≥ ...')

ax_right.set_xlabel('Number of Generators k', fontsize=12)
ax_right.set_ylabel('Value', fontsize=12)
ax_right.set_title('Quantitative Kesten Duality\nfor F₂ through F₁₁', fontsize=13, fontweight='bold')
ax_right.set_xticks(x)
ax_right.set_xticklabels([str(k) for k in ks])
ax_right.legend(fontsize=10, loc='upper right')
ax_right.grid(True, alpha=0.3, axis='y')

# Highlight F₂
ax_right.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax_right.annotate('F₂', xy=(0, 0), fontsize=10, fontweight='bold', color='gray',
                 xytext=(0, -0.15), ha='center')

plt.savefig('viz_kesten_triangle.png', dpi=150, bbox_inches='tight')
print("Saved viz_kesten_triangle.png")
