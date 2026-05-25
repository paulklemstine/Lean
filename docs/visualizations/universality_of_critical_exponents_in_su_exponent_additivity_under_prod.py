#!/usr/bin/env python3
"""
Visualization 1: Exponent Additivity Under Direct Products

Illustrates the flagship theorem (exponent_mul_of_two_sided_bounds):
when two functions have power-law bounds with exponent β, their product
has bounds with exponent 2β. Shows the two-sided envelope and the
transition from individual to product scaling.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 10,
    'figure.figsize': (14, 5),
})

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Parameters
beta = 1.5
tc = 0.0
x = np.linspace(-2, 2, 1000)
x_nonzero = np.where(np.abs(x - tc) > 1e-10, x, np.nan)
dx = np.abs(x_nonzero - tc)

# Panel 1: Individual functions with power-law bounds
ax = axes[0]
c1, C1 = 0.8, 1.5
f_vals = (1.0 + 0.3 * np.sin(5 * x_nonzero)) * dx**beta
lower1 = c1 * dx**beta
upper1 = C1 * dx**beta

ax.fill_between(x, np.where(np.isnan(lower1), 0, lower1),
                np.where(np.isnan(upper1), 0, upper1),
                alpha=0.2, color='blue', label=f'Bounds: c|x|^{beta} to C|x|^{beta}')
ax.plot(x, np.where(np.isnan(f_vals), 0, f_vals), 'b-', linewidth=1.5, label='|f(x)|')
ax.set_xlabel('x')
ax.set_ylabel('|f(x)|')
ax.set_title(f'Individual Function: exponent β = {beta}')
ax.legend(loc='upper left', fontsize=9)
ax.set_ylim(0, 5)
ax.axvline(x=tc, color='gray', linestyle=':', alpha=0.5)

# Panel 2: Second function
ax = axes[1]
c2, C2 = 0.6, 1.8
g_vals = (1.2 - 0.2 * np.cos(3 * x_nonzero)) * dx**beta
lower2 = c2 * dx**beta
upper2 = C2 * dx**beta

ax.fill_between(x, np.where(np.isnan(lower2), 0, lower2),
                np.where(np.isnan(upper2), 0, upper2),
                alpha=0.2, color='red', label=f'Bounds: c|x|^{beta} to C|x|^{beta}')
ax.plot(x, np.where(np.isnan(g_vals), 0, g_vals), 'r-', linewidth=1.5, label='|g(x)|')
ax.set_xlabel('x')
ax.set_ylabel('|g(x)|')
ax.set_title(f'Second Function: exponent β = {beta}')
ax.legend(loc='upper left', fontsize=9)
ax.set_ylim(0, 5)
ax.axvline(x=tc, color='gray', linestyle=':', alpha=0.5)

# Panel 3: Product with doubled exponent
ax = axes[2]
fg_vals = f_vals * g_vals
lower_prod = (c1 * c2) * dx**(2 * beta)
upper_prod = (C1 * C2) * dx**(2 * beta)

ax.fill_between(x, np.where(np.isnan(lower_prod), 0, lower_prod),
                np.where(np.isnan(upper_prod), 0, upper_prod),
                alpha=0.2, color='purple',
                label=f'Bounds: c|x|^{2*beta} to C|x|^{2*beta}')
ax.plot(x, np.where(np.isnan(fg_vals), 0, fg_vals), 'purple', linewidth=1.5,
        label='|f(x)·g(x)|')
ax.set_xlabel('x')
ax.set_ylabel('|f·g(x)|')
ax.set_title(f'Product: exponent 2β = {2*beta}')
ax.legend(loc='upper left', fontsize=9)
ax.set_ylim(0, 8)
ax.axvline(x=tc, color='gray', linestyle=':', alpha=0.5)

plt.suptitle('Exponent Additivity Under Products\n'
             '(exponent_mul_of_two_sided_bounds)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_exponent_additivity.png', dpi=150, bbox_inches='tight')
print("Saved viz_exponent_additivity.png")
