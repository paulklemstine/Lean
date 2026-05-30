"""
Visualization: p-adic Universality of Chip-Firing Critical Groups

Produces a figure showing:
1. (Top) p-rank distributions for random lifts of different base graphs with same b₁
2. (Bottom) Cohen-Lenstra predicted probabilities vs observed

This visualizes the central universality phenomenon: graphs with the same
Betti number produce the same limiting distribution of p-primary critical groups.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
import random


# === Self-contained helper functions ===

def _laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)

def _snf_invariants(M):
    M = M.astype(int).tolist()
    n, m = len(M), len(M[0]) if M else 0
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i][j] != 0:
                    M[k], M[i] = M[i], M[k]
                    for row in M:
                        row[k], row[j] = row[j], row[k]
                    found = True
                    break
            if found:
                break
        if not found:
            continue
        changed = True
        while changed:
            changed = False
            if M[k][k] < 0:
                for j in range(m): M[k][j] = -M[k][j]
            for i in range(k+1, n):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j in range(m): M[i][j] -= q * M[k][j]
                    if M[i][k] != 0:
                        M[k], M[i] = M[i], M[k]
                        changed = True
            for j in range(k+1, m):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i in range(n): M[i][j] -= q * M[i][k]
                    if M[k][j] != 0:
                        for i in range(n): M[i][k], M[i][j] = M[i][j], M[i][k]
                        changed = True
    return [abs(M[i][i]) for i in range(min(n, m)) if abs(M[i][i]) > 1]

def _critical_group(adj):
    L = _laplacian(adj)
    return _snf_invariants(L[:-1, :-1])

def _random_lift(adj, n):
    nv = adj.shape[0]
    total = nv * n
    lift = np.zeros((total, total), dtype=int)
    for u in range(nv):
        for v in range(u+1, nv):
            if adj[u][v] > 0:
                perm = list(range(n))
                random.shuffle(perm)
                for i in range(n):
                    lift[u*n+i][v*n+perm[i]] = 1
                    lift[v*n+perm[i]][u*n+i] = 1
    return lift

def _sylow_p(inv_factors, p):
    parts = []
    for d in inv_factors:
        pk = 1
        t = d
        while t % p == 0:
            pk *= p
            t //= p
        if pk > 1:
            parts.append(pk)
    return parts

def _make_cycle(n):
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i][(i+1) % n] = 1
        A[(i+1) % n][i] = 1
    return A


# === Build test graphs with b₁ = 2 ===

# Graph 1: C₄ with diagonal (K₄ minus one edge)
G1 = _make_cycle(4)
G1[0][2] = 1; G1[2][0] = 1

# Graph 2: C₅ (cycle on 5 vertices, b₁ = 1) -- wait, need b₁=2
# Actually C₄+diagonal has 5 edges, 4 vertices -> b₁ = 5-4+1 = 2. Good.
# Graph 2: Two triangles sharing an edge
G2 = np.zeros((4, 4), dtype=int)
G2[0][1] = G2[1][0] = 1
G2[1][2] = G2[2][1] = 1
G2[0][2] = G2[2][0] = 1
G2[0][3] = G2[3][0] = 1
G2[1][3] = G2[3][1] = 1
# edges: 01,12,02,03,13 = 5 edges, 4 vertices -> b₁ = 2. Good.

# Graph 3: Path of length 2 with two extra edges
G3 = np.zeros((3, 3), dtype=int)
G3[0][1] = G3[1][0] = 1
G3[1][2] = G3[2][1] = 1
G3[0][2] = G3[2][0] = 1
# This is K₃ with b₁ = 3-3+1 = 1. Need more edges.
# Use 5 vertices with 6 edges -> b₁ = 2
G3 = np.zeros((5, 5), dtype=int)
for i, j in [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2)]:
    G3[i][j] = G3[j][i] = 1

b1_values = []
for G in [G1, G2, G3]:
    edges = int(G.sum()) // 2
    n = G.shape[0]
    b1_values.append(edges - n + 1)

# === Run experiments ===
random.seed(42)
p = 3
n_sheets = 5
num_samples = 300

graph_names = ["K₄\\{e} (4v, 5e)", "Double triangle (4v, 5e)", "Pentagon+chord (5v, 6e)"]
colors = ['#2196F3', '#FF5722', '#4CAF50']

all_distributions = []
max_rank = 0

for G in [G1, G2, G3]:
    ranks = []
    for _ in range(num_samples):
        lift = _random_lift(G, n_sheets)
        inv = _critical_group(lift)
        pr = len(_sylow_p(inv, p))
        ranks.append(pr)
        max_rank = max(max_rank, pr)
    all_distributions.append(ranks)

# === Create figure ===
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Overlaid histograms
ax1 = axes[0]
rank_range = range(0, max_rank + 2)

for idx, (ranks, name, color) in enumerate(zip(all_distributions, graph_names, colors)):
    dist = Counter(ranks)
    total = len(ranks)
    probs = [dist.get(k, 0) / total for k in rank_range]
    offset = (idx - 1) * 0.25
    ax1.bar([k + offset for k in rank_range], probs, width=0.22, alpha=0.85,
            label=f"{name}\nb₁={b1_values[idx]}", color=color, edgecolor='white')

ax1.set_xlabel(f'{p}-rank of Sylow-{p} subgroup', fontsize=12)
ax1.set_ylabel('Probability', fontsize=12)
ax1.set_title(f'Distribution of {p}-primary rank\n({n_sheets}-sheeted lifts, {num_samples} samples each)',
              fontsize=13)
ax1.legend(fontsize=9, loc='upper right')
ax1.set_xticks(list(rank_range))

# Panel 2: Cohen-Lenstra prediction vs observed
ax2 = axes[1]
b1 = 2

# Cohen-Lenstra prediction: P(rank=0) = ∏(1 - p^{-i}) for i=1..b₁
cl_trivial = 1.0
for i in range(1, b1 + 1):
    cl_trivial *= (1 - p**(-i))

# Observed
obs_trivial = []
for ranks in all_distributions:
    obs_trivial.append(sum(1 for r in ranks if r == 0) / len(ranks))

x_pos = [0, 1, 2]
ax2.bar(x_pos, obs_trivial, width=0.4, alpha=0.85, color=colors,
        edgecolor='white', label='Observed P(rank=0)')
ax2.axhline(y=cl_trivial, color='red', linestyle='--', linewidth=2,
            label=f'Cohen-Lenstra prediction: {cl_trivial:.4f}')

ax2.set_xticks(x_pos)
ax2.set_xticklabels([f'G{i+1}' for i in range(3)], fontsize=11)
ax2.set_ylabel('P(trivial Sylow-p)', fontsize=12)
ax2.set_title(f'Universality: P(rank=0) vs Cohen-Lenstra\n(p={p}, b₁={b1})',
              fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('universality_visualization.png', dpi=150, bbox_inches='tight')
print("Saved universality_visualization.png")
