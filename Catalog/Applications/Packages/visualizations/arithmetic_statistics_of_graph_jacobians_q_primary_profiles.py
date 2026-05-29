"""
Visualization: q-Primary Profiles of Random Graph Jacobians

Creates a heatmap showing the distribution of q-primary profiles
λ_{q,j} = #{i : q^j | d_i} for random Erdős-Rényi graph Jacobians.
This visualizes the partition structure that connects to Cohen-Lenstra
theory — the antitone (non-increasing) property is visible as the
staircase pattern in the heatmap.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce

# ── Inline algorithms ──

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nz = np.argwhere(sub != 0)
            if len(nz) == 0: break
            mv, mp = float('inf'), None
            for pos in nz:
                v = abs(sub[pos[0], pos[1]])
                if v < mv: mv, mp = v, (pos[0]+k, pos[1]+k)
            if mp[0] != k: A[[k, mp[0]]] = A[[mp[0], k]]
            if mp[1] != k: A[:, [k, mp[1]]] = A[:, [mp[1], k]]
            if A[k,k] < 0: A[k,:] = -A[k,:]
            if A[k,k] == 0: break
            for i in range(k+1, rows):
                if A[i,k] != 0:
                    q = A[i,k]//A[k,k]; A[i,:] -= q*A[k,:]
                    if A[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k,j] != 0:
                    q = A[k,j]//A[k,k]; A[:,j] -= q*A[:,k]
                    if A[k,j] != 0: changed = True
    diag = [abs(A[i,i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    A = np.zeros((n,n), dtype=int)
    for i,j in edges: A[i,j] = A[j,i] = 1
    L = np.diag(A.sum(axis=1)) - A
    idx = list(range(1, n))
    Lr = L[np.ix_(idx, idx)]
    return sorted([d for d in smith_normal_form(Lr) if d > 1])

def random_connected_graph(n, p):
    while True:
        edges = [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]
        adj = {i: set() for i in range(n)}
        for i,j in edges: adj[i].add(j); adj[j].add(i)
        visited, queue = {0}, [0]
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited: visited.add(u); queue.append(u)
        if len(visited) == n: return edges

# ── Sampling ──
np.random.seed(123)
n = 15
p_edge = 0.5
num_samples = 200
max_level = 8

primes = [2, 3, 5]
profile_data = {q: np.zeros((num_samples, max_level)) for q in primes}

for s in range(num_samples):
    edges = random_connected_graph(n, p_edge)
    factors = graph_jacobian_factors(n, edges)
    if not factors:
        factors = [1]
    for q in primes:
        for j in range(max_level):
            count = sum(1 for d in factors if d % (q**j) == 0)
            profile_data[q][s, j] = count

# ── Plotting ──
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, q in enumerate(primes):
    ax = axes[idx]
    data = profile_data[q]

    # Compute mean and std per level
    means = data.mean(axis=0)
    stds = data.std(axis=0)

    levels = np.arange(max_level)
    ax.bar(levels, means, yerr=stds, capsize=4,
           color=plt.cm.viridis(np.linspace(0.3, 0.9, max_level)),
           edgecolor='black', linewidth=0.5, alpha=0.8)

    ax.set_xlabel('Level j', fontsize=12)
    ax.set_ylabel(f'Mean λ_{{{q},j}}', fontsize=12)
    ax.set_title(f'q = {q}: q-Primary Profile', fontsize=14, fontweight='bold')
    ax.set_xticks(levels)
    ax.grid(True, alpha=0.3, axis='y')

    # Annotate with antitone property
    ax.annotate('Antitone\n(non-increasing)',
                xy=(max_level//2, means[max_level//2]),
                fontsize=9, ha='center', style='italic', color='gray')

fig.suptitle(f'q-Primary Profiles of Random Graph Jacobians\n'
             f'G({n}, {p_edge}), {num_samples} samples — '
             f'λ_{{q,j}} = #{{i : q^j | d_i}}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_profiles.png', dpi=150, bbox_inches='tight')
print("Saved viz_profiles.png")
