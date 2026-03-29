#!/usr/bin/env python3
"""
Demo 2: The Four Division Algebras & Cayley-Dickson Construction
=================================================================
Visualizes ℝ, ℂ, ℍ, 𝕆 and the Cayley-Dickson doubling process.
Shows how each step loses a property but gains physics.

Generates: fig3_cayley_dickson.png, fig4_octonion_multiplication.png
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ─── Figure 3: Cayley-Dickson Construction ─────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(16, 9))
ax.set_xlim(-1, 17)
ax.set_ylim(-2, 8)
ax.axis('off')

# Title
ax.text(8, 7.5, 'The Cayley-Dickson Construction',
        fontsize=22, fontweight='bold', ha='center', fontfamily='serif')
ax.text(8, 6.9, 'Each doubling creates a richer algebra — and a new force of nature',
        fontsize=12, ha='center', fontfamily='serif', fontstyle='italic',
        color='#555555')

# Define the four algebras
algebras_data = [
    {
        'name': 'ℝ', 'full_name': 'Real Numbers',
        'dim': 1, 'x': 1.5, 'color': '#4CAF50',
        'properties': ['Ordered', 'Commutative', 'Associative', 'Alternative'],
        'physics': 'Measurement\nClassical mechanics',
        'lost': None,
        'basis': '{1}'
    },
    {
        'name': 'ℂ', 'full_name': 'Complex Numbers',
        'dim': 2, 'x': 5.5, 'color': '#2196F3',
        'properties': ['Commutative', 'Associative', 'Alternative'],
        'physics': 'Phase → U(1)\nElectromagnetism',
        'lost': 'Ordering',
        'basis': '{1, i}'
    },
    {
        'name': 'ℍ', 'full_name': 'Quaternions',
        'dim': 4, 'x': 9.5, 'color': '#9C27B0',
        'properties': ['Associative', 'Alternative'],
        'physics': 'Chirality → SU(2)\nWeak nuclear force',
        'lost': 'Commutativity',
        'basis': '{1, i, j, k}'
    },
    {
        'name': '𝕆', 'full_name': 'Octonions',
        'dim': 8, 'x': 13.5, 'color': '#FF9800',
        'properties': ['Alternative'],
        'physics': 'Color → SU(3)\nStrong nuclear force',
        'lost': 'Associativity',
        'basis': '{1,e₁,...,e₇}'
    },
]

y_center = 3.5
box_w = 3.2
box_h = 4.8

for data in algebras_data:
    x = data['x']
    c = data['color']
    
    # Main box
    rect = mpatches.FancyBboxPatch(
        (x - box_w/2, y_center - box_h/2), box_w, box_h,
        boxstyle="round,pad=0.15",
        facecolor=c + '15', edgecolor=c, linewidth=2.5
    )
    ax.add_patch(rect)
    
    # Algebra symbol
    ax.text(x, y_center + 1.8, data['name'],
            fontsize=32, fontweight='bold', ha='center', va='center',
            fontfamily='serif', color=c)
    
    # Full name
    ax.text(x, y_center + 1.1, data['full_name'],
            fontsize=10, ha='center', va='center', fontfamily='serif',
            color='#333333')
    
    # Dimension
    ax.text(x, y_center + 0.55, f"dim = {data['dim']}",
            fontsize=11, ha='center', va='center', fontfamily='serif',
            color='#666666', fontweight='bold')
    
    # Basis
    ax.text(x, y_center + 0.1, data['basis'],
            fontsize=9, ha='center', va='center', fontfamily='serif',
            color='#888888')
    
    # Properties (with checkmarks)
    all_props = ['Ordered', 'Commutative', 'Associative', 'Alternative']
    for k, prop in enumerate(all_props):
        has_it = prop in data['properties']
        symbol = '✓' if has_it else '✗'
        clr = '#2E7D32' if has_it else '#C62828'
        ax.text(x - 0.9, y_center - 0.5 - k*0.35, f'{symbol} {prop}',
                fontsize=8.5, ha='left', va='center', fontfamily='serif',
                color=clr)
    
    # Physics connection
    ax.text(x, y_center - 2.1, data['physics'],
            fontsize=9, ha='center', va='center', fontfamily='serif',
            color=c, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=c+'22',
                     edgecolor=c, linewidth=1))

# Arrows between algebras
arrow_props = dict(arrowstyle='->', color='#333333', lw=2,
                   connectionstyle='arc3,rad=0')
for i in range(3):
    x1 = algebras_data[i]['x'] + box_w/2 + 0.05
    x2 = algebras_data[i+1]['x'] - box_w/2 - 0.05
    xmid = (x1 + x2) / 2
    
    ax.annotate('', xy=(x2, y_center), xytext=(x1, y_center),
                arrowprops=arrow_props)
    
    # Label: what was lost
    lost = algebras_data[i+1]['lost']
    ax.text(xmid, y_center + 0.4, '×2', fontsize=11, fontweight='bold',
            ha='center', va='center', fontfamily='serif', color='#333333')
    ax.text(xmid, y_center - 0.4, f'lose\n{lost}',
            fontsize=8, ha='center', va='center', fontfamily='serif',
            color='#C62828', fontstyle='italic')

# The "STOP" sign after octonions
ax.text(15.8, y_center, '🚫', fontsize=30, ha='center', va='center')
ax.text(15.8, y_center - 0.8, 'Sedenions\nhave zero\ndivisors!',
        fontsize=8, ha='center', va='center', fontfamily='serif',
        color='#C62828', fontweight='bold')

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig3_cayley_dickson.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig3_cayley_dickson.png")


# ─── Figure 4: Octonion Multiplication Table (Fano Plane) ──────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

# Left: Fano plane visualization
ax1.set_xlim(-1.8, 1.8)
ax1.set_ylim(-1.8, 1.8)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title('The Fano Plane\nMultiplication Rules of 𝕆',
              fontsize=15, fontweight='bold', fontfamily='serif')

# 7 points of the Fano plane
# Standard labeling: e1,...,e7
# Triples: (1,2,3), (1,4,5), (1,7,6), (2,4,6), (2,5,7), (3,4,7), (3,6,5)
# Using the convention eᵢeⱼ = eₖ for oriented triple (i,j,k)

angles = np.linspace(np.pi/2, np.pi/2 + 2*np.pi, 7, endpoint=False)
r_outer = 1.3
points = {}
labels = ['e₁', 'e₂', 'e₃', 'e₄', 'e₅', 'e₆', 'e₇']
colors_fano = ['#E53935', '#1E88E5', '#43A047', '#FF8F00',
               '#8E24AA', '#00ACC1', '#F4511E']

for idx in range(7):
    x = r_outer * np.cos(angles[idx])
    y = r_outer * np.sin(angles[idx])
    points[idx+1] = (x, y)
    
    ax1.plot(x, y, 'o', markersize=20, color=colors_fano[idx],
             zorder=5, markeredgecolor='white', markeredgewidth=2)
    
    # Label slightly outward
    lx = 1.25 * x / r_outer * (r_outer + 0.35)
    ly = 1.25 * y / r_outer * (r_outer + 0.35)
    ax1.text(lx, ly, labels[idx], fontsize=14, fontweight='bold',
             ha='center', va='center', fontfamily='serif',
             color=colors_fano[idx])

# The 7 lines of the Fano plane (including the inscribed circle)
# Triples (oriented): (1,2,4), (2,3,5), (3,4,6), (4,5,7), (5,6,1), (6,7,2), (7,1,3)
# Alternative standard: (1,2,3), (1,4,5), (2,4,6), (3,4,7), (1,6,7), (2,5,7), (3,5,6)
lines = [(1,2,4), (2,3,5), (3,4,6), (4,5,7), (5,6,1), (6,7,2), (7,1,3)]

for triple in lines:
    for k in range(3):
        i, j = triple[k], triple[(k+1) % 3]
        x1, y1 = points[i]
        x2, y2 = points[j]
        ax1.plot([x1, x2], [y1, y2], '-', color='#555555',
                linewidth=1.5, zorder=1)

# Draw the inscribed circle (one of the "lines" is a circle)
theta = np.linspace(0, 2*np.pi, 100)
r_circle = r_outer * np.sin(np.pi/7) / np.sin(3*np.pi/7) * 0.95
# Actually, let's just draw a nice circle through some middle points
circle_r = 0.62
ax1.plot(circle_r * np.cos(theta), circle_r * np.sin(theta),
         '--', color='#555555', linewidth=1.5, zorder=1)

ax1.text(0, -1.7, 'eᵢ · eⱼ = eₖ  along each oriented line',
         fontsize=10, ha='center', fontfamily='serif', fontstyle='italic',
         color='#555555')

# Right: Multiplication table
ax2.axis('off')
ax2.set_title('Octonion Multiplication Table',
              fontsize=15, fontweight='bold', fontfamily='serif')

# Create multiplication table
# Using convention: e_i * e_j
# Standard octonion multiplication (index doubling)
mult_table = np.array([
    #  e1  e2  e3  e4  e5  e6  e7
    [ -1,  4, -7,  2, -6,  3, -5],  # e1 * 
    [ -4, -1,  5, -1,  3, -7,  6],  # e2 *
    [  7, -5, -1,  6, -2, -4,  1],  # e3 *
    [ -2,  1, -6, -1,  7,  5, -3],  # e4 *
    [  6, -3,  2, -7, -1, -1,  4],  # e5 *
    [ -3,  7,  4, -5,  1, -1, -2],  # e6 *
    [  5, -6, -1,  3, -4,  2, -1],  # e7 *
])

# Simple display
table_data = [
    ['·',  'e₁', 'e₂', 'e₃', 'e₄', 'e₅', 'e₆', 'e₇'],
    ['e₁', '-1',  'e₄', 'e₇', '-e₂', 'e₆','-e₃','-e₅'],
    ['e₂', '-e₄', '-1', 'e₅', 'e₁', '-e₃','e₇', '-e₆'],
    ['e₃', '-e₇','-e₅', '-1', 'e₆', 'e₂', 'e₄', '-e₁'],
    ['e₄', 'e₂', '-e₁','-e₆', '-1', 'e₇', '-e₅','e₃'],
    ['e₅', '-e₆','e₃', '-e₂','e₇',  '-1', 'e₁', '-e₄'],  
    ['e₆', 'e₃', '-e₇', '-e₄','e₅', '-e₁', '-1', 'e₂'],
    ['e₇', 'e₅',  'e₆', 'e₁','-e₃', 'e₄', '-e₂', '-1'],
]

# Draw as a colored grid
cell_size = 0.16
x0, y0 = 0.08, 0.92

for i, row in enumerate(table_data):
    for j, val in enumerate(row):
        x = x0 + j * cell_size
        y = y0 - i * cell_size
        
        # Color coding
        if i == 0 or j == 0:
            bg = '#E0E0E0'
            fontw = 'bold'
            clr = '#333333'
        elif val == '-1':
            bg = '#FFCDD2'
            fontw = 'bold'
            clr = '#C62828'
        elif val.startswith('-'):
            bg = '#FFF3E0'
            fontw = 'normal'
            clr = '#E65100'
        else:
            bg = '#E8F5E9'
            fontw = 'normal'
            clr = '#2E7D32'
        
        ax2.text(x, y, val, fontsize=10, ha='center', va='center',
                fontfamily='serif', fontweight=fontw, color=clr,
                transform=ax2.transAxes,
                bbox=dict(boxstyle='round,pad=0.3', facecolor=bg,
                         edgecolor='#BDBDBD', linewidth=0.5))

ax2.text(0.5, 0.05, 'Non-associativity: (eᵢeⱼ)eₖ ≠ eᵢ(eⱼeₖ) in general\n'
         'But alternativity holds: (eᵢeᵢ)eⱼ = eᵢ(eᵢeⱼ)',
         fontsize=10, ha='center', va='center', fontfamily='serif',
         fontstyle='italic', color='#555555', transform=ax2.transAxes)

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig4_octonion_multiplication.png',
            dpi=200, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig4_octonion_multiplication.png")
