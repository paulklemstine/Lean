#!/usr/bin/env python3
"""
Visualization: Lovász Local Lemma Conditions

Visualizes the LLL parameter space and avoidance probability.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import exp

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: LLL feasible region
ax1 = axes[0]
ds = np.arange(1, 51)
p_max = 1 / (np.e * (ds + 1))

ax1.semilogy(ds, p_max, 'b-', linewidth=2, label='p_max = 1/(e(d+1))')
ax1.fill_between(ds, 0, p_max, alpha=0.2, color='blue', label='LLL feasible region')
ax1.set_xlabel('d (dependency degree)', fontsize=14)
ax1.set_ylabel('p (probability bound)', fontsize=14)
ax1.set_title('Symmetric LLL: Feasible Region', fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-4, 1)

# Plot 2: Avoidance probability lower bound
ax2 = axes[1]
ns = range(1, 201)
for d in [2, 5, 10, 20]:
    p = 1 / (exp(1) * (d + 1))
    avoidance = [(1 - p) ** n for n in ns]
    x_witness = 1 / (d + 1)
    avoidance_witness = [(1 - x_witness) ** n for n in ns]
    ax2.semilogy(list(ns), avoidance_witness, linewidth=2, 
                label=f'd={d}, x=1/(d+1)')

ax2.set_xlabel('n (number of events)', fontsize=14)
ax2.set_ylabel('∏(1 - x_i) (avoidance bound)', fontsize=14)
ax2.set_title('LLL Avoidance Probability Lower Bound', fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lll_conditions.png', dpi=150, bbox_inches='tight')
print("Saved lll_conditions.png")
