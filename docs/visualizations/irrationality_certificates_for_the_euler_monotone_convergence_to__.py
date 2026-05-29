"""
Visualization: Monotone Convergence of H_n - log(n) to γ

Shows the Euler renormalization sequence E_n = H_{n+1} - log(n+1) converging
monotonically from above to the Euler–Mascheroni constant γ, with certified
error bounds 1/(n+1) displayed as a shaded region.
"""

import numpy as np
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015328606065120900824024310421

def harmonic(n):
    return sum(1.0 / k for k in range(1, n + 1))

def euler_renorm(n):
    return harmonic(n + 1) - np.log(n + 1)

def richardson(n):
    return euler_renorm(n) - 1.0 / (2 * (n + 1))

# Compute sequences
ns = np.arange(1, 201)
E = np.array([euler_renorm(n) for n in ns])
R = np.array([richardson(n) for n in ns])
bounds_upper = np.array([GAMMA + 1.0 / (n + 1) for n in ns])
bounds_lower = np.full_like(ns, GAMMA, dtype=float)

fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})

# Top plot: convergence
ax1 = axes[0]
ax1.fill_between(ns, bounds_lower, bounds_upper, alpha=0.15, color='blue',
                  label='Certified region: γ to γ + 1/(n+1)')
ax1.plot(ns, E, 'b-', linewidth=1.5, label='$E_n = H_{n+1} - \\ln(n+1)$', alpha=0.8)
ax1.plot(ns, R, 'r--', linewidth=1.2, label='Richardson corrected', alpha=0.7)
ax1.axhline(y=GAMMA, color='green', linewidth=2, linestyle='-',
            label=f'γ ≈ {GAMMA:.10f}', alpha=0.8)
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Monotone Convergence to the Euler–Mascheroni Constant γ',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper right')
ax1.set_xlim(1, 200)
ax1.set_ylim(GAMMA - 0.02, GAMMA + 0.55)
ax1.grid(True, alpha=0.3)

# Bottom plot: error on log scale
ax2 = axes[1]
errors_E = np.array([euler_renorm(n) - GAMMA for n in ns])
errors_R = np.array([abs(richardson(n) - GAMMA) for n in ns])
cert_bounds = np.array([1.0 / (n + 1) for n in ns])

ax2.semilogy(ns, errors_E, 'b-', linewidth=1.5, label='$E_n - γ$ (raw error)')
ax2.semilogy(ns, errors_R, 'r--', linewidth=1.2, label='|Richardson − γ|')
ax2.semilogy(ns, cert_bounds, 'k:', linewidth=1.5, label='Certified bound 1/(n+1)')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('Error (log scale)', fontsize=12)
ax2.set_title('Approximation Error with Certified Bounds', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(1, 200)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")
