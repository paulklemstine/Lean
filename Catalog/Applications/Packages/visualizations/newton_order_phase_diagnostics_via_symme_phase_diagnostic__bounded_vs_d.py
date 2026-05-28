#!/usr/bin/env python3
"""
Visualization: Phase Diagnostic — Bounded vs Divergent Newton Order

Creates a clear visual comparison of the Newton gap scaling behavior
in the gapped vs critical phases of the SSH model. The gapped phase
shows saturation (bounded), while the critical phase shows logarithmic
growth (divergent). This directly illustrates Theorems A and C.
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

def sup_newton_gap(e):
    m = len(e) - 1
    if m <= 1: return 0.0
    gaps = []
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gaps.append(np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k]))
    return max(gaps) if gaps else 0.0

# Compute data
m_values = [4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48]
delta_values = [0.0, 0.05, 0.1, 0.2, 0.3, 0.5]
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4', '#9467bd', '#8c564b']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: gap vs m (linear scale)
for delta, color in zip(delta_values, colors):
    gaps = []
    for m in m_values:
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps.append(sup_newton_gap(e))
    label = 'δ = 0 (CRITICAL)' if delta == 0 else f'δ = {delta}'
    lw = 3 if delta == 0 else 1.5
    ax1.plot(m_values, gaps, 'o-', color=color, label=label, linewidth=lw, markersize=5)

ax1.set_xlabel('Subsystem size m', fontsize=13)
ax1.set_ylabel('sup Newton gap', fontsize=13)
ax1.set_title('Newton Gap: Linear Scale', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right: gap vs log(m) — test for logarithmic scaling
for delta, color in zip(delta_values, colors):
    gaps = []
    for m in m_values:
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps.append(sup_newton_gap(e))
    label = 'δ = 0 (CRITICAL)' if delta == 0 else f'δ = {delta}'
    lw = 3 if delta == 0 else 1.5
    ax2.plot(np.log(m_values), gaps, 'o-', color=color, label=label, linewidth=lw, markersize=5)

# Add linear fit for critical case
crit_gaps = []
for m in m_values:
    eigs = ssh_eigenvalues(m, 0.0)
    e = esymm_stable(eigs)
    crit_gaps.append(sup_newton_gap(e))
log_m = np.log(m_values)
slope, intercept = np.polyfit(log_m, crit_gaps, 1)
fit_line = slope * log_m + intercept
ax2.plot(log_m, fit_line, '--', color='gray', linewidth=2,
         label=f'Linear fit: slope={slope:.3f}')

ax2.set_xlabel('log(m)', fontsize=13)
ax2.set_ylabel('sup Newton gap', fontsize=13)
ax2.set_title('Newton Gap vs log(m): Testing Logarithmic Divergence', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate('Bounded\n(gapped)', xy=(log_m[-1], 0.1), fontsize=11,
            ha='right', color='#1f77b4', weight='bold')
ax2.annotate('Growing\n(critical)', xy=(log_m[-1], crit_gaps[-1]),
            fontsize=11, ha='right', color='#d62728', weight='bold')

plt.tight_layout()
plt.savefig('viz_phase_diagnostic.png', dpi=150, bbox_inches='tight')
print("Saved: viz_phase_diagnostic.png")
