#!/usr/bin/env python3
"""Visualization of the Primitive Rank Bound Conjecture."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def random_nilpotent_matrix(n: int, weight: int) -> np.ndarray:
    """Generate a random nilpotent matrix with given nilpotency weight."""
    J = np.zeros((n, n))
    for i in range(min(weight - 1, n - 1)):
        J[i, i + 1] = 1.0
    P = np.random.randn(n, n)
    while np.abs(np.linalg.det(P)) < 0.01:
        P = np.random.randn(n, n)
    return P @ J @ np.linalg.inv(P)


def verify_bound(L: np.ndarray) -> tuple:
    """Check primitive rank bound."""
    n = L.shape[0]
    ker_dim = n - int(np.round(np.linalg.matrix_rank(L, tol=1e-10)))
    power = L.copy()
    weight = 0
    for k in range(1, n + 1):
        if np.allclose(power, 0, atol=1e-10):
            weight = k - 1
            break
        power = power @ L
    else:
        weight = n
    ratio = ker_dim * (weight + 1) / n if n > 0 else 1.0
    return ker_dim, weight, ratio


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Primitive Rank Bound Conjecture: dim(ker L) × (w+1) ≥ dim(V)",
                 fontsize=14, fontweight='bold')

    # Panel 1: Scatter plot of ratio vs dimension
    ax = axes[0]
    dims = range(3, 20)
    ratios_by_dim = {d: [] for d in dims}

    for n in dims:
        for w in range(1, min(n, 8)):
            for _ in range(50):
                L = random_nilpotent_matrix(n, w)
                _, _, ratio = verify_bound(L)
                ratios_by_dim[n].append(ratio)

    box_data = [ratios_by_dim[d] for d in dims]
    bp = ax.boxplot(box_data, positions=list(dims), widths=0.6,
                    patch_artist=True,
                    boxprops=dict(facecolor='steelblue', alpha=0.5),
                    medianprops=dict(color='darkblue', linewidth=2))
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2,
               label='Conjecture bound (ratio ≥ 1)')
    ax.set_xlabel('Matrix dimension')
    ax.set_ylabel('dim(ker L) × (w+1) / dim(V)')
    ax.set_title('Ratio Distribution by Dimension')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Ratio vs weight for fixed dimension
    ax = axes[1]
    n_fixed = 12
    for w in range(1, 8):
        ratios = []
        for _ in range(200):
            L = random_nilpotent_matrix(n_fixed, w)
            _, _, r = verify_bound(L)
            ratios.append(r)
        ax.scatter([w] * len(ratios), ratios, alpha=0.3, s=10, color='steelblue')
        ax.plot(w, np.mean(ratios), 'ro', markersize=8, zorder=5)

    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2)
    ax.set_xlabel('Nilpotency weight w')
    ax.set_ylabel('dim(ker L) × (w+1) / dim(V)')
    ax.set_title(f'Fixed Dimension n = {n_fixed}')
    ax.grid(True, alpha=0.3)

    # Panel 3: Heatmap of minimum ratio
    ax = axes[2]
    dims_hm = range(3, 16)
    weights_hm = range(1, 10)
    min_ratios = np.full((len(list(weights_hm)), len(list(dims_hm))), np.nan)

    for i, w in enumerate(weights_hm):
        for j, n in enumerate(dims_hm):
            if w >= n:
                continue
            ratios = []
            for _ in range(100):
                L = random_nilpotent_matrix(n, w)
                _, _, r = verify_bound(L)
                ratios.append(r)
            min_ratios[i, j] = min(ratios)

    im = ax.imshow(min_ratios, aspect='auto', cmap='RdYlGn',
                   vmin=0.5, vmax=3.0,
                   extent=[2.5, 15.5, 9.5, 0.5])
    plt.colorbar(im, ax=ax, label='Min ratio')
    ax.set_xlabel('Matrix dimension n')
    ax.set_ylabel('Nilpotency weight w')
    ax.set_title('Minimum Ratio (green = conjecture holds)')
    ax.set_xticks(list(dims_hm))
    ax.set_yticks(list(weights_hm))

    plt.tight_layout()
    plt.savefig("primitive_bound_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved primitive_bound_visualization.png")


if __name__ == "__main__":
    main()
