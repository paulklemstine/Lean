#!/usr/bin/env python3
"""
Visualization: Exponential Consistency Decay

Shows how the probability of database consistency decays exponentially
with the number of constraints (columns, rows, and pairs).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def consistency_probability(r, C):
    return (1.0 - r) ** C


def overlap_constraints(n_cols, n_rows):
    return n_cols * (n_cols - 1) // 2 * n_rows


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: P vs missing rate for different grid sizes
rates = np.linspace(0.01, 0.5, 200)
for n_cols, n_rows, color in [(3, 10, 'blue'), (5, 20, 'green'),
                                (8, 50, 'orange'), (10, 100, 'red')]:
    C = overlap_constraints(n_cols, n_rows)
    probs = [(1 - r) ** C for r in rates]
    log_probs = [np.log10(max(p, 1e-300)) for p in probs]
    axes[0].plot(rates, log_probs, color=color, linewidth=2,
                 label=f'{n_cols} cols, {n_rows} rows (C={C})')

axes[0].set_xlabel('Missing Rate r', fontsize=12)
axes[0].set_ylabel('log₁₀ P(consistent)', fontsize=12)
axes[0].set_title('Consistency Probability vs Rate', fontsize=14,
                  fontweight='bold')
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-50, 1)

# Plot 2: P vs number of columns (fixed rate, rows)
n_cols_range = range(2, 25)
for r, color in [(0.05, 'blue'), (0.1, 'green'), (0.2, 'orange'),
                  (0.3, 'red')]:
    n_rows = 50
    log_probs = []
    for n in n_cols_range:
        C = overlap_constraints(n, n_rows)
        p = (1 - r) ** C
        log_probs.append(np.log10(max(p, 1e-300)))
    axes[1].plot(list(n_cols_range), log_probs, color=color, linewidth=2,
                 marker='o', markersize=3, label=f'r = {r}')

axes[1].set_xlabel('Number of Columns n', fontsize=12)
axes[1].set_ylabel('log₁₀ P(consistent)', fontsize=12)
axes[1].set_title('Consistency vs Columns (50 rows)', fontsize=14,
                  fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(-200, 1)

# Plot 3: Constraint count scaling
n_range = np.arange(2, 30)
constraints_linear = n_range * 50
constraints_quadratic = n_range * (n_range - 1) // 2 * 50

axes[2].plot(n_range, constraints_linear, 'b-', linewidth=2,
             label='Linear: n × k')
axes[2].plot(n_range, constraints_quadratic, 'r-', linewidth=2,
             label='Quadratic: C(n,2) × k')
axes[2].fill_between(n_range, constraints_linear, constraints_quadratic,
                     alpha=0.15, color='red')
axes[2].set_xlabel('Number of Columns n', fontsize=12)
axes[2].set_ylabel('Constraint Count', fontsize=12)
axes[2].set_title('Overlap Constraints Scale Quadratically', fontsize=14,
                  fontweight='bold')
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

fig.suptitle('Exponential Consistency Decay in the Sheaf Model',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('consistency_decay.png', dpi=150, bbox_inches='tight')
print("Saved consistency_decay.png")
