#!/usr/bin/env python3
"""
Visualization: Cohomology Dimensions across Network Topologies
==============================================================
Creates a heatmap showing how H⁰ and H¹ dimensions vary as we change
the number of edges in a random graph. Illustrates the phase transition
from disconnected (high H⁰) to connected (H⁰ = 1) networks.
"""

import numpy as np
import matplotlib.pyplot as plt

def compute_cohomology(n, edges):
    """Compute H⁰ and H¹ for constant sheaf on graph with n vertices."""
    m = len(edges)
    if m == 0:
        return n, 0
    delta = np.zeros((m, n), dtype=float)
    for idx, (u, v) in enumerate(edges):
        delta[idx, u] = -1
        delta[idx, v] = +1
    _, S, _ = np.linalg.svd(delta, full_matrices=False)
    rank = np.sum(S > 1e-10)
    return n - rank, m - rank

# Parameters
n = 30
p_values = np.linspace(0.01, 0.3, 30)
num_trials = 50

h0_avg = np.zeros(len(p_values))
h1_avg = np.zeros(len(p_values))
h0_std = np.zeros(len(p_values))
h1_std = np.zeros(len(p_values))

np.random.seed(42)

for i, p in enumerate(p_values):
    h0_samples = []
    h1_samples = []
    for _ in range(num_trials):
        edges = [(a, b) for a in range(n) for b in range(a+1, n) 
                 if np.random.random() < p]
        h0, h1 = compute_cohomology(n, edges)
        h0_samples.append(h0)
        h1_samples.append(h1)
    h0_avg[i] = np.mean(h0_samples)
    h1_avg[i] = np.mean(h1_samples)
    h0_std[i] = np.std(h0_samples)
    h1_std[i] = np.std(h1_samples)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

threshold = np.log(n) / n

# H⁰ plot
ax1 = axes[0]
ax1.fill_between(p_values, h0_avg - h0_std, h0_avg + h0_std, alpha=0.3, color='#2196F3')
ax1.plot(p_values, h0_avg, 'o-', color='#1565C0', linewidth=2, markersize=4, label='dim H⁰ (interpretations)')
ax1.axvline(x=threshold, color='red', linestyle='--', alpha=0.7, label=f'Threshold p* = ln({n})/{n} ≈ {threshold:.3f}')
ax1.set_xlabel('Edge probability p', fontsize=12)
ax1.set_ylabel('dim H⁰', fontsize=12)
ax1.set_title('Interpretation Diversity vs Edge Density', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(bottom=0)

# H¹ plot
ax2 = axes[1]
ax2.fill_between(p_values, h1_avg - h1_std, h1_avg + h1_std, alpha=0.3, color='#FF9800')
ax2.plot(p_values, h1_avg, 's-', color='#E65100', linewidth=2, markersize=4, label='dim H¹ (barriers)')
ax2.axvline(x=threshold, color='red', linestyle='--', alpha=0.7, label=f'Threshold p* ≈ {threshold:.3f}')
ax2.set_xlabel('Edge probability p', fontsize=12)
ax2.set_ylabel('dim H¹', fontsize=12)
ax2.set_title('Transmission Barriers vs Edge Density', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(bottom=0)

fig.suptitle('Sheaf Cohomology of Random Graphs G(30, p)', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('cohomology_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved cohomology_heatmap.png")
