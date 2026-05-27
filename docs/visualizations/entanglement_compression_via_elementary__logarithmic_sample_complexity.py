"""
Visualization: Logarithmic Sample Complexity

Demonstrates Theorem 3: the minimum truncation order K needed to achieve
precision ε scales as K = O(log(1/ε)). Shows this for multiple decay
rates ρ, confirming the logarithmic relationship.

This script is fully self-contained - no local imports.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minimum_K_for_epsilon(C, rho, epsilon):
    """Compute minimum K such that C * rho^K / (1-rho) <= epsilon."""
    if rho <= 0 or rho >= 1 or epsilon <= 0:
        return 0
    target = epsilon * (1 - rho) / C
    if target >= 1:
        return 0
    return int(np.ceil(np.log(1 / target) / np.log(1 / rho)))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: K vs log(1/ε) for different ρ
ax1 = axes[0]
C = 1.0
rho_values = [0.2, 0.4, 0.6, 0.8, 0.9]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(rho_values)))

epsilons = np.logspace(-1, -10, 50)

for rho, color in zip(rho_values, colors):
    Ks = [minimum_K_for_epsilon(C, rho, eps) for eps in epsilons]
    ax1.plot(-np.log10(epsilons), Ks, '-', color=color, linewidth=2,
             label=f'ρ = {rho}')

ax1.set_xlabel('-log₁₀(ε) (precision digits)', fontsize=12)
ax1.set_ylabel('K (truncation order)', fontsize=12)
ax1.set_title('Logarithmic Sample Complexity\nK = O(log(1/ε))', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Tail bound vs K showing exponential decay
ax2 = axes[1]

for rho, color in zip(rho_values, colors):
    Ks = np.arange(0, 30)
    bounds = [C * rho**K / (1 - rho) for K in Ks]
    ax2.semilogy(Ks, bounds, '-', color=color, linewidth=2,
                 label=f'ρ = {rho}')

ax2.set_xlabel('K (truncation order)', fontsize=12)
ax2.set_ylabel('C · ρᴷ / (1−ρ)', fontsize=12)
ax2.set_title('Geometric Tail Bound\n(exponential decay in K)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1e-14, 100)

# Add annotation
ax2.annotate('Each line is linear\non this semilog plot',
             xy=(15, 1e-6), fontsize=10, fontstyle='italic',
             color='gray')

plt.tight_layout()
plt.savefig('viz_log_complexity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_log_complexity.png")
