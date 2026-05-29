#!/usr/bin/env python3
"""
Visualization: Scaling Collapse of the Wreath Defect

Tests the crossover profile conjecture by plotting the rescaled defect
R_α(k,m) = k^α · Δ(k,m) / m against the scaling variable λ = m/k^α
for multiple values of k.

If the conjecture holds, curves for different k should collapse onto
a universal profile F(λ) when α equals the critical exponent.
This is the finite-group analog of data collapse in critical phenomena.
"""

import numpy as np
import matplotlib.pyplot as plt

# Model parameters
C = 1.0
a_exp = 1
b_exp = 1
alpha_c = b_exp / a_exp


def wreath_defect_model(k, m, C=1.0, a=1, b=1):
    """Model defect: Δ(k,m) = C · m^a / k^b."""
    if k == 0:
        return 0.0
    return C * (m ** a) / (k ** b)


def rescaled_defect(k, m, alpha, C=1.0, a=1, b=1):
    """Rescaled defect: R_α = k^α · Δ / m."""
    if m == 0 or k == 0:
        return 0.0
    d = wreath_defect_model(k, m, C, a, b)
    return (k ** alpha) * d / m


# Create figure with subplots for different candidate exponents
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
alpha_candidates = [0.5, 1.0, 1.5, 2.0]
k_values = [10, 20, 50, 100, 200]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(k_values)))

for idx, alpha in enumerate(alpha_candidates):
    ax = axes[idx // 2][idx % 2]

    for i, k in enumerate(k_values):
        # Generate m values
        m_max = min(int(5 * k ** alpha) + 1, 10000)
        m_vals = np.arange(1, m_max + 1)

        # Compute scaling variable and rescaled defect
        lambdas = m_vals / (k ** alpha)
        R_vals = np.array([rescaled_defect(k, m, alpha, C, a_exp, b_exp)
                           for m in m_vals])

        ax.plot(lambdas, R_vals, '-', color=colors[i],
                linewidth=1.5, alpha=0.8, label=f'k={k}')

    # Theoretical prediction for this model
    lam_theory = np.linspace(0.01, 5, 200)
    if abs(alpha - alpha_c) < 0.01:
        # At critical exponent: F(λ) = C (constant)
        ax.axhline(y=C, color='red', linestyle='--',
                   linewidth=2, label=f'F(λ) = C = {C}')
        collapse_quality = "PERFECT COLLAPSE"
    elif alpha < alpha_c:
        collapse_quality = "Curves diverge (subcritical α)"
    else:
        collapse_quality = "Curves shrink (supercritical α)"

    ax.set_xlabel('$\\lambda = m/k^{\\alpha}$', fontsize=11)
    ax.set_ylabel('$R_{\\alpha}(k,m) = k^{\\alpha} \\Delta / m$',
                  fontsize=11)
    ax.set_title(f'$\\alpha = {alpha}$ — {collapse_quality}',
                 fontsize=11)
    ax.legend(fontsize=8, loc='best')
    ax.set_xlim(0, 5)
    ax.grid(True, alpha=0.3)

plt.suptitle(
    'Scaling Collapse Test for Wreath Defect\n'
    f'Model: $|\\Delta(k,m)| = C \\cdot m^{a_exp}/k^{b_exp}$, '
    f'$\\alpha_c = {alpha_c}$',
    fontsize=14, fontweight='bold'
)
plt.tight_layout()
plt.savefig('scaling_collapse.png', dpi=150, bbox_inches='tight')
print("Saved scaling_collapse.png")
