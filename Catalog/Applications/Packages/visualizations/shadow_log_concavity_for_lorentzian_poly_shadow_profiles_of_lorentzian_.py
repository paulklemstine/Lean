"""
Visualization: Shadow Profiles and Log-Concavity

Visualizes the shadow cardinality sequences for various families of polynomial
supports, highlighting the log-concavity property. The plot shows how the
shadow profile |Sh_k(S)| varies with k for different support families,
and marks the log-concavity ratios.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations, product as iproduct
from math import comb
from typing import List, Tuple, Set

# ─── Self-contained core functions ───────────────────────────────────────────

def bounded_compositions(n, total, bounds):
    results = []
    def bt(idx, rem, cur):
        if idx == n:
            if rem == 0: results.append(tuple(cur))
            return
        for v in range(min(rem, bounds[idx]) + 1):
            cur.append(v); bt(idx+1, rem-v, cur); cur.pop()
    bt(0, total, [])
    return results

def kth_shadow(S, d, k):
    target = d - k
    if target < 0: return set()
    shadow = set()
    for alpha in S:
        for beta in bounded_compositions(len(alpha), target, alpha):
            shadow.add(beta)
    return shadow

def shadow_profile(S, d):
    return [len(kth_shadow(S, d, k)) for k in range(d + 1)]

def boolean_support(n, r):
    S = set()
    for subset in combinations(range(n), r):
        vec = [0]*n
        for i in subset: vec[i] = 1
        S.add(tuple(vec))
    return S

def simplex_product_support(dims):
    n = sum(dims)
    offsets = [sum(dims[:i]) for i in range(len(dims))]
    groups = []
    for j, d in enumerate(dims):
        group = []
        for idx in range(d):
            vec = [0]*n
            vec[offsets[j] + idx] = 1
            group.append(tuple(vec))
        groups.append(group)
    S = set()
    for combo in iproduct(*groups):
        total = tuple(sum(v[i] for v in combo) for i in range(n))
        S.add(total)
    return S

def complete_simplex(n, d):
    return set(bounded_compositions(n, d, tuple([d]*n)))

def random_mconvex(n, d, size, seed=42):
    rng = np.random.RandomState(seed)
    start = [0]*n
    for _ in range(d): start[rng.randint(n)] += 1
    S = {tuple(start)}
    for _ in range(size*20):
        if len(S) >= size: break
        alpha = list(list(S)[rng.randint(len(S))])
        nz = [i for i in range(n) if alpha[i] > 0]
        if not nz: continue
        i = nz[rng.randint(len(nz))]
        j = rng.randint(n)
        if i != j:
            na = alpha[:]; na[i] -= 1; na[j] += 1
            S.add(tuple(na))
    return S

# ─── Generate data ───────────────────────────────────────────────────────────

families = {
    r'$U_{3,7}$ (Boolean)': (boolean_support(7, 3), 3),
    r'$U_{4,8}$ (Boolean)': (boolean_support(8, 4), 4),
    r'Simplex $[2]^3$': (simplex_product_support([2,2,2]), 3),
    r'Simplex $[3]^2$': (simplex_product_support([3,3]), 2),
    r'Complete $h_3(\mathbf{x}_4)$': (complete_simplex(4, 3), 3),
    r'Random M-convex': (random_mconvex(5, 4, 25, 42), 4),
}

# ─── Plot ─────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0', '#F44336', '#00BCD4']

for idx, (name, (S, d)) in enumerate(families.items()):
    ax = axes[idx]
    prof = shadow_profile(S, d)
    ks = list(range(d + 1))

    # Bar chart of shadow profile
    bars = ax.bar(ks, prof, color=colors[idx], alpha=0.7, edgecolor='white', linewidth=0.5)

    # Overlay line
    ax.plot(ks, prof, 'o-', color=colors[idx], markersize=6, linewidth=2, zorder=5)

    # Mark log-concavity ratios
    for k in range(1, len(prof) - 1):
        denom = prof[k-1] * prof[k+1]
        if denom > 0:
            ratio = prof[k]**2 / denom
            ax.annotate(f'{ratio:.2f}', xy=(k, prof[k]),
                       xytext=(0, 12), textcoords='offset points',
                       ha='center', fontsize=8, color='darkgreen',
                       fontweight='bold')

    ax.set_title(name, fontsize=11, fontweight='bold')
    ax.set_xlabel('Shadow depth k', fontsize=9)
    ax.set_ylabel('|Sh_k(S)|', fontsize=9)
    ax.set_xticks(ks)
    ax.grid(axis='y', alpha=0.3)

    # Add |S| and log-concavity status
    lc = all(prof[k]**2 >= prof[k-1]*prof[k+1] for k in range(1, len(prof)-1))
    status = '✓ Log-concave' if lc else '✗ Not log-concave'
    ax.text(0.02, 0.95, f'|S|={len(S)}\n{status}',
            transform=ax.transAxes, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Shadow Profiles of Lorentzian Polynomial Supports\n'
             'Numbers above bars: log-concavity ratio a[k]²/(a[k-1]·a[k+1])',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved shadow_profiles.png")
