"""
Visualization: Shadow Profile Heatmap

Visualizes how the shadow profile a_k = |Shadow_k(S)| varies across
different support geometries. Shows the "derivative complexity decay"
pattern as a heatmap comparing multiple support types.

Uses only matplotlib, no local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


# ---- Inline helper functions (no local imports) ----

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

def matroid_basis_support(n, r):
    support = set()
    for basis in combinations(range(n), r):
        idx = [0] * n
        for elem in basis:
            idx[elem] = 1
        support.add(tuple(idx))
    return support


# ---- Main visualization ----

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Shadow Profiles: Derivative Complexity Decay Patterns', 
             fontsize=16, fontweight='bold')

# (a) Single monomial profiles
ax = axes[0, 0]
ax.set_title('Single Monomial x^d (n=3 vars)', fontsize=12)
for d in range(2, 8):
    S = {tuple([d] + [0] * 2)}
    # Actually let's use the full monomial (d, 0, 0)
    # For a more interesting pattern, use (d//3, d//3, d - 2*(d//3))
    a, b = d // 2, d - d // 2
    S = {(a, b, 0)}
    profile = shadow_profile(S, max_k=d)
    # Normalize to compare shapes
    ax.plot(range(len(profile)), profile, 'o-', label=f'd={d}', markersize=4)
ax.set_xlabel('Shadow depth k')
ax.set_ylabel('|Shadow_k(S)|')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# (b) Simplex supports (all multi-indices of given degree)
ax = axes[0, 1]
ax.set_title('Full Simplex Supports (all multi-indices of degree d)', fontsize=12)
for n in [2, 3, 4]:
    for d in [4, 6]:
        S = set(multi_indices_of_mass(n, d))
        profile = shadow_profile(S, max_k=d)
        ax.plot(range(len(profile)), profile, 'o-', 
                label=f'n={n}, d={d}', markersize=4)
ax.set_xlabel('Shadow depth k')
ax.set_ylabel('|Shadow_k(S)|')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# (c) Uniform matroid profiles
ax = axes[1, 0]
ax.set_title('Uniform Matroid U_{r,n} Basis Supports', fontsize=12)
for n in [5, 6, 7, 8]:
    r = 3
    S = matroid_basis_support(n, r)
    profile = shadow_profile(S, max_k=r)
    ax.plot(range(len(profile)), profile, 's-', 
            label=f'U_{{3,{n}}}', markersize=6)
ax.set_xlabel('Shadow depth k')
ax.set_ylabel('|Shadow_k(S)|')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# (d) Heatmap: profile normalized by max, for varying degree
ax = axes[1, 1]
ax.set_title('Shadow Profile Heatmap (n=3, varying degree)', fontsize=12)
max_d = 8
heatmap_data = np.zeros((max_d, max_d + 1))
for d in range(1, max_d + 1):
    S = set(multi_indices_of_mass(3, d))
    profile = shadow_profile(S, max_k=d)
    max_val = max(profile) if profile else 1
    for k, val in enumerate(profile):
        heatmap_data[d - 1, k] = val / max_val

im = ax.imshow(heatmap_data, aspect='auto', cmap='YlOrRd', 
               origin='lower', extent=[-0.5, max_d + 0.5, 0.5, max_d + 0.5])
ax.set_xlabel('Shadow depth k')
ax.set_ylabel('Total degree d')
plt.colorbar(im, ax=ax, label='Normalized |Shadow_k|')

plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
