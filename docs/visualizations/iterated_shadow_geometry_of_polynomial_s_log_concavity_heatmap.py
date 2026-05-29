"""
Visualization: Log-Concavity Heatmap

Creates a heatmap showing the log-concavity ratio a_k^2 / (a_{k-1} * a_{k+1})
for various support families and shadow depths. Values >= 1 confirm log-concavity.
The conjecture predicts all cells should be >= 1 for exchange families.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow

def shadow_profile(S, max_k=None):
    if not S: return [0]
    if max_k is None: max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def matroid_basis_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0]*n
        for i in combo: vec[i] = 1
        result.add(tuple(vec))
    return result

def simplex_support(n, d):
    return set(multi_indices_of_mass(n, d))


# Compute log-concavity ratios for various families
families = []
labels = []

for n in range(3, 8):
    for r in range(1, n):
        if r >= n: continue
        S = matroid_basis_support(n, r)
        prof = shadow_profile(S)
        families.append(prof)
        labels.append(f'U({r},{n})')

for n in range(2, 6):
    for d in range(2, 6):
        S = simplex_support(n, d)
        prof = shadow_profile(S)
        families.append(prof)
        labels.append(f'Δ({n},{d})')

# Find max length
max_len = max(len(p) for p in families)

# Compute LC ratios
ratios = np.full((len(families), max_len - 2), np.nan)
for i, prof in enumerate(families):
    for k in range(1, len(prof) - 1):
        if prof[k-1] > 0 and prof[k+1] > 0:
            ratios[i, k-1] = prof[k]**2 / (prof[k-1] * prof[k+1])
        elif prof[k] > 0 and prof[k+1] == 0:
            ratios[i, k-1] = float('inf')

# Plot
fig, ax = plt.subplots(figsize=(12, 8))

# Replace inf with a large number for display
display_ratios = np.where(np.isinf(ratios), 5.0, ratios)
display_ratios = np.where(np.isnan(display_ratios), 0, display_ratios)

im = ax.imshow(display_ratios, cmap='RdYlGn', vmin=0.5, vmax=3.0, aspect='auto')
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=8)
ax.set_xticks(range(max_len - 2))
ax.set_xticklabels([f'k={k+1}' for k in range(max_len - 2)], fontsize=9)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Support family', fontsize=12)
ax.set_title('Log-Concavity Ratios: a_k² / (a_{k-1} · a_{k+1})\n'
             'Green ≥ 1 confirms log-concavity; Red < 1 would refute it',
             fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(families)):
    for j in range(max_len - 2):
        if not np.isnan(ratios[i, j]) and not np.isinf(ratios[i, j]):
            ax.text(j, i, f'{ratios[i,j]:.2f}', ha='center', va='center',
                   fontsize=6, color='black')
        elif np.isinf(ratios[i, j]):
            ax.text(j, i, '∞', ha='center', va='center', fontsize=7, color='darkgreen')

plt.colorbar(im, ax=ax, label='LC ratio (≥1 = log-concave)')
plt.tight_layout()
plt.savefig('log_concavity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved log_concavity_heatmap.png")
