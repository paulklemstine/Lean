#!/usr/bin/env python3
"""
Visualization: Probabilistic Lorentzian Stability — The 1/√n Law

This script produces a comprehensive visualization showing:
1. Survival probability heatmap across dimensions and exponents
2. The deterministic vs random threshold curves
3. Operator norm scaling verification

All functions are self-contained — no imports from local modules.
If using matplotlib, saves to PNG via plt.savefig().
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def make_lorentzian_matrix(n, gap=1.0):
    A = np.diag([-gap] * n)
    A[0, 0] = gap
    return A


def random_symmetric_perturbation(n, delta):
    E = np.random.uniform(-delta, delta, size=(n, n))
    return (E + E.T) / 2


def survival_probability(n, alpha, gap=1.0, n_trials=300):
    delta = gap / (n ** alpha)
    A = make_lorentzian_matrix(n, gap)
    count = 0
    for _ in range(n_trials):
        E = random_symmetric_perturbation(n, delta)
        eigvals = np.linalg.eigvalsh(A + E)
        if np.sum(eigvals > 1e-12) == 1:
            count += 1
    return count / n_trials


def main():
    np.random.seed(42)

    # Parameters
    dimensions = [5, 10, 20, 50, 100, 200]
    alphas = np.linspace(0.25, 1.1, 25)
    gap = 1.0

    # Compute survival probabilities
    print("Computing survival probabilities...")
    data = np.zeros((len(dimensions), len(alphas)))
    for i, n in enumerate(dimensions):
        for j, alpha in enumerate(alphas):
            data[i, j] = survival_probability(n, alpha, gap, n_trials=200)
            print(f"  n={n}, α={alpha:.2f}: p={data[i,j]:.2f}")

    # Compute operator norm scaling
    print("Computing operator norm scaling...")
    norm_dims = [5, 10, 20, 50, 100, 200, 500]
    norm_ratios = []
    for n in norm_dims:
        norms = []
        for _ in range(300):
            E = random_symmetric_perturbation(n, 1.0)
            norms.append(np.max(np.abs(np.linalg.eigvalsh(E))))
        norm_ratios.append(np.mean(norms) / np.sqrt(n))

    # === CREATE FIGURE ===
    fig = plt.figure(figsize=(18, 14))
    gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

    # Panel 1: Heatmap
    ax1 = fig.add_subplot(gs[0, 0])
    im = ax1.imshow(data, aspect='auto', cmap='RdYlGn',
                    extent=[alphas[0], alphas[-1], len(dimensions)-0.5, -0.5],
                    vmin=0, vmax=1)
    ax1.set_yticks(range(len(dimensions)))
    ax1.set_yticklabels([str(n) for n in dimensions])
    ax1.set_xlabel('Exponent α (δ = ε/n^α)', fontsize=12)
    ax1.set_ylabel('Dimension n', fontsize=12)
    ax1.set_title('Survival Probability Heatmap', fontsize=13, fontweight='bold')
    ax1.axvline(x=0.5, color='white', linestyle='--', linewidth=2, alpha=0.8)
    ax1.text(0.52, -0.3, 'α = ½', color='white', fontsize=11, fontweight='bold')
    plt.colorbar(im, ax=ax1, label='P(signature preserved)')

    # Panel 2: Survival curves
    ax2 = fig.add_subplot(gs[0, 1])
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(dimensions)))
    for i, n in enumerate(dimensions):
        ax2.plot(alphas, data[i], 'o-', color=colors[i], label=f'n={n}',
                 linewidth=2, markersize=4, alpha=0.8)
    ax2.axvline(x=0.5, color='red', linestyle='--', linewidth=2, alpha=0.7,
                label='α = ½')
    ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.4)
    ax2.set_xlabel('Exponent α', fontsize=12)
    ax2.set_ylabel('Survival Probability', fontsize=12)
    ax2.set_title('The 1/√n Law: Transition at α = ½', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9, ncol=2)
    ax2.set_ylim(-0.05, 1.05)
    ax2.grid(True, alpha=0.2)

    # Panel 3: Threshold comparison
    ax3 = fig.add_subplot(gs[1, 0])
    ns = np.arange(2, 501)
    ax3.semilogy(ns, gap / ns, 'b-', linewidth=2.5, label='Deterministic: ε/n')
    ax3.semilogy(ns, gap / np.sqrt(ns), 'r-', linewidth=2.5, label='Random: ε/√n')
    ax3.fill_between(ns, gap / ns, gap / np.sqrt(ns), alpha=0.12, color='green')
    ax3.annotate('√n improvement\n(new safe zone)',
                 xy=(100, gap / np.sqrt(100)), xytext=(200, 0.3),
                 fontsize=11, ha='center',
                 arrowprops=dict(arrowstyle='->', color='green', lw=2),
                 color='green', fontweight='bold')
    ax3.set_xlabel('Dimension n', fontsize=12)
    ax3.set_ylabel('Max Safe δ', fontsize=12)
    ax3.set_title('Deterministic vs Random Thresholds', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.2)

    # Panel 4: Operator norm scaling
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.plot(norm_dims, norm_ratios, 's-', color='purple', linewidth=2,
             markersize=8, label='Empirical ‖E‖/(√n·δ)')
    ax4.axhline(y=np.mean(norm_ratios[-3:]), color='purple', linestyle='--',
                alpha=0.5, label=f'Asymptotic C ≈ {np.mean(norm_ratios[-3:]):.2f}')
    ax4.set_xlabel('Dimension n', fontsize=12)
    ax4.set_ylabel('‖E‖_op / (√n · δ)', fontsize=12)
    ax4.set_title('Operator Norm Scaling Verification', fontsize=13, fontweight='bold')
    ax4.legend(fontsize=11)
    ax4.grid(True, alpha=0.2)
    ax4.set_ylim(0, max(norm_ratios) * 1.3)

    fig.suptitle('Probabilistic Lorentzian Stability: The 1/√n Law',
                 fontsize=16, fontweight='bold', y=0.98)

    plt.savefig('stability_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: stability_visualization.png")


if __name__ == "__main__":
    main()
