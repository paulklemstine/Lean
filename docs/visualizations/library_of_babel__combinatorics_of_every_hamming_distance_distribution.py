#!/usr/bin/env python3
"""
Visualization: Hamming Distance Distribution

Plots the distribution of Hamming distances between a fixed word
and random words, showing concentration around the mean.
"""

import random
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hamming_distance(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def main():
    random.seed(42)
    n = 5000  # word length
    k = 25    # alphabet size
    trials = 100000

    expected_mean = n * (k - 1) / k
    expected_std = math.sqrt(n * (k - 1) / k**2)

    x = [random.randint(0, k-1) for _ in range(n)]
    distances = []
    for _ in range(trials):
        y = [random.randint(0, k-1) for _ in range(n)]
        distances.append(hamming_distance(x, y))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Histogram
    ax1 = axes[0]
    ax1.hist(distances, bins=80, density=True, alpha=0.7, color='steelblue',
             edgecolor='white', linewidth=0.5, label='Observed')

    # Theoretical normal approximation
    xs = np.linspace(min(distances), max(distances), 200)
    normal_pdf = (1 / (expected_std * math.sqrt(2 * math.pi))) * \
                 np.exp(-0.5 * ((xs - expected_mean) / expected_std)**2)
    ax1.plot(xs, normal_pdf, 'r-', linewidth=2, label='Normal approximation')

    ax1.axvline(expected_mean, color='darkred', linestyle='--', linewidth=1.5,
                label=f'Mean = {expected_mean:.0f}')
    ax1.set_xlabel('Hamming Distance', fontsize=12)
    ax1.set_ylabel('Density', fontsize=12)
    ax1.set_title(f'Hamming Distance Distribution\n(n={n}, k={k}, {trials:,} samples)',
                  fontsize=13)
    ax1.legend(fontsize=10)

    # Q-Q plot (standardized)
    ax2 = axes[1]
    sorted_z = np.sort([(d - expected_mean) / expected_std for d in distances])
    theoretical_q = np.array([
        -math.sqrt(2) * math.erfc(2 * (i + 0.5) / len(sorted_z)) 
        for i in range(len(sorted_z))
    ]) if False else np.linspace(-4, 4, len(sorted_z))

    # Use scipy-free Q-Q: plot sorted standardized values against expected normal quantiles
    n_pts = len(sorted_z)
    expected_quantiles = [_normal_quantile((i + 0.5) / n_pts) for i in range(n_pts)]
    
    # Subsample for plotting
    step = max(1, n_pts // 2000)
    ax2.scatter(expected_quantiles[::step], sorted_z[::step], s=1, alpha=0.5, color='steelblue')
    ax2.plot([-4, 4], [-4, 4], 'r-', linewidth=1.5, label='y = x (perfect normal)')
    ax2.set_xlabel('Theoretical Quantiles', fontsize=12)
    ax2.set_ylabel('Observed Quantiles', fontsize=12)
    ax2.set_title('Q-Q Plot (Normal)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(-4, 4)
    ax2.set_ylim(-4, 4)

    plt.tight_layout()
    plt.savefig('hamming_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved hamming_distribution.png")


def _normal_quantile(p):
    """Approximate inverse normal CDF using rational approximation."""
    if p <= 0:
        return -8.0
    if p >= 1:
        return 8.0
    if p == 0.5:
        return 0.0
    if p > 0.5:
        return -_normal_quantile(1 - p)
    
    t = math.sqrt(-2 * math.log(p))
    c0, c1, c2 = 2.515517, 0.802853, 0.010328
    d1, d2, d3 = 1.432788, 0.189269, 0.001308
    return -(t - (c0 + c1*t + c2*t**2) / (1 + d1*t + d2*t**2 + d3*t**3))


if __name__ == "__main__":
    main()
