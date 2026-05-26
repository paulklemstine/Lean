#!/usr/bin/env python3
"""
Visualization 2: Disorder Phase Diagram
=========================================

This visualization shows the "phase diagram" of hypergraphs in the
(collision index, heterogeneity) plane, colored by the integrality gap.
It reveals two distinct phases:
  - Ordered phase (CI ≈ 1, low heterogeneity): LP relaxation is tight
  - Disordered phase (CI < 1, high heterogeneity): significant gap

This is the statistical mechanics analogy: disorder drives phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import itertools
import random
from collections import Counter


# ---- Inline functions ----

def edge_heterogeneity(edges):
    sizes = [len(e) for e in edges]
    if not sizes:
        return 0.0
    mu = np.mean(sizes)
    return float(np.mean([(s - mu)**2 for s in sizes]))


def collision_index(edges):
    sizes = [len(e) for e in edges]
    if not sizes:
        return 1.0
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c/n)**2 for c in counts.values())


def support_width(edges):
    sizes = [len(e) for e in edges]
    return (max(sizes) - min(sizes)) if sizes else 0


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


# ---- Generate data ----
n = 12
num_trials = 400
rng = random.Random(123)

data = []
for trial in range(num_trials):
    num_edges = rng.randint(3, 14)
    vertices = list(range(n))
    edges = set()
    sizes_pool = rng.choice([[2,3], [2,4], [2,5], [3,5], [2,3,4,5], [2,3,4], [3,4,5]])
    for _ in range(num_edges):
        k = rng.choice(sizes_pool)
        if k <= n:
            edge = frozenset(rng.sample(vertices, k))
            edges.add(edge)
    edges = list(edges)
    if not edges:
        continue

    het = edge_heterogeneity(edges)
    ci = collision_index(edges)
    sw = support_width(edges)
    tau = transversal_number_exact(n, edges)
    tau_star = fractional_transversal_number(n, edges)
    if np.isnan(tau_star):
        continue

    gap = tau - tau_star
    data.append((ci, het, gap, sw))

cis = np.array([d[0] for d in data])
hets = np.array([d[1] for d in data])
gaps = np.array([d[2] for d in data])
widths = np.array([d[3] for d in data])

# ---- Plot ----
fig, ax = plt.subplots(figsize=(10, 8))

# Color by gap
scatter = ax.scatter(cis, hets, c=gaps, cmap='RdYlBu_r',
                     s=40 + widths * 15, alpha=0.7,
                     edgecolors='gray', linewidths=0.3,
                     vmin=0, vmax=max(gaps.max(), 1))

cbar = plt.colorbar(scatter, ax=ax, label='Integrality Gap (τ − τ*)')
cbar.ax.tick_params(labelsize=11)

# Phase boundary
ax.axvline(x=1.0, color='green', linestyle=':', linewidth=2, alpha=0.5)
ax.annotate('Uniform\n(ordered phase)', xy=(0.98, 0.02),
            xycoords='data', fontsize=10, color='green',
            ha='right', va='bottom')

# Labels
ax.set_xlabel('Collision Index', fontsize=14)
ax.set_ylabel('Edge-Size Heterogeneity (σ²)', fontsize=14)
ax.set_title('Disorder Phase Diagram\nPoint size ∝ support width; color = integrality gap',
             fontsize=15)
ax.grid(True, alpha=0.2)

# Add phase labels
ax.text(0.85, max(hets)*0.8, 'DISORDERED\n(large gap)',
        fontsize=12, color='darkred', alpha=0.7,
        ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.5))

if min(cis) < 0.95:
    ax.text(min(cis) + 0.02, min(hets) + 0.1, 'Transition\nregion',
            fontsize=10, color='gray', alpha=0.7)

plt.tight_layout()
plt.savefig('disorder_phases.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved disorder_phases.png")
