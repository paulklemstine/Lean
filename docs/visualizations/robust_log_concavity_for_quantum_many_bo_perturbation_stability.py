#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability of Lorentzian Certificates

Shows how the minimum mass certificate degrades under multiplicative
perturbation, comparing the actual degradation to the theoretical
bound exp(-ε) × minMass(ν).

Demonstrates the formally proved theorem `minMass_perturbation_lower_bound`.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Self-contained infrastructure ───────────────────────────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ops = [I2] * n; ops[i] = sigma_z; ops[i+1] = sigma_z
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2] * n; ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H

def ground_state_dist(H):
    evals, evecs = np.linalg.eigh(H)
    psi = evecs[:, np.argmin(evals)]
    return np.abs(psi)**2

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

n = 5
h_ref = 1.5  # Reference point (away from critical)
H_ref = tfim_hamiltonian(n, h=h_ref)
mu_ref = ground_state_dist(H_ref)
min_mass_ref = np.min(mu_ref)

# Panel 1: min-mass vs perturbation strength
delta_h_vals = np.linspace(0, 2.0, 80)
actual_min_masses = []
epsilons = []
theoretical_bounds = []

for dh in delta_h_vals:
    H_pert = tfim_hamiltonian(n, h=h_ref + dh)
    mu_pert = ground_state_dist(H_pert)
    actual_min_masses.append(np.min(mu_pert))

    # Compute epsilon (multiplicative closeness)
    mask = (mu_ref > 1e-300) & (mu_pert > 1e-300)
    if np.any(mask):
        ratios = mu_pert[mask] / mu_ref[mask]
        eps = max(abs(np.log(np.max(ratios))), abs(np.log(np.min(ratios))))
    else:
        eps = 10.0
    epsilons.append(eps)
    theoretical_bounds.append(np.exp(-eps) * min_mass_ref)

ax = axes[0]
ax.plot(delta_h_vals, actual_min_masses, 'b-', linewidth=2, label='Actual minMass(μ)')
ax.plot(delta_h_vals, theoretical_bounds, 'r--', linewidth=2, label=r'$e^{-\varepsilon}$ × minMass(ν)')
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('Minimum mass', fontsize=12)
ax.set_title('Min-Mass Degradation', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 2: epsilon vs delta_h
ax = axes[1]
ax.plot(delta_h_vals, epsilons, 'g-', linewidth=2)
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('ε (multiplicative closeness)', fontsize=12)
ax.set_title('Closeness Parameter ε', fontsize=13)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio actual/bound (should be ≥ 1)
ax = axes[2]
ratios_plot = [a / (b + 1e-300) for a, b in zip(actual_min_masses, theoretical_bounds)]
ax.plot(delta_h_vals, ratios_plot, 'm-', linewidth=2)
ax.axhline(y=1.0, color='k', linestyle='--', alpha=0.5, label='Bound = 1')
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('Actual / Theoretical bound', fontsize=12)
ax.set_title('Theorem Verification: Ratio ≥ 1', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle(f'Perturbation Stability of Lorentzian Certificate (n={n}, h_ref={h_ref})',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_stability.png")
