#!/usr/bin/env python3
"""
Demo 7: Grand Unified Visualization
=====================================
The complete visual summary of the Algebraic Theory of Reality,
showing all four layers, their connections, and predictions.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Arc
import matplotlib.patheffects as pe

def create_grand_visualization():
    """Create the grand unified visualization."""
    fig = plt.figure(figsize=(24, 16), facecolor='#0a0a1a')

    # Create a single large axis
    ax = fig.add_subplot(111)
    ax.set_xlim(-1, 25)
    ax.set_ylim(-2, 17)
    ax.set_aspect('equal')
    ax.axis('off')
    fig.patch.set_facecolor('#0a0a1a')

    # ============ TITLE ============
    ax.text(12, 16.5, 'THE ALGEBRAIC THEORY OF REALITY',
           fontsize=28, fontweight='bold', ha='center', va='center',
           color='white',
           path_effects=[pe.withStroke(linewidth=3, foreground='#333366')])
    ax.text(12, 15.8, 'Reality is the Cayley-Dickson construction made manifest',
           fontsize=14, ha='center', va='center', color='#FFD93D', alpha=0.8,
           style='italic')

    # ============ FOUR LAYERS (concentric structure) ============
    layers = [
        {'name': 'ℝ', 'full': 'REAL', 'dim': 1, 'color': '#FF6B6B',
         'physics': 'Classical Mechanics\nTime · Entropy · Order',
         'property': 'ORDERED', 'r': 1.5, 'cx': 5, 'cy': 10},
        {'name': 'ℂ', 'full': 'COMPLEX', 'dim': 2, 'color': '#4ECDC4',
         'physics': 'Quantum Mechanics\nSuperposition · Phase · EM',
         'property': 'COMMUTATIVE', 'r': 2.5, 'cx': 5, 'cy': 10},
        {'name': 'ℍ', 'full': 'QUATERNIONIC', 'dim': 4, 'color': '#45B7D1',
         'physics': 'Nuclear Forces\nSpin · SU(2) · SU(3)',
         'property': 'ASSOCIATIVE', 'r': 3.5, 'cx': 5, 'cy': 10},
        {'name': '𝕆', 'full': 'OCTONIONIC', 'dim': 8, 'color': '#96CEB4',
         'physics': 'Gravity\nCurvature · G₂ · E₈',
         'property': 'ALTERNATIVE', 'r': 4.5, 'cx': 5, 'cy': 10},
    ]

    for layer in layers:
        circle = Circle((layer['cx'], layer['cy']), layer['r'],
                        fill=False, edgecolor=layer['color'],
                        linewidth=2.5, alpha=0.6, linestyle='-')
        ax.add_patch(circle)

        # Label on circle
        angle = np.pi/4 + (layer['r'] - 1.5) * 0.3
        lx = layer['cx'] + layer['r'] * np.cos(angle)
        ly = layer['cy'] + layer['r'] * np.sin(angle)
        ax.text(lx, ly, layer['name'], fontsize=20, fontweight='bold',
               ha='center', va='center', color=layer['color'],
               bbox=dict(boxstyle='round,pad=0.15', facecolor='#0a0a1a',
                        edgecolor=layer['color'], alpha=0.9))

    # Layer labels on the right
    for i, layer in enumerate(layers):
        y = 14.5 - i * 1.2
        ax.text(10.5, y, f"{layer['name']}  dim={layer['dim']}",
               fontsize=14, fontweight='bold', color=layer['color'], va='center')
        ax.text(10.5, y-0.4, layer['physics'], fontsize=8,
               color=layer['color'], alpha=0.7, va='top', linespacing=1.3)

    # Property labels
    for i, layer in enumerate(layers):
        y = 14.5 - i * 1.2
        ax.text(14, y, f"← {layer['property']}", fontsize=9,
               color=layer['color'], alpha=0.5, va='center')

    # ============ MAGIC SQUARE (right side) ============
    ms_x, ms_y = 18, 12
    ax.text(ms_x + 2, ms_y + 3, 'MAGIC SQUARE', fontsize=14,
           fontweight='bold', ha='center', color='#FFD93D')

    ms_data = [
        ['A₁', 'A₂', 'C₃', 'F₄'],
        ['A₂', 'A₂²', 'A₅', 'E₆'],
        ['C₃', 'A₅', 'D₆', 'E₇'],
        ['F₄', 'E₆', 'E₇', 'E₈'],
    ]
    ms_labels = ['ℝ', 'ℂ', 'ℍ', '𝕆']
    ms_colors_lab = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']

    exceptional = {(0,3), (1,3), (2,3), (3,0), (3,1), (3,2), (3,3)}

    for j in range(4):
        ax.text(ms_x + j + 0.5, ms_y + 2.3, ms_labels[j], fontsize=12,
               fontweight='bold', ha='center', color=ms_colors_lab[j])
    for i in range(4):
        ax.text(ms_x - 0.5, ms_y + 1.5 - i, ms_labels[i], fontsize=12,
               fontweight='bold', ha='center', color=ms_colors_lab[i])

    for i in range(4):
        for j in range(4):
            x = ms_x + j
            y = ms_y + 1 - i
            is_exc = (i, j) in exceptional
            color = '#FFD93D' if is_exc else 'white'
            ax.add_patch(FancyBboxPatch((x+0.05, y+0.05), 0.9, 0.9,
                boxstyle="round,pad=0.03",
                facecolor=color, alpha=0.1 if is_exc else 0.05,
                edgecolor=color, linewidth=1.5 if is_exc else 0.5))
            ax.text(x+0.5, y+0.5, ms_data[i][j], fontsize=9,
                   ha='center', va='center', color=color,
                   fontweight='bold' if is_exc else 'normal')

    # ============ PREDICTIONS (bottom) ============
    pred_y = 2
    ax.text(12, pred_y + 2, 'PREDICTIONS', fontsize=16, fontweight='bold',
           ha='center', color='#FFD93D')

    predictions = [
        ('No Fifth Force', 'Sedenions have zero divisors → only 4 layers possible',
         '#FF6B6B', '✓ Consistent'),
        ('Three Generations', 'J₃(𝕆) has 3 octonionic off-diagonal entries',
         '#4ECDC4', '✓ Observed'),
        ('Proton Stability', 'Norm-preserving embeddings → charge conservation',
         '#45B7D1', '✓ τ > 10³⁴ yr'),
        ('Dark = Hidden 𝕆', '7D imaginary octonions → 1 hidden gravitational direction',
         '#96CEB4', '? Testable'),
    ]

    for i, (title, desc, color, status) in enumerate(predictions):
        x = 1 + i * 6
        box = FancyBboxPatch((x-0.5, pred_y-0.8), 5.5, 2.2,
                            boxstyle="round,pad=0.15",
                            facecolor=color, alpha=0.08,
                            edgecolor=color, linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+2.3, pred_y+1, title, fontsize=11, fontweight='bold',
               ha='center', color=color)
        ax.text(x+2.3, pred_y+0.3, desc, fontsize=7, ha='center',
               color=color, alpha=0.7, wrap=True)
        ax.text(x+2.3, pred_y-0.3, status, fontsize=9, ha='center',
               color=color, fontweight='bold', alpha=0.9)

    # ============ KEY NUMBERS ============
    ax.text(12, -0.5, '1 + 2 + 4 + 8 = 15 = dim SU(4)     |     '
           'dim G₂ = 14     |     dim J₃(𝕆) = 27     |     '
           'dim E₈ = 248',
           fontsize=10, ha='center', color='white', alpha=0.5,
           family='monospace')

    ax.text(12, -1.2, 'Hurwitz (1898)  ·  Adams (1960)  ·  '
           'Freudenthal-Tits (1966)  ·  Algebraic Theory of Reality (2025)',
           fontsize=9, ha='center', color='#FFD93D', alpha=0.4)

    # ============ CONNECTING ARROWS ============
    # From layers to magic square
    ax.annotate('', xy=(16.5, 12), xytext=(14.5, 12),
               arrowprops=dict(arrowstyle='->', color='#FFD93D', lw=1.5,
                              connectionstyle='arc3,rad=0'))

    # ============ THE EQUATION ============
    eq_y = 5.5
    ax.text(12, eq_y + 0.8, 'THE FUNDAMENTAL EQUATION', fontsize=12,
           fontweight='bold', ha='center', color='#FFD93D', alpha=0.8)

    ax.text(12, eq_y, 'Reality  =  ℝ  ⊕  ℂ  ⊕  ℍ  ⊕  𝕆',
           fontsize=22, fontweight='bold', ha='center', va='center',
           color='white', family='monospace',
           path_effects=[pe.withStroke(linewidth=2, foreground='#333366')])

    ax.text(12, eq_y - 0.8,
           '(time)    (quantum)   (forces)   (gravity)',
           fontsize=10, ha='center', color='white', alpha=0.4)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/07_grand_unified.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/07_grand_unified.png")

if __name__ == '__main__':
    create_grand_visualization()
