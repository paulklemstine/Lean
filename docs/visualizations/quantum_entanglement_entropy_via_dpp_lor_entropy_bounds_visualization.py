#!/usr/bin/env python3
"""
Visualization: Binary Entropy Bounds and DPP-Lorentzian Structure

This script visualizes the core mathematical relationships proven in the
formalization: binary entropy squeeze between 2x(1-x) and log(2),
entropy vs variance scatter, and Newton ratio distributions.

Uses matplotlib, saves output as PNG.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations


def binary_entropy(x):
    x = np.clip(x, 1e-15, 1 - 1e-15)
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermion_entropy(spectrum):
    return sum(binary_entropy(x) for x in spectrum)


def subsystem_variance(spectrum):
    return np.sum(spectrum * (1 - spectrum))


def esymm_dp(spectrum, max_k=None):
    m = len(spectrum)
    if max_k is None:
        max_k = m
    e = np.zeros(max_k + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, max_k), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Entanglement Entropy via DPP-Lorentzian Structure", fontsize=16, fontweight='bold')

# Panel 1: Binary entropy squeeze
ax = axes[0, 0]
x = np.linspace(0.001, 0.999, 1000)
hx = binary_entropy(x)
lower = 2 * x * (1 - x)
ax.fill_between(x, lower, np.log(2), alpha=0.1, color='blue', label='Proven range for h(x)')
ax.plot(x, hx, 'b-', linewidth=2.5, label='h(x) = binary entropy')
ax.plot(x, lower, 'r--', linewidth=2, label=r'$2x(1-x)$ (lower bound)')
ax.axhline(y=np.log(2), color='green', linestyle=':', linewidth=2, label=r'$\log 2$ (upper bound)')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('h(x)', fontsize=12)
ax.set_title('Theorem: $2x(1-x) \\leq h(x) \\leq \\log 2$', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(0, 0.8)

# Panel 2: Entropy vs Variance (random spectra)
ax = axes[0, 1]
np.random.seed(42)
m = 6
entropies, variances = [], []
for _ in range(3000):
    spec = np.random.beta(2, 2, size=m)
    entropies.append(fermion_entropy(spec))
    variances.append(subsystem_variance(spec))
entropies = np.array(entropies)
variances = np.array(variances)

scatter = ax.scatter(variances, entropies, alpha=0.2, s=8, c=entropies, cmap='viridis')
v_range = np.linspace(0, variances.max() * 1.1, 100)
ax.plot(v_range, 2 * v_range, 'r-', linewidth=2.5, label=r'$S = 2 \cdot \mathrm{Var}$ (lower)')
ax.axhline(y=m * np.log(2), color='green', linestyle='--', linewidth=2, label=r'$S = m\log 2$ (upper)')
ax.set_xlabel(r'Variance $\mathrm{Var}(N_A)$', fontsize=12)
ax.set_ylabel(r'Entropy $S$', fontsize=12)
ax.set_title(f'Entropy Bounds (m={m}, 3000 samples)', fontsize=13)
ax.legend(fontsize=10)
plt.colorbar(scatter, ax=ax, label='Entropy S')

# Panel 3: Elementary symmetric profiles
ax = axes[1, 0]
spectra = {
    'Flat (λ=0.5)': np.full(m, 0.5),
    'Peaked': np.array([0.9, 0.1, 0.05, 0.05, 0.8, 0.1]),
    'Spread': np.array([0.3, 0.7, 0.4, 0.6, 0.5, 0.5]),
}
for name, spec in spectra.items():
    e = esymm_dp(spec)
    ax.semilogy(range(len(e)), e + 1e-15, 'o-', linewidth=2, markersize=6, label=name)
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel(r'$e_k(\lambda)$ (log scale)', fontsize=12)
ax.set_title('Elementary Symmetric Profiles', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(range(m + 1))

# Panel 4: Newton ratio heatmap
ax = axes[1, 1]
n_samples = 200
all_ratios = np.zeros((n_samples, m - 1))
entropies_sorted = []
for idx in range(n_samples):
    spec = np.sort(np.random.beta(2, 2, size=m))[::-1]
    e = esymm_dp(spec)
    entropies_sorted.append(fermion_entropy(spec))
    for k in range(1, m):
        denom = e[k-1] * e[k+1]
        if abs(denom) > 1e-15:
            all_ratios[idx, k-1] = min(e[k]**2 / denom, 20)
        else:
            all_ratios[idx, k-1] = 20

sort_idx = np.argsort(entropies_sorted)
all_ratios_sorted = all_ratios[sort_idx]

im = ax.imshow(all_ratios_sorted.T, aspect='auto', cmap='YlOrRd',
               extent=[0, n_samples, m-0.5, 0.5], vmin=1, vmax=10)
ax.set_xlabel('Sample (sorted by entropy ↑)', fontsize=12)
ax.set_ylabel(r'Newton index $k$', fontsize=12)
ax.set_title(r'Newton Ratios $\rho_k = e_k^2/(e_{k-1}e_{k+1})$', fontsize=13)
ax.set_yticks(range(1, m))
plt.colorbar(im, ax=ax, label=r'$\rho_k$ (all ≥ 1)')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('visualize_entropy.png', dpi=150, bbox_inches='tight')
print("Saved visualize_entropy.png")
