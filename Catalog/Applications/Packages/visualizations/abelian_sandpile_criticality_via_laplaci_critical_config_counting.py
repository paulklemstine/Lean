#!/usr/bin/env python3
"""
Visualization: Critical Configuration Counting vs Determinant

For a range of graph families (paths, cycles, complete graphs),
plots the number of critical configurations against the determinant
of the reduced Laplacian, demonstrating perfect agreement (Kirchhoff's theorem).
Also shows the spectral gap (Fiedler value) for each graph.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n


def count_critical_configs(adj, q):
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)
    ranges = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(max(1, degrees[v]))))
    count = 0
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, adj, q):
            count += 1
    return count


def reduced_laplacian_det(adj, q):
    L = np.diag(adj.sum(axis=1)) - adj
    idx = [i for i in range(adj.shape[0]) if i != q]
    Lq = L[np.ix_(idx, idx)]
    return int(round(abs(np.linalg.det(Lq))))


def fiedler_value(adj):
    L = np.diag(adj.sum(axis=1)) - adj
    evals = np.sort(np.linalg.eigvalsh(L.astype(float)))
    return evals[1] if len(evals) > 1 else 0


# ============================================================
# Generate graph families
# ============================================================

data = []
q = 0

# Paths
for n in range(2, 7):
    edges = [(i, i+1) for i in range(n-1)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Path', n, nc, det, fv))

# Cycles
for n in range(3, 8):
    edges = [(i, (i+1) % n) for i in range(n)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Cycle', n, nc, det, fv))

# Complete graphs
for n in range(3, 7):
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Complete', n, nc, det, fv))

# ============================================================
# Plot
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Critical configs vs det for each family
ax1 = axes[0]
families = {}
for family, n, nc, det, fv in data:
    if family not in families:
        families[family] = {'n': [], 'nc': [], 'det': []}
    families[family]['n'].append(n)
    families[family]['nc'].append(nc)
    families[family]['det'].append(det)

colors = {'Path': '#2196F3', 'Cycle': '#4CAF50', 'Complete': '#F44336'}
markers = {'Path': 'o', 'Cycle': 's', 'Complete': '^'}

for family, vals in families.items():
    ax1.scatter(vals['det'], vals['nc'], c=colors[family], marker=markers[family],
                s=100, label=family, zorder=5, edgecolors='white')

# Perfect agreement line
max_val = max(max(v['det']) for v in families.values()) * 1.1
ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x')
ax1.set_xlabel('det(L_q)', fontsize=12)
ax1.set_ylabel('#Critical Configurations', fontsize=12)
ax1.set_title('Kirchhoff\'s Theorem Verified\n#Critical = det(Reduced Laplacian)', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Plot 2: Jacobian order vs n for each family
ax2 = axes[1]
for family, vals in families.items():
    ax2.semilogy(vals['n'], vals['nc'], f'-{markers[family]}', color=colors[family],
                 linewidth=2, markersize=8, label=family)

ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel('Jacobian Order (log scale)', fontsize=12)
ax2.set_title('Growth of Jacobian Group\nby Graph Family', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Fiedler value vs n
ax3 = axes[2]
fiedler_data = {}
for family, n, nc, det, fv in data:
    if family not in fiedler_data:
        fiedler_data[family] = {'n': [], 'fv': []}
    fiedler_data[family]['n'].append(n)
    fiedler_data[family]['fv'].append(fv)

for family, vals in fiedler_data.items():
    ax3.plot(vals['n'], vals['fv'], f'-{markers[family]}', color=colors[family],
             linewidth=2, markersize=8, label=family)

ax3.set_xlabel('Number of vertices n', fontsize=12)
ax3.set_ylabel('Fiedler Value λ₂', fontsize=12)
ax3.set_title('Algebraic Connectivity\n(Spectral Gap)', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_critical_configs.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_critical_configs.png")
