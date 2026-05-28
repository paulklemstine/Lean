#!/usr/bin/env python3
"""
Visualization: Newton Ratio Profile Heatmap

Visualizes the full Newton ratio profile in the (m, k) plane for both
gapped and critical SSH phases. The heatmap reveals where log-concavity
violations concentrate as system size grows.

Key insight: At criticality (δ=0), a bright "ridge" of large Newton gaps
emerges near k ~ m/2, growing with m. In the gapped phase, the heatmap
stays uniformly dark (small gaps).
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
    C = np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])
    return C

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    eigs = np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15)
    return np.sort(eigs)

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def newton_gap_profile(e):
    m = len(e) - 1
    gaps = np.zeros(m - 1) if m > 1 else np.array([])
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gaps[k-1] = np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k])
    return gaps

# Parameters
m_values = list(range(4, 52, 2))
max_k = max(m_values) - 1

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, (delta, title) in enumerate([(0.0, 'Critical (δ = 0)'),
                                        (0.3, 'Gapped (δ = 0.3)')]):
    # Build heatmap data
    heatmap = np.full((len(m_values), max_k), np.nan)
    for i, m in enumerate(m_values):
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps = newton_gap_profile(e)
        for j in range(len(gaps)):
            heatmap[i, j] = gaps[j]

    ax = axes[idx]
    im = ax.imshow(heatmap.T, aspect='auto', origin='lower',
                   extent=[m_values[0], m_values[-1], 1, max_k],
                   cmap='RdYlBu_r', interpolation='nearest')
    ax.set_xlabel('System size m', fontsize=12)
    ax.set_ylabel('Index k', fontsize=12)
    ax.set_title(title, fontsize=13)
    plt.colorbar(im, ax=ax, label='Newton gap')

plt.suptitle('Newton Ratio Profile Heatmap: SSH Model', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_newton_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_newton_heatmap.png")
