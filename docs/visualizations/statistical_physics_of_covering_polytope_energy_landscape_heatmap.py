#!/usr/bin/env python3
"""
Visualization: Energy Landscape of Transversal Sizes

Creates a heatmap showing the distribution of Gibbs mass across transversal
sizes at different temperatures, illustrating the transition from the
high-temperature counting regime to the low-temperature optimization regime.

This directly visualizes the content of the free energy sandwich theorem:
the Gibbs measure interpolates between uniform over all transversals (β=0)
and concentrated on minimum transversals (β→∞).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
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


def size_distribution(n, edges, beta):
    """Compute the distribution of |S| under the Gibbs measure."""
    Z = 0.0
    counts = defaultdict(float)
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            w = np.exp(-beta * len(S))
            Z += w
            counts[len(S)] += w
    if Z > 0:
        for k in counts:
            counts[k] /= Z
    return dict(counts)


# Generate hypergraph
n = 11
K = 2
edges = generate_hypergraph(n, d=3, target_edges=10, K=K, seed=42)

# Find tau
tau = n
for k in range(n + 1):
    for combo in itertools.combinations(range(n), k):
        if is_transversal(edges, set(combo)):
            tau = k
            break
    if tau == k:
        break

# Compute distributions at various β
betas = np.linspace(0, 5, 80)
max_size = n
min_size = tau

# Build heatmap data
heatmap = np.zeros((max_size - min_size + 1, len(betas)))
for j, b in enumerate(betas):
    dist = size_distribution(n, edges, b)
    for size, prob in dist.items():
        if min_size <= size <= max_size:
            heatmap[size - min_size, j] = prob

# Mean cover size
mean_sizes = []
for b in betas:
    dist = size_distribution(n, edges, b)
    mean = sum(k * v for k, v in dist.items())
    mean_sizes.append(mean)

fig, axes = plt.subplots(2, 1, figsize=(12, 10), height_ratios=[3, 1])

# Top: Heatmap
ax = axes[0]
im = ax.imshow(heatmap, aspect='auto', origin='lower',
               extent=[betas[0], betas[-1], min_size - 0.5, max_size + 0.5],
               cmap='YlOrRd', norm=mcolors.PowerNorm(gamma=0.5))
ax.plot(betas, mean_sizes, 'cyan', linewidth=2.5, label=r'$\mathbb{E}_\mu[|S|]$')
ax.axhline(y=tau, color='white', linewidth=1.5, linestyle='--', alpha=0.8,
           label=f'τ(H) = {tau}')
cbar = plt.colorbar(im, ax=ax, label='Gibbs probability')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Transversal size $|S|$', fontsize=13)
ax.set_title(f'Gibbs Mass Distribution over Transversal Sizes\n'
             f'(n={n}, |E|={len(edges)}, d=3, K={K}, τ={tau})', fontsize=14)
ax.legend(fontsize=11, loc='upper right')

# Bottom: Entropy-like measure (number of sizes with >1% mass)
ax = axes[1]
entropies = []
for j, b in enumerate(betas):
    col = heatmap[:, j]
    # Shannon entropy
    H = -sum(p * np.log(p + 1e-20) for p in col if p > 0)
    entropies.append(H)

ax.plot(betas, entropies, 'g-', linewidth=2)
ax.fill_between(betas, 0, entropies, alpha=0.2, color='green')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel('Shannon entropy\nof size distribution', fontsize=11)
ax.set_title('Entropy of Transversal Size Distribution', fontsize=13)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved energy_landscape.png")
