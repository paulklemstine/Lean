#!/usr/bin/env python3
"""
Millennium Problems — Grand Overview Visualization

Creates a single panoramic figure showing all 7 Millennium Problems,
their status, connections, and the "local-to-global" unifying theme.

Run: python demo_00_overview.py
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Circle


def create_overview():
    """Create the grand overview figure."""
    fig = plt.figure(figsize=(20, 14))

    # Title
    fig.suptitle('THE MILLENNIUM PRIZE PROBLEMS\nA Survey of the Greatest Open Questions in Mathematics',
                fontsize=20, fontweight='bold', y=0.98)

    # ─── Main grid ───
    gs = fig.add_gridspec(3, 3, hspace=0.4, wspace=0.3,
                          left=0.05, right=0.95, top=0.92, bottom=0.05)

    problems = [
        {
            'name': 'P vs NP',
            'status': 'OPEN',
            'color': '#e74c3c',
            'prize': '$1,000,000',
            'field': 'Computer Science',
            'question': 'Can every problem whose\nsolution is quickly verified\nalso be quickly solved?',
            'key': 'Finding vs. Verifying',
            'row': 0, 'col': 0,
        },
        {
            'name': 'Hodge Conjecture',
            'status': 'OPEN',
            'color': '#e67e22',
            'prize': '$1,000,000',
            'field': 'Algebraic Geometry',
            'question': 'Are all Hodge classes\nalgebraic cycle classes?',
            'key': 'Analysis = Algebra?',
            'row': 0, 'col': 1,
        },
        {
            'name': 'Riemann Hypothesis',
            'status': 'OPEN',
            'color': '#9b59b6',
            'prize': '$1,000,000',
            'field': 'Number Theory',
            'question': 'Do all non-trivial zeros of\nζ(s) lie on Re(s) = 1/2?',
            'key': 'Order in the Primes',
            'row': 0, 'col': 2,
        },
        {
            'name': 'Yang-Mills\nMass Gap',
            'status': 'OPEN',
            'color': '#3498db',
            'prize': '$1,000,000',
            'field': 'Mathematical Physics',
            'question': 'Does quantum Yang-Mills\ntheory exist with a\npositive mass gap?',
            'key': 'Quantum ↔ Classical',
            'row': 1, 'col': 0,
        },
        {
            'name': 'Navier-Stokes',
            'status': 'OPEN',
            'color': '#1abc9c',
            'prize': '$1,000,000',
            'field': 'Analysis / PDEs',
            'question': 'Do smooth solutions to\nNavier-Stokes always exist\nin 3D?',
            'key': 'Smooth or Singular?',
            'row': 1, 'col': 1,
        },
        {
            'name': 'Birch &\nSwinnerton-Dyer',
            'status': 'OPEN',
            'color': '#f39c12',
            'prize': '$1,000,000',
            'field': 'Number Theory',
            'question': 'Does rank(E(ℚ)) equal\nord_{s=1} L(E,s)?',
            'key': 'L-functions ↔ Points',
            'row': 1, 'col': 2,
        },
        {
            'name': 'Poincaré\nConjecture',
            'status': 'SOLVED ✓',
            'color': '#2ecc71',
            'prize': 'Declined!',
            'field': 'Topology',
            'question': 'Is every simply connected\nclosed 3-manifold\nhomeomorphic to S³?',
            'key': 'Perelman (2003)',
            'row': 2, 'col': 1,
        },
    ]

    for prob in problems:
        ax = fig.add_subplot(gs[prob['row'], prob['col']])
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)

        # Background
        is_solved = 'SOLVED' in prob['status']
        bg_color = '#d5f5e3' if is_solved else '#fef9e7'
        rect = FancyBboxPatch((0.2, 0.2), 9.6, 9.6,
                               boxstyle='round,pad=0.1',
                               facecolor=bg_color,
                               edgecolor=prob['color'],
                               linewidth=3)
        ax.add_patch(rect)

        # Status badge
        badge_color = '#2ecc71' if is_solved else '#e74c3c'
        ax.text(9.5, 9.5, prob['status'], fontsize=9, fontweight='bold',
               ha='right', va='top', color='white',
               bbox=dict(boxstyle='round,pad=0.2', facecolor=badge_color))

        # Title
        ax.text(5, 8.5, prob['name'], fontsize=14, fontweight='bold',
               ha='center', va='center', color=prob['color'])

        # Field
        ax.text(5, 7.3, prob['field'], fontsize=10, ha='center', va='center',
               style='italic', color='gray')

        # Question
        ax.text(5, 5, prob['question'], fontsize=9, ha='center', va='center',
               fontfamily='serif')

        # Key insight
        ax.text(5, 2.5, prob['key'], fontsize=10, fontweight='bold',
               ha='center', va='center', color=prob['color'],
               bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                        edgecolor=prob['color'], alpha=0.8))

        # Prize
        ax.text(5, 1, prob['prize'], fontsize=9, ha='center', va='center',
               color='darkgoldenrod', fontweight='bold')

        ax.axis('off')

    # Add unifying theme in bottom-left and bottom-right
    for pos, text in [(0, 'The Unifying Theme:\n\n"When does LOCAL\ninformation determine\nGLOBAL structure?"\n\nEvery Millennium Problem\nasks this question in a\ndifferent domain.'),
                      (2, 'Score: 1/7 Solved\n\nTotal Prize: $7,000,000\nAwarded: $1,000,000\n(Perelman declined)\n\nRemaining: $6,000,000\nfor the brave')]:
        ax = fig.add_subplot(gs[2, pos])
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.text(5, 5, text, fontsize=11, ha='center', va='center',
               fontfamily='serif',
               bbox=dict(boxstyle='round,pad=0.5', facecolor='lavender',
                        edgecolor='navy', linewidth=2))
        ax.axis('off')

    plt.savefig('demo_00_overview.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_00_overview.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Millennium Problems — Grand Overview")
    print("=" * 60)
    create_overview()
    print("\nDone! Check demo_00_overview.png")
