#!/usr/bin/env python3
"""
Visualization: The Full Transference Pipeline

This script creates a comprehensive visualization of the complete
pipeline from Deligne-Lusztig character bounds to applications:

  Character Ratio → Spectral Gap → Cheeger Constant → Applications

It shows how each transformation preserves quantitative information
and how the bounds improve uniformly as q grows.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

C = 2.0

def sp4_order(q):
    return q**4 * (q**4 - 1) * (q**2 - 1)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Pipeline overview as heatmap
ax = axes[0, 0]
q_vals = [3, 5, 7, 9, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
quantities = ['C/q ratio', 'Spectral gap', 'Cheeger h', 'Code dist']

data = np.zeros((len(quantities), len(q_vals)))
for j, q in enumerate(q_vals):
    ratio = C / q
    gap = 1 - ratio
    cheeger = gap / 2
    code = cheeger / 8
    data[0, j] = ratio
    data[1, j] = gap
    data[2, j] = cheeger
    data[3, j] = code

im = ax.imshow(data, aspect='auto', cmap='RdYlGn',
               vmin=0, vmax=1)
ax.set_xticks(range(len(q_vals)))
ax.set_xticklabels(q_vals, fontsize=8)
ax.set_yticks(range(len(quantities)))
ax.set_yticklabels(quantities, fontsize=10)
ax.set_xlabel('Field size q', fontsize=11)
ax.set_title('Transference Pipeline: All Bounds vs q', fontsize=13)
plt.colorbar(im, ax=ax, shrink=0.8)

# Add text annotations
for i in range(len(quantities)):
    for j in range(len(q_vals)):
        val = data[i, j]
        color = 'white' if val < 0.3 or val > 0.7 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=6, color=color)

# Top-right: Quasirandomness dimension growth
ax = axes[0, 1]
q_range = np.arange(3, 50)
min_dims = (q_range**2 - 1) // 2
group_orders = [sp4_order(q) for q in q_range]
num_irreps = [go // (md**2) if md > 0 else go for go, md in zip(group_orders, min_dims)]

ax.semilogy(q_range, min_dims, 'b-', linewidth=2, label='Min irrep dim (q²-1)/2')
ax.semilogy(q_range, group_orders, 'r-', linewidth=2, label='|Sp₄(𝔽_q)|')
ax.semilogy(q_range, num_irreps, 'g--', linewidth=2, label='Max #irreps')

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Value (log scale)', fontsize=12)
ax.set_title('Quasirandomness: Dimension Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-left: Gap quality comparison
ax = axes[1, 0]
q_range = np.arange(3, 100)
gaps_C1 = 1 - 1.0 / q_range
gaps_C2 = 1 - 2.0 / q_range
gaps_C4 = 1 - 4.0 / q_range
gaps_C_half = 1 - 0.5 / q_range

ax.plot(q_range, gaps_C_half, '-', color='darkgreen', linewidth=2, label='C = 0.5')
ax.plot(q_range, gaps_C1, '-', color='green', linewidth=2, label='C = 1')
ax.plot(q_range, gaps_C2, '-', color='blue', linewidth=2, label='C = 2 (predicted)')
ax.plot(q_range, gaps_C4, '-', color='red', linewidth=2, label='C = 4')
ax.axhline(y=1/3, color='gray', linestyle=':', alpha=0.7,
           label='ε₀ = 1/3 threshold')
ax.fill_between(q_range, 0, gaps_C2, alpha=0.08, color='blue')

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Spectral gap lower bound', fontsize=12)
ax.set_title('Gap Sensitivity to Constant C', fontsize=13)
ax.legend(fontsize=9, loc='lower right')
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

# Bottom-right: Application summary
ax = axes[1, 1]
q_vals_app = np.array([3, 5, 7, 11, 17, 23, 31, 41])

code_dists = []
mix_times = []
ham_gaps = []

for q in q_vals_app:
    gap = 1 - C/q
    cheeger = gap / 2
    order = sp4_order(q)
    code_dists.append(cheeger * order / 8)
    rate = 1 - gap
    if rate > 0 and rate < 1:
        mix_times.append(np.log(0.01) / np.log(rate))
    else:
        mix_times.append(1)
    ham_gaps.append(gap)

x = np.arange(len(q_vals_app))
width = 0.25

bars1 = ax.bar(x - width, [g for g in ham_gaps], width,
               label='Hamiltonian gap', color='steelblue', alpha=0.8)
bars2 = ax.bar(x, [mt / max(mix_times) for mt in mix_times], width,
               label='Norm. mixing time', color='coral', alpha=0.8)
bars3 = ax.bar(x + width, [cd / max(code_dists) for cd in code_dists], width,
               label='Norm. code distance', color='mediumseagreen', alpha=0.8)

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Normalized value', fontsize=12)
ax.set_title('Cross-Domain Applications', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels(q_vals_app)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('pipeline_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: pipeline_analysis.png")
