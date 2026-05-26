#!/usr/bin/env python3
"""
Visualization 2: Total Variation Bound for Warm-Start Sampling

Shows the relationship between coefficient perturbation (ℓ₁ distance) and
the total variation distance between normalized distributions. Demonstrates
the proved bound TV ≤ Δ/min(Z, Z') and its tightness across different
perturbation regimes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import math


def normalize_weights(w):
    s = sum(w)
    return [x / s for x in w] if s > 0 else [0] * len(w)


def tv_distance(mu, nu):
    return 0.5 * sum(abs(a - b) for a, b in zip(mu, nu))


def l1_distance(w, wp):
    return sum(abs(a - b) for a, b in zip(w, wp))


random.seed(42)

# Generate many random experiments
n_trials = 500
n_states = 15

deltas = []
tvs = []
bounds = []
ratios = []

for _ in range(n_trials):
    w = [random.uniform(0.1, 3.0) for _ in range(n_states)]
    # Random perturbation of varying magnitude
    magnitude = random.uniform(0.01, 2.0)
    w_prime = [max(0, wi + random.uniform(-magnitude, magnitude)) for wi in w]

    Z = sum(w)
    Z_prime = sum(w_prime)
    if Z == 0 or Z_prime == 0:
        continue

    delta = l1_distance(w, w_prime)
    mu = normalize_weights(w)
    nu = normalize_weights(w_prime)
    tv = tv_distance(mu, nu)
    bound = delta / min(Z, Z_prime)

    deltas.append(delta)
    tvs.append(tv)
    bounds.append(bound)
    if bound > 1e-10:
        ratios.append(tv / bound)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: TV vs bound
ax1 = axes[0]
ax1.scatter(bounds, tvs, alpha=0.4, s=15, c='steelblue', edgecolors='none')
max_val = max(max(bounds), max(tvs)) * 1.1
ax1.plot([0, max_val], [0, max_val], 'r-', linewidth=2, label='TV = bound (equality)')
ax1.set_xlabel('Bound: Δ / min(Z, Z\')', fontsize=12)
ax1.set_ylabel('Actual TV Distance', fontsize=12)
ax1.set_title('TV Distance vs Upper Bound', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, max_val)
ax1.set_ylim(0, max_val)

# Plot 2: Tightness ratio histogram
ax2 = axes[1]
ax2.hist(ratios, bins=40, color='coral', edgecolor='black', linewidth=0.5, alpha=0.8)
ax2.axvline(x=0.5, color='blue', linestyle='--', linewidth=1.5,
            label='Ratio = 0.5 (equal Z, Z\')')
ax2.set_xlabel('Tightness Ratio (TV / Bound)', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Bound Tightness', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: TV vs perturbation magnitude
ax3 = axes[2]
scatter = ax3.scatter(deltas, tvs, c=[min(Z, Z_prime_val) for Z_prime_val
                                       in [sum([max(0, wi + random.uniform(-1, 1))
                                                for wi in [random.uniform(0.1, 3.0)
                                                           for _ in range(n_states)]])
                                           for _ in range(len(deltas))]],
                      alpha=0.5, s=15, cmap='viridis', edgecolors='none')
# Simpler: just color by index
ax3.scatter(deltas, tvs, alpha=0.4, s=15, c='forestgreen', edgecolors='none')
ax3.set_xlabel('ℓ₁ Perturbation Δ', fontsize=12)
ax3.set_ylabel('TV Distance', fontsize=12)
ax3.set_title('TV vs Perturbation Size', fontsize=13)
ax3.grid(True, alpha=0.3)

# Add regression line
if deltas:
    sorted_pairs = sorted(zip(deltas, tvs))
    # Moving average
    window = max(1, len(sorted_pairs) // 20)
    ma_x, ma_y = [], []
    for i in range(0, len(sorted_pairs) - window, window):
        chunk = sorted_pairs[i:i+window]
        ma_x.append(sum(x for x, _ in chunk) / len(chunk))
        ma_y.append(sum(y for _, y in chunk) / len(chunk))
    ax3.plot(ma_x, ma_y, 'r-', linewidth=2, label='Moving average')
    ax3.legend(fontsize=10)

plt.suptitle('Warm-Start Total Variation Bounds\n'
             f'({n_trials} trials, {n_states} states each)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tv_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_tv_bounds.png")
