"""
Visualization: Elementary Symmetric Polynomial Coefficient Decay

Visualizes the core mathematical phenomenon: how the esymm coefficients
|e_k| of compressible spectra decay exponentially, contrasted with
non-compressible (critical) spectra. Demonstrates the geometric tail
bound from Theorem 1.

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


def geometric_tail_bound(C, rho, K):
    """Proved bound: C * rho^K / (1 - rho)."""
    if rho <= 0:
        return 0.0
    return C * rho**K / (1 - rho)


# Generate spectra
m = 20

spectra = {
    'Gapped (ρ=0.3)': 1.0 / (1.0 + np.exp(1.2 * np.arange(1, m+1))),
    'Gapped (ρ=0.5)': 1.0 / (1.0 + np.exp(0.7 * np.arange(1, m+1))),
    'Gapped (ρ=0.7)': 1.0 / (1.0 + np.exp(0.35 * np.arange(1, m+1))),
    'Critical': np.clip(1.0 / (1.0 + np.arange(1, m+1)), 0, 1),
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']
markers = ['o', 's', '^', 'D']

# Panel 1: ESymm coefficient decay
ax1 = axes[0]
for (name, p), color, marker in zip(spectra.items(), colors, markers):
    e = esymm_all(p)
    ks = np.arange(len(e))
    abs_e = np.abs(e)
    mask = abs_e > 1e-16

    ax1.semilogy(ks[mask], abs_e[mask], marker=marker, color=color,
                 markersize=6, linewidth=1.5, label=name, alpha=0.8)

    # Fit and plot geometric bound for gapped spectra
    if 'Critical' not in name:
        log_vals = np.log(abs_e[1:])
        valid = np.isfinite(log_vals)
        if np.sum(valid) >= 3:
            coeffs = np.polyfit(np.arange(1, m+1)[valid], log_vals[valid], 1)
            rho_fit = np.exp(coeffs[0])
            C_fit = np.exp(coeffs[1])
            ks_fit = np.arange(0, m+1)
            ax1.semilogy(ks_fit, C_fit * rho_fit**ks_fit, '--', color=color,
                         alpha=0.4, linewidth=1)

ax1.set_xlabel('k (order)', fontsize=12)
ax1.set_ylabel('|e_k(p)|', fontsize=12)
ax1.set_title('Elementary Symmetric Polynomial Coefficients', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-16, 10)

# Panel 2: Tail sum vs K (demonstrating Theorem 1)
ax2 = axes[1]
for (name, p), color, marker in zip(spectra.items(), colors, markers):
    e = esymm_all(p)

    tail_sums = []
    Ks = list(range(1, m + 1))
    for K in Ks:
        tail = sum(abs(e[k]) for k in range(K, m + 1))
        tail_sums.append(tail)

    ax2.semilogy(Ks, tail_sums, marker=marker, color=color,
                 markersize=6, linewidth=1.5, label=name, alpha=0.8)

    # Plot proved geometric tail bound for gapped spectra
    if 'Critical' not in name:
        log_vals = np.log(np.abs(e[1:]))
        valid = np.isfinite(log_vals)
        if np.sum(valid) >= 3:
            coeffs = np.polyfit(np.arange(1, m+1)[valid], log_vals[valid], 1)
            rho_fit = np.exp(coeffs[0])
            C_fit = np.exp(coeffs[1])
            bounds = [geometric_tail_bound(C_fit, rho_fit, K) for K in Ks]
            ax2.semilogy(Ks, bounds, '--', color=color, alpha=0.4, linewidth=1)

ax2.set_xlabel('K (truncation order)', fontsize=12)
ax2.set_ylabel('∑_{k≥K} |e_k(p)|', fontsize=12)
ax2.set_title('Tail Bound (Theorem 1: exponential decay)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_esymm_decay.png', dpi=150, bbox_inches='tight')
print("Saved: viz_esymm_decay.png")
