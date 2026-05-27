#!/usr/bin/env python3
"""
Visualization: Disjoint Triangles Family — Growth of Gap with Parameter

Shows how the integrality gap, heterogeneity, and collision index evolve
as the parameter n grows in the disjoint-triangles-plus-large-edge family.
This is the explicit infinite family proved in the Lean development to have
positive heterogeneity and positive ceiling gap for n ≥ 3.
"""

import math
from collections import Counter
import numpy as np
import matplotlib.pyplot as plt


# ── Self-contained computations ──────────────────────────────────────

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

def fractional_transversal_lp(n_v, edges):
    try:
        from scipy.optimize import linprog
        c = np.ones(n_v)
        A_ub = [[-1 if v in e else 0 for v in range(n_v)] for e in edges]
        b_ub = [-1] * len(edges)
        bounds = [(0, 1)] * n_v
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    return 3 * n_v / (2 * 3)  # fallback: 3n/2


# ── Compute family data ──────────────────────────────────────────────

ns = list(range(2, 20))
data = {'n': [], 'tau': [], 'tau_star': [], 'gap': [], 'ceil_gap': [],
        'het': [], 'ci': [], 'sw': []}

for n in ns:
    nv, edges = disjoint_triangles_family(n)
    het = edge_heterogeneity(edges)
    ci = collision_index(edges)
    sw = max(len(e) for e in edges) - min(len(e) for e in edges)
    tau = 2 * n  # proved in Lean
    tau_star = fractional_transversal_lp(nv, edges)
    gap = tau - tau_star
    cgap = tau - math.ceil(tau_star - 1e-9)

    data['n'].append(n)
    data['tau'].append(tau)
    data['tau_star'].append(tau_star)
    data['gap'].append(gap)
    data['ceil_gap'].append(cgap)
    data['het'].append(het)
    data['ci'].append(ci)
    data['sw'].append(sw)


# ── Plot ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Top-left: τ and τ* vs n
ax = axes[0, 0]
ax.plot(data['n'], data['tau'], 'bo-', label='τ (integer)', markersize=5)
ax.plot(data['n'], data['tau_star'], 'rs-', label='τ* (fractional)',
        markersize=5)
ax.fill_between(data['n'], data['tau_star'], data['tau'],
                alpha=0.2, color='green', label='Gap region')
ax.set_xlabel('Parameter n', fontsize=11)
ax.set_ylabel('Transversal number', fontsize=11)
ax.set_title('Integer vs Fractional Transversal', fontsize=12,
             fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Top-right: Gap vs n
ax = axes[0, 1]
ax.plot(data['n'], data['gap'], 'g^-', label='τ − τ*', markersize=6)
ax.plot(data['n'], data['ceil_gap'], 'mv-', label='τ − ⌈τ*⌉',
        markersize=6)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Gap = 1')
ax.axvline(x=3, color='gray', linestyle=':', alpha=0.5, label='n = 3 threshold')
ax.set_xlabel('Parameter n', fontsize=11)
ax.set_ylabel('Gap', fontsize=11)
ax.set_title('Integrality Gap Growth', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-left: Heterogeneity vs n
ax = axes[1, 0]
ax.plot(data['n'], data['het'], 'ko-', markersize=5)
ax.fill_between(data['n'], 0, data['het'], alpha=0.15, color='orange')
ax.set_xlabel('Parameter n', fontsize=11)
ax.set_ylabel('Edge-size heterogeneity (σ²)', fontsize=11)
ax.set_title('Heterogeneity Growth', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.3)

# Bottom-right: Collision Index vs n
ax = axes[1, 1]
ax.plot(data['n'], data['ci'], 'cs-', markersize=5, label='CI')
ax.plot(data['n'], [1 - ci for ci in data['ci']], 'r^-', markersize=5,
        label='1 − CI (disorder)')
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.3)
ax.set_xlabel('Parameter n', fontsize=11)
ax.set_ylabel('Value', fontsize=11)
ax.set_title('Collision Index (Information-Theoretic Disorder)', fontsize=12,
             fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Disjoint-Triangles Family: Disorder Forces Integrality Gap',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('family_growth.png', dpi=150, bbox_inches='tight')
print("Saved: family_growth.png")
