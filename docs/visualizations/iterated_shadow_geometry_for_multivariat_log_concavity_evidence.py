"""
Visualization: Log-Concavity of Shadow Profiles

Tests and visualizes the Shadow Log-Concavity Conjecture across
exchange families. Each point represents a support set; color indicates
whether the shadow profile is log-concave.

Uses only matplotlib and numpy, no local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random

# ---- Inline helper functions ----

def mass(tau):
    return sum(tau)

def multi_indices_of_mass(n, k):
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k, -1, -1):
        for rest in multi_indices_of_mass(n - 1, k - first):
            result.append((first,) + rest)
    return result

def leq(tau, alpha):
    return all(t <= a for t, a in zip(tau, alpha))

def sub(alpha, tau):
    return tuple(max(a - t, 0) for a, t in zip(alpha, tau))

def kth_shadow(S, k):
    if not S:
        return set()
    n = len(next(iter(S)))
    result = set()
    taus = multi_indices_of_mass(n, k)
    for alpha in S:
        for tau in taus:
            if leq(tau, alpha):
                result.add(sub(alpha, tau))
    return result

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(mass(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def is_log_concave(seq):
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k-1] * seq[k+1]:
            return False
    return True

def is_discrete_exchange_family(S):
    S_set = set(S)
    if not S_set:
        return True
    n = len(next(iter(S_set)))
    for alpha in S_set:
        for beta in S_set:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            candidate = list(alpha)
                            candidate[i] -= 1
                            candidate[j] += 1
                            if tuple(candidate) in S_set:
                                found = True
                                break
                    if not found:
                        return False
    return True

def matroid_basis_support(n, r):
    support = set()
    for basis in combinations(range(n), r):
        idx = [0] * n
        for elem in basis:
            idx[elem] = 1
        support.add(tuple(idx))
    return support


# ---- Main visualization ----

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Shadow Log-Concavity Conjecture: Experimental Evidence', 
             fontsize=16, fontweight='bold')

# Panel 1: Log-concavity ratios for uniform matroids
ax = axes[0]
ax.set_title('Uniform Matroids: a_k² vs a_{k-1}·a_{k+1}', fontsize=11)

data_x, data_y = [], []
for n in range(3, 10):
    for r in range(2, n):
        S = matroid_basis_support(n, r)
        profile = shadow_profile(S, max_k=r)
        for k in range(1, len(profile) - 1):
            if profile[k-1] > 0 and profile[k+1] > 0:
                ratio = profile[k]**2 / (profile[k-1] * profile[k+1])
                data_x.append(f"U_{{{r},{n}}},k={k}")
                data_y.append(ratio)

colors = ['green' if r >= 1 else 'red' for r in data_y]
ax.bar(range(len(data_y)), data_y, color=colors, alpha=0.7, width=0.8)
ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='LC threshold')
ax.set_ylabel('a_k² / (a_{k-1} · a_{k+1})')
ax.set_xlabel('Test case index')
ax.legend()
ax.set_ylim(0, max(data_y) * 1.1 if data_y else 2)

# Panel 2: Exchange vs non-exchange families
ax = axes[1]
ax.set_title('Exchange vs Non-Exchange Families', fontsize=11)

random.seed(42)
exch_lc, exch_not_lc, non_exch_lc, non_exch_not_lc = 0, 0, 0, 0

for n in range(2, 6):
    for d in range(2, 6):
        all_indices = multi_indices_of_mass(n, d)
        if len(all_indices) < 3:
            continue
        for _ in range(30):
            size = random.randint(3, min(len(all_indices), 12))
            S = set(random.sample(all_indices, size))
            exch = is_discrete_exchange_family(S)
            profile = shadow_profile(S, max_k=d)
            lc = is_log_concave(profile)
            if exch and lc:
                exch_lc += 1
            elif exch and not lc:
                exch_not_lc += 1
            elif not exch and lc:
                non_exch_lc += 1
            else:
                non_exch_not_lc += 1

categories = ['Exchange\n& LC', 'Exchange\n& ¬LC', '¬Exchange\n& LC', '¬Exchange\n& ¬LC']
values = [exch_lc, exch_not_lc, non_exch_lc, non_exch_not_lc]
colors = ['#2ecc71', '#e74c3c', '#3498db', '#95a5a6']
bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=0.5)
ax.set_ylabel('Number of supports tested')
for bar, val in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 1,
            str(val), ha='center', va='bottom', fontsize=10, fontweight='bold')

# Panel 3: Profile shape comparison
ax = axes[2]
ax.set_title('Shadow Profile Shapes (normalized)', fontsize=11)

examples = [
    ('U_{3,7}', matroid_basis_support(7, 3)),
    ('U_{4,8}', matroid_basis_support(8, 4)),
    ('Simplex(3,5)', set(multi_indices_of_mass(3, 5))),
    ('x⁴y⁴', {(4, 4)}),
]

for name, S in examples:
    max_d = max(mass(a) for a in S)
    profile = shadow_profile(S, max_k=max_d)
    max_val = max(profile)
    normalized = [v / max_val for v in profile]
    x_norm = [k / max_d for k in range(len(profile))]
    ax.plot(x_norm, normalized, 'o-', label=name, markersize=5, linewidth=2)

ax.set_xlabel('Normalized shadow depth k/d')
ax.set_ylabel('Normalized |Shadow_k| / max')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('log_concavity_evidence.png', dpi=150, bbox_inches='tight')
print("Saved log_concavity_evidence.png")
