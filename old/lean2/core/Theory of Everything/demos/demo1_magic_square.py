#!/usr/bin/env python3
"""
Demo 1: The Freudenthal-Tits Magic Square
==========================================
Visualizes the 4×4 Magic Square of Lie algebras arising from
pairs of division algebras (ℝ, ℂ, ℍ, 𝕆).

Generates: fig1_magic_square.png, fig2_dimension_growth.png
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ─── The Magic Square Data ───────────────────────────────────────────────────

algebras = ['ℝ', 'ℂ', 'ℍ', '𝕆']
algebra_dims = [1, 2, 4, 8]

# Magic Square entries: (Name, Dimension, Rank, Cartan type, is_exceptional)
magic_square = [
    # Row ℝ
    [('SO(3)',   3,  1, 'A₁', False), ('SU(3)',   8,  2, 'A₂', False),
     ('Sp(3)',  21,  3, 'C₃', False), ('F₄',    52,  4, 'F₄', True)],
    # Row ℂ
    [('SU(3)',   8,  2, 'A₂', False), ('SU(3)²', 16,  4, 'A₂⊕A₂', False),
     ('SU(6)', 35,  5, 'A₅', False), ('E₆',    78,  6, 'E₆', True)],
    # Row ℍ
    [('Sp(3)',  21,  3, 'C₃', False), ('SU(6)', 35,  5, 'A₅', False),
     ('SO(12)', 66,  6, 'D₆', False), ('E₇',   133,  7, 'E₇', True)],
    # Row 𝕆
    [('F₄',    52,  4, 'F₄', True), ('E₆',    78,  6, 'E₆', True),
     ('E₇',   133,  7, 'E₇', True), ('E₈',   248,  8, 'E₈', True)],
]

# ─── Figure 1: The Magic Square Visualization ─────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(12, 10))
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-0.5, 5.0)
ax.set_aspect('equal')
ax.axis('off')

# Title
ax.text(2.0, 4.7, 'The Freudenthal–Tits Magic Square',
        fontsize=20, fontweight='bold', ha='center', va='center',
        fontfamily='serif')
ax.text(2.0, 4.35, 'Division Algebras → Lie Algebras → Forces of Nature',
        fontsize=12, ha='center', va='center', fontfamily='serif',
        fontstyle='italic', color='#555555')

# Color scheme
color_classical = '#E8F4FD'  # Light blue for classical
color_exceptional = '#FFE4B5'  # Gold for exceptional
color_border_classical = '#2196F3'
color_border_exceptional = '#FF8C00'

# Draw column headers
for j, alg in enumerate(algebras):
    ax.text(j + 0.5, 3.85, alg, fontsize=18, fontweight='bold',
            ha='center', va='center', fontfamily='serif',
            color='#333333')

# Draw row headers
for i, alg in enumerate(algebras):
    ax.text(-0.3, 2.9 - i, alg, fontsize=18, fontweight='bold',
            ha='center', va='center', fontfamily='serif',
            color='#333333')

# Draw cells
for i in range(4):
    for j in range(4):
        name, dim, rank, cartan, exceptional = magic_square[i][j]
        x = j + 0.1
        y = 2.5 - i
        
        # Cell background
        color = color_exceptional if exceptional else color_classical
        border = color_border_exceptional if exceptional else color_border_classical
        lw = 3 if exceptional else 1.5
        
        rect = mpatches.FancyBboxPatch(
            (x, y), 0.8, 0.8,
            boxstyle="round,pad=0.05",
            facecolor=color, edgecolor=border, linewidth=lw
        )
        ax.add_patch(rect)
        
        # Lie algebra name
        ax.text(x + 0.4, y + 0.55, name,
                fontsize=13, fontweight='bold', ha='center', va='center',
                fontfamily='serif', color='#1a1a1a')
        
        # Dimension
        ax.text(x + 0.4, y + 0.3, f'dim = {dim}',
                fontsize=9, ha='center', va='center',
                fontfamily='serif', color='#666666')
        
        # Cartan type
        ax.text(x + 0.4, y + 0.12, cartan,
                fontsize=8, ha='center', va='center',
                fontfamily='serif', color='#999999', fontstyle='italic')

# Legend
legend_elements = [
    mpatches.Patch(facecolor=color_exceptional, edgecolor=color_border_exceptional,
                   linewidth=2, label='Exceptional (from octonions)'),
    mpatches.Patch(facecolor=color_classical, edgecolor=color_border_classical,
                   linewidth=1.5, label='Classical'),
]
ax.legend(handles=legend_elements, loc='lower center', fontsize=11,
          frameon=True, fancybox=True, shadow=True, ncol=2,
          bbox_to_anchor=(0.5, -0.08))

# Physics annotations
annotations = [
    (0.5, 1.0, 'SU(3): Strong Force', '#FF4444', (0.5, 3.3)),
    (3.5, -0.15, 'E₈: Theory of Everything', '#FF8C00', (3.5, 0.0)),
]

# Annotate SU(3) at (ℝ,ℂ)
ax.annotate('Strong Force\n(QCD)', xy=(1.5, 3.3), xytext=(1.5, 4.05),
            fontsize=9, ha='center', va='center', color='#CC0000',
            fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#CC0000', lw=1.5))

# Annotate E₈ at (𝕆,𝕆) 
ax.annotate('Theory of\nEverything?', xy=(3.5, 0.15), xytext=(4.5, -0.3),
            fontsize=9, ha='center', va='center', color='#FF8C00',
            fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#FF8C00', lw=1.5))

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig1_magic_square.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig1_magic_square.png")


# ─── Figure 2: Dimension Growth Along Octonionic Column ───────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Bar chart of dimensions along octonionic column
oct_column = ['F₄\n(ℝ,𝕆)', 'E₆\n(ℂ,𝕆)', 'E₇\n(ℍ,𝕆)', 'E₈\n(𝕆,𝕆)']
oct_dims = [52, 78, 133, 248]
oct_ranks = [4, 6, 7, 8]

colors = ['#FF6B35', '#FF8C42', '#FFA64D', '#FFD700']
bars = ax1.bar(oct_column, oct_dims, color=colors, edgecolor='#333',
               linewidth=1.5, width=0.6)

# Add dimension labels on bars
for bar, dim, rank in zip(bars, oct_dims, oct_ranks):
    ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 5,
             f'{dim}', ha='center', va='bottom', fontsize=14,
             fontweight='bold', fontfamily='serif')
    ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height()/2,
             f'rank {rank}', ha='center', va='center', fontsize=10,
             fontfamily='serif', color='white', fontweight='bold')

ax1.set_ylabel('Dimension of Lie Algebra', fontsize=13, fontfamily='serif')
ax1.set_title('The Octonionic Column\n(Exceptional Lie Groups)', fontsize=15,
              fontweight='bold', fontfamily='serif')
ax1.set_ylim(0, 280)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# Right: The full 4×4 dimension heatmap
dim_matrix = np.array([
    [3, 8, 21, 52],
    [8, 16, 35, 78],
    [21, 35, 66, 133],
    [52, 78, 133, 248]
])

im = ax2.imshow(dim_matrix, cmap='YlOrRd', aspect='equal')
ax2.set_xticks(range(4))
ax2.set_yticks(range(4))
ax2.set_xticklabels(algebras, fontsize=14, fontfamily='serif')
ax2.set_yticklabels(algebras, fontsize=14, fontfamily='serif')
ax2.set_title('Dimension Heatmap of Magic Square', fontsize=15,
              fontweight='bold', fontfamily='serif')

# Add text annotations
for i in range(4):
    for j in range(4):
        name = magic_square[i][j][0]
        dim = magic_square[i][j][1]
        exceptional = magic_square[i][j][4]
        color = 'white' if dim > 50 else 'black'
        weight = 'bold' if exceptional else 'normal'
        ax2.text(j, i - 0.15, name, ha='center', va='center',
                fontsize=10, color=color, fontweight=weight, fontfamily='serif')
        ax2.text(j, i + 0.2, str(dim), ha='center', va='center',
                fontsize=9, color=color, fontfamily='serif')

plt.colorbar(im, ax=ax2, label='Dimension', shrink=0.8)
plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig2_dimension_growth.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig2_dimension_growth.png")
