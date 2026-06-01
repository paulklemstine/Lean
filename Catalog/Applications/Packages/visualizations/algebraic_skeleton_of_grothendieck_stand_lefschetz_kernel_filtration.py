#!/usr/bin/env python3
"""Visualization of Lefschetz kernel filtrations for nilpotent operators."""

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


def lefschetz_filtration(L: np.ndarray) -> list:
    """Compute kernel filtration dimensions."""
    n = L.shape[0]
    dims = [0]
    power = np.eye(n)
    for k in range(1, n + 2):
        power = power @ L
        ker_dim = n - int(np.round(np.linalg.matrix_rank(power, tol=1e-10)))
        dims.append(ker_dim)
        if ker_dim == n:
            break
    return dims


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Lefschetz Kernel Filtrations for Nilpotent Operators",
                 fontsize=16, fontweight='bold')

    configs = [
        (6, 3, "6-dim, weight 3 (surface)"),
        (8, 4, "8-dim, weight 4 (3-fold)"),
        (10, 5, "10-dim, weight 5 (4-fold)"),
        (12, 3, "12-dim, weight 3 (surface, large)"),
    ]

    for ax, (n, w, title) in zip(axes.flat, configs):
        # Plot multiple random instances
        for trial in range(5):
            L = random_nilpotent_matrix(n, w)
            dims = lefschetz_filtration(L)
            ks = list(range(len(dims)))
            alpha = 0.3 if trial > 0 else 1.0
            lw = 1 if trial > 0 else 2.5
            ax.plot(ks, dims, 'o-', alpha=alpha, linewidth=lw,
                    color='steelblue' if trial > 0 else 'darkblue',
                    markersize=4 if trial > 0 else 6)

        ax.set_xlabel("Power k")
        ax.set_ylabel("dim(ker L^k)")
        ax.set_title(title)
        ax.axhline(y=n, color='red', linestyle='--', alpha=0.5, label=f'dim(V) = {n}')
        ax.set_ylim(-0.5, n + 1)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("filtration_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved filtration_visualization.png")


if __name__ == "__main__":
    main()
