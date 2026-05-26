#!/usr/bin/env python3
"""
Visualization: Concentration of Subgroup Pressure

Shows the self-averaging phenomenon: as the symmetric group degree n
grows, the distribution of random subgroup pressure concentrates
around its mean. The top row shows histograms narrowing; the bottom
row shows variance decay following O(1/n^4) for point stabilizers.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def inverse_index_kernel_matrix(indices):
    """Build weight matrix W[i,j] = 1 / (idx_i^2 * idx_j^2)."""
    inv = 1.0 / (np.array(indices, dtype=float) ** 2)
    return np.outer(inv, inv)


def sample_pressures(W, p=0.5, num_samples=20000, seed=42):
    """Sample random pressures under Bernoulli(p) inclusion."""
    rng = np.random.RandomState(seed)
    n = W.shape[0]
    pressures = np.zeros(num_samples)
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pressures[i] = chi @ W @ chi
    return pressures


# ─── Build data ──────────────────────────────────────────────────────
ns = [5, 7, 9, 11, 13, 15]
all_ns = list(range(5, 16))

# Point stabilizers: n copies of index n
data = {}
for n in ns:
    indices = [n] * n
    W = inverse_index_kernel_matrix(indices)
    pressures = sample_pressures(W)
    data[n] = pressures

# Variance data for all n
var_data = []
for n in all_ns:
    indices = [n] * n
    W = inverse_index_kernel_matrix(indices)
    pressures = sample_pressures(W, num_samples=30000)
    var_data.append(np.var(pressures))

# Influence bounds
influence_bounds = []
for n in all_ns:
    # Each influence = 2 * n / n^4 = 2/n^3
    infl = 2.0 * n / n**4
    bound = 0.25 * n * infl**2  # p(1-p) * |S| * infl^2
    influence_bounds.append(bound)

# ─── Plot ────────────────────────────────────────────────────────────
fig = plt.figure(figsize=(16, 10))

# Top row: Distribution histograms
for i, n in enumerate(ns):
    ax = fig.add_subplot(2, len(ns), i + 1)
    pressures = data[n]
    mean = np.mean(pressures)
    std = np.std(pressures)
    
    if std > 1e-15:
        normalized = (pressures - mean) / std
        ax.hist(normalized, bins=50, density=True, alpha=0.7, 
                color=plt.cm.viridis(i / len(ns)), edgecolor='none')
        x = np.linspace(-4, 4, 200)
        ax.plot(x, np.exp(-x**2/2)/np.sqrt(2*np.pi), 'r-', lw=1.5)
    
    ax.set_title(f'$S_{{{n}}}$', fontsize=14)
    ax.set_xlim(-4, 4)
    ax.set_ylim(0, 0.55)
    if i == 0:
        ax.set_ylabel('Density', fontsize=12)
    ax.set_xlabel('$(\\Pi - \\mathbb{E}[\\Pi])/\\sigma$', fontsize=10)
    ax.tick_params(labelsize=9)

# Bottom left: Variance decay
ax1 = fig.add_subplot(2, 3, 4)
ax1.loglog(all_ns, var_data, 'bo-', markersize=6, label='Empirical Var')
ax1.loglog(all_ns, influence_bounds, 'r^--', markersize=6, label='Influence Bound')
# Reference line
ref = [var_data[0] * (all_ns[0]/n)**4 for n in all_ns]
ax1.loglog(all_ns, ref, 'k:', alpha=0.5, label='$O(n^{-4})$')
ax1.set_xlabel('$n$', fontsize=12)
ax1.set_ylabel('Var($\\Pi$)', fontsize=12)
ax1.set_title('Variance Decay', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Bottom center: Concentration quality
ax2 = fig.add_subplot(2, 3, 5)
cv = [np.std(sample_pressures(inverse_index_kernel_matrix([n]*n), num_samples=20000)) / 
      max(np.mean(sample_pressures(inverse_index_kernel_matrix([n]*n), num_samples=20000)), 1e-30)
      for n in all_ns]
ax2.plot(all_ns, cv, 'gs-', markersize=6)
ax2.set_xlabel('$n$', fontsize=12)
ax2.set_ylabel('CV = $\\sigma / \\mu$', fontsize=12)
ax2.set_title('Coefficient of Variation', fontsize=14)
ax2.grid(True, alpha=0.3)

# Bottom right: Influence profile
ax3 = fig.add_subplot(2, 3, 6)
for n_val, color in [(5, 'blue'), (10, 'orange'), (15, 'green')]:
    indices = np.array([n_val] * n_val, dtype=float)
    W = inverse_index_kernel_matrix(indices)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    ax3.bar(np.arange(len(influences)) + (n_val - 10) * 0.1, 
            influences, width=0.3, alpha=0.7, 
            label=f'$S_{{{n_val}}}$', color=color)
ax3.set_xlabel('Subgroup index', fontsize=12)
ax3.set_ylabel('Influence', fontsize=12)
ax3.set_title('Influence Profile', fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Concentration of Subgroup Pressure on Symmetric Groups', 
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
