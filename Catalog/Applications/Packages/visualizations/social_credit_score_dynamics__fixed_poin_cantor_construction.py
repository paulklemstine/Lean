#!/usr/bin/env python3
"""Visualization of Cantor set construction and measure convergence."""

import matplotlib.pyplot as plt
import numpy as np


def cantor_intervals(n: int) -> list[tuple[float, float]]:
    """Return the list of intervals at stage n of Cantor construction."""
    intervals = [(0.0, 1.0)]
    for _ in range(n):
        new_intervals = []
        for a, b in intervals:
            third = (b - a) / 3
            new_intervals.append((a, a + third))
            new_intervals.append((b - third, b))
        intervals = new_intervals
    return intervals


def main():
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Top: Cantor set construction stages
    n_stages = 7
    for n in range(n_stages):
        intervals = cantor_intervals(n)
        y = n_stages - n
        for a, b in intervals:
            ax1.plot([a, b], [y, y], 'b-', linewidth=max(1, 8 - n))

    ax1.set_xlabel('Score value x', fontsize=12)
    ax1.set_ylabel('Stage n', fontsize=12)
    ax1.set_title('Cantor Set Construction: Social Score Stratification', fontsize=14)
    ax1.set_yticks(range(1, n_stages + 1))
    ax1.set_yticklabels([f'n={n}' for n in range(n_stages - 1, -1, -1)])
    ax1.set_xlim(-0.05, 1.05)

    # Bottom: Measure convergence
    ns = np.arange(0, 30)
    measures = (2.0 / 3.0) ** ns
    ax2.semilogy(ns, measures, 'ro-', markersize=4, label='(2/3)ⁿ')
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.set_xlabel('Stage n', fontsize=12)
    ax2.set_ylabel('Total measure (log scale)', fontsize=12)
    ax2.set_title('Cantor Attractor Measure → 0', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cantor_construction.png', dpi=150)
    print("Saved cantor_construction.png")


if __name__ == "__main__":
    main()
