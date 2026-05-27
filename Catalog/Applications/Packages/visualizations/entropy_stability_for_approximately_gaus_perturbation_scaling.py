#!/usr/bin/env python3
"""
Visualization 2: Perturbation Scaling and Conjecture Testing

Visualizes:
- How entropy difference scales with perturbation epsilon (linear regime)
- Comparison of sup-norm vs L1 bounds
- Testing the m*log(m+1) conjecture for local interactions
- Elementary symmetric polynomial stability
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def region_entropy(spec):
    return np.sum(binary_entropy(spec))


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


def elem_symm(k, spec):
    m = len(spec)
    if k > m or k < 0:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod([spec[i] for i in S]) for S in combinations(range(m), k))


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Entropy difference vs epsilon (linearity test)
ax = axes[0, 0]
delta = 0.15
L = entropy_stability_constant(delta)
np.random.seed(42)

for m_val, color in [(5, 'blue'), (10, 'green'), (20, 'red'), (50, 'purple')]:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    eps_range = np.linspace(0, 0.15, 30)
    max_diffs = []
    for eps in eps_range:
        diffs = []
        for _ in range(200):
            pert = np.random.uniform(-eps, eps, m_val)
            spec = np.clip(spec0 + pert, delta, 1 - delta)
            diffs.append(abs(region_entropy(spec) - region_entropy(spec0)))
        max_diffs.append(np.max(diffs))

    ax.plot(eps_range, max_diffs, 'o-', color=color, markersize=3,
            label=f'm={m_val} (observed)')
    ax.plot(eps_range, m_val * L * eps_range, '--', color=color, alpha=0.5,
            label=f'm={m_val} (bound)')

ax.set_xlabel('Perturbation ε', fontsize=12)
ax.set_ylabel('Max |ΔS|', fontsize=12)
ax.set_title('Entropy Difference: Linear in ε', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 2: Sup-norm vs L1 bound comparison
ax = axes[0, 1]
m_val = 15
delta = 0.15
L = entropy_stability_constant(delta)
np.random.seed(123)
spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)

# Generate perturbations with varying localization
n_trials = 500
actual_diffs = []
sup_bounds = []
l1_bounds = []

for _ in range(n_trials):
    # Random localization: perturbation concentrated on random subset
    n_perturbed = np.random.randint(1, m_val + 1)
    eta = 0.08
    pert = np.zeros(m_val)
    indices = np.random.choice(m_val, n_perturbed, replace=False)
    pert[indices] = np.random.uniform(-eta, eta, n_perturbed)
    spec = np.clip(spec0 + pert, delta, 1 - delta)

    actual_diff = abs(region_entropy(spec) - region_entropy(spec0))
    sup_bound = m_val * L * np.max(np.abs(spec - spec0))
    l1_bound = L * np.sum(np.abs(spec - spec0))

    actual_diffs.append(actual_diff)
    sup_bounds.append(sup_bound)
    l1_bounds.append(l1_bound)

ax.scatter(l1_bounds, actual_diffs, alpha=0.3, s=10, c='blue', label='L1 bound')
ax.scatter(sup_bounds, actual_diffs, alpha=0.3, s=10, c='red', label='Sup bound')
max_val = max(max(sup_bounds), max(l1_bounds))
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x (tight)')
ax.set_xlabel('Certified bound', fontsize=12)
ax.set_ylabel('Actual |ΔS|', fontsize=12)
ax.set_title('L1 vs Sup-Norm Bounds', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: m*log(m+1) conjecture test
ax = axes[1, 0]
m_values = np.arange(2, 65)
eps = 0.05
delta = 0.15
np.random.seed(42)

ratios_mean = []
ratios_max = []
log_bound = np.log(m_values + 1)

for m_val in m_values:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    trial_ratios = []
    for _ in range(100):
        pert = np.random.uniform(-eps, eps, m_val)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        diff = abs(region_entropy(spec) - region_entropy(spec0))
        ratio = diff / (eps * m_val) if eps * m_val > 0 else 0
        trial_ratios.append(ratio)
    ratios_mean.append(np.mean(trial_ratios))
    ratios_max.append(np.max(trial_ratios))

ax.plot(m_values, ratios_max, 'r.', markersize=3, alpha=0.5, label='Max ratio')
ax.plot(m_values, ratios_mean, 'b-', linewidth=1.5, label='Mean ratio')
ax.plot(m_values, log_bound, 'g--', linewidth=2, label='log(m+1) conjecture')
L = entropy_stability_constant(delta)
ax.axhline(L, color='orange', linestyle=':', label=f'L_δ={L:.2f} (formal bound)')
ax.set_xlabel('Subsystem size m', fontsize=12)
ax.set_ylabel('|ΔS| / (ε·m)', fontsize=12)
ax.set_title('Conjecture: Correction ~ m·log(m+1)·ε', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Elementary symmetric polynomial stability
ax = axes[1, 1]
m_val = 8
np.random.seed(42)
spec0 = np.random.uniform(0.1, 0.9, m_val)

eta_range = np.linspace(0, 0.1, 25)
for k in [1, 2, 3, 4]:
    e0 = elem_symm(k, spec0)
    max_diffs_esymm = []
    bounds_esymm = []
    for eta in eta_range:
        diffs = []
        for _ in range(200):
            pert = np.random.uniform(-eta, eta, m_val)
            spec = np.clip(spec0 + pert, 0, 1)
            diffs.append(abs(elem_symm(k, spec) - e0))
        max_diffs_esymm.append(np.max(diffs))
        bounds_esymm.append(comb(m_val, k) * k * eta)

    ax.plot(eta_range, max_diffs_esymm, 'o-', markersize=3, label=f'k={k} observed')
    ax.plot(eta_range, bounds_esymm, '--', alpha=0.5, label=f'k={k} bound')

ax.set_xlabel('Perturbation η', fontsize=12)
ax.set_ylabel('|e_k(λ) - e_k(μ)|', fontsize=12)
ax.set_title('Elementary Symmetric Polynomial Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)

plt.suptitle('Perturbation Scaling and Conjecture Testing',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_perturbation_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_scaling.png")
