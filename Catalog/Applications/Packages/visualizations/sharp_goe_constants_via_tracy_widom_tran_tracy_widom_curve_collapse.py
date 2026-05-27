#!/usr/bin/env python3
"""
Visualization 2: Tracy–Widom Curve Collapse

Demonstrates that the GOE operator norm exceedance probability, when plotted
against the rescaled variable t = (ε − 2σ) · n^(2/3) / σ, collapses onto
a universal curve independent of dimension n.
"""

import numpy as np
import matplotlib.pyplot as plt


def sample_GOE(n, sigma, rng):
    E = rng.normal(0, sigma / np.sqrt(n), size=(n, n))
    E = (E + E.T) / np.sqrt(2)
    np.fill_diagonal(E, rng.normal(0, sigma * np.sqrt(2.0 / n), size=n))
    return E


def operator_norm(M):
    return np.max(np.abs(np.linalg.eigvalsh(M)))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
sigma = 1.0
num_samples = 2000
seed = 42

# Left: Raw exceedance curves
ax = axes[0]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
dims = [10, 30, 100, 300]

for n, color in zip(dims, colors):
    rng = np.random.default_rng(seed)
    norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
    eps_vals = np.linspace(1.0, 3.5, 80)
    probs = [np.mean([norm >= eps for norm in norms]) for eps in eps_vals]
    ax.plot(eps_vals / sigma, probs, color=color, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='2σ edge')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('P(‖E‖ ≥ ε)', fontsize=14)
ax.set_title('Raw Exceedance Curves', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Rescaled collapse
ax = axes[1]
for n, color in zip(dims, colors):
    rng = np.random.default_rng(seed)
    norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
    t_vals = np.linspace(-4, 6, 80)
    eps_from_t = [2 * sigma + t * sigma / n**(2/3) for t in t_vals]
    probs = [np.mean([norm >= eps for norm in norms]) for eps in eps_from_t]
    ax.plot(t_vals, probs, color=color, label=f'n = {n}', linewidth=2, alpha=0.8)

ax.axvline(x=0.0, color='red', linestyle='--', alpha=0.7, label='Edge (t = 0)')
ax.set_xlabel('t = (ε − 2σ) · n^(2/3) / σ', fontsize=14)
ax.set_ylabel('P(‖E‖ ≥ ε)', fontsize=14)
ax.set_title('Tracy–Widom Curve Collapse', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tracy_widom_collapse.png', dpi=150, bbox_inches='tight')
print("Saved tracy_widom_collapse.png")
