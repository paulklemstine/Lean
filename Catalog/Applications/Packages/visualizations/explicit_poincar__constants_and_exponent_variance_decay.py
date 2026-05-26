#!/usr/bin/env python3
"""
Visualization 2: Variance Decay under Iterated Averaging

Shows how the variance of a function decays exponentially under
repeated application of the bubble-rotation averaging operator,
compared to pure adjacent-transposition walk.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def build_transition_matrix(n, gens):
    perms = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    k = len(gens)
    P = np.zeros((N, N))
    for i, s in enumerate(perms):
        for g in gens:
            t = tuple(g[s[j]] for j in range(n))
            P[i, idx[t]] += 1.0 / k
    return P


def adj_only_generators(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens


def bubble_rotation_generators(n):
    gens = set()
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.add(tuple(p))
    rho = tuple((i + 1) % n for i in range(n))
    rho_inv = tuple((i - 1) % n for i in range(n))
    gens.add(rho)
    gens.add(rho_inv)
    return list(gens)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx_n, n in enumerate([4, 5]):
    ax = axes[idx_n]
    N = factorial(n)

    # Build transition matrices
    P_br = build_transition_matrix(n, bubble_rotation_generators(n))
    P_adj = build_transition_matrix(n, adj_only_generators(n))

    # Initial mean-zero function
    np.random.seed(42)
    f0 = np.random.randn(N)
    f0 -= f0.mean()
    initial_var = np.var(f0)

    # Track variance decay
    T = 60
    vars_br = []
    vars_adj = []

    f_br = f0.copy()
    f_adj = f0.copy()

    for t in range(T):
        vars_br.append(np.var(f_br))
        vars_adj.append(np.var(f_adj))
        f_br = P_br @ f_br
        f_adj = P_adj @ f_adj

    # Normalize by initial variance
    vars_br = np.array(vars_br) / initial_var
    vars_adj = np.array(vars_adj) / initial_var

    ts = np.arange(T)
    ax.semilogy(ts, vars_br, 'b-', linewidth=2.5, label='Bubble-rotation walk')
    ax.semilogy(ts, vars_adj, 'r--', linewidth=2.5, label='Adjacent swaps only')

    # Theoretical bounds
    eigs_br = np.sort(np.abs(np.linalg.eigvals(P_br)))[::-1]
    eigs_adj = np.sort(np.abs(np.linalg.eigvals(P_adj)))[::-1]

    ax.semilogy(ts, eigs_br[1] ** (2 * ts), 'b:', alpha=0.5, linewidth=1.5,
                label=f'Theory: (1-γ_br)^{{2t}}, γ={1-eigs_br[1]:.4f}')
    ax.semilogy(ts, eigs_adj[1] ** (2 * ts), 'r:', alpha=0.5, linewidth=1.5,
                label=f'Theory: (1-γ_adj)^{{2t}}, γ={1-eigs_adj[1]:.4f}')

    ax.set_xlabel('Iteration t', fontsize=13)
    ax.set_ylabel('Var(A^t f) / Var(f)', fontsize=13)
    ax.set_title(f'Variance Decay on S_{n} (n={n})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-12, 2)

plt.tight_layout()
plt.savefig('variance_decay.png', dpi=150, bbox_inches='tight')
print("Saved variance_decay.png")
