"""
Visualization 2: Defect Perturbation Bounds
=============================================
Shows how the pairwise negative dependence defect changes under
perturbation, comparing the actual change with the certified 2η
and 4η bounds. Demonstrates the tightness of the symmetric bound.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


def pairwise_neg_dep_defect(K, i, j):
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


# Setup
n = 8
k = 4
K = molecular_orbital_kernel(n, k)

eta_values = np.logspace(-4, -0.5, 50)

# Track max defect perturbation for each eta
max_defect_changes = []
for eta in eta_values:
    K_noisy = (1 - eta) * K + eta * np.eye(n) / 2
    max_change = 0
    for i in range(n):
        for j in range(i + 1, n):
            d_ideal = pairwise_neg_dep_defect(K, i, j)
            d_noisy = pairwise_neg_dep_defect(K_noisy, i, j)
            max_change = max(max_change, abs(d_ideal - d_noisy))
    max_defect_changes.append(max_change)

max_defect_changes = np.array(max_defect_changes)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Absolute bounds
ax1.loglog(eta_values, max_defect_changes, 'ko-', markersize=3,
           label='Actual max |Δdefect|', linewidth=2)
ax1.loglog(eta_values, 2 * eta_values, 'b--', linewidth=2,
           label='Symmetric bound (2η)')
ax1.loglog(eta_values, 4 * eta_values, 'r--', linewidth=2,
           label='General bound (4η)')
ax1.set_xlabel('Perturbation η', fontsize=12)
ax1.set_ylabel('Max |Δdefect|', fontsize=12)
ax1.set_title('Defect Perturbation: Actual vs Certified Bounds', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Ratios
ratio_2eta = max_defect_changes / (2 * eta_values)
ratio_4eta = max_defect_changes / (4 * eta_values)

ax2.semilogx(eta_values, ratio_2eta, 'b-o', markersize=3, linewidth=2,
             label='Actual / (2η)')
ax2.semilogx(eta_values, ratio_4eta, 'r-o', markersize=3, linewidth=2,
             label='Actual / (4η)')
ax2.axhline(y=1.0, color='gray', linestyle=':', linewidth=1.5, label='Bound = 1')
ax2.set_xlabel('Perturbation η', fontsize=12)
ax2.set_ylabel('Ratio (actual / bound)', fontsize=12)
ax2.set_title('Bound Tightness Analysis', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.2)

plt.suptitle(f'Certified Fermion Sampling Quality (n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("defect_perturbation_bounds.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved defect_perturbation_bounds.png")
