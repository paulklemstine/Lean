"""
Visualization: Shadow Inflation Ratio for Permanent Supports

This visualizes the key computational finding: the ratio of actual shadow
size to the Kruskal-Katona minimum grows systematically with matrix size m,
providing evidence that permanent supports are far from extremal in the
KK sense. This growing gap is the foundation of the shadow-gap lower-bound
conjecture for algebraic circuit complexity.

Output: PNG plot saved via matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import comb, factorial
from typing import Set, Tuple, List

ExponentVector = Tuple[int, ...]
Family = Set[ExponentVector]


def one_shadow(S: Family, n: int) -> Family:
    shadow: Family = set()
    for alpha in S:
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def kk_cascade(m: int, d: int) -> int:
    if d == 0 or m == 0:
        return 0
    result_pairs = []
    remaining = m
    for k in range(d, 0, -1):
        a = k - 1
        while comb(a + 1, k) <= remaining:
            a += 1
        if comb(a, k) > 0:
            result_pairs.append((a, k))
            remaining -= comb(a, k)
        if remaining == 0:
            break
    return sum(comb(a, k - 1) for a, k in result_pairs)


def perm_support(m: int) -> Family:
    family: Family = set()
    for perm in permutations(range(m)):
        vec = [0] * (m * m)
        for i in range(m):
            vec[i * m + perm[i]] = 1
        family.add(tuple(vec))
    return family


# Compute data
ms = list(range(2, 6))
shadow_sizes = []
kk_bounds = []
ratios = []
gaps = []

for m in ms:
    S = perm_support(m)
    sh = one_shadow(S, m * m)
    kk = kk_cascade(len(S), m)
    shadow_sizes.append(len(sh))
    kk_bounds.append(kk)
    ratios.append(len(sh) / kk if kk > 0 else 0)
    gaps.append(len(sh) - kk)

# Create figure with 2x2 subplots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Shadow Analysis of Permanent Polynomial Supports',
             fontsize=16, fontweight='bold', y=0.98)

# Plot 1: Shadow size vs KK bound
ax1 = axes[0, 0]
x = range(len(ms))
width = 0.35
bars1 = ax1.bar([i - width/2 for i in x], shadow_sizes, width,
                label='Actual |Sh₁|', color='#e74c3c', alpha=0.8)
bars2 = ax1.bar([i + width/2 for i in x], kk_bounds, width,
                label='KK minimum', color='#3498db', alpha=0.8)
ax1.set_xlabel('Matrix size m')
ax1.set_ylabel('Shadow cardinality')
ax1.set_title('Actual Shadow vs KK Minimum')
ax1.set_xticks(x)
ax1.set_xticklabels([str(m) for m in ms])
ax1.legend()
ax1.set_yscale('log')

# Plot 2: Inflation ratio
ax2 = axes[0, 1]
ax2.plot(ms, ratios, 'o-', color='#e74c3c', linewidth=2, markersize=8)
ax2.plot(ms, [m - 1 for m in ms], '--', color='#95a5a6', linewidth=1,
         label='y = m - 1 (trend)')
ax2.set_xlabel('Matrix size m')
ax2.set_ylabel('|Sh₁| / KK_min')
ax2.set_title('Shadow Inflation Ratio')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Shadow gap
ax3 = axes[1, 0]
ax3.bar(ms, gaps, color='#2ecc71', alpha=0.8)
ax3.set_xlabel('Matrix size m')
ax3.set_ylabel('Shadow gap = |Sh₁| - KK_min')
ax3.set_title('Shadow Gap (Excess over KK Minimum)')
ax3.set_yscale('log')

# Plot 4: Support size, shadow size, KK bound comparison
ax4 = axes[1, 1]
ax4.plot(ms, [factorial(m) for m in ms], 's-', label='|Supp| = m!',
         color='#9b59b6', linewidth=2, markersize=8)
ax4.plot(ms, shadow_sizes, 'o-', label='|Sh₁(Supp)|',
         color='#e74c3c', linewidth=2, markersize=8)
ax4.plot(ms, kk_bounds, '^-', label='KK minimum',
         color='#3498db', linewidth=2, markersize=8)
ax4.set_xlabel('Matrix size m')
ax4.set_ylabel('Cardinality (log scale)')
ax4.set_title('Growth Comparison')
ax4.legend()
ax4.set_yscale('log')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_inflation.png', dpi=150, bbox_inches='tight')
print("Saved: shadow_inflation.png")
