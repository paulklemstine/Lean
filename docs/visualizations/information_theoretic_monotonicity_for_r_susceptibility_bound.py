"""
Visualization 3: Susceptibility Bound — Statistical Mechanics Bridge

Shows the susceptibility χ(μ) = ∑ Cov(X_i, X_j) for various uniform matroid
distributions, compared to the proved bound χ ≤ n/4. Decomposes χ into
diagonal (variance) and off-diagonal (covariance) contributions, illustrating
how negative dependence suppresses the off-diagonal part.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def matroid_susceptibility(n, k):
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)

    def cp(i):
        return sum(w for s in subsets if i in s)

    def cov(i, j):
        pij = sum(w for s in subsets if i in s and j in s)
        return pij - cp(i) * cp(j)

    diag = sum(cov(i, i) for i in range(n))
    off = sum(cov(i, j) for i in range(n) for j in range(n) if i != j)
    return diag, off, diag + off


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Susceptibility Bound: Bridge to Statistical Mechanics',
             fontsize=14, fontweight='bold')

# Left plot: susceptibility vs k for various n
for n in [4, 5, 6, 7, 8]:
    ks = range(1, n)
    chis = [matroid_susceptibility(n, k)[2] for k in ks]
    ax1.plot(ks, chis, 'o-', label=f'n={n}', markersize=5)
    ax1.axhline(y=n / 4, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Rank k')
ax1.set_ylabel('Susceptibility χ(μ)')
ax1.set_title('χ vs. Rank for Uniform Matroids')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right plot: decomposition for n=7
n = 7
ks = range(1, n)
diags = []
offs = []
totals = []
for k in ks:
    d, o, t = matroid_susceptibility(n, k)
    diags.append(d)
    offs.append(o)
    totals.append(t)

x = np.arange(len(list(ks)))
width = 0.35
ax2.bar(x - width / 2, diags, width, label='Diagonal (∑Var)', color='steelblue')
ax2.bar(x + width / 2, offs, width, label='Off-diagonal (∑Cov)', color='salmon')
ax2.plot(x, totals, 'k^-', markersize=8, label='Total χ', linewidth=2)
ax2.axhline(y=n / 4, color='red', linestyle='--', linewidth=2, label=f'Bound n/4 = {n/4}')
ax2.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

ax2.set_xlabel('Rank k')
ax2.set_ylabel('Covariance contribution')
ax2.set_title(f'Susceptibility Decomposition (n={n})')
ax2.set_xticks(x)
ax2.set_xticklabels(list(ks))
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")
