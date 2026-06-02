#!/usr/bin/env python3
"""
Visualization: Spectral Complexity Landscape of Degree-1 L-Functions

Plots the spectral complexity κ = d·q + |μ| for degree-1 Selberg data
with conductor q and spectral shift μ ∈ {0, 1/2}.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
from math import gcd


def euler_totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Scatter of (q, κ) for degree 1 ---
    ax1 = axes[0]
    max_q = 50

    even_q, even_kappa = [], []
    odd_q, odd_kappa = [], []

    for q in range(1, max_q + 1):
        # Even character: μ = 0, κ = 1·q + 0 = q
        even_q.append(q)
        even_kappa.append(q)
        # Odd character: μ = 1/2, κ = 1·q + 1/2 = q + 0.5
        odd_q.append(q)
        odd_kappa.append(q + 0.5)

    ax1.scatter(even_q, even_kappa, c='#2196F3', s=30, alpha=0.7, label='Even (μ=0)')
    ax1.scatter(odd_q, odd_kappa, c='#FF5722', s=30, alpha=0.7, label='Odd (μ=1/2)')
    ax1.set_xlabel('Conductor q', fontsize=12)
    ax1.set_ylabel('Spectral Complexity κ(S)', fontsize=12)
    ax1.set_title('Degree-1 Spectral Complexity Landscape', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Highlight zeta
    ax1.annotate('ζ(s)', xy=(1, 1), xytext=(5, 5),
                fontsize=10, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='black'))

    # --- Right panel: Conductor counting N₁(Q) vs Q ---
    ax2 = axes[1]
    Qs = list(range(1, max_q + 1))
    N_even = []  # Cumulative count of even data
    N_odd = []   # Cumulative count of odd data
    N_total = [] # Total
    phi_cumulative = []  # Cumulative totient

    cum_phi = 0
    for Q in Qs:
        # Each conductor q contributes 2 data points (even and odd), for q > 2
        N_even.append(Q)  # One even datum per conductor 1..Q
        N_odd.append(Q)   # One odd datum per conductor 1..Q (for simplicity)
        N_total.append(2 * Q)
        cum_phi += euler_totient(Q)
        phi_cumulative.append(cum_phi)

    ax2.plot(Qs, N_total, 'b-', linewidth=2, label='N₁(Q) total data')
    ax2.plot(Qs, phi_cumulative, 'r--', linewidth=2, label='Σφ(q) (primitive chars)')
    ax2.fill_between(Qs, 0, N_total, alpha=0.1, color='blue')
    ax2.set_xlabel('Conductor bound Q', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Conductor Counting: N₁(Q) vs Σφ(q)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Add polynomial bound reference
    bound = [2 * (Q + 1) for Q in Qs]
    ax2.plot(Qs, bound, 'g:', linewidth=1.5, alpha=0.7, label='Bound: 2(Q+1)')
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('selberg_complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: selberg_complexity_landscape.png")


if __name__ == "__main__":
    main()
