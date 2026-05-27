#!/usr/bin/env python3
"""
Visualization: Exponent Landscape for Exchange Descent

Visualizes the relationship between certificate depth k and the descent
complexity exponent d-k, showing how the upper and lower bounds converge
to within a single power of d.

This is a self-contained script — no local imports.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def compute_bounds(d_max=12):
    """Compute upper and lower bounds for all (d, k) pairs."""
    d_vals = list(range(2, d_max + 1))
    data = []
    for d in d_vals:
        for k in range(d):
            lb_exp = max(d - k - 1, 0)
            ub_exp = d - k
            lb = d ** lb_exp
            ub = d ** ub_exp
            data.append({
                'd': d, 'k': k,
                'lb_exp': lb_exp, 'ub_exp': ub_exp,
                'lb': lb, 'ub': ub,
                'gap': ub_exp - lb_exp,
            })
    return data


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))

    data = compute_bounds(12)

    # Plot 1: Heatmap of lower bound exponent d-k-1
    ax = axes[0, 0]
    d_max = 12
    matrix = np.full((d_max - 1, d_max - 1), np.nan)
    for item in data:
        if item['d'] <= d_max and item['k'] < d_max - 1:
            matrix[item['d'] - 2, item['k']] = item['lb_exp']
    im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto', origin='lower',
                   extent=[0, d_max-1, 2, d_max+1])
    ax.set_xlabel('Certificate depth k')
    ax.set_ylabel('Dimension d')
    ax.set_title('Lower Bound Exponent (d-k-1)')
    plt.colorbar(im, ax=ax, label='Exponent')

    # Plot 2: Log-scale comparison of bounds for fixed k=1
    ax = axes[0, 1]
    k_fixed = 1
    ds = list(range(3, 13))
    lbs = [d ** (d - k_fixed - 1) for d in ds]
    ubs = [d ** (d - k_fixed) for d in ds]
    ax.semilogy(ds, lbs, 'bo-', label=f'Lower bound $d^{{d-k-1}}$', markersize=6)
    ax.semilogy(ds, ubs, 'rs-', label=f'Upper bound $d^{{d-k}}$', markersize=6)
    ax.fill_between(ds, lbs, ubs, alpha=0.15, color='green')
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Bound value (log scale)')
    ax.set_title(f'Upper vs Lower Bound (k={k_fixed})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: The gap is always exactly 1
    ax = axes[1, 0]
    for k in [0, 1, 2, 3]:
        ds_k = [d for d in range(k+2, 13)]
        gaps = [1] * len(ds_k)  # gap is always 1 power of d
        ax.plot(ds_k, gaps, 'o-', label=f'k={k}', markersize=6)
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Exponent gap (upper - lower)')
    ax.set_title('Gap Between Exponents = 1 (Universal)')
    ax.set_ylim(0, 3)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Gap = 1')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: "Phase diagram" of complexity classes
    ax = axes[1, 1]
    d_vals = list(range(2, 13))
    k_vals = list(range(12))
    D, K = np.meshgrid(d_vals, k_vals)
    Z = np.full_like(D, np.nan, dtype=float)
    for i, k in enumerate(k_vals):
        for j, d in enumerate(d_vals):
            if k < d:
                Z[i, j] = d - k  # the effective exponent
    im = ax.pcolormesh(np.array(d_vals) - 0.5, np.array(k_vals) - 0.5, Z,
                       cmap='viridis', shading='auto')
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Certificate depth k')
    ax.set_title('Effective Exponent d-k (Phase Diagram)')
    plt.colorbar(im, ax=ax, label='Exponent d-k')

    # Add diagonal line k = d
    ax.plot([2, 12], [2, 12], 'r--', linewidth=2, label='k = d (linear)')
    ax.legend(loc='upper left')

    plt.suptitle('Sharp Exponent Landscape for Exchange Descent', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_exponent_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_exponent_landscape.png")


if __name__ == '__main__':
    main()
