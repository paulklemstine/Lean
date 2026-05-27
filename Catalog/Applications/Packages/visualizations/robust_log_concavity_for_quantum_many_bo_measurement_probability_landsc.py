#!/usr/bin/env python3
"""
Visualization: Measurement Probability Landscape

Heatmap of ground-state measurement probabilities for the transverse-field
Ising model as a function of field strength h and configuration index.
Shows how the measurement distribution transforms from ordered (low h)
to disordered (high h), with the Lorentzian structure most visible
in the disordered phase.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

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

# ── Compute landscape ────────────────────────────────────────────────

n = 6
J = 1.0
h_vals = np.linspace(0.1, 3.0, 60)
dim = 2**n

landscape = np.zeros((len(h_vals), dim))
gaps = []
min_masses = []
entropies = []

for i, h in enumerate(h_vals):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    gaps.append(evals[idx[1]] - evals[idx[0]])
    psi = evecs[:, idx[0]]
    probs = np.abs(psi)**2
    landscape[i] = probs
    min_masses.append(np.min(probs))
    ent = -np.sum(probs[probs > 0] * np.log2(probs[probs > 0]))
    entropies.append(ent)

# ── Plot ──────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: probability heatmap
ax = axes[0, 0]
im = ax.imshow(landscape.T, aspect='auto', origin='lower',
               extent=[h_vals[0], h_vals[-1], 0, dim],
               norm=mcolors.LogNorm(vmin=max(1e-6, landscape[landscape>0].min()),
                                    vmax=landscape.max()),
               cmap='viridis')
ax.set_xlabel('Transverse field h/J', fontsize=11)
ax.set_ylabel('Configuration index', fontsize=11)
ax.set_title('Ground-State Measurement Probabilities', fontsize=13)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7, linewidth=1.5)
plt.colorbar(im, ax=ax, label='μ(x)')

# Top-right: spectral gap
ax = axes[0, 1]
ax.plot(h_vals, gaps, 'b-', linewidth=2)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7)
ax.set_xlabel('h/J', fontsize=11)
ax.set_ylabel('Spectral gap Δ(H)', fontsize=11)
ax.set_title('Quantum Spectral Gap', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-left: minimum mass (anti-concentration)
ax = axes[1, 0]
ax.semilogy(h_vals, min_masses, 'r-', linewidth=2)
ax.axvline(x=1.0, color='gray', linestyle='--', alpha=0.7)
ax.set_xlabel('h/J', fontsize=11)
ax.set_ylabel('min μ(x)', fontsize=11)
ax.set_title('Anti-Concentration (min mass)', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-right: entropy
ax = axes[1, 1]
ax.plot(h_vals, entropies, 'g-', linewidth=2)
ax.axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f'max entropy = {n}')
ax.axvline(x=1.0, color='gray', linestyle='--', alpha=0.7)
ax.set_xlabel('h/J', fontsize=11)
ax.set_ylabel('Shannon entropy (bits)', fontsize=11)
ax.set_title('Distribution Entropy', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)

fig.suptitle(f'Quantum Measurement Landscape: {n}-site Transverse-Field Ising Model',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('measurement_landscape.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved measurement_landscape.png")
