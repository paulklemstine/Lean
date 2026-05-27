#!/usr/bin/env python3
"""
Visualization: Susceptibility Bounds — The Statistical Mechanics Bridge

Shows how susceptibility (sum of all pairwise covariances) scales with system
size n for uniform matroid distributions, compared against the proved bound
χ ≤ n·(1/4 + (n-1)·ε). Demonstrates the connection between Lorentzian
negativity and anti-ferromagnetic behavior in statistical physics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def make_matroid(n, r):
    subs = set(frozenset(c) for c in combinations(range(n), r))
    weights = {}
    w = 1.0 / len(subs)
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in subs else 0.0
    return weights


def coord_prob(weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(weights, i) * coord_prob(weights, j)


def susceptibility(n, weights):
    return sum(coord_cov(weights, i, j) for i in range(n) for j in range(n))


def find_max_eps(n, weights):
    best = 0.0
    for eps in np.linspace(0.001, 0.49, 300):
        ok = True
        for i in range(n):
            p = coord_prob(weights, i)
            if p < eps - 1e-12 or p > 1 - eps + 1e-12:
                ok = False; break
        if ok:
            for i in range(n):
                for j in range(n):
                    if i != j and abs(coord_cov(weights, i, j)) > eps + 1e-12:
                        ok = False; break
                if not ok: break
        if ok:
            best = eps
    return best


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: χ vs n for fixed r/n ≈ 1/2
ns_half = list(range(4, 13))
chi_vals = []
chi_bounds = []
chi_per_n = []

for n in ns_half:
    r = n // 2
    if comb(n, r) > 10000:
        continue
    w = make_matroid(n, r)
    chi = susceptibility(n, w)
    eps = find_max_eps(n, w)
    bound = n * (0.25 + (n-1) * eps) if eps > 0 else float('inf')
    chi_vals.append(chi)
    chi_bounds.append(bound)
    chi_per_n.append(chi / n)

x = ns_half[:len(chi_vals)]
axes[0].plot(x, chi_vals, 'bo-', linewidth=2, markersize=6, label='χ (actual)')
axes[0].plot(x, chi_bounds, 'r^--', linewidth=2, markersize=6, label='Bound')
axes[0].set_xlabel('n')
axes[0].set_ylabel('Susceptibility χ')
axes[0].set_title('χ vs n for U(n, ⌊n/2⌋)', fontweight='bold')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Panel 2: χ/n vs n (per-particle response)
axes[1].plot(x, chi_per_n, 'gs-', linewidth=2, markersize=6, label='χ/n')
axes[1].axhline(y=0.25, color='orange', linestyle=':', linewidth=2, label='1/4 (diagonal only)')
axes[1].set_xlabel('n')
axes[1].set_ylabel('χ/n')
axes[1].set_title('Per-Particle Susceptibility', fontweight='bold')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Panel 3: Susceptibility for different ranks
for n in [6, 8, 10]:
    if n > 10:
        continue
    ranks = list(range(1, n))
    chis = []
    for r in ranks:
        if comb(n, r) > 10000:
            chis.append(np.nan)
            continue
        w = make_matroid(n, r)
        chis.append(susceptibility(n, w))
    axes[2].plot(ranks, chis, 'o-', linewidth=1.5, markersize=5, label=f'n={n}')

axes[2].set_xlabel('Rank r')
axes[2].set_ylabel('Susceptibility χ')
axes[2].set_title('χ vs Rank for Various n', fontweight='bold')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

fig.suptitle('Susceptibility Bounds: Lorentzian Negativity Suppresses Clustering',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('susceptibility_bounds.png', dpi=150, bbox_inches='tight')
print("Saved susceptibility_bounds.png")
