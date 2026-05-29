#!/usr/bin/env python3
"""
Visualization 3: Boundary Mass and Expansion — The Cross-Domain Bridge

Demonstrates Theorem 3 (perturbative_boundaryMass_lower_bound):
boundary mass of a perturbed spin system is bounded below by
exp(-ε) times the boundary mass of the reference system.

This visualizes the core cross-domain bridge connecting quantum spectral gaps
to classical expansion properties.
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

def get_gs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evals[idx[0]], evals[idx[1]], np.abs(evecs[:, idx[0]])**2

def boundary_mass(mu, n, A):
    """Compute boundary mass on Hamming-1 graph."""
    bm = 0.0
    for x in A:
        for bit in range(n):
            y = x ^ (1 << bit)
            if y not in A:
                bm += mu[x]
                break
    return bm

def min_expansion(mu, n, min_size=1, max_size=None):
    """Compute minimum expansion ratio over non-trivial subsets."""
    dim = 2**n
    if max_size is None:
        max_size = dim // 2
    
    # Sample random subsets for speed
    np.random.seed(123)
    min_ratio = float('inf')
    for _ in range(500):
        size = np.random.randint(min_size, max_size + 1)
        A = set(np.random.choice(dim, size, replace=False))
        mu_A = sum(mu[x] for x in A)
        if mu_A < 1e-12 or mu_A > 1 - 1e-12:
            continue
        bm = boundary_mass(mu, n, A)
        ratio = bm / (mu_A * (1 - mu_A))
        min_ratio = min(min_ratio, ratio)
    return min_ratio


n = 5
J = 1.0
h_ref = 3.0
_, _, mu_ref = get_gs(n, J, h_ref)

h_values = np.linspace(0.3, 3.5, 40)
dim = 2**n

# Compute for multiple subset choices
subset_choices = {
    'First half': set(range(dim // 2)),
    'Low Hamming weight': set(x for x in range(dim) if bin(x).count('1') <= n // 2),
    'Random subset': set(np.random.choice(dim, dim // 3, replace=False)),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Boundary mass vs h for different subsets
ax = axes[0, 0]
for name, A in subset_choices.items():
    bms = []
    for h in h_values:
        _, _, mu = get_gs(n, J, h)
        bms.append(boundary_mass(mu, n, A))
    ax.plot(h_values, bms, '-o', markersize=2, label=name)
ax.axvline(x=1.0, color='r', linestyle='--', alpha=0.4, label='Critical')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Boundary mass', fontsize=12)
ax.set_title('Boundary Mass ∂A for Various Subsets', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 2: Certified lower bound vs actual
ax = axes[0, 1]
A = set(range(dim // 2))
bm_ref = boundary_mass(mu_ref, n, A)
bms_actual = []
bms_certified = []
epsilons_plot = []

for h in h_values:
    _, _, mu = get_gs(n, J, h)
    bm = boundary_mass(mu, n, A)
    bms_actual.append(bm)
    
    valid = (mu_ref > 1e-15) & (mu > 1e-15)
    if np.any(valid):
        eps = np.max(np.abs(np.log(mu[valid] / mu_ref[valid])))
    else:
        eps = 5.0
    epsilons_plot.append(eps)
    bms_certified.append(np.exp(-eps) * bm_ref)

ax.plot(h_values, bms_actual, 'r-', linewidth=2, label='Actual ∂A(μ)')
ax.plot(h_values, bms_certified, 'b--', linewidth=2, label=r'Certified: $e^{-\varepsilon}$·∂A(ν)')
ax.fill_between(h_values, 0, bms_certified, alpha=0.1, color='blue')
ax.axvline(x=h_ref, color='green', linestyle=':', alpha=0.5, label=f'Reference h={h_ref}')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Boundary mass', fontsize=12)
ax.set_title('Theorem 3: Certified Boundary Mass Lower Bound', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: Spectral gap vs expansion (the bridge!)
ax = axes[1, 0]
gaps = []
expansions = []
for h in h_values:
    E0, E1, mu = get_gs(n, J, h)
    gaps.append(E1 - E0)
    exp_ratio = min_expansion(mu, n)
    expansions.append(exp_ratio)

ax.scatter(gaps, expansions, c=h_values, cmap='plasma', s=30, zorder=5)
ax.set_xlabel('Quantum Spectral Gap Δ', fontsize=12)
ax.set_ylabel('Classical Expansion Φ', fontsize=12)
ax.set_title('THE BRIDGE: Quantum Gap ↔ Classical Expansion', fontsize=13)
sm = plt.cm.ScalarMappable(cmap='plasma',
                            norm=plt.Normalize(vmin=h_values[0], vmax=h_values[-1]))
plt.colorbar(sm, ax=ax, label='h/J')
ax.grid(True, alpha=0.2)

# Panel 4: ε vs h
ax = axes[1, 1]
ax.plot(h_values, epsilons_plot, 'k-', linewidth=2)
ax.axhline(y=1.0, color='orange', linestyle='--', alpha=0.5, label='ε = 1')
ax.axvline(x=1.0, color='r', linestyle='--', alpha=0.4, label='Critical')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Multiplicative Distance from Reference', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

plt.suptitle('Cross-Domain Bridge: Quantum Gaps → Classical Expansion\n'
             f'Transverse-Field Ising Model, n={n}', fontsize=15)
plt.tight_layout()
plt.savefig('viz_boundary_mass.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_mass.png")
