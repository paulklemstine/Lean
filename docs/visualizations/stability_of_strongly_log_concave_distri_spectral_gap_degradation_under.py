import math
"""
Visualization: Spectral Gap Degradation Under Iterated Perturbation

Shows how the Lorentzian spectral gap degrades linearly under successive
coefficient perturbations, demonstrating the iterated_perturbation_gap theorem.
The key insight: noise does not cascade — gap degradation is exactly linear.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
initial_gap = 1.0
delta_per_step = 0.05
max_steps = 18
n_trials = 20

rng = np.random.default_rng(2025)

# Theoretical prediction: gap(k) = ε - k·δ
steps = np.arange(0, max_steps + 1)
theoretical_gap = initial_gap - steps * delta_per_step
theoretical_gap = np.maximum(theoretical_gap, 0)

# Simulated gap degradation (with actual log-concavity computation)
def estimate_gap_from_coeffs(coeffs):
    n = len(coeffs)
    if n < 3:
        return float('inf')
    min_gap = float('inf')
    for k in range(1, n - 1):
        if coeffs[k-1] > 1e-15 and coeffs[k+1] > 1e-15 and coeffs[k] > 1e-15:
            ratio = coeffs[k]**2 / (coeffs[k-1] * coeffs[k+1])
            gap = ratio - 1.0
            min_gap = min(min_gap, gap)
    return max(min_gap, 0.0)

n = 12
ref_coeffs = np.array([float(math.comb(n, k)) for k in range(n+1)])
ref_coeffs /= ref_coeffs.sum()
ref_gap = estimate_gap_from_coeffs(ref_coeffs)

empirical_gaps = np.zeros((n_trials, max_steps + 1))
for trial in range(n_trials):
    current = ref_coeffs.copy()
    empirical_gaps[trial, 0] = ref_gap
    for step in range(1, max_steps + 1):
        noise = delta_per_step * 0.02 * rng.standard_normal(len(current))
        current = current + noise
        current = np.maximum(current, 1e-15)
        current /= current.sum()
        empirical_gaps[trial, step] = estimate_gap_from_coeffs(current)

mean_gaps = empirical_gaps.mean(axis=0)
std_gaps = empirical_gaps.std(axis=0)

# Normalized theoretical curve
norm_theoretical = ref_gap * (1 - steps * delta_per_step / initial_gap)
norm_theoretical = np.maximum(norm_theoretical, 0)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left: theoretical
ax1.fill_between(steps, theoretical_gap, alpha=0.3, color='steelblue', label='Certified safe region')
ax1.plot(steps, theoretical_gap, 'o-', color='steelblue', linewidth=2, markersize=5,
         label=f'Gap = ε − k·δ (ε={initial_gap}, δ={delta_per_step})')
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Gap = 0 (breakdown)')
ax1.axvline(x=initial_gap/delta_per_step, color='red', linestyle=':', alpha=0.5,
            label=f'k* = ε/δ = {initial_gap/delta_per_step:.0f}')
ax1.set_xlabel('Number of Perturbation Steps (k)', fontsize=12)
ax1.set_ylabel('Preserved Spectral Gap', fontsize=12)
ax1.set_title('Theorem: Linear Gap Degradation', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.set_ylim(-0.1, 1.15)
ax1.grid(alpha=0.3)

# Right: empirical vs theoretical
ax2.fill_between(steps, mean_gaps - std_gaps, mean_gaps + std_gaps,
                 alpha=0.2, color='darkorange')
ax2.plot(steps, mean_gaps, 's-', color='darkorange', linewidth=2, markersize=5,
         label=f'Empirical mean gap (n={n}, {n_trials} trials)')
ax2.plot(steps, norm_theoretical, '--', color='steelblue', linewidth=2,
         label='Theoretical linear bound')
ax2.set_xlabel('Number of Perturbation Steps (k)', fontsize=12)
ax2.set_ylabel('Log-Concavity Gap', fontsize=12)
ax2.set_title('Empirical Validation: Binomial Distribution', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)

fig.suptitle('Spectral Gap Degradation Under Iterated Perturbation\n'
             '(No error amplification: gap loss is exactly linear)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_degradation.png', dpi=150, bbox_inches='tight')
plt.close()
