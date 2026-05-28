"""
Visualization: Universality Collapse of Tropical Margin

This script visualizes the central prediction of tropical threshold universality:
after rescaling by √(log n), the probability curves P(tropMargin ≥ 0) collapse
for sub-Gaussian ensembles but not for heavy-tailed distributions.

The plot shows empirical transition curves for Gaussian, Rademacher, Uniform,
Exponential (all sub-Gaussian) and Cauchy (heavy-tailed counterexample).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = 2.0 * W[i, j] - W[i, i] - W[j, j]
                if s < margin:
                    margin = s
    return margin


def generate_noise(n, ensemble, rng):
    if ensemble == 'Gaussian':
        return rng.standard_normal((n, n))
    elif ensemble == 'Rademacher':
        return rng.choice([-1.0, 1.0], size=(n, n))
    elif ensemble == 'Uniform':
        return rng.uniform(-np.sqrt(3), np.sqrt(3), (n, n))
    elif ensemble == 'Exponential':
        return rng.exponential(1.0, (n, n)) - 1.0
    elif ensemble == 'Cauchy':
        return rng.standard_cauchy((n, n))


def run_universality_test(n, ensembles, scaled_strengths, num_trials, seed=42):
    rng = np.random.default_rng(seed)
    scale = np.sqrt(np.log(n))
    results = {}
    
    for ens in ensembles:
        probs = []
        for s in scaled_strengths:
            signal = s * scale
            S = np.full((n, n), signal / 2.0)
            np.fill_diagonal(S, 0.0)
            count = 0
            for _ in range(num_trials):
                N = generate_noise(n, ens, rng)
                if trop_margin(S + N) >= 0:
                    count += 1
            probs.append(count / num_trials)
        results[ens] = np.array(probs)
    
    return results


# Parameters
n = 8
ensembles = ['Gaussian', 'Rademacher', 'Uniform', 'Exponential', 'Cauchy']
scaled_strengths = np.linspace(-1, 8, 20)
num_trials = 300

results = run_universality_test(n, ensembles, scaled_strengths, num_trials)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = {
    'Gaussian': '#2196F3',
    'Rademacher': '#4CAF50', 
    'Uniform': '#FF9800',
    'Exponential': '#9C27B0',
    'Cauchy': '#F44336'
}

markers = {
    'Gaussian': 'o',
    'Rademacher': 's',
    'Uniform': '^',
    'Exponential': 'D',
    'Cauchy': 'x'
}

# Left panel: all ensembles
for ens in ensembles:
    ax1.plot(scaled_strengths, results[ens], 
             color=colors[ens], marker=markers[ens], markersize=5,
             linewidth=2, label=ens, alpha=0.85)

ax1.set_xlabel('Scaled signal strength (s / √log n)', fontsize=13)
ax1.set_ylabel('P(tropMargin ≥ 0)', fontsize=13)
ax1.set_title(f'Tropical Margin Phase Transition (n={n})', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, framealpha=0.9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.05)
ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

# Right panel: sub-Gaussian only (collapse region)
sub_gaussian = ['Gaussian', 'Rademacher', 'Uniform', 'Exponential']
for ens in sub_gaussian:
    ax2.plot(scaled_strengths, results[ens],
             color=colors[ens], marker=markers[ens], markersize=5,
             linewidth=2, label=ens, alpha=0.85)

# Add Cauchy as faded background
ax2.plot(scaled_strengths, results['Cauchy'],
         color=colors['Cauchy'], marker=markers['Cauchy'], markersize=4,
         linewidth=1.5, label='Cauchy (non-universal)', alpha=0.4, linestyle='--')

ax2.set_xlabel('Scaled signal strength (s / √log n)', fontsize=13)
ax2.set_ylabel('P(tropMargin ≥ 0)', fontsize=13)
ax2.set_title('Sub-Gaussian Universality Collapse', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, framealpha=0.9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)
ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('universality_collapse.png', dpi=150, bbox_inches='tight')
print("Saved: universality_collapse.png")
