#!/usr/bin/env python3
"""
Visualization 1: Partition Function Landscape for Theta Graphs

Plots the periodic partition function Z_periodic, Z_pin, and Z_harm
as functions of one edge length while keeping the other two fixed.
Shows how the factorization Z_periodic = Z_pin * Z_harm holds
across the parameter space, with the harmonic factor (tropical
Jacobian covolume) dominating for long edges.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def compute_zpin_inline(n, det_Lred):
    return (2 * np.pi) ** ((n - 1) / 2) / np.sqrt(det_Lred)


def compute_covol_inline(a, b, c):
    return np.sqrt(a * b + b * c + c * a)


matplotlib.rcParams.update({'font.size': 12})
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Z components vs c for Θ(1, 1, c)
c_vals = np.linspace(0.2, 8, 200)
a, b = 1.0, 1.0
zpins, zharms, zpers = [], [], []
for c in c_vals:
    w = 1/a + 1/b + 1/c
    zpin = compute_zpin_inline(2, w)
    covol = compute_covol_inline(a, b, c)
    zpins.append(zpin)
    zharms.append(covol)
    zpers.append(zpin * covol)

ax = axes[0]
ax.plot(c_vals, zpers, 'b-', lw=2, label=r'$Z_{\mathrm{periodic}}$')
ax.plot(c_vals, zpins, 'r--', lw=2, label=r'$Z_{\mathrm{pin}}$')
ax.plot(c_vals, zharms, 'g-.', lw=2, label=r'$Z_{\mathrm{harm}}$')
ax.set_xlabel('Edge length c')
ax.set_ylabel('Partition function value')
ax.set_title(r'$\Theta(1, 1, c)$: Sector Factorization')
ax.legend(fontsize=10)
ax.set_xlim(0.2, 8)
ax.grid(True, alpha=0.3)

# Panel 2: Free energy decomposition
F_totals = [-np.log(z) for z in zpers]
F_pins = [-np.log(z) for z in zpins]
F_harms = [-np.log(z) for z in zharms]

ax = axes[1]
ax.fill_between(c_vals, 0, F_pins, alpha=0.3, color='red',
                label=r'$F_{\mathrm{pin}}$ (combinatorial)')
ax.fill_between(c_vals, F_pins, [fp + fh for fp, fh in zip(F_pins, F_harms)],
                alpha=0.3, color='green',
                label=r'$F_{\mathrm{harm}}$ (topological)')
ax.plot(c_vals, F_totals, 'k-', lw=2, label=r'$F_{\mathrm{total}}$')
ax.set_xlabel('Edge length c')
ax.set_ylabel('Free energy (−log Z)')
ax.set_title('Free Energy Decomposition')
ax.legend(fontsize=10)
ax.set_xlim(0.2, 8)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio Z_periodic / Z_pin = covol (tropical Jacobian)
ratios = [zp / zpi for zp, zpi in zip(zpers, zpins)]
ax = axes[2]
ax.plot(c_vals, ratios, 'purple', lw=2.5,
        label=r'$Z_{\mathrm{per}}/Z_{\mathrm{pin}}$')
ax.plot(c_vals, zharms, 'g--', lw=1.5, alpha=0.7,
        label=r'covol($\Lambda_\Gamma$)')
ax.set_xlabel('Edge length c')
ax.set_ylabel('Value')
ax.set_title(r'Ratio = Tropical Jacobian Volume')
ax.legend(fontsize=10)
ax.set_xlim(0.2, 8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_partition_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_partition_landscape.png")
