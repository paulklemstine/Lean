#!/usr/bin/env python3
"""
Visualization: Lee–Yang Zero Clouds Under Coupling Noise
=========================================================
Shows how Lee–Yang zeros of the Ising field polynomial move when coupling
constants are perturbed. The original zeros (blue) scatter into clouds (red)
under random symmetric perturbations of the coupling matrix.

This visualizes the core prediction of the stability theorem: displacement
is bounded by O(β n² δ).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def field_poly_coeffs(n, beta, J):
    """Compute Ising field polynomial coefficients."""
    coeffs = np.zeros(n + 1)
    for bits in iterproduct([0, 1], repeat=n):
        sigma = np.array([1 if b else -1 for b in bits])
        k = sum(bits)
        energy = sigma @ J @ sigma
        coeffs[k] += np.exp(beta * energy)
    return coeffs


def field_poly_roots(coeffs):
    """Find roots of field polynomial."""
    return np.roots(coeffs[::-1])


def curie_weiss_coupling(n, J_val=1.0):
    """Curie–Weiss coupling matrix."""
    J = np.full((n, n), J_val / n)
    np.fill_diagonal(J, 0)
    return J


# Parameters
n = 6
beta = 1.0
delta = 0.03
trials = 50

np.random.seed(42)

J = curie_weiss_coupling(n)
coeffs_orig = field_poly_coeffs(n, beta, J)
roots_orig = field_poly_roots(coeffs_orig)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: zero clouds
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1, label='Unit circle')

# Plot perturbed zeros
for _ in range(trials):
    dJ = np.random.uniform(-delta, delta, (n, n))
    dJ = (dJ + dJ.T) / 2
    np.fill_diagonal(dJ, 0)
    coeffs_pert = field_poly_coeffs(n, beta, J + dJ)
    roots_pert = field_poly_roots(coeffs_pert)
    ax.scatter(roots_pert.real, roots_pert.imag, c='red', s=5, alpha=0.15, zorder=2)

# Plot original zeros on top
ax.scatter(roots_orig.real, roots_orig.imag, c='blue', s=80, marker='*',
           edgecolors='black', linewidths=0.5, zorder=5, label='Original zeros')

ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)
ax.set_title(f'Lee–Yang Zero Clouds (n={n}, β={beta}, δ={delta})', fontsize=13)
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Right panel: displacement histogram
all_displacements = []
for _ in range(200):
    dJ = np.random.uniform(-delta, delta, (n, n))
    dJ = (dJ + dJ.T) / 2
    np.fill_diagonal(dJ, 0)
    coeffs_pert = field_poly_coeffs(n, beta, J + dJ)
    roots_pert = field_poly_roots(coeffs_pert)

    # Greedy matching
    used = set()
    for z in roots_orig:
        dists = np.abs(roots_pert - z)
        for idx in np.argsort(dists):
            if idx not in used:
                used.add(idx)
                all_displacements.append(dists[idx])
                break

ax2 = axes[1]
ax2.hist(all_displacements, bins=40, color='steelblue', edgecolor='black',
         alpha=0.7, density=True)
bound = beta * n**2 * delta
ax2.axvline(bound, color='red', linewidth=2, linestyle='--',
            label=f'βn²δ = {bound:.3f}')
ax2.set_xlabel('Root displacement |ζ\' - ζ|', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Displacement Distribution', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_zero_clouds.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: viz_zero_clouds.png")
