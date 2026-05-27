#!/usr/bin/env python3
"""
Visualization: L² Contraction and Exponential Mixing

Shows the exponential decay of variance under iterated Markov steps,
demonstrating the core mixing theorem: Var(P^t f) ≤ (1-gap)^t · Var(f).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_gap(J):
    eigenvalues = np.linalg.eigvalsh(J)
    sorted_eigs = np.sort(eigenvalues)[::-1]
    return abs(sorted_eigs[1]) if len(sorted_eigs) > 1 else 0


def simulate_variance_decay(J, h, n_chains=30, max_steps=300, beta=1.0):
    """Track variance of magnetization over time."""
    n = len(h)
    chains = [np.random.randint(2, size=n) for _ in range(n_chains)]
    
    variance_over_time = []
    for t in range(max_steps):
        # One Glauber step for each chain
        for c in range(n_chains):
            site = np.random.randint(n)
            spins = 2 * chains[c].astype(float) - 1
            local_field = beta * (J[site] @ spins - J[site, site] * spins[site] + h[site])
            prob_plus = 1.0 / (1.0 + np.exp(-2 * local_field))
            chains[c][site] = int(np.random.random() < prob_plus)
        
        # Compute variance of magnetization across chains
        mags = [np.mean(2 * c.astype(float) - 1) for c in chains]
        variance_over_time.append(np.var(mags))
    
    return np.array(variance_over_time)


np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Variance decay for different coupling strengths
ax = axes[0]
n = 12
for strength, color, ls in [(0.2, 'steelblue', '-'), (0.5, 'forestgreen', '-'),
                              (0.8, 'crimson', '-')]:
    J = strength * (np.ones((n, n)) - np.eye(n)) / n
    h = np.zeros(n)
    gap = compute_gap(J)
    
    var_decay = simulate_variance_decay(J, h, n_chains=40, max_steps=200)
    steps = np.arange(len(var_decay))
    
    ax.plot(steps, var_decay, color=color, alpha=0.5, linewidth=1)
    
    # Theoretical bound
    if var_decay[0] > 0 and gap > 0:
        spectral_gap = gap / n
        theory_bound = var_decay[0] * (1 - spectral_gap) ** steps
        ax.plot(steps, theory_bound, color=color, linewidth=2, linestyle='--',
                label=f'β={strength}, ε={gap:.3f}')

ax.set_xlabel('Steps', fontsize=12)
ax.set_ylabel('Variance across chains', fontsize=12)
ax.set_title('Variance Decay\n(solid: empirical, dashed: theory)', fontsize=13)
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Log variance vs steps (should be linear)
ax = axes[1]
n = 16
J = 0.4 * (np.ones((n, n)) - np.eye(n)) / n
h = np.zeros(n)
gap = compute_gap(J)

for trial in range(5):
    var_decay = simulate_variance_decay(J, h, n_chains=50, max_steps=300)
    steps = np.arange(len(var_decay))
    log_var = np.log(var_decay + 1e-15)
    ax.plot(steps, log_var, alpha=0.3, color='steelblue', linewidth=0.8)

# Average
avg_var = np.zeros(300)
for trial in range(10):
    var_decay = simulate_variance_decay(J, h, n_chains=50, max_steps=300)
    avg_var += var_decay
avg_var /= 10
ax.plot(steps, np.log(avg_var + 1e-15), color='navy', linewidth=2,
        label='Average (10 trials)')

# Theory
spectral_gap = gap / n
theory_slope = np.log(1 - spectral_gap)
ax.plot(steps, np.log(avg_var[0] + 1e-15) + theory_slope * steps,
        color='crimson', linewidth=2, linestyle='--',
        label=f'Theory: slope={theory_slope:.4f}')

ax.set_xlabel('Steps', fontsize=12)
ax.set_ylabel('log(Variance)', fontsize=12)
ax.set_title(f'Log-Variance (n={n}, β=0.4)\nLinear decay = exponential mixing', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Contraction rate vs spectral gap
ax = axes[2]
ns = [6, 8, 10, 12, 14, 16, 18, 20]
strengths_test = [0.2, 0.4, 0.6]
markers = ['o', 's', '^']
colors_test = ['steelblue', 'forestgreen', 'crimson']

for idx, strength in enumerate(strengths_test):
    gaps_n = []
    rates_n = []
    for n_val in ns:
        J = strength * (np.ones((n_val, n_val)) - np.eye(n_val)) / n_val
        h = np.zeros(n_val)
        gap = compute_gap(J)
        
        var_decay = simulate_variance_decay(J, h, n_chains=30, max_steps=100)
        # Estimate decay rate from first 50 steps
        if var_decay[0] > 1e-10 and var_decay[49] > 1e-10:
            rate = -np.log(var_decay[49] / var_decay[0]) / 50
        else:
            rate = 0
        
        gaps_n.append(gap / n_val)
        rates_n.append(rate)
    
    ax.scatter(gaps_n, rates_n, s=60, marker=markers[idx], color=colors_test[idx],
               label=f'β={strength}', zorder=5, edgecolors='black', linewidth=0.5)

# Theory line: rate = gap
max_gap = max(max(g for g in gaps_n if g > 0) for gaps_n in [[compute_gap(s * (np.ones((n, n)) - np.eye(n)) / n) / n for n in ns] for s in strengths_test])
x_theory = np.linspace(0, max_gap * 1.2, 100)
ax.plot(x_theory, x_theory, 'k--', linewidth=1.5, label='Theory: rate = gap')

ax.set_xlabel('Spectral Gap ε/n', fontsize=12)
ax.set_ylabel('Empirical Contraction Rate', fontsize=12)
ax.set_title('Contraction Rate ≈ Spectral Gap', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lorentzian_contraction.png', dpi=150, bbox_inches='tight')
print("Saved: lorentzian_contraction.png")
