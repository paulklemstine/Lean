#!/usr/bin/env python3
"""
Visualization: Thermal Sharpening of Tropical Margins

This script visualizes how the soft margin (finite-temperature free energy)
converges to the tropical margin (zero-temperature limit) as the inverse
temperature β increases. The certified approximation band from the
sandwich theorem is shown as a shaded region.

Key insight: The soft margin lives in a band of width log(card)/β above
the tropical margin, and this band shrinks monotonically as temperature drops.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]

def all_slacks(W):
    n = W.shape[0]
    return np.array([diag_ex_slack(W, i, j) for i in range(n) for j in range(n) if i != j])

def trop_margin(W):
    s = all_slacks(W)
    return float(np.min(s))

def soft_margin(beta, W):
    s = all_slacks(W)
    return -log_sum_exp(beta, -s)

# Generate data
np.random.seed(42)
n = 8
W = np.random.randn(n, n) * 0.5
for i in range(n):
    W[i, i] += 2.5

tm = trop_margin(W)
num_pairs = n * (n - 1)

betas = np.logspace(-0.5, 2.5, 200)
soft_margins = [soft_margin(b, W) for b in betas]
upper_bounds = [tm for _ in betas]
lower_bounds = [tm - np.log(num_pairs) / b for b in betas]

# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left panel: Margin vs β
ax = axes[0]
ax.fill_between(betas, lower_bounds, upper_bounds, alpha=0.15, color='green',
                label='Certified band: log(card)/β')
ax.plot(betas, soft_margins, 'b-', linewidth=2.5, label='Soft margin (β)')
ax.axhline(y=tm, color='red', linestyle='--', linewidth=2, label=f'Tropical margin = {tm:.3f}')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Thermal Sharpening: Soft → Tropical', fontsize=15)
ax.set_xscale('log')
ax.legend(fontsize=11, loc='lower right')
ax.grid(True, alpha=0.3)
ax.set_ylim(tm - 1.5, tm + 0.5)

# Right panel: Error vs β (log-log)
ax = axes[1]
errors = [tm - sm for sm in soft_margins]
bounds_err = [np.log(num_pairs) / b for b in betas]
ax.loglog(betas, errors, 'b-', linewidth=2.5, label='Actual error')
ax.loglog(betas, bounds_err, 'r--', linewidth=2, label='Bound: log(card)/β')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('|soft_margin - trop_margin|', fontsize=13)
ax.set_title('Approximation Error (O(1/β) decay)', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_thermal_sharpening.png', dpi=150, bbox_inches='tight')
print("Saved viz_thermal_sharpening.png")
