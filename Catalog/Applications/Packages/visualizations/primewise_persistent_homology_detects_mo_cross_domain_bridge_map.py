"""
Visualization 3: Cross-Domain Bridge Map

Visualizes the connections between the three mathematical domains bridged
by primewise persistent homology:
- Topological Data Analysis (persistence barcodes)
- Arithmetic Geometry (point counts, Frobenius traces)
- Information Theory (barcode entropy, data processing inequality)

Shows how key theorems connect these domains.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.2, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Title
ax.text(0, 1.45, 'Cross-Domain Bridge Map',
        ha='center', va='top', fontsize=18, fontweight='bold')
ax.text(0, 1.32, 'Primewise Persistent Homology connects three mathematical worlds',
        ha='center', va='top', fontsize=12, style='italic', color='gray')

# Three domain circles
circle_radius = 0.45
domain_colors = {
    'TDA': '#2196F3',
    'AG': '#4CAF50',
    'IT': '#FF9800',
}

# Positions (equilateral triangle)
positions = {
    'TDA': (0, 0.85),
    'AG': (-0.9, -0.35),
    'IT': (0.9, -0.35),
}

# Draw circles
for domain, (x, y) in positions.items():
    circle = plt.Circle((x, y), circle_radius, color=domain_colors[domain],
                        alpha=0.15, linewidth=3, edgecolor=domain_colors[domain])
    ax.add_patch(circle)

# Domain labels
domain_labels = {
    'TDA': ('Topological\nData Analysis', [
        'Persistence Barcodes',
        'Filtered Complexes',
        'Birth-Death Pairs',
        'Bottleneck Distance',
    ]),
    'AG': ('Arithmetic\nGeometry', [
        'Calabi-Yau Threefolds',
        'Hecke Eigenvalues',
        'Frobenius Traces',
        'Point Counts over F_p',
    ]),
    'IT': ('Information\nTheory', [
        'Shannon Entropy',
        'Data Processing Ineq.',
        'Channel Capacity',
        'Mutual Information',
    ]),
}

for domain, (x, y) in positions.items():
    label, items = domain_labels[domain]
    ax.text(x, y + 0.15, label, ha='center', va='center',
            fontsize=14, fontweight='bold', color=domain_colors[domain])
    for i, item in enumerate(items):
        ax.text(x, y - 0.05 - i * 0.1, f'• {item}', ha='center', va='center',
                fontsize=8, color='#333')

# Draw bridge arrows with theorem labels
bridges = [
    ('TDA', 'AG', 'Barcode → Betti\nnumbers (Thm A)', '#1565C0'),
    ('AG', 'IT', 'Point counts →\nEntropy bound', '#2E7D32'),
    ('IT', 'TDA', 'DPI for\nbarcodes (Thm C)', '#E65100'),
]

for domain1, domain2, label, color in bridges:
    x1, y1 = positions[domain1]
    x2, y2 = positions[domain2]

    # Midpoint
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2

    # Shorten arrows to not overlap circles
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    ux, uy = dx/length, dy/length

    ax.annotate('', xy=(x2 - ux * circle_radius, y2 - uy * circle_radius),
                xytext=(x1 + ux * circle_radius, y1 + uy * circle_radius),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

    # Label at midpoint (offset perpendicular to arrow)
    nx, ny = -uy * 0.15, ux * 0.15
    ax.text(mx + nx, my + ny, label, ha='center', va='center',
            fontsize=9, fontweight='bold', color=color,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                     edgecolor=color, alpha=0.9))

# Central theorem
center_x, center_y = 0, 0.1
ax.text(center_x, center_y, 'Main Theorem:\nHasse-bounded pairings\n⟹ Modularity-compatible\npoint counts',
        ha='center', va='center', fontsize=10, fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFEB3B',
                 edgecolor='#F57F17', alpha=0.9, linewidth=2))

# Bottom: Key formula
ax.text(0, -1.05, r'$a_p = (b_1 + b_2) - (d_1 + d_2) + p + 1$',
        ha='center', va='center', fontsize=14, fontweight='bold',
        color='#333',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8EAF6',
                 edgecolor='#3F51B5', alpha=0.8))
ax.text(0, -1.18, 'The Frobenius trace is encoded in the persistence pairing',
        ha='center', va='center', fontsize=10, style='italic', color='gray')

plt.savefig('viz_cross_domain.png', dpi=150, bbox_inches='tight')
print("Saved viz_cross_domain.png")
