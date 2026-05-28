#!/usr/bin/env python3
"""
Visualization: Potts Partition Function Stability Landscape

Visualizes the log-Lipschitz stability of the Potts partition function
as coupling parameters are perturbed. Shows that the certified bound
(red surface) always envelopes the empirical variation (blue dots),
confirming the formally verified theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def potts_energy(sigma, J, beta):
    n = len(sigma)
    total = sum(J[i, j] for i in range(n) for j in range(n) if sigma[i] == sigma[j])
    return beta * total


def potts_partition(n, q, J, beta):
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        Z += np.exp(potts_energy(np.array(sigma), J, beta))
    return Z


# Parameters
n = 3
q = 3
beta = 0.8
np.random.seed(42)

J_base = np.random.randn(n, n) * 0.3
J_base = (J_base + J_base.T) / 2

# Generate perturbations along two directions
n_points = 25
delta_range = np.linspace(-0.3, 0.3, n_points)

# Direction 1: uniform perturbation
dJ1 = np.ones((n, n)) / n
# Direction 2: random structured perturbation
dJ2 = np.random.randn(n, n)
dJ2 = (dJ2 + dJ2.T) / 2
dJ2 /= np.max(np.abs(dJ2))

log_Z_base = np.log(potts_partition(n, q, J_base, beta))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Log Z as function of perturbation magnitude
for idx, (dJ, label) in enumerate([(dJ1, "Uniform"), (dJ2, "Random")]):
    log_Zs = []
    deltas = []
    bounds = []
    for d in delta_range:
        J_pert = J_base + d * dJ
        log_Z = np.log(potts_partition(n, q, J_pert, beta))
        log_Zs.append(log_Z)
        deltas.append(d)
        sup_norm = np.max(np.abs(d * dJ))
        bounds.append(abs(beta) * n**2 * sup_norm)

    log_Zs = np.array(log_Zs)
    bounds = np.array(bounds)

    ax = axes[idx]
    ax.fill_between(delta_range, log_Z_base - bounds, log_Z_base + bounds,
                     alpha=0.2, color='red', label='Certified envelope')
    ax.plot(delta_range, log_Zs, 'b-', linewidth=2, label='log Z(J + δ·ΔJ)')
    ax.axhline(y=log_Z_base, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Perturbation δ', fontsize=12)
    ax.set_ylabel('log Z', fontsize=12)
    ax.set_title(f'{label} perturbation (n={n}, q={q})', fontsize=13)
    ax.legend(fontsize=10)

# Plot 3: Ratio heatmap across q and n
ax = axes[2]
q_values = [2, 3, 4, 5]
n_values = [2, 3, 4]
ratios = np.zeros((len(q_values), len(n_values)))

for qi, q_val in enumerate(q_values):
    for ni, n_val in enumerate(n_values):
        J = np.random.randn(n_val, n_val) * 0.3
        J = (J + J.T) / 2
        dJ = np.random.randn(n_val, n_val) * 0.1
        dJ = (dJ + dJ.T) / 2
        K = J + dJ

        Z_J = potts_partition(n_val, q_val, J, beta)
        Z_K = potts_partition(n_val, q_val, K, beta)
        empirical = abs(np.log(Z_J) - np.log(Z_K))
        certified = abs(beta) * n_val**2 * np.max(np.abs(J - K))
        ratios[qi, ni] = empirical / certified if certified > 0 else 0

im = ax.imshow(ratios, cmap='YlOrRd', vmin=0, vmax=1, aspect='auto')
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values)
ax.set_yticks(range(len(q_values)))
ax.set_yticklabels(q_values)
ax.set_xlabel('Number of sites n', fontsize=12)
ax.set_ylabel('Number of states q', fontsize=12)
ax.set_title('Bound tightness ratio', fontsize=13)
plt.colorbar(im, ax=ax, label='|Δ log Z| / certified bound')

for qi in range(len(q_values)):
    for ni in range(len(n_values)):
        ax.text(ni, qi, f'{ratios[qi, ni]:.2f}',
                ha='center', va='center', fontsize=10,
                color='white' if ratios[qi, ni] > 0.5 else 'black')

plt.suptitle('Potts Partition Function: Certified Stability', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_stability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_landscape.png")
