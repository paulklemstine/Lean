"""
Visualization: Prime-Power Moments vs Cohen-Lenstra Predictions

Plots the empirical mean of M_{q,k}(Jac(G)) for random Erdős-Rényi
graphs G(n, 1/2) against the Cohen-Lenstra predicted values, showing
convergence as n increases. This visualizes the core connection between
random graph Jacobians and arithmetic statistics.
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

def cl_moment(q, k):
    total = 0.0
    for m in range(50):
        total += (1 - 1.0/q) * (1.0/q)**m * q**min(m, k)
    return total

# ── Sampling ──
np.random.seed(42)
ns = [8, 12, 16, 20, 25]
p_edge = 0.5
num_samples = 150
primes = [2, 3, 5]
ks = [1, 2]

results = {q: {k: [] for k in ks} for q in primes}

for n in ns:
    for q in primes:
        for k in ks:
            moments = []
            for _ in range(num_samples):
                edges = random_connected_graph(n, p_edge)
                factors = graph_jacobian_factors(n, edges)
                if not factors: factors = [1]
                m = reduce(lambda a,b: a*b, [gcd(d, q**k) for d in factors], 1)
                moments.append(m)
            results[q][k].append(np.mean(moments))

# ── Plotting ──
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#FF5722']

for idx, q in enumerate(primes):
    ax = axes[idx]
    for ki, k in enumerate(ks):
        cl_pred = cl_moment(q, k)
        ax.plot(ns, results[q][k], 'o-', color=colors[ki],
                label=f'Empirical E[M_{{{q},{k}}}]', markersize=8)
        ax.axhline(y=cl_pred, color=colors[ki], linestyle='--', alpha=0.7,
                   label=f'CL prediction = {cl_pred:.3f}')
    ax.set_xlabel('n (graph size)', fontsize=12)
    ax.set_ylabel('Mean torsion count', fontsize=12)
    ax.set_title(f'q = {q}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

fig.suptitle('Prime-Power Moments of Random Graph Jacobians vs Cohen-Lenstra Predictions\n'
             f'G(n, {p_edge}), {num_samples} samples per point',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moments.png', dpi=150, bbox_inches='tight')
print("Saved viz_moments.png")
