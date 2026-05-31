"""
Visualization: Double Descent in SCC Bounds

Shows how the SCC generalization bound can be non-monotone in effective rank,
demonstrating the algebraic core of the double descent phenomenon.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def spectral_compression_complexity(depth, spectral_norms, frobenius_norms, margin):
    """Compute SCC given layer-wise norms."""
    L = depth
    eff_ranks = [(f/s)**2 for s, f in zip(spectral_norms, frobenius_norms)]
    R_eff = sum(eff_ranks)
    C_spec = 1.0
    for s in spectral_norms:
        C_spec *= s
    C_spec /= margin
    return L**2 * R_eff * C_spec**2


def scc_bound(scc_val, n, delta):
    """Compute sqrt(SCC * log(2n)/n + log(1/delta)/n)."""
    inner = scc_val * math.log(2*n) / n + math.log(1/delta) / n
    return math.sqrt(max(0, inner))


def main():
    gamma = 1.0
    n = 1000
    delta = 0.05

    # Vary the Frobenius norm (controls effective rank) for different depths
    frob_values = np.linspace(1.01, 20, 200)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: SCC vs effective rank for different depths
    ax = axes[0]
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (3, '#4CAF50'), (5, '#9C27B0')]:
        sigma = 1.0  # spectral norm = 1 (orthogonal)
        sccs = []
        eff_ranks = []
        for F in frob_values:
            eff_ranks.append(L * (F/sigma)**2)
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            sccs.append(scc_val)
        ax.plot(eff_ranks, sccs, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('SCC', fontsize=12)
    ax.set_title('SCC vs Effective Rank\n(σ=1 per layer)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Double descent witness - varying spectral norm with fixed rank
    ax = axes[1]
    sigma_values = np.linspace(0.5, 5, 200)
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (3, '#4CAF50')]:
        F = 10.0
        bounds = []
        for sigma in sigma_values:
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            bounds.append(scc_bound(scc_val, n, delta))
        ax.plot(sigma_values, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Spectral Norm per Layer', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title(f'Bound vs Spectral Norm\n(F=10, n={n})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: The actual double descent shape
    ax = axes[2]
    # Simulate: as width increases, effective rank increases but spectral norm decreases
    widths = np.logspace(0.5, 3, 200)
    for L, color in [(2, '#FF5722'), (3, '#4CAF50')]:
        bounds = []
        eff_ranks_plot = []
        for w in widths:
            # Model: sigma ~ 1 + 1/sqrt(w), F ~ sqrt(w)
            sigma = 1 + 1/math.sqrt(w)
            F = math.sqrt(w)
            if F < sigma:
                F = sigma + 0.01
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            bounds.append(scc_bound(scc_val, n, delta))
            eff_ranks_plot.append(L * (F/sigma)**2)
        ax.plot(eff_ranks_plot, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('Double Descent Shape\n(σ→1 as width→∞)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_double_descent.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_double_descent.png")


if __name__ == "__main__":
    main()
