#!/usr/bin/env python3
"""
Visualization 1: Entropy Landscape

Visualizes the degree entropy H(G) vs the certified lower bound log(|V|d̄/Δ)
across random graphs of varying density. Shows that the bound always holds
and is tight for near-regular graphs.

Key insight: The entropy floor rises as graphs become denser (more regular),
demonstrating that spectral regularity forces information-theoretic regularity.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


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


def entropy_lower_bound(degrees):
    n = len(degrees)
    d_bar = float(degrees.mean())
    delta = int(degrees.max())
    if delta == 0:
        return float('-inf')
    return np.log(n * d_bar / delta)


def spectral_radius(adj):
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


# Generate data
n = 40
p_values = np.linspace(0.05, 0.95, 50)
n_samples = 30

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Entropy vs Lower Bound scatter
all_H = []
all_LB = []
all_p = []

for p_val in p_values:
    for _ in range(n_samples):
        adj = generate_erdos_renyi(n, p_val)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue
        H = shannon_entropy(degrees)
        lb = entropy_lower_bound(degrees)
        all_H.append(H)
        all_LB.append(lb)
        all_p.append(p_val)

all_H = np.array(all_H)
all_LB = np.array(all_LB)
all_p = np.array(all_p)

sc = axes[0].scatter(all_LB, all_H, c=all_p, cmap='viridis', alpha=0.4, s=8)
axes[0].plot([0, np.log(n)], [0, np.log(n)], 'r--', linewidth=2, label='H = bound (equality)')
axes[0].set_xlabel('Lower Bound: log(|V|·d̄/Δ)', fontsize=12)
axes[0].set_ylabel('Degree Entropy H(G)', fontsize=12)
axes[0].set_title('Entropy vs Certified Lower Bound', fontsize=13)
axes[0].legend(fontsize=10)
plt.colorbar(sc, ax=axes[0], label='Edge probability p')

# Plot 2: Entropy margin by density
p_bins = np.linspace(0.05, 0.95, 20)
mean_margins = []
min_margins = []
for i in range(len(p_bins) - 1):
    mask = (all_p >= p_bins[i]) & (all_p < p_bins[i + 1])
    if mask.any():
        margins = all_H[mask] - all_LB[mask]
        mean_margins.append(margins.mean())
        min_margins.append(margins.min())
    else:
        mean_margins.append(0)
        min_margins.append(0)

bin_centers = (p_bins[:-1] + p_bins[1:]) / 2
axes[1].fill_between(bin_centers, 0, mean_margins, alpha=0.3, color='blue', label='Mean margin')
axes[1].plot(bin_centers, mean_margins, 'b-', linewidth=2)
axes[1].plot(bin_centers, min_margins, 'r-', linewidth=2, label='Min margin')
axes[1].axhline(y=0, color='k', linewidth=0.5, linestyle='--')
axes[1].set_xlabel('Edge Probability p', fontsize=12)
axes[1].set_ylabel('H(G) − log(|V|·d̄/Δ)', fontsize=12)
axes[1].set_title('Bound Margin vs Graph Density', fontsize=13)
axes[1].legend(fontsize=10)

# Plot 3: Regularity deficit
all_D = np.log(n) - all_H
all_UB = []
for H_val, p_val in zip(all_H, all_p):
    adj = generate_erdos_renyi(n, p_val)
    degrees = degree_sequence(adj)
    d_bar = float(degrees.mean())
    delta = int(degrees.max())
    if d_bar > 0 and delta > 0:
        all_UB.append(np.log(delta / d_bar))
    else:
        all_UB.append(0)
all_UB = np.array(all_UB)

axes[2].scatter(all_p, all_D, c='steelblue', alpha=0.3, s=8, label='D(G)')
axes[2].set_xlabel('Edge Probability p', fontsize=12)
axes[2].set_ylabel('Regularity Deficit D(G)', fontsize=12)
axes[2].set_title('Deficit Decreases with Density', fontsize=13)
axes[2].legend(fontsize=10)

plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")
