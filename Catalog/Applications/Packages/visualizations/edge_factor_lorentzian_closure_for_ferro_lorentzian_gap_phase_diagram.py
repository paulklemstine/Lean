#!/usr/bin/env python3
"""
Visualization 3: Lorentzian Gap Phase Diagram

Shows how the Lorentzian gap of the partition polynomial Hessian
varies with coupling strength (β) and graph size. The gap controls
mixing time of Glauber dynamics and susceptibility bounds.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_lorentzian_gap(n, beta, J=1.0):
    """
    Compute the Lorentzian gap for K_n at inverse temperature beta.

    The gap is the off-diagonal entry of the Hessian for the (0,1) slice
    at uniform specialization z = (1,...,1).
    """
    edges = list(combinations(range(n), 2))
    w = np.exp(2 * beta * J)
    z = np.ones(n)

    factors = [1.0 + w * z[u] * z[v] for u, v in edges]
    total = np.prod(factors)

    # Mixed partial for (0, 1)
    mixed = 0.0
    for k, (u, v) in enumerate(edges):
        if (u == 0 and v == 1) or (u == 1 and v == 0):
            prod_rest = total / factors[k] if factors[k] != 0 else 0
            mixed += w * prod_rest

    return mixed


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Gap vs β for different graph sizes
ax = axes[0, 0]
betas = np.linspace(0.01, 2.0, 100)
for n in [3, 4, 5, 6, 7]:
    gaps = [compute_lorentzian_gap(n, b) for b in betas]
    ax.semilogy(betas, gaps, linewidth=2, label=f'K_{n}')

ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('Lorentzian gap (log scale)')
ax.set_title('Lorentzian gap vs coupling strength')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Determinant heatmap for K_5
ax = axes[0, 1]
n = 5
beta_range = np.linspace(0.01, 2.0, 50)
z1_range = np.linspace(0.1, 3.0, 50)
det_matrix = np.zeros((50, 50))

edges = list(combinations(range(n), 2))

for ib, beta in enumerate(beta_range):
    w = np.exp(2 * beta)
    for iz, z1 in enumerate(z1_range):
        z = np.ones(n)
        z[0] = z1
        factors = [1.0 + w * z[u] * z[v] for u, v in edges]
        total = np.prod(factors)
        mixed = 0.0
        for k, (u, v) in enumerate(edges):
            if (u == 0 and v == 1) or (u == 1 and v == 0):
                prod_rest = total / factors[k] if factors[k] != 0 else 0
                mixed += w * prod_rest
        det_matrix[iz, ib] = -mixed**2

im = ax.imshow(det_matrix, extent=[beta_range[0], beta_range[-1],
               z1_range[0], z1_range[-1]],
               aspect='auto', origin='lower', cmap='RdBu')
plt.colorbar(im, ax=ax, label='det(H)')
ax.set_xlabel('β')
ax.set_ylabel('z₁ specialization')
ax.set_title('K₅: Hessian determinant (always ≤ 0)')

# Plot 3: Mixing time estimate vs β
ax = axes[1, 0]
for n in [4, 6, 8]:
    betas = np.linspace(0.01, 1.5, 80)
    mix_times = []
    for beta in betas:
        gap = compute_lorentzian_gap(n, beta)
        t_mix = n**2 / gap * np.log(n) if gap > 0 else 1e10
        mix_times.append(min(t_mix, 1e6))
    ax.semilogy(betas, mix_times, linewidth=2, label=f'K_{n}')

ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('Mixing time bound (log scale)')
ax.set_title('Mixing time estimate from Lorentzian gap')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Gap ratio (gap / partition value)
ax = axes[1, 1]
for n in [3, 4, 5, 6]:
    betas = np.linspace(0.01, 2.0, 100)
    ratios = []
    edges = list(combinations(range(n), 2))
    for beta in betas:
        w = np.exp(2 * beta)
        z = np.ones(n)
        gap = compute_lorentzian_gap(n, beta)
        Z_val = np.prod([1.0 + w * z[u] * z[v] for u, v in edges])
        ratios.append(gap / Z_val if Z_val > 0 else 0)
    ax.plot(betas, ratios, linewidth=2, label=f'K_{n}')

ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('Gap / Z (normalized gap)')
ax.set_title('Normalized Lorentzian gap')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('Lorentzian Gap Phase Diagram for Ferromagnetic Models',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_phase_diagram.png")
