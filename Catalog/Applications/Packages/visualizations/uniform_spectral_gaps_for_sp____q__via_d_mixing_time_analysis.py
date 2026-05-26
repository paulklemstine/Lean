#!/usr/bin/env python3
"""
Visualization: Mixing Time and Random Walk Convergence for Sp₄(𝔽_q)

This script visualizes:
1. How the random walk error decays geometrically with step count
2. Mixing time as a function of q
3. The Diaconis-Shahshahani majorant convergence

The plots demonstrate that larger q gives faster per-step mixing
(larger spectral gap), but the group is also larger, requiring
more steps to explore. The balance gives O(q · log|G|) mixing time.
"""

import numpy as np
import matplotlib.pyplot as plt

def sp4_order(q):
    return q**4 * (q**4 - 1) * (q**2 - 1)

C = 2.0

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Walk error decay for different q
ax1 = axes[0]
steps = np.arange(0, 50)

for q, color in [(3, 'red'), (5, 'orange'), (7, 'green'),
                  (11, 'blue'), (23, 'purple')]:
    gap = 1 - C/q
    rate = 1 - gap
    error = rate ** steps
    ax1.semilogy(steps, error, '-', color=color, linewidth=2,
                 label=f'q={q}, gap={gap:.2f}')

ax1.axhline(y=0.01, color='black', linestyle='--', alpha=0.5,
            label='ε = 0.01 threshold')
ax1.set_xlabel('Number of steps k', fontsize=12)
ax1.set_ylabel('Walk error (1-gap)^k', fontsize=12)
ax1.set_title('Random Walk Error Decay', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_ylim(1e-8, 2)
ax1.grid(True, alpha=0.3)

# Plot 2: Mixing time vs q
ax2 = axes[1]
q_vals = np.arange(3, 60, 2)
mix_times = []
log_G_vals = []

for q in q_vals:
    gap = 1 - C/q
    rate = 1 - gap
    if rate > 0 and rate < 1:
        k = int(np.ceil(np.log(0.01) / np.log(rate)))
    else:
        k = 1
    mix_times.append(k)
    log_G_vals.append(np.log2(sp4_order(q)))

ax2.plot(q_vals, mix_times, 'bo-', markersize=4, linewidth=1.5,
         label='Mixing time (ε=0.01)')
ax2_twin = ax2.twinx()
ax2_twin.plot(q_vals, log_G_vals, 'r--', linewidth=1.5,
              label='log₂|G|', alpha=0.7)
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Mixing time (steps)', fontsize=12, color='blue')
ax2_twin.set_ylabel('log₂|Sp₄(𝔽_q)|', fontsize=12, color='red')
ax2.set_title('Mixing Time vs Group Size', fontsize=13)
ax2.tick_params(axis='y', labelcolor='blue')
ax2_twin.tick_params(axis='y', labelcolor='red')

lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=9, loc='center right')
ax2.grid(True, alpha=0.3)

# Plot 3: DS majorant convergence
ax3 = axes[2]

for q, color in [(3, 'red'), (7, 'green'), (13, 'blue'), (23, 'purple')]:
    alpha = C / q
    order = sp4_order(q)
    A = order / 4.0
    steps_ds = np.arange(0, 30)
    majorant = A * alpha**(2 * steps_ds)
    ax3.semilogy(steps_ds, majorant, '-', color=color, linewidth=2,
                 label=f'q={q}')

ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5,
            label='TV distance = 1')
ax3.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5,
            label='ε = 0.01')
ax3.set_xlabel('Number of steps k', fontsize=12)
ax3.set_ylabel('DS majorant (log scale)', fontsize=12)
ax3.set_title('Diaconis–Shahshahani Convergence', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_ylim(1e-15, 1e12)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: mixing_analysis.png")
