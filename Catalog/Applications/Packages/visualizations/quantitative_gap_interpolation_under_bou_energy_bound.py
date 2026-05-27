"""
Visualization: Pair-Overlap Energy Bound E(x) ≤ K · (Σx)²

Shows that the quadratic energy bound is always satisfied, and visualizes
how the energy-to-bound ratio varies with K and instance parameters.
This demonstrates the analytic backbone theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog


def generate_hypergraph(n, d, m, max_codegree=None):
    edges = []
    codeg = np.zeros((n, n), dtype=int)
    attempts = 0
    while len(edges) < m and attempts < m * 100:
        attempts += 1
        verts = set(np.random.choice(n, d, replace=False).tolist())
        if any(verts == set(e) for e in edges):
            continue
        if max_codegree is not None:
            vl = list(verts)
            ok = all(codeg[vl[i], vl[j]] < max_codegree
                     for i in range(len(vl)) for j in range(i+1, len(vl)))
            if not ok:
                continue
        edges.append(verts)
        vl = list(verts)
        for i in range(len(vl)):
            for j in range(i+1, len(vl)):
                codeg[vl[i], vl[j]] += 1
                codeg[vl[j], vl[i]] += 1
    return edges


def solve_lp(n, edges):
    if not edges:
        return np.zeros(n)
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    return result.x if result.success else None


def compute_energy(n, edges, x):
    codeg = np.zeros((n, n), dtype=int)
    for e in edges:
        vl = list(e)
        for i in range(len(vl)):
            for j in range(i+1, len(vl)):
                codeg[vl[i], vl[j]] += 1
                codeg[vl[j], vl[i]] += 1
    energy = 0.0
    for u in range(n):
        for v in range(u+1, n):
            energy += 2 * codeg[u, v] * x[u] * x[v]
    return energy


np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Energy vs bound for different K
ax1 = axes[0]
K_values = [1, 2, 5, 10]
colors = ['#1976D2', '#388E3C', '#F57C00', '#D32F2F']

for K, color in zip(K_values, colors):
    energies = []
    bounds = []
    for _ in range(30):
        edges = generate_hypergraph(50, 3, 80, max_codegree=K)
        if len(edges) < 5:
            continue
        x = solve_lp(50, edges)
        if x is None or np.sum(x) < 0.1:
            continue
        E = compute_energy(50, edges, x)
        B = K * np.sum(x)**2
        energies.append(E)
        bounds.append(B)
    
    ax1.scatter(bounds, energies, color=color, alpha=0.6, s=40, label=f'K={K}')

# Diagonal line (equality)
max_val = max(max(bounds) if bounds else 0 for K, color in zip(K_values, colors))
ax1.plot([0, max_val*1.1], [0, max_val*1.1], 'k--', linewidth=1, alpha=0.5,
         label='E = K·(Σx)²')

ax1.set_xlabel('Bound K · (Σx)²', fontsize=13)
ax1.set_ylabel('Actual Energy E(x)', fontsize=13)
ax1.set_title('Energy vs Quadratic Bound', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right panel: Energy ratio distribution
ax2 = axes[1]

for K, color in zip(K_values, colors):
    ratios = []
    for _ in range(50):
        edges = generate_hypergraph(50, 3, 80, max_codegree=K)
        if len(edges) < 5:
            continue
        x = solve_lp(50, edges)
        if x is None or np.sum(x) < 0.1:
            continue
        E = compute_energy(50, edges, x)
        B = K * np.sum(x)**2
        if B > 0:
            ratios.append(E / B)
    
    if ratios:
        ax2.hist(ratios, bins=15, alpha=0.5, color=color, label=f'K={K}',
                 density=True, edgecolor='white')

ax2.axvline(x=1.0, color='k', linestyle='--', linewidth=2, alpha=0.7,
            label='Bound (ratio=1)')
ax2.set_xlabel('Ratio E(x) / [K · (Σx)²]', fontsize=13)
ax2.set_ylabel('Density', fontsize=13)
ax2.set_title('Distribution of Energy Ratio', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.05, 1.2)

plt.suptitle('Pair-Overlap Energy Bound: E(x) ≤ K · (Σx)²', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('energy_bound.png', dpi=150, bbox_inches='tight')
print("Saved energy_bound.png")
