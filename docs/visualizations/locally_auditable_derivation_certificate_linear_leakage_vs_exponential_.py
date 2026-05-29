#!/usr/bin/env python3
"""
Visualization: Linear Leakage Growth vs Exponential Confidence Gain

Visualizes the fundamental asymmetry at the heart of locally auditable proofs:
information leakage grows only linearly with the number of audit rounds, while
the verifier's confidence grows exponentially. This is the visual embodiment of
Theorems 3 and 5 together.

Left panel: Leakage (fraction of proof revealed) grows linearly.
Right panel: Confidence (1 - acceptance probability for defective proofs) grows
exponentially toward 1.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ── Self-contained simulation ──

def simulate_audit_leakage(n_steps, max_dep, k_values, num_trials=2000, seed=42):
    """Simulate leakage for various round counts."""
    rng = random.Random(seed)
    # Generate random dependency sizes
    dep_sizes = [rng.randint(0, max_dep) for _ in range(n_steps)]

    results = {}
    for k in k_values:
        leakages = []
        for _ in range(num_trials):
            total = sum(1 + dep_sizes[rng.randrange(n_steps)] for _ in range(k))
            leakages.append(total)
        results[k] = {
            'mean': np.mean(leakages),
            'max': np.max(leakages),
            'min': np.min(leakages),
            'std': np.std(leakages),
            'bound': k * (1 + max_dep),
        }
    return results

# ── Parameters ──

n_steps = 100
max_dep = 3
k_values = list(range(1, 51))
defect_density = 0.15

leakage_data = simulate_audit_leakage(n_steps, max_dep, k_values)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ── Left panel: Leakage ──

means = [leakage_data[k]['mean'] / n_steps for k in k_values]
maxes = [leakage_data[k]['max'] / n_steps for k in k_values]
bounds = [leakage_data[k]['bound'] / n_steps for k in k_values]

ax1.fill_between(k_values,
                  [leakage_data[k]['mean'] / n_steps - leakage_data[k]['std'] / n_steps for k in k_values],
                  [leakage_data[k]['mean'] / n_steps + leakage_data[k]['std'] / n_steps for k in k_values],
                  alpha=0.2, color='steelblue')
ax1.plot(k_values, means, '-', color='steelblue', linewidth=2, label='Average leakage')
ax1.plot(k_values, maxes, '--', color='coral', linewidth=1.5, label='Max leakage (empirical)')
ax1.plot(k_values, bounds, '-', color='darkred', linewidth=2, label='Bound: k·(1+d)/n')

ax1.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax1.set_ylabel('Fraction of Proof Revealed', fontsize=12)
ax1.set_title('Information Leakage (Linear Growth)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 51)

# ── Right panel: Confidence vs Leakage ──

# For each k, compute both leakage fraction and confidence
leakage_fracs = [leakage_data[k]['mean'] / n_steps for k in k_values]
confidences = [1 - (1 - defect_density) ** k for k in k_values]

# Create a dual-axis plot showing the asymmetry
ax2.plot(k_values, confidences, '-', color='forestgreen', linewidth=2.5,
         label=f'Confidence (δ={defect_density})')
ax2.fill_between(k_values, 0, confidences, alpha=0.1, color='forestgreen')

ax2_twin = ax2.twinx()
ax2_twin.plot(k_values, leakage_fracs, '-', color='steelblue', linewidth=2.5,
              label='Leakage fraction')
ax2_twin.fill_between(k_values, 0, leakage_fracs, alpha=0.1, color='steelblue')

ax2.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax2.set_ylabel('Confidence (1 - accept prob)', fontsize=12, color='forestgreen')
ax2_twin.set_ylabel('Fraction of Proof Revealed', fontsize=12, color='steelblue')
ax2.set_title('Confidence vs Leakage: The Fundamental Asymmetry',
              fontsize=14, fontweight='bold')

# Annotate the sweet spot
sweet_k = 15
ax2.annotate(f'k={sweet_k}: {1-(1-defect_density)**sweet_k:.1%} confidence\n'
             f'with {leakage_data[sweet_k]["mean"]/n_steps:.0%} leakage',
             xy=(sweet_k, 1-(1-defect_density)**sweet_k),
             xytext=(sweet_k + 8, 0.5),
             fontsize=10,
             arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

ax2.set_xlim(0, 51)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, loc='center right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_leakage.png', dpi=150, bbox_inches='tight')
print("Saved viz_leakage.png")
