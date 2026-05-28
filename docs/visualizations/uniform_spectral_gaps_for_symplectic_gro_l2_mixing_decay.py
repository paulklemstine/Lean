#!/usr/bin/env python3
"""
Visualization: L² Mixing Decay Curves

Shows the geometric decay of the L² mixing bound (1-ε)^k as a function
of walk length k, for different spectral gaps ε. This visualizes the
core content of Theorem 3: a positive spectral gap implies exponential
mixing, with the rate controlled by the gap.

The curves demonstrate that larger gaps (from better character-ratio bounds)
lead to faster mixing — the practical payoff of the certificate framework.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Decay curves for different gaps ---
ax1 = axes[0]
k_values = np.arange(0, 51)

gap_configs = [
    (0.1, '#E91E63', 'Gap ε = 0.1 (Sp₈, small q)'),
    (0.3, '#FF9800', 'Gap ε = 0.3 (Sp₆, moderate q)'),
    (0.5, '#4CAF50', 'Gap ε = 0.5 (Sp₄, moderate q)'),
    (0.7, '#2196F3', 'Gap ε = 0.7 (Sp₄, large q)'),
    (0.9, '#9C27B0', 'Gap ε = 0.9 (SL₂, large q)'),
]

for gap, color, label in gap_configs:
    decay = (1 - gap) ** k_values
    ax1.plot(k_values, decay, color=color, linewidth=2.5, label=label)

ax1.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01 threshold')
ax1.set_xlabel('Walk length k', fontsize=12)
ax1.set_ylabel('L² mixing bound (1−gap)ᵏ', fontsize=12)
ax1.set_title('Geometric Mixing Decay', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.set_yscale('log')
ax1.set_ylim(1e-4, 1.5)
ax1.grid(True, alpha=0.3)

# --- Right panel: Mixing time vs gap ---
ax2 = axes[1]
gaps = np.linspace(0.01, 0.99, 200)
epsilon_values = [0.1, 0.01, 0.001]
colors_eps = ['#2196F3', '#4CAF50', '#E91E63']

for eps, color in zip(epsilon_values, colors_eps):
    t_mix = np.ceil(np.log(1/eps) / gaps)
    ax2.plot(gaps, t_mix, color=color, linewidth=2.5,
             label=f't_mix(ε={eps})')

# Mark specific group configurations
group_points = [
    (0.1, 'Sp₈\nsmall q'),
    (0.3, 'Sp₆\nmod. q'),
    (0.5, 'Sp₄\nmod. q'),
    (0.7, 'Sp₄\nlarge q'),
]

for gap_val, name in group_points:
    t_val = np.ceil(np.log(100) / gap_val)
    ax2.annotate(name, (gap_val, t_val), fontsize=8,
                 textcoords="offset points", xytext=(15, 10),
                 arrowprops=dict(arrowstyle='->', color='gray'),
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

ax2.set_xlabel('Spectral gap ε', fontsize=12)
ax2.set_ylabel('Mixing time (steps)', fontsize=12)
ax2.set_title('Mixing Time vs Spectral Gap', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
print("Saved mixing_decay.png")
