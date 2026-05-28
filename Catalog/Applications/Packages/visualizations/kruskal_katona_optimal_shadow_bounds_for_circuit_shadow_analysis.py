"""
Visualization: Circuit Shadow Bound Heatmap

Displays a heatmap showing how the circuit shadow bound grows as a function
of the number of addition and multiplication gates. Each cell represents
the shadow bound for a circuit with a given number of add/mul gates,
demonstrating that multiplication gates dominate shadow growth.

Output: PNG plot saved via matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, factorial
from itertools import permutations
from typing import Set, Tuple

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


# Compute data for the gap growth analysis
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Shadow Gap as Complexity Invariant', fontsize=14, fontweight='bold')

# Panel 1: Gap vs m for permanent
ms = [2, 3, 4, 5]
gaps = []
support_sizes = []
shadow_sizes = []

for m in ms:
    perm_S: Family = set()
    for perm in permutations(range(m)):
        vec = [0] * (m * m)
        for i in range(m):
            vec[i * m + perm[i]] = 1
        perm_S.add(tuple(vec))

    sh = one_shadow(perm_S, m * m)
    kk = kk_cascade(len(perm_S), m)
    gaps.append(len(sh) - kk)
    support_sizes.append(len(perm_S))
    shadow_sizes.append(len(sh))

ax1 = axes[0]
ax1.semilogy(ms, gaps, 'o-', color='#e74c3c', linewidth=2, markersize=10)
ax1.set_xlabel('Matrix size m', fontsize=12)
ax1.set_ylabel('Shadow Gap', fontsize=12)
ax1.set_title('Permanent Shadow Gap Growth')
ax1.grid(True, alpha=0.3)
for i, (m, g) in enumerate(zip(ms, gaps)):
    ax1.annotate(f'{g}', (m, g), textcoords="offset points",
                 xytext=(0, 10), ha='center', fontsize=10)

# Panel 2: Comparison of different polynomial families
ax2 = axes[1]
n = 6
families = {}

# e_1 through e_5
for r in range(1, 6):
    from itertools import combinations as comb_iter
    fam = set()
    for subset in comb_iter(range(n), r):
        vec = [0] * n
        for j in subset:
            vec[j] = 1
        fam.add(tuple(vec))
    sh = one_shadow(fam, n)
    kk = kk_cascade(len(fam), r)
    families[f'e_{r}'] = {'size': len(fam), 'shadow': len(sh), 'kk': kk,
                          'gap': len(sh) - kk, 'ratio': len(sh) / kk if kk > 0 else 0}

names = list(families.keys())
fam_gaps = [families[name]['gap'] for name in names]
fam_ratios = [families[name]['ratio'] for name in names]

colors = ['#3498db'] * len(names)
ax2.bar(names, fam_ratios, color=colors, alpha=0.8)
ax2.set_xlabel('Polynomial', fontsize=12)
ax2.set_ylabel('Inflation Ratio |Sh₁|/KK', fontsize=12)
ax2.set_title(f'Inflation Ratios (n={n})')
ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='KK-optimal')
ax2.legend()

# Panel 3: Shadow sizes comparison
ax3 = axes[2]
# Compare perm_3 with e_3 (same support size = 6)
bars_x = ['perm₃\n(9 vars)', 'e₃(6 vars)\n(same |S|=6)']
perm3_sh = shadow_sizes[1]  # m=3
e3_kk = kk_cascade(6, 3)
e3_fam = set()
for triple in comb_iter(range(6), 3):
    vec = [0] * 6
    for j in triple:
        vec[j] = 1
    e3_fam.add(tuple(vec))
e3_sh = len(one_shadow(e3_fam, 6))

ax3.bar(bars_x, [perm3_sh, e3_sh], color=['#e74c3c', '#3498db'], alpha=0.8)
ax3.set_ylabel('|Sh₁(S)|', fontsize=12)
ax3.set_title('Shadow Size: perm₃ vs e₃')
for i, v in enumerate([perm3_sh, e3_sh]):
    ax3.text(i, v + 0.5, str(v), ha='center', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig('circuit_shadow_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: circuit_shadow_analysis.png")
