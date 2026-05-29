#!/usr/bin/env python3
"""
Visualization 3: Boundary Mass and Graph Expansion

Plots the boundary mass (graph expansion quantity) for the Hamming graph
on {0,1}^n, comparing a reference free-fermion distribution to perturbed
measurement distributions. Demonstrates the cross-domain bridge theorem
`perturbative_boundaryMass_lower_bound`.
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

def boundary_mass(mu, n_bits, A):
    bmass = 0.0
    for x in A:
        for bit in range(n_bits):
            y = x ^ (1 << bit)
            if y not in A:
                bmass += mu[x]
                break
    return bmass

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for panel, n in enumerate([3, 4, 5]):
    ax = axes[panel]
    dim = 2**n

    # Reference distribution at h = 1.0 (critical / free-fermion-like)
    H_ref = tfim_hamiltonian(n, h=1.0)
    mu_ref = ground_state_dist(H_ref)

    # Set A = top-half-mass configurations
    idx_sorted = np.argsort(-mu_ref)
    A = set(idx_sorted[:dim // 2])

    h_vals = np.linspace(0.1, 3.5, 50)
    bm_vals = []
    bm_ref_val = boundary_mass(mu_ref, n, A)
    bm_bounds = []

    for h in h_vals:
        H_pert = tfim_hamiltonian(n, h=h)
        mu_pert = ground_state_dist(H_pert)

        bm = boundary_mass(mu_pert, n, A)
        bm_vals.append(bm)

        # Compute epsilon and theoretical bound
        mask = (mu_ref > 1e-300) & (mu_pert > 1e-300)
        if np.any(mask):
            ratios = mu_pert[mask] / mu_ref[mask]
            eps = max(abs(np.log(np.max(ratios))), abs(np.log(np.min(ratios))))
        else:
            eps = 10.0
        bm_bounds.append(np.exp(-eps) * bm_ref_val)

    ax.plot(h_vals, bm_vals, 'b-', linewidth=2, label='Actual boundary mass')
    ax.plot(h_vals, bm_bounds, 'r--', linewidth=2, label=r'$e^{-\varepsilon}$ × ref bound')
    ax.axhline(y=bm_ref_val, color='gray', linestyle=':', alpha=0.5, label='Reference')
    ax.axvline(x=1.0, color='green', linestyle='-.', alpha=0.4, label='h = J (ref)')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Boundary mass', fontsize=12)
    ax.set_title(f'n = {n}', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

fig.suptitle('Boundary Mass Transfer Under Perturbation\n'
             '(Cross-Domain Bridge Theorem Verification)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_boundary_mass.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_mass.png")
