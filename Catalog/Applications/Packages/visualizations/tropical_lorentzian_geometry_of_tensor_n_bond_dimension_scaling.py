#!/usr/bin/env python3
"""
Visualization 2: Bond Dimension vs. Tropical Gap Scaling

Visualizes the relationship between bond dimension χ and:
- Support cardinality |S| (bounded by χ^n, Theorem 8)
- Estimated tropical gap (Conjecture A: gap ~ log(χ))

This illustrates the cross-domain bridge between tensor network
complexity and tropical geometric invariants.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
import random


def weight_eval(coeff, x, m):
    """Tropical affine evaluation."""
    return coeff.get(m, 0.0) + sum(m[i] * x[i] for i in range(len(m)))


def local_gap(support, coeff, x):
    """Local tropical gap at x."""
    if len(support) <= 1:
        return float('inf')
    weights = sorted(weight_eval(coeff, x, m) for m in support)
    return weights[1] - weights[0]


def make_chain_support(length, chi):
    """Generate chain network support: adjacent entries differ by ≤ 1."""
    support = []
    for m in cartesian_product(range(chi), repeat=length):
        if all(abs(m[i] - m[i+1]) <= 1 for i in range(length-1)):
            support.append(m)
    if not support:
        support = [tuple(0 for _ in range(length))]
    return support


def estimate_gap(support, coeff, n, num_samples=5000):
    """Estimate global tropical gap by sampling."""
    min_gap = float('inf')
    avg_gap = 0.0
    for _ in range(num_samples):
        x = np.random.randn(n) * 3.0
        g = local_gap(support, coeff, x)
        if g < float('inf'):
            min_gap = min(min_gap, g)
            avg_gap += g
    avg_gap /= num_samples
    return min_gap, avg_gap


# Parameters
n = 3  # boundary legs
chi_values = list(range(2, 9))
random.seed(42)
np.random.seed(42)

# Collect data
support_sizes = []
theoretical_bounds = []
min_gaps = []
avg_gaps = []

for chi in chi_values:
    support = make_chain_support(n, chi)
    coeff = {m: random.uniform(0.1, 2.0) for m in support}
    
    support_sizes.append(len(support))
    theoretical_bounds.append(chi ** n)
    
    min_g, avg_g = estimate_gap(support, coeff, n)
    min_gaps.append(min_g)
    avg_gaps.append(avg_g)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Support size vs bound
ax1 = axes[0]
ax1.bar(chi_values, support_sizes, alpha=0.7, color='#3498DB', label='Actual |S|')
ax1.plot(chi_values, theoretical_bounds, 'r-o', linewidth=2, markersize=8,
         label=f'Bound χ^{n}')
ax1.set_xlabel('Bond dimension χ', fontsize=12)
ax1.set_ylabel('Support cardinality', fontsize=12)
ax1.set_title('Support Size vs. Bond Dimension Bound\n(Theorem 8)', 
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Average gap vs log(χ)
ax2 = axes[1]
log_chi = [np.log(chi + 1) for chi in chi_values]
ax2.plot(log_chi, avg_gaps, 'bo-', linewidth=2, markersize=8, label='Avg tropical gap')
ax2.plot(log_chi, min_gaps, 'rs--', linewidth=2, markersize=8, label='Min tropical gap')

# Fit linear regression
z = np.polyfit(log_chi, avg_gaps, 1)
fit_line = np.poly1d(z)
ax2.plot(log_chi, fit_line(log_chi), 'g--', linewidth=1.5, alpha=0.7,
         label=f'Fit: {z[0]:.2f}·log(χ+1) + {z[1]:.2f}')

ax2.set_xlabel('log(χ + 1)', fontsize=12)
ax2.set_ylabel('Tropical gap', fontsize=12)
ax2.set_title('Tropical Gap vs. log(Bond Dimension)\n(Conjecture A)', 
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Gap/log(χ) ratio
ax3 = axes[2]
ratios = [avg_gaps[i] / log_chi[i] for i in range(len(chi_values))]
ax3.plot(chi_values, ratios, 'ko-', linewidth=2, markersize=8)
ax3.axhline(y=np.mean(ratios), color='red', linestyle='--', alpha=0.5,
            label=f'Mean ratio = {np.mean(ratios):.3f}')
ax3.fill_between(chi_values, 
                 [np.mean(ratios) - np.std(ratios)] * len(chi_values),
                 [np.mean(ratios) + np.std(ratios)] * len(chi_values),
                 alpha=0.1, color='red')

ax3.set_xlabel('Bond dimension χ', fontsize=12)
ax3.set_ylabel('Gap / log(χ+1)', fontsize=12)
ax3.set_title('Ratio Stability\n(Tests Logarithmic Scaling)', 
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.suptitle('Bond Dimension Controls Tropical Geometry: Computational Evidence',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('bond_dim_scaling.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved bond_dim_scaling.png")
print("\nData summary:")
for i, chi in enumerate(chi_values):
    print(f"  χ={chi}: |S|={support_sizes[i]}, bound={theoretical_bounds[i]}, "
          f"avg_gap={avg_gaps[i]:.4f}, ratio={ratios[i]:.4f}")
