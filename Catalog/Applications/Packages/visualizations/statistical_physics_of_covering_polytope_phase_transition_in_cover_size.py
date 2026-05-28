#!/usr/bin/env python3
"""
Visualization: Phase Transition in Covering Polytope Thermodynamics

Plots the mean cover size E_μ[|S|] as a function of β for several values
of the pair-codegree bound K, illustrating how bounded overlap controls
the sharpness of the transition from fractional-optimum-like to 
integral-minimum-like behavior.

Shows the predicted critical β_c ≈ log(d-1) + c/(K+1) for d=3 uniform
hypergraphs.
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
    return all(len(set(S) & edge) > 0 for edge in edges)


def exact_mean_size(n, edges, beta):
    Z = 0.0
    E_size = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            w = np.exp(-beta * len(S))
            Z += w
            E_size += len(S) * w
    return E_size / Z if Z > 0 else 0


def find_tau(n, edges):
    for k in range(n + 1):
        for combo in itertools.combinations(range(n), k):
            if is_transversal(edges, set(combo)):
                return k
    return n


# Parameters
n = 10
d = 3
K_values = [1, 2, 3, 5]
betas = np.linspace(0, 5, 100)
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Mean cover size vs β
ax = axes[0]
for K, color in zip(K_values, colors):
    edges = generate_hypergraph(n, d=d, target_edges=max(8, 2*n//K), K=K, seed=42+K)
    tau = find_tau(n, edges)
    
    mean_sizes = [exact_mean_size(n, edges, b) for b in betas]
    
    ax.plot(betas, mean_sizes, color=color, linewidth=2,
            label=f'K={K} (τ={tau}, |E|={len(edges)})')
    ax.axhline(y=tau, color=color, linewidth=0.8, linestyle=':', alpha=0.5)

# Predicted critical β
for K, color in zip(K_values, colors):
    beta_c = np.log(d - 1) + 1.0 / (K + 1)
    ax.axvline(x=beta_c, color=color, linewidth=0.8, linestyle='--', alpha=0.4)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Mean cover size $\mathbb{E}_{\mu}[|S|]$', fontsize=13)
ax.set_title(f'Phase Transition in Cover Size\n({d}-uniform, n={n})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Gibbs tail concentration
ax = axes[1]
K = 2
edges = generate_hypergraph(n, d=d, target_edges=10, K=K, seed=44)
tau = find_tau(n, edges)

for t_val, ls, lbl in [(1, '-', 'defect ≥ 1'), (2, '--', 'defect ≥ 2'), (3, ':', 'defect ≥ 3')]:
    tail_probs = []
    for b in betas:
        Z = 0.0
        Z_tail = 0.0
        for mask in range(1 << n):
            S = {i for i in range(n) if mask & (1 << i)}
            if is_transversal(edges, S):
                w = np.exp(-b * len(S))
                Z += w
                if len(S) - tau >= t_val:
                    Z_tail += w
        tail_probs.append(Z_tail / Z if Z > 0 else 0)
    
    ax.semilogy(betas, [max(p, 1e-10) for p in tail_probs], 
                linewidth=2, linestyle=ls, label=lbl)

# Theoretical bound curves
for t_val, ls in [(1, '-'), (2, '--'), (3, ':')]:
    bound = [min(1, 2**n * np.exp(-b * t_val) / max(np.exp(-b * tau), 1e-300))
             for b in betas]
    ax.semilogy(betas, [max(b, 1e-10) for b in bound],
                color='gray', linewidth=1, linestyle=ls, alpha=0.5)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Gibbs tail probability', fontsize=13)
ax.set_title(f'Gibbs Tail Concentration\n(K={K}, τ={tau})', fontsize=14)
ax.set_ylim(1e-6, 2)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_transition.png")
