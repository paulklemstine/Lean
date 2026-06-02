#!/usr/bin/env python3
"""
Visualization: Hypergraph Ramsey Number Bounds

Shows the gap between lower and upper bounds for R_3(k,k).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2


def probabilistic_lower_bound(r: int, k: int) -> int:
    binom_kr = comb(k, r)
    if binom_kr <= 1:
        return k
    threshold = 2 ** (binom_kr - 1)
    lo, hi = k, min(10**15, 2 ** (binom_kr // k) + 1000)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if 2 * comb(mid, k) < threshold:
            lo = mid
        else:
            hi = mid - 1
    return lo


def stepping_up_upper_bound(k: int) -> float:
    """Upper bound via stepping-up from R(k-1, k-1) <= 4^{k-1}."""
    graph_bound = 4 ** (k - 1)
    return log2(2 ** graph_bound + 1)


def main():
    fig, ax = plt.subplots(figsize=(10, 7))

    ks = list(range(3, 9))

    # Lower bounds (probabilistic method)
    lower_bounds = []
    for k in ks:
        lb = probabilistic_lower_bound(3, k)
        lower_bounds.append(log2(lb + 1) if lb > 1 else 1)

    # Upper bounds (stepping-up)
    upper_bounds = []
    for k in ks:
        if k <= 5:
            ub = stepping_up_upper_bound(k)
            upper_bounds.append(min(ub, 100))
        else:
            upper_bounds.append(100)  # Cap for display

    # Known values
    known = {3: (4, 4), 4: (13, 13)}  # R_3(k,k) = (lower, upper)
    bounds = {5: (34, 55)}

    ax.fill_between(ks, lower_bounds, upper_bounds, alpha=0.2, color='#F44336',
                     label='Gap between bounds')
    ax.plot(ks, lower_bounds, 'o-', color='#2196F3', linewidth=2, markersize=8,
            label='Lower bound (probabilistic)')
    ax.plot(ks, upper_bounds, 's-', color='#F44336', linewidth=2, markersize=8,
            label='Upper bound (stepping-up)')

    # Mark known values
    for k, (lo, hi) in known.items():
        ax.plot(k, log2(lo), '*', color='#4CAF50', markersize=15, zorder=5)
        ax.annotate(f'R₃({k},{k}) = {lo}', (k, log2(lo)),
                    textcoords="offset points", xytext=(10, 10), fontsize=10,
                    color='#4CAF50', fontweight='bold')

    for k, (lo, hi) in bounds.items():
        ax.plot(k, log2(lo), 'v', color='#FF9800', markersize=10, zorder=5)
        ax.plot(k, log2(hi), '^', color='#FF9800', markersize=10, zorder=5)
        ax.annotate(f'{lo} ≤ R₃({k},{k}) ≤ {hi}', (k, log2((lo + hi) / 2)),
                    textcoords="offset points", xytext=(10, 0), fontsize=10,
                    color='#FF9800')

    ax.set_xlabel('Clique size k', fontsize=13)
    ax.set_ylabel('log₂(R₃(k,k))', fontsize=13)
    ax.set_title('3-Uniform Hypergraph Ramsey Numbers:\nThe Gap Between Single and Double Exponential',
                 fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 50)

    plt.tight_layout()
    plt.savefig('ramsey_bounds_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ramsey_bounds_gap.png")


if __name__ == "__main__":
    main()
