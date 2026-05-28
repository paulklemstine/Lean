#!/usr/bin/env python3
"""
Visualization: Complexity Comparison

Compares the computational cost of spectral (eigenvalue) certification
vs coefficient-inequality certification for Lorentzian polynomials.
Shows the asymptotic advantage of the discrete certificate approach.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def certificate_cost(n, d):
    """Number of inequality checks for the coefficient certificate."""
    if d < 2:
        return n
    n_leaves = comb(n + d - 3, d - 2)
    return n * n * n_leaves


def spectral_cost(n, d):
    """Cost of eigenvalue decomposition for all quadratic leaves."""
    if d < 2:
        return n
    n_leaves = comb(n + d - 3, d - 2)
    return n_leaves * n ** 3  # n³ per eigenvalue decomposition


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Cost vs n (fixed d=4) ---
ax1 = axes[0]
n_range = np.arange(2, 51)
d_fixed = 4

cert_costs = [certificate_cost(n, d_fixed) for n in n_range]
spec_costs = [spectral_cost(n, d_fixed) for n in n_range]

ax1.semilogy(n_range, cert_costs, 'b-', linewidth=2, label='Certificate (n² per leaf)')
ax1.semilogy(n_range, spec_costs, 'r--', linewidth=2, label='Spectral (n³ per leaf)')
ax1.fill_between(n_range, cert_costs, spec_costs, alpha=0.15, color='green')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Total operations', fontsize=12)
ax1.set_title(f'Cost vs Variables (degree d={d_fixed})', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Cost vs d (fixed n=10) ---
ax2 = axes[1]
n_fixed = 10
d_range = np.arange(2, 13)

cert_costs_d = [certificate_cost(n_fixed, d) for d in d_range]
spec_costs_d = [spectral_cost(n_fixed, d) for d in d_range]

ax2.semilogy(d_range, cert_costs_d, 'b-o', linewidth=2, markersize=5,
              label='Certificate')
ax2.semilogy(d_range, spec_costs_d, 'r--s', linewidth=2, markersize=5,
              label='Spectral')
ax2.fill_between(d_range, cert_costs_d, spec_costs_d, alpha=0.15, color='green')

ax2.set_xlabel('Degree d', fontsize=12)
ax2.set_ylabel('Total operations', fontsize=12)
ax2.set_title(f'Cost vs Degree (n={n_fixed} variables)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Speedup ratio ---
ax3 = axes[2]

for d in [3, 4, 6, 8]:
    n_vals = np.arange(3, 51)
    speedups = []
    for n in n_vals:
        cc = certificate_cost(n, d)
        sc = spectral_cost(n, d)
        speedups.append(sc / cc if cc > 0 else 1)
    ax3.plot(n_vals, speedups, linewidth=2, label=f'd = {d}')

ax3.axhline(y=1, color='k', linestyle='--', alpha=0.5)
ax3.set_xlabel('Number of variables n', fontsize=12)
ax3.set_ylabel('Speedup (spectral / certificate)', fontsize=12)
ax3.set_title('Certificate Speedup Factor', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, None)

fig.suptitle('Computational Advantage of Coefficient Certificates over Spectral Methods',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_complexity_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_comparison.png")
