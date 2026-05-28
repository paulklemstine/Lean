"""
Visualization: Invariant Factor Profile Heatmap

This script generates a heatmap showing the distribution of q-primary
invariant factor profiles across random graph ensembles. Each cell shows
the frequency of a particular (q-rank, max q-valuation) pair,
revealing the internal structure of random graph Jacobians.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from collections import Counter


# Inlined algorithms
def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L, v=0):
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    M = M.copy().astype(int)
    n, m = M.shape; r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i,j] != 0:
                    M[[col,i]] = M[[i,col]]; M[:,[col,j]] = M[:,[j,col]]
                    pf = True; break
            if pf: break
        if not pf: break
        ch = True
        while ch:
            ch = False
            if M[col,col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i,col] != 0:
                    q = M[i,col]//M[col,col]; M[i] -= q*M[col]
                    if M[i,col] != 0:
                        if abs(M[i,col]) < abs(M[col,col]): M[[col,i]] = M[[i,col]]
                        ch = True
            for j in range(col+1, m):
                if M[col,j] != 0:
                    q = M[col,j]//M[col,col]; M[:,j] -= q*M[:,col]
                    if M[col,j] != 0:
                        if abs(M[col,j]) < abs(M[col,col]): M[:,[col,j]] = M[:,[j,col]]
                        ch = True
            for i in range(col+1, n):
                brk = False
                for j in range(col+1, m):
                    if M[i,j] % M[col,col] != 0:
                        M[i] += M[col]; ch = True; brk = True; break
                if brk: break
    return [abs(int(M[i,i])) for i in range(r) if M[i,i] != 0]

def jacobian_factors(adj):
    L = graph_laplacian(adj); Ls = reduced_laplacian(L)
    return sorted([f for f in smith_normal_form(Ls) if f > 1])

def erdos_renyi(n, p, rng):
    upper = np.zeros((n,n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]; vis = {0}; queue = [0]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis: vis.add(u); queue.append(u)
    return len(vis) == n

def padic_val(n, p):
    if n == 0: return 0
    v = 0
    while n % p == 0: v += 1; n //= p
    return v


# ============================================================
# Data collection
# ============================================================

rng = np.random.default_rng(42)
n_graph = 20
p_edge = 0.5
num_samples = 300

# For each prime, collect (q-rank, max_valuation) pairs
prime_data = {}
for q in [2, 3, 5]:
    pairs = []
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n_graph, p_edge, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]

        # q-rank = number of factors divisible by q
        q_rank = sum(1 for d in fac if d % q == 0)
        # max q-valuation
        max_val = max(padic_val(d, q) for d in fac) if fac else 0
        pairs.append((q_rank, max_val))

        collected += 1
        if collected >= num_samples: break
    prime_data[q] = pairs


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle(f'q-Primary Profile Distribution of Graph Jacobians\n'
             f'G({n_graph}, {p_edge}), {num_samples} samples per prime',
             fontsize=14, fontweight='bold')

for col, q in enumerate([2, 3, 5]):
    ax = axes[col]
    pairs = prime_data[q]

    if not pairs:
        ax.set_title(f'q = {q}: No data')
        continue

    # Create heatmap
    max_rank = max(r for r, v in pairs) + 1
    max_val = max(v for r, v in pairs) + 1

    heatmap = np.zeros((max_val, max_rank))
    for r, v in pairs:
        heatmap[v, r] += 1
    heatmap /= len(pairs)

    im = ax.imshow(heatmap, cmap='YlOrRd', aspect='auto', origin='lower',
                   interpolation='nearest')

    ax.set_xlabel(f'{q}-rank (# factors divisible by {q})', fontsize=11)
    ax.set_ylabel(f'Max {q}-adic valuation', fontsize=11)
    ax.set_title(f'Prime q = {q}', fontsize=13, fontweight='bold')

    # Add text annotations
    for i in range(min(max_val, 8)):
        for j in range(min(max_rank, 12)):
            if i < heatmap.shape[0] and j < heatmap.shape[1]:
                val = heatmap[i, j]
                if val > 0.005:
                    color = 'white' if val > 0.15 else 'black'
                    ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                            fontsize=8, color=color, fontweight='bold')

    fig.colorbar(im, ax=ax, label='Frequency', shrink=0.8)

plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig('viz_invariant_factor_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_invariant_factor_heatmap.png")
