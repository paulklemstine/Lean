#!/usr/bin/env python3
"""
Demo 5: The Noncommutative Frontier — Spectral Triples & Connes Distance
=========================================================================
Visualizes the passage from commutative to noncommutative geometry.
Shows how a spectral triple (A, H, D) replaces a Riemannian manifold
when commutativity is dropped.

Run: python demo5_noncommutative_frontier.py
Output: noncommutative_frontier.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_noncommutative_frontier():
    fig = plt.figure(figsize=(18, 14))

    # ═══ Panel 1: The Translation Ladder ═══
    ax1 = fig.add_axes([0.05, 0.55, 0.9, 0.4])
    ax1.set_xlim(0, 20)
    ax1.set_ylim(0, 8)
    ax1.axis('off')
    ax1.set_title('From Commutative to Noncommutative: The Translation Ladder',
                  fontsize=18, fontweight='bold', fontfamily='serif', pad=20)

    levels = [
        {
            'y': 6.5, 'space': 'Topological space X',
            'algebra': 'C(X) — continuous functions',
            'theorem': 'Gelfand–Naimark',
            'color_s': '#e8f4f8', 'color_a': '#f0e6f6'
        },
        {
            'y': 5.0, 'space': 'Smooth manifold M',
            'algebra': 'C∞(M) — smooth functions',
            'theorem': 'Milnor / Connes',
            'color_s': '#d4edda', 'color_a': '#e8d5e8'
        },
        {
            'y': 3.5, 'space': 'Riemannian manifold (M,g)',
            'algebra': 'Spectral triple (C∞(M), L²(S), D̸)',
            'theorem': 'Connes reconstruction',
            'color_s': '#fff3cd', 'color_a': '#fce4ec'
        },
        {
            'y': 2.0, 'space': '??? (no classical space)',
            'algebra': 'Spectral triple (A, H, D)  [A noncommutative]',
            'theorem': 'Noncommutative geometry',
            'color_s': '#f8d7da', 'color_a': '#fce4ec'
        },
        {
            'y': 0.5, 'space': '??? (Standard Model!)',
            'algebra': '(C∞(M) ⊗ Aᶠ,  H,  D)  where Aᶠ = ℂ ⊕ ℍ ⊕ M₃(ℂ)',
            'theorem': 'Connes–Chamseddine',
            'color_s': '#f8d7da', 'color_a': '#d5f5e3'
        },
    ]

    for lev in levels:
        y = lev['y']
        # Space box
        ax1.add_patch(mpatches.FancyBboxPatch((0.5, y - 0.4), 6.5, 0.8,
                     boxstyle="round,pad=0.1", facecolor=lev['color_s'],
                     edgecolor='#0f3460', lw=1.5))
        ax1.text(3.75, y, lev['space'], fontsize=10, ha='center', va='center',
                color='#0f3460', fontfamily='serif')
        # Arrow
        ax1.annotate('', xy=(8.8, y), xytext=(7.2, y),
                    arrowprops=dict(arrowstyle='<->', color='#e94560', lw=2))
        ax1.text(8, y + 0.35, lev['theorem'], fontsize=7.5, ha='center',
                va='center', color='#e94560', fontfamily='serif', style='italic')
        # Algebra box
        ax1.add_patch(mpatches.FancyBboxPatch((9.2, y - 0.4), 10.3, 0.8,
                     boxstyle="round,pad=0.1", facecolor=lev['color_a'],
                     edgecolor='#533483', lw=1.5))
        ax1.text(14.35, y, lev['algebra'], fontsize=10, ha='center', va='center',
                color='#533483', fontfamily='serif')

    # Vertical arrow showing "increasing abstraction"
    ax1.annotate('', xy=(0.2, 0.3), xytext=(0.2, 6.8),
                arrowprops=dict(arrowstyle='->', color='#999999', lw=2))
    ax1.text(0.1, 3.5, 'deeper', fontsize=10, ha='center', va='center',
            color='#999999', fontfamily='serif', rotation=90)

    # ═══ Panel 2: Connes Distance Formula ═══
    ax2 = fig.add_axes([0.05, 0.05, 0.45, 0.42])
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 8)
    ax2.axis('off')
    ax2.set_title("Connes' Distance Formula", fontsize=16, fontweight='bold',
                  fontfamily='serif', pad=10)

    # The formula
    ax2.text(5, 6.5,
             r'$d(\phi, \psi) = \sup\{|\phi(a) - \psi(a)| \;:\; \|[D, \pi(a)]\| \leq 1\}$',
             fontsize=14, ha='center', va='center', color='#1a1a2e',
             fontfamily='serif',
             bbox=dict(boxstyle='round,pad=0.5', facecolor='#fff3cd',
                       edgecolor='#e94560', lw=2))

    # Explanation
    explanations = [
        (5, 5.2, 'φ, ψ = states (quantum analogs of points)', '#0f3460'),
        (5, 4.5, 'a ∈ A = observable (analog of function)', '#533483'),
        (5, 3.8, 'D = Dirac operator (encodes the metric)', '#e94560'),
        (5, 3.1, '[D, π(a)] = commutator (measures "gradient")', '#2196F3'),
        (5, 2.4, '‖·‖ ≤ 1 = Lipschitz condition', '#4CAF50'),
    ]
    for x, y, text, color in explanations:
        ax2.text(x, y, text, fontsize=10, ha='center', va='center',
                color=color, fontfamily='serif')

    ax2.text(5, 1.2, 'When A is commutative, this recovers\nthe geodesic distance on the manifold!',
             fontsize=11, ha='center', va='center', color='#1a1a2e',
             fontfamily='serif', style='italic',
             bbox=dict(boxstyle='round,pad=0.4', facecolor='#e8f4f8',
                       edgecolor='#0f3460', lw=1.5))

    # ═══ Panel 3: Two-Point Space Example ═══
    ax3 = fig.add_axes([0.55, 0.05, 0.4, 0.42])
    ax3.set_xlim(0, 10)
    ax3.set_ylim(0, 8)
    ax3.axis('off')
    ax3.set_title('Example: The Two-Point "Space"', fontsize=16, fontweight='bold',
                  fontfamily='serif', pad=10)

    # The spectral triple
    ax3.text(5, 7, 'A = ℂ²,   H = ℂ²,   D = [[0, λ], [λ̄, 0]]',
             fontsize=12, ha='center', va='center', color='#1a1a2e', fontfamily='monospace')

    # Two points
    ax3.plot(3, 4.5, 'o', markersize=25, color='#0f3460',
             markeredgecolor='#1a1a2e', markeredgewidth=2, zorder=10)
    ax3.text(3, 4.5, 'p', fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=11)

    ax3.plot(7, 4.5, 'o', markersize=25, color='#e94560',
             markeredgecolor='#1a1a2e', markeredgewidth=2, zorder=10)
    ax3.text(7, 4.5, 'q', fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=11)

    # Distance line
    ax3.annotate('', xy=(6.5, 4.5), xytext=(3.5, 4.5),
                arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2.5))
    ax3.text(5, 5.2, r'$d(p, q) = 1/|\lambda|$', fontsize=14, ha='center',
             va='center', color='#4CAF50', fontweight='bold', fontfamily='serif')

    # States
    ax3.text(3, 3.3, r'$\phi(a,b) = a$', fontsize=11, ha='center', va='center',
             color='#0f3460', fontfamily='serif')
    ax3.text(7, 3.3, r'$\psi(a,b) = b$', fontsize=11, ha='center', va='center',
             color='#e94560', fontfamily='serif')

    ax3.text(5, 2, 'The Dirac operator D determines\nthe distance between "points" (states).',
             fontsize=10, ha='center', va='center', color='#666666',
             fontfamily='serif', style='italic')

    ax3.text(5, 0.8, 'No underlying topological space needed!',
             fontsize=12, ha='center', va='center', color='#e94560',
             fontweight='bold', fontfamily='serif',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#fce4ec',
                       edgecolor='#e94560', lw=1.5))

    plt.savefig('noncommutative_frontier.png', dpi=200, bbox_inches='tight',
                facecolor='white')
    print("✓ Saved noncommutative_frontier.png")
    plt.close()

if __name__ == '__main__':
    create_noncommutative_frontier()
