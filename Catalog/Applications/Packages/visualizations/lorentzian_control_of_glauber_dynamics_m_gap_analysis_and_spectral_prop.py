#!/usr/bin/env python3
"""
Visualization: Lorentzian Eigenvalue Spectrum and Gap Stability

Shows how the eigenvalue spectrum of the coupling matrix changes
under perturbation, and how the Lorentzian gap degrades.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def complete_graph_coupling(n, strength):
    return strength * (np.ones((n, n)) - np.eye(n)) / n


def compute_gap(J):
    eigenvalues = np.linalg.eigvalsh(J)
    sorted_eigs = np.sort(eigenvalues)[::-1]
    return abs(sorted_eigs[1]) if len(sorted_eigs) > 1 else 0


np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Heatmap of gap vs (n, coupling)
ax = axes[0, 0]
n_values = np.arange(4, 25)
strengths = np.linspace(0.05, 1.0, 20)
gap_matrix = np.zeros((len(n_values), len(strengths)))
for i, n in enumerate(n_values):
    for j, s in enumerate(strengths):
        J = complete_graph_coupling(n, s)
        gap_matrix[i, j] = compute_gap(J)

im = ax.imshow(gap_matrix, aspect='auto', origin='lower',
               extent=[strengths[0], strengths[-1], n_values[0], n_values[-1]],
               cmap='viridis')
plt.colorbar(im, ax=ax, label='Lorentzian Gap ε')
ax.set_xlabel('Coupling Strength β', fontsize=12)
ax.set_ylabel('System Size n', fontsize=12)
ax.set_title('Lorentzian Gap Landscape', fontsize=13)

# Panel 2: Gap as function of coupling for different n
ax = axes[0, 1]
for n in [8, 12, 16, 20]:
    gaps = []
    ss = np.linspace(0.01, 1.5, 50)
    for s in ss:
        J = complete_graph_coupling(n, s)
        gaps.append(compute_gap(J))
    ax.plot(ss, gaps, linewidth=2, label=f'n={n}')

ax.set_xlabel('Coupling Strength β', fontsize=12)
ax.set_ylabel('Lorentzian Gap ε', fontsize=12)
ax.set_title('Gap vs Coupling Strength', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Predicted mixing time n·log(n)/ε
ax = axes[1, 0]
for strength_label, strength in [('weak (0.2)', 0.2), ('medium (0.5)', 0.5), ('strong (0.8)', 0.8)]:
    ns = np.arange(4, 30)
    tmix_pred = []
    for n in ns:
        J = complete_graph_coupling(n, strength)
        gap = compute_gap(J)
        if gap > 1e-10:
            tmix_pred.append(n * np.log(n) / gap)
        else:
            tmix_pred.append(np.nan)
    ax.plot(ns, tmix_pred, linewidth=2, label=strength_label)

ax.set_xlabel('System Size n', fontsize=12)
ax.set_ylabel('Predicted Mixing Time', fontsize=12)
ax.set_title('Predicted t_mix = n·log(n)/ε', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 4: Spectral gap ε/n
ax = axes[1, 1]
for strength_label, strength in [('β=0.2', 0.2), ('β=0.5', 0.5), ('β=0.8', 0.8)]:
    ns = np.arange(4, 30)
    spec_gaps = []
    for n in ns:
        J = complete_graph_coupling(n, strength)
        gap = compute_gap(J)
        spec_gaps.append(gap / n if gap > 0 else 0)
    ax.plot(ns, spec_gaps, 'o-', linewidth=1.5, markersize=3, label=strength_label)

ax.set_xlabel('System Size n', fontsize=12)
ax.set_ylabel('Spectral Gap ε/n', fontsize=12)
ax.set_title('Spectral Gap Scaling', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Lorentzian MCMC: Gap Analysis for Complete Graph Ising Models',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('lorentzian_spectrum_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: lorentzian_spectrum_analysis.png")
