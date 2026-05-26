"""
Visualization 2: The Certificate Pipeline — From Character Bounds to Expansion

Visualizes the complete transference chain:
  Character Ratio → Spectral Radius → Spectral Gap → Cheeger Constant → Mixing Time

Shows how each step of the certified pipeline transforms the input data
into expansion guarantees, for multiple values of q.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from matplotlib.patches import FancyArrowPatch

matplotlib.rcParams['font.size'] = 11
matplotlib.rcParams['figure.figsize'] = (16, 10)

fig = plt.figure(figsize=(16, 10))
fig.suptitle('Character-Ratio Certificate Pipeline\n'
             'From Representation Theory to Certified Expansion',
             fontsize=16, fontweight='bold', y=0.98)

# Data
q_values = [3, 5, 7, 9, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
C = 2.0

max_ratios = [C/q for q in q_values]
spectral_gaps = [1 - r for r in max_ratios]
cheeger_bounds = [g/2 for g in spectral_gaps]
mixing_times = [int(np.ceil(np.log(100)/np.log(q/C))) for q in q_values]

# --- Panel 1: Waterfall showing the transformation ---
ax1 = fig.add_subplot(2, 2, 1)
x = np.arange(len(q_values))
width = 0.25

bars1 = ax1.bar(x - width, max_ratios, width, label='Max ratio C/q',
                color='#e74c3c', alpha=0.8)
bars2 = ax1.bar(x, spectral_gaps, width, label='Spectral gap 1-C/q',
                color='#3498db', alpha=0.8)
bars3 = ax1.bar(x + width, cheeger_bounds, width, label='Cheeger (1-C/q)/2',
                color='#2ecc71', alpha=0.8)

ax1.set_xlabel('q values')
ax1.set_ylabel('Value')
ax1.set_title('Pipeline Stages for Each q')
ax1.set_xticks(x[::2])
ax1.set_xticklabels([str(q) for q in q_values[::2]])
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.2, axis='y')

# --- Panel 2: Walk error decay curves ---
ax2 = fig.add_subplot(2, 2, 2)
steps = np.arange(0, 30)

for q, color in zip([3, 5, 7, 11, 23], ['#e74c3c', '#e67e22', '#f1c40f', '#3498db', '#2ecc71']):
    rho = C / q
    decay = rho ** steps
    ax2.semilogy(steps, decay, '-', linewidth=2, color=color, label=f'q={q}')

ax2.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax2.set_xlabel('Random Walk Steps')
ax2.set_ylabel('L² Error Bound')
ax2.set_title('Geometric Mixing Decay')
ax2.legend(fontsize=9, ncol=2)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1e-6, 1.5)

# --- Panel 3: Certificate composition ---
ax3 = fig.add_subplot(2, 2, 3)

torus_data = {
    'Split': 1.2,
    'Long': 1.5,
    'Short': 1.8,
    'Coxeter': 0.9,
    'Mixed': 1.1,
}
q_range = np.arange(3, 30)

for name, scale in torus_data.items():
    per_torus_ratio = scale / q_range
    ax3.plot(q_range, per_torus_ratio, 'o-', markersize=3, linewidth=1.5,
             label=f'{name} (c={scale})')

# Global bound (max over torus types)
global_ratio = max(torus_data.values()) / q_range
ax3.plot(q_range, global_ratio, 'k--', linewidth=2.5, label='Global max (certificate)')
ax3.axhline(y=0.5, color='red', linestyle=':', alpha=0.4, label='Expansion threshold')

ax3.set_xlabel('q (field size)')
ax3.set_ylabel('Per-Torus Character Ratio')
ax3.set_title('Torus-Type Decomposition')
ax3.legend(fontsize=8, ncol=2)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 0.7)

# --- Panel 4: Comparison across exceptional groups ---
ax4 = fig.add_subplot(2, 2, 4)

# Hypothetical constants for exceptional groups
exceptional_data = {
    'G₂': {'C': 2.0, 'torus_types': 5, 'rank': 2},
    'F₄': {'C': 3.5, 'torus_types': 25, 'rank': 4},
    'E₆': {'C': 4.0, 'torus_types': 25, 'rank': 6},
    'E₇': {'C': 5.0, 'torus_types': 60, 'rank': 7},
    'E₈': {'C': 6.0, 'torus_types': 112, 'rank': 8},
}

q_for_comparison = np.arange(3, 40)
colors_exc = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']

for (name, data), color in zip(exceptional_data.items(), colors_exc):
    gap = 1 - data['C'] / q_for_comparison
    gap = np.maximum(gap, 0)
    ax4.plot(q_for_comparison, gap, '-', linewidth=2, color=color,
             label=f"{name} (C={data['C']}, T={data['torus_types']})")

ax4.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
ax4.set_xlabel('q (field size)')
ax4.set_ylabel('Certified Spectral Gap')
ax4.set_title('Exceptional Group Family Comparison')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(-0.1, 1.05)

plt.tight_layout()
plt.savefig('viz_certificate_pipeline.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_pipeline.png")
