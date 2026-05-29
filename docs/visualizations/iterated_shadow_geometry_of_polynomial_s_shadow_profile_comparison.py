"""
Visualization: Shadow Profile Comparison

Plots the shadow profile a_k = |Sh_k(S)| for several families of supports,
showing how derivative complexity decays as the shadow depth increases.
The log-concavity of these curves is visually apparent and relates to
deep conjectures connecting discrete convex geometry to polynomial algebra.
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

def product_simplex_support(dims):
    if not dims: return {()}
    result = set()
    for a in range(dims[0]+1):
        for rest in product_simplex_support(dims[1:]):
            result.add((a,)+rest)
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Simplex supports
ax = axes[0]
for n, d, color in [(3, 3, '#2196F3'), (3, 5, '#4CAF50'), (4, 3, '#FF9800'), (4, 4, '#E91E63')]:
    S = simplex_support(n, d)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 'o-', color=color, label=f'Simplex({n},{d})',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Simplex Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Matroid basis supports
ax = axes[1]
for n, r, color in [(5, 2, '#2196F3'), (6, 2, '#4CAF50'), (6, 3, '#FF9800'), (7, 3, '#E91E63')]:
    S = matroid_basis_support(n, r)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 's-', color=color, label=f'U({r},{n})',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Matroid Basis Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Product simplex supports
ax = axes[2]
for dims, color in [([2,2,2], '#2196F3'), ([3,2,1], '#4CAF50'), ([3,3,2], '#FF9800'), ([4,2,2], '#E91E63')]:
    S = product_simplex_support(dims)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 'D-', color=color, label=f'Prod{dims}',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Product Simplex Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle('Shadow Profiles: Derivative Complexity Decay', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
