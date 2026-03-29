#!/usr/bin/env python3
"""
Demo 3: The Freudenthal-Tits Magic Square
==========================================
Visualizes the Magic Square — how pairs of division algebras
generate ALL exceptional Lie groups and unify the forces of nature.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import matplotlib.patheffects as pe

def create_magic_square():
    """Create the Freudenthal-Tits Magic Square visualization."""
    fig, axes = plt.subplots(1, 2, figsize=(20, 10),
                            gridspec_kw={'width_ratios': [1.2, 1]})
    fig.patch.set_facecolor('#0a0a1a')

    # ===== LEFT PANEL: The Magic Square =====
    ax = axes[0]
    ax.set_xlim(-0.5, 5.5)
    ax.set_ylim(-1, 6)
    ax.set_aspect('equal')
    ax.axis('off')

    # Magic Square data: Lie algebras and their dimensions
    ms_algebras = [
        ['A₁\n(3)', 'A₂\n(8)', 'C₃\n(21)', 'F₄\n(52)'],
        ['A₂\n(8)', 'A₂⊕A₂\n(16)', 'A₅\n(35)', 'E₆\n(78)'],
        ['C₃\n(21)', 'A₅\n(35)', 'D₆\n(66)', 'E₇\n(133)'],
        ['F₄\n(52)', 'E₆\n(78)', 'E₇\n(133)', 'E₈\n(248)'],
    ]

    ms_dims = [
        [3, 8, 21, 52],
        [8, 16, 35, 78],
        [21, 35, 66, 133],
        [52, 78, 133, 248],
    ]

    # Whether the entry is an exceptional Lie algebra
    is_exceptional = [
        [False, False, False, True],
        [False, False, False, True],
        [False, False, False, True],
        [True, True, True, True],
    ]

    labels = ['ℝ', 'ℂ', 'ℍ', '𝕆']
    label_colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']

    # Draw column headers
    for j in range(4):
        ax.text(j + 1.5, 5.5, labels[j], fontsize=22, fontweight='bold',
               ha='center', va='center', color=label_colors[j])

    # Draw row headers
    for i in range(4):
        ax.text(0.3, 4 - i + 0.5, labels[i], fontsize=22, fontweight='bold',
               ha='center', va='center', color=label_colors[i])

    # Draw cells
    for i in range(4):
        for j in range(4):
            x = j + 1
            y = 4 - i
            dim = ms_dims[i][j]

            # Color based on dimension (intensity)
            intensity = dim / 248
            if is_exceptional[i][j]:
                facecolor = plt.cm.magma(0.3 + 0.6 * intensity)
                edgecolor = '#FFD93D'
                textcolor = '#FFD93D'
                lw = 2.5
            else:
                facecolor = plt.cm.viridis(0.2 + 0.5 * intensity)
                edgecolor = 'white'
                textcolor = 'white'
                lw = 1

            box = FancyBboxPatch((x, y), 1, 1,
                                boxstyle="round,pad=0.05",
                                facecolor=facecolor, alpha=0.3,
                                edgecolor=edgecolor, linewidth=lw)
            ax.add_patch(box)

            ax.text(x + 0.5, y + 0.5, ms_algebras[i][j],
                   fontsize=10, ha='center', va='center',
                   color=textcolor, fontweight='bold' if is_exceptional[i][j] else 'normal')

    # Title
    ax.text(3, 5.9, 'The Freudenthal-Tits Magic Square',
           fontsize=16, fontweight='bold', ha='center', va='center', color='white')

    # Annotation for exceptional algebras
    ax.text(3, -0.5, '★ Gold border = Exceptional Lie algebra',
           fontsize=10, ha='center', va='center', color='#FFD93D', alpha=0.7)
    ax.text(3, -0.9, 'Entry (A₁, A₂) = Lie algebra constructed from division algebras A₁ and A₂',
           fontsize=9, ha='center', va='center', color='white', alpha=0.5)

    # ===== RIGHT PANEL: Physical Interpretations =====
    ax2 = axes[1]
    ax2.axis('off')
    ax2.set_xlim(0, 1)
    ax2.set_ylim(0, 1)

    ax2.text(0.5, 0.97, 'Physical Interpretations',
            fontsize=16, fontweight='bold', ha='center', va='top', color='white')

    interpretations = [
        ('G₂ = Aut(𝕆)', '14-dim', '#96CEB4',
         'Automorphisms of the octonions\n→ G₂ holonomy manifolds in M-theory'),
        ('F₄ = Aut(J₃(𝕆))', '52-dim', '#FFD93D',
         'Automorphisms of the exceptional\nJordan algebra → Quantum gravity observables'),
        ('E₆', '78-dim', '#FFD93D',
         'Grand Unified Theory gauge group\n→ Contains SU(3)×SU(3)×SU(3)'),
        ('E₇', '133-dim', '#FFD93D',
         'U-duality in string theory\n→ Controls black hole entropy'),
        ('E₈', '248-dim', '#FFD93D',
         'Heterotic string gauge group\n→ E₈×E₈ is a Theory of Everything candidate'),
        ('SU(3) = A₂', '8-dim', '#4ECDC4',
         'Quantum Chromodynamics (strong force)\n→ Appears in row/column (ℝ,ℂ) and (ℂ,ℝ)'),
        ('Sp(3) = C₃', '21-dim', '#45B7D1',
         'Symplectic geometry of phase space\n→ Classical mechanics generalization'),
        ('SO(12) = D₆', '66-dim', 'white',
         'Rotation group in 12 dimensions\n→ Compactification symmetry'),
    ]

    for i, (name, dim, color, desc) in enumerate(interpretations):
        y = 0.90 - i * 0.115
        ax2.text(0.02, y, f'• {name}', fontsize=11, fontweight='bold',
                color=color, va='top', transform=ax2.transAxes)
        ax2.text(0.42, y, f'({dim})', fontsize=9, color=color, alpha=0.6,
                va='top', transform=ax2.transAxes)
        ax2.text(0.04, y - 0.035, desc, fontsize=8, color=color, alpha=0.5,
                va='top', transform=ax2.transAxes, linespacing=1.3)

    # Key insight box
    ax2.text(0.5, 0.03, '"All five exceptional Lie groups emerge\n'
            'from pairs of division algebras.\n'
            'The forces of nature are not arbitrary —\n'
            'they are algebraically inevitable."',
            fontsize=10, ha='center', va='bottom', color='#FFD93D',
            style='italic', transform=ax2.transAxes,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a2e',
                     edgecolor='#FFD93D', alpha=0.5))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/03_magic_square.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/03_magic_square.png")

if __name__ == '__main__':
    create_magic_square()
