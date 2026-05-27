"""
Visualization: Newton–Girard Power Sum Reconstruction

Visualizes the Newton–Girard recurrence in action: power sums are
reconstructed from elementary symmetric data, showing exact recovery
for k ≤ m and the finite linear recurrence for k > m.

This demonstrates the algebraic backbone: all spectral moments are
determined by finitely many symmetric invariants.
"""

import warnings
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

warnings.filterwarnings('ignore')
matplotlib.rcParams['font.size'] = 12


def elementary_symmetric_all(mu):
    m = len(mu)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += mu[i] * e[k - 1]
    return e


def power_sum_from_esymm(esymm_data, m, N):
    p = np.zeros(N + 1)
    p[0] = float(m)
    for k in range(1, N + 1):
        ek = esymm_data[k] if k < len(esymm_data) else 0.0
        val = (-1) ** (k + 1) * k * ek
        for j in range(1, k):
            ej = esymm_data[j] if j < len(esymm_data) else 0.0
            val -= (-1) ** j * ej * p[k - j]
        p[k] = val
    return p


# Setup
np.random.seed(42)
m = 5
mu = np.array([0.15, 0.3, 0.5, 0.7, 0.85])
N = 25

esymm = elementary_symmetric_all(mu)
p_recon = power_sum_from_esymm(esymm, m, N)
p_direct = np.array([np.sum(mu**k) for k in range(N + 1)])

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Power sums
ax = axes[0, 0]
ks = np.arange(N + 1)
ax.plot(ks, p_direct, 'ro-', markersize=4, label='Direct $p_k = \\sum_i \\mu_i^k$', linewidth=1.5)
ax.plot(ks, p_recon, 'b^--', markersize=4, label='Newton–Girard reconstruction', linewidth=1.5, alpha=0.7)
ax.axvline(x=m, color='green', linestyle=':', linewidth=2, label=f'm = {m} (recurrence boundary)')
ax.set_xlabel('Order k')
ax.set_ylabel('Power sum $p_k$')
ax.set_title('Power Sum Values')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Reconstruction error
ax = axes[0, 1]
errors = np.abs(p_recon - p_direct)
ax.semilogy(ks[1:], np.maximum(errors[1:], 1e-16), 'ko-', markersize=4)
ax.axvline(x=m, color='green', linestyle=':', linewidth=2, label=f'm = {m}')
ax.set_xlabel('Order k')
ax.set_ylabel('Absolute error')
ax.set_title('Reconstruction Error (machine precision)')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Elementary symmetric polynomials
ax = axes[1, 0]
ks_e = np.arange(m + 3)
esymm_vals = [esymm[k] if k <= m else 0.0 for k in ks_e]
colors = ['blue' if k <= m else 'red' for k in ks_e]
bars = ax.bar(ks_e, esymm_vals, color=colors, alpha=0.7, edgecolor='black')
ax.set_xlabel('Order k')
ax.set_ylabel('$e_k(\\mu)$')
ax.set_title(f'Elementary Symmetric Polynomials (m={m})')
ax.axvline(x=m + 0.5, color='red', linestyle='--', linewidth=2, label='$e_k = 0$ for $k > m$')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Panel 4: Finite linear recurrence coefficients
ax = axes[1, 1]
recurrence_coeffs = [(-1)**j * esymm[j+1] for j in range(m)]
ax.bar(range(m), recurrence_coeffs, color='purple', alpha=0.7, edgecolor='black')
ax.set_xlabel('Index j')
ax.set_ylabel('Coefficient $(-1)^j \\cdot e_{j+1}$')
ax.set_title(f'Recurrence Coefficients for $k > {m}$')
ax.set_xticks(range(m))
ax.grid(True, alpha=0.3, axis='y')
ax.text(0.05, 0.95, f'$p_k = \\sum_{{j=0}}^{{{m-1}}} (-1)^j e_{{j+1}} p_{{k-1-j}}$',
        transform=ax.transAxes, fontsize=11, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.suptitle('Newton–Girard Recurrence: From Symmetric Data to Power Sums',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_newton_girard.png', dpi=150, bbox_inches='tight')
print("Saved viz_newton_girard.png")
