"""
Demo 4: Arrows Reverse — Contravariance of Space and Algebra
=============================================================
The Algebraic Theory of Space — Pillar IV

The deepest structural insight: maps between spaces correspond to
maps between algebras IN THE OPPOSITE DIRECTION.

    f: X → Y    ↔    f*: O(Y) → O(X)

Embedding ↔ Surjection, Surjection ↔ Injection.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def plot_arrows_reverse():
    """Visualize the contravariance principle."""
    fig, axes = plt.subplots(3, 1, figsize=(16, 14))

    # Example 1: Embedding S¹ ↪ ℝ² ↔ Surjection ℝ[x,y] ↠ ℝ[x,y]/(x²+y²-1)
    ax = axes[0]
    ax.set_xlim(-1, 17)
    ax.set_ylim(-1.5, 2.5)
    ax.set_title("Example 1: Embedding a circle in the plane",
                 fontsize=13, fontweight='bold')

    # Space side
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(1.5 + 0.8*np.cos(theta), 0.5 + 0.8*np.sin(theta),
            '-', color='crimson', lw=3)
    ax.text(1.5, -0.8, 'S¹', ha='center', fontsize=14,
            color='crimson', fontweight='bold')

    ax.annotate('', xy=(5, 0.5), xytext=(3, 0.5),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))
    ax.text(4, 0.9, 'embed\n↪', ha='center', fontsize=11)

    ax.fill([4.5, 7.5, 7.5, 4.5], [-0.5, -0.5, 1.5, 1.5],
            alpha=0.15, color='dodgerblue')
    ax.plot([4.5, 7.5, 7.5, 4.5, 4.5], [-0.5, -0.5, 1.5, 1.5, -0.5],
            '-', color='dodgerblue', lw=2)
    ax.text(6, -0.8, 'ℝ²', ha='center', fontsize=14,
            color='dodgerblue', fontweight='bold')

    # Algebra side (arrows reversed!)
    ax.text(9, 0.5, '⟷', fontsize=24, ha='center', va='center',
            fontweight='bold', color='green')
    ax.text(9, 1.5, 'DUALITY', ha='center', fontsize=10,
            color='green', fontweight='bold')

    # Algebra boxes
    ax.text(12, 0.5, 'ℝ[x,y]/(x²+y²−1)', ha='center', va='center',
            fontsize=12, color='crimson', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#ffe0e0', alpha=0.8))

    ax.annotate('', xy=(12, 0.5), xytext=(15, 0.5),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))
    ax.text(13.5, 0.9, 'surject\n↠', ha='center', fontsize=11)

    ax.text(15.5, 0.5, 'ℝ[x,y]', ha='center', va='center',
            fontsize=12, color='dodgerblue', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#e0e8ff', alpha=0.8))

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    # Example 2: Projection ℝ² → ℝ ↔ Injection ℝ[x] ↪ ℝ[x,y]
    ax = axes[1]
    ax.set_xlim(-1, 17)
    ax.set_ylim(-1.5, 2.5)
    ax.set_title("Example 2: Projecting the plane to a line",
                 fontsize=13, fontweight='bold')

    # Space side
    ax.fill([0.5, 3.5, 3.5, 0.5], [-0.5, -0.5, 1.5, 1.5],
            alpha=0.15, color='dodgerblue')
    ax.plot([0.5, 3.5, 3.5, 0.5, 0.5], [-0.5, -0.5, 1.5, 1.5, -0.5],
            '-', color='dodgerblue', lw=2)
    ax.text(2, -0.8, 'ℝ²', ha='center', fontsize=14,
            color='dodgerblue', fontweight='bold')

    ax.annotate('', xy=(6.5, 0.5), xytext=(4, 0.5),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))
    ax.text(5.2, 0.9, 'project\nπ₁', ha='center', fontsize=11)

    ax.plot([5, 8], [0.5, 0.5], '-', color='crimson', lw=3)
    ax.text(6.5, -0.3, 'ℝ', ha='center', fontsize=14,
            color='crimson', fontweight='bold')

    # Algebra side
    ax.text(9, 0.5, '⟷', fontsize=24, ha='center', va='center',
            fontweight='bold', color='green')

    ax.text(12, 0.5, 'ℝ[x,y]', ha='center', va='center',
            fontsize=12, color='dodgerblue', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#e0e8ff', alpha=0.8))

    ax.annotate('', xy=(12, 0.5), xytext=(15, 0.5),
                arrowprops=dict(arrowstyle='<-', color='black', lw=2))
    ax.text(13.5, 0.9, 'inject\n↪', ha='center', fontsize=11)

    ax.text(15.5, 0.5, 'ℝ[x]', ha='center', va='center',
            fontsize=12, color='crimson', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#ffe0e0', alpha=0.8))

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    # Summary
    ax = axes[2]
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 4)
    ax.set_title("The Contravariance Principle", fontsize=14, fontweight='bold')

    table_data = [
        ('Space Map', 'Algebra Map', 'Intuition'),
        ('f: X ↪ Y (embed)', 'f*: O(Y) ↠ O(X) (surject)',
         'Fewer points → fewer functions needed'),
        ('f: X ↠ Y (surject)', 'f*: O(Y) ↪ O(X) (inject)',
         'Collapsing points → functions must agree'),
        ('f: X ≅ Y (homeo)', 'f*: O(Y) ≅ O(X) (iso)',
         'Same space → same algebra'),
    ]

    for i, row in enumerate(table_data):
        y = 3.2 - i * 0.8
        weight = 'bold' if i == 0 else 'normal'
        color = 'black' if i == 0 else ['#1f77b4', '#2ca02c', '#d62728'][i-1]
        ax.text(2, y, row[0], ha='center', fontsize=11, fontweight=weight, color=color)
        ax.text(8, y, row[1], ha='center', fontsize=11, fontweight=weight, color=color)
        ax.text(13.5, y, row[2], ha='center', fontsize=9, fontweight=weight,
                color=color, style='italic')

    ax.axhline(y=2.7, color='gray', lw=0.5, xmin=0.05, xmax=0.95)

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    fig.suptitle("Pillar IV: Arrows Reverse Under Space-Algebra Duality",
                 fontsize=16, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/04_arrows_reverse.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 04_arrows_reverse.png")


if __name__ == "__main__":
    plot_arrows_reverse()
    print("\n🎯 Pillar IV demo complete: Arrows reverse!")
