#!/usr/bin/env python3
"""
Visualization: Exponential Growth of Accurate Oracle Behaviors

Shows how the number of oracle behaviors achieving ≥95% accuracy
grows exponentially with the number of inputs.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import math


def count_accurate_oracles(n: int, truth_bits: list, max_error_frac: float = 0.05) -> int:
    """Count oracle behaviors on n inputs with error rate ≤ max_error_frac."""
    max_errors = int(n * max_error_frac)
    count = 0
    for mask in range(2 ** n):
        errors = sum(1 for i in range(n)
                     if ((mask >> i) & 1 == 1) != truth_bits[i])
        if errors <= max_errors:
            count += 1
    return count


def main():
    random.seed(42)
    truth_bits = [random.choice([True, False]) for _ in range(22)]
    
    ns = list(range(1, 21))
    total_counts = [2 ** n for n in ns]
    accurate_counts = [count_accurate_oracles(n, truth_bits[:n]) for n in ns]
    lower_bounds = [2 ** (n // 21) for n in ns]
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Absolute counts (log scale)
    ax1 = axes[0]
    ax1.semilogy(ns, total_counts, 'b-o', label='Total behaviors (2^n)', markersize=4)
    ax1.semilogy(ns, accurate_counts, 'r-s', label='Accurate behaviors (≥95%)', markersize=4)
    ax1.semilogy(ns, lower_bounds, 'g--^', label='Lower bound (2^⌊n/21⌋)', markersize=4)
    ax1.set_xlabel('Number of inputs (n)', fontsize=12)
    ax1.set_ylabel('Count (log scale)', fontsize=12)
    ax1.set_title('Oracle Behaviors: Total vs Accurate', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Fraction of accurate behaviors
    ax2 = axes[1]
    fractions = [a / t for a, t in zip(accurate_counts, total_counts)]
    ax2.plot(ns, fractions, 'r-s', markersize=5, linewidth=2)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Number of inputs (n)', fontsize=12)
    ax2.set_ylabel('Fraction accurate', fontsize=12)
    ax2.set_title('Fraction of Accurate Oracle Behaviors', fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_counting.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_counting.png")
    
    # Additional plot: accuracy threshold sensitivity
    fig2, ax3 = plt.subplots(figsize=(8, 6))
    thresholds = [0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]
    n_test = 16
    for thresh in thresholds:
        counts_for_thresh = []
        for n in range(1, n_test + 1):
            counts_for_thresh.append(count_accurate_oracles(n, truth_bits[:n], 1 - thresh))
        ax3.semilogy(range(1, n_test + 1), counts_for_thresh,
                     '-o', label=f'≥{thresh*100:.0f}% accuracy', markersize=3)
    
    ax3.set_xlabel('Number of inputs (n)', fontsize=12)
    ax3.set_ylabel('Count of accurate behaviors (log scale)', fontsize=12)
    ax3.set_title('Accurate Behaviors by Threshold', fontsize=13)
    ax3.legend(fontsize=9, ncol=2)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_threshold.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_threshold.png")


if __name__ == "__main__":
    main()
