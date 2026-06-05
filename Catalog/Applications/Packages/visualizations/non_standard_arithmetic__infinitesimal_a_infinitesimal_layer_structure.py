#!/usr/bin/env python3
"""
Visualization: Infinitesimal/Bounded/Infinite Layer Structure

Shows the three-layer decomposition of a non-Archimedean ordered field:
- Infinitesimal core (green)
- Bounded ring (blue)
- Infinite elements (red)
With reciprocal duality arrows connecting them.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def create_layer_diagram():
    """Create the three-layer diagram of a non-Archimedean field."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Nested structure
    ax1.set_xlim(-5, 5)
    ax1.set_ylim(-5, 5)
    ax1.set_aspect('equal')
    ax1.set_title('Non-Archimedean Field Structure\n'
                   '(Three Algebraic Layers)', fontsize=13, fontweight='bold')

    # Infinite region (background)
    infinite_rect = patches.FancyBboxPatch(
        (-4.5, -4.5), 9, 9, boxstyle="round,pad=0.1",
        facecolor='#ffcccc', edgecolor='red', linewidth=2, alpha=0.5)
    ax1.add_patch(infinite_rect)

    # Bounded ring (middle circle)
    bounded_circle = plt.Circle((0, 0), 3, facecolor='#cce5ff',
                                 edgecolor='blue', linewidth=2, alpha=0.7)
    ax1.add_patch(bounded_circle)

    # Infinitesimal ideal (inner circle)
    inf_circle = plt.Circle((0, 0), 1, facecolor='#ccffcc',
                             edgecolor='green', linewidth=2, alpha=0.8)
    ax1.add_patch(inf_circle)

    # Labels
    ax1.text(0, 0, '0\n(infinitesimal)', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkgreen')
    ax1.text(0, 2, 'Bounded Elements\n(subring)', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkblue')
    ax1.text(0, -2, '±1, ±2, ..., ±n', ha='center', va='center',
             fontsize=9, color='navy')
    ax1.text(3.8, 3.8, 'Infinite\nElements', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkred')
    ax1.text(-3.8, -3.8, 'ω, ω², ...', ha='center', va='center',
             fontsize=9, color='darkred')

    # Reciprocal duality arrow
    ax1.annotate('', xy=(0.7, 0.3), xytext=(3.5, 3.5),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2))
    ax1.annotate('', xy=(3.5, 3.5), xytext=(0.7, 0.3),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2,
                               connectionstyle="arc3,rad=0.3"))
    ax1.text(2.5, 2.5, 'x ↔ x⁻¹\n(Reciprocal\nDuality)',
             ha='center', va='center', fontsize=9, color='purple',
             fontweight='bold', rotation=45)

    ax1.set_xlabel('Elements of F', fontsize=11)
    ax1.axis('off')

    # Right panel: n * |x| < 1 visualization
    ax2.set_title('Infinitesimal Test: n · |x| < 1\n'
                   'for all positive n', fontsize=13, fontweight='bold')

    x_vals = np.logspace(-4, 1, 200)
    n_vals = [1, 5, 10, 50, 100, 500]

    for n in n_vals:
        y = n * x_vals
        ax2.plot(x_vals, y, label=f'n = {n}', alpha=0.7)

    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
    ax2.fill_between(x_vals, 0, 1, alpha=0.1, color='green')

    ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.set_xlabel('|x|', fontsize=12)
    ax2.set_ylabel('n · |x|', fontsize=12)
    ax2.legend(fontsize=9, loc='upper left')
    ax2.set_ylim(1e-4, 1e4)
    ax2.grid(True, alpha=0.3)

    ax2.text(1e-3, 0.3, 'Infinitesimal\nregion', fontsize=11,
             color='green', fontweight='bold', ha='center')
    ax2.text(1, 10, 'Bounded but\nnot infinitesimal', fontsize=10,
             color='blue', ha='center')

    plt.tight_layout()
    plt.savefig('viz_infinitesimal_layers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_infinitesimal_layers.png")


def create_overspill_diagram():
    """Visualize the overspill principle."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title('Overspill Principle: Decreasing Chain with Overflow',
                 fontsize=13, fontweight='bold')

    N = 50
    # S_n = {i | i > n} for n = 0, 5, 10, ...
    chain_indices = list(range(0, 30, 3))

    for idx, n in enumerate(chain_indices):
        y = len(chain_indices) - idx
        members = [i for i in range(N) if i > n]
        non_members = [i for i in range(N) if i <= n]

        ax.scatter(members, [y] * len(members), c='blue', s=10, alpha=0.6)
        ax.scatter(non_members, [y] * len(non_members), c='lightgray', s=10, alpha=0.3)
        ax.text(-3, y, f'S_{n}', fontsize=9, ha='right', va='center')

    # Overflow function line: f(i) = i - 1
    overflow_x = list(range(1, N))
    overflow_y = [len(chain_indices) - (i - 1) / 3 for i in overflow_x]
    ax.plot(overflow_x, overflow_y, 'r-', linewidth=2, alpha=0.7,
            label='Overflow f(i) = i−1')

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Chain level (decreasing ↑)', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('viz_overspill.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_overspill.png")


if __name__ == "__main__":
    create_layer_diagram()
    create_overspill_diagram()
