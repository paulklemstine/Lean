#!/usr/bin/env python3
"""
Visualization 3: Boundary Expansion and Cheeger Constants

Visualizes the boundary mass and Cheeger constant of quantum measurement
distributions on the Hamming graph, demonstrating Theorem 3
(perturbative_boundaryMassC_lower_bound).
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

def boundary_mass(mu, A_indices, n_qubits):
    A_set = set(A_indices)
    total = 0.0
    for x in A_indices:
        for bit in range(n_qubits):
            neighbor = x ^ (1 << bit)
            if neighbor not in A_set:
                total += mu[x]
                break
    return total

def cheeger_estimate(mu, n_qubits, n_samples=200):
    dim = 2 ** n_qubits
    rng = np.random.RandomState(42)
    min_cheeger = float('inf')
    
    for _ in range(n_samples):
        mask = rng.randint(0, 2, size=dim).astype(bool)
        if not np.any(mask) or np.all(mask):
            continue
        A = np.where(mask)[0].tolist()
        mu_A = sum(mu[i] for i in A)
        if mu_A < 1e-10 or mu_A > 1 - 1e-10:
            continue
        bm = boundary_mass(mu, A, n_qubits)
        cheeger = bm / (mu_A * (1 - mu_A))
        min_cheeger = min(min_cheeger, cheeger)
    
    return min_cheeger if min_cheeger != float('inf') else 0.0


n_qubits = 4
dim = 2 ** n_qubits
J = 1.0
h_values = np.linspace(0.2, 3.5, 40)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Boundary Expansion of Quantum Measurement Distributions\n'
             f'{n_qubits}-qubit TFIM on Hamming Graph',
             fontsize=14, fontweight='bold')

# Panel 1: Boundary mass for fixed set A = first half
ax = axes[0][0]
A_half = list(range(dim // 2))

bm_values = []
bm_ref_lower = []
gaps = []

# Reference
H_ref = tfim_hamiltonian(n_qubits, J, 3.0)
psi_ref, _ = ground_state(H_ref)
mu_ref = np.abs(psi_ref)**2
bm_ref = boundary_mass(mu_ref, A_half, n_qubits)

for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, gap = ground_state(H)
    mu = np.abs(psi)**2
    
    bm = boundary_mass(mu, A_half, n_qubits)
    bm_values.append(bm)
    gaps.append(gap)
    
    # Compute ε
    eps = 0.0
    for i in range(dim):
        if mu_ref[i] > 1e-15 and mu[i] > 1e-15:
            eps = max(eps, abs(np.log(mu[i] / mu_ref[i])))
    bm_ref_lower.append(np.exp(-eps) * bm_ref)

ax.plot(h_values, bm_values, 'b-', linewidth=2, label='∂μ(A) actual')
ax.plot(h_values, bm_ref_lower, 'r--', linewidth=2, label='exp(-ε)·∂ν(A) lower bound')
ax.fill_between(h_values, bm_ref_lower, bm_values, alpha=0.15, color='green',
                where=[b <= a + 1e-10 for a, b in zip(bm_values, bm_ref_lower)])
ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5)
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Boundary mass')
ax.set_title('Boundary Mass: Actual vs. Perturbative Bound')
ax.legend(fontsize=9)

# Panel 2: Cheeger constant estimate
ax = axes[0][1]
cheeger_values = []
for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, _ = ground_state(H)
    mu = np.abs(psi)**2
    cheeger_values.append(cheeger_estimate(mu, n_qubits))

ax.plot(h_values, cheeger_values, 'g-', linewidth=2)
ax.plot(h_values, gaps, 'b--', linewidth=1.5, alpha=0.7, label='Spectral gap Δ(H)')
ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5)
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Value')
ax.set_title('Cheeger Constant vs. Quantum Gap')
ax.legend(['Cheeger Φ(μ)', 'Spectral gap Δ(H)'], fontsize=10)

# Panel 3: Boundary mass for multiple set sizes
ax = axes[1][0]
h_test = 1.5
H_test = tfim_hamiltonian(n_qubits, J, h_test)
psi_test, _ = ground_state(H_test)
mu_test = np.abs(psi_test)**2

set_sizes = range(1, dim)
bm_by_size = []
for k in set_sizes:
    # Use first k configurations
    A = list(range(k))
    bm_by_size.append(boundary_mass(mu_test, A, n_qubits))

mu_A_vals = [sum(mu_test[i] for i in range(k)) for k in set_sizes]
ax.plot(mu_A_vals, bm_by_size, 'b-', linewidth=2)
ax.set_xlabel('μ(A)')
ax.set_ylabel('Boundary mass ∂μ(A)')
ax.set_title(f'Boundary Mass Profile (h={h_test})')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Panel 4: Heatmap of measurement distribution
ax = axes[1][1]
n_h_heatmap = 30
h_heatmap = np.linspace(0.2, 3.0, n_h_heatmap)
probs_matrix = np.zeros((n_h_heatmap, dim))

for i, h in enumerate(h_heatmap):
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, _ = ground_state(H)
    probs_matrix[i, :] = np.abs(psi)**2

im = ax.imshow(probs_matrix.T, aspect='auto', cmap='viridis',
               extent=[h_heatmap[0], h_heatmap[-1], dim - 0.5, -0.5])
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Configuration index')
ax.set_title('Measurement Distribution μ(x)')
plt.colorbar(im, ax=ax, label='Probability')

plt.tight_layout()
plt.savefig('viz_boundary_expansion.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_expansion.png")
