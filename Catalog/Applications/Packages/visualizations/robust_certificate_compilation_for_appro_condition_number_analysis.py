#!/usr/bin/env python3
"""
Visualization: Condition Number and Normalization Stability

This script visualizes the key normalization stability theorem:
‖w/‖w‖ - v/‖v‖‖₂ ≤ 2·‖w-v‖₂ / min(‖w‖₂, ‖v‖₂)

Shows how the condition number (2/min_norm) controls perturbation
amplification, and how mass lower bounds provide dimension-independent
conditioning.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def l2_norm(w):
    return np.sqrt(np.sum(w**2))

def normalized_vec(w):
    norm = l2_norm(w)
    return w / norm if norm > 1e-15 else np.zeros_like(w)

# ─────────────────────────────────────────────────────────────
# Panel 1: Condition number vs dimension for different families
# ─────────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Normalization amplification factor
ax = axes[0]
dims = np.arange(3, 51)
eps = 0.1
n_trials = 50

amp_factors = []
theoretical_bounds = []

for n in dims:
    exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
    norm_exact = l2_norm(exact)
    
    factors = []
    for trial in range(n_trials):
        rng = np.random.RandomState(trial)
        noise = rng.exponential(1.0, size=len(exact))
        noise = noise / np.sum(noise) * eps
        perturbed = exact + noise
        
        psi_diff = l2_norm(normalized_vec(perturbed) - normalized_vec(exact))
        raw_diff = l2_norm(perturbed - exact)
        
        if raw_diff > 1e-15:
            factors.append(psi_diff / raw_diff)
    
    amp_factors.append(np.mean(factors))
    min_norm = min(l2_norm(exact), l2_norm(exact + noise))
    theoretical_bounds.append(2.0 / min_norm)

ax.semilogy(dims, amp_factors, 'bo-', markersize=3, label='Empirical amplification')
ax.semilogy(dims, theoretical_bounds, 'r--', linewidth=2, label='Bound: 2/min(‖w‖,‖v‖)')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Amplification factor', fontsize=11)
ax.set_title('Normalization Amplification\nvs Dimension', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Fidelity loss scaling
ax = axes[1]
eps_vals = np.logspace(-4, 0, 30)
n = 10
exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)

fid_losses = []
for eps in eps_vals:
    losses = []
    for trial in range(20):
        rng = np.random.RandomState(trial)
        noise = rng.exponential(1.0, size=len(exact))
        noise = noise / np.sum(noise) * eps
        perturbed = exact + noise
        
        f = np.sum(normalized_vec(perturbed) * normalized_vec(exact))**2
        losses.append(1.0 - f)
    fid_losses.append(np.mean(losses))

ax.loglog(eps_vals, fid_losses, 'bo-', markersize=3, label='Actual 1 - F')
ax.loglog(eps_vals, 4 * eps_vals**2 / l2_norm(exact)**2, 'r--', linewidth=2,
          label='Bound: 4ε²/‖w‖²')
# Reference slope
ax.loglog(eps_vals, eps_vals**2 * fid_losses[-1] / eps_vals[-1]**2, 'k:',
          linewidth=1, alpha=0.5, label='Slope 2 reference')
ax.set_xlabel('Perturbation ε', fontsize=11)
ax.set_ylabel('Fidelity loss (1 - F)', fontsize=11)
ax.set_title(f'Quadratic Fidelity Loss\n(Binomial C({n},k))', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Dimension dependence of effective constant
ax = axes[2]
dims2 = [5, 10, 20, 50, 100, 200]
eps_test = 0.01
c_effs_raw = []
c_effs_mass = []

for n in dims2:
    exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
    # Normalize to unit mass for fair comparison
    exact_norm = exact / np.sum(exact)
    
    effs = []
    for trial in range(50):
        rng = np.random.RandomState(trial)
        noise = rng.exponential(1.0, size=len(exact_norm))
        noise = noise / np.sum(noise) * eps_test
        perturbed = exact_norm + noise
        
        tv = 0.5 * np.sum(np.abs(perturbed - exact_norm))
        f = np.sum(normalized_vec(perturbed) * normalized_vec(exact_norm))**2
        loss = 1.0 - f
        if tv > 1e-15:
            effs.append(loss / tv**2)
    
    c_effs_raw.append(np.mean(effs))
    # Mass-based: C_mass = 4n/m² where m = 1 (unit mass)
    c_effs_mass.append(4.0 * (n + 1))

ax.plot(dims2, c_effs_raw, 'bo-', markersize=6, linewidth=2,
        label='Empirical C_eff')
ax.plot(dims2, c_effs_mass, 'r--', markersize=4, linewidth=2,
        label='Theorem bound: 4n/m²')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Effective constant C', fontsize=11)
ax.set_title('Dimension Dependence\nof Fidelity Constant', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Condition Number Analysis for Certificate Compilation',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_condition_number.png', dpi=150, bbox_inches='tight')
print("Saved viz_condition_number.png")
