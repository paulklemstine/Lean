#!/usr/bin/env python3
"""
Visualization 3: Data Collapse Test for Critical Exponent

Demonstrates the data collapse method for identifying the critical exponent.
Plots rescaled defect R_alpha vs m/k^alpha for several candidate exponents,
showing that only the correct exponent (alpha_c = 2) produces collapse.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def model_defect(k, m, C=0.5, a=1, b=2):
    """Wreath defect: Delta(k,m) = C * m^a / k^b"""
    return C * (m ** a) / (k ** b)


# Generate data across multiple k values and m scalings
k_values = [5, 8, 12, 20, 30, 50]
m_multipliers = np.linspace(0.1, 5.0, 30)

alpha_candidates = [1.0, 1.5, 2.0, 2.5, 3.0]

fig, axes = plt.subplots(1, len(alpha_candidates), figsize=(20, 4.5),
                          sharey=False)

for idx, alpha in enumerate(alpha_candidates):
    ax = axes[idx]

    for k in k_values:
        x_vals = []
        y_vals = []
        for mult in m_multipliers:
            m = max(1, int(mult * k ** alpha))
            delta = model_defect(k, m)
            x = m / k ** alpha  # scaling ratio
            y = k ** alpha / m * delta  # rescaled defect
            x_vals.append(x)
            y_vals.append(y)

        ax.plot(x_vals, y_vals, 'o-', markersize=3, linewidth=1,
                label=f'k={k}', alpha=0.7)

    ax.set_xlabel(r'$m / k^{\alpha}$', fontsize=12)
    if idx == 0:
        ax.set_ylabel(r'$R_\alpha = k^\alpha \Delta / m$', fontsize=12)
    ax.set_title(rf'$\alpha = {alpha}$', fontsize=14,
                 fontweight='bold',
                 color='green' if alpha == 2.0 else 'black')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=7, loc='best')

    if alpha == 2.0:
        ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5,
                    label='C = 0.5')
        # Add green border for correct alpha
        for spine in ax.spines.values():
            spine.set_color('green')
            spine.set_linewidth(3)

plt.suptitle('Data Collapse Test: Only α = 2.0 Produces Collapse\n'
             '(All curves should overlap for the correct critical exponent)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('collapse_test.png', dpi=150, bbox_inches='tight')
print("Saved collapse_test.png")
