"""
Visualization: Character Sum Oscillation

Visualizes the partial character sums S(d, N) = Σ_{n=1}^{N} χ_d(n)
for several discriminants d. These sums oscillate but are bounded
by the Pólya-Vinogradov inequality: |S(d,N)| ≤ C·√|d|·log|d|.

The oscillation pattern encodes deep information about the distribution
of primes in arithmetic progressions — a key consequence of the
Langlands correspondence.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import isqrt, log


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

discriminants = [(-3, '#e41a1c'), (5, '#377eb8'), (-7, '#4daf4a'), (13, '#984ea3')]
N_max = 500

for idx, (d, color) in enumerate(discriminants):
    ax = axes[idx // 2][idx % 2]
    
    # Compute partial sums
    partial_sums = []
    running_sum = 0
    ns = list(range(1, N_max + 1))
    
    for n in ns:
        running_sum += kronecker_symbol(d, n)
        partial_sums.append(running_sum)
    
    ax.plot(ns, partial_sums, color=color, linewidth=0.8, alpha=0.9)
    ax.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)
    
    # Add Pólya-Vinogradov bound
    abs_d = abs(d)
    pv_bound = 2.0 * abs_d**0.5 * (log(abs_d) + 1)
    ax.axhline(y=pv_bound, color=color, linestyle=':', linewidth=1, alpha=0.5)
    ax.axhline(y=-pv_bound, color=color, linestyle=':', linewidth=1, alpha=0.5)
    
    ax.set_xlabel('N', fontsize=10)
    ax.set_ylabel(f'S({d}, N)', fontsize=10)
    ax.set_title(f'Character Sum for d = {d}  (Q(√{d}))', fontsize=12, fontweight='bold')
    ax.fill_between(ns, -pv_bound, pv_bound, alpha=0.05, color=color)
    
    # Annotate
    max_sum = max(abs(s) for s in partial_sums)
    ax.text(0.98, 0.95, f'max|S| = {max_sum}\nPV bound ≈ {pv_bound:.1f}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Character Sum Oscillations: The "Heartbeat" of Langlands\n'
             'Partial sums Σ χ_d(n) oscillate within the Pólya-Vinogradov bound',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_character_sums.png', dpi=150, bbox_inches='tight')
print("Saved viz_character_sums.png")
