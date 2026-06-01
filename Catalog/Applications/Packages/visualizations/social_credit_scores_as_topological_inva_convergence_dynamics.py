#!/usr/bin/env python3
"""
Score Convergence Visualization

Shows geometric convergence of iterated scoring under contraction,
and the two-point contraction theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Convergence from different starting points
    kappa = 0.6
    x_star = 0.5 / (1 - kappa)  # fixed point of T(x) = κx + 0.5*(1-κ)
    update = lambda x: kappa * x + 0.5 * (1 - kappa)
    n_iter = 30

    starts = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
    colors = plt.cm.cool(np.linspace(0, 1, len(starts)))

    for x0, c in zip(starts, colors):
        traj = [x0]
        x = x0
        for _ in range(n_iter):
            x = update(x)
            traj.append(x)
        axes[0].plot(range(n_iter + 1), traj, '-o', color=c, markersize=3,
                    label=f'x₀ = {x0:.1f}')

    axes[0].axhline(y=x_star, color='red', linestyle='--', alpha=0.7,
                   label=f'x* = {x_star:.2f}')
    axes[0].set_xlabel('Iteration n', fontsize=11)
    axes[0].set_ylabel('Score', fontsize=11)
    axes[0].set_title(f'Contraction Convergence (κ = {kappa})', fontsize=12)
    axes[0].legend(fontsize=8, ncol=2)
    axes[0].set_ylim(-0.05, 1.05)

    # Panel 2: Error decay (log scale)
    for x0, c in zip(starts, colors):
        traj = [x0]
        x = x0
        for _ in range(n_iter):
            x = update(x)
            traj.append(x)
        errors = [abs(t - x_star) + 1e-16 for t in traj]
        axes[1].semilogy(range(n_iter + 1), errors, '-o', color=c,
                        markersize=3, label=f'x₀ = {x0:.1f}')

    # Theoretical bound
    bound = [kappa**n for n in range(n_iter + 1)]
    axes[1].semilogy(range(n_iter + 1), bound, 'k--', linewidth=2,
                    alpha=0.5, label=f'κⁿ = {kappa}ⁿ')
    axes[1].set_xlabel('Iteration n', fontsize=11)
    axes[1].set_ylabel('|xₙ - x*|', fontsize=11)
    axes[1].set_title('Geometric Error Decay', fontsize=12)
    axes[1].legend(fontsize=8, ncol=2)

    # Panel 3: Two-point gap contraction
    kappas = [0.3, 0.5, 0.7, 0.9]
    colors_k = plt.cm.autumn(np.linspace(0, 0.9, len(kappas)))

    for k, c in zip(kappas, colors_k):
        update_k = lambda x, k=k: k * x + 0.5 * (1 - k)
        x, y = 0.1, 0.9
        gaps = [abs(x - y)]
        for _ in range(n_iter):
            x = update_k(x)
            y = update_k(y)
            gaps.append(abs(x - y))
        axes[2].semilogy(range(n_iter + 1), gaps, '-o', color=c,
                        markersize=3, label=f'κ = {k}')

    axes[2].set_xlabel('Iteration n', fontsize=11)
    axes[2].set_ylabel('|xₙ - yₙ|', fontsize=11)
    axes[2].set_title('Two-Point Gap Contraction', fontsize=12)
    axes[2].legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_convergence.png")


if __name__ == "__main__":
    main()
