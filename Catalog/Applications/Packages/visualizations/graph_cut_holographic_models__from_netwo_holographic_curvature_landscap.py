#!/usr/bin/env python3
"""
Visualization: Holographic Curvature Landscape

Shows the curvature tensor K(X,Y,Z) across a parameter space, revealing
the higher-order geometric structure of the holographic model.

Also plots the curvature-distance duality conjecture test:
|K(X,Y,Z)| vs (defect(X,Y) · defect(Y,Z) · defect(X,Z))^(2/3)

Key insight: the curvature tensor captures tripartite entanglement
that pairwise defects miss — analogous to topological entanglement
entropy in condensed matter physics.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
import random

# Ground set and submodular function
n = 5
elements = list(range(n))

# Submodular function: weighted rank function
weights = {0: 1.0, 1: 1.5, 2: 0.8, 3: 2.0, 4: 1.2}

def weighted_rank(S, cap=3):
    if not S:
        return 0.0
    return min(sum(weights.get(x, 0) for x in S), cap)

# Generate all nonempty subsets
subsets = []
for k in range(1, n + 1):
    for combo in combinations(elements, k):
        subsets.append(frozenset(combo))

def defect(f, X, Y):
    return f(X) + f(Y) - f(X & Y) - f(X | Y)

def curvature_tensor(f, X, Y, Z):
    return (defect(f, X, Y) + defect(f, Y, Z) + defect(f, X, Z)
            - defect(f, X, Y | Z) - defect(f, Y, X | Z) - defect(f, Z, X | Y))

# Compute curvature tensor values and duality test
random.seed(42)
K_values = []
product_values = []
duality_holds = []

for _ in range(2000):
    X = random.choice(subsets)
    Y = random.choice(subsets)
    Z = random.choice(subsets)

    K = curvature_tensor(weighted_rank, X, Y, Z)
    dXY = defect(weighted_rank, X, Y)
    dYZ = defect(weighted_rank, Y, Z)
    dXZ = defect(weighted_rank, X, Z)

    prod = dXY * dYZ * dXZ
    if prod > 1e-10:
        bound = prod ** (2/3)
        K_values.append(abs(K))
        product_values.append(bound)
        duality_holds.append(abs(K) <= bound + 1e-10)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Curvature tensor distribution
ax1 = axes[0]
K_all = []
for i in range(min(500, len(subsets))):
    for j in range(min(500, len(subsets))):
        if i != j:
            X = subsets[i % len(subsets)]
            Y = subsets[j % len(subsets)]
            Z = subsets[(i + j) % len(subsets)]
            K = curvature_tensor(weighted_rank, X, Y, Z)
            K_all.append(K)

ax1.hist(K_all, bins=50, color='steelblue', edgecolor='black', linewidth=0.3, alpha=0.8)
ax1.axvline(x=0, color='red', linewidth=1.5, linestyle='--', label='K = 0')
ax1.set_xlabel('Curvature tensor K(X,Y,Z)', fontsize=11)
ax1.set_ylabel('Frequency', fontsize=11)
ax1.set_title('Curvature Tensor Distribution', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.2)

# Add statistics
mean_K = np.mean(K_all)
ax1.text(0.95, 0.95, f'Mean: {mean_K:.4f}\nStd: {np.std(K_all):.4f}\n'
         f'Min: {min(K_all):.4f}\nMax: {max(K_all):.4f}',
         transform=ax1.transAxes, fontsize=8, va='top', ha='right',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

# Plot 2: Curvature-Distance Duality scatter
ax2 = axes[1]
K_arr = np.array(K_values)
P_arr = np.array(product_values)

colors_scatter = ['green' if h else 'red' for h in duality_holds]
ax2.scatter(P_arr, K_arr, c=colors_scatter, alpha=0.4, s=8, edgecolors='none')

# Diagonal line (bound)
max_val = max(max(P_arr), max(K_arr)) * 1.1
ax2.plot([0, max_val], [0, max_val], 'k--', linewidth=1, label='|K| = bound')
ax2.set_xlabel('(d(X,Y)·d(Y,Z)·d(X,Z))^{2/3}', fontsize=10)
ax2.set_ylabel('|K(X,Y,Z)|', fontsize=10)
ax2.set_title('Curvature-Distance Duality\nConjecture Test', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.2)

violations = sum(1 for h in duality_holds if not h)
total = len(duality_holds)
ax2.text(0.05, 0.95,
         f'Tests: {total}\nViolations: {violations}\n'
         f'Rate: {violations/total:.1%}',
         transform=ax2.transAxes, fontsize=9, va='top',
         bbox=dict(boxstyle='round', facecolor='lightgreen' if violations == 0 else 'lightyellow',
                   alpha=0.7))

# Plot 3: Defect spectrum across subsets
ax3 = axes[2]

# Compute all pairwise defects for singletons
singleton_defects = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        Xi = frozenset({elements[i]})
        Yj = frozenset({elements[j]})
        singleton_defects[i, j] = defect(weighted_rank, Xi, Yj)

im = ax3.imshow(singleton_defects, cmap='inferno', aspect='equal')
ax3.set_xticks(range(n))
ax3.set_xticklabels([f'{{{e}}}' for e in elements], fontsize=9)
ax3.set_yticks(range(n))
ax3.set_yticklabels([f'{{{e}}}' for e in elements], fontsize=9)
ax3.set_title('Pairwise Defect Matrix\n(Singleton Regions)', fontsize=13, fontweight='bold')
ax3.set_xlabel('Region Y', fontsize=10)
ax3.set_ylabel('Region X', fontsize=10)
plt.colorbar(im, ax=ax3, label='Defect', shrink=0.8)

# Annotate values
for i in range(n):
    for j in range(n):
        ax3.text(j, i, f'{singleton_defects[i,j]:.2f}',
                ha='center', va='center', fontsize=8,
                color='white' if singleton_defects[i,j] > 0.3 else 'black')

plt.tight_layout()
plt.savefig('curvature_landscape.png', dpi=150, bbox_inches='tight')
print("Saved curvature_landscape.png")
