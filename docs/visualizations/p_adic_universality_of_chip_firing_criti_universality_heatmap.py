"""
Visualization: Universality Heatmap

Shows the p-primary critical group statistics across different base graphs
(columns) and different primes (rows). If the universality conjecture holds,
each row should show similar colors across columns (same Betti number → same
distribution).
"""

import numpy as np
import matplotlib.pyplot as plt
import random
from collections import Counter
from math import gcd

# Self-contained implementations
def graph_laplacian(adj):
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L.astype(int)

def smith_factors(M):
    A = M.copy().astype(int)
    m, n = A.shape
    r = min(m, n)
    for col in range(r):
        found = False
        for i in range(col, m):
            for j in range(col, n):
                if A[i, j] != 0:
                    A[[col, i]] = A[[i, col]]
                    A[:, [col, j]] = A[:, [j, col]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        if A[col, col] < 0:
            A[col] = -A[col]
        changed = True
        while changed:
            changed = False
            for i in range(col + 1, m):
                if A[i, col] != 0:
                    q = A[i, col] // A[col, col]
                    A[i] -= q * A[col]
                    if A[i, col] != 0:
                        A[[col, i]] = A[[i, col]]
                        changed = True
            for j in range(col + 1, n):
                if A[col, j] != 0:
                    q = A[col, j] // A[col, col]
                    A[:, j] -= q * A[:, col]
                    if A[col, j] != 0:
                        A[:, [col, j]] = A[:, [j, col]]
                        changed = True
    diag = [abs(A[i, i]) for i in range(r)]
    for i in range(len(diag) - 1):
        if diag[i] != 0 and diag[i + 1] != 0:
            g = gcd(diag[i], diag[i + 1])
            if g != diag[i]:
                diag[i], diag[i + 1] = g, (diag[i] * diag[i + 1]) // g
    return [d for d in diag if d > 1]

def critical_group(adj):
    L = graph_laplacian(adj)
    return smith_factors(L[:-1, :-1])

def random_graph_lift(adj, n_sheets):
    k = adj.shape[0]
    N = k * n_sheets
    lift_adj = np.zeros((N, N), dtype=int)
    for u in range(k):
        for v in range(u + 1, k):
            if adj[u, v] == 1:
                perm = list(range(n_sheets))
                random.shuffle(perm)
                for s in range(n_sheets):
                    i = u * n_sheets + s
                    j = v * n_sheets + perm[s]
                    lift_adj[i, j] = 1
                    lift_adj[j, i] = 1
    return lift_adj

random.seed(42)

# Base graphs with b1 = 2
graphs = {
    "K₄−e": np.array([[0,1,1,1],[1,0,1,0],[1,1,0,1],[1,0,1,0]]),
    "Theta": np.array([[0,1,1,1],[1,0,0,0],[1,0,0,1],[1,0,1,0]]),
    "Bowtie": np.array([[0,1,1,0,0],[1,0,1,0,0],[1,1,0,1,1],[0,0,1,0,1],[0,0,1,1,0]]),
}

primes = [2, 3, 5, 7]
n_sheets = 4
n_samples = 150

# Compute: fraction of lifts with trivial Sylow-p part
data = np.zeros((len(primes), len(graphs)))
graph_names = list(graphs.keys())

for j, (gname, adj) in enumerate(graphs.items()):
    for i, p in enumerate(primes):
        trivial_count = 0
        for _ in range(n_samples):
            lift = random_graph_lift(adj, n_sheets)
            jac = critical_group(lift)
            # Check if Sylow-p is trivial
            has_p = False
            for d in jac:
                if d % p == 0:
                    has_p = True
                    break
            if not has_p:
                trivial_count += 1
        data[i, j] = trivial_count / n_samples

fig, ax = plt.subplots(figsize=(8, 6))

im = ax.imshow(data, cmap='RdYlBu', aspect='auto', vmin=0, vmax=1)

ax.set_xticks(range(len(graph_names)))
ax.set_xticklabels(graph_names, fontsize=11)
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f"p = {p}" for p in primes], fontsize=11)

# Add text annotations
for i in range(len(primes)):
    for j in range(len(graph_names)):
        text = f"{data[i,j]:.2f}"
        color = "white" if data[i, j] < 0.3 or data[i, j] > 0.7 else "black"
        ax.text(j, i, text, ha="center", va="center", fontsize=12,
                fontweight='bold', color=color)

plt.colorbar(im, ax=ax, label="P(Sylow-p is trivial)", shrink=0.8)
ax.set_title(f"Universality Test: P(trivial Sylow-p)\n"
             f"All base graphs have b₁ = 2, {n_sheets}-sheeted lifts, {n_samples} samples",
             fontsize=13, fontweight='bold')
ax.set_xlabel("Base Graph", fontsize=12)
ax.set_ylabel("Prime p", fontsize=12)

plt.tight_layout()
plt.savefig("viz_universality_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_universality_heatmap.png")
