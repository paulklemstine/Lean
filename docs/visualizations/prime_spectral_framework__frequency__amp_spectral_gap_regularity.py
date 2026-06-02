#!/usr/bin/env python3
"""
Visualization: Spectral Gap Regularity
========================================
Tests and visualizes the Spectral Gap Regularity Conjecture:
log(p_{n+1})/log(p_n) ≤ 1 + 1/n for consecutive primes.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def main():
    primes = sieve_primes(100000)

    fig, axes = plt.subplots(2, 1, figsize=(14, 10))

    # Compute ratios
    ns = list(range(1, len(primes)))
    ratios = [math.log(primes[i]) / math.log(primes[i-1]) for i in range(1, len(primes))]
    bounds = [1 + 1.0 / n for n in ns]

    # Top: ratios and bound
    ax1 = axes[0]
    ax1.scatter(ns[:200], ratios[:200], s=8, alpha=0.7, color='#377eb8', label='log(p_{n+1})/log(p_n)')
    ax1.plot(ns[:200], bounds[:200], 'r-', linewidth=2, alpha=0.8, label='1 + 1/n bound')
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('n (prime index)', fontsize=13)
    ax1.set_ylabel('Frequency ratio', fontsize=13)
    ax1.set_title('Spectral Gap Regularity Conjecture (first 200 primes)', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0.95, 2.1)

    # Bottom: margin (bound - ratio)
    ax2 = axes[1]
    margins = [b - r for b, r in zip(bounds, ratios)]
    ax2.semilogy(ns[:2000], margins[:2000], '.', markersize=2, alpha=0.5, color='#4daf4a')
    ax2.set_xlabel('n (prime index)', fontsize=13)
    ax2.set_ylabel('Margin (1 + 1/n - ratio)', fontsize=13)
    ax2.set_title('Conjecture Margin (all positive ⟹ conjecture holds)', fontsize=13)
    ax2.grid(True, alpha=0.3, which='both')

    # Check and annotate
    all_positive = all(m > 0 for m in margins)
    min_margin = min(margins)
    min_idx = margins.index(min_margin) + 1
    ax2.annotate(f'Min margin = {min_margin:.6f} at n={min_idx}',
                xy=(min_idx, min_margin), fontsize=11,
                arrowprops=dict(arrowstyle='->', color='red'),
                xytext=(min_idx + 500, min_margin * 5),
                color='red', fontweight='bold')

    status = "VERIFIED ✓" if all_positive else "VIOLATED ✗"
    fig.suptitle(f'Status: {status} for {len(primes)} primes', fontsize=12,
                 color='green' if all_positive else 'red', y=0.02)

    plt.tight_layout()
    plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: spectral_gaps.png (conjecture {status})")


if __name__ == "__main__":
    main()
