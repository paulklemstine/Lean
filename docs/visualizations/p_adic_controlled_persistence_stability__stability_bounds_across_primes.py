"""
Visualization: Valuation-Sensitive Stability Bounds
====================================================

Visualizes how the stability modulus δ/p^ν decreases as the p-adic
valuation depth ν increases, for multiple primes simultaneously.

This plot is the core visual insight of arithmetic TDA:
primes of different sizes create different "damping profiles"
for topological stability bounds.
"""

import matplotlib.pyplot as plt
import numpy as np


def valuation_sensitive_shift(p, nu, delta):
    """Compute δ // p^ν."""
    return delta // (p ** nu)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # --- Panel 1: Bound vs ν for multiple primes ---
    ax = axes[0]
    delta = 1000
    primes = [2, 3, 5, 7, 11]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    max_nu = 8

    for p, color in zip(primes, colors):
        nus = list(range(max_nu + 1))
        bounds = [valuation_sensitive_shift(p, nu, delta) for nu in nus]
        ax.plot(nus, bounds, 'o-', color=color, label=f'p = {p}',
                markersize=6, linewidth=2)

    ax.axhline(y=delta, color='gray', linestyle='--', alpha=0.5,
               label=f'δ = {delta}')
    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Stability bound δ/p^ν', fontsize=12)
    ax.set_title('Stability Bound vs. Divisibility Depth', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Heatmap of bounds for p=2 ---
    ax = axes[1]
    p = 2
    deltas = np.arange(1, 65)
    nus = np.arange(0, 7)

    heatmap_data = np.zeros((len(nus), len(deltas)))
    for i, nu in enumerate(nus):
        for j, d in enumerate(deltas):
            heatmap_data[i, j] = valuation_sensitive_shift(p, nu, int(d))

    im = ax.imshow(heatmap_data, aspect='auto', cmap='viridis',
                   extent=[1, 64, 6.5, -0.5])
    ax.set_xlabel('δ (original shift)', fontsize=12)
    ax.set_ylabel('ν (valuation depth)', fontsize=12)
    ax.set_title(f'Shift Bound Heatmap (p = {p})', fontsize=13)
    ax.set_yticks(range(7))
    plt.colorbar(im, ax=ax, label='δ/p^ν')

    # --- Panel 3: Improvement ratio ---
    ax = axes[2]
    delta = 100

    for p, color in zip(primes, colors):
        nus = np.arange(0, 8)
        ratios = [valuation_sensitive_shift(p, int(nu), delta) / delta
                  for nu in nus]
        ax.plot(nus, ratios, 's-', color=color, label=f'p = {p}',
                markersize=6, linewidth=2)

    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Ratio (δ/p^ν) / δ', fontsize=12)
    ax.set_title('Relative Improvement Factor', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0.001)

    plt.suptitle('P-adic Controlled Persistence Stability',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_stability_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved viz_stability_bounds.png")


if __name__ == "__main__":
    main()
