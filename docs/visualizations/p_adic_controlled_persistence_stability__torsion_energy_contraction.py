"""
Visualization: Torsion Energy Contraction Under P-adic Scaling
===============================================================

Visualizes the energy dissipation phenomenon: when an element with
p^k-torsion is scaled by p^ν, its torsion order drops to k - ν.
This is the arithmetic analogue of energy decay in physical systems.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # --- Panel 1: Torsion order reduction ---
    ax = axes[0]
    max_k = 8
    colors_nu = plt.cm.RdYlBu(np.linspace(0.1, 0.9, max_k))

    for k in range(1, max_k + 1):
        nus = list(range(k + 1))
        residuals = [k - nu for nu in nus]
        ax.plot(nus, residuals, 'o-', color=colors_nu[k-1],
                label=f'k = {k}', markersize=5, linewidth=1.5)

    ax.set_xlabel('Scaling depth ν', fontsize=12)
    ax.set_ylabel('Residual torsion order (k - ν)', fontsize=12)
    ax.set_title('Torsion Order Reduction', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5,
               label='Complete annihilation')

    # --- Panel 2: Annihilation heatmap ---
    ax = axes[1]
    max_k_heat = 10
    max_nu_heat = 10

    heatmap = np.zeros((max_nu_heat, max_k_heat))
    for k in range(max_k_heat):
        for nu in range(max_nu_heat):
            if nu <= k:
                heatmap[nu, k] = k - nu
            else:
                heatmap[nu, k] = 0  # Completely annihilated

    im = ax.imshow(heatmap, aspect='auto', cmap='hot_r',
                   extent=[0.5, max_k_heat + 0.5, max_nu_heat - 0.5, -0.5])
    ax.set_xlabel('Original torsion order k', fontsize=12)
    ax.set_ylabel('Scaling depth ν', fontsize=12)
    ax.set_title('Residual Torsion Order Heatmap', fontsize=13)
    plt.colorbar(im, ax=ax, label='k - ν')

    # Add diagonal line where ν = k (complete annihilation)
    ax.plot([0.5, max_k_heat + 0.5], [-0.5, max_k_heat - 0.5],
            'w--', linewidth=2, alpha=0.7)
    ax.text(max_k_heat * 0.6, max_k_heat * 0.35, 'ν = k\n(annihilation)',
            color='white', fontsize=9, ha='center', fontweight='bold')

    # --- Panel 3: Multi-prime energy decay curves ---
    ax = axes[2]
    primes = [2, 3, 5, 7]
    prime_colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    delta = 1000

    for p, color in zip(primes, prime_colors):
        nus = np.arange(0, 12)
        # Normalized energy: (δ/p^ν) / δ
        energies = [delta // (p ** int(nu)) / delta for nu in nus]
        ax.plot(nus, energies, 'D-', color=color, label=f'p = {p}',
                markersize=5, linewidth=2)

    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Normalized energy E/E₀', fontsize=12)
    ax.set_title('Energy Decay by Prime', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-4)

    plt.suptitle('Torsion Energy Contraction in Arithmetic TDA',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_energy_contraction.png', dpi=150, bbox_inches='tight')
    print("Saved viz_energy_contraction.png")


if __name__ == "__main__":
    main()
