#!/usr/bin/env python3
"""
Visualization 1: Gap Landscape Heatmap

Visualizes the quantum spectral gap and surrogate Lorentzian gap across
the (J, h) parameter space of the transverse-field Ising model.
Shows how the gap closes at the phase transition and how anti-concentration
certificates track the gap.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
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
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H


n = 5
J_values = np.linspace(0.2, 2.0, 25)
h_values = np.linspace(0.2, 2.0, 25)

gap_grid = np.zeros((len(J_values), len(h_values)))
minmass_grid = np.zeros((len(J_values), len(h_values)))
entropy_grid = np.zeros((len(J_values), len(h_values)))

for i, J in enumerate(J_values):
    for j, h in enumerate(h_values):
        H = tfim_hamiltonian(n, J, h)
        evals = np.linalg.eigvalsh(H)
        evals_sorted = np.sort(evals)
        gap_grid[i, j] = evals_sorted[1] - evals_sorted[0]
        
        _, evecs = np.linalg.eigh(H)
        psi = evecs[:, np.argmin(evals)]
        mu = np.abs(psi)**2
        minmass_grid[i, j] = np.min(mu)
        entropy_grid[i, j] = -np.sum(mu[mu > 0] * np.log2(mu[mu > 0]))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

im0 = axes[0].imshow(gap_grid, extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='viridis')
axes[0].plot(J_values, J_values, 'r--', linewidth=2, label='h = J (critical)')
axes[0].set_xlabel('Transverse field h', fontsize=12)
axes[0].set_ylabel('Coupling J', fontsize=12)
axes[0].set_title('Quantum Spectral Gap Δ', fontsize=14)
axes[0].legend(fontsize=10)
plt.colorbar(im0, ax=axes[0])

im1 = axes[1].imshow(np.log10(minmass_grid + 1e-20),
                       extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='magma')
axes[1].plot(J_values, J_values, 'w--', linewidth=2, label='h = J')
axes[1].set_xlabel('Transverse field h', fontsize=12)
axes[1].set_ylabel('Coupling J', fontsize=12)
axes[1].set_title('log₁₀(min mass) — Anti-Concentration', fontsize=14)
axes[1].legend(fontsize=10)
plt.colorbar(im1, ax=axes[1])

im2 = axes[2].imshow(entropy_grid,
                       extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='coolwarm')
axes[2].plot(J_values, J_values, 'k--', linewidth=2, label='h = J')
axes[2].set_xlabel('Transverse field h', fontsize=12)
axes[2].set_ylabel('Coupling J', fontsize=12)
axes[2].set_title('Shannon Entropy (bits)', fontsize=14)
axes[2].legend(fontsize=10)
plt.colorbar(im2, ax=axes[2])

plt.suptitle(f'Quantum Lorentzian Bridge: TFIM Parameter Landscape (n={n})', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_landscape.png")
