"""
Visualization: Spectral Complexity Landscape

Shows how depth and spectral norm interact to determine the
generalization bound, illustrating the depth-norm tradeoff.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def scc_value(depth, sigma, frob, margin):
    """Compute SCC for a homogeneous network."""
    L = depth
    R_eff = L * (frob / sigma) ** 2
    C_spec = sigma ** L / margin
    return L ** 2 * R_eff * C_spec ** 2


def scc_bound(scc_val, n, delta):
    inner = scc_val * math.log(2 * n) / n + math.log(1 / delta) / n
    return math.sqrt(max(0, inner))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    n, delta, frob, gamma = 5000, 0.05, 10.0, 1.0

    # Plot 1: Heatmap of SCC in (depth, sigma) space
    ax = axes[0]
    depths = np.arange(1, 21)
    sigmas = np.linspace(0.5, 3.0, 100)
    Z = np.zeros((len(sigmas), len(depths)))
    for i, s in enumerate(sigmas):
        for j, L in enumerate(depths):
            Z[i, j] = math.log10(max(1e-10, scc_value(L, s, frob, gamma)))

    im = ax.pcolormesh(depths, sigmas, Z, cmap='RdYlBu_r', shading='auto')
    plt.colorbar(im, ax=ax, label='log₁₀(SCC)')
    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Spectral Norm σ', fontsize=12)
    ax.set_title('SCC Landscape\n(F=10, γ=1)', fontsize=13)

    # Mark the σ=1 line (orthogonal)
    ax.axhline(y=1.0, color='white', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.text(15, 1.05, 'σ=1 (orthogonal)', color='white', fontsize=9)

    # Plot 2: Bound vs depth for different spectral norms
    ax = axes[1]
    depths_fine = np.arange(1, 31)
    for sigma, color, ls in [(0.8, '#2196F3', '-'), (1.0, '#4CAF50', '-'),
                               (1.2, '#FF9800', '-'), (1.5, '#FF5722', '-'),
                               (2.0, '#9C27B0', '-')]:
        bounds = []
        for L in depths_fine:
            scc = scc_value(L, sigma, frob, gamma)
            bounds.append(scc_bound(scc, n, delta))
        ax.plot(depths_fine, bounds, color=color, linewidth=2,
                linestyle=ls, label=f'σ={sigma}')

    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title(f'Bound vs Depth\n(n={n}, δ={delta})', fontsize=13)
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Effective rank contribution
    ax = axes[2]
    frob_values = np.linspace(1.01, 30, 200)
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (5, '#4CAF50'), (10, '#9C27B0')]:
        sigma = 1.0
        bounds = []
        eff_ranks = []
        for F in frob_values:
            eff_ranks.append(L * (F/sigma)**2)
            scc = scc_value(L, sigma, F, gamma)
            bounds.append(scc_bound(scc, n, delta))
        ax.plot(eff_ranks, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('Bound vs Effective Rank\n(σ=1 per layer)', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_spectral_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_spectral_landscape.png")


if __name__ == "__main__":
    main()
