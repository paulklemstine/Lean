"""
Visualization: Tropical Barrier Distance Bounds

Shows how tropical barriers at different weight thresholds provide
certified lower bounds on the CSS Z-distance of quantum LDPC codes.
Demonstrates the relationship between barrier threshold, minimum
support size, and distance certification.

Saves output as tropical_barrier.png.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Tropical Barrier Distance Bounds for Quantum LDPC Codes',
                 fontsize=16, fontweight='bold')

    # -----------------------------------------------------------------------
    # Panel 1: Barrier concept illustration
    # -----------------------------------------------------------------------
    ax = axes[0]

    # Simulate a filtration with edge weights
    np.random.seed(42)
    n_edges = 30
    weights = np.sort(np.random.randint(1, 20, n_edges))
    is_birth = np.random.random(n_edges) > 0.4

    barrier_threshold = 8

    birth_weights = weights[is_birth]
    death_weights = weights[~is_birth]

    ax.hist(birth_weights, bins=range(1, 21), color='#2196F3', alpha=0.7,
            label='Edge births', edgecolor='black', linewidth=0.5)
    ax.hist(death_weights, bins=range(1, 21), color='#FF9800', alpha=0.7,
            label='Edge deaths', edgecolor='black', linewidth=0.5)
    ax.axvline(x=barrier_threshold, color='red', linewidth=3, linestyle='--',
               label=f'Barrier λ={barrier_threshold}')

    low = sum(1 for w in birth_weights if w <= barrier_threshold)
    high = sum(1 for w in birth_weights if w > barrier_threshold)

    ax.fill_between([0.5, barrier_threshold], [0, 0], [5, 5],
                    alpha=0.1, color='green', label=f'Low-weight: {low} births')
    ax.fill_between([barrier_threshold, 20.5], [0, 0], [5, 5],
                    alpha=0.1, color='red', label=f'High-weight: {high} births')

    ax.set_xlabel('Tropical Weight', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Tropical Barrier Concept', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    # -----------------------------------------------------------------------
    # Panel 2: Distance bound vs barrier threshold for toric codes
    # -----------------------------------------------------------------------
    ax = axes[1]

    for L in [3, 4, 5, 6]:
        n_e = 2 * L * L
        n_v = L * L
        n_cycles = n_e - (n_v - 1)

        thresholds = range(1, 20)
        bounds = []
        for T in thresholds:
            # For toric code, cycles of length L must use edges
            # A simple model: low-weight births below T
            low = min(T - 2, n_cycles)  # simplified
            bound = max(1, L - max(0, low - 1))
            bounds.append(min(bound, L))

        ax.plot(list(thresholds), bounds, 'o-', markersize=4,
                label=f'Toric {L}×{L} (d={L})', linewidth=2)

    ax.set_xlabel('Barrier Threshold λ', fontsize=12)
    ax.set_ylabel('Distance Lower Bound', fontsize=12)
    ax.set_title('Distance Bound vs Threshold', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # -----------------------------------------------------------------------
    # Panel 3: Birth concentration under expansion
    # -----------------------------------------------------------------------
    ax = axes[2]

    # Simulate expansion effect on birth concentration
    T_range = np.arange(1, 30)
    total_births = 50

    for eps_label, factor in [('No expansion', 1.0),
                               ('Weak expansion (ε=0.1)', 0.7),
                               ('Strong expansion (ε=0.5)', 0.3)]:
        low_births = np.minimum(
            total_births,
            np.floor(factor * T_range / 30 * total_births).astype(int)
        )
        ax.plot(T_range, low_births, 'o-', markersize=3, label=eps_label, linewidth=2)

    ax.axhline(y=total_births, color='gray', linestyle=':', alpha=0.5)
    ax.text(25, total_births + 1, f'Total births = {total_births}',
            fontsize=9, ha='right')

    ax.set_xlabel('Weight Threshold T', fontsize=12)
    ax.set_ylabel('Low-Weight Births ≤ T', fontsize=12)
    ax.set_title('Expansion Concentrates Births', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_barrier.png', dpi=150, bbox_inches='tight')
    print("Saved tropical_barrier.png")


if __name__ == '__main__':
    main()
