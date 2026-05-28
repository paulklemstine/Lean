#!/usr/bin/env python3
"""
Visualization: Fidelity Landscape Under Perturbation

This script visualizes how fidelity degrades as coefficient vectors are
perturbed away from exact Lorentzian families, confirming the quadratic
bound F ≥ 1 - C·ε² proved in the formal development.

Creates a figure showing:
1. Actual fidelity vs perturbation size (empirical)
2. Certified lower bound (theorem)
3. The quadratic envelope
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def l2_norm(w):
    return np.sqrt(np.sum(w**2))

def normalized_vec(w):
    norm = l2_norm(w)
    return w / norm if norm > 1e-15 else np.zeros_like(w)

def fidelity(w, v):
    return float(np.sum(normalized_vec(w) * normalized_vec(v))**2)

def tv_dist(w, v):
    return 0.5 * np.sum(np.abs(w - v))

def certified_bound(w, v):
    min_norm = min(l2_norm(w), l2_norm(v))
    if min_norm < 1e-15:
        return 0.0
    return max(1.0 - 4.0 * np.sum((w - v)**2) / min_norm**2, 0.0)

# Parameters
n_values = [5, 10, 20]
n_eps = 50
eps_range = np.linspace(0, 2.0, n_eps)
n_trials = 20

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=True)

for idx, n in enumerate(n_values):
    ax = axes[idx]
    exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
    
    actual_fids = np.zeros((n_trials, n_eps))
    bounds = np.zeros((n_trials, n_eps))
    tv_dists = np.zeros((n_trials, n_eps))
    
    for trial in range(n_trials):
        rng = np.random.RandomState(trial)
        for j, eps in enumerate(eps_range):
            noise = rng.exponential(1.0, size=len(exact))
            noise = noise / np.sum(noise) * eps if np.sum(noise) > 0 else noise
            perturbed = exact + noise
            
            actual_fids[trial, j] = fidelity(perturbed, exact)
            bounds[trial, j] = certified_bound(perturbed, exact)
            tv_dists[trial, j] = tv_dist(perturbed, exact)
    
    # Plot individual trials (light)
    for trial in range(min(n_trials, 5)):
        ax.plot(eps_range, actual_fids[trial], 'b-', alpha=0.15, linewidth=0.5)
    
    # Plot mean
    mean_fid = np.mean(actual_fids, axis=0)
    mean_bound = np.mean(bounds, axis=0)
    
    ax.plot(eps_range, mean_fid, 'b-', linewidth=2, label='Actual fidelity (mean)')
    ax.plot(eps_range, mean_bound, 'r--', linewidth=2, label='Certified bound')
    
    # Shade the gap
    ax.fill_between(eps_range, mean_bound, mean_fid, alpha=0.15, color='green',
                    label='Safety margin')
    
    # Quadratic reference
    norm_exact = l2_norm(exact)
    C_ref = 4.0 / norm_exact**2
    quadratic = 1.0 - C_ref * eps_range**2
    ax.plot(eps_range, np.maximum(quadratic, 0), 'k:', linewidth=1.5,
            label=f'1 - {C_ref:.2e}·ε²')
    
    ax.set_xlabel('Perturbation size ε (ℓ¹ norm)', fontsize=11)
    if idx == 0:
        ax.set_ylabel('Fidelity', fontsize=11)
    ax.set_title(f'Binomial C({n}, k)', fontsize=13, fontweight='bold')
    ax.set_ylim([0.0, 1.05])
    ax.set_xlim([0, 2.0])
    ax.legend(fontsize=8, loc='lower left')
    ax.grid(True, alpha=0.3)

plt.suptitle('Robust Certificate Compilation: Fidelity vs Perturbation',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_fidelity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_fidelity_landscape.png")
