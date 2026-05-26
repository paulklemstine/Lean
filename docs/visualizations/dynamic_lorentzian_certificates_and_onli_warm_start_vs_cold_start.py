#!/usr/bin/env python3
"""
Visualization: Warm-Start vs Cold-Start Total Variation

Illustrates how the warm-start advantage grows with distribution size,
showing that the total variation between successive normalized distributions
remains small even as the overall distribution becomes more complex.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)


def total_variation(mu, nu):
    """Total variation distance."""
    return 0.5 * np.sum(np.abs(mu - nu))


# Experiment parameters
sizes = [5, 10, 20, 50, 100, 200, 500]
perturbation_scales = [0.01, 0.05, 0.10]
n_trials = 50

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Warm-Start vs Cold-Start Sampling: Total Variation Analysis',
             fontsize=13, fontweight='bold')

for ax, scale in zip(axes, perturbation_scales):
    cold_means = []
    cold_stds = []
    warm_means = []
    warm_stds = []
    bound_means = []

    for size in sizes:
        cold_tvs = []
        warm_tvs = []
        bounds = []

        for _ in range(n_trials):
            # Generate random weights
            w = np.random.exponential(1.0, size)
            perturbation = np.random.normal(0, scale, size)
            w_prime = np.maximum(0, w + perturbation)

            Z = w.sum()
            Z_prime = w_prime.sum()

            if Z_prime <= 0:
                continue

            mu = w / Z
            nu = w_prime / Z_prime
            uniform = np.ones(size) / size

            cold_tv = total_variation(uniform, nu)
            warm_tv = total_variation(mu, nu)
            delta = np.sum(np.abs(w - w_prime))
            bound = delta / min(Z, Z_prime)

            cold_tvs.append(cold_tv)
            warm_tvs.append(warm_tv)
            bounds.append(bound)

        cold_means.append(np.mean(cold_tvs))
        cold_stds.append(np.std(cold_tvs))
        warm_means.append(np.mean(warm_tvs))
        warm_stds.append(np.std(warm_tvs))
        bound_means.append(np.mean(bounds))

    cold_means = np.array(cold_means)
    warm_means = np.array(warm_means)
    bound_means = np.array(bound_means)

    ax.semilogy(sizes, cold_means, 'ro-', linewidth=2, markersize=6, label='Cold-start TV')
    ax.semilogy(sizes, warm_means, 'bs-', linewidth=2, markersize=6, label='Warm-start TV')
    ax.semilogy(sizes, bound_means, 'g^--', linewidth=1.5, markersize=6, label='Theorem bound')

    ax.set_xlabel('Distribution Size')
    ax.set_ylabel('Total Variation (log scale)')
    ax.set_title(f'Perturbation scale = {scale}')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_warmstart.png', dpi=150, bbox_inches='tight')
print("Saved viz_warmstart.png")
