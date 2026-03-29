"""
Demo 2: Topology from Algebra — The Zariski Topology
=====================================================
The Algebraic Theory of Space — Pillar II

Shows how the topology of a space is encoded in the ideal structure
of its coordinate ring. The Galois connection between ideals and
closed sets is visualized.

Key idea: Open sets D(f) = {p ∈ Spec(A) : f ∉ p} form a basis
for the Zariski topology. Closed sets V(I) = {p : I ⊆ p}.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle, FancyBboxPatch
import matplotlib.gridspec as gridspec

def plot_galois_connection():
    """Visualize the Galois connection between ideals and closed sets."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 10))

    # Left: Lattice of ideals of ℝ[x,y]/(xy)
    # This ring represents two intersecting lines (x-axis and y-axis)
    ax1.set_xlim(-1, 5)
    ax1.set_ylim(-0.5, 6)
    ax1.set_title("Ideal Lattice of ℝ[x,y]/(xy)", fontsize=13, fontweight='bold')

    ideals = {
        'A': (2.5, 5.5, '(1) = A\n(whole ring)', '#d62728'),
        'x': (1, 4, '(x)', '#1f77b4'),
        'y': (4, 4, '(y)', '#2ca02c'),
        'xy': (2.5, 2.5, '(x,y)\n= maximal', '#9467bd'),
        '0': (2.5, 1, '(0)', '#8c564b'),
    }

    for key, (x, y, label, color) in ideals.items():
        ax1.plot(x, y, 'o', color=color, markersize=20, zorder=5)
        offset = (15, 0) if key not in ['xy', 'A', '0'] else (20, 0)
        ax1.annotate(label, (x, y), textcoords="offset points",
                     xytext=offset, fontsize=11, color=color, fontweight='bold')

    # Containment arrows (Hasse diagram)
    edges = [('0', 'x'), ('0', 'y'), ('x', 'xy'), ('y', 'xy'), ('xy', 'A')]
    for a, b in edges:
        x1, y1 = ideals[a][0], ideals[a][1]
        x2, y2 = ideals[b][0], ideals[b][1]
        ax1.annotate('', xy=(x2, y2-0.2), xytext=(x1, y1+0.2),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax1.text(0, 0, '⊆ = containment\n(upward)', fontsize=9,
             color='gray', style='italic')
    ax1.set_xticks([])
    ax1.set_yticks([])
    for spine in ax1.spines.values():
        spine.set_visible(False)

    # Right: Corresponding closed sets in Spec
    ax2.set_xlim(-1, 5)
    ax2.set_ylim(-0.5, 6)
    ax2.set_title("Closed Sets of Spec(ℝ[x,y]/(xy))", fontsize=13, fontweight='bold')

    closed_sets = {
        'empty': (2.5, 5.5, 'V(1) = ∅', '#d62728'),
        'yaxis': (1, 4, 'V(x) = {y-axis points}', '#1f77b4'),
        'xaxis': (4, 4, 'V(y) = {x-axis points}', '#2ca02c'),
        'origin': (2.5, 2.5, 'V(x,y) = {origin}', '#9467bd'),
        'whole': (2.5, 1, 'V(0) = Spec (whole space)', '#8c564b'),
    }

    for key, (x, y, label, color) in closed_sets.items():
        ax2.plot(x, y, 's', color=color, markersize=20, zorder=5)
        offset = (15, 0) if key not in ['origin', 'empty', 'whole'] else (20, 0)
        ax2.annotate(label, (x, y), textcoords="offset points",
                     xytext=offset, fontsize=10, color=color, fontweight='bold')

    # Containment arrows (reversed! — antitone)
    edges_rev = [('empty', 'yaxis'), ('empty', 'xaxis'),
                 ('yaxis', 'origin'), ('xaxis', 'origin'), ('origin', 'whole')]
    for a, b in edges_rev:
        x1, y1 = closed_sets[a][0], closed_sets[a][1]
        x2, y2 = closed_sets[b][0], closed_sets[b][1]
        ax2.annotate('', xy=(x2, y2-0.2), xytext=(x1, y1+0.2),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax2.text(0, 0, '⊇ = containment\n(reversed!)', fontsize=9,
             color='gray', style='italic')
    ax2.set_xticks([])
    ax2.set_yticks([])
    for spine in ax2.spines.values():
        spine.set_visible(False)

    # Big arrow between
    fig.text(0.5, 0.5, '⟷\nV(·)', ha='center', va='center',
             fontsize=20, color='crimson', fontweight='bold')

    fig.suptitle("Pillar II: Topology IS the Ideal Lattice (Reversed)",
                 fontsize=16, fontweight='bold')
    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/02_galois_connection.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 02_galois_connection.png")


def plot_zariski_vs_euclidean():
    """Compare Zariski and Euclidean topologies on ℝ²."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Euclidean topology: open sets are unions of open balls
    ax = axes[0]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title("Euclidean Topology on ℝ²\n(familiar)", fontsize=13, fontweight='bold')

    # Draw some open balls
    for _ in range(8):
        cx, cy = np.random.uniform(-2, 2, 2)
        r = np.random.uniform(0.3, 1.0)
        circle = plt.Circle((cx, cy), r, fill=True, alpha=0.15,
                            color=np.random.choice(['blue', 'green', 'red', 'purple']))
        ax.add_patch(circle)
        circle2 = plt.Circle((cx, cy), r, fill=False, alpha=0.5,
                             color='gray', linestyle='--')
        ax.add_patch(circle2)

    ax.text(-2.8, -2.8, "Open sets = unions of open balls\n"
            "Very many open sets\n"
            "Hausdorff (points can be separated)",
            fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.grid(True, alpha=0.15)

    # Zariski topology: closed sets are algebraic varieties
    ax = axes[1]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title("Zariski Topology on ℝ²\n(algebraic)", fontsize=13, fontweight='bold')

    # Closed sets are algebraic curves and points
    t = np.linspace(-3, 3, 300)

    # A parabola (closed set)
    mask = np.abs(t**2) < 3
    ax.plot(t[mask], t[mask]**2, '-', color='crimson', lw=3, alpha=0.7)
    ax.fill_between(t[mask], t[mask]**2 - 0.05, t[mask]**2 + 0.05,
                    color='crimson', alpha=0.1)
    ax.text(1.2, 1.8, 'V(y−x²)', color='crimson', fontsize=10, fontweight='bold')

    # A line (closed set)
    ax.plot(t, 0.5*t + 0.5, '-', color='blue', lw=3, alpha=0.7)
    ax.text(-2.5, -0.3, 'V(2y−x−1)', color='blue', fontsize=10, fontweight='bold')

    # Isolated points (closed)
    ax.plot([1, -1], [0, 0], 'o', color='green', markersize=10)
    ax.text(1.2, -0.3, 'V(y, x²−1)', color='green', fontsize=10)

    # Background is the complement = open set
    ax.set_facecolor('#f0f8ff')

    ax.text(-2.8, -2.8,
            "Closed sets = zero sets of polynomials\n"
            "Very few closed sets (coarse topology!)\n"
            "NOT Hausdorff — points cannot be separated",
            fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.grid(True, alpha=0.15)

    fig.suptitle("Two Topologies, One Space: Algebra Chooses Zariski",
                 fontsize=15, fontweight='bold')
    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/02_zariski_vs_euclidean.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 02_zariski_vs_euclidean.png")


if __name__ == "__main__":
    np.random.seed(42)
    plot_galois_connection()
    plot_zariski_vs_euclidean()
    print("\n🎯 Pillar II demos complete: Topology from algebra!")
