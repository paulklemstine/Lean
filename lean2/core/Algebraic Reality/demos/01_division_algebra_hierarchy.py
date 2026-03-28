#!/usr/bin/env python3
"""
Demo 1: The Division Algebra Hierarchy
=======================================
Visualizes the four normed division algebras and the properties lost
at each step of the Cayley-Dickson construction.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import matplotlib.patheffects as pe

def create_hierarchy_diagram():
    """Create the division algebra hierarchy diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    ax.set_xlim(-1, 17)
    ax.set_ylim(-1, 11)
    ax.set_aspect('equal')
    ax.axis('off')
    fig.patch.set_facecolor('#0a0a1a')

    # Colors for each algebra
    colors = {
        'R': '#FF6B6B',   # Red
        'C': '#4ECDC4',   # Teal
        'H': '#45B7D1',   # Blue
        'O': '#96CEB4',   # Green
        'S': '#555555',   # Gray (broken)
    }

    # Division algebra boxes
    algebras = [
        {'name': 'ℝ', 'full': 'Real Numbers', 'dim': 1, 'x': 2, 'y': 8,
         'props': ['Ordered', 'Commutative', 'Associative', 'Division'],
         'physics': 'Classical Mechanics\nThermodynamics\nArrow of Time',
         'color': colors['R']},
        {'name': 'ℂ', 'full': 'Complex Numbers', 'dim': 2, 'x': 6, 'y': 8,
         'props': ['Commutative', 'Associative', 'Division'],
         'physics': 'Quantum Mechanics\nElectromagnetism\nSuperposition',
         'color': colors['C']},
        {'name': 'ℍ', 'full': 'Quaternions', 'dim': 4, 'x': 10, 'y': 8,
         'props': ['Associative', 'Division'],
         'physics': 'Weak Nuclear Force\nStrong Force\nSpin & Rotation',
         'color': colors['H']},
        {'name': '𝕆', 'full': 'Octonions', 'dim': 8, 'x': 14, 'y': 8,
         'props': ['Alternative', 'Division'],
         'physics': 'Gravity\nSpacetime Curvature\nDark Matter?',
         'color': colors['O']},
    ]

    for alg in algebras:
        # Main box
        box = FancyBboxPatch((alg['x']-1.5, alg['y']-1.2), 3, 2.4,
                            boxstyle="round,pad=0.15",
                            facecolor=alg['color'], alpha=0.2,
                            edgecolor=alg['color'], linewidth=2)
        ax.add_patch(box)

        # Algebra symbol
        ax.text(alg['x'], alg['y']+0.5, alg['name'],
               fontsize=32, fontweight='bold', ha='center', va='center',
               color=alg['color'],
               path_effects=[pe.withStroke(linewidth=1, foreground='white')])

        # Dimension
        ax.text(alg['x'], alg['y']-0.1, f"dim = {alg['dim']}",
               fontsize=12, ha='center', va='center', color='white', alpha=0.8)

        # Full name
        ax.text(alg['x'], alg['y']-0.6, alg['full'],
               fontsize=9, ha='center', va='center', color='white', alpha=0.6)

        # Physics box below
        physics_box = FancyBboxPatch((alg['x']-1.5, alg['y']-3.8), 3, 2.0,
                                    boxstyle="round,pad=0.1",
                                    facecolor=alg['color'], alpha=0.08,
                                    edgecolor=alg['color'], linewidth=1,
                                    linestyle='--')
        ax.add_patch(physics_box)
        ax.text(alg['x'], alg['y']-2.8, alg['physics'],
               fontsize=8, ha='center', va='center', color=alg['color'],
               alpha=0.9, linespacing=1.5)

    # Arrows between algebras showing lost properties
    losses = [
        {'from': 2, 'to': 6, 'lost': '✗ Ordering', 'y': 9.7},
        {'from': 6, 'to': 10, 'lost': '✗ Commutativity', 'y': 9.7},
        {'from': 10, 'to': 14, 'lost': '✗ Associativity', 'y': 9.7},
    ]

    for loss in losses:
        mid = (loss['from'] + loss['to']) / 2
        ax.annotate('', xy=(loss['to']-1.6, 8.5), xytext=(loss['from']+1.6, 8.5),
                   arrowprops=dict(arrowstyle='->', color='#FFD93D',
                                  lw=2, connectionstyle='arc3,rad=0.15'))
        ax.text(mid, loss['y'], loss['lost'],
               fontsize=10, ha='center', va='center',
               color='#FFD93D', fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#0a0a1a',
                        edgecolor='#FFD93D', alpha=0.9))

    # The broken fifth step
    ax.text(16.2, 8.5, '𝕊', fontsize=24, ha='center', va='center',
           color='#555555', alpha=0.4)
    ax.text(16.2, 7.7, 'Sedenions', fontsize=8, ha='center', va='center',
           color='#555555', alpha=0.4)
    ax.text(16.2, 9.7, '✗ DIVISION\n(zero divisors!)',
           fontsize=9, ha='center', va='center',
           color='#FF0000', fontweight='bold', alpha=0.7)

    # Big red X over sedenions
    ax.plot([15.5, 16.9], [7.2, 9.0], 'r-', lw=3, alpha=0.4)
    ax.plot([15.5, 16.9], [9.0, 7.2], 'r-', lw=3, alpha=0.4)

    # Title
    ax.text(8, 10.5, 'THE DIVISION ALGEBRA HIERARCHY',
           fontsize=20, fontweight='bold', ha='center', va='center',
           color='white',
           path_effects=[pe.withStroke(linewidth=2, foreground='#333366')])
    ax.text(8, 10.0, 'The Cayley-Dickson Construction: Each doubling loses a property',
           fontsize=11, ha='center', va='center', color='white', alpha=0.6)

    # Legend: Cayley-Dickson doubling formula
    ax.text(8, 0.3, 'Cayley-Dickson: (a,b)·(c,d) = (ac - d̄b, da + bc̄)',
           fontsize=11, ha='center', va='center', color='white', alpha=0.5,
           family='monospace')

    # Sum annotation
    ax.text(8, -0.3, '1 + 2 + 4 + 8 = 15 = dim SU(4) ⊃ SU(3)×SU(2)×U(1)',
           fontsize=10, ha='center', va='center', color='#FFD93D', alpha=0.7)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/01_hierarchy.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/01_hierarchy.png")

if __name__ == '__main__':
    create_hierarchy_diagram()
