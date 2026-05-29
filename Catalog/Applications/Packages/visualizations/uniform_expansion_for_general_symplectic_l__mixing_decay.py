#!/usr/bin/env python3
"""
Visualization: L² Mixing Decay for Symplectic Random Walks

Shows the geometric convergence of random walks on Cayley graphs
of Sp_{2n}(F_q). The contraction factor (1-gap)^k decays exponentially,
with the rate controlled by the character-ratio constant C_n.

This illustrates the automorphic spectral decay: the finite analog
of Hecke operator decay on Siegel modular form spaces.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: L² decay curves for different ranks at fixed q
ax1 = axes[0]
q = 23
max_steps = 60
steps = np.arange(0, max_steps + 1)

for n in [1, 2, 3, 5, 8]:
    C_n = n + 1
    gap = 1 - C_n / q
    if gap > 0:
        contraction = (1 - gap) ** steps
        ax1.semilogy(steps, contraction, '-', linewidth=2, label=f'n={n}, gap={gap:.3f}')

ax1.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε = 0.01')
ax1.set_xlabel('Steps k', fontsize=11)
ax1.set_ylabel('Contraction (1-gap)^k', fontsize=11)
ax1.set_title(f'L² Mixing Decay (q={q})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, max_steps)
ax1.set_ylim(1e-6, 1.5)

# Plot 2: Contraction factor vs field size for rank 3
ax2 = axes[1]
n = 3
C_n = n + 1
q_range = np.arange(5, 101)
steps_list = [5, 10, 20, 50]

for k in steps_list:
    contractions = []
    for q_val in q_range:
        gap = max(0, 1 - C_n / q_val)
        contractions.append((1 - gap) ** k if gap > 0 else 1.0)
    ax2.plot(q_range, contractions, '-', linewidth=2, label=f'k={k} steps')

ax2.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε = 0.01')
ax2.set_xlabel('Field size q', fontsize=11)
ax2.set_ylabel(f'Contraction after k steps', fontsize=11)
ax2.set_title(f'Mixing vs Field Size (n={n})', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)

# Plot 3: Phase diagram — sufficient steps for ε-mixing
ax3 = axes[2]
eps = 0.01

# For each (n, q), compute mixing time
ranks = range(1, 12)
q_vals = range(5, 80)

mixing_grid = np.zeros((len(list(ranks)), len(list(q_vals))))
ranks_list = list(ranks)
q_vals_list = list(q_vals)

for i, n_val in enumerate(ranks_list):
    C = n_val + 1
    for j, q_val in enumerate(q_vals_list):
        gap = 1 - C / q_val
        if gap > 0.001:
            contraction = 1 - gap
            mt = math.ceil(math.log(1.0 / eps) / math.log(1.0 / contraction))
            mixing_grid[i, j] = min(mt, 500)
        else:
            mixing_grid[i, j] = 500  # Very large / undefined

im = ax3.imshow(mixing_grid, aspect='auto', cmap='plasma_r', origin='lower',
                vmin=1, vmax=200, interpolation='bilinear')
# Label axes
x_ticks = range(0, len(q_vals_list), 10)
ax3.set_xticks(list(x_ticks))
ax3.set_xticklabels([q_vals_list[i] for i in x_ticks])
ax3.set_yticks(range(len(ranks_list)))
ax3.set_yticklabels(ranks_list)
ax3.set_xlabel('Field size q', fontsize=11)
ax3.set_ylabel('Rank n', fontsize=11)
ax3.set_title('Mixing Time Phase Diagram', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax3, shrink=0.8, label='Steps to ε=0.01')

# Draw the critical line n+1 = q (below this, no expansion)
critical_n = [q_val - 1 for q_val in q_vals_list]
critical_j = list(range(len(q_vals_list)))
# Map critical_n to row indices
critical_rows = [(cn - ranks_list[0]) for cn in critical_n]
valid = [(j, r) for j, r in zip(critical_j, critical_rows)
         if 0 <= r < len(ranks_list)]
if valid:
    ax3.plot([v[0] for v in valid], [v[1] for v in valid],
             'w--', linewidth=2, alpha=0.8, label='n+1=q boundary')
    ax3.legend(fontsize=8, loc='upper left')

plt.suptitle('Symplectic Random Walk Mixing: Geometric Convergence',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
print("Saved mixing_decay.png")
