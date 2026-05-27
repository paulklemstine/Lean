#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Diagram

Illustrates the core confluence property of the STTC:
when a term can be reduced two different ways, both paths
eventually converge to equivalent results (modulo AC).

Uses matplotlib to create a publication-quality diagram.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ============================================================================
# Left panel: The Confluence Diamond
# ============================================================================
ax = axes[0]
ax.set_xlim(-3, 3)
ax.set_ylim(-3.5, 3.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Confluence Diamond\n(STTC Rewrite System)', fontsize=14, fontweight='bold')

# Nodes
nodes = {
    't': (0, 3),
    't₁': (-2, 0),
    't₂': (2, 0),
    't₃': (-1, -2.5),
    't₄': (1, -2.5),
}

colors = {
    't': '#2196F3',
    't₁': '#4CAF50',
    't₂': '#FF9800',
    't₃': '#9C27B0',
    't₄': '#9C27B0',
}

for name, (x, y) in nodes.items():
    circle = plt.Circle((x, y), 0.4, color=colors[name], alpha=0.8, zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, name, ha='center', va='center', fontsize=12,
            fontweight='bold', color='white', zorder=6)

# Arrows
arrow_style = dict(arrowstyle='->', color='#333', lw=2, connectionstyle='arc3,rad=0.1')

# t → t₁ (β-reduction)
ax.annotate('', xy=(-1.7, 0.3), xytext=(-0.3, 2.7),
            arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2.5))
ax.text(-1.5, 1.7, 'β-step', fontsize=10, color='#4CAF50', fontweight='bold', rotation=55)

# t → t₂ (dist-reduction)
ax.annotate('', xy=(1.7, 0.3), xytext=(0.3, 2.7),
            arrowprops=dict(arrowstyle='->', color='#FF9800', lw=2.5))
ax.text(0.7, 1.7, 'dist-step', fontsize=10, color='#FF9800', fontweight='bold', rotation=-55)

# t₁ →* t₃
ax.annotate('', xy=(-1.1, -2.1), xytext=(-1.85, -0.4),
            arrowprops=dict(arrowstyle='->', color='#9C27B0', lw=2, linestyle='dashed'))
ax.text(-2.0, -1.2, '→*', fontsize=11, color='#9C27B0', fontweight='bold')

# t₂ →* t₄
ax.annotate('', xy=(1.1, -2.1), xytext=(1.85, -0.4),
            arrowprops=dict(arrowstyle='->', color='#9C27B0', lw=2, linestyle='dashed'))
ax.text(1.5, -1.2, '→*', fontsize=11, color='#9C27B0', fontweight='bold')

# t₃ ≡ t₄ (AC equivalence)
ax.annotate('', xy=(0.6, -2.5), xytext=(-0.6, -2.5),
            arrowprops=dict(arrowstyle='<->', color='#E91E63', lw=2.5))
ax.text(0, -3.1, '≡ mod AC', fontsize=11, color='#E91E63',
        fontweight='bold', ha='center')

# ============================================================================
# Right panel: Type-Level Separation
# ============================================================================
ax2 = axes[1]
ax2.set_xlim(-0.5, 4.5)
ax2.set_ylim(-0.5, 4.5)
ax2.axis('off')
ax2.set_title('Type-Level Separation\n(Why Confluence Works)', fontsize=14, fontweight='bold')

# Draw type levels
levels = [
    (0, 'Level 0\n(Base Types)', ['ℝ', 'Vec n', 'Mat m×n'], '#E3F2FD', '#1565C0'),
    (2, 'Level 1\n(Arrow Types)', ['τ₁ → τ₂'], '#FFF3E0', '#E65100'),
    (3.5, 'Level 2+\n(Higher Order)', ['(τ₁→τ₂) → τ₃'], '#F3E5F5', '#6A1B9A'),
]

for y_base, label, types, bg_color, text_color in levels:
    rect = mpatches.FancyBboxPatch((0.3, y_base), 3.4, 1.2,
                                    boxstyle="round,pad=0.1",
                                    facecolor=bg_color, edgecolor=text_color,
                                    linewidth=2)
    ax2.add_patch(rect)
    ax2.text(0.5, y_base + 0.9, label, fontsize=9, color=text_color,
            fontweight='bold', va='top')
    ax2.text(2.5, y_base + 0.5, ', '.join(types), fontsize=10,
            color=text_color, ha='center', va='center')

# Dist arrow at level 0
ax2.annotate('dist rules\nfire HERE', xy=(3.8, 0.6), xytext=(4.2, 1.5),
            fontsize=9, color='#1565C0', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#1565C0', lw=1.5),
            ha='center')

# Beta arrow at level 1
ax2.annotate('β-reduction\nfires HERE', xy=(3.8, 2.6), xytext=(4.2, 3.5),
            fontsize=9, color='#E65100', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#E65100', lw=1.5),
            ha='center')

# "No overlap" annotation
ax2.text(2.0, 1.5, '← NO OVERLAP →', fontsize=11, color='#D32F2F',
        fontweight='bold', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE', edgecolor='#D32F2F'))

plt.tight_layout()
plt.savefig('confluence_diagram.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved confluence_diagram.png")
