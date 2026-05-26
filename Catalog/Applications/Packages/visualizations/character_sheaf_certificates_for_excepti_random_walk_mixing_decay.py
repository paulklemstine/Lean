#!/usr/bin/env python3
"""
Visualization: Random Walk Mixing Decay

Shows the geometric decay of L² error for random walks on Cayley graphs
with different certified spectral radii. Demonstrates how larger q
(smaller spectral radius) leads to faster mixing.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

C = 2.0
q_values = [3, 5, 7, 11, 17, 31]
n_steps = np.arange(0, 31)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: L² error decay (log scale)
ax1 = axes[0]
colors = plt.cm.viridis(np.linspace(0, 0.9, len(q_values)))

for q, color in zip(q_values, colors):
    rho = C / q
    errors = rho ** n_steps
    label = f'q={q}, ρ={rho:.3f}'
    ax1.semilogy(n_steps, errors, '-o', color=color, markersize=3,
                 linewidth=1.5, label=label)

ax1.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε = 0.01')
ax1.axhline(y=0.001, color='darkred', linestyle='--', alpha=0.5, label='ε = 0.001')
ax1.set_xlabel('Number of steps n', fontsize=12)
ax1.set_ylabel('L² error bound ρⁿ', fontsize=12)
ax1.set_title('Geometric Mixing Decay\n(C = 2, varying q)', fontsize=13)
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-15, 1.5)

# Plot 2: Mixing time vs q
ax2 = axes[1]
q_range = np.arange(3, 101)
epsilons = [0.1, 0.01, 0.001, 1e-6]
styles = ['-', '--', '-.', ':']

for eps, style in zip(epsilons, styles):
    mixing_times = []
    for q in q_range:
        rho = C / q
        if rho < 1 and rho > 0:
            t = np.ceil(np.log(1/eps) / np.log(1/rho))
        else:
            t = np.nan
        mixing_times.append(t)
    ax2.plot(q_range, mixing_times, style, linewidth=2,
             label=f'ε = {eps}')

ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Mixing time (steps)', fontsize=12)
ax2.set_title('Mixing Time vs Field Size\n(steps to reach L² error ε)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_decay_plot.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved mixing_decay_plot.png")
