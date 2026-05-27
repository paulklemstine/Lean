#!/usr/bin/env python3
"""
Visualization: Tropical Spectral Gap Scaling Under Weight Perturbation

Shows how the tropical spectral gap and minimum exchange defect scale
together as we continuously perturb the weight function. This
demonstrates the Lipschitz stability theorem: small weight perturbations
cause bounded changes in the spectral gap.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


def compute_gap_and_defect(bases, w_fn, n_elements):
    bases_set = set(bases)

    # Hessian-based spectral gap
    H = {}
    elements = list(range(n_elements))
    for i in elements:
        for j in elements:
            if i == j:
                vals = [w_fn(B) for B in bases if i in B]
                H[(i, j)] = max(vals) if vals else -1e18
            else:
                vals = [w_fn(B) for B in bases if i in B and j in B]
                H[(i, j)] = max(vals) if vals else -1e18

    min_slack = float('inf')
    for i in elements:
        for j in range(i+1, n_elements):
            slack = 2 * H[(i, j)] - H[(i, i)] - H[(j, j)]
            min_slack = min(min_slack, slack)

    # Exchange defect
    min_defect = float('inf')
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        d = w_fn(B1) + w_fn(B2) - w_fn(B1n) - w_fn(B2n)
                        min_defect = min(min_defect, d)

    return min_slack, min_defect if min_defect != float('inf') else 0


# Setup: K₄
edges = list(combinations(range(4), 2))
bases = graphical_matroid_bases(4, edges)

# Base weights and perturbation direction
rng = random.Random(42)
w_base = {B: rng.randint(-5, 5) for B in bases}
w_pert = {B: rng.randint(-3, 3) for B in bases}

# Sweep parameter t from -2 to 2
t_values = np.linspace(-2, 2, 50)
gaps = []
defects = []

for t in t_values:
    w_fn = lambda B, t=t: w_base.get(B, 0) + t * w_pert.get(B, 0)
    g, d = compute_gap_and_defect(bases, w_fn, len(edges))
    gaps.append(g)
    defects.append(d)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

ax1.plot(t_values, gaps, 'b-', linewidth=2, label='Tropical Spectral Gap')
ax1.plot(t_values, defects, 'r--', linewidth=2, label='Min Exchange Defect')
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Tropical Spectral Gap vs Min Exchange Defect\nunder Weight Perturbation (K₄)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Difference
diff = [g - d for g, d in zip(gaps, defects)]
ax2.plot(t_values, diff, 'g-', linewidth=2)
ax2.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax2.set_xlabel('Perturbation parameter t', fontsize=12)
ax2.set_ylabel('Gap − Defect', fontsize=12)
ax2.set_title('Difference: Spectral Gap − Exchange Defect', fontsize=13)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_scaling.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_scaling.png")
