"""
Demo 1: Points Emerge from Algebra
===================================
The Algebraic Theory of Space — Pillar I

Shows how "points" of a space emerge as maximal ideals of a ring.
For the polynomial ring k[x], maximal ideals (x - a) correspond to
points a on the number line.

For k[x,y], maximal ideals (x - a, y - b) correspond to points (a,b)
in the plane.

We visualize the spectrum of various rings and show how algebraic
structure creates geometric structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection

def plot_spec_line():
    """Visualize Spec(ℝ[x]) — the affine line."""
    fig, axes = plt.subplots(2, 1, figsize=(14, 8))

    # Top: The algebraic side — ideals of ℝ[x]
    ax = axes[0]
    ax.set_xlim(-5, 5)
    ax.set_ylim(-0.5, 3)
    ax.set_title("Algebraic Side: Ideals of ℝ[x]", fontsize=14, fontweight='bold')

    # Generic point (0) — the zero ideal (prime but not maximal)
    ax.plot(0, 2.5, 'o', color='gold', markersize=20, zorder=5)
    ax.annotate('(0)\ngeneric point', (0, 2.5), textcoords="offset points",
                xytext=(30, 0), fontsize=11, color='gold',
                arrowprops=dict(arrowstyle='->', color='gold'))

    # Maximal ideals (x - a) for various a
    points = np.linspace(-4, 4, 9)
    for a in points:
        ax.plot(a, 1, 's', color='dodgerblue', markersize=12, zorder=5)
        ax.annotate(f'(x{"+" if -a>=0 else ""}{-a:.0f})', (a, 1),
                    textcoords="offset points", xytext=(0, -20),
                    fontsize=8, ha='center', color='dodgerblue')

    # Arrows showing containment: (0) ⊂ (x-a)
    for a in points:
        ax.annotate('', xy=(a, 1.15), xytext=(0, 2.35),
                    arrowprops=dict(arrowstyle='->', color='lightgray', lw=0.5))

    ax.text(-4.8, 2.5, 'Prime ideal\n(not maximal)', fontsize=9,
            color='gold', style='italic')
    ax.text(-4.8, 1, 'Maximal ideals\n= "points"', fontsize=9,
            color='dodgerblue', style='italic')
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

    # Bottom: The spatial side — the affine line
    ax = axes[1]
    ax.set_xlim(-5, 5)
    ax.set_ylim(-0.5, 1.5)
    ax.set_title("Spatial Side: The Affine Line (emerged from algebra!)",
                 fontsize=14, fontweight='bold')

    ax.axhline(y=0.5, color='dodgerblue', lw=2, alpha=0.3)
    for a in points:
        ax.plot(a, 0.5, 'o', color='dodgerblue', markersize=10, zorder=5)
        ax.annotate(f'{a:.0f}', (a, 0.5), textcoords="offset points",
                    xytext=(0, -18), fontsize=10, ha='center')

    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

    # Connection arrow
    fig.text(0.5, 0.48, '⟱  Maximal ideals (x−a)  become  points a  ⟱',
             ha='center', fontsize=13, color='crimson', fontweight='bold')

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    fig.suptitle("Pillar I: Points Emerge from Algebra",
                 fontsize=16, fontweight='bold', y=0.99)
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/01_points_from_algebra.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 01_points_from_algebra.png")


def plot_spec_plane():
    """Visualize Spec(ℝ[x,y]) — the affine plane."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_title("Spec(ℝ[x,y]) — The Plane Emerges from Algebra",
                 fontsize=14, fontweight='bold')
    ax.set_xlabel("x", fontsize=12)
    ax.set_ylabel("y", fontsize=12)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Maximal ideals (x-a, y-b) = points
    grid = np.arange(-3, 4, 1)
    for a in grid:
        for b in grid:
            ax.plot(a, b, 'o', color='dodgerblue', markersize=6, alpha=0.6)

    # Some prime ideals (curves)
    t = np.linspace(-3.5, 3.5, 200)

    # (y - x²) = parabola
    mask = np.abs(t**2) < 4
    ax.plot(t[mask], t[mask]**2, '-', color='crimson', lw=2, label='V(y − x²)')
    ax.annotate('Prime ideal (y−x²)\n= parabola', xy=(1.5, 2.25),
                fontsize=9, color='crimson', style='italic')

    # (x² + y² - 4) = circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(2*np.cos(theta), 2*np.sin(theta), '-', color='forestgreen',
            lw=2, label='V(x²+y²−4)')
    ax.annotate('Prime ideal (x²+y²−4)\n= circle', xy=(1.5, -1.5),
                fontsize=9, color='forestgreen', style='italic')

    # (x) = y-axis
    ax.axvline(x=0, color='darkorange', lw=2, alpha=0.7, label='V(x)')
    ax.annotate('Prime ideal (x)\n= y-axis', xy=(0.2, 3.5),
                fontsize=9, color='darkorange', style='italic')

    ax.legend(loc='upper left', fontsize=10)

    # Annotation
    ax.text(-3.8, -3.8,
            "• Blue dots = maximal ideals (x−a, y−b) = POINTS\n"
            "• Colored curves = prime ideals (f(x,y)) = SUBSPACES\n"
            "• The plane wasn't assumed — it EMERGED from ℝ[x,y]",
            fontsize=9, verticalalignment='bottom',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/01b_spec_plane.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 01b_spec_plane.png")


def plot_spec_integers():
    """Visualize Spec(ℤ) — one of the most beautiful objects in math."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 6))

    ax.set_xlim(-1, 15)
    ax.set_ylim(-1, 5)
    ax.set_title("Spec(ℤ) — The Integers as a Space",
                 fontsize=16, fontweight='bold')

    # Generic point (0)
    ax.plot(7, 4, 'o', color='gold', markersize=30, zorder=5, alpha=0.8)
    ax.text(7, 4, '(0)', ha='center', va='center', fontsize=11, fontweight='bold')
    ax.text(7, 4.7, 'generic point\n(the "soul" of Spec(ℤ))',
            ha='center', fontsize=9, color='gold', style='italic')

    # Maximal ideals (p) for primes
    primes = [2, 3, 5, 7, 11, 13]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

    for i, (p, col) in enumerate(zip(primes, colors)):
        x = 1 + i * 2.3
        ax.plot(x, 1, 's', color=col, markersize=18, zorder=5)
        ax.text(x, 1, f'({p})', ha='center', va='center',
                fontsize=11, fontweight='bold', color='white')
        ax.text(x, 0.2, f'𝔽_{p}', ha='center', fontsize=10, color=col)

        # Arrow from (0) to (p)
        ax.annotate('', xy=(x, 1.35), xytext=(7, 3.7),
                    arrowprops=dict(arrowstyle='->', color=col, lw=1, alpha=0.4))

    ax.text(7.5, 2.5, '(0) ⊂ (p)\ncontainment = specialization',
            fontsize=9, color='gray', style='italic')

    ax.text(0, -0.5,
            "Spec(ℤ) has one point for each prime number, plus a generic point.\n"
            "The generic point (0) is \"dense\" — it belongs to every open set.\n"
            "Each closed point (p) carries a residue field 𝔽ₚ = ℤ/pℤ.\n"
            "Number theory IS geometry on this space!",
            fontsize=10, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/01c_spec_integers.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 01c_spec_integers.png")


if __name__ == "__main__":
    plot_spec_line()
    plot_spec_plane()
    plot_spec_integers()
    print("\n🎯 Pillar I demos complete: Points emerge from algebras!")
