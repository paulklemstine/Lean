#!/usr/bin/env python3
"""
Visualization 3: Cross-Domain Bridge — Covariance Form Identity

Visualizes the key identity connecting Lorentzian geometry to statistical physics:
    ∑_{i,j} Cov(σ_i, σ_j) v_i v_j = Var(∑_i v_i σ_i) ≥ 0

Shows that the quadratic covariance form (susceptibility) is always nonneg,
demonstrating the positive semidefiniteness proved in covarianceForm_nonneg.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def spin_configs(n):
    return np.array(list(product([-1, 1], repeat=n)), dtype=float)


def compute_covariance_form(n, beta, J, h, v):
    configs = spin_configs(n)
    energies = np.array([np.dot(h, s) + s @ J @ s for s in configs])
    be = beta * energies
    be -= np.max(be)
    w = np.exp(be); w /= np.sum(w)

    # LHS: v^T Cov v
    mean_s = configs.T @ w
    cov = np.zeros((n, n))
    for k in range(len(configs)):
        cov += w[k] * np.outer(configs[k], configs[k])
    cov -= np.outer(mean_s, mean_s)
    lhs = v @ cov @ v

    # RHS: E[(v·σ)²] - E[v·σ]²
    linear = configs @ v
    E_sq = np.sum(w * linear**2)
    E_val = np.sum(w * linear)
    rhs = E_sq - E_val**2

    return lhs, rhs, cov


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Cross-Domain Bridge: Lorentzian Geometry ↔ Statistical Physics',
             fontsize=16, fontweight='bold', y=0.98)

rng = np.random.default_rng(42)

# Panel 1: Identity verification across many random directions
ax = axes[0, 0]
n_val = 6
beta = 1.5
J = np.ones((n_val, n_val)) / n_val
np.fill_diagonal(J, 0)
h = rng.standard_normal(n_val) * 0.3

num_dirs = 200
lhs_vals = []
rhs_vals = []
for _ in range(num_dirs):
    v = rng.standard_normal(n_val)
    l, r, _ = compute_covariance_form(n_val, beta, J, h, v)
    lhs_vals.append(l)
    rhs_vals.append(r)

ax.scatter(lhs_vals, rhs_vals, alpha=0.5, s=20, c='#2196F3')
lim = max(max(lhs_vals), max(rhs_vals)) * 1.1
ax.plot([0, lim], [0, lim], 'r--', alpha=0.7, label='y = x')
ax.set_xlabel('LHS: v^T Cov v', fontsize=12)
ax.set_ylabel('RHS: E[(v·σ)²] - E[v·σ]²', fontsize=12)
ax.set_title('Covariance Form Identity (200 random v)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
max_err = max(abs(l - r) for l, r in zip(lhs_vals, rhs_vals))
ax.text(0.05, 0.92, f'Max |LHS - RHS| = {max_err:.2e}',
        transform=ax.transAxes, fontsize=10, bbox=dict(boxstyle='round',
        facecolor='wheat', alpha=0.5))

# Panel 2: Nonnegativity across temperature range
ax = axes[0, 1]
beta_range = np.linspace(0.1, 5.0, 50)
min_cov_forms = {4: [], 6: [], 8: []}
colors_n = {4: '#E91E63', 6: '#4CAF50', 8: '#FF9800'}

for n_val in [4, 6, 8]:
    J = np.ones((n_val, n_val)) / n_val
    np.fill_diagonal(J, 0)
    h = np.zeros(n_val)

    for b in beta_range:
        min_form = float('inf')
        for _ in range(50):
            v = rng.standard_normal(n_val)
            v /= np.linalg.norm(v)
            l, _, _ = compute_covariance_form(n_val, b, J, h, v)
            min_form = min(min_form, l)
        min_cov_forms[n_val].append(min_form)

    ax.plot(beta_range, min_cov_forms[n_val], color=colors_n[n_val],
            linewidth=2, label=f'n = {n_val}')

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('min v^T Cov v (unit v)', fontsize=12)
ax.set_title('Nonnegativity of Covariance Form\n(min over random unit vectors)',
             fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.text(0.05, 0.05, 'Always ≥ 0\n(Theorem: covarianceForm_nonneg)',
        transform=ax.transAxes, fontsize=10,
        bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

# Panel 3: Eigenvalue spectrum of covariance matrix
ax = axes[1, 0]
n_val = 8
J = np.ones((n_val, n_val)) / n_val
np.fill_diagonal(J, 0)
h = np.zeros(n_val)
betas_sample = [0.3, 0.7, 1.0, 1.5, 2.0, 3.0]
colors_b = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(betas_sample)))

for b, col in zip(betas_sample, colors_b):
    _, _, cov = compute_covariance_form(n_val, b, J, h, np.ones(n_val))
    eigs = np.sort(np.linalg.eigvalsh(cov))[::-1]
    ax.plot(range(1, n_val + 1), eigs, 'o-', color=col, markersize=5,
            label=f'β = {b}')

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xlabel('Eigenvalue index', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title(f'Covariance Spectrum (n={n_val}, K_n)', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 4: Perturbation effect on covariance eigenvalues
ax = axes[1, 1]
n_val = 6
J = np.ones((n_val, n_val)) / n_val
np.fill_diagonal(J, 0)
h = np.zeros(n_val)
beta = 1.5

# Unperturbed
_, _, cov0 = compute_covariance_form(n_val, beta, J, h, np.ones(n_val))
eigs0 = np.sort(np.linalg.eigvalsh(cov0))[::-1]

deltas = [0.001, 0.005, 0.01, 0.05, 0.1]
for delta in deltas:
    eig_samples = []
    for _ in range(50):
        noise = rng.uniform(-delta, delta, (n_val, n_val))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        _, _, cov_p = compute_covariance_form(n_val, beta, J + noise, h,
                                               np.ones(n_val))
        eig_samples.append(np.sort(np.linalg.eigvalsh(cov_p))[::-1])
    eig_samples = np.array(eig_samples)
    max_shift = np.max(np.abs(eig_samples - eigs0[None, :]))
    ax.bar(deltas.index(delta), max_shift, color='#7C4DFF', alpha=0.7)

ax.set_xticks(range(len(deltas)))
ax.set_xticklabels([f'δ={d}' for d in deltas], fontsize=9)
ax.set_ylabel('Max eigenvalue shift', fontsize=12)
ax.set_title(f'Covariance Stability (n={n_val}, β={beta})', fontsize=13)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('covariance_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: covariance_bridge.png")
