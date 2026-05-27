#!/usr/bin/env python3
"""
Visualization 2: Perturbation Landscape — ε-Distance from Free-Fermion Reference

Shows how the multiplicative perturbation parameter ε varies across the
phase diagram, illustrating the regime where our perturbative theorems
(event_prob_ratio_bound, perturbative_boundaryMassC_lower_bound) apply.
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

def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evecs[:, idx[0]], evals[idx[1]] - evals[idx[0]]


n_qubits = 5
dim = 2 ** n_qubits
J = 1.0

# Reference points: deep in each phase
h_ref_high = 5.0  # Paramagnetic (near product state / free-fermion)
H_ref = tfim_hamiltonian(n_qubits, J, h_ref_high)
psi_ref, _ = ground_state(H_ref)
mu_ref = np.abs(psi_ref)**2

h_values = np.linspace(0.1, 4.0, 80)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Perturbation Landscape for Quantum Measurement Distributions\n'
             f'{n_qubits}-qubit Transverse-Field Ising Model, reference at h={h_ref_high}',
             fontsize=13, fontweight='bold')

# Panel 1: ε vs h
epsilons = []
gaps = []
for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, gap = ground_state(H)
    mu = np.abs(psi)**2
    
    eps = 0.0
    for i in range(dim):
        if mu_ref[i] > 1e-15 and mu[i] > 1e-15:
            eps = max(eps, abs(np.log(mu[i] / mu_ref[i])))
    
    epsilons.append(eps)
    gaps.append(gap)

ax = axes[0]
ax.plot(h_values, epsilons, 'b-', linewidth=2)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='Critical point')
ax.fill_between(h_values, 0, epsilons, alpha=0.15, color='blue')
ax.set_xlabel('Transverse field h', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Multiplicative Distance\nfrom Reference', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: exp(-ε) bound degradation
ax = axes[1]
exp_neg_eps = [np.exp(-e) for e in epsilons]
ax.plot(h_values, exp_neg_eps, 'g-', linewidth=2, label='exp(-ε)')
ax.plot(h_values, [np.exp(e) for e in epsilons], 'r-', linewidth=2, label='exp(ε)')
ax.fill_between(h_values, exp_neg_eps, [np.exp(e) for e in epsilons],
                alpha=0.1, color='orange')
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7)
ax.set_xlabel('Transverse field h', fontsize=12)
ax.set_ylabel('Multiplicative factor', fontsize=12)
ax.set_title('Event Probability Ratio\nBound (Theorem 1)', fontsize=12)
ax.set_yscale('log')
ax.legend(fontsize=10)

# Panel 3: Gap vs ε scatter
ax = axes[2]
colors = ['green' if e < 1.0 else 'orange' if e < 2.0 else 'red' for e in epsilons]
ax.scatter(gaps, epsilons, c=colors, s=40, alpha=0.7, edgecolors='black', linewidths=0.5)
ax.set_xlabel('Quantum spectral gap Δ(H)', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Gap-Perturbation\nCorrelation', fontsize=12)

# Add annotation
ax.annotate('Efficient\nregion', xy=(max(gaps)*0.7, min(epsilons)*1.5),
            fontsize=11, color='green', fontweight='bold')
ax.annotate('Critical\nregion', xy=(min(gaps)*1.2, max(epsilons)*0.8),
            fontsize=11, color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_landscape.png")
