#!/usr/bin/env python3
"""
Demo 1: Oracle Phase Transition (Direction A1)

Simulates random oracles on finite sets and demonstrates the phase transition
at p_c = 1/2. For a random oracle on {0, 1, ..., n-1}, each element is
independently "fixed" (O(x) = x) with probability p. The fraction of fixed
points |Fix(O)|/n concentrates around p, with a sharp sigmoid transition
at p = 1/2 that sharpens as n grows.

This is analogous to percolation thresholds and the 3-SAT phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

np.random.seed(42)

def simulate_random_oracle(n, p, num_trials=1000):
    """Simulate random oracles and return fixed-point fractions."""
    fractions = []
    for _ in range(num_trials):
        # Each element fixed with probability p
        fixed = np.random.binomial(1, p, size=n)
        fractions.append(np.sum(fixed) / n)
    return np.array(fractions)

def oracle_majority_probability(n, p, num_trials=5000):
    """Probability that |Fix(O)| > n/2 (oracle is 'mostly truth')."""
    count = 0
    for _ in range(num_trials):
        fixed = np.random.binomial(1, p, size=n)
        if np.sum(fixed) > n / 2:
            count += 1
    return count / num_trials

# ─── Figure 1: Phase Transition Sigmoid ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
p_values = np.linspace(0, 1, 50)

for n, color, marker in [(50, '#2196F3', 'o'), (200, '#FF9800', 's'),
                          (1000, '#4CAF50', '^'), (5000, '#E91E63', 'D')]:
    probs = [oracle_majority_probability(n, p, num_trials=2000) for p in p_values]
    ax1.plot(p_values, probs, f'-{marker}', color=color, label=f'n = {n}',
             markersize=4, linewidth=1.5, alpha=0.8)

ax1.axvline(x=0.5, color='red', linestyle='--', alpha=0.5, label='$p_c = 1/2$')
ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
ax1.set_xlabel('Fixing probability p', fontsize=12)
ax1.set_ylabel('P(oracle is "mostly truth")', fontsize=12)
ax1.set_title('Oracle Phase Transition\nP(|Fix(O)| > n/2) vs. p', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ─── Figure 2: Fixed-Point Density Distribution ───
ax2 = fig.add_subplot(gs[0, 1])
n = 500

for p, color in [(0.2, '#2196F3'), (0.4, '#FF9800'), (0.5, '#E91E63'),
                  (0.6, '#4CAF50'), (0.8, '#9C27B0')]:
    fracs = simulate_random_oracle(n, p, num_trials=3000)
    ax2.hist(fracs, bins=40, alpha=0.5, color=color, label=f'p = {p}',
             density=True, edgecolor='white', linewidth=0.5)

ax2.set_xlabel('Truth density ρ = |Fix(O)|/n', fontsize=12)
ax2.set_ylabel('Probability density', fontsize=12)
ax2.set_title(f'Distribution of Truth Density (n = {n})', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# ─── Figure 3: Variance Collapse ───
ax3 = fig.add_subplot(gs[1, 0])
n_values = np.logspace(1, 4, 30, dtype=int)
p_fixed = 0.5

variances = []
theoretical_var = []
for n in n_values:
    fracs = simulate_random_oracle(n, p_fixed, num_trials=1000)
    variances.append(np.var(fracs))
    theoretical_var.append(p_fixed * (1 - p_fixed) / n)

ax3.loglog(n_values, variances, 'o-', color='#2196F3', label='Simulated Var(ρ)',
           markersize=5, linewidth=1.5)
ax3.loglog(n_values, theoretical_var, '--', color='#E91E63',
           label='Theory: p(1-p)/n', linewidth=2)
ax3.set_xlabel('System size n', fontsize=12)
ax3.set_ylabel('Var(ρ)', fontsize=12)
ax3.set_title('Variance Collapse at Criticality (p = 0.5)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# ─── Figure 4: Phase Diagram ───
ax4 = fig.add_subplot(gs[1, 1])
n_grid = np.array([50, 100, 200, 500, 1000])
p_grid = np.linspace(0.1, 0.9, 30)

phase_map = np.zeros((len(n_grid), len(p_grid)))
for i, n in enumerate(n_grid):
    for j, p in enumerate(p_grid):
        phase_map[i, j] = oracle_majority_probability(n, p, num_trials=1000)

im = ax4.imshow(phase_map, extent=[0.1, 0.9, 0, len(n_grid)-1],
                aspect='auto', cmap='RdYlBu_r', origin='lower', vmin=0, vmax=1)
ax4.set_yticks(range(len(n_grid)))
ax4.set_yticklabels(n_grid)
ax4.set_xlabel('Fixing probability p', fontsize=12)
ax4.set_ylabel('System size n', fontsize=12)
ax4.set_title('Oracle Phase Diagram', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax4, label='P(mostly truth)')

fig.suptitle('Direction A1: Oracle Phase Transition Conjecture',
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig1_oracle_phase_transition.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 1 saved: fig1_oracle_phase_transition.png")

# ─── Figure 5: Critical Fluctuations ───
fig2, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax, (p, label) in zip(axes, [(0.3, 'Subcritical (p=0.3)'),
                                   (0.5, 'Critical (p=0.5)'),
                                   (0.7, 'Supercritical (p=0.7)')]):
    n = 100
    # Show 10 random oracle realizations as binary images
    oracles = np.random.binomial(1, p, size=(10, 10))
    ax.imshow(oracles, cmap='coolwarm', interpolation='nearest', vmin=0, vmax=1)
    ax.set_title(label, fontsize=12, fontweight='bold')
    ax.set_xlabel(f'Fix density: {oracles.mean():.2f}')
    ax.set_xticks([])
    ax.set_yticks([])

fig2.suptitle('Oracle Realizations at Different Phases (10×10 grid)',
              fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('/workspace/request-project/Research/demos/fig2_oracle_realizations.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 2 saved: fig2_oracle_realizations.png")
