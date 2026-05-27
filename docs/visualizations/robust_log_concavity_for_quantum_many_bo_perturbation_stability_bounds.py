#!/usr/bin/env python3
"""
Visualization: Perturbation Stability of Measurement Distributions

Demonstrates the formally verified theorem `event_prob_ratio_bound`:
when distributions are multiplicatively close, event probabilities
are controlled. Shows how the perturbation envelope exp(±ε) bounds
event probabilities as the perturbation grows.
"""

import numpy as np
import matplotlib.pyplot as plt

# ── Hamiltonian construction (self-contained) ─────────────────────────

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    I2 = np.eye(2, dtype=complex)
    Zop = np.array([[1,0],[0,-1]], dtype=complex)
    Xop = np.array([[0,1],[1,0]], dtype=complex)
    for i in range(n - 1):
        ops = [I2]*n; ops[i] = Zop; ops[i+1] = Zop
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2]*n; ops[i] = Xop
        H -= h * kron_chain(ops)
    return H

# ── Compute perturbation data ────────────────────────────────────────

n = 5
J = 1.0
h_ref = 2.5  # Reference: deep in paramagnetic phase
dim = 2**n

H_ref = tfim_hamiltonian(n, J, h_ref)
evals_ref, evecs_ref = np.linalg.eigh(H_ref)
idx = np.argsort(evals_ref)
psi_ref = evecs_ref[:, idx[0]]
nu = np.abs(psi_ref)**2

# Scan perturbation strength
delta_h_vals = np.linspace(0, 2.0, 50)
epsilons = []
event_ratios = []
min_mass_ratios = []
boundary_ratios = []

event_indices = set(range(dim // 2))

for dh in delta_h_vals:
    h_pert = h_ref - dh
    if h_pert <= 0:
        break
    H_pert = tfim_hamiltonian(n, J, h_pert)
    evals_p, evecs_p = np.linalg.eigh(H_pert)
    idx_p = np.argsort(evals_p)
    psi_p = evecs_p[:, idx_p[0]]
    mu = np.abs(psi_p)**2

    # Compute actual ε
    with np.errstate(divide='ignore', invalid='ignore'):
        log_ratios = np.where(nu > 1e-15, np.log(mu / nu), 0)
    eps = float(np.max(np.abs(log_ratios[nu > 1e-15]))) if np.any(nu > 1e-15) else 0
    epsilons.append(eps)

    # Event probability ratio
    mu_event = sum(mu[i] for i in event_indices)
    nu_event = sum(nu[i] for i in event_indices)
    if nu_event > 0:
        event_ratios.append(mu_event / nu_event)
    else:
        event_ratios.append(1.0)

    # Min mass ratio
    mm_mu = np.min(mu)
    mm_nu = np.min(nu)
    if mm_nu > 0:
        min_mass_ratios.append(mm_mu / mm_nu)
    else:
        min_mass_ratios.append(1.0)

delta_h_vals = delta_h_vals[:len(epsilons)]

# ── Plot ──────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: ε vs perturbation strength
ax = axes[0]
ax.plot(delta_h_vals, epsilons, 'b-o', markersize=3, linewidth=2)
ax.set_xlabel('Perturbation Δh', fontsize=11)
ax.set_ylabel('Multiplicative error ε', fontsize=11)
ax.set_title('Perturbation Parameter ε', fontsize=13)
ax.grid(True, alpha=0.3)

# Panel 2: Event ratio with certified bounds
ax = axes[1]
eps_arr = np.array(epsilons)
ax.fill_between(delta_h_vals, np.exp(-eps_arr), np.exp(eps_arr),
                alpha=0.2, color='green', label='Certified envelope e^{±ε}')
ax.plot(delta_h_vals, event_ratios, 'r-', linewidth=2,
        label='Actual event ratio μ(S)/ν(S)')
ax.plot(delta_h_vals, np.exp(eps_arr), 'g--', linewidth=1, alpha=0.7)
ax.plot(delta_h_vals, np.exp(-eps_arr), 'g--', linewidth=1, alpha=0.7)
ax.set_xlabel('Perturbation Δh', fontsize=11)
ax.set_ylabel('Event probability ratio', fontsize=11)
ax.set_title('Event Ratio Bound (Thm 1)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Min mass ratio with certified bound
ax = axes[2]
ax.fill_between(delta_h_vals, np.exp(-eps_arr), np.ones_like(eps_arr) * 5,
                alpha=0.15, color='blue', label='Certified lower: e^{-ε}')
ax.plot(delta_h_vals, min_mass_ratios, 'purple', linewidth=2,
        label='Actual min_mass(μ)/min_mass(ν)')
ax.plot(delta_h_vals, np.exp(-eps_arr), 'b--', linewidth=1, alpha=0.7)
ax.set_xlabel('Perturbation Δh', fontsize=11)
ax.set_ylabel('Min mass ratio', fontsize=11)
ax.set_title('Min Mass Perturbation (Thm 2)', fontsize=13)
ax.legend(fontsize=9)
ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)

fig.suptitle('Perturbation Stability of Quantum Measurement Distributions',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('perturbation_stability.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved perturbation_stability.png")
