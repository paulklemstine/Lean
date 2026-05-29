#!/usr/bin/env python3
"""
Visualization: Schanuel Deficiency Analysis Heatmap

For tuples of dimension n = 2, 3, 4, visualizes the fraction of randomly 
sampled coordinate matrices that are certified ℚ-linearly independent 
(full column rank) versus dependent. This illustrates the "density" of 
Schanuel-applicable configurations.

The key finding: as the coordinate bound grows, the fraction of independent
tuples approaches 1, showing that Schanuel's conjecture applies "generically"
and dependence is measure-zero.
"""

import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction
import random

def rational_rank(M):
    """Exact rank via Gaussian elimination over ℚ."""
    rows = [row[:] for row in M]
    m = len(rows)
    if m == 0:
        return 0
    n = len(rows[0])
    pivot_row = 0
    for col in range(n):
        found = None
        for row in range(pivot_row, m):
            if rows[row][col] != 0:
                found = row
                break
        if found is None:
            continue
        rows[pivot_row], rows[found] = rows[found], rows[pivot_row]
        pivot_val = rows[pivot_row][col]
        for row in range(m):
            if row != pivot_row and rows[row][col] != 0:
                factor = rows[row][col] / pivot_val
                for j in range(n):
                    rows[row][j] -= factor * rows[pivot_row][j]
        pivot_row += 1
    return pivot_row

def independence_fraction(m, n, bound, num_samples=2000):
    """
    Estimate the fraction of m×n matrices with entries in {-bound,...,bound}
    that have full column rank (rank = n).
    """
    count_indep = 0
    for _ in range(num_samples):
        M = [[Fraction(random.randint(-bound, bound)) for _ in range(n)]
             for _ in range(m)]
        if rational_rank(M) == n:
            count_indep += 1
    return count_indep / num_samples

def main():
    random.seed(42)
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    bounds = list(range(1, 16))
    configs = [
        (2, 2, "n=2, m=2"),  # 2 elements in 2-dim basis
        (3, 3, "n=3, m=3"),  # 3 elements in 3-dim basis
        (4, 3, "n=3, m=4"),  # 3 elements in 4-dim basis (overdetermined)
    ]
    
    for ax, (m, n, label) in zip(axes, configs):
        fractions_indep = []
        for b in bounds:
            f = independence_fraction(m, n, b, num_samples=1000)
            fractions_indep.append(f)
        
        ax.bar(bounds, fractions_indep, color='steelblue', alpha=0.8, edgecolor='navy')
        ax.set_xlabel('Coordinate bound B', fontsize=11)
        ax.set_ylabel('Fraction ℚ-independent', fontsize=11)
        ax.set_title(f'{label}\n(m×n matrix, entries in [-B,B])', fontsize=12)
        ax.set_ylim(0, 1.05)
        ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.5, label='All independent')
        
        # Add the asymptotic line
        if fractions_indep:
            avg = np.mean(fractions_indep[-3:])
            ax.axhline(y=avg, color='red', linestyle=':', alpha=0.5, 
                       label=f'Asymptotic ≈ {avg:.3f}')
        ax.legend(fontsize=9)
    
    plt.suptitle('Independence Density: Fraction of Certified ℚ-Independent Tuples\n'
                 '(Higher = more tuples where Schanuel applies)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_deficiency_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_deficiency_heatmap.png")

if __name__ == "__main__":
    main()
