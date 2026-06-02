#!/usr/bin/env python3
"""
Visualization: Tower Function Growth and Ramsey Number Hierarchy

Generates a plot comparing growth rates of Ramsey numbers across uniformities.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2


def tower(h: int) -> int:
    if h == 0:
        return 1
    return 2 ** tower(h - 1)


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


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Tower function growth
    ax1 = axes[0]
    heights = list(range(6))
    tower_vals = [tower(h) for h in heights]
    log_tower = [log2(t) if t > 0 else 0 for t in tower_vals]

    ax1.bar(heights, log_tower, color=['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#607D8B'])
    ax1.set_xlabel('Height h', fontsize=12)
    ax1.set_ylabel('log₂(tower(h))', fontsize=12)
    ax1.set_title('Tower Function: Iterated Exponential Growth', fontsize=14)
    for i, (h, v) in enumerate(zip(heights, tower_vals)):
        label = str(v) if v < 10000 else f'2^{log_tower[i]:.0f}'
        ax1.text(h, log_tower[i] + 0.5, label, ha='center', fontsize=10)

    # Panel 2: Growth rate comparison across uniformities
    ax2 = axes[1]
    colors_r = {2: '#2196F3', 3: '#F44336', 4: '#4CAF50'}
    labels_r = {2: 'r=2 (graphs)', 3: 'r=3 (3-uniform)', 4: 'r=4 (4-uniform)'}

    for r in [2, 3, 4]:
        ks = list(range(r + 1, min(r + 6, 11)))
        lbs = []
        for k in ks:
            lb = probabilistic_lower_bound(r, k)
            lbs.append(log2(lb + 1) if lb > 0 else 0)
        ax2.plot(ks, lbs, 'o-', color=colors_r[r], label=labels_r[r], linewidth=2, markersize=8)

    ax2.set_xlabel('Clique size k', fontsize=12)
    ax2.set_ylabel('log₂(lower bound for R_r(k,k))', fontsize=12)
    ax2.set_title('Ramsey Lower Bounds by Uniformity', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ramsey_growth_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ramsey_growth_comparison.png")


if __name__ == "__main__":
    main()
