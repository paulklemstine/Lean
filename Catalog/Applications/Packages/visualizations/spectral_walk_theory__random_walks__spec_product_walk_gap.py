#!/usr/bin/env python3
"""
Visualization: Product Walk Spectral Gap

Shows that the product walk gap satisfies 1-(1-γ₁)(1-γ₂) ≥ min(γ₁,γ₂).
"""

import math

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Product gap as a function of γ₂, with γ₁ fixed
    gamma1_values = [0.1, 0.3, 0.5, 0.7, 0.9]
    gamma2s = np.linspace(0.01, 0.99, 200)
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(gamma1_values)))

    for g1, color in zip(gamma1_values, colors):
        product_gaps = 1 - (1 - g1) * (1 - gamma2s)
        min_gaps = np.minimum(g1, gamma2s)
        ax1.plot(gamma2s, product_gaps, color=color, linewidth=1.5,
                 label=f'$\\gamma_1 = {g1}$')
        ax1.plot(gamma2s, min_gaps, color=color, linewidth=0.8, linestyle='--',
                 alpha=0.5)

    ax1.set_xlabel(r'$\gamma_2$', fontsize=12)
    ax1.set_ylabel('Spectral gap', fontsize=12)
    ax1.set_title(r'Product Gap vs $\min(\gamma_1, \gamma_2)$', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Heatmap of product gap / min gap ratio
    g1_range = np.linspace(0.05, 0.95, 100)
    g2_range = np.linspace(0.05, 0.95, 100)
    G1, G2 = np.meshgrid(g1_range, g2_range)
    product_gap = 1 - (1 - G1) * (1 - G2)
    min_gap = np.minimum(G1, G2)
    ratio = product_gap / min_gap

    im = ax2.imshow(ratio, extent=[0.05, 0.95, 0.05, 0.95], origin='lower',
                    cmap='RdYlGn', vmin=1.0, vmax=3.0, aspect='auto')
    ax2.set_xlabel(r'$\gamma_1$', fontsize=12)
    ax2.set_ylabel(r'$\gamma_2$', fontsize=12)
    ax2.set_title(r'$\frac{1-(1-\gamma_1)(1-\gamma_2)}{\min(\gamma_1,\gamma_2)}$ (always $\geq 1$)',
                  fontsize=14)
    plt.colorbar(im, ax=ax2, label='Ratio')

    plt.tight_layout()
    plt.savefig('product_walk_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved product_walk_gap.png")


if __name__ == "__main__":
    main()
