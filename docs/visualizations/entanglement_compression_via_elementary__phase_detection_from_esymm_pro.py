"""
Visualization: Phase Detection from ESymm Decay Profile

Demonstrates how the exponential compressibility of esymm coefficients
changes across a quantum phase transition. Gapped phases show clean
exponential decay (high R²), while critical phases show deviations.

This script is fully self-contained - no local imports.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_all(p):
    """Compute all elementary symmetric polynomials [e_0, ..., e_m]."""
    m = len(p)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for j in range(m):
        for k in range(min(j + 1, m), 0, -1):
            e[k] += p[j] * e[k - 1]
    return e


def fit_exponential_decay(e_coeffs):
    """Fit |e_k| ~ C * rho^k and return (C, rho, r_squared)."""
    ks, log_vals = [], []
    for k in range(1, len(e_coeffs)):
        if abs(e_coeffs[k]) > 1e-15:
            ks.append(k)
            log_vals.append(np.log(abs(e_coeffs[k])))
    if len(ks) < 3:
        return None, None, 0.0
    ks = np.array(ks, dtype=float)
    log_vals = np.array(log_vals)
    A = np.vstack([np.ones_like(ks), ks]).T
    coeffs, residuals, _, _ = np.linalg.lstsq(A, log_vals, rcond=None)
    C = np.exp(coeffs[0])
    rho = np.exp(coeffs[1])
    ss_res = residuals[0] if len(residuals) > 0 else np.sum((log_vals - A @ coeffs)**2)
    ss_tot = np.sum((log_vals - np.mean(log_vals))**2)
    r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 0.0
    return C, rho, r2


def binary_entropy_scalar(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


# Sweep through gap values (simulating phase transition)
m = 20
gaps = np.linspace(0.05, 3.0, 60)

rho_values = []
r2_values = []
entropy_values = []

for gap in gaps:
    p = 1.0 / (1.0 + np.exp(gap * np.arange(1, m + 1)))
    e = esymm_all(p)
    C, rho, r2 = fit_exponential_decay(e)
    rho_values.append(rho if rho is not None else 1.0)
    r2_values.append(r2)
    entropy_values.append(sum(binary_entropy_scalar(x) for x in p))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: ρ vs gap
ax1 = axes[0, 0]
ax1.plot(gaps, rho_values, 'b-', linewidth=2)
ax1.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='ρ = 1 (critical)')
ax1.set_xlabel('Spectral Gap Δ', fontsize=12)
ax1.set_ylabel('Decay Rate ρ', fontsize=12)
ax1.set_title('Compressibility Parameter vs Gap', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: R² vs gap
ax2 = axes[0, 1]
ax2.plot(gaps, r2_values, 'g-', linewidth=2)
ax2.axhline(y=0.95, color='r', linestyle='--', alpha=0.5,
            label='R² = 0.95 threshold')
ax2.fill_between(gaps, 0.95, 1, alpha=0.1, color='green',
                  label='Compressible region')
ax2.set_xlabel('Spectral Gap Δ', fontsize=12)
ax2.set_ylabel('R² (exponential fit quality)', fontsize=12)
ax2.set_title('Compressibility Detection', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.8, 1.01)

# Panel 3: ESymm profiles for selected gaps
ax3 = axes[1, 0]
selected_gaps = [0.1, 0.5, 1.0, 2.0]
colors = ['#F44336', '#FF9800', '#4CAF50', '#2196F3']

for gap, color in zip(selected_gaps, colors):
    p = 1.0 / (1.0 + np.exp(gap * np.arange(1, m + 1)))
    e = esymm_all(p)
    ks = np.arange(len(e))
    abs_e = np.abs(e)
    mask = abs_e > 1e-16
    ax3.semilogy(ks[mask], abs_e[mask], 'o-', color=color,
                 markersize=5, linewidth=1.5,
                 label=f'Δ = {gap}')

ax3.set_xlabel('k', fontsize=12)
ax3.set_ylabel('|e_k|', fontsize=12)
ax3.set_title('ESymm Profiles Across Phase Transition', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Entropy vs gap
ax4 = axes[1, 1]
ax4.plot(gaps, entropy_values, 'purple', linewidth=2)
ax4.set_xlabel('Spectral Gap Δ', fontsize=12)
ax4.set_ylabel('Entanglement Entropy S', fontsize=12)
ax4.set_title('Entropy vs Spectral Gap', fontsize=13)
ax4.grid(True, alpha=0.3)

# Add annotation about area law
ax4.annotate('Area law: S bounded\nas m → ∞',
             xy=(2.0, entropy_values[-10]),
             xytext=(1.5, max(entropy_values) * 0.7),
             fontsize=10, fontstyle='italic',
             arrowprops=dict(arrowstyle='->', color='gray'),
             color='gray')

plt.suptitle('Phase Detection from ESymm Compressibility', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_detection.png', dpi=150, bbox_inches='tight')
print("Saved: viz_phase_detection.png")
