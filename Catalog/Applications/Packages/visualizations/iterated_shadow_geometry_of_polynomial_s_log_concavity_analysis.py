"""
Visualization: Log-Concavity of Shadow Profiles

Shows the log-concavity test for shadow profiles across multiple
families. Plots log(a_k) vs k, where log-concavity corresponds to
concavity of this curve. Also visualizes the ratio a_{k+1}/a_k
which should be decreasing for log-concave sequences.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, product as iterproduct
from math import comb, log


# ── Inline implementations ───────────────────────────────────────────

def all_multi_indices_of_mass(n, k):
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    results = []
    for first in range(k + 1):
        for rest in all_multi_indices_of_mass(n - 1, k - first):
            results.append((first,) + rest)
    return results


def enumerate_multi_indices_le(alpha, mass):
    n = len(alpha)
    results = []
    def generate(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                results.append(tuple(current))
            return
        for v in range(min(alpha[pos], remaining) + 1):
            current.append(v)
            generate(pos + 1, remaining - v, current)
            current.pop()
    generate(0, mass, [])
    return results


def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        for tau in enumerate_multi_indices_le(alpha, k):
            beta = tuple(a - t for a, t in zip(alpha, tau))
            shadow.add(beta)
    return shadow


def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


def simplex_support(n, d):
    return set(all_multi_indices_of_mass(n, d))


def matroid_basis_support(n, r):
    support = set()
    for basis in combinations(range(n), r):
        alpha = tuple(1 if i in basis else 0 for i in range(n))
        support.add(alpha)
    return support


def product_support(dims):
    return set(iterproduct(*(range(d + 1) for d in dims)))


# ── Plotting ──────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Collect data
families = [
    ("Δ(3,5)", simplex_support(3, 5), '#1f77b4', 'o'),
    ("Δ(4,4)", simplex_support(4, 4), '#ff7f0e', 'o'),
    ("U(3,6)", matroid_basis_support(6, 3), '#2ca02c', 's'),
    ("U(4,7)", matroid_basis_support(7, 4), '#d62728', 's'),
    ("[0,3]×[0,3]", product_support([3, 3]), '#9467bd', '^'),
    ("[0,2]³", product_support([2, 2, 2]), '#8c564b', '^'),
]

# Panel 1: log(a_k) vs k — concavity = log-concavity
ax1.set_title("Log of Shadow Profile (concavity = log-concavity)",
              fontsize=12, fontweight='bold')
for name, S, color, marker in families:
    prof = shadow_profile(S)
    ks = list(range(len(prof)))
    log_prof = [log(max(a, 1)) for a in prof]
    ax1.plot(ks, log_prof, f'{marker}-', color=color, label=name,
             linewidth=2, markersize=7)

ax1.set_xlabel('Shadow depth k', fontsize=11)
ax1.set_ylabel('log |Sh_k(S)|', fontsize=11)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Ratio a_{k+1}/a_k — monotone decreasing = log-concavity
ax2.set_title("Ratio a_{k+1}/a_k (decreasing ⟹ log-concavity)",
              fontsize=12, fontweight='bold')
for name, S, color, marker in families:
    prof = shadow_profile(S)
    ratios = []
    ratio_ks = []
    for k in range(len(prof) - 1):
        if prof[k] > 0:
            ratios.append(prof[k + 1] / prof[k])
            ratio_ks.append(k)
    if ratios:
        ax2.plot(ratio_ks, ratios, f'{marker}-', color=color, label=name,
                 linewidth=2, markersize=7)

ax2.set_xlabel('Shadow depth k', fontsize=11)
ax2.set_ylabel('a_{k+1} / a_k', fontsize=11)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='ratio = 1')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.suptitle('Log-Concavity Analysis of Shadow Profiles',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('log_concavity.png', dpi=150, bbox_inches='tight')
print("Saved log_concavity.png")
