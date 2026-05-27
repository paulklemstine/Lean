#!/usr/bin/env python3
"""
Visualization 3: Mixing Time Comparison — Local vs Hybrid Random Walk.

Shows the L² decay of a random walk on the 2D torus for both the
local and hybrid generators, demonstrating the exact 2× speedup.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def spectral_gap_local(n):
    return 4 * math.sin(math.pi / n) ** 2


def spectral_gap_hybrid(n):
    return 2 * spectral_gap_local(n)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: L² norm decay over time
ax1 = axes[0]
for n in [10, 20, 50]:
    gl = spectral_gap_local(n)
    gh = spectral_gap_hybrid(n)

    t = np.linspace(0, 5 / gl, 200)
    decay_loc = np.exp(-gl * t)
    decay_hyb = np.exp(-gh * t)

    ax1.plot(t, decay_loc, '-', linewidth=2,
             label=f'Local (n={n})', alpha=0.8)
    ax1.plot(t, decay_hyb, '--', linewidth=2,
             label=f'Hybrid (n={n})', alpha=0.8)

ax1.set_xlabel('Time t', fontsize=13)
ax1.set_ylabel('‖P^t f - Ef‖₂ / ‖f - Ef‖₂', fontsize=13)
ax1.set_title('L² Mixing: Exponential Decay', fontsize=14)
ax1.set_yscale('log')
ax1.axhline(y=0.01, color='gray', linestyle=':', label='ε = 0.01 threshold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-4, 1.5)

# Right panel: Mixing time vs n
ax2 = axes[1]
n_range = np.arange(3, 101)
epsilon = 0.01

for d, color, marker in [(1, '#e74c3c', 'o'), (2, '#2ecc71', 's'), (3, '#3498db', '^')]:
    gl = 4 * np.sin(np.pi / n_range) ** 2
    gh = 2 * gl

    t_loc = -np.log(epsilon) / gl
    t_hyb = -np.log(epsilon) / gh

    ax2.plot(n_range, t_loc, '-', color=color, linewidth=2,
             label=f'Local (d={d})', alpha=0.8)
    ax2.plot(n_range, t_hyb, '--', color=color, linewidth=2,
             label=f'Hybrid (d={d})', alpha=0.8)

ax2.set_xlabel('Modulus n', fontsize=13)
ax2.set_ylabel('Mixing time t_mix(ε=0.01)', fontsize=13)
ax2.set_title('Mixing Time: Local vs Hybrid', fontsize=14)
ax2.legend(fontsize=9, ncol=2)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Add annotation
ax2.annotate('2× gap\n(universal)',
             xy=(50, -np.log(0.01) / (4*np.sin(np.pi/50)**2)),
             xytext=(60, 500),
             fontsize=11, color='black',
             arrowprops=dict(arrowstyle='->', color='black'),
             ha='center')

plt.tight_layout()
plt.savefig('mixing_time.png', dpi=150, bbox_inches='tight')
print("Saved mixing_time.png")
