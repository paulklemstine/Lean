#!/usr/bin/env python3
"""Visualization of Hodge index theorem signatures."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def hodge_signature(Q: np.ndarray) -> tuple:
    """Compute signature of a symmetric matrix."""
    eigs = np.linalg.eigvalsh(Q)
    tol = 1e-10
    return int(np.sum(eigs > tol)), int(np.sum(eigs < -tol)), int(np.sum(np.abs(eigs) <= tol))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Hodge Index Theorem: Intersection Form Signatures",
                 fontsize=14, fontweight='bold')

    # Panel 1: Signature vs Picard number
    ax = axes[0]
    picard_numbers = list(range(1, 21))
    pos_ranks = []
    neg_ranks = []
    for rho in picard_numbers:
        Q = np.diag([1.0] + [-1.0] * (rho - 1))
        p, q, _ = hodge_signature(Q)
        pos_ranks.append(p)
        neg_ranks.append(q)

    ax.bar(picard_numbers, pos_ranks, label='Positive rank', color='steelblue', alpha=0.8)
    ax.bar(picard_numbers, neg_ranks, bottom=pos_ranks, label='Negative rank',
           color='coral', alpha=0.8)
    ax.set_xlabel('Picard number ρ')
    ax.set_ylabel('Rank')
    ax.set_title('Hodge Index: Signature (1, ρ-1)')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 2: Eigenvalue distribution for random perturbation of Hodge form
    ax = axes[1]
    np.random.seed(42)
    rho = 10
    Q_base = np.diag([1.0] + [-1.0] * (rho - 1))
    perturbations = [0, 0.01, 0.05, 0.1, 0.2]
    colors = plt.cm.viridis(np.linspace(0, 0.8, len(perturbations)))

    for eps, color in zip(perturbations, colors):
        P = np.random.randn(rho, rho)
        P = (P + P.T) / 2  # symmetrize
        Q = Q_base + eps * P
        eigs = np.sort(np.linalg.eigvalsh(Q))
        ax.plot(range(rho), eigs, 'o-', color=color, label=f'ε = {eps}',
                markersize=5, linewidth=1.5)

    ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax.set_xlabel('Eigenvalue index')
    ax.set_ylabel('Eigenvalue')
    ax.set_title(f'Perturbed Hodge Form (ρ = {rho})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Positive-negative disjointness visualization
    ax = axes[2]
    theta = np.linspace(0, 2 * np.pi, 200)
    # Positive cone (small)
    r_pos = 0.3
    x_pos = r_pos * np.cos(theta)
    y_pos = r_pos * np.sin(theta)
    ax.fill(x_pos, y_pos, color='steelblue', alpha=0.3, label='Positive cone')
    ax.plot(x_pos, y_pos, color='steelblue', linewidth=2)

    # Negative region (complement)
    r_neg_outer = 1.5
    r_neg_inner = 0.5
    x_neg_out = r_neg_outer * np.cos(theta)
    y_neg_out = r_neg_outer * np.sin(theta)
    x_neg_in = r_neg_inner * np.cos(theta[::-1])
    y_neg_in = r_neg_inner * np.sin(theta[::-1])
    ax.fill(np.concatenate([x_neg_out, x_neg_in]),
            np.concatenate([y_neg_out, y_neg_in]),
            color='coral', alpha=0.2, label='Negative region')
    ax.plot(x_neg_out, y_neg_out, color='coral', linewidth=2)

    ax.plot(0, 0, 'ko', markersize=8, zorder=5)
    ax.annotate('Origin\n(only intersection)', (0, 0), (0.3, -0.8),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='black'))
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_title('Pos-Neg Disjointness')
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("hodge_index_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved hodge_index_visualization.png")


if __name__ == "__main__":
    main()
