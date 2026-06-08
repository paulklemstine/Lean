#!/usr/bin/env python3
"""
Visualization: BCH Defect Scaling — Noncommutativity in Quantum EML

Plots how the BCH defect ||exp(εX)*exp(εY) - exp(ε(X+Y))|| scales
with the parameter magnitude ε, demonstrating the quantum correction.
"""

import numpy as np
from scipy.linalg import expm
import matplotlib.pyplot as plt

def bch_defect_norm(h1, h2):
    return np.linalg.norm(expm(h1) @ expm(h2) - expm(h1 + h2))

def commutator_norm(h1, h2):
    return np.linalg.norm(h1 @ h2 - h2 @ h1)

# Pauli matrices
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

epsilons = np.linspace(0.01, 3.0, 200)

# Pair 1: σ_x, σ_z
defects_xz = [bch_defect_norm(eps * sigma_x, eps * sigma_z) for eps in epsilons]
comms_xz = [commutator_norm(eps * sigma_x, eps * sigma_z) for eps in epsilons]
half_comms_xz = [0.5 * c for c in comms_xz]

# Pair 2: σ_x, σ_y
defects_xy = [bch_defect_norm(eps * sigma_x, eps * sigma_y) for eps in epsilons]

# Pair 3: Commuting (both σ_z)
defects_comm = [bch_defect_norm(eps * sigma_z, eps * sigma_z) for eps in epsilons]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: BCH defect for different matrix pairs
ax1 = axes[0]
ax1.plot(epsilons, defects_xz, 'b-', linewidth=2, label=r'$\|D(\varepsilon\sigma_x, \varepsilon\sigma_z)\|$')
ax1.plot(epsilons, defects_xy, 'r-', linewidth=2, label=r'$\|D(\varepsilon\sigma_x, \varepsilon\sigma_y)\|$')
ax1.plot(epsilons, defects_comm, 'g--', linewidth=2, label=r'$\|D(\varepsilon\sigma_z, \varepsilon\sigma_z)\| = 0$')
ax1.plot(epsilons, half_comms_xz, 'b:', linewidth=1.5, alpha=0.7, label=r'$\frac{1}{2}\|[\varepsilon\sigma_x, \varepsilon\sigma_z]\|$ (BCH approx)')
ax1.set_xlabel(r'Parameter magnitude $\varepsilon$', fontsize=12)
ax1.set_ylabel('BCH defect norm', fontsize=12)
ax1.set_title('BCH Defect: Noncommutativity Witness', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right panel: Ratio of defect to commutator (approaches 0.5)
ratios = [d / c if c > 1e-15 else np.nan for d, c in zip(defects_xz, comms_xz)]
ax2 = axes[1]
ax2.plot(epsilons, ratios, 'b-', linewidth=2)
ax2.axhline(y=0.5, color='r', linestyle='--', linewidth=1, alpha=0.7, label=r'$\frac{1}{2}$ (BCH prediction)')
ax2.set_xlabel(r'Parameter magnitude $\varepsilon$', fontsize=12)
ax2.set_ylabel(r'$\|D\| / \|[h_1, h_2]\|$', fontsize=12)
ax2.set_title('BCH Defect / Commutator Ratio', fontsize=14)
ax2.set_ylim(0, 1.5)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('bch_defect_scaling.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved bch_defect_scaling.png")
