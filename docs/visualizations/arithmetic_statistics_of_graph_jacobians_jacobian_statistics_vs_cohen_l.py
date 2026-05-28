"""
Visualization: Graph Jacobian Arithmetic Statistics vs Cohen–Lenstra Predictions

This script generates a comprehensive visualization showing:
1. Top row: Histograms of prime-power moments M_{q,1} for q=2,3,5
   across different graph sizes, compared to Cohen–Lenstra expected values.
2. Bottom row: Convergence of empirical E[M_{q,k}] to CL predictions
   as graph size n increases.

The plots demonstrate the CL-ER conjecture: random graph Jacobians
asymptotically obey Cohen–Lenstra statistics.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce


# ============================================================
# Inlined core algorithms
# ============================================================

def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L, v=0):
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    M = M.copy().astype(int)
    n, m = M.shape
    r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i, j] != 0:
                    M[[col, i]] = M[[i, col]]
                    M[:, [col, j]] = M[:, [j, col]]
                    pf = True; break
            if pf: break
        if not pf: break
        ch = True
        while ch:
            ch = False
            if M[col, col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i, col] != 0:
                    q = M[i, col] // M[col, col]
                    M[i] -= q * M[col]
                    if M[i, col] != 0:
                        if abs(M[i, col]) < abs(M[col, col]):
                            M[[col, i]] = M[[i, col]]
                        ch = True
            for j in range(col+1, m):
                if M[col, j] != 0:
                    q = M[col, j] // M[col, col]
                    M[:, j] -= q * M[:, col]
                    if M[col, j] != 0:
                        if abs(M[col, j]) < abs(M[col, col]):
                            M[:, [col, j]] = M[:, [j, col]]
                        ch = True
            for i in range(col+1, n):
                brk = False
                for j in range(col+1, m):
                    if M[i, j] % M[col, col] != 0:
                        M[i] += M[col]; ch = True; brk = True; break
                if brk: break
    return [abs(int(M[i, i])) for i in range(r) if M[i, i] != 0]

def jacobian_factors(adj):
    L = graph_laplacian(adj)
    Ls = reduced_laplacian(L)
    fac = smith_normal_form(Ls)
    return sorted([f for f in fac if f > 1])

def erdos_renyi(n, p, rng):
    upper = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]
    vis = {0}; queue = [0]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis:
                vis.add(u); queue.append(u)
    return len(vis) == n

def prime_power_moment(factors, q, k):
    qk = q**k; r = 1
    for d in factors: r *= gcd(d, qk)
    return r

def cl_expected_moment(q, k):
    r = 1.0
    for j in range(1, k+1): r *= q**j / (q**j - 1)
    return r


# ============================================================
# Data collection
# ============================================================

rng = np.random.default_rng(42)
primes = [2, 3, 5]
n_values_hist = [10, 20, 30]
n_values_conv = [8, 10, 12, 15, 18, 22, 26, 30]
num_samples = 200

# Collect histogram data
hist_data = {q: {n: [] for n in n_values_hist} for q in primes}
for n in n_values_hist:
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n, 0.5, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]
        for q in primes:
            hist_data[q][n].append(prime_power_moment(fac, q, 1))
        collected += 1
        if collected >= num_samples: break

# Collect convergence data
conv_data = {q: {k: [] for k in [1, 2]} for q in primes}
for n in n_values_conv:
    moments_n = {q: {k: [] for k in [1, 2]} for q in primes}
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n, 0.5, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]
        for q in primes:
            for k in [1, 2]:
                moments_n[q][k].append(prime_power_moment(fac, q, k))
        collected += 1
        if collected >= num_samples: break

    for q in primes:
        for k in [1, 2]:
            data = moments_n[q][k]
            conv_data[q][k].append(np.mean(data) if data else 0)


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(16, 11))
fig.suptitle('Graph Jacobian Statistics vs Cohen–Lenstra Predictions\n'
             'Random Erdős–Rényi Graphs G(n, 1/2)',
             fontsize=15, fontweight='bold', y=0.98)

colors = ['#2196F3', '#4CAF50', '#FF9800']
cl_color = '#E91E63'

for col, q in enumerate(primes):
    # Top: Histograms
    ax = axes[0, col]
    for idx, n in enumerate(n_values_hist):
        data = hist_data[q][n]
        if data:
            max_val = int(np.percentile(data, 95)) + 2
            bins = np.arange(0.5, max_val + 1.5, 1)
            ax.hist(data, bins=bins, alpha=0.5, density=True,
                    color=colors[idx], label=f'n={n}', edgecolor='white')

    cl_val = cl_expected_moment(q, 1)
    ax.axvline(cl_val, color=cl_color, linestyle='--', linewidth=2.5,
               label=f'CL E[M]={cl_val:.2f}')
    ax.set_title(f'Prime q = {q}: Distribution of M_{{q,1}}', fontsize=12)
    ax.set_xlabel(f'M_{{{q},1}}  (= ∏ gcd(dᵢ, {q}))', fontsize=10)
    ax.set_ylabel('Density', fontsize=10)
    ax.legend(fontsize=9, framealpha=0.9)
    ax.set_xlim(left=0)

    # Bottom: Convergence
    ax2 = axes[1, col]
    markers = ['o', 's']
    line_colors = ['#1565C0', '#C62828']
    for kidx, k in enumerate([1, 2]):
        means = conv_data[q][k]
        cl_k = cl_expected_moment(q, k)
        ax2.plot(n_values_conv, means, markers[kidx] + '-',
                 color=line_colors[kidx], markersize=6, linewidth=1.5,
                 label=f'k={k}: empirical', alpha=0.9)
        ax2.axhline(cl_k, color=line_colors[kidx], linestyle='--',
                    linewidth=1.5, alpha=0.6,
                    label=f'k={k}: CL = {cl_k:.3f}')

    ax2.set_title(f'q = {q}: Convergence of E[M_{{q,k}}]', fontsize=12)
    ax2.set_xlabel('Graph size n', fontsize=10)
    ax2.set_ylabel(f'E[M_{{{q},k}}]', fontsize=10)
    ax2.legend(fontsize=9, framealpha=0.9)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_jacobian_statistics.png', dpi=150, bbox_inches='tight')
print("Saved: viz_jacobian_statistics.png")
