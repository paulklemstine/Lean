#!/usr/bin/env python3
"""
Visualization: Quantum Singleton Bound Rate-Distance Tradeoff.

Shows the feasible region for CSS code parameters (rate vs distance)
under the quantum Singleton bound, with toric code family overlaid.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def singleton_max_rate(d, n):
    """Maximum rate k/n from quantum Singleton: 2d + k <= n + 2."""
    k_max = max(0, n + 2 - 2 * d)
    return k_max / n


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Rate vs normalized distance d/n
    ax = axes[0]
    for n in [50, 100, 200, 500, 1000]:
        ds = np.arange(1, n // 2 + 2)
        rates = [singleton_max_rate(d, n) for d in ds]
        ax.plot(ds / n, rates, label=f'n={n}', alpha=0.8)

    # Toric code family
    Ls = [3, 4, 5, 7, 10, 15, 20, 30]
    toric_d_over_n = [L / (2 * L ** 2) for L in Ls]
    toric_rate = [2 / (2 * L ** 2) for L in Ls]
    ax.scatter(toric_d_over_n, toric_rate, c='red', s=60, zorder=5,
              label='Toric codes', marker='*')

    ax.set_xlabel('Normalized distance d/n', fontsize=12)
    ax.set_ylabel('Encoding rate k/n', fontsize=12)
    ax.set_title('Quantum Singleton Bound: Rate vs Distance', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Right panel: Scaling laws d^2 vs n
    ax2 = axes[1]
    for g in [1, 2, 3, 5]:
        ns = np.arange(4 * g, 1000)
        d_max = [(n - 2 * g) // 2 + 1 for n in ns]
        d2 = [d ** 2 for d in d_max]
        ax2.plot(ns, d2, label=f'g={g}', alpha=0.8)

    # Toric code: d^2 = L^2, n = 2L^2, so d^2 = n/2
    ns_toric = np.array([2 * L ** 2 for L in range(3, 30)])
    d2_toric = ns_toric / 2
    ax2.plot(ns_toric, d2_toric, 'r--', linewidth=2, label='Toric: d²=n/2')

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('d² (distance squared)', fontsize=12)
    ax2.set_title('Distance Scaling: d² vs n', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.set_xlim(0, 1000)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_singleton_tradeoff.png', dpi=150)
    print("Saved viz_singleton_tradeoff.png")


if __name__ == "__main__":
    main()
