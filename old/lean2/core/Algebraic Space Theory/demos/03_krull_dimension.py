"""
Demo 3: Dimension from Prime Ideal Chains
==========================================
The Algebraic Theory of Space — Pillar III

Dimension of a space = Krull dimension of its ring
             = length of the longest chain of prime ideals.

We visualize how dimension 0, 1, 2, 3 emerge from algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from mpl_toolkits.mplot3d import Axes3D


def plot_dimension_ladder():
    """Show how Krull dimension builds up spatial dimension."""
    fig, axes = plt.subplots(1, 4, figsize=(20, 8))

    configs = [
        {
            'title': 'Dimension 0\nA = 𝔽₅ (a field)',
            'chain': ['(0)'],
            'chain_labels': ['(0) — the only\nprime ideal'],
            'space_desc': 'A single point',
            'color': '#e41a1c',
            'space_plot': lambda ax: ax.plot(0, 0, 'o', markersize=20, color='#e41a1c')
        },
        {
            'title': 'Dimension 1\nA = k[x]',
            'chain': ['(0)', '(x−a)'],
            'chain_labels': ['(0)', '(x−a)'],
            'space_desc': 'A line',
            'color': '#377eb8',
            'space_plot': lambda ax: (
                ax.plot(np.linspace(-2, 2, 100), np.zeros(100), '-',
                        color='#377eb8', lw=3),
                ax.plot(np.linspace(-1.5, 1.5, 7), np.zeros(7), 'o',
                        color='#377eb8', markersize=8)
            )
        },
        {
            'title': 'Dimension 2\nA = k[x,y]',
            'chain': ['(0)', '(x)', '(x,y)'],
            'chain_labels': ['(0)', '(x)', '(x,y−b)'],
            'space_desc': 'A plane',
            'color': '#4daf4a',
            'space_plot': lambda ax: (
                ax.fill([-2, 2, 2, -2], [-1.5, -1.5, 1.5, 1.5],
                        alpha=0.2, color='#4daf4a'),
                ax.plot([-2, 2, 2, -2, -2], [-1.5, -1.5, 1.5, 1.5, -1.5],
                        '-', color='#4daf4a', lw=2)
            )
        },
        {
            'title': 'Dimension 3\nA = k[x,y,z]',
            'chain': ['(0)', '(x)', '(x,y)', '(x,y,z)'],
            'chain_labels': ['(0)', '(x)', '(x,y)', '(x,y,z)'],
            'space_desc': '3-space',
            'color': '#984ea3',
            'space_plot': lambda ax: (
                ax.text(0, 0, '3D\nSPACE', ha='center', va='center',
                        fontsize=18, color='#984ea3', fontweight='bold'),
            )
        }
    ]

    for idx, cfg in enumerate(configs):
        ax = axes[idx]
        ax.set_xlim(-3, 3)
        ax.set_ylim(-2, 2 + len(cfg['chain']) * 1.5)

        # Draw the chain of prime ideals
        n = len(cfg['chain'])
        for i, label in enumerate(cfg['chain_labels']):
            y = 2 + i * 1.2
            ax.plot(0, y, 'o', color=cfg['color'], markersize=16, zorder=5)
            ax.text(0.5, y, label, fontsize=10, va='center', color=cfg['color'])
            if i > 0:
                ax.annotate('', xy=(0, y - 0.2), xytext=(0, y - 1.0),
                            arrowprops=dict(arrowstyle='->', color='gray', lw=2))
                ax.text(-0.8, y - 0.6, '⊊', fontsize=14, color='gray',
                        ha='center', va='center')

        # Dimension label
        ax.text(0, 1 + n * 1.2 + 0.5, f'Krull dim = {n-1}',
                ha='center', fontsize=13, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor=cfg['color'], alpha=0.15))

        # Space visualization at bottom
        cfg['space_plot'](ax)
        ax.text(0, -1.7, cfg['space_desc'], ha='center', fontsize=11,
                style='italic', color=cfg['color'])

        ax.set_title(cfg['title'], fontsize=12, fontweight='bold', pad=10)
        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_visible(False)

    fig.suptitle("Pillar III: Dimension = Length of Longest Prime Ideal Chain",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/03_dimension_ladder.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 03_dimension_ladder.png")


def plot_dimension_product():
    """Demonstrate dim(A ⊗ B) = dim(A) + dim(B) algebraically."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    ax.set_xlim(-1, 13)
    ax.set_ylim(-1, 7)
    ax.set_title("The Product Rule: dim(X × Y) = dim(X) + dim(Y)\n"
                 "Algebraically: Krull dim(A ⊗ B) = Krull dim(A) + Krull dim(B)",
                 fontsize=13, fontweight='bold')

    # Line × Line = Plane
    # k[x] ⊗ k[y] = k[x,y]

    # Left: Spec(k[x]) — a line
    ax.plot([0.5, 3.5], [5, 5], '-', color='#377eb8', lw=4)
    ax.text(2, 5.5, 'Line = Spec(k[x])\ndim = 1', ha='center',
            fontsize=11, color='#377eb8', fontweight='bold')

    # Middle: ×
    ax.text(4.5, 5, '×', fontsize=30, ha='center', va='center', fontweight='bold')

    # Right: Spec(k[y]) — a line
    ax.plot([5.5, 8.5], [5, 5], '-', color='#2ca02c', lw=4)
    ax.text(7, 5.5, 'Line = Spec(k[y])\ndim = 1', ha='center',
            fontsize=11, color='#2ca02c', fontweight='bold')

    # Equals
    ax.text(9.5, 5, '=', fontsize=30, ha='center', va='center', fontweight='bold')

    # Result: Spec(k[x,y]) — a plane
    ax.fill([10, 12.5, 12.5, 10], [4, 4, 6, 6], alpha=0.2, color='#984ea3')
    ax.plot([10, 12.5, 12.5, 10, 10], [4, 4, 6, 6, 4], '-', color='#984ea3', lw=2)
    ax.text(11.25, 3.5, 'Plane = Spec(k[x,y])\ndim = 2 = 1 + 1',
            ha='center', fontsize=11, color='#984ea3', fontweight='bold')

    # Algebraic version below
    ax.text(6, 2.5, 'Algebraically:', ha='center', fontsize=14, fontweight='bold')
    ax.text(6, 1.5, 'k[x]  ⊗  k[y]  ≅  k[x,y]', ha='center', fontsize=16,
            fontfamily='monospace', color='darkblue',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.text(6, 0.3,
            'Tensor product of algebras = Cartesian product of spaces\n'
            'Krull dim is additive under tensor product (for nice rings)',
            ha='center', fontsize=11, style='italic', color='gray')

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/03_dimension_product.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 03_dimension_product.png")


if __name__ == "__main__":
    plot_dimension_ladder()
    plot_dimension_product()
    print("\n🎯 Pillar III demos complete: Dimension from prime chains!")
