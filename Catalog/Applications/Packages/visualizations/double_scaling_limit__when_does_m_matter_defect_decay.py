#!/usr/bin/env python3
"""
Visualization: Defect Decay Along Subcritical Sequences

Shows the wreath defect Δ(k, m(k)) tending to zero for different
subcritical sequences m(k) = floor(k^α) with α < α_c, while growing
or persisting for α ≥ α_c.

This directly illustrates the subcritical irrelevance theorem:
if m(k)^a / k^b → 0, then Δ(k, m(k)) → 0.
"""

import numpy as np
import matplotlib.pyplot as plt


def wreath_defect_model(k, m, C=1.0, a=1, b=1):
    """Model defect: Δ(k,m) = C · m^a / k^b."""
    if k == 0:
        return 0.0
    return C * (m ** a) / (k ** b)


# Parameters
C = 1.0
a_exp = 1
b_exp = 1
alpha_c = b_exp / a_exp

k_range = np.arange(3, 501)
alpha_values = [0.3, 0.5, 0.7, 0.9, 1.0, 1.2, 1.5, 2.0]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw defect Δ(k, m(k))
ax1 = axes[0]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    defects = np.array([wreath_defect_model(int(k), int(m), C, a_exp, b_exp)
                        for k, m in zip(k_range, m_vals)])
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax1.plot(k_range, defects, style, linewidth=lw,
             label=f'α={alpha}')

ax1.set_xlabel('k', fontsize=12)
ax1.set_ylabel('$\\Delta(k, m(k))$', fontsize=12)
ax1.set_title('Wreath Defect Along $m(k) = k^{\\alpha}$', fontsize=12)
ax1.legend(fontsize=8, ncol=2)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Subcritical ratio m^a / k^b
ax2 = axes[1]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    ratios = (m_vals.astype(float) ** a_exp) / (k_range.astype(float) ** b_exp)
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax2.plot(k_range, ratios, style, linewidth=lw,
             label=f'α={alpha}')

ax2.set_xlabel('k', fontsize=12)
ax2.set_ylabel('$m(k)^a / k^b$', fontsize=12)
ax2.set_title('Subcritical Ratio (→0 iff subcritical)', fontsize=12)
ax2.legend(fontsize=8, ncol=2)
ax2.set_yscale('log')
ax2.axhline(y=1, color='red', linestyle='-', linewidth=1, alpha=0.5)
ax2.grid(True, alpha=0.3)

# Panel 3: Per-copy pressure deviation
ax3 = axes[2]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    # Per-copy deviation = Δ(k,m)/m
    deviations = np.array([
        wreath_defect_model(int(k), int(m), C, a_exp, b_exp) / max(1, m)
        for k, m in zip(k_range, m_vals)
    ])
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax3.plot(k_range, deviations, style, linewidth=lw,
             label=f'α={alpha}')

ax3.set_xlabel('k', fontsize=12)
ax3.set_ylabel('$\\Delta(k,m(k)) / m(k)$', fontsize=12)
ax3.set_title('Per-Copy Pressure Deviation', fontsize=12)
ax3.legend(fontsize=8, ncol=2)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

plt.suptitle(
    f'Defect Decay: Critical Exponent $\\alpha_c = {alpha_c}$\n'
    f'(solid: subcritical, dashed: critical, dotted: supercritical)',
    fontsize=14, fontweight='bold'
)
plt.tight_layout()
plt.savefig('defect_decay.png', dpi=150, bbox_inches='tight')
print("Saved defect_decay.png")
