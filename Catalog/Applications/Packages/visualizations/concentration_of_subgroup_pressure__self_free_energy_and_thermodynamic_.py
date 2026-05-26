#!/usr/bin/env python3
"""
Visualization: Free Energy and Thermodynamic Stability

Shows the convexity of the log moment generating function (free energy)
for subgroup pressure, demonstrating the connection to statistical
mechanics. Convexity implies thermodynamic stability — the system
has well-defined phases and smooth transitions.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_free_energy_curve(n, betas, p=0.5, num_samples=30000, seed=42):
    """Compute F(β) = log E[exp(β Π)] for point stabilizers of S_n."""
    rng = np.random.RandomState(seed)
    
    # Weight matrix
    w = 1.0 / n**4
    W = np.full((n, n), w)
    
    # Pre-sample pressures
    pressures = np.zeros(num_samples)
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pressures[i] = chi @ W @ chi
    
    mean_pres = np.mean(pressures)
    centered = pressures - mean_pres
    
    F = np.zeros(len(betas))
    for j, beta in enumerate(betas):
        log_vals = beta * centered
        max_val = np.max(log_vals)
        F[j] = max_val + np.log(np.mean(np.exp(log_vals - max_val)))
    
    return F, mean_pres


# ─── Compute ─────────────────────────────────────────────────────────
betas = np.linspace(-50, 50, 200)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Free energy curves
ax = axes[0, 0]
colors = plt.cm.plasma(np.linspace(0.2, 0.8, 4))
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas)
    ax.plot(betas, F, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$ (inverse temperature)', fontsize=12)
ax.set_ylabel('$\\log\\, \\mathrm{MGF}(\\beta)$', fontsize=12)
ax.set_title('Log Moment Generating Function', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Top-right: Convexity verification
ax = axes[0, 1]
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas)
    # Second difference as convexity measure
    d2F = np.diff(np.diff(F))
    dbeta = betas[1] - betas[0]
    d2F /= dbeta**2
    ax.plot(betas[1:-1], d2F, color=colors[i], lw=1.5, label=f'$S_{{{n}}}$')
ax.axhline(y=0, color='k', linestyle='--', alpha=0.5)
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel("$F''(\\beta)$ (susceptibility)", fontsize=12)
ax.set_title('Convexity = Thermodynamic Stability', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-left: Partition function Z(β)
ax = axes[1, 0]
betas_short = np.linspace(-20, 20, 100)
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas_short)
    Z = np.exp(F)
    ax.semilogy(betas_short, Z, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel('$Z(\\beta) = \\mathbb{E}[e^{\\beta \\Pi}]$', fontsize=12)
ax.set_title('Partition Function', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-right: Expected pressure vs β (derivative of F)
ax = axes[1, 1]
for i, n in enumerate([5, 8, 12, 15]):
    F, mean_pres = compute_free_energy_curve(n, betas)
    dF = np.gradient(F, betas)
    ax.plot(betas, dF + mean_pres, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel('$\\langle \\Pi \\rangle_\\beta$', fontsize=12)
ax.set_title('Thermal Average of Pressure', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle('Thermodynamic Structure of Subgroup Pressure', 
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_free_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_free_energy.png")
