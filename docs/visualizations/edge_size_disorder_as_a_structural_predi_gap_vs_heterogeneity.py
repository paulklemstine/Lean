#!/usr/bin/env python3
"""
Visualization: Integrality Gap vs Edge-Size Heterogeneity

Visualizes the core conjecture: as edge-size heterogeneity (variance)
increases, the integrality gap τ - τ* tends to grow, and positive
ceiling gaps become more frequent. The plot shows random hypergraphs
on 15 vertices with edge sizes in {2,3,4,5}, colored by whether they
exhibit a positive ceiling gap.
"""

import random
import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def generate_random_hypergraph(n_vertices, n_edges, edge_sizes):
    vertices = list(range(n_vertices))
    edges = set()
    attempts = 0
    while len(edges) < n_edges and attempts < n_edges * 100:
        k = random.choice(edge_sizes)
        if k <= n_vertices:
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.add(edge)
        attempts += 1
    return vertices, list(edges)


def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    return sum((s - mean_size) ** 2 for s in sizes) / len(sizes)


def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def exact_transversal_number(vertices, edges):
    n = len(vertices)
    for size in range(n + 1):
        for subset in itertools.combinations(vertices, size):
            S = set(subset)
            if all(S & set(e) for e in edges):
                return size
    return n


def lp_fractional_transversal(vertices, edges):
    try:
        from scipy.optimize import linprog
        n = len(vertices)
        m = len(edges)
        if m == 0:
            return 0.0
        c = np.ones(n)
        A_ub = np.zeros((m, n))
        b_ub = -np.ones(m)
        for i, e in enumerate(edges):
            for v in e:
                A_ub[i, v] = -1.0
        bounds = [(0, None)] * n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    # Fallback
    if not edges:
        return 0.0
    weights = {v: 0.0 for v in vertices}
    for e in edges:
        for v in e:
            weights[v] += 1.0 / len(e)
    for _ in range(200):
        min_s = min(sum(weights[v] for v in e) for e in edges)
        if min_s >= 1.0 - 1e-10:
            break
        if min_s > 0:
            for v in vertices:
                weights[v] /= min_s
    return sum(weights.values())


random.seed(42)
np.random.seed(42)

hets, gaps, ceil_gaps, cis = [], [], [], []

for _ in range(600):
    n_edges = random.randint(4, 18)
    vertices, edges = generate_random_hypergraph(15, n_edges, [2, 3, 4, 5])
    if not edges:
        continue
    h = edge_heterogeneity(edges)
    ci = collision_index(edges)
    tau = exact_transversal_number(vertices, edges)
    tau_star = lp_fractional_transversal(vertices, edges)
    hets.append(h)
    gaps.append(tau - tau_star)
    ceil_gaps.append(tau - int(np.ceil(tau_star)))
    cis.append(ci)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Gap vs Heterogeneity
colors = ['#e74c3c' if cg >= 1 else '#3498db' for cg in ceil_gaps]
ax1.scatter(hets, gaps, c=colors, alpha=0.5, s=20, edgecolors='none')
ax1.set_xlabel('Edge-Size Heterogeneity (σ²)', fontsize=13)
ax1.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax1.set_title('Integrality Gap vs Edge-Size Heterogeneity', fontsize=14)
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Add legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#e74c3c', label='Positive ceiling gap (τ > ⌈τ*⌉)'),
                   Patch(facecolor='#3498db', label='No ceiling gap')]
ax1.legend(handles=legend_elements, fontsize=10)

# Right: Collision Index vs Gap
ax2.scatter(cis, gaps, c=colors, alpha=0.5, s=20, edgecolors='none')
ax2.set_xlabel('Collision Index (Σ pₖ²)', fontsize=13)
ax2.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax2.set_title('Integrality Gap vs Collision Index', fontsize=14)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('viz_gap_vs_heterogeneity.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_vs_heterogeneity.png")
