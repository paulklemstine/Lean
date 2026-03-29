"""
Demo 6: Grand Unification — The Complete Rosetta Stone
======================================================
The Algebraic Theory of Space — Synthesis

A comprehensive visualization showing the complete duality between
Space and Algebra, with all five pillars unified into a single diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

def plot_rosetta_stone():
    """The grand Rosetta Stone of Space-Algebra duality."""
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)

    # Title
    ax.text(10, 13.5, "THE ALGEBRAIC THEORY OF SPACE",
            ha='center', fontsize=22, fontweight='bold', color='navy')
    ax.text(10, 12.8, "The Complete Rosetta Stone",
            ha='center', fontsize=14, style='italic', color='gray')

    # Two columns
    # Left: SPACE
    header_left = FancyBboxPatch((0.5, 11.5), 8, 1, boxstyle="round,pad=0.1",
                                  facecolor='#e8f0fe', edgecolor='dodgerblue', lw=2)
    ax.add_patch(header_left)
    ax.text(4.5, 12, 'GEOMETRY / TOPOLOGY', ha='center', va='center',
            fontsize=16, fontweight='bold', color='dodgerblue')

    # Right: ALGEBRA
    header_right = FancyBboxPatch((11.5, 11.5), 8, 1, boxstyle="round,pad=0.1",
                                   facecolor='#fef0e0', edgecolor='darkorange', lw=2)
    ax.add_patch(header_right)
    ax.text(15.5, 12, 'ALGEBRA', ha='center', va='center',
            fontsize=16, fontweight='bold', color='darkorange')

    # Center: duality arrows
    ax.text(10, 12, '⟷', fontsize=28, ha='center', va='center',
            fontweight='bold', color='crimson')

    # Rows
    rows = [
        ('I', 'Point x ∈ X', 'Maximal ideal 𝔪 ⊂ A\nor character χ: A → k', '#e41a1c'),
        ('II', 'Open set U ⊆ X', 'Basic open D(f) = {𝔭 : f ∉ 𝔭}', '#377eb8'),
        ('III', 'dim(X) = n', 'Krull dim(A) = n\n(longest prime chain)', '#4daf4a'),
        ('IV', 'Continuous f: X → Y', 'Ring hom f*: O(Y) → O(X)\n(arrows reverse!)', '#984ea3'),
        ('V', 'Curvature R ≠ 0', '[∇_X, ∇_Y] ≠ ∇_{[X,Y]}\n(derivations don\'t commute)', '#ff7f00'),
        ('', 'Closed subset Z ⊆ X', 'Ideal I ⊆ A\n(V(I) = {𝔭 ⊇ I})', '#8c564b'),
        ('', 'Vector bundle E → X', 'Fin. gen. projective module P\n(Serre-Swan theorem)', '#e377c2'),
        ('', 'Connected components', 'Idempotents e² = e ∈ A', '#7f7f7f'),
        ('', 'Compact space', 'Every ideal ⊆ maximal ideal\n(Zorn\'s lemma)', '#bcbd22'),
        ('', 'Hausdorff space', 'Characters separate points\n(Gelfand-Naimark)', '#17becf'),
    ]

    for i, (pillar, left_text, right_text, color) in enumerate(rows):
        y = 10.5 - i * 1.05
        bg_alpha = 0.12 if pillar else 0.05

        # Background stripe
        stripe = FancyBboxPatch((0.3, y - 0.4), 19.4, 0.85,
                                boxstyle="round,pad=0.05",
                                facecolor=color, alpha=bg_alpha,
                                edgecolor='none')
        ax.add_patch(stripe)

        # Pillar number
        if pillar:
            ax.text(0.7, y, pillar, ha='center', va='center',
                    fontsize=12, fontweight='bold', color=color,
                    bbox=dict(boxstyle='circle', facecolor=color, alpha=0.2))

        # Left text
        ax.text(4.5, y, left_text, ha='center', va='center',
                fontsize=11, color=color)

        # Arrow
        ax.text(10, y, '⟷', ha='center', va='center',
                fontsize=16, color=color)

        # Right text
        ax.text(15.5, y, right_text, ha='center', va='center',
                fontsize=10, color=color)

    # Bottom: the fundamental theorem
    theorem_box = FancyBboxPatch((2, 0.3), 16, 1.4, boxstyle="round,pad=0.2",
                                  facecolor='#fff8dc', edgecolor='darkgoldenrod', lw=2)
    ax.add_patch(theorem_box)
    ax.text(10, 1.3, 'FUNDAMENTAL THEOREM (Gelfand-Naimark-Serre-Swan):',
            ha='center', fontsize=12, fontweight='bold', color='darkgoldenrod')
    ax.text(10, 0.7,
            'CptHaus^op  ≃  CommC*Alg        (compact Hausdorff spaces ↔ commutative C*-algebras)',
            ha='center', fontsize=11, fontfamily='serif', color='darkgoldenrod')

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/06_rosetta_stone.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 06_rosetta_stone.png")


def plot_theory_map():
    """Show the web of connections in the theory."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 14))
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')

    # Central node
    ax.plot(0, 0, 'o', markersize=50, color='gold', zorder=5)
    ax.text(0, 0, 'SPACE\n=\nALGEBRA', ha='center', va='center',
            fontsize=11, fontweight='bold', color='darkgoldenrod')

    # Five pillars as satellite nodes
    pillars = [
        (0, 3.5, 'I. Points\n= Max Ideals', '#e41a1c'),
        (3.3, 1.1, 'II. Topology\n= Ideal Lattice', '#377eb8'),
        (2.0, -2.8, 'III. Dimension\n= Krull dim', '#4daf4a'),
        (-2.0, -2.8, 'IV. Continuity\n= Ring Homs', '#984ea3'),
        (-3.3, 1.1, 'V. Curvature\n= [∇,∇]', '#ff7f00'),
    ]

    for x, y, label, color in pillars:
        ax.plot(x, y, 'o', markersize=35, color=color, alpha=0.3, zorder=4)
        ax.text(x, y, label, ha='center', va='center',
                fontsize=9, fontweight='bold', color=color)
        ax.annotate('', xy=(x*0.55, y*0.55), xytext=(x*0.85, y*0.85),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2, alpha=0.5))

    # Connections between pillars (the web)
    for i in range(5):
        for j in range(i+1, 5):
            x1, y1 = pillars[i][0], pillars[i][1]
            x2, y2 = pillars[j][0], pillars[j][1]
            ax.plot([x1, x2], [y1, y2], '-', color='lightgray',
                    lw=1, alpha=0.4, zorder=1)

    # Applications around the outer ring
    applications = [
        (0, 4.8, 'Algebraic\nGeometry'),
        (4.5, 1.5, 'Noncommutative\nGeometry'),
        (2.8, -3.9, 'General\nRelativity'),
        (-2.8, -3.9, 'Quantum\nMechanics'),
        (-4.5, 1.5, 'String\nTheory'),
    ]

    for x, y, label in applications:
        ax.text(x, y, label, ha='center', va='center',
                fontsize=9, style='italic', color='gray',
                bbox=dict(boxstyle='round', facecolor='whitesmoke', alpha=0.7))

    ax.set_title("The Web of the Algebraic Theory of Space",
                 fontsize=16, fontweight='bold', pad=20)
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/06_theory_map.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 06_theory_map.png")


if __name__ == "__main__":
    plot_rosetta_stone()
    plot_theory_map()
    print("\n🎯 Grand Unification demos complete!")
