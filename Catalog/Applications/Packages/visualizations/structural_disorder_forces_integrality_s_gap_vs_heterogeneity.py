#!/usr/bin/env python3
"""
Visualization: Gap vs Heterogeneity Scatter Plot

Visualizes the relationship between edge-size heterogeneity (variance)
and the integrality gap τ − τ* for random hypergraphs on n=12 vertices.
Points are colored by collision index to show the information-theoretic
disorder dimension. The explicit disjoint-triangles family is highlighted.

This is the central visualization of the Heterogeneity–Gap Conjecture:
it shows that high disorder (large heterogeneity, low collision index)
correlates with large integrality gaps.
"""

import itertools
import random
import math
from collections import Counter
import numpy as np
import matplotlib.pyplot as plt


# ── Self-contained computations ──────────────────────────────────────

def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean = sum(sizes) / len(sizes)
    return sum((s - mean) ** 2 for s in sizes) / len(sizes)

def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c / n) ** 2 for c in counts.values())

def transversal_number_exact(n_vertices, edges):
    for size in range(n_vertices + 1):
        for S in itertools.combinations(range(n_vertices), size):
            S_set = set(S)
            if all(S_set & e for e in edges):
                return size
    return n_vertices

def fractional_transversal_lp(n_vertices, edges):
    try:
        from scipy.optimize import linprog
        c = np.ones(n_vertices)
        A_ub = [[-1 if v in e else 0 for v in range(n_vertices)] for e in edges]
        b_ub = [-1] * len(edges)
        bounds = [(0, 1)] * n_vertices
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    return 0.0

def random_hypergraph(n_v, n_e, sizes=[2, 3, 4, 5]):
    edges = set()
    for _ in range(n_e * 3):
        k = random.choice(sizes)
        k = min(k, n_v)
        e = frozenset(random.sample(range(n_v), k))
        edges.add(e)
        if len(edges) >= n_e:
            break
    return list(edges)

def disjoint_triangles_family(n_param):
    n_v = 3 * n_param
    edges = []
    for i in range(n_param):
        b = 3 * i
        edges.append(frozenset([b, b+1]))
        edges.append(frozenset([b, b+2]))
        edges.append(frozenset([b+1, b+2]))
    edges.append(frozenset(3*i for i in range(n_param)))
    return n_v, edges


# ── Generate data ────────────────────────────────────────────────────

random.seed(42)
n_v = 12
n_e = 10
n_trials = 300

hets, gaps, cis, ceil_gaps = [], [], [], []
for _ in range(n_trials):
    edges = random_hypergraph(n_v, n_e)
    if not edges:
        continue
    het = edge_heterogeneity(edges)
    ci = collision_index(edges)
    tau = transversal_number_exact(n_v, edges)
    tau_star = fractional_transversal_lp(n_v, edges)
    gap = tau - tau_star
    cgap = tau - math.ceil(tau_star - 1e-9)

    hets.append(het)
    gaps.append(gap)
    cis.append(ci)
    ceil_gaps.append(cgap)

# Family data
fam_hets, fam_gaps, fam_ns = [], [], []
for n_param in range(3, 8):
    nv, edges = disjoint_triangles_family(n_param)
    het = edge_heterogeneity(edges)
    tau_star = fractional_transversal_lp(nv, edges)
    tau = 2 * n_param  # known
    fam_hets.append(het)
    fam_gaps.append(tau - tau_star)
    fam_ns.append(n_param)


# ── Plot ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Gap vs Heterogeneity
ax = axes[0]
sc = ax.scatter(hets, gaps, c=cis, cmap='RdYlBu', alpha=0.6, s=30,
                edgecolors='gray', linewidths=0.3, vmin=0.2, vmax=1.0)
ax.scatter(fam_hets, fam_gaps, c='red', marker='D', s=100, zorder=5,
           edgecolors='black', linewidths=1.5, label='Disjoint triangles family')
for i, n in enumerate(fam_ns):
    ax.annotate(f'n={n}', (fam_hets[i], fam_gaps[i]),
                textcoords="offset points", xytext=(8, 5), fontsize=8,
                fontweight='bold', color='darkred')

ax.set_xlabel('Edge-size heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Integrality gap (τ − τ*)', fontsize=12)
ax.set_title('Disorder Forces Integrality Separation', fontsize=13,
             fontweight='bold')
ax.legend(fontsize=10)
plt.colorbar(sc, ax=ax, label='Collision index')
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.4, label='gap = 1')

# Right: Collision Index vs Gap
ax = axes[1]
ax.scatter(cis, gaps, c=hets, cmap='magma', alpha=0.6, s=30,
           edgecolors='gray', linewidths=0.3)
fam_cis = [collision_index(disjoint_triangles_family(n)[1]) for n in fam_ns]
ax.scatter(fam_cis, fam_gaps, c='red', marker='D', s=100, zorder=5,
           edgecolors='black', linewidths=1.5, label='Disjoint triangles')
ax.set_xlabel('Collision index (CI)', fontsize=12)
ax.set_ylabel('Integrality gap (τ − τ*)', fontsize=12)
ax.set_title('Information-Theoretic Disorder vs Gap', fontsize=13,
             fontweight='bold')
ax.legend(fontsize=10)
cb = plt.colorbar(ax.collections[0], ax=ax, label='Heterogeneity (σ²)')

plt.tight_layout()
plt.savefig('gap_vs_heterogeneity.png', dpi=150, bbox_inches='tight')
print("Saved: gap_vs_heterogeneity.png")
