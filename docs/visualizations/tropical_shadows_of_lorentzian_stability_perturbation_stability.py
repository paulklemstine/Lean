#!/usr/bin/env python3
"""
Visualization: Perturbation Stability of Tropical Gap

This script visualizes how the tropical spectral gap degrades under
weight perturbation, demonstrating the 4-Lipschitz bound proved in
Theorem 4 (exchange_slack_lipschitz).
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

# Base weight matrix (4×4 uniform Lorentzian)
n = 4
d, c = 0.0, 2.0
w_base = np.full((n, n), c)
np.fill_diagonal(w_base, d)


def diag_exchange_slack(w, i, j):
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_gap_value(w):
    n = w.shape[0]
    return min(diag_exchange_slack(w, i, j)
               for i in range(n) for j in range(n) if i != j)


# Experiment: vary perturbation magnitude
eps_values = np.linspace(0, 1.5, 200)
n_trials = 500

gap_means = []
gap_mins = []
gap_maxs = []
gap_stds = []

for eps in eps_values:
    gaps = []
    for _ in range(n_trials):
        perturbation = np.random.uniform(-eps, eps, (n, n))
        perturbation = (perturbation + perturbation.T) / 2
        w_pert = w_base + perturbation
        gaps.append(tropical_gap_value(w_pert))
    gap_means.append(np.mean(gaps))
    gap_mins.append(np.min(gaps))
    gap_maxs.append(np.max(gaps))
    gap_stds.append(np.std(gaps))

gap_means = np.array(gap_means)
gap_mins = np.array(gap_mins)
gap_maxs = np.array(gap_maxs)

base_gap = tropical_gap_value(w_base)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Plot 1: Gap distribution under perturbation
ax1 = axes[0]
ax1.fill_between(eps_values, gap_mins, gap_maxs, alpha=0.2, color='blue',
                 label='Range (min-max)')
ax1.plot(eps_values, gap_means, 'b-', linewidth=2, label='Mean gap')
ax1.plot(eps_values, base_gap - 4 * eps_values, 'r--', linewidth=2,
         label='Lower bound: gap₀ - 4ε')
ax1.plot(eps_values, base_gap + 4 * eps_values, 'r--', linewidth=2,
         label='Upper bound: gap₀ + 4ε')
ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='-')
ax1.axhline(y=base_gap, color='green', linewidth=1, linestyle=':',
            label=f'Base gap = {base_gap:.1f}')
ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax1.set_ylabel('Tropical spectral gap', fontsize=12)
ax1.set_title('Gap Stability Under Weight Perturbation', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Mark the critical perturbation where stability is lost
critical_eps = base_gap / 4
ax1.axvline(x=critical_eps, color='orange', linewidth=1.5, linestyle='-.',
            label=f'Critical ε = gap₀/4 = {critical_eps:.2f}')
ax1.legend(fontsize=9)

# Plot 2: Slack distribution for a specific perturbation
ax2 = axes[1]
eps_fixed = 0.3
all_slacks_base = []
all_slacks_pert = []

for i in range(n):
    for j in range(n):
        if i != j:
            all_slacks_base.append(diag_exchange_slack(w_base, i, j))

for _ in range(200):
    perturbation = np.random.uniform(-eps_fixed, eps_fixed, (n, n))
    perturbation = (perturbation + perturbation.T) / 2
    w_pert = w_base + perturbation
    for i in range(n):
        for j in range(n):
            if i != j:
                all_slacks_pert.append(diag_exchange_slack(w_pert, i, j))

ax2.hist(all_slacks_pert, bins=50, alpha=0.6, color='blue', density=True,
         label=f'Perturbed (ε={eps_fixed})')
ax2.axvline(x=all_slacks_base[0], color='green', linewidth=2,
            label=f'Base value = {all_slacks_base[0]:.1f}')
ax2.axvline(x=all_slacks_base[0] - 4*eps_fixed, color='red', linewidth=2,
            linestyle='--', label=f'Lower bound')
ax2.axvline(x=all_slacks_base[0] + 4*eps_fixed, color='red', linewidth=2,
            linestyle='--', label=f'Upper bound')
ax2.set_xlabel('Exchange slack value', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title(f'Slack Distribution (ε = {eps_fixed})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle('Tropical Gap Lipschitz Stability (4-Lipschitz Bound)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved: perturbation_stability.png")
