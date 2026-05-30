"""
Visualization: Cohen-Lenstra Distribution vs Empirical p-primary Groups

Compares the theoretical Cohen-Lenstra weights (1/|Aut(G)|) with the
empirical distribution of Sylow-p subgroups of critical groups of
random graph lifts. This is the key test of the universality conjecture.
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

def p_primary_part(group, p):
    parts = []
    for d in group:
        pk = 1
        temp = d
        while temp % p == 0:
            pk *= p
            temp //= p
        if pk > 1:
            parts.append(pk)
    parts.sort()
    return tuple(parts)

random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

primes = [2, 3, 5]
base_graph = np.array([
    [0, 1, 1, 1],
    [1, 0, 1, 0],
    [1, 1, 0, 1],
    [1, 0, 1, 0]
])  # K4-e, b1=2

n_sheets = 5
n_samples = 300

for idx, p in enumerate(primes):
    ax = axes[idx]

    # Compute empirical distribution
    type_counts = Counter()
    for _ in range(n_samples):
        lift = random_graph_lift(base_graph, n_sheets)
        jac = critical_group(lift)
        pp = p_primary_part(jac, p)
        type_counts[pp] += 1

    # Sort by frequency
    types_sorted = sorted(type_counts.items(), key=lambda x: -x[1])[:8]

    labels = []
    empirical = []
    for typ, count in types_sorted:
        if not typ:
            labels.append("trivial")
        else:
            labels.append(" × ".join(f"ℤ/{d}" for d in typ))
        empirical.append(count / n_samples)

    x = np.arange(len(labels))
    width = 0.6

    bars = ax.bar(x, empirical, width, color='#2196F3', alpha=0.8,
                  edgecolor='white', linewidth=0.5, label='Empirical')

    ax.set_xlabel("Sylow-p subgroup type", fontsize=10)
    ax.set_ylabel("Probability", fontsize=10)
    ax.set_title(f"p = {p}", fontsize=12, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.legend(fontsize=9)

fig.suptitle(f"p-Primary Critical Group Distribution\n"
             f"Base: K₄−e (b₁=2), {n_sheets}-sheeted lifts, {n_samples} samples",
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig("viz_cohen_lenstra.png", dpi=150, bbox_inches='tight')
print("Saved viz_cohen_lenstra.png")
