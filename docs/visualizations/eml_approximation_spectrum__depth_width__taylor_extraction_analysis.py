#!/usr/bin/env python3
"""
Visualization: EML Taylor Quadratic Extraction

Shows how exp(εx) extracts the quadratic term x² as ε → 0,
and compares EML approximation quality vs piecewise linear.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x = np.linspace(0, 1, 1000)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: EML quadratic extraction for various ε
ax = axes[0, 0]
ax.plot(x, x**2, 'k-', linewidth=2, label='x²')
for eps in [1.0, 0.5, 0.2, 0.1, 0.05]:
    approx = 2 * (np.exp(eps * x) - 1 - eps * x) / eps**2
    ax.plot(x, approx, '--', label=f'ε = {eps}', alpha=0.8)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('EML Quadratic Extraction: 2(exp(εx)-1-εx)/ε² → x²')
ax.legend()
ax.set_ylim(-0.1, 1.5)

# Plot 2: Error vs width
ax = axes[0, 1]
widths = range(1, 101)
eml_errors = []
pwl_errors = []
eml_bounds = []

for w in widths:
    eps = 1.0 / w
    approx_vals = 2 * (np.exp(eps * x) - 1 - eps * x) / eps**2
    max_err = np.max(np.abs(approx_vals - x**2))
    eml_errors.append(max_err)
    pwl_errors.append(1.0 / (8 * w**2))
    eml_bounds.append(np.exp(1) / (3 * w))

ax.semilogy(widths, eml_errors, 'b-', label='EML actual error')
ax.semilogy(widths, eml_bounds, 'b--', label='EML bound: e/(3w)')
ax.semilogy(widths, pwl_errors, 'r-', label='PWL error: 1/(8w²)')
ax.set_xlabel('Width w')
ax.set_ylabel('Max error on [0,1]')
ax.set_title('Error vs Width for x² Approximation')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Taylor remainder verification
ax = axes[1, 0]
t_vals = np.linspace(-3, 3, 1000)
remainder = np.abs(np.exp(t_vals) - 1 - t_vals - t_vals**2/2)
bound = np.abs(t_vals)**3 / 6 * np.exp(np.abs(t_vals))

ax.semilogy(t_vals, remainder, 'b-', label='|exp(t) - 1 - t - t²/2|')
ax.semilogy(t_vals, bound, 'r--', label='|t|³/6 · exp(|t|)')
ax.set_xlabel('t')
ax.set_ylabel('Value')
ax.set_title('Taylor Remainder Bound (Theorem 1)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Crossover depth
ax = axes[1, 1]
widths_arr = np.arange(1, 51)
crossover_d = 8 * widths_arr * np.exp(1) / 3

ax.plot(widths_arr, crossover_d, 'b-', linewidth=2)
ax.fill_between(widths_arr, crossover_d, 500, alpha=0.2, color='blue',
                label='EML dominates PWL')
ax.fill_between(widths_arr, 0, crossover_d, alpha=0.2, color='red',
                label='PWL dominates EML')
ax.set_xlabel('Width w')
ax.set_ylabel('Depth d')
ax.set_title('Depth-Width Crossover: d ≥ 8we/3')
ax.set_ylim(0, 400)
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('taylor_extraction.png', dpi=150, bbox_inches='tight')
print("Saved taylor_extraction.png")
