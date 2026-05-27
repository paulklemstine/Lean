"""
Visualization: Quantum-to-Classical Gap Bridge

Visualizes the central correspondence: how the quantum spectral gap of a
transverse-field Ising model controls the Lorentzian gap surrogate and
classical expansion (boundary mass) of the ground-state measurement distribution.

Three panels show:
1. Quantum gap vs transverse field strength
2. Lorentzian gap surrogate tracking the quantum gap
3. Scatter plot revealing the quantitative bridge: classical expansion vs quantum gap
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

def analyze(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    probs = np.abs(evecs[:, idx[0]])**2
    gap = evals[idx[1]] - evals[idx[0]]
    p_min, p_max = np.min(probs), np.max(probs)
    lor = p_min / p_max if p_max > 1e-15 else 0.0
    half = set(range(2**(n-1)))
    bm = sum(probs[x] for x in half if any(x ^ (1 << b) not in half for b in range(n)))
    return float(gap), lor, bm


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = {'4': '#2196F3', '6': '#FF5722', '8': '#4CAF50'}

for n in [4, 6, 8]:
    h_vals = np.linspace(0.1, 3.0, 60)
    gaps, lors, bms = [], [], []
    for h in h_vals:
        g, l, b = analyze(n, 1.0, h)
        gaps.append(g)
        lors.append(l)
        bms.append(b)

    c = colors[str(n)]

    axes[0].plot(h_vals, gaps, color=c, linewidth=2, label=f'n={n}')
    axes[0].set_xlabel('Transverse field h/J', fontsize=12)
    axes[0].set_ylabel('Spectral gap Δ(H)', fontsize=12)
    axes[0].set_title('Quantum Spectral Gap', fontsize=13, fontweight='bold')
    axes[0].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.2)

    axes[1].plot(h_vals, lors, color=c, linewidth=2, label=f'n={n}')
    axes[1].set_xlabel('Transverse field h/J', fontsize=12)
    axes[1].set_ylabel('min(μ)/max(μ)', fontsize=12)
    axes[1].set_title('Lorentzian Gap Surrogate', fontsize=13, fontweight='bold')
    axes[1].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.2)

    axes[2].scatter(gaps, bms, color=c, s=20, alpha=0.7, label=f'n={n}')
    axes[2].set_xlabel('Quantum gap Δ(H)', fontsize=12)
    axes[2].set_ylabel('Boundary mass (half-space)', fontsize=12)
    axes[2].set_title('Classical Expansion vs Quantum Gap', fontsize=13, fontweight='bold')
    axes[2].legend(fontsize=10)
    axes[2].grid(True, alpha=0.2)

plt.suptitle('Quantum-to-Classical Bridge: Transverse-Field Ising Model',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_bridge.png', dpi=150, bbox_inches='tight')
