#!/usr/bin/env python3
"""
Visualization: The Humor-Entropy Bound

Demonstrates the theorem: E[|X - μ|] ≤ √Var(X).

This visualization shows 5000 random probability distributions, plotting
expected surprise vs. standard deviation. The theorem guarantees all
points lie below the diagonal y = x. The gap between the cloud and the
diagonal reveals how much "slack" the bound has for typical distributions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

np.random.seed(42)

# Plot 1: Humor-Entropy bound scatter
ax = axes[0]
n_distributions = 5000
expected_surprises = []
std_devs = []

for _ in range(n_distributions):
    n = np.random.randint(2, 50)
    points = np.random.randn(n) * np.random.uniform(0.5, 10)
    weights = np.random.dirichlet(np.ones(n))

    mean = np.sum(weights * points)
    es = np.sum(weights * np.abs(points - mean))
    var = np.sum(weights * (points - mean)**2)
    sd = np.sqrt(var)

    expected_surprises.append(es)
    std_devs.append(sd)

es_arr = np.array(expected_surprises)
sd_arr = np.array(std_devs)
ratios = es_arr / np.maximum(sd_arr, 1e-10)

ax.scatter(sd_arr, es_arr, c=ratios, cmap='viridis', s=5, alpha=0.5)
max_val = max(max(sd_arr), max(es_arr)) * 1.05
ax.plot([0, max_val], [0, max_val], 'r-', linewidth=2, label='E[|X-μ|] = √Var')
ax.set_xlabel('Standard Deviation (√Var)')
ax.set_ylabel('Expected Surprise E[|X-μ|]')
ax.set_title('Humor-Entropy Bound\n(5000 random distributions)')
ax.legend()
ax.set_xlim(0, max_val)
ax.set_ylim(0, max_val)

# Add annotation for the bound
ax.annotate('All points below\nthe diagonal ✓',
           xy=(max_val * 0.4, max_val * 0.3),
           fontsize=11, color='red',
           ha='center')

# Plot 2: Distribution of ratios E[|X-μ|] / √Var
ax = axes[1]
ax.hist(ratios, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
ax.axvline(x=1.0, color='red', linewidth=2, linestyle='--', label='Bound (ratio = 1)')
ax.axvline(x=np.mean(ratios), color='green', linewidth=2, linestyle='-',
           label=f'Mean ratio = {np.mean(ratios):.3f}')
ax.set_xlabel('Ratio E[|X-μ|] / √Var')
ax.set_ylabel('Count')
ax.set_title(f'Distribution of Bound Tightness\n(max ratio = {max(ratios):.4f})')
ax.legend()

# Plot 3: Escalating comedy sequences
ax = axes[2]
n_steps = 20
sequences = {
    'Linear': np.arange(1, n_steps + 1, dtype=float),
    'Quadratic': np.arange(1, n_steps + 1, dtype=float)**2 / n_steps,
    'Logarithmic': np.log(np.arange(1, n_steps + 1, dtype=float) + 1),
    'Exponential': 1.5**np.arange(n_steps) / 10,
}

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for (name, seq), color in zip(sequences.items(), colors):
    cumulative = np.cumsum(seq)
    lower_bound = np.arange(1, n_steps + 1) * seq[0]
    ax.plot(range(1, n_steps + 1), cumulative, '-', color=color,
            linewidth=2, label=f'{name} (total)')
    ax.plot(range(1, n_steps + 1), lower_bound, '--', color=color,
            linewidth=1, alpha=0.5)

ax.set_xlabel('Number of Jokes')
ax.set_ylabel('Cumulative Humor')
ax.set_title('Escalating Comedy Sequences\n(solid = actual, dashed = n·h₀ bound)')
ax.legend(fontsize=9)

plt.tight_layout()
plt.savefig('humor_entropy.png', dpi=150, bbox_inches='tight')
print("Saved humor_entropy.png")
