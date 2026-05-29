#!/usr/bin/env python3
"""
Visualization: Exponential Soundness Amplification

Visualizes how repeated independent audits exponentially decrease the probability
that a defective proof certificate passes verification. Shows theoretical bounds
(1-ε)^k alongside empirical measurements for various defect densities.

This is the core visual demonstration of Theorem 3 (repeated_audit_accept_count_le_pow):
the number of all-accepting challenge sequences decays exponentially with the number
of audit rounds.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ── Self-contained certificate simulation ──

def generate_certificate(n_steps, n_vars=5, seed=42):
    """Generate a synthetic proof certificate."""
    rng = random.Random(seed)
    valid = [True] * n_steps
    deps = []
    for i in range(n_steps):
        nd = rng.randint(0, min(2, i))
        deps.append(sorted(rng.sample(range(i), nd)) if i > 0 and nd > 0 else [])
    return valid, deps

def corrupt(valid, num_corrupt, seed=42):
    """Corrupt a certificate by marking random steps as invalid."""
    rng = random.Random(seed)
    n = len(valid)
    corrupted = list(valid)
    indices = rng.sample(range(n), min(num_corrupt, n))
    for i in indices:
        corrupted[i] = False
    return corrupted

def repeated_audit_trial(valid, k, rng):
    """Single trial of k-round audit. Returns True if all rounds accept."""
    n = len(valid)
    return all(valid[rng.randrange(n)] for _ in range(k))

# ── Generate data ──

n_steps = 50
valid_base, deps = generate_certificate(n_steps)
defect_densities = [0.05, 0.10, 0.20, 0.35, 0.50]
k_values = np.arange(1, 31)
num_trials = 20000

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: log-scale acceptance probability vs rounds
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(defect_densities)))

for idx, density in enumerate(defect_densities):
    num_corrupt = max(1, int(n_steps * density))
    corrupted = corrupt(valid_base, num_corrupt, seed=idx * 100)
    actual_density = sum(1 for v in corrupted if not v) / n_steps
    accept_prob_single = 1 - actual_density

    # Theoretical curve
    theoretical = [accept_prob_single ** k for k in k_values]
    ax1.plot(k_values, theoretical, '-', color=colors[idx], linewidth=2,
             label=f'δ={actual_density:.2f} (theory)')

    # Empirical points
    rng = random.Random(42 + idx)
    empirical = []
    for k in k_values:
        accepts = sum(1 for _ in range(num_trials)
                      if repeated_audit_trial(corrupted, k, rng))
        empirical.append(accepts / num_trials)
    ax1.scatter(k_values[::3], [empirical[i] for i in range(0, len(k_values), 3)],
                color=colors[idx], s=40, zorder=5, edgecolors='white', linewidth=0.5)

ax1.set_yscale('log')
ax1.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax1.set_ylabel('Acceptance Probability', fontsize=12)
ax1.set_title('Exponential Soundness Amplification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.set_ylim(1e-6, 1.1)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 31)

# Right panel: rounds needed for target confidence
target_confidences = [0.90, 0.95, 0.99, 0.999]
density_range = np.linspace(0.01, 0.5, 100)

for conf in target_confidences:
    rounds_needed = [np.log(1 - conf) / np.log(1 - d) for d in density_range]
    ax2.plot(density_range, rounds_needed, linewidth=2,
             label=f'{conf:.1%} confidence')

ax2.set_xlabel('Defect Density (δ)', fontsize=12)
ax2.set_ylabel('Audit Rounds Needed', fontsize=12)
ax2.set_title('Rounds for Target Confidence', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 0.5)
ax2.set_ylim(0, 100)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplification.png")
