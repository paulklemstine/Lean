#!/usr/bin/env python3
"""
Visualization 1: Quantum Spectral Gap vs. Surrogate Lorentzian Certificate

Plots the quantum spectral gap Δ(H) alongside the surrogate Lorentzian
certificate (min-mass × dim) for the transverse-field Ising model as the
transverse field h varies. Demonstrates the conjectural inequality:
  Δ(H) / n² ≤ Lorentzian certificate

This visualization is the core empirical test of the quantum-to-classical
gap transfer conjecture.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Pauli / Hamiltonian infrastructure (self-contained) ─────────────────
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

def ground_state_data(n, h):
    H = tfim_hamiltonian(n, h=h)
    evals = np.linalg.eigvalsh(H)
    evals.sort()
    evecs = np.linalg.eigh(H)[1]
    psi = evecs[:, np.argmin(np.linalg.eigvalsh(H))]
    mu = np.abs(psi)**2
    gap = evals[1] - evals[0]
    min_mass = np.min(mu)
    return gap, min_mass, mu

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, n in enumerate([3, 4, 5, 6]):
    ax = axes[idx // 2, idx % 2]
    h_vals = np.linspace(0.1, 3.5, 60)
    gaps, certs, min_masses = [], [], []

    for h in h_vals:
        gap, mm, mu = ground_state_data(n, h)
        gaps.append(gap)
        min_masses.append(mm)
        certs.append(mm * 2**n)  # normalized certificate

    gaps = np.array(gaps)
    certs = np.array(certs)
    scaled_gaps = gaps / n**2

    ax.plot(h_vals, gaps, 'b-', linewidth=2, label=r'$\Delta(H)$')
    ax.plot(h_vals, certs, 'r--', linewidth=2, label=r'minMass $\times 2^n$ (certificate)')
    ax.plot(h_vals, scaled_gaps, 'g:', linewidth=2, label=r'$\Delta(H)/n^2$')
    ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5, label='Critical point')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Gap / Certificate', fontsize=12)
    ax.set_title(f'n = {n} ({2**n} configurations)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

fig.suptitle('Quantum Spectral Gap vs. Lorentzian Certificate\n'
             'Transverse-Field Ising Model', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_gap_certificate.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_certificate.png")
