import math
"""
Visualization: Mixing Time Scaling — Theory vs Empirical

Shows how mixing time of Glauber dynamics scales with state space size
and preserved spectral gap, validating the bound t_mix ≤ (1/γ) log(N/η).
Tests the dimension-free mixing conjecture for matroid distributions.
"""

import numpy as np
import matplotlib.pyplot as plt

def binomial_coeffs(n):
    c = np.array([float(math.comb(n, k)) for k in range(n+1)])
    c /= c.sum()
    return c

def estimate_gap(coeffs):
    n = len(coeffs)
    if n < 3:
        return 0.0
    min_g = float('inf')
    for k in range(1, n-1):
        if coeffs[k-1] > 1e-15 and coeffs[k+1] > 1e-15 and coeffs[k] > 1e-15:
            r = coeffs[k]**2 / (coeffs[k-1] * coeffs[k+1])
            min_g = min(min_g, r - 1.0)
    return max(min_g, 0.0)

def glauber_step(state, coeffs, rng):
    n = len(coeffs) - 1
    if state == 0:
        proposal = 1
    elif state == n:
        proposal = n - 1
    else:
        proposal = state + (1 if rng.random() < 0.5 else -1)
    if coeffs[proposal] > 0:
        ratio = coeffs[proposal] / max(coeffs[state], 1e-300)
        if rng.random() < min(1.0, ratio):
            return proposal
    return state

def estimate_mixing_time(coeffs, threshold=0.1, n_trials=100, max_steps=5000, rng=None):
    if rng is None:
        rng = np.random.default_rng()
    n = len(coeffs) - 1
    chains = [0] * n_trials
    for t in range(1, max_steps + 1):
        chains = [glauber_step(s, coeffs, rng) for s in chains]
        if t % 5 == 0:  # check periodically
            counts = np.zeros(n + 1)
            for s in chains:
                counts[s] += 1
            empirical = counts / n_trials
            tv = 0.5 * np.sum(np.abs(empirical - coeffs))
            if tv < threshold:
                return float(t)
    return float(max_steps)

rng = np.random.default_rng(2025)

# Experiment 1: Mixing time vs dimension (clean distributions)
dims = [4, 6, 8, 10, 12, 14, 16, 18]
mix_times_clean = []
predicted_clean = []
gaps_clean = []

for n in dims:
    c = binomial_coeffs(n)
    g = estimate_gap(c)
    gaps_clean.append(g)
    mt = estimate_mixing_time(c, threshold=0.12, n_trials=80, rng=rng)
    mix_times_clean.append(mt)
    predicted_clean.append((1/max(g, 1e-10)) * np.log((n+1) / 0.12))

# Experiment 2: Mixing time vs noise level (fixed dimension)
n_fixed = 10
ref = binomial_coeffs(n_fixed)
gap_ref = estimate_gap(ref)
noise_levels = np.linspace(0, 0.08, 15)
mix_times_noisy = []
preserved_gaps = []

for sigma in noise_levels:
    noisy = ref + sigma * rng.standard_normal(len(ref))
    noisy = np.maximum(noisy, 1e-10)
    noisy /= noisy.sum()
    
    cdist = np.sum(np.abs(ref - noisy))
    pg = max(gap_ref - cdist, 0.01)
    preserved_gaps.append(pg)
    
    mt = estimate_mixing_time(noisy, threshold=0.12, n_trials=80, rng=rng)
    mix_times_noisy.append(mt)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left: Mixing time vs dimension
ax1.semilogy(dims, mix_times_clean, 'o-', color='steelblue', linewidth=2,
             markersize=7, label='Empirical mixing time')
ax1.semilogy(dims, predicted_clean, 's--', color='darkorange', linewidth=2,
             markersize=7, label='Predicted: (1/gap)·log(N/η)')
log_n = [np.log(n+1) for n in dims]
scale = mix_times_clean[0] / log_n[0] if log_n[0] > 0 else 1
ax1.semilogy(dims, [scale * l for l in log_n], ':', color='green', linewidth=2,
             label='O(log N) scaling')
ax1.set_xlabel('Dimension n', fontsize=12)
ax1.set_ylabel('Mixing Time (steps)', fontsize=12)
ax1.set_title('Mixing Time vs Dimension\n(Binomial Distribution)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3, which='both')

# Right: Mixing time vs noise
ax2.plot(noise_levels, mix_times_noisy, 'o-', color='crimson', linewidth=2,
         markersize=6, label='Empirical mixing time')
ax2_twin = ax2.twinx()
ax2_twin.plot(noise_levels, preserved_gaps, 's--', color='steelblue', linewidth=2,
              markersize=6, label='Preserved gap', alpha=0.7)
ax2.set_xlabel('Noise Level σ', fontsize=12)
ax2.set_ylabel('Mixing Time (steps)', fontsize=12, color='crimson')
ax2_twin.set_ylabel('Preserved Gap', fontsize=12, color='steelblue')
ax2.set_title(f'Mixing Time vs Noise (n={n_fixed})\n'
              f'Reference gap = {gap_ref:.4f}',
              fontsize=13, fontweight='bold')
ax2.tick_params(axis='y', labelcolor='crimson')
ax2_twin.tick_params(axis='y', labelcolor='steelblue')
ax2.grid(alpha=0.3)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=9, loc='upper left')

fig.suptitle('Certified Mixing Time: Theory vs Empirical\n'
             'Dimension-Free Mixing Conjecture: t_mix ∝ log|supp| / ε_eff',
             fontsize=14, fontweight='bold', y=1.05)
plt.tight_layout()
plt.savefig('viz_mixing_time.png', dpi=150, bbox_inches='tight')
plt.close()
