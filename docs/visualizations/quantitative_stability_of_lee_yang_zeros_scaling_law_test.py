#!/usr/bin/env python3
"""
Visualization: Scaling Law Test for Lee–Yang Zero Displacement
==============================================================
Tests whether the maximum zero displacement scales as βnδ (Conjecture A)
or βn²δ (proved bound). Plots the scaled displacement ratio vs. system size
for both scaling hypotheses.
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


def curie_weiss_coupling(n, J_val=1.0):
    """Curie–Weiss coupling matrix."""
    J = np.full((n, n), J_val / n)
    np.fill_diagonal(J, 0)
    return J


def measure_max_displacement(n, beta, delta, trials=50):
    """Measure average max displacement over random perturbations."""
    J = curie_weiss_coupling(n)
    coeffs_orig = field_poly_coeffs(n, beta, J)
    roots_orig = np.roots(coeffs_orig[::-1])

    max_disps = []
    for _ in range(trials):
        dJ = np.random.uniform(-delta, delta, (n, n))
        dJ = (dJ + dJ.T) / 2
        np.fill_diagonal(dJ, 0)
        coeffs_pert = field_poly_coeffs(n, beta, J + dJ)
        roots_pert = np.roots(coeffs_pert[::-1])

        used = set()
        disps = []
        for z in roots_orig:
            dists = np.abs(roots_pert - z)
            for idx in np.argsort(dists):
                if idx not in used:
                    used.add(idx)
                    disps.append(dists[idx])
                    break
        if disps:
            max_disps.append(max(disps))

    return np.mean(max_disps) if max_disps else 0


np.random.seed(42)

ns = [3, 4, 5, 6, 7, 8]
beta = 1.0
delta = 0.01
trials = 80

# Collect data
displacements = []
for n in ns:
    d = measure_max_displacement(n, beta, delta, trials)
    displacements.append(d)
    print(f"n={n}: max displacement = {d:.6f}, βn²δ = {beta*n**2*delta:.6f}, "
          f"βnδ = {beta*n*delta:.6f}")

displacements = np.array(displacements)
ns_arr = np.array(ns, dtype=float)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: displacement / (βn²δ)
ax = axes[0]
ratio_n2 = displacements / (beta * ns_arr**2 * delta)
ratio_n1 = displacements / (beta * ns_arr * delta)

ax.plot(ns, ratio_n2, 'bo-', linewidth=2, markersize=8, label='max|Δζ| / (βn²δ)')
ax.plot(ns, ratio_n1, 'rs--', linewidth=2, markersize=8, label='max|Δζ| / (βnδ)')
ax.set_xlabel('System size n', fontsize=12)
ax.set_ylabel('Scaled displacement', fontsize=12)
ax.set_title('Scaling Law Comparison', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: raw displacement vs theory
ax2 = axes[1]
ax2.plot(ns, displacements, 'go-', linewidth=2, markersize=8, label='Measured max|Δζ|')
ax2.plot(ns, beta * ns_arr**2 * delta, 'r--', linewidth=2, label='βn²δ (proved bound)')
ax2.plot(ns, beta * ns_arr * delta, 'b:', linewidth=2, label='βnδ (Conjecture A)')
ax2.set_xlabel('System size n', fontsize=12)
ax2.set_ylabel('Displacement', fontsize=12)
ax2.set_title('Displacement vs. Theoretical Bounds', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_scaling_law.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: viz_scaling_law.png")
