#!/usr/bin/env python3
"""
Visualization 1: Quantum Spectral Gap vs. Lorentzian Certificate

Plots the quantum spectral gap Δ(H) alongside the surrogate Lorentzian
certificate (minimum mass, log-concavity ratio) as transverse field h varies
in the 1D transverse-field Ising model.

This visualizes the core conjecture: quantum gap controls Lorentzian gap.
"""

import numpy as np
import matplotlib.pyplot as plt


def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * (kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n))
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def solve(H):
    evals = np.linalg.eigvalsh(H)
    evals.sort()
    return evals[1] - evals[0], evals

def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evecs[:, idx[0]]


# Compute data for multiple system sizes
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Quantum Spectral Gap vs. Lorentzian Certificates\n'
             'Transverse-Field Ising Model: H = -J ΣZ_iZ_{i+1} - h ΣX_i',
             fontsize=14, fontweight='bold')

h_values = np.linspace(0.1, 3.0, 60)

for n_idx, n_qubits in enumerate([3, 4, 5, 6]):
    ax = axes[n_idx // 2][n_idx % 2]
    
    gaps = []
    min_masses = []
    lc_ratios = []
    entropies = []
    
    for h in h_values:
        H = tfim_hamiltonian(n_qubits, 1.0, h)
        gap, _ = solve(H)
        psi = ground_state(H)
        mu = np.abs(psi)**2
        
        gaps.append(gap)
        min_masses.append(float(np.min(mu)))
        
        max_mu = np.max(mu)
        min_mu = np.min(mu)
        lc_ratios.append(min_mu / max_mu if max_mu > 0 else 0)
        
        ent = -sum(p * np.log2(p) for p in mu if p > 1e-15)
        entropies.append(ent / n_qubits)  # Normalized
    
    ax2 = ax.twinx()
    
    l1, = ax.plot(h_values, gaps, 'b-', linewidth=2, label='Spectral gap Δ(H)')
    l2, = ax2.plot(h_values, lc_ratios, 'r--', linewidth=2, label='LC ratio min/max μ')
    l3, = ax2.plot(h_values, [m * 2**n_qubits for m in min_masses], 'g:', 
                    linewidth=2, label='Normalized min mass')
    
    ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5, label='h/J = 1 (critical)')
    
    ax.set_xlabel('Transverse field h', fontsize=11)
    ax.set_ylabel('Spectral gap Δ(H)', color='blue', fontsize=11)
    ax2.set_ylabel('Certificate value', color='red', fontsize=11)
    ax.set_title(f'n = {n_qubits} qubits ({2**n_qubits} configs)', fontsize=12)
    
    lines = [l1, l2, l3]
    labels = [l.get_label() for l in lines]
    ax.legend(lines, labels, loc='upper right', fontsize=8)
    
    ax.tick_params(axis='y', labelcolor='blue')
    ax2.tick_params(axis='y', labelcolor='red')

plt.tight_layout()
plt.savefig('viz_gap_certificate.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_certificate.png")
