"""
Visualization: Improvement Heatmap across Degree and Dimension

This script creates a heatmap showing the practical impact of the improved
stability constant across different polynomial degrees k and dimensions n.
Visualizes:
1. The improvement factor (always = n, independent of k)
2. Certified tolerance values under old vs new bounds
3. Required floating-point precision (number of significant digits)
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def elementary_symmetric_hessian(n, k, x):
    """Compute Hessian of e_k at point x."""
    if k < 2:
        return np.zeros((n, n))
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            remaining = [idx for idx in range(n) if idx != i and idx != j]
            if k - 2 == 0:
                H[i, j] = 1.0
            elif k - 2 <= len(remaining):
                for combo in combinations(remaining, k - 2):
                    prod = 1.0
                    for c in combo:
                        prod *= x[c]
                    H[i, j] += prod
    return H


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    ks = list(range(2, 8))
    ns = list(range(8, 21))

    # --- Panel 1: Spectral gaps ---
    gaps = np.zeros((len(ks), len(ns)))
    for i, k in enumerate(ks):
        for j, n in enumerate(ns):
            if n > k:
                H = elementary_symmetric_hessian(n, k, np.ones(n))
                eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
                if len(eigs) >= 2 and eigs[1] < 0:
                    gaps[i, j] = -eigs[1]
                else:
                    gaps[i, j] = np.nan
            else:
                gaps[i, j] = np.nan

    im1 = axes[0].imshow(gaps, aspect='auto', cmap='viridis',
                         origin='lower')
    axes[0].set_xticks(range(len(ns)))
    axes[0].set_xticklabels(ns)
    axes[0].set_yticks(range(len(ks)))
    axes[0].set_yticklabels([f'$e_{k}$' for k in ks])
    axes[0].set_xlabel('Dimension $n$', fontsize=12)
    axes[0].set_ylabel('Polynomial', fontsize=12)
    axes[0].set_title('Spectral Gap $\\varepsilon$', fontsize=13)
    plt.colorbar(im1, ax=axes[0], label='Gap $\\varepsilon$')

    # --- Panel 2: New certified tolerance (ε/n) ---
    new_tol = np.zeros_like(gaps)
    for i, k in enumerate(ks):
        for j, n in enumerate(ns):
            if not np.isnan(gaps[i, j]) and gaps[i, j] > 0:
                new_tol[i, j] = gaps[i, j] / n
            else:
                new_tol[i, j] = np.nan

    im2 = axes[1].imshow(np.log10(new_tol + 1e-20), aspect='auto',
                         cmap='RdYlGn', origin='lower',
                         vmin=-5, vmax=2)
    axes[1].set_xticks(range(len(ns)))
    axes[1].set_xticklabels(ns)
    axes[1].set_yticks(range(len(ks)))
    axes[1].set_yticklabels([f'$e_{k}$' for k in ks])
    axes[1].set_xlabel('Dimension $n$', fontsize=12)
    axes[1].set_ylabel('Polynomial', fontsize=12)
    axes[1].set_title('log₁₀(New Tolerance $\\varepsilon/n$)', fontsize=13)
    plt.colorbar(im2, ax=axes[1], label='$\\log_{10}(\\varepsilon/n)$')

    # --- Panel 3: Improvement factor (old/new tolerance) ---
    improvement = np.zeros_like(gaps)
    for i, k in enumerate(ks):
        for j, n in enumerate(ns):
            if not np.isnan(gaps[i, j]):
                improvement[i, j] = n  # Always = n
            else:
                improvement[i, j] = np.nan

    im3 = axes[2].imshow(improvement, aspect='auto', cmap='Blues',
                         origin='lower')
    axes[2].set_xticks(range(len(ns)))
    axes[2].set_xticklabels(ns)
    axes[2].set_yticks(range(len(ks)))
    axes[2].set_yticklabels([f'$e_{k}$' for k in ks])
    axes[2].set_xlabel('Dimension $n$', fontsize=12)
    axes[2].set_ylabel('Polynomial', fontsize=12)
    axes[2].set_title('Improvement Factor ($= n$)', fontsize=13)
    cbar3 = plt.colorbar(im3, ax=axes[2], label='Factor')

    # Add text annotations for improvement
    for i, k in enumerate(ks):
        for j, n in enumerate(ns):
            if not np.isnan(improvement[i, j]):
                axes[2].text(j, i, f'{int(improvement[i, j])}',
                           ha='center', va='center', fontsize=7,
                           color='white' if improvement[i, j] > 14 else 'black')

    plt.suptitle('Sharp Lorentzian Stability: Degree × Dimension Analysis',
                fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_heatmap.png")


if __name__ == "__main__":
    main()
