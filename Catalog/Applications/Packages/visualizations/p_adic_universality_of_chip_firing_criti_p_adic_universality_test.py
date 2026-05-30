#!/usr/bin/env python3
"""
Visualization: p-adic Universality Test
Shows the distribution of p-adic valuations of critical groups across
random lifts of different base graphs with the same Betti number.
If universality holds, the histograms should converge.
"""

import numpy as np
import matplotlib.pyplot as plt
import random
from collections import Counter

# ============================================================
# Self-contained utility functions
# ============================================================

def graph_laplacian(adj):
    D = np.diag(adj.sum(axis=1).astype(int))
    return D - adj

def reduced_laplacian(L, sink=0):
    return np.delete(np.delete(L, sink, axis=0), sink, axis=1)

def smith_factors(M):
    M = M.copy().astype(int)
    rows, cols = M.shape
    n = min(rows, cols)
    for i in range(n):
        found = False
        for r in range(i, rows):
            for c in range(i, cols):
                if M[r, c] != 0:
                    M[[i, r]] = M[[r, i]]
                    M[:, [i, c]] = M[:, [c, i]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        for _ in range(500):
            changed = False
            for r in range(i + 1, rows):
                if M[r, i] != 0:
                    q = M[r, i] // M[i, i]
                    M[r] -= q * M[i]
                    if M[r, i] != 0 and abs(M[r, i]) < abs(M[i, i]):
                        M[[i, r]] = M[[r, i]]
                        changed = True
            for c in range(i + 1, cols):
                if M[i, c] != 0:
                    q = M[i, c] // M[i, i]
                    M[:, c] -= q * M[:, i]
                    if M[i, c] != 0 and abs(M[i, c]) < abs(M[i, i]):
                        M[:, [i, c]] = M[:, [c, i]]
                        changed = True
            if not changed:
                break
    return [abs(M[i, i]) for i in range(n) if abs(M[i, i]) > 1]

def critical_group(adj, sink=0):
    L = graph_laplacian(adj)
    Lr = reduced_laplacian(L, sink)
    return smith_factors(Lr)

def random_lift(adj, n_sheets):
    nv = adj.shape[0]
    N = nv * n_sheets
    lift = np.zeros((N, N), dtype=int)
    for v in range(nv):
        for w in range(v + 1, nv):
            if adj[v, w]:
                perm = list(range(n_sheets))
                random.shuffle(perm)
                for i in range(n_sheets):
                    vi = v * n_sheets + i
                    wj = w * n_sheets + perm[i]
                    lift[vi, wj] = lift[wj, vi] = 1
    return lift

def padic_val(n, p):
    if n == 0:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def p_primary_val(factors, p):
    return sum(padic_val(f, p) for f in factors)

# ============================================================
# Build test graphs
# ============================================================

def make_cycle(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i+1) % n] = adj[(i+1) % n, i] = 1
    return adj

def make_theta():
    adj = np.zeros((4, 4), dtype=int)
    for u, v in [(0,1), (0,2), (2,1), (0,3), (3,1)]:
        adj[u, v] = adj[v, u] = 1
    return adj

def make_diamond():
    adj = np.zeros((4, 4), dtype=int)
    for u, v in [(0,1), (0,2), (0,3), (1,2), (2,3)]:
        adj[u, v] = adj[v, u] = 1
    return adj

# ============================================================
# Generate data and plot
# ============================================================

random.seed(42)
np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: b₁ = 1, p = 5 ---
p = 5
n_sheets = 4
n_trials = 200

graphs_b1 = [("C₃ (triangle)", make_cycle(3)),
             ("C₄ (square)", make_cycle(4)),
             ("C₅ (pentagon)", make_cycle(5))]

ax = axes[0]
all_vals = set()

for name, adj in graphs_b1:
    vals = []
    for _ in range(n_trials):
        lift = random_lift(adj, n_sheets)
        cg = critical_group(lift)
        vals.append(p_primary_val(cg, p))
    all_vals.update(vals)
    counts = Counter(vals)
    total = sum(counts.values())
    x = sorted(counts.keys())
    y = [counts[v] / total for v in x]
    ax.bar([xi + 0.2 * graphs_b1.index((name, adj)) - 0.2 for xi in x], y,
           width=0.18, label=name, alpha=0.8)

ax.set_xlabel(f'v₅(|Jac(G̃)|)', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title(f'p-Primary Valuation Distribution\nb₁ = 1, p = {p}, {n_sheets}-sheeted lifts', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(sorted(all_vals))

# --- Panel 2: b₁ = 2, p = 3 ---
p2 = 3
n_sheets2 = 3

graphs_b2 = [("Theta graph", make_theta()),
             ("Diamond graph", make_diamond())]

ax2 = axes[1]
all_vals2 = set()
colors = ['#2196F3', '#FF5722']

for idx, (name, adj) in enumerate(graphs_b2):
    vals = []
    for _ in range(n_trials):
        lift = random_lift(adj, n_sheets2)
        cg = critical_group(lift)
        vals.append(p_primary_val(cg, p2))
    all_vals2.update(vals)
    counts = Counter(vals)
    total = sum(counts.values())
    x = sorted(counts.keys())
    y = [counts[v] / total for v in x]
    ax2.bar([xi + 0.25 * idx - 0.125 for xi in x], y,
            width=0.22, label=name, alpha=0.8, color=colors[idx])

ax2.set_xlabel(f'v₃(|Jac(G̃)|)', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title(f'p-Primary Valuation Distribution\nb₁ = 2, p = {p2}, {n_sheets2}-sheeted lifts', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_xticks(sorted(all_vals2))

plt.suptitle('Testing the p-adic Universality Conjecture for Chip-Firing Critical Groups',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
