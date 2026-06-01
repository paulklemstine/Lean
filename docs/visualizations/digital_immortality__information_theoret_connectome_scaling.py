#!/usr/bin/env python3
"""Visualization: Quadratic scaling of connectome description length."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def min_description_length(n, k):
    return n * n * math.log2(k)

def bekenstein_bound_bits(R, M, hbar=1.054571817e-34, c=2.998e8):
    E = M * c**2
    return 2 * math.pi * R * E / (hbar * math.log(2))

neurons = np.logspace(1, 11, 200)
k_values = [2, 8, 64, 256]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Description length vs neuron count
ax1 = axes[0]
for k, color in zip(k_values, colors):
    bits = [n**2 * math.log2(k) for n in neurons]
    ax1.loglog(neurons, bits, color=color, linewidth=2, label=f'k={k}')

bek = bekenstein_bound_bits(0.1, 1.4)
ax1.axhline(y=bek, color='purple', linestyle='--', linewidth=2,
            label=f'Bekenstein bound\n(brain-sized)')
ax1.set_xlabel('Number of Neurons (n)', fontsize=12)
ax1.set_ylabel('Minimum Description Length (bits)', fontsize=12)
ax1.set_title('Connectome Information Requirement\nvs. Neuron Count', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(10, 1e11)

# Plot 2: Compression ratio
ax2 = axes[1]
n_vals = range(2, 12)
for k, color in zip([2, 4, 8], colors[:3]):
    ratios = []
    for n in n_vals:
        total_bits = n * n * math.log2(k)
        half_bits = total_bits / 2
        ratio = 2**half_bits / k**(n*n)
        ratios.append(ratio)
    ax2.semilogy(list(n_vals), ratios, 'o-', color=color, linewidth=2,
                 markersize=6, label=f'k={k}')

ax2.set_xlabel('Number of Neurons (n)', fontsize=12)
ax2.set_ylabel('Fraction Compressible to Half Length', fontsize=12)
ax2.set_title('Incompressibility: Fraction of\nCompressible Connectomes', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('connectome_scaling.png', dpi=150, bbox_inches='tight')
print("Saved connectome_scaling.png")
