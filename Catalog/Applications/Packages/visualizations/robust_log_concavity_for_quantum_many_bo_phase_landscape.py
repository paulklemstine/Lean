"""
Visualization: Phase Landscape of Lorentzian Quantum Geometry

A 2D heatmap showing how the Lorentzian gap surrogate varies across the
(J, h) parameter space of the transverse-field Ising model. Regions of
high Lorentzian gap (red) correspond to states amenable to classical
simulation; regions of low gap (blue) mark quantum phase transitions
where simulation becomes hard.

This visualizes the central conjecture: the geometry of measurement
distributions encodes computational complexity.
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

def compute_certificates(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    probs = np.abs(evecs[:, idx[0]])**2
    gap = evals[idx[1]] - evals[idx[0]]
    p_min, p_max = np.min(probs), np.max(probs)
    lor = p_min / p_max if p_max > 1e-15 else 0.0
    mask = probs > 1e-15
    entropy = -float(np.sum(probs[mask] * np.log(probs[mask])))
    return float(gap), lor, entropy


n = 6
J_vals = np.linspace(0.1, 2.5, 40)
h_vals = np.linspace(0.1, 2.5, 40)

gap_grid = np.zeros((len(h_vals), len(J_vals)))
lor_grid = np.zeros((len(h_vals), len(J_vals)))
ent_grid = np.zeros((len(h_vals), len(J_vals)))

for i, h in enumerate(h_vals):
    for j, J in enumerate(J_vals):
        g, l, e = compute_certificates(n, J, h)
        gap_grid[i, j] = g
        lor_grid[i, j] = l
        ent_grid[i, j] = e

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Quantum gap landscape
im0 = axes[0].imshow(gap_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='viridis', origin='upper')
axes[0].plot(J_vals, J_vals, 'w--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[0].set_xlabel('Coupling J', fontsize=12)
axes[0].set_ylabel('Transverse field h', fontsize=12)
axes[0].set_title('Quantum Spectral Gap Δ(H)', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9, loc='upper left')
plt.colorbar(im0, ax=axes[0])

# Lorentzian gap landscape
im1 = axes[1].imshow(lor_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='RdYlBu_r', origin='upper',
                      vmin=0, vmax=1)
axes[1].plot(J_vals, J_vals, 'k--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[1].set_xlabel('Coupling J', fontsize=12)
axes[1].set_ylabel('Transverse field h', fontsize=12)
axes[1].set_title('Lorentzian Gap Surrogate', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=9, loc='upper left')
plt.colorbar(im1, ax=axes[1])

# Entropy landscape
im2 = axes[2].imshow(ent_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='magma', origin='upper')
axes[2].plot(J_vals, J_vals, 'w--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[2].set_xlabel('Coupling J', fontsize=12)
axes[2].set_ylabel('Transverse field h', fontsize=12)
axes[2].set_title('Measurement Entropy', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=9, loc='upper left')
plt.colorbar(im2, ax=axes[2])

plt.suptitle(f'Phase Landscape of Lorentzian Quantum Geometry (TFIM, n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_landscape.png', dpi=150, bbox_inches='tight')
