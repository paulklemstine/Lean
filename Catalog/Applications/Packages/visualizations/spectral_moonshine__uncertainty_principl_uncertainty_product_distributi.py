#!/usr/bin/env python3
"""
Visualization: Uncertainty Product Distribution

For each small group, generates random class functions and plots the distribution
of uncertainty products σ_cls · σ_spec, showing the r lower bound from the
Spectral Uncertainty Principle. Also compares irreducible characters (which
achieve the bound for simple groups like A₅) against random functions.
"""

import numpy as np
import matplotlib.pyplot as plt


def get_groups():
    """Return character tables for small groups."""
    phi = (1 + np.sqrt(5)) / 2
    w = np.exp(2j * np.pi / 3)
    return {
        "S₃": {
            "order": 6,
            "class_sizes": np.array([1, 3, 2]),
            "char_table": np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex),
        },
        "A₄": {
            "order": 12,
            "class_sizes": np.array([1, 3, 4, 4]),
            "char_table": np.array([
                [1, 1, 1, 1], [1, 1, w, w**2],
                [1, 1, w**2, w], [3, -1, 0, 0],
            ], dtype=complex),
        },
        "S₄": {
            "order": 24,
            "class_sizes": np.array([1, 6, 3, 8, 6]),
            "char_table": np.array([
                [1,1,1,1,1],[1,-1,1,1,-1],[2,0,2,-1,0],
                [3,1,-1,0,-1],[3,-1,-1,0,1],
            ], dtype=complex),
        },
        "A₅": {
            "order": 60,
            "class_sizes": np.array([1, 15, 20, 12, 12]),
            "char_table": np.array([
                [1, 1, 1, 1, 1],
                [3, -1, 0, phi, 1-phi],
                [3, -1, 0, 1-phi, phi],
                [4, 0, 1, -1, -1],
                [5, 1, -1, 0, 0],
            ], dtype=complex),
        },
    }


def compute_uncertainty_product(f_vals, char_table, class_sizes, order, tol=1e-10):
    """Compute σ_cls(f) · σ_spec(f)."""
    r = len(class_sizes)
    sigma_cls = int(np.sum(np.abs(f_vals) > tol))

    coeffs = np.zeros(r, dtype=complex)
    for i in range(r):
        coeffs[i] = np.sum(class_sizes * f_vals * np.conj(char_table[i])) / order
    sigma_spec = int(np.sum(np.abs(coeffs) > tol))

    return sigma_cls * sigma_spec


def plot_uncertainty_distribution():
    groups = get_groups()
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Uncertainty Product Distribution: σ_cls × σ_spec ≥ r",
                 fontsize=16, fontweight='bold', y=0.98)

    rng = np.random.default_rng(42)
    n_random = 5000

    for idx, (name, data) in enumerate(groups.items()):
        ax = axes[idx // 2, idx % 2]
        r = len(data["class_sizes"])
        ct = data["char_table"]
        cs = data["class_sizes"]
        N = data["order"]

        # Random class functions
        products_random = []
        for _ in range(n_random):
            f = rng.standard_normal(r) + 1j * rng.standard_normal(r)
            prod = compute_uncertainty_product(f, ct, cs, N)
            products_random.append(prod)

        # Irreducible characters
        products_irr = []
        for i in range(r):
            prod = compute_uncertainty_product(ct[i], ct, cs, N)
            products_irr.append(prod)

        # Plot histogram
        bins = np.arange(0, max(max(products_random), r*r) + 2) - 0.5
        ax.hist(products_random, bins=bins, alpha=0.7, color='steelblue',
                edgecolor='navy', label='Random class functions', density=True)

        # Mark irreducible characters
        for i, prod in enumerate(products_irr):
            ax.axvline(prod, color='red', linestyle='--', alpha=0.8, linewidth=1.5)
        ax.axvline(products_irr[0], color='red', linestyle='--', alpha=0.8,
                  linewidth=1.5, label=f'Irreducible chars')

        # Mark the bound
        ax.axvline(r, color='green', linestyle='-', linewidth=3, alpha=0.8,
                  label=f'Bound: r = {r}')

        # Shade violation region
        ax.axvspan(-0.5, r - 0.5, alpha=0.15, color='red')

        ax.set_xlabel('σ_cls × σ_spec', fontsize=11)
        ax.set_ylabel('Density', fontsize=11)
        ax.set_title(f'{name} (r = {r})', fontsize=13, fontweight='bold')
        ax.legend(fontsize=9, loc='upper right')

        # Stats
        min_prod = min(products_random)
        violations = sum(1 for p in products_random if p < r)
        ax.text(0.02, 0.95, f'Min product: {min_prod}\nViolations: {violations}/{n_random}',
                transform=ax.transAxes, fontsize=9,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("uncertainty_product.png", dpi=150, bbox_inches='tight')
    print("Saved: uncertainty_product.png")


if __name__ == "__main__":
    plot_uncertainty_distribution()
