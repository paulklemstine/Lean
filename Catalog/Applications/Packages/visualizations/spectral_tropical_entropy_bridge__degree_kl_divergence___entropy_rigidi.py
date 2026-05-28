#!/usr/bin/env python3
"""
Visualization 3: KL Divergence Identity and Entropy Rigidity

Visualizes two key results:
1. D(G) = D_KL(p || uniform) — the regularity deficit IS a KL divergence
2. Regular graphs uniquely maximize entropy (rigidity theorem)

Shows how the degree distribution of regular vs irregular graphs
relates to the uniform distribution, and how entropy changes as
graphs are perturbed away from regularity.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees):
    return float(degrees.sum())


def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def regularity_deficit(degrees):
    n = len(degrees)
    return np.log(n) - shannon_entropy(degrees)


def kl_divergence_from_uniform(degrees):
    n = len(degrees)
    p = degree_distribution(degrees)
    u = 1.0 / n
    kl = 0.0
    for pv in p:
        if pv > 0:
            kl += pv * np.log(pv / u)
    return kl


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Plot 1: D(G) vs D_KL(p || u) ---
n_graphs = 300
deficits = []
kl_divs = []

for _ in range(n_graphs):
    n = random.choice([20, 30, 40, 50])
    p = random.uniform(0.05, 0.9)
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    degrees = degree_sequence(adj)
    if graph_volume(degrees) == 0:
        continue
    D = regularity_deficit(degrees)
    KL = kl_divergence_from_uniform(degrees)
    deficits.append(D)
    kl_divs.append(KL)

deficits = np.array(deficits)
kl_divs = np.array(kl_divs)

axes[0].scatter(kl_divs, deficits, c='steelblue', alpha=0.5, s=15)
axes[0].plot([0, deficits.max()], [0, deficits.max()], 'r-', linewidth=2, label='D = D_KL (identity)')
axes[0].set_xlabel('D_KL(p || uniform)', fontsize=12)
axes[0].set_ylabel('Regularity Deficit D(G)', fontsize=12)
axes[0].set_title('Verified: D(G) ≡ D_KL(p || u)', fontsize=13)
axes[0].legend(fontsize=11)
max_err = np.max(np.abs(deficits - kl_divs))
axes[0].text(0.05, 0.9, f'Max |D - D_KL| = {max_err:.2e}',
             transform=axes[0].transAxes, fontsize=10,
             bbox=dict(boxstyle='round', facecolor='lightyellow'))

# --- Plot 2: Entropy rigidity - perturbing from regular ---
n = 30
# Start with a 6-regular graph (cycle with 3 neighbors each side)
adj_base = np.zeros((n, n), dtype=int)
for i in range(n):
    for d in [1, 2, 3]:
        adj_base[i][(i + d) % n] = adj_base[(i + d) % n][i] = 1

perturbation_levels = np.linspace(0, 0.5, 30)
mean_entropies = []
mean_deficits = []

for pert in perturbation_levels:
    trial_H = []
    trial_D = []
    for _ in range(50):
        adj = adj_base.copy()
        # Randomly add/remove edges
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < pert:
                    adj[i][j] = 1 - adj[i][j]
                    adj[j][i] = adj[i][j]
        # Ensure simple graph
        np.fill_diagonal(adj, 0)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue
        trial_H.append(shannon_entropy(degrees))
        trial_D.append(regularity_deficit(degrees))
    if trial_H:
        mean_entropies.append(np.mean(trial_H))
        mean_deficits.append(np.mean(trial_D))
    else:
        mean_entropies.append(0)
        mean_deficits.append(0)

axes[1].plot(perturbation_levels, mean_entropies, 'b-', linewidth=2, label='H(G)')
axes[1].axhline(y=np.log(n), color='r', linewidth=1, linestyle='--', label='log|V| (max entropy)')
axes[1].set_xlabel('Perturbation Level', fontsize=12)
axes[1].set_ylabel('Degree Entropy H(G)', fontsize=12)
axes[1].set_title('Entropy Rigidity: Perturbing from Regular', fontsize=13)
axes[1].legend(fontsize=10)

# --- Plot 3: Degree distribution comparison ---
# Regular graph
degrees_reg = degree_sequence(adj_base)
p_reg = degree_distribution(degrees_reg)

# Highly irregular graph (star + some random)
adj_irreg = np.zeros((n, n), dtype=int)
for i in range(1, n):
    adj_irreg[0][i] = adj_irreg[i][0] = 1
for i in range(1, n):
    for j in range(i + 1, n):
        if random.random() < 0.1:
            adj_irreg[i][j] = adj_irreg[j][i] = 1
degrees_irreg = degree_sequence(adj_irreg)
p_irreg = degree_distribution(degrees_irreg)

uniform = np.ones(n) / n

x = np.arange(n)
width = 0.25
axes[2].bar(x - width, sorted(p_reg, reverse=True), width, color='steelblue', alpha=0.7, label='Regular graph')
axes[2].bar(x, sorted(p_irreg, reverse=True), width, color='coral', alpha=0.7, label='Irregular graph')
axes[2].bar(x + width, uniform, width, color='gray', alpha=0.4, label='Uniform 1/|V|')
axes[2].set_xlabel('Vertex (sorted by degree)', fontsize=12)
axes[2].set_ylabel('Probability p_v', fontsize=12)
axes[2].set_title('Degree Distribution vs Uniform', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].set_xlim(-1, n)

plt.tight_layout()
plt.savefig('kl_divergence_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved kl_divergence_rigidity.png")
