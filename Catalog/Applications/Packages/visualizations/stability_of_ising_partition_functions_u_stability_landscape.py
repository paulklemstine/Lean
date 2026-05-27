#!/usr/bin/env python3
"""
Visualization 1: Stability Landscape of Ising Partition Function

Visualizes how the log partition function changes as couplings are perturbed,
showing the Lipschitz bound envelope and the empirical distribution of
perturbation effects for different system sizes.

This illustrates the core theorem: |log Z(J') - log Z(J)| ≤ β n² δ
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def spin_configs(n):
    return np.array(list(product([-1, 1], repeat=n)), dtype=float)


def log_partition(beta, J, h, configs):
    energies = np.array([np.dot(h, s) + s @ J @ s for s in configs])
    be = beta * energies
    mx = np.max(be)
    return mx + np.log(np.sum(np.exp(be - mx)))


def complete_graph_J(n, strength=1.0):
    J = strength * np.ones((n, n)) / n
    np.fill_diagonal(J, 0)
    return J


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Stability of Ising Partition Functions Under Coupling Noise',
             fontsize=16, fontweight='bold', y=0.98)

beta = 1.0
rng = np.random.default_rng(42)

# Panel 1: Log-Lipschitz bound verification for multiple n
ax = axes[0, 0]
n_values = [4, 6, 8]
colors = ['#2196F3', '#FF9800', '#4CAF50']
delta_values = np.linspace(0, 0.15, 30)

for n_val, color in zip(n_values, colors):
    J = complete_graph_J(n_val)
    configs = spin_configs(n_val)
    h = np.zeros(n_val)
    logZ0 = log_partition(beta, J, h, configs)

    max_diffs = []
    mean_diffs = []
    for delta in delta_values:
        diffs = []
        for _ in range(30):
            noise = rng.uniform(-delta, delta, (n_val, n_val))
            noise = (noise + noise.T) / 2
            np.fill_diagonal(noise, 0)
            logZ_p = log_partition(beta, J + noise, h, configs)
            diffs.append(abs(logZ_p - logZ0))
        max_diffs.append(np.max(diffs))
        mean_diffs.append(np.mean(diffs))

    bound = beta * n_val**2 * delta_values
    ax.fill_between(delta_values, 0, bound, alpha=0.1, color=color)
    ax.plot(delta_values, bound, '--', color=color, alpha=0.7,
            label=f'Bound (n={n_val})')
    ax.scatter(delta_values, max_diffs, s=15, color=color, alpha=0.8,
               label=f'Max obs. (n={n_val})')

ax.set_xlabel('Perturbation δ', fontsize=12)
ax.set_ylabel('|log Z\' - log Z|', fontsize=12)
ax.set_title('Log-Lipschitz Bound Verification', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 2: Covariance eigenvalues under perturbation
ax = axes[0, 1]
n_val = 6
J = complete_graph_J(n_val)
configs = spin_configs(n_val)
h = np.zeros(n_val)
deltas_test = [0, 0.02, 0.05, 0.1, 0.2]
colors_pert = plt.cm.viridis(np.linspace(0.2, 0.9, len(deltas_test)))

for delta, col in zip(deltas_test, colors_pert):
    all_eigs = []
    for _ in range(20):
        noise = rng.uniform(-delta, delta, (n_val, n_val))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        J_p = J + noise

        _, w, _ = [None, None, None]
        energies = np.array([np.dot(h, s) + s @ J_p @ s for s in configs])
        be = beta * energies
        be -= np.max(be)
        w = np.exp(be)
        w /= np.sum(w)
        mean_s = configs.T @ w
        cov = np.zeros((n_val, n_val))
        for k in range(len(configs)):
            cov += w[k] * np.outer(configs[k], configs[k])
        cov -= np.outer(mean_s, mean_s)
        all_eigs.append(np.linalg.eigvalsh(cov))

    all_eigs = np.array(all_eigs)
    positions = np.arange(n_val)
    ax.boxplot([all_eigs[:, i] for i in range(n_val)],
               positions=positions + delta * 2,
               widths=0.03, patch_artist=True,
               boxprops=dict(facecolor=col, alpha=0.5),
               medianprops=dict(color='black'),
               flierprops=dict(markersize=2),
               manage_ticks=False)

ax.set_xlabel('Eigenvalue index', fontsize=12)
ax.set_ylabel('Covariance eigenvalue', fontsize=12)
ax.set_title(f'Covariance Spectrum vs Noise (n={n_val})', fontsize=13)
ax.set_xticks(range(n_val))
ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Zero')
ax.legend(['δ=' + str(d) for d in deltas_test], fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 3: Bound tightness ratio vs n
ax = axes[1, 0]
n_range = [3, 4, 5, 6, 7, 8]
delta_fixed = 0.05
tightness_ratios = []

for n_val in n_range:
    J = complete_graph_J(n_val)
    configs = spin_configs(n_val)
    h = np.zeros(n_val)
    logZ0 = log_partition(beta, J, h, configs)
    bound = beta * n_val**2 * delta_fixed

    max_diff = 0
    for _ in range(100):
        noise = rng.uniform(-delta_fixed, delta_fixed, (n_val, n_val))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        logZ_p = log_partition(beta, J + noise, h, configs)
        max_diff = max(max_diff, abs(logZ_p - logZ0))

    tightness_ratios.append(max_diff / bound)

ax.bar(range(len(n_range)), tightness_ratios, color='#9C27B0', alpha=0.7)
ax.set_xticks(range(len(n_range)))
ax.set_xticklabels([f'n={n}' for n in n_range])
ax.set_ylabel('Max |Δlog Z| / Bound', fontsize=12)
ax.set_title(f'Bound Tightness (δ={delta_fixed}, β={beta})', fontsize=13)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Bound = 1')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Panel 4: Phase diagram — susceptibility with error bars
ax = axes[1, 1]
n_val = 6
J = complete_graph_J(n_val)
configs = spin_configs(n_val)
h = np.zeros(n_val)
beta_range = np.linspace(0.1, 4.0, 40)
coupling_noise = 0.02

chi_means = []
chi_errs = []
for b in beta_range:
    chis = []
    for _ in range(30):
        noise = rng.uniform(-coupling_noise, coupling_noise, (n_val, n_val))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        J_p = J + noise

        energies = np.array([np.dot(h, s) + s @ J_p @ s for s in configs])
        be = b * energies
        be -= np.max(be)
        w = np.exp(be)
        w /= np.sum(w)
        mean_s = configs.T @ w
        cov = np.zeros((n_val, n_val))
        for k in range(len(configs)):
            cov += w[k] * np.outer(configs[k], configs[k])
        cov -= np.outer(mean_s, mean_s)
        chis.append(b * np.trace(cov) / n_val)

    chi_means.append(np.mean(chis))
    chi_errs.append(np.std(chis))

ax.fill_between(beta_range,
                np.array(chi_means) - np.array(chi_errs),
                np.array(chi_means) + np.array(chi_errs),
                alpha=0.3, color='#E91E63')
ax.plot(beta_range, chi_means, color='#E91E63', linewidth=2)
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Susceptibility χ', fontsize=12)
ax.set_title(f'Phase Transition with Noisy Couplings (n={n_val})', fontsize=13)
ax.grid(True, alpha=0.3)
ax.annotate('Peak susceptibility\n(phase transition)',
            xy=(beta_range[np.argmax(chi_means)], max(chi_means)),
            xytext=(beta_range[np.argmax(chi_means)] + 0.5, max(chi_means) * 0.8),
            arrowprops=dict(arrowstyle='->', color='black'),
            fontsize=10)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('stability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: stability_landscape.png")
