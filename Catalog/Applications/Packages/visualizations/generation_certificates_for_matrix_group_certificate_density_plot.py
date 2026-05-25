#!/usr/bin/env python3
"""
Visualization: Certificate Density in GL_n(F_q)

Shows how Singer certificate density (fraction of matrices with irreducible
characteristic polynomial) varies across different finite fields and dimensions.
The key pattern is density ≈ 1/n, consistent with Conjecture A.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

from algorithms import certificate_density_exact

# Compute densities
data = {}
cases = [(2, 2), (2, 3), (2, 5), (2, 7), (3, 2), (3, 3)]

for n, p in cases:
    num_cert, gl_size, density = certificate_density_exact(n, p)
    data[(n, p)] = {
        'density': density,
        'n_density': n * density,
        'num_cert': num_cert,
        'gl_size': gl_size
    }

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Certificate density by group
groups = [f"GL_{n}(F_{p})" for n, p in cases]
densities = [data[(n, p)]['density'] for n, p in cases]
n_densities = [data[(n, p)]['n_density'] for n, p in cases]

colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0', '#00BCD4']
bars = ax1.bar(range(len(groups)), densities, color=colors, alpha=0.8, edgecolor='black')
ax1.set_xticks(range(len(groups)))
ax1.set_xticklabels(groups, rotation=30, ha='right')
ax1.set_ylabel('Certificate Density', fontsize=12)
ax1.set_title('Singer Certificate Density in GL_n(F_q)', fontsize=14, fontweight='bold')
ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

# Add value labels on bars
for bar, d in zip(bars, densities):
    ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.01,
             f'{d:.3f}', ha='center', va='bottom', fontsize=10)

# Add 1/n reference lines
for i, (n, p) in enumerate(cases):
    ax1.plot([i - 0.3, i + 0.3], [1/n, 1/n], 'r--', alpha=0.5, linewidth=1.5)

ax1.legend(['1/n reference'], loc='upper right')

# Plot 2: n × density (should be bounded away from 0)
bars2 = ax2.bar(range(len(groups)), n_densities, color=colors, alpha=0.8, edgecolor='black')
ax2.set_xticks(range(len(groups)))
ax2.set_xticklabels(groups, rotation=30, ha='right')
ax2.set_ylabel('n × Density', fontsize=12)
ax2.set_title('Conjecture A Test: n × Density > c_q > 0', fontsize=14, fontweight='bold')
ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='c_q = 0.5 threshold')
ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

for bar, nd in zip(bars2, n_densities):
    ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.02,
             f'{nd:.3f}', ha='center', va='bottom', fontsize=10)

ax2.legend()

plt.tight_layout()
plt.savefig('certificate_density_plot.png', dpi=150, bbox_inches='tight')
print("Saved certificate_density_plot.png")
