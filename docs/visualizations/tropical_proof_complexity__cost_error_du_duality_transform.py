#!/usr/bin/env python3
"""
Visualization: Amplification-Cost Duality

Shows the core duality: exponential error decay in probability space
becomes linear cost growth in tropical space.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    base_errors = [0.1, 0.2, 0.3, 0.4, 0.5]
    max_k = 15

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Exponential error decay
    ax1 = axes[0]
    for eps in base_errors:
        ks = np.arange(1, max_k + 1)
        errors = eps ** ks
        ax1.semilogy(ks, errors, 'o-', label=f'ε = {eps}', markersize=4)

    ax1.set_xlabel('Rounds (k)', fontsize=12)
    ax1.set_ylabel('Error ε^k (log scale)', fontsize=12)
    ax1.set_title('Probability Space:\nExponential Decay', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Linear tropical cost growth
    ax2 = axes[1]
    for eps in base_errors:
        tau = -math.log(eps)
        ks = np.arange(1, max_k + 1)
        trop_costs = ks * tau
        ax2.plot(ks, trop_costs, 'o-', label=f'τ(ε) = {tau:.2f}', markersize=4)

    ax2.set_xlabel('Rounds (k)', fontsize=12)
    ax2.set_ylabel('Tropical Cost k·τ(ε)', fontsize=12)
    ax2.set_title('Tropical Space:\nLinear Growth', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Panel 3: The transform
    ax3 = axes[2]
    eps_range = np.linspace(0.01, 0.99, 200)
    tau_range = -np.log(eps_range)
    ax3.plot(eps_range, tau_range, 'k-', linewidth=2)
    ax3.fill_between(eps_range, tau_range, alpha=0.1, color='blue')

    for eps in base_errors:
        tau = -math.log(eps)
        ax3.plot(eps, tau, 'ro', markersize=8)
        ax3.annotate(f'({eps}, {tau:.2f})', (eps, tau),
                     textcoords="offset points", xytext=(10, 5), fontsize=8)

    ax3.set_xlabel('Error ε', fontsize=12)
    ax3.set_ylabel('Tropical Cost τ(ε) = -log(ε)', fontsize=12)
    ax3.set_title('The Transform:\nτ(ε) = -log(ε)', fontsize=13)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('duality_transform.png', dpi=150, bbox_inches='tight')
    print("Saved: duality_transform.png")


if __name__ == "__main__":
    main()
