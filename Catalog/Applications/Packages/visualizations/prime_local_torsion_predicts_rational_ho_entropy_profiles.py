"""
Visualization: Torsion Entropy Profiles

Shows how the torsion entropy H_p decomposes across primes for different
group orders, illustrating the entropy bound theorem.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return sorted(factors)


def p_torsion_size(m, p):
    """Count elements in the p-torsion subgroup of ℤ/mℤ."""
    count = 0
    for a in range(m):
        pk = 1
        while pk <= m:
            if (pk * a) % m == 0:
                count += 1
                break
            pk *= p
    return count


def torsion_entropy(m, p):
    size = p_torsion_size(m, p)
    return math.log2(size) if size > 1 else 0.0


# Groups to analyze
groups = [6, 12, 30, 60, 120, 210]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

for idx, m in enumerate(groups):
    ax = axes[idx]
    pf = prime_factors(m)
    group_ent = math.log2(m)

    # Compute entropies
    entropies = [torsion_entropy(m, p) for p in pf]
    labels = [str(p) for p in pf]

    # Bar chart
    bars = ax.bar(labels, entropies, color=['#2196F3', '#FF9800', '#4CAF50',
                                            '#E91E63', '#9C27B0', '#00BCD4'][:len(pf)],
                  alpha=0.8, edgecolor='black', linewidth=0.5)

    # Add group entropy line
    ax.axhline(y=group_ent, color='red', linestyle='--', linewidth=2,
               label=f'log₂({m}) = {group_ent:.2f}')

    ax.set_title(f'ℤ/{m}ℤ', fontsize=14, fontweight='bold')
    ax.set_xlabel('Prime p', fontsize=11)
    ax.set_ylabel('H_p (bits)', fontsize=11)
    ax.legend(fontsize=9)
    ax.set_ylim(0, group_ent * 1.2)

    # Add value labels on bars
    for bar, val in zip(bars, entropies):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                    f'{val:.2f}', ha='center', va='bottom', fontsize=9)

fig.suptitle('Torsion Entropy Profiles: H_p ≤ log₂(|A|) for Each Prime p',
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
print("Saved entropy_profiles.png")
