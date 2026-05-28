#!/usr/bin/env python3
"""
Visualization: Free Energy Landscape of Covering Polytopes

Plots the free energy f_H(β) and its sandwich bounds for a small hypergraph,
demonstrating Theorems 1 and 2: monotonicity and variational bounds.

The plot shows:
- The exact free energy curve (monotone nondecreasing)
- Lower bound: (βτ - |V|log2)/|V|
- Upper bound: βτ/|V|
- The transition from high-temperature (counting) to low-temperature (optimization)
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from collections import defaultdict


def generate_hypergraph(n, d=3, target_edges=None, K=2, seed=42):
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    edges = []
    pair_count = defaultdict(int)
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    return edges


def is_transversal(edges, S):
    S_set = set(S)
    return all(len(S_set & edge) > 0 for edge in edges)


def exact_partition_function(n, edges, beta):
    Z = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            Z += np.exp(-beta * len(S))
    return Z


def find_tau(n, edges):
    for k in range(n + 1):
        for combo in itertools.combinations(range(n), k):
            if is_transversal(edges, set(combo)):
                return k
    return n


# Generate hypergraph
n = 12
K = 2
edges = generate_hypergraph(n, d=3, target_edges=12, K=K, seed=42)
tau = find_tau(n, edges)

# Compute free energy
betas = np.linspace(0.01, 6, 200)
free_energies = []
for b in betas:
    Z = exact_partition_function(n, edges, b)
    f = -np.log(max(Z, 1e-300)) / n
    free_energies.append(f)

free_energies = np.array(free_energies)

# Bounds
lower_bound = (betas * tau - n * np.log(2)) / n
upper_bound = betas * tau / n

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Free energy with bounds
ax = axes[0]
ax.fill_between(betas, lower_bound, upper_bound, alpha=0.15, color='blue',
                label='Variational sandwich')
ax.plot(betas, free_energies, 'b-', linewidth=2.5, label=r'$f_H(\beta)$ (exact)')
ax.plot(betas, lower_bound, 'b--', linewidth=1, alpha=0.6,
        label=r'Lower: $(\beta\tau - |V|\ln 2)/|V|$')
ax.plot(betas, upper_bound, 'b:', linewidth=1, alpha=0.6,
        label=r'Upper: $\beta\tau/|V|$')
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='-')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Free energy $f_H(\beta)$', fontsize=13)
ax.set_title(f'Free Energy Landscape\n(n={n}, |E|={len(edges)}, '
             r'$\tau$=' + f'{tau}, K={K})', fontsize=14)
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

# Right: Partition function (log scale)
ax = axes[1]
Z_values = [exact_partition_function(n, edges, b) for b in betas]
Z_lower = [np.exp(-b * tau) for b in betas]
Z_upper = [2**n * np.exp(-b * tau) for b in betas]

ax.semilogy(betas, Z_values, 'r-', linewidth=2.5, label=r'$Z_H(\beta)$')
ax.semilogy(betas, Z_lower, 'r--', linewidth=1, alpha=0.6,
            label=r'$e^{-\beta\tau}$')
ax.semilogy(betas, Z_upper, 'r:', linewidth=1, alpha=0.6,
            label=r'$2^{|V|} e^{-\beta\tau}$')
ax.fill_between(betas, Z_lower, Z_upper, alpha=0.1, color='red')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Partition function $Z_H(\beta)$', fontsize=13)
ax.set_title('Partition Function Bounds\n(Theorem 2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('free_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved free_energy_landscape.png")
