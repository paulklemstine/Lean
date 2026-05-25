#!/usr/bin/env python3
"""
Visualization: Ising Model Partition Function Log-Concavity

Shows how the 1D Ising model partition function coefficients (grouped by
magnetization) exhibit log-concavity at various temperatures, and how
the concavity depth relates to system parameters.
"""

import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np
from itertools import product as cart_product

matplotlib.use('Agg')


def ratio_seq(seq):
    return [seq[i+1] / seq[i] for i in range(len(seq)-1)]

def is_positive(seq, tol=1e-12):
    return all(x > tol for x in seq)

def is_log_concave(seq, tol=1e-10):
    for n in range(len(seq) - 2):
        if seq[n+1]**2 < seq[n] * seq[n+2] - tol:
            return False
    return True

def kfold_depth(seq, max_depth=20):
    if not is_positive(seq):
        return -1
    current = list(seq)
    depth = 0
    for _ in range(max_depth):
        if len(current) < 3:
            return depth + max_depth - _
        if not is_log_concave(current):
            return depth
        depth += 1
        current = ratio_seq(current)
        if not is_positive(current):
            return depth
    return depth


def ising_1d_partition(n, beta=1.0):
    mag_energy = {}
    for config in cart_product([-1, 1], repeat=n):
        m = sum(config)
        energy = -sum(config[i] * config[i+1] for i in range(n-1))
        weight = math.exp(-beta * energy)
        mag_energy[m] = mag_energy.get(m, 0.0) + weight
    mags = sorted(mag_energy.keys())
    return [mag_energy[m] for m in mags], mags


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Ising partition function for different N
ax1 = axes[0, 0]
for n in [4, 5, 6, 7, 8]:
    coeffs, mags = ising_1d_partition(n, beta=1.0)
    ax1.plot(mags, coeffs, 'o-', label=f'N={n}', markersize=4)
ax1.set_xlabel('Magnetization m')
ax1.set_ylabel('Z(m) = partition weight')
ax1.set_title('1D Ising Partition Function (β=1)', fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Temperature dependence for N=8
ax2 = axes[0, 1]
betas = [0.1, 0.5, 1.0, 2.0, 5.0]
for beta in betas:
    coeffs, mags = ising_1d_partition(8, beta=beta)
    ax2.plot(mags, coeffs, 'o-', label=f'β={beta}', markersize=4)
ax2.set_xlabel('Magnetization m')
ax2.set_ylabel('Z(m)')
ax2.set_title('N=8 Ising: Temperature Dependence', fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Log-concavity depth vs temperature
ax3 = axes[1, 0]
beta_range = np.linspace(0.1, 5.0, 30)
for n in [4, 5, 6, 7]:
    depths = []
    for beta in beta_range:
        coeffs, _ = ising_1d_partition(n, beta=beta)
        d = kfold_depth(coeffs)
        depths.append(d)
    ax3.plot(beta_range, depths, '-', label=f'N={n}', linewidth=2)
ax3.set_xlabel('Inverse Temperature β')
ax3.set_ylabel('Log-Concavity Depth')
ax3.set_title('Concavity Depth vs Temperature', fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Panel 4: Product stability for Ising
ax4 = axes[1, 1]
ns = range(3, 9)
single_d = []
product_d = []
for n in ns:
    c1, _ = ising_1d_partition(n, beta=1.0)
    c2, _ = ising_1d_partition(n, beta=0.5)
    d1 = kfold_depth(c1)
    prod = [c1[i] * c2[i] for i in range(min(len(c1), len(c2)))]
    d2 = kfold_depth(prod)
    single_d.append(d1)
    product_d.append(d2)

ax4.bar([n - 0.15 for n in ns], single_d, width=0.3, label='Z(β=1)',
        color='steelblue')
ax4.bar([n + 0.15 for n in ns], product_d, width=0.3, label='Z(β=1)·Z(β=0.5)',
        color='coral')
ax4.set_xlabel('System Size N')
ax4.set_ylabel('Log-Concavity Depth')
ax4.set_title('Product Stability for Ising Models', fontweight='bold')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3, axis='y')

plt.suptitle('Ising Model & Higher-Order Log-Concavity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ising_visualization.png', dpi=150, bbox_inches='tight')
print("Saved ising_visualization.png")
