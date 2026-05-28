"""
Visualization 1: Leaf Witness Landscape on the Exchange Graph

Visualizes the base exchange graph of a matroid (U(2,5)) with nodes
colored by their leaf witness values. Edges connect bases that differ
by a single exchange. The color gradient shows how leaf witness values
vary across the exchange graph, illustrating the tropical exchange
property: adjacent bases always have values bounded below by their
minimum.

Uses matplotlib to produce a static graph layout.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from itertools import combinations
from typing import FrozenSet, Dict, Set, Tuple

# Self-contained matroid and leaf witness computation
Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]

def uniform_matroid_bases(n: int, r: int) -> Set[Basis]:
    return {frozenset(c) for c in combinations(range(n), r)}

def basis_generating_polynomial(bases: Set[Basis], n: int) -> Polynomial:
    poly: Polynomial = {}
    for basis in bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly

def partial_derivative(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            key = tuple(new_exp)
            result[key] = result.get(key, 0.0) + coeff * exp[var]
    return result

def leaf_witness(p: Polynomial, S: FrozenSet[int]) -> float:
    current = p
    for i in sorted(S):
        current = partial_derivative(current, i)
    return sum(current.values())

# Build U(2, 5) exchange graph
n, r = 5, 2
bases = uniform_matroid_bases(n, r)
p = basis_generating_polynomial(bases, n)
lw = {b: leaf_witness(p, b) for b in bases}

# Build exchange graph edges
edges = []
bases_list = sorted(bases)
for i, b1 in enumerate(bases_list):
    for b2 in bases_list[i+1:]:
        if len(b1.symmetric_difference(b2)) == 2:
            edges.append((i, bases_list.index(b1), bases_list.index(b2)))

# Layout: arrange bases in a circle
num_bases = len(bases_list)
angles = np.linspace(0, 2 * np.pi, num_bases, endpoint=False)
x = np.cos(angles)
y = np.sin(angles)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# --- Left panel: Exchange graph colored by leaf witness ---
values = np.array([lw[b] for b in bases_list])
norm = plt.Normalize(vmin=values.min(), vmax=values.max())
cmap = cm.viridis

# Draw edges
for _, i, j in edges:
    ax1.plot([x[i], x[j]], [y[i], y[j]], 'k-', alpha=0.3, linewidth=0.8)

# Draw nodes
scatter = ax1.scatter(x, y, c=values, cmap=cmap, s=400, zorder=5,
                       edgecolors='black', linewidth=1.5)

# Label nodes
for i, b in enumerate(bases_list):
    label = '{' + ','.join(str(e) for e in sorted(b)) + '}'
    ax1.annotate(label, (x[i], y[i]), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax1.set_title('Leaf Witness Values on Exchange Graph\nU(2, 5)', fontsize=14)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.axis('off')
plt.colorbar(scatter, ax=ax1, label='Leaf Witness Value', shrink=0.8)

# --- Right panel: Exchange pair analysis ---
# For each edge, compute whether exchange achieves equality or strict inequality
equality_edges = []
strict_edges = []
for _, i, j in edges:
    b1, b2 = bases_list[i], bases_list[j]
    min_val = min(lw[b1], lw[b2])
    # Check exchange from b1 to b2
    for a in b1 - b2:
        for b in b2 - b1:
            b_new = (b1 - {a}) | {b}
            if b_new in bases and abs(lw[b_new] - min_val) < 1e-10:
                equality_edges.append((i, j))
            elif b_new in bases and lw[b_new] > min_val + 1e-10:
                strict_edges.append((i, j))

# Draw edges colored by type
for i, j in set(equality_edges):
    ax2.plot([x[i], x[j]], [y[i], y[j]], 'b-', alpha=0.6, linewidth=2,
             label='Equality' if (i,j) == equality_edges[0] else '')
for i, j in set(strict_edges):
    ax2.plot([x[i], x[j]], [y[i], y[j]], 'r-', alpha=0.6, linewidth=2,
             label='Strict' if (i,j) == strict_edges[0] else '')

ax2.scatter(x, y, c=values, cmap=cmap, s=400, zorder=5,
            edgecolors='black', linewidth=1.5)

for i, b in enumerate(bases_list):
    label = '{' + ','.join(str(e) for e in sorted(b)) + '}'
    ax2.annotate(label, (x[i], y[i]), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax2.set_title('Exchange Inequality Analysis\nBlue=Equality, Red=Strict', fontsize=14)
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.axis('off')

plt.tight_layout()
plt.savefig('exchange_graph.png', dpi=150, bbox_inches='tight')
print("Saved exchange_graph.png")
