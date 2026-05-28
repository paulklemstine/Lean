"""
Visualization: Moment Convergence Curves

This script visualizes the convergence of prime-power moments E[M_{q,k}]
to Cohen–Lenstra predictions as graph size n → ∞, for multiple edge
probabilities p. This directly tests the CL-ER conjecture.

The x-axis is graph size n, the y-axis is the ratio E_empirical / E_CL.
Convergence to 1.0 supports the conjecture.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd


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

n_values = [6, 8, 10, 12, 15, 18, 22, 26, 30]
p_values = [0.3, 0.5, 0.7]
primes = [2, 3, 5]
num_samples = 150

# ratios[p_val][q][k] = list of ratios (one per n)
ratios = {p_val: {q: {k: [] for k in [1, 2, 3]}
          for q in primes} for p_val in p_values}

for p_val in p_values:
    rng = np.random.default_rng(42)
    for n in n_values:
        moment_sums = {q: {k: [] for k in [1, 2, 3]} for q in primes}
        collected = 0
        for _ in range(num_samples * 10):
            A = erdos_renyi(n, p_val, rng)
            if not is_connected(A): continue
            fac = jacobian_factors(A)
            if not fac: fac = [1]
            for q in primes:
                for k in [1, 2, 3]:
                    moment_sums[q][k].append(prime_power_moment(fac, q, k))
            collected += 1
            if collected >= num_samples: break

        for q in primes:
            for k in [1, 2, 3]:
                data = moment_sums[q][k]
                cl = cl_expected_moment(q, k)
                ratio = np.mean(data) / cl if data and cl > 0 else 0
                ratios[p_val][q][k].append(ratio)


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(3, 3, figsize=(16, 14))
fig.suptitle('Convergence of E[M_{q,k}] / E_{CL}[M_{q,k}] → 1\n'
             'Testing the Cohen–Lenstra Conjecture for Erdős–Rényi Graphs',
             fontsize=15, fontweight='bold', y=0.99)

p_colors = {'0.3': '#1976D2', '0.5': '#388E3C', '0.7': '#E64A19'}
p_markers = {'0.3': 'o', '0.5': 's', '0.7': '^'}

for row, q in enumerate(primes):
    for col, k in enumerate([1, 2, 3]):
        ax = axes[row, col]

        for p_val in p_values:
            data = ratios[p_val][q][k]
            pkey = str(p_val)
            ax.plot(n_values[:len(data)], data,
                    p_markers[pkey] + '-',
                    color=p_colors[pkey],
                    markersize=6, linewidth=1.5,
                    label=f'p = {p_val}', alpha=0.85)

        # Reference line at 1.0
        ax.axhline(1.0, color='red', linestyle='--', linewidth=2, alpha=0.5,
                   label='CL prediction')

        # Shaded region ±10%
        ax.axhspan(0.9, 1.1, alpha=0.08, color='green')

        ax.set_title(f'q = {q}, k = {k}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Graph size n', fontsize=10)
        ax.set_ylabel('Ratio E[M] / E_CL[M]', fontsize=10)
        ax.legend(fontsize=8, loc='best')
        ax.set_ylim(0.3, 2.5)
        ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_moment_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: viz_moment_convergence.png")
