#!/usr/bin/env python3
"""
Visualization: Eigenvalue Spectrum and Newton Ratio Profile

Shows how the correlation eigenvalue spectrum changes from gapped to critical,
and how this manifests in the Newton ratio profile. The top row shows eigenvalues
clustering away from 0 and 1 in the gapped phase (spectral pinching), while
spreading to the full interval [0,1] at criticality. The bottom row shows the
corresponding Newton ratio profiles.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def build_ssh_correlation_matrix(m, delta, n_k=8192):
    t1, t2 = 1.0 + delta, 1.0 - delta
    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)
    c_coeffs = np.array([(2.0/n_k) * np.sum(f_k * np.cos(n*k_vals)) for n in range(m)])
    return np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    return np.sort(np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15))

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1); e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def newton_ratio_profile(e):
    m = len(e) - 1
    if m <= 1: return np.array([])
    log_R = np.zeros(m - 1)
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            log_R[k-1] = 2*np.log(e[k]) - np.log(e[k-1]) - np.log(e[k+1])
    return log_R

m = 32
delta_list = [0.0, 0.1, 0.3, 0.5]
fig, axes = plt.subplots(2, 4, figsize=(18, 8))

for col, delta in enumerate(delta_list):
    eigs = ssh_eigenvalues(m, delta)
    e = esymm_stable(eigs)
    profile = newton_ratio_profile(e)

    # Top: eigenvalue spectrum
    ax_top = axes[0, col]
    ax_top.bar(range(m), eigs, color='steelblue', alpha=0.8, width=0.8)
    ax_top.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax_top.axhline(y=1, color='red', linestyle='--', alpha=0.5)
    ax_top.set_ylim(-0.05, 1.05)
    ax_top.set_xlabel('Index i', fontsize=10)
    ax_top.set_ylabel('λᵢ', fontsize=11)
    title = f'δ = {delta}' if delta > 0 else 'δ = 0 (critical)'
    ax_top.set_title(title, fontsize=12, fontweight='bold')
    ax_top.grid(True, alpha=0.2)

    # Mark pinching region if gapped
    if delta > 0:
        eps = eigs.min()
        ax_top.axhspan(0, eps, alpha=0.1, color='red')
        ax_top.axhspan(1-eps, 1, alpha=0.1, color='red')

    # Bottom: Newton ratio profile
    ax_bot = axes[1, col]
    k_range = np.arange(1, len(profile) + 1)
    colors = ['green' if r > 0 else 'red' for r in profile]
    ax_bot.bar(k_range, profile, color=colors, alpha=0.7, width=0.8)
    ax_bot.axhline(y=0, color='black', linewidth=0.5)
    ax_bot.set_xlabel('Index k', fontsize=10)
    ax_bot.set_ylabel('log(Rₖ)', fontsize=11)
    ax_bot.set_title(f'Newton Ratios (m={m})', fontsize=11)
    ax_bot.grid(True, alpha=0.2)

plt.suptitle('SSH Model: Eigenvalue Spectrum and Newton Ratio Profile',
            fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: viz_eigenvalue_spectrum.png")
