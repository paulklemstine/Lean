#!/usr/bin/env python3
"""
Demo 5: Octonionic Physics — The Deepest Layer
================================================
Visualizes the octonionic structure, Fano plane, and the connection
between non-associativity and spacetime curvature.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import Circle, FancyArrowPatch
import matplotlib.patheffects as pe

def draw_fano_plane(ax):
    """Draw the Fano plane — the multiplication table of imaginary octonions."""
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # The 7 points of the Fano plane (imaginary octonion units)
    # Arranged as: outer triangle + inner triangle + center
    r_outer = 1.6
    r_inner = 0.75

    points = {}
    labels = ['e₁', 'e₂', 'e₃', 'e₄', 'e₅', 'e₆', 'e₇']

    # Outer triangle
    for i in range(3):
        angle = np.pi/2 + i * 2*np.pi/3
        points[labels[i]] = (r_outer * np.cos(angle), r_outer * np.sin(angle))

    # Inner triangle (rotated 60°)
    for i in range(3):
        angle = np.pi/2 + np.pi/3 + i * 2*np.pi/3
        points[labels[i+3]] = (r_inner * np.cos(angle), r_inner * np.sin(angle))

    # Center
    points['e₇'] = (0, 0)

    # Colors for the 7 lines (triples)
    line_colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
                   '#FFD93D', '#DDA0DD', '#FF8C42']

    # The 7 triples of the Fano plane (oriented)
    # Each triple (eᵢ, eⱼ, eₖ) means eᵢ · eⱼ = eₖ
    triples = [
        ('e₁', 'e₂', 'e₃'),  # outer triangle side
        ('e₁', 'e₄', 'e₅'),  # line from e₁ through inner
        ('e₂', 'e₅', 'e₆'),  # line from e₂ through inner
        ('e₃', 'e₆', 'e₄'),  # line from e₃ through inner
        ('e₁', 'e₇', 'e₆'),  # line through center
        ('e₂', 'e₇', 'e₄'),  # line through center
        ('e₃', 'e₇', 'e₅'),  # line through center
    ]

    # Draw lines
    for idx, (a, b, c) in enumerate(triples):
        pts = [points[a], points[b], points[c]]
        color = line_colors[idx]

        if 'e₇' in (a, b, c):
            # Lines through center — draw as straight lines
            non_center = [p for p, label in zip(pts, [a,b,c]) if label != 'e₇']
            ax.plot([non_center[0][0], non_center[1][0]],
                   [non_center[0][1], non_center[1][1]],
                   color=color, linewidth=2, alpha=0.6)
        elif idx == 0:
            # Outer triangle — draw sides
            for i in range(3):
                j = (i + 1) % 3
                ax.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                       color=color, linewidth=2, alpha=0.6)
        else:
            # Inner lines
            ax.plot([pts[0][0], pts[2][0]], [pts[0][1], pts[2][1]],
                   color=color, linewidth=2, alpha=0.6)

    # Draw inscribed circle for inner triangle triple
    circle = Circle((0, 0), r_inner, fill=False, edgecolor='#DDA0DD',
                    linewidth=2, alpha=0.4, linestyle='--')
    ax.add_patch(circle)

    # Draw points
    for label, (x, y) in points.items():
        circle = Circle((x, y), 0.12, facecolor='white', edgecolor='#FFD93D',
                        linewidth=2, zorder=10)
        ax.add_patch(circle)
        ax.text(x, y, label, fontsize=9, ha='center', va='center',
               fontweight='bold', color='#0a0a1a', zorder=11)

    ax.set_title('The Fano Plane\n(Multiplication table of imaginary octonions)',
                color='white', fontsize=12, pad=10)

def create_octonion_visualization():
    """Create the octonion physics visualization."""
    fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')

    # ===== Panel 1: Fano Plane =====
    ax1 = fig.add_subplot(221, facecolor='#0a0a1a')
    draw_fano_plane(ax1)

    # ===== Panel 2: Non-associativity and curvature =====
    ax2 = fig.add_subplot(222, facecolor='#0a0a1a')
    ax2.axis('off')
    ax2.set_title('Non-Associativity ↔ Curvature\n(The deepest connection)',
                 color='white', fontsize=12, pad=10)

    content = [
        ('THE ASSOCIATOR', '#FFD93D', True),
        ('[x, y, z] = (xy)z − x(yz)', 'white', False),
        ('', 'white', False),
        ('In the octonions:', '#4ECDC4', True),
        ('• [eᵢ, eⱼ, eₖ] ≠ 0 in general', 'white', False),
        ('• The associator is ALTERNATING:', 'white', False),
        ('  [x,y,z] = −[y,x,z] = −[x,z,y]', '#FF6B6B', False),
        ('', 'white', False),
        ('In general relativity:', '#96CEB4', True),
        ('• R(X,Y)Z = ∇_X∇_Y Z − ∇_Y∇_X Z − ∇_[X,Y] Z', 'white', False),
        ('• The Riemann tensor is ALTERNATING:', 'white', False),
        ('  R(X,Y) = −R(Y,X)', '#FF6B6B', False),
        ('', 'white', False),
        ('SAME ALGEBRAIC STRUCTURE!', '#FFD93D', True),
        ('', 'white', False),
        ('Curvature = failure of parallel transport', '#DDA0DD', False),
        ('to be path-independent', '#DDA0DD', False),
        ('= failure of covariant derivatives to associate', '#DDA0DD', False),
        ('= the octonionic associator!', '#FFD93D', True),
    ]

    y = 0.92
    for text, color, bold in content:
        if text:
            ax2.text(0.05, y, text, fontsize=10 if not bold else 12,
                    fontweight='bold' if bold else 'normal',
                    color=color, transform=ax2.transAxes, va='top',
                    family='monospace' if '=' in text and not bold else 'sans-serif')
        y -= 0.048

    # ===== Panel 3: G₂ and exceptional holonomy =====
    ax3 = fig.add_subplot(223, facecolor='#0a0a1a')
    ax3.axis('off')
    ax3.set_title('G₂ = Aut(𝕆) and M-Theory\n(The exceptional holonomy group)',
                 color='white', fontsize=12, pad=10)

    g2_content = [
        ('G₂: The Automorphism Group of the Octonions', '#FFD93D', 13),
        ('', 'white', 10),
        ('dim(G₂) = 14', '#4ECDC4', 12),
        ('(= 7 × 6 / 3, from the Fano plane\'s 7 lines)', 'white', 9),
        ('', 'white', 10),
        ('G₂ is the smallest exceptional Lie group.', 'white', 10),
        ('It is the ONLY simple Lie group that preserves', 'white', 10),
        ('a generic 3-form in 7 dimensions.', 'white', 10),
        ('', 'white', 10),
        ('In M-theory (11d supergravity):', '#96CEB4', 12),
        ('', 'white', 10),
        ('• Compactify 11d → 4d on a 7-manifold M₇', 'white', 10),
        ('• For N=1 SUSY in 4d: Hol(M₇) = G₂', '#FF6B6B', 11),
        ('• G₂ manifolds are Ricci-flat (= vacuum Einstein)', 'white', 10),
        ('• The 7 extra dimensions are "shaped" by 𝕆!', '#FFD93D', 11),
        ('', 'white', 10),
        ('Why 7 extra dimensions?', '#4ECDC4', 12),
        ('Because dim(Im 𝕆) = 7.', '#4ECDC4', 12),
        ('It\'s not a choice — it\'s algebra.', '#FFD93D', 11),
    ]

    y = 0.92
    for text, color, fontsize in g2_content:
        if text:
            ax3.text(0.05, y, text, fontsize=fontsize, color=color,
                    fontweight='bold' if fontsize >= 12 else 'normal',
                    transform=ax3.transAxes, va='top')
        y -= 0.048

    # ===== Panel 4: The composition algebra and conservation =====
    ax4 = fig.add_subplot(224, facecolor='#0a0a1a')
    ax4.set_title('The 8-Square Identity (Degen, 1818)\n'
                 'Norm multiplicativity in the octonions',
                 color='white', fontsize=11, pad=10)

    # Plot the n-square identity existence
    dims = np.arange(1, 17)
    exists = [d in [1, 2, 4, 8] for d in dims]

    colors = ['#FF6B6B' if d == 1 else '#4ECDC4' if d == 2 else
              '#45B7D1' if d == 4 else '#96CEB4' if d == 8 else '#333333'
              for d in dims]

    alphas = [0.9 if e else 0.3 for e in exists]
    bars = ax4.bar(dims, [1 if e else 0.15 for e in exists],
                  color=colors, edgecolor='white', linewidth=0.5)
    for bar, a in zip(bars, alphas):
        bar.set_alpha(a)

    labels_map = {1: 'ℝ', 2: 'ℂ', 4: 'ℍ', 8: '𝕆'}
    for d in [1, 2, 4, 8]:
        ax4.text(d, 1.08, labels_map[d], fontsize=16, fontweight='bold',
                ha='center', color=colors[d-1])
        ax4.text(d, 0.5, '✓', fontsize=14, ha='center', color='white')

    # Mark the non-existent ones
    for d in dims:
        if d not in [1, 2, 4, 8]:
            ax4.text(d, 0.22, '✗', fontsize=10, ha='center', color='#FF0000',
                    alpha=0.5)

    ax4.set_xlabel('Dimension n', color='white', fontsize=11)
    ax4.set_ylabel('n-square identity exists?', color='white', fontsize=11)
    ax4.set_xticks(dims)
    ax4.set_ylim(0, 1.3)
    ax4.tick_params(colors='white')
    ax4.set_facecolor('#0a0a1a')
    ax4.spines['bottom'].set_color('white')
    ax4.spines['left'].set_color('white')
    ax4.spines['top'].set_visible(False)
    ax4.spines['right'].set_visible(False)

    ax4.text(8, -0.25, 'Hurwitz (1898): Only n = 1, 2, 4, 8 admit composition.\n'
            '|xy| = |x|·|y| only in division algebras!',
            fontsize=9, ha='center', color='#FFD93D', alpha=0.7,
            transform=ax4.transData)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/05_octonion_physics.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/05_octonion_physics.png")

if __name__ == '__main__':
    create_octonion_visualization()
