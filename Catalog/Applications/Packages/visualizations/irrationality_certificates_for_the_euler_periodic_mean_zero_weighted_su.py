"""
Visualization: Periodic Mean-Zero Weighted Sums vs Harmonic Divergence

Contrasts the bounded behavior of sum_{k=1}^n f(k)/k for periodic mean-zero
functions f with the divergent behavior of the harmonic sum (mean ≠ 0).
This visualizes the key theorem periodic_mean_zero_log_weighted_bounded
and its connection to L-function special values.
"""

import numpy as np
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015328606065120900824024310421

def periodic_weighted_sum_sequence(f, max_n):
    """Compute partial sums sum_{k=1}^n f(k mod q)/k for n = 1..max_n."""
    q = len(f)
    sums = np.zeros(max_n)
    running = 0.0
    for k in range(1, max_n + 1):
        running += f[k % q] / k
        sums[k - 1] = running
    return sums

def harmonic_log_sequence(max_n):
    """Compute H_n - log(n) for n = 1..max_n."""
    sums = np.zeros(max_n)
    running = 0.0
    for k in range(1, max_n + 1):
        running += 1.0 / k
        sums[k - 1] = running - np.log(k)
    return sums

max_n = 2000
ns = np.arange(1, max_n + 1)

# Periodic mean-zero examples
chi4 = [0, 1, 0, -1]  # χ mod 4
chi3 = [0, 1, -1]      # Legendre mod 3
custom = [3, -1, -1, -1]  # Custom mean-zero

sums_chi4 = periodic_weighted_sum_sequence(chi4, max_n)
sums_chi3 = periodic_weighted_sum_sequence(chi3, max_n)
sums_custom = periodic_weighted_sum_sequence(custom, max_n)
sums_harmonic = harmonic_log_sequence(max_n)

# Harmonic series (divergent, mean ≠ 0)
harmonic_raw = np.cumsum(1.0 / ns)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: bounded periodic sums
ax = axes[0, 0]
ax.plot(ns, sums_chi4, 'b-', linewidth=0.8, alpha=0.7,
        label=f'χ mod 4: [0,1,0,−1] → π/4 ≈ {np.pi/4:.4f}')
ax.plot(ns, sums_chi3, 'r-', linewidth=0.8, alpha=0.7,
        label='Legendre mod 3: [0,1,−1]')
ax.plot(ns, sums_custom, 'g-', linewidth=0.8, alpha=0.7,
        label='Custom: [3,−1,−1,−1]')
ax.axhline(y=np.pi/4, color='blue', linestyle=':', alpha=0.5)
ax.set_xlabel('n')
ax.set_ylabel('$\\sum_{k=1}^n f(k)/k$')
ax.set_title('Bounded: Periodic Mean-Zero Weighted Sums', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Top right: divergent harmonic
ax = axes[0, 1]
ax.plot(ns, harmonic_raw, 'k-', linewidth=1.5, label='$H_n$ (divergent)')
ax.plot(ns, np.log(ns), 'r--', linewidth=1.2, label='$\\ln(n)$')
ax.set_xlabel('n')
ax.set_ylabel('Value')
ax.set_title('Divergent: $H_n$ (Non-Zero Mean f=1)', fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: H_n - log(n) converging to γ
ax = axes[1, 0]
ax.plot(ns, sums_harmonic, 'b-', linewidth=1, alpha=0.8,
        label='$H_n - \\ln(n)$')
ax.axhline(y=GAMMA, color='green', linewidth=2, linestyle='--',
           label=f'γ ≈ {GAMMA:.6f}')
ax.fill_between(ns, GAMMA, sums_harmonic, alpha=0.1, color='blue')
ax.set_xlabel('n')
ax.set_ylabel('$H_n - \\ln(n)$')
ax.set_title('Renormalized: $H_n - \\ln(n) → γ$', fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(GAMMA - 0.05, GAMMA + 0.6)

# Bottom right: comparison of convergence rates
ax = axes[1, 1]
errors_gamma = np.abs(sums_harmonic - GAMMA)
errors_chi4 = np.abs(sums_chi4 - np.pi/4)
ax.loglog(ns[1:], errors_gamma[1:], 'b-', linewidth=0.8, alpha=0.7,
          label='$|H_n - \\ln n - γ|$')
ax.loglog(ns[1:], errors_chi4[1:], 'r-', linewidth=0.8, alpha=0.7,
          label='$|S_n^{χ_4} - π/4|$')
ax.loglog(ns[1:], 1.0/ns[1:], 'k:', linewidth=1.5, alpha=0.5,
          label='$1/n$ reference')
ax.set_xlabel('n')
ax.set_ylabel('Error (log-log)')
ax.set_title('Convergence Rate Comparison', fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Mean-Zero Periodicity: The Structural Mechanism\n'
             'Separating Bounded Sums from Divergent Harmonic Series',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('periodic_sums_plot.png', dpi=150, bbox_inches='tight')
print("Saved periodic_sums_plot.png")
