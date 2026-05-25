#!/usr/bin/env python3
"""
Visualization: Entropy-Energy Competition

Shows the decomposition of the effective free energy
Φ = log(N) - 2·log(D_min) into its entropy and energy components.

The crossing point where entropy equals energy marks the phase
transition. This visualization makes the statistical mechanics
analogy concrete: the competition between the number of defect
states (entropy) and the cost of each defect (energy) determines
whether random generation succeeds or fails.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def maximal_subgroup_indices_Sn(n):
    indices = []
    if n >= 2:
        indices.append(2)
    for k in range(1, n // 2 + 1):
        indices.append(math.comb(n, k))
    for k in range(2, n):
        if n % k == 0:
            m_val = n // k
            idx = math.factorial(n) // (math.factorial(k) ** m_val * math.factorial(m_val))
            if idx > 1:
                indices.append(idx)
    return sorted(set(indices))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Entropy vs Energy for S_k as k varies
ax1 = axes[0]
k_vals = range(2, 15)
entropies = []
energies = []

for k in k_vals:
    indices = maximal_subgroup_indices_Sn(k)
    n_subs = len(indices)
    min_idx = min(indices) if indices else 1
    entropy = math.log(n_subs) if n_subs > 0 else 0
    energy = 2 * math.log(min_idx)
    entropies.append(entropy)
    energies.append(energy)

ax1.plot(list(k_vals), entropies, 'b-o', label='Entropy = log(N)', markersize=5)
ax1.plot(list(k_vals), energies, 'r-s', label='Energy = 2·log(D_min)', markersize=5)
ax1.fill_between(list(k_vals), entropies, energies, 
                 where=[e > en for e, en in zip(entropies, energies)],
                 alpha=0.2, color='blue', label='Entropy > Energy')
ax1.fill_between(list(k_vals), entropies, energies,
                 where=[e <= en for e, en in zip(entropies, energies)],
                 alpha=0.2, color='red', label='Energy > Entropy')
ax1.set_xlabel('Block size k', fontsize=11)
ax1.set_ylabel('Value', fontsize=11)
ax1.set_title('S_k: Entropy vs Energy', fontsize=12)
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Effective Φ for S_k^m vs m, different k
ax2 = axes[1]
m_vals = range(1, 25)

for k in [2, 3, 4, 5, 7]:
    indices = maximal_subgroup_indices_Sn(k)
    n_subs_base = len(indices)
    min_idx = min(indices) if indices else 1
    phis = []
    for m in m_vals:
        total_subs = m * n_subs_base
        entropy = math.log(total_subs) if total_subs > 0 else 0
        energy = 2 * math.log(min_idx)
        phis.append(entropy - energy)
    ax2.plot(list(m_vals), phis, '-o', markersize=3, label=f'k={k}')

ax2.axhline(y=0, color='black', linestyle='--', linewidth=1.5)
ax2.set_xlabel('Number of blocks m', fontsize=11)
ax2.set_ylabel('Effective Φ = log(N) - 2·log(D_min)', fontsize=11)
ax2.set_title('Phase Indicator Φ vs Block Count', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.annotate('Entropy\ndominates', xy=(18, 3), fontsize=10, color='red')
ax2.annotate('Energy\ndominates', xy=(3, -2), fontsize=10, color='blue')

# Panel 3: Pressure decomposition bar chart for selected (k,m) pairs
ax3 = axes[2]
cases = [(2, 4), (3, 3), (4, 2), (5, 2), (3, 6), (6, 1)]
x_pos = range(len(cases))
pressures = []
labels = []

for k, m in cases:
    indices = maximal_subgroup_indices_Sn(k)
    p = m * sum(1.0 / idx**2 for idx in indices)
    pressures.append(p)
    labels.append(f'S_{k}^{m}')

colors_bar = ['red' if p > 1 else 'orange' if p > 0.5 else 'green' 
              for p in pressures]
bars = ax3.bar(x_pos, pressures, color=colors_bar, alpha=0.7, edgecolor='black')
ax3.axhline(y=1.0, color='black', linestyle='--', linewidth=1.5, label='Transition')
ax3.set_xticks(list(x_pos))
ax3.set_xticklabels(labels, fontsize=10)
ax3.set_ylabel('Pressure', fontsize=11)
ax3.set_title('Pressure for Selected Groups', fontsize=12)
ax3.legend(fontsize=9)

# Add value labels on bars
for bar, p in zip(bars, pressures):
    ax3.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.02,
             f'{p:.3f}', ha='center', va='bottom', fontsize=8)

plt.tight_layout()
plt.savefig('entropy_energy.png', dpi=150, bbox_inches='tight')
print("Saved entropy_energy.png")
