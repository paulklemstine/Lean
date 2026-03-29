#!/usr/bin/env python3
"""
Demo 3: E₈ Root System & Symmetry Breaking Chain
==================================================
Visualizes the E₈ root system projected to 2D (Petrie projection),
and the symmetry breaking chain from E₈ to the Standard Model.

Generates: fig5_e8_projection.png, fig6_symmetry_breaking.png
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product

# ─── E₈ Root System ──────────────────────────────────────────────────────────

def generate_e8_roots():
    """Generate all 240 roots of E₈."""
    roots = []
    
    # Type 1: All permutations of (±1, ±1, 0, 0, 0, 0, 0, 0) — 112 roots
    for i in range(8):
        for j in range(i+1, 8):
            for si in [1, -1]:
                for sj in [1, -1]:
                    root = [0]*8
                    root[i] = si
                    root[j] = sj
                    roots.append(root)
    
    # Type 2: (±1/2, ±1/2, ..., ±1/2) with even number of minus signs — 128 roots
    for signs in product([0.5, -0.5], repeat=8):
        if sum(1 for s in signs if s < 0) % 2 == 0:
            roots.append(list(signs))
    
    return np.array(roots)

def petrie_projection(roots):
    """Project 8D roots to 2D using Petrie projection (Coxeter plane)."""
    # The Petrie projection uses angles related to the Coxeter number h=30
    # For E₈, we project onto a plane where the symmetry appears as 30-fold
    n = roots.shape[1]
    angles = np.array([k * np.pi / 15 for k in range(n)])  # h/2 = 15
    
    # Projection matrix
    proj_x = np.cos(angles)
    proj_y = np.sin(angles)
    
    x = roots @ proj_x
    y = roots @ proj_y
    
    return x, y


# Generate and project
roots = generate_e8_roots()
print(f"Generated {len(roots)} E₈ roots")

x, y = petrie_projection(roots)

# Compute distances from origin for coloring
distances = np.sqrt(x**2 + y**2)
norm_dist = (distances - distances.min()) / (distances.max() - distances.min())

# ─── Figure 5: E₈ Petrie Projection ──────────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(12, 12))
ax.set_aspect('equal')

# Background
fig.patch.set_facecolor('#0a0a2e')
ax.set_facecolor('#0a0a2e')

# Color by distance — golden to deep blue
colors = plt.cm.magma(norm_dist * 0.8 + 0.1)

# Draw lines between nearby roots (connections)
threshold = 0.5
for i in range(len(x)):
    for j in range(i+1, len(x)):
        dx = x[i] - x[j]
        dy = y[i] - y[j]
        d = np.sqrt(dx**2 + dy**2)
        if d < threshold:
            alpha = max(0.02, 0.15 * (1 - d/threshold))
            ax.plot([x[i], x[j]], [y[i], y[j]], '-',
                   color='#FFD700', alpha=alpha, linewidth=0.3)

# Plot roots
scatter = ax.scatter(x, y, c=norm_dist, cmap='magma', s=15, zorder=5,
                     edgecolors='white', linewidths=0.3, alpha=0.9)

# Title and labels
ax.set_title('E₈ Root System — Petrie Projection\n240 roots in 8 dimensions, '
             'projected to the Coxeter plane',
             fontsize=16, fontweight='bold', fontfamily='serif',
             color='white', pad=20)

# Stats box
stats_text = (
    f'Roots: 240\n'
    f'Dimension: 8\n'
    f'Rank: 8\n'
    f'Coxeter number: 30\n'
    f'|Weyl group|: 696,729,600\n'
    f'dim(E₈) = 240 + 8 = 248'
)
props = dict(boxstyle='round,pad=0.8', facecolor='#1a1a4e',
             edgecolor='#FFD700', alpha=0.9)
ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
        fontsize=11, fontfamily='monospace', color='#FFD700',
        verticalalignment='top', bbox=props)

ax.set_xlim(min(x)*1.15, max(x)*1.15)
ax.set_ylim(min(y)*1.15, max(y)*1.15)
ax.tick_params(colors='white')
for spine in ax.spines.values():
    spine.set_color('#333366')

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig5_e8_projection.png', dpi=200,
            bbox_inches='tight', facecolor='#0a0a2e')
plt.close()
print("✅ Saved fig5_e8_projection.png")


# ─── Figure 6: Symmetry Breaking Chain ─────────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(16, 8))
ax.set_xlim(-0.5, 16)
ax.set_ylim(-1, 7)
ax.axis('off')

# Title
ax.text(8, 6.5, 'The Symmetry Breaking Chain',
        fontsize=20, fontweight='bold', ha='center', fontfamily='serif')
ax.text(8, 5.9, 'From E₈ (Theory of Everything) to the Standard Model',
        fontsize=12, ha='center', fontfamily='serif', fontstyle='italic',
        color='#555555')

# Chain data
chain = [
    {'name': 'E₈', 'dim': 248, 'x': 1.5, 'color': '#FFD700',
     'desc': 'Heterotic\nstring theory', 'energy': '10¹⁹ GeV'},
    {'name': 'E₇', 'dim': 133, 'x': 4.0, 'color': '#FFA726',
     'desc': 'Extended\nsupergravity', 'energy': '~10¹⁸ GeV'},
    {'name': 'E₆', 'dim': 78, 'x': 6.5, 'color': '#FF7043',
     'desc': 'GUT with\n27 fermions', 'energy': '~10¹⁶ GeV'},
    {'name': 'SO(10)', 'dim': 45, 'x': 9.0, 'color': '#AB47BC',
     'desc': 'Pati-Salam\nunification', 'energy': '~10¹⁵ GeV'},
    {'name': 'SU(5)', 'dim': 24, 'x': 11.5, 'color': '#5C6BC0',
     'desc': 'Georgi-\nGlashow GUT', 'energy': '~10¹⁴ GeV'},
    {'name': 'SU(3)×SU(2)×U(1)', 'dim': 12, 'x': 14.5, 'color': '#26A69A',
     'desc': 'Standard\nModel!', 'energy': '~10² GeV'},
]

y_main = 3.5
for i, data in enumerate(chain):
    x = data['x']
    c = data['color']
    
    # Circle with dimension proportional to sqrt(dim)
    r = 0.15 * np.sqrt(data['dim']) / np.sqrt(12)
    r = min(r, 0.9)
    circle = plt.Circle((x, y_main), r, facecolor=c + '33',
                        edgecolor=c, linewidth=3, zorder=5)
    ax.add_patch(circle)
    
    # Name
    ax.text(x, y_main, data['name'], fontsize=12 if i < 5 else 9,
            fontweight='bold', ha='center', va='center',
            fontfamily='serif', color=c)
    
    # Dimension below
    ax.text(x, y_main - r - 0.4, f'dim = {data["dim"]}',
            fontsize=10, ha='center', va='center',
            fontfamily='serif', color='#666666')
    
    # Description above
    ax.text(x, y_main + r + 0.5, data['desc'],
            fontsize=9, ha='center', va='center',
            fontfamily='serif', color=c, fontweight='bold')
    
    # Energy scale
    ax.text(x, y_main - r - 0.8, data['energy'],
            fontsize=8, ha='center', va='center',
            fontfamily='serif', color='#999999', fontstyle='italic')
    
    # Arrow to next
    if i < len(chain) - 1:
        next_x = chain[i+1]['x']
        next_r = 0.15 * np.sqrt(chain[i+1]['dim']) / np.sqrt(12)
        next_r = min(next_r, 0.9)
        ax.annotate('', xy=(next_x - next_r - 0.15, y_main),
                    xytext=(x + r + 0.15, y_main),
                    arrowprops=dict(arrowstyle='->', color='#666666',
                                   lw=2, connectionstyle='arc3,rad=0'))
        # Label: symmetry breaking
        mid_x = (x + next_x) / 2
        ax.text(mid_x, y_main + 0.15, '⊃', fontsize=14, ha='center',
                va='center', color='#666666')

# Bottom annotation
ax.text(8, 0.5, 'Each arrow = spontaneous symmetry breaking\n'
        'Lost symmetries become massive gauge bosons (W±, Z⁰, X, Y...)\n'
        'The Standard Model is what remains after E₈ breaks 236 of its 248 symmetries',
        fontsize=11, ha='center', va='center', fontfamily='serif',
        color='#333333',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#F5F5F5',
                 edgecolor='#CCCCCC'))

# Division algebra annotation on the left
ax.text(0.2, 5.2, 'Magic Square\nColumn:', fontsize=10, fontweight='bold',
        ha='center', va='center', fontfamily='serif', color='#888888')
ms_labels = ['𝕆⊗𝕆', 'ℍ⊗𝕆', 'ℂ⊗𝕆', '', '', '']
for i, lbl in enumerate(ms_labels):
    if lbl:
        ax.text(chain[i]['x'], y_main + 1.8, lbl,
                fontsize=9, ha='center', va='center',
                fontfamily='serif', color='#888888', fontstyle='italic')

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig6_symmetry_breaking.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig6_symmetry_breaking.png")
