#!/usr/bin/env python3
"""
Visualization 1: Integrality Gap vs Edge-Size Heterogeneity
============================================================

This plot shows the relationship between edge-size heterogeneity (variance)
and the integrality gap (τ - τ*) for random hypergraphs. The emerging
pattern reveals a threshold phenomenon: above a critical heterogeneity
value, positive gaps become nearly universal.

Points are colored by whether they have a positive ceiling gap (τ - ⌈τ*⌉ ≥ 1).
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
import random
from collections import Counter


# ---- Inline all needed functions ----

def edge_heterogeneity(edge_list):
    sizes = [len(e) for e in edge_list]
    if not sizes:
        return 0.0
    mu = np.mean(sizes)
    return float(np.mean([(s - mu)**2 for s in sizes]))


def collision_index(edge_list):
    sizes = [len(e) for e in edge_list]
    if not sizes:
        return 1.0
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c/n)**2 for c in counts.values())


def is_transversal(edges, S):
    return all(len(S & e) > 0 for e in edges)


def transversal_number_exact(n, edges):
    if not edges:
        return 0
    for k in range(n + 1):
        for S in itertools.combinations(range(n), k):
            if is_transversal(edges, set(S)):
                return k
    return n


def fractional_transversal_number(n, edges):
    try:
        from scipy.optimize import linprog
        m = len(edges)
        if m == 0:
            return 0.0
        c = np.ones(n)
        A_ub = np.zeros((m, n))
        for i, e in enumerate(edges):
            for v in e:
                A_ub[i, v] = -1.0
        b_ub = -np.ones(m)
        result = linprog(c, A_ub=A_ub, b_ub=b_ub,
                         bounds=[(0, None)]*n, method='highs')
        return float(result.fun) if result.success else float('nan')
    except ImportError:
        return float('nan')


def random_hypergraph(n, num_edges, edge_sizes, rng):
    vertices = list(range(n))
    edges = set()
    for _ in range(num_edges):
        k = rng.choice(edge_sizes)
        if k <= n:
            edge = frozenset(rng.sample(vertices, k))
            edges.add(edge)
    return list(edges)


# ---- Generate data ----
n = 12
num_trials = 300
rng = random.Random(42)

hets = []
gaps = []
ceil_gaps = []
cis = []

for trial in range(num_trials):
    num_edges = rng.randint(3, 12)
    edges = random_hypergraph(n, num_edges, [2, 3, 4, 5], rng)
    if not edges:
        continue

    het = edge_heterogeneity(edges)
    ci = collision_index(edges)
    tau = transversal_number_exact(n, edges)
    tau_star = fractional_transversal_number(n, edges)
    if np.isnan(tau_star):
        continue

    gap = tau - tau_star
    cg = tau - int(np.ceil(tau_star - 1e-10))

    hets.append(het)
    gaps.append(gap)
    ceil_gaps.append(cg)
    cis.append(ci)

hets = np.array(hets)
gaps = np.array(gaps)
ceil_gaps = np.array(ceil_gaps)
cis = np.array(cis)

# ---- Plot ----
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Gap vs Heterogeneity
ax = axes[0]
pos_mask = ceil_gaps >= 1
neg_mask = ~pos_mask

ax.scatter(hets[neg_mask], gaps[neg_mask], c='steelblue', alpha=0.5,
           s=30, label='No ceiling gap', edgecolors='none')
ax.scatter(hets[pos_mask], gaps[pos_mask], c='crimson', alpha=0.7,
           s=50, label='Positive ceiling gap', edgecolors='none', marker='D')

ax.set_xlabel('Edge-Size Heterogeneity (σ²)', fontsize=13)
ax.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax.set_title('Integrality Gap vs Heterogeneity\n(Random hypergraphs, n=12)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Add threshold line
if any(pos_mask):
    threshold = min(hets[pos_mask]) * 0.9
    ax.axvline(x=threshold, color='orange', linestyle='--', linewidth=2,
               alpha=0.7, label=f'δ* ≈ {threshold:.2f}')
    ax.legend(fontsize=11)

# Right: Collision Index vs Gap
ax = axes[1]
ax.scatter(cis[neg_mask], gaps[neg_mask], c='steelblue', alpha=0.5,
           s=30, label='No ceiling gap', edgecolors='none')
ax.scatter(cis[pos_mask], gaps[pos_mask], c='crimson', alpha=0.7,
           s=50, label='Positive ceiling gap', edgecolors='none', marker='D')

ax.set_xlabel('Collision Index', fontsize=13)
ax.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax.set_title('Integrality Gap vs Collision Index\n(Lower CI = more disorder)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.axvline(x=1.0, color='green', linestyle=':', linewidth=2, alpha=0.5,
           label='CI = 1 (uniform)')

plt.tight_layout()
plt.savefig('gap_vs_heterogeneity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved gap_vs_heterogeneity.png")
