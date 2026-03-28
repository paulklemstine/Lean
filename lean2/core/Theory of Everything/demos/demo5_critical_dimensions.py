#!/usr/bin/env python3
"""
Demo 5: Critical Dimensions and the Division Algebra Connection
================================================================
Visualizes how division algebras determine spacetime dimensions
in string theory, and the connection to supersymmetry.

Generates: fig9_critical_dimensions.png, fig10_grand_unified.png
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ─── Figure 9: Critical Dimensions ─────────────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(14, 8))
ax.set_xlim(-1, 15)
ax.set_ylim(-1, 9)
ax.axis('off')

ax.text(7, 8.3, 'Why These Dimensions? Division Algebras Decide.',
        fontsize=18, fontweight='bold', ha='center', fontfamily='serif')
ax.text(7, 7.6, 'The formula: d_critical = dim(𝕂) + 2   determines spacetime',
        fontsize=12, ha='center', fontfamily='serif', fontstyle='italic',
        color='#555555')

# The four cases
cases = [
    {
        'algebra': 'ℝ', 'dim_k': 1, 'd_crit': 3,
        'color': '#4CAF50', 'x': 1.5,
        'theory': 'Chern-Simons\nTheory',
        'desc': '3D topological\nfield theories',
        'icon': '△'
    },
    {
        'algebra': 'ℂ', 'dim_k': 2, 'd_crit': 4,
        'color': '#2196F3', 'x': 5,
        'theory': 'Our\nSpacetime',
        'desc': '4D = 3+1\nMinkowski space',
        'icon': '◇'
    },
    {
        'algebra': 'ℍ', 'dim_k': 4, 'd_crit': 6,
        'color': '#9C27B0', 'x': 8.5,
        'theory': 'Calabi-Yau\nCompactification',
        'desc': '6D internal\nmanifold CY₃',
        'icon': '⬡'
    },
    {
        'algebra': '𝕆', 'dim_k': 8, 'd_crit': 10,
        'color': '#FF9800', 'x': 12,
        'theory': 'Superstring\nTheory',
        'desc': '10D = 4+6\ncritical dimension',
        'icon': '★'
    },
]

y_center = 4.5
for case in cases:
    x = case['x']
    c = case['color']
    
    # Main box
    rect = mpatches.FancyBboxPatch(
        (x - 1.2, y_center - 2.2), 2.4, 4.4,
        boxstyle="round,pad=0.15",
        facecolor=c + '15', edgecolor=c, linewidth=2.5
    )
    ax.add_patch(rect)
    
    # Algebra
    ax.text(x, y_center + 1.5, case['algebra'],
            fontsize=28, fontweight='bold', ha='center', va='center',
            fontfamily='serif', color=c)
    
    # Formula
    ax.text(x, y_center + 0.6, f"dim = {case['dim_k']}",
            fontsize=11, ha='center', va='center', fontfamily='serif',
            color='#666666')
    
    # Arrow and critical dimension
    ax.text(x, y_center - 0.1, '↓', fontsize=16, ha='center',
            va='center', color='#999999')
    ax.text(x, y_center - 0.7, f"d = {case['dim_k']} + 2 = {case['d_crit']}",
            fontsize=12, fontweight='bold', ha='center', va='center',
            fontfamily='serif', color=c)
    
    # Theory name
    ax.text(x, y_center - 1.4, case['theory'],
            fontsize=11, fontweight='bold', ha='center', va='center',
            fontfamily='serif', color='#333333')
    
    # Description
    ax.text(x, y_center - 2.0, case['desc'],
            fontsize=9, ha='center', va='top', fontfamily='serif',
            color='#888888')

# Connecting line
ax.plot([1.5, 12], [y_center + 2.5, y_center + 2.5], '-',
        color='#CCCCCC', linewidth=1)
for case in cases:
    ax.plot(case['x'], y_center + 2.5, 'o', color=case['color'],
            markersize=8, zorder=5)

# The key relationship at bottom
ax.text(7, 0.5,
        '10D superstring = 4D spacetime ⊕ 6D Calabi-Yau\n'
        '                = (ℂ + 2)  ⊕  (ℍ + 2)\n'
        '                = dim(ℂ) + dim(ℍ) + 4\n'
        '                     ↕\n'
        '         The quaternions ARE the internal dimensions!',
        fontsize=12, fontfamily='monospace', ha='center', va='center',
        color='#333333',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#F3E5F5',
                 edgecolor='#9C27B0', linewidth=1.5))

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig9_critical_dimensions.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig9_critical_dimensions.png")


# ─── Figure 10: The Grand Unified Picture ──────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(16, 12))
ax.set_xlim(-1, 15)
ax.set_ylim(-2, 12)
ax.axis('off')

# Background gradient effect
for i in range(100):
    y = -2 + i * 14/100
    alpha = 0.02
    ax.axhline(y=y, color='#6A0DAD', alpha=alpha, linewidth=10)

ax.text(7, 11, 'THE THEORY OF EVERYTHING',
        fontsize=24, fontweight='bold', ha='center', fontfamily='serif',
        color='#1a1a1a')
ax.text(7, 10.2, 'How Four Number Systems Build the Universe',
        fontsize=14, ha='center', fontfamily='serif', fontstyle='italic',
        color='#555555')

# Central structure: The Magic Square in compact form
ms_x, ms_y = 5, 6
ms_size = 0.7

ms_entries = [
    ['A₁', 'A₂', 'C₃', 'F₄'],
    ['A₂', 'A₂²', 'A₅', 'E₆'],
    ['C₃', 'A₅', 'D₆', 'E₇'],
    ['F₄', 'E₆', 'E₇', 'E₈'],
]

ms_colors = [
    ['#90CAF9', '#90CAF9', '#90CAF9', '#FFD54F'],
    ['#90CAF9', '#90CAF9', '#90CAF9', '#FFD54F'],
    ['#90CAF9', '#90CAF9', '#90CAF9', '#FFD54F'],
    ['#FFD54F', '#FFD54F', '#FFD54F', '#FFD54F'],
]

ax.text(ms_x + 1.5*ms_size, ms_y + 2.2*ms_size, 'MAGIC SQUARE',
        fontsize=12, fontweight='bold', ha='center', fontfamily='serif',
        color='#333333')

for i in range(4):
    for j in range(4):
        x = ms_x + j * ms_size
        y = ms_y - i * ms_size + ms_size
        rect = mpatches.Rectangle(
            (x, y), ms_size*0.95, ms_size*0.95,
            facecolor=ms_colors[i][j], edgecolor='#333333', linewidth=1
        )
        ax.add_patch(rect)
        ax.text(x + ms_size/2, y + ms_size/2, ms_entries[i][j],
               fontsize=8, fontweight='bold', ha='center', va='center',
               fontfamily='serif')

# Row/column labels
alg_labels = ['ℝ', 'ℂ', 'ℍ', '𝕆']
for i, lbl in enumerate(alg_labels):
    ax.text(ms_x + i*ms_size + ms_size/2, ms_y + 2*ms_size, lbl,
            fontsize=12, fontweight='bold', ha='center', fontfamily='serif')
    ax.text(ms_x - 0.3, ms_y - i*ms_size + 1.5*ms_size, lbl,
            fontsize=12, fontweight='bold', ha='center', fontfamily='serif')

# Connections from Magic Square to physics
connections = [
    # (from_x, from_y, to_x, to_y, label, color)
    (ms_x + 1.5*ms_size, ms_y + ms_size*0.5, 1, 3.5,
     'SU(3): Strong Force', '#E53935'),
    (ms_x + 3.5*ms_size, ms_y - 2.5*ms_size, 12, 3.5,
     'E₈: String Theory', '#FF9800'),
    (ms_x + 3.5*ms_size, ms_y - 0.5*ms_size, 12, 6,
     'E₆: GUT / 27 Particles', '#FF6F00'),
    (ms_x + 0.5*ms_size, ms_y + 0.5*ms_size, 1, 6,
     'SO(3): Angular Momentum', '#4CAF50'),
]

for fx, fy, tx, ty, label, color in connections:
    ax.annotate(label, xy=(fx, fy), xytext=(tx, ty),
                fontsize=10, fontweight='bold', fontfamily='serif',
                color=color, ha='center', va='center',
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5,
                               connectionstyle='arc3,rad=0.2'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor=color+'22',
                         edgecolor=color))

# Bottom: The master equation
ax.text(7, 0.5,
        r'$\mathfrak{L}(\mathbb{K}_1, \mathbb{K}_2) = '
        r'\mathrm{Der}(\mathbb{K}_1) \oplus \mathrm{Der}(\mathbb{K}_2) '
        r'\oplus (\mathrm{Im}(\mathbb{K}_1) \otimes \mathrm{Im}(\mathbb{K}_2) '
        r'\otimes \mathfrak{sl}_3)$',
        fontsize=14, ha='center', va='center', fontfamily='serif',
        color='#1a1a1a',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#FFF8E1',
                 edgecolor='#FFD700', linewidth=2))

ax.text(7, -0.7, 'This single formula generates ALL forces of nature.',
        fontsize=13, fontweight='bold', ha='center', va='center',
        fontfamily='serif', color='#6A0DAD')

# Key insight boxes
insights = [
    (2, 1.8, 'Hurwitz Theorem:\nOnly 4 division algebras\nexist: ℝ, ℂ, ℍ, 𝕆',
     '#4CAF50'),
    (7, 1.8, 'Magic Square:\n16 pairs → 16 Lie algebras\nincluding ALL exceptionals',
     '#FF9800'),
    (12, 1.8, 'Physics:\nSU(3)×SU(2)×U(1) ⊂ E₈\n= Standard Model ⊂ TOE',
     '#E53935'),
]

for x, y, text, color in insights:
    ax.text(x, y, text, fontsize=9, ha='center', va='center',
            fontfamily='serif', color='#333333',
            bbox=dict(boxstyle='round,pad=0.5', facecolor=color+'15',
                     edgecolor=color, linewidth=1.5))

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig10_grand_unified.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig10_grand_unified.png")
