#!/usr/bin/env python3
"""
Visualization: Mixing Rate vs Condition Number

Shows how the Lorentzian condition number predicts MCMC mixing behavior.
As the condition number grows, the contraction surrogate shrinks, indicating
slower mixing. This is the cross-domain bridge from algebraic combinatorics
to algorithm design.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def spectral_gap(H):
    eigs = np.linalg.eigvalsh(H)
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0

def operator_norm(H):
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))


# Compute data for uniform matroids
ms = list(range(3, 51))
kappas = []
contractions = []
radii = []

for m in ms:
    H = leaf_hessian(m)
    g = spectral_gap(H)
    N = operator_norm(H)
    k = N / g if g > 0 else float('inf')
    kappas.append(k)
    contractions.append(g / N if N > 0 else 0)
    radii.append(1.0 / m**2)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Condition Number Controls Algorithmic Behavior', 
             fontsize=14, fontweight='bold')

# Panel 1: Condition number growth
ax = axes[0, 0]
ax.plot(ms, kappas, 'b-', linewidth=2, label='κ(e_r) = m − 1')
ax.fill_between(ms, kappas, alpha=0.15, color='blue')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Condition number κ')
ax.set_title('Condition Number Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Contraction surrogate decay
ax = axes[0, 1]
ax.plot(ms, contractions, 'r-', linewidth=2, label='1/κ = contraction surrogate')
ax.plot(ms, [1/m for m in ms], 'g--', alpha=0.7, label='1/m (theoretical)')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Contraction rate')
ax.set_title('Contraction Surrogate Decay')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Certified radius decay
ax = axes[1, 0]
ax.semilogy(ms, radii, 'b-', linewidth=2, label='Certified radius 1/m²')
ax.semilogy(ms, [1/k for k in kappas], 'r--', linewidth=1.5, 
            label='Contraction surrogate 1/κ')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Value (log scale)')
ax.set_title('Radius and Contraction vs Dimension')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: The unifying relationship
ax = axes[1, 1]
ax.loglog(kappas, radii, 'bo', markersize=6, alpha=0.7)
ax.loglog(kappas, [1/(k+1)**2 for k in kappas], 'r--', linewidth=1.5,
          label='1/(κ+1)²')
# Fit a power law
log_k = np.log(kappas)
log_r = np.log(radii)
slope, intercept = np.polyfit(log_k, log_r, 1)
fit_r = np.exp(intercept) * np.array(kappas)**slope
ax.loglog(kappas, fit_r, 'g-', linewidth=1.5, 
          label=f'Fit: r ∝ κ^{{{slope:.2f}}}')

ax.set_xlabel('Condition number κ')
ax.set_ylabel('Certified radius r')
ax.set_title('The Unifying Relationship: κ vs r')
ax.legend()
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Better conditioned\n(more robust)', 
            xy=(3, 0.05), fontsize=9, color='green',
            ha='center')
ax.annotate('Ill-conditioned\n(fragile)', 
            xy=(30, 0.0005), fontsize=9, color='red',
            ha='center')

plt.tight_layout()
plt.savefig('viz_mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing_convergence.png")
