"""
Visualization: Prime Spectrum of Stability Bounds
==================================================

Shows the "arithmetic frequency spectrum" of persistence stability:
how different primes contribute different damping profiles,
creating a rich multi-scale picture of topological noise attenuation.
"""

import matplotlib.pyplot as plt
import numpy as np


def valuation_sensitive_shift(p, nu, delta):
    """Compute δ // p^ν."""
    return delta // (p ** nu)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # --- Panel 1: Bar chart comparing bounds across primes ---
    ax = axes[0, 0]
    delta = 720  # = 2^4 * 3^2 * 5 (highly composite)
    primes = [2, 3, 5, 7, 11, 13]
    max_nu = 4

    x = np.arange(len(primes))
    width = 0.15
    cmap = plt.cm.Blues

    for nu in range(max_nu + 1):
        bounds = [valuation_sensitive_shift(p, nu, delta) for p in primes]
        color = cmap(0.3 + 0.15 * nu)
        bars = ax.bar(x + nu * width, bounds, width, label=f'ν = {nu}',
                      color=color, edgecolor='gray', linewidth=0.5)

    ax.set_xticks(x + width * max_nu / 2)
    ax.set_xticklabels([f'p={p}' for p in primes])
    ax.set_ylabel('Stability bound δ/p^ν', fontsize=12)
    ax.set_title(f'Primewise Bounds (δ = {delta})', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2, axis='y')

    # --- Panel 2: Factorization structure ---
    ax = axes[0, 1]
    # Show how δ's factorization determines which primes give the best bounds
    deltas = [60, 120, 180, 360, 720, 1080]
    primes_check = [2, 3, 5]

    data = np.zeros((len(deltas), len(primes_check)))
    for i, d in enumerate(deltas):
        for j, p in enumerate(primes_check):
            # Best improvement ratio at ν=1
            data[i, j] = valuation_sensitive_shift(p, 1, d) / d

    im = ax.imshow(data, aspect='auto', cmap='RdYlGn_r')
    ax.set_xticks(range(len(primes_check)))
    ax.set_xticklabels([f'p={p}' for p in primes_check])
    ax.set_yticks(range(len(deltas)))
    ax.set_yticklabels([str(d) for d in deltas])
    ax.set_xlabel('Prime', fontsize=12)
    ax.set_ylabel('δ', fontsize=12)
    ax.set_title('Improvement Ratio at ν=1', fontsize=13)
    plt.colorbar(im, ax=ax, label='(δ/p)/δ')

    # Annotate cells
    for i in range(len(deltas)):
        for j in range(len(primes_check)):
            ax.text(j, i, f'{data[i,j]:.2f}', ha='center', va='center',
                    fontsize=9, color='black' if data[i,j] > 0.3 else 'white')

    # --- Panel 3: Monotonicity surface ---
    ax = axes[1, 0]
    p = 2
    deltas_range = np.arange(1, 101)
    nus_range = np.arange(0, 8)

    D, N = np.meshgrid(deltas_range, nus_range)
    Z = np.vectorize(lambda d, n: valuation_sensitive_shift(p, int(n), int(d)))(D, N)

    contour = ax.contourf(D, N, Z, levels=20, cmap='viridis')
    ax.set_xlabel('δ', fontsize=12)
    ax.set_ylabel('ν', fontsize=12)
    ax.set_title(f'Stability Surface (p = {p})', fontsize=13)
    plt.colorbar(contour, ax=ax, label='δ/p^ν')

    # --- Panel 4: Comparative improvement for p=2,3,5 ---
    ax = axes[1, 1]
    delta = 1000
    primes_plot = [2, 3, 5]
    styles = ['-', '--', ':']
    prime_colors = ['#e41a1c', '#377eb8', '#4daf4a']

    for p, style, color in zip(primes_plot, styles, prime_colors):
        nus = np.arange(0, 11)
        improvements = [(delta - valuation_sensitive_shift(p, int(nu), delta)) / delta * 100
                        for nu in nus]
        ax.plot(nus, improvements, style, color=color, label=f'p = {p}',
                linewidth=2.5, markersize=6)

    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Improvement over δ (%)', fontsize=12)
    ax.set_title(f'Percentage Improvement (δ = {delta})', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 105)

    plt.suptitle('Prime Spectrum of Arithmetic Persistence Stability',
                 fontsize=15, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('viz_prime_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved viz_prime_spectrum.png")


if __name__ == "__main__":
    main()
