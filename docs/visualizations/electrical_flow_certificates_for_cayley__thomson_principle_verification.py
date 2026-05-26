#!/usr/bin/env python3
"""
Visualization: Flow Energy vs Effective Resistance

Produces a scatter plot comparing path-flow energy (combinatorial)
against effective resistance (variational) for all vertex pairs in S_3 and S_4.

Thomson's principle guarantees every point lies above the diagonal:
  R_eff(s,t) ≤ E(path_flow(s,t))

The gap between the two measures quantifies how far canonical paths
are from optimal electrical flows.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# ─── Self-contained helpers ───
def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def adjacent_transpositions(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens

def build_cayley(n):
    elements = list(permutations(range(n)))
    idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)
    N = len(elements)
    adj = np.zeros((N, N))
    for g in elements:
        gi = idx[g]
        for s in gens:
            adj[gi][idx[compose(s, g)]] = 1
    return elements, idx, gens, adj

def eff_resistance(adj):
    L = np.diag(adj.sum(axis=1)) - adj
    Lp = np.linalg.pinv(L)
    d = np.diag(Lp)
    N = adj.shape[0]
    R = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            R[i][j] = d[i] + d[j] - 2*Lp[i][j]
    return R

def bubble_path_len(src, dst, n):
    diff = compose(dst, inverse(src))
    p = list(inverse(diff))
    count = 0
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                count += 1
    return count


# ─── Compute data ───
fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

for panel, n in enumerate([3, 4]):
    elements, idx, gens, adj = build_cayley(n)
    N = len(elements)
    R = eff_resistance(adj)

    resistances = []
    energies = []
    for src in elements:
        for dst in elements:
            if src == dst:
                continue
            r = R[idx[src]][idx[dst]]
            e = bubble_path_len(src, dst, n)  # energy = path length for simple path
            resistances.append(r)
            energies.append(e)

    ax = axes[panel]
    ax.scatter(resistances, energies, alpha=0.4, s=15, color='steelblue',
               label='(R_eff, path energy)')

    # Diagonal: Thomson bound
    max_val = max(max(resistances), max(energies)) + 0.5
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2,
            label='Thomson: E ≥ R_eff')

    ax.set_xlabel('Effective Resistance R_eff(s,t)', fontsize=12)
    ax.set_ylabel('Path Flow Energy E(φ)', fontsize=12)
    ax.set_title(f'Thomson\'s Principle — S_{n}\n'
                 f'All {N*(N-1)} pairs, |G|={N}',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(0, max_val)
    ax.set_ylim(0, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('thomson_principle.png', dpi=150, bbox_inches='tight')
print("Saved: thomson_principle.png")
