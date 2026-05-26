#!/usr/bin/env python3
"""
Visualization: Explicit Two-Scale Family Analysis

Plots the behavior of the explicit two-scale hypergraph family H_m
as the parameter m grows, showing how heterogeneity, collision index,
and integrality gap evolve. This family is the key constructive
example in the Heterogeneity-Gap theory.
"""

import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def two_scale_family(m):
    """Construct H_m: m disjoint pairs + one large edge of even vertices."""
    n = 2 * m + 1
    vertices = list(range(n))
    edges = []
    for i in range(m):
        edges.append((2 * i, 2 * i + 1))
    large = tuple(range(0, 2 * m, 2))
    if len(large) >= 2:
        edges.append(large)
    return vertices, edges


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


def support_width(edges):
    if not edges:
        return 0
    sizes = [len(e) for e in edges]
    return max(sizes) - min(sizes)


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
    return float('nan')


ms = list(range(2, 12))
hets, cis, sws, taus, tau_stars, gaps = [], [], [], [], [], []

for m in ms:
    vertices, edges = two_scale_family(m)
    hets.append(edge_heterogeneity(edges))
    cis.append(collision_index(edges))
    sws.append(support_width(edges))

    if m <= 9:
        tau = exact_transversal_number(vertices, edges)
    else:
        tau = m  # Known: τ = m for this family
    tau_star = lp_fractional_transversal(vertices, edges)

    taus.append(tau)
    tau_stars.append(tau_star)
    gaps.append(tau - tau_star)

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Plot 1: Disorder invariants vs m
ax = axes[0, 0]
ax.plot(ms, hets, 'ro-', label='Heterogeneity (σ²)', markersize=7)
ax.plot(ms, cis, 'bs-', label='Collision Index', markersize=7)
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Disorder Invariants vs Parameter m', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Support width vs m
ax = axes[0, 1]
ax.bar(ms, sws, color='#27ae60', alpha=0.7)
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Support Width', fontsize=12)
ax.set_title('Support Width Growth', fontsize=13)
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: τ and τ* vs m
ax = axes[1, 0]
ax.plot(ms, taus, 'ro-', label='τ (integer)', markersize=8, linewidth=2)
ax.plot(ms, tau_stars, 'b^-', label='τ* (fractional)', markersize=8, linewidth=2)
ax.fill_between(ms, tau_stars, taus, alpha=0.2, color='purple',
                label='Integrality gap')
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Transversal Number', fontsize=12)
ax.set_title('Integer vs Fractional Transversal', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 4: Gap vs heterogeneity for this family
ax = axes[1, 1]
ax.scatter(hets, gaps, c='purple', s=80, zorder=5)
for i, m in enumerate(ms):
    ax.annotate(f'm={m}', (hets[i], gaps[i]), textcoords="offset points",
                xytext=(5, 5), fontsize=9)
ax.set_xlabel('Heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Integrality Gap (τ − τ*)', fontsize=12)
ax.set_title('Gap vs Heterogeneity in Two-Scale Family', fontsize=13)
ax.grid(True, alpha=0.3)

plt.suptitle('Two-Scale Hypergraph Family H_m: Disorder Forces Gap',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_family_analysis.png', dpi=150, bbox_inches='tight')
print("Saved viz_family_analysis.png")
