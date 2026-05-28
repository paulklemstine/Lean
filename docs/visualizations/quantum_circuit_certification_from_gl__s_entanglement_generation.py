"""
Visualization: Entanglement Generation via Certified Channel

Shows how the certified quantum channel drives a pure (zero-entanglement)
state toward the maximally mixed (high-entanglement) state, with the
spectral gap controlling the convergence rate.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def gl2_fq_elements(q):
    elements = []
    for a, b, c, d in product(range(q), repeat=4):
        if (a * d - b * c) % q != 0:
            elements.append(np.array([[a, b], [c, d]], dtype=int))
    return elements


def build_idx_map(elements, q):
    idx_map = {}
    for i, A in enumerate(elements):
        key = tuple(int(A[r, c] % q) for r in range(2) for c in range(2))
        idx_map[key] = i
    return idx_map


def mat_inv(A, q):
    det = int((A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q)
    det_inv = pow(det, q - 2, q)
    return (det_inv * np.array([[A[1, 1], -A[0, 1]], [-A[1, 0], A[0, 0]]])) % q


def perm_unitary(elements, s, q, idx_map):
    N = len(elements)
    U = np.zeros((N, N), dtype=complex)
    for i, x in enumerate(elements):
        sx = (s @ x) % q
        key = tuple(int(sx[r, c] % q) for r in range(2) for c in range(2))
        U[idx_map[key], i] = 1.0
    return U


def apply_channel(unitaries, rho):
    result = np.zeros_like(rho)
    for U in unitaries:
        result += U @ rho @ U.conj().T
    return result / len(unitaries)


def von_neumann_entropy(rho):
    eigs = np.real(np.linalg.eigvalsh(rho))
    eigs = eigs[eigs > 1e-15]
    return -np.sum(eigs * np.log2(eigs))


# Setup
q = 5
g = np.array([[0, 1], [4, 1]], dtype=int)
h = np.array([[1, 1], [0, 1]], dtype=int)

elements = gl2_fq_elements(q)
N = len(elements)
idx_map = build_idx_map(elements, q)

g_inv, h_inv = mat_inv(g, q), mat_inv(h, q)
unitaries = [perm_unitary(elements, s, q, idx_map)
             for s in [g, g_inv, h, h_inv]]

max_entropy = np.log2(N)
max_iter = 20

# Run for different initial states
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Different initial pure states
np.random.seed(42)
initial_states = []
labels = []

# State 1: computational basis |0⟩
rho0 = np.zeros((N, N), dtype=complex)
rho0[0, 0] = 1.0
initial_states.append(rho0)
labels.append('|0⟩⟨0|')

# State 2: another basis state
rho1 = np.zeros((N, N), dtype=complex)
rho1[N // 2, N // 2] = 1.0
initial_states.append(rho1)
labels.append(f'|{N//2}⟩⟨{N//2}|')

# State 3: random pure state
v = np.random.randn(N) + 1j * np.random.randn(N)
v /= np.linalg.norm(v)
rho2 = np.outer(v, v.conj())
initial_states.append(rho2)
labels.append('Random |ψ⟩')

colors = ['#2196F3', '#4CAF50', '#FF9800']

# Plot 1: Entropy growth
ax1 = axes[0]
for k, (rho_init, label, color) in enumerate(zip(initial_states, labels, colors)):
    entropies = [von_neumann_entropy(rho_init)]
    rho_curr = rho_init.copy()
    for t in range(1, max_iter + 1):
        rho_curr = apply_channel(unitaries, rho_curr)
        entropies.append(von_neumann_entropy(rho_curr))
    ax1.plot(range(max_iter + 1), entropies, 'o-', color=color,
             linewidth=2, markersize=4, label=label)

ax1.axhline(y=max_entropy, color='red', linestyle='--', linewidth=1.5,
            label=f'Max entropy = {max_entropy:.1f}')
ax1.set_xlabel('Iterations', fontsize=12)
ax1.set_ylabel('Von Neumann Entropy (bits)', fontsize=12)
ax1.set_title('Entanglement Growth', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Purity decay
ax2 = axes[1]
for k, (rho_init, label, color) in enumerate(zip(initial_states, labels, colors)):
    purities = [float(np.real(np.trace(rho_init @ rho_init)))]
    rho_curr = rho_init.copy()
    for t in range(1, max_iter + 1):
        rho_curr = apply_channel(unitaries, rho_curr)
        purities.append(float(np.real(np.trace(rho_curr @ rho_curr))))
    ax2.semilogy(range(max_iter + 1), purities, 'o-', color=color,
                 linewidth=2, markersize=4, label=label)

ax2.axhline(y=1.0 / N, color='red', linestyle='--', linewidth=1.5,
            label=f'Min purity = 1/{N}')
ax2.set_xlabel('Iterations', fontsize=12)
ax2.set_ylabel('Purity tr(ρ²)', fontsize=12)
ax2.set_title('Purity Decay', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Distance to maximally mixed
ax3 = axes[2]
rho_mm = np.eye(N, dtype=complex) / N
for k, (rho_init, label, color) in enumerate(zip(initial_states, labels, colors)):
    dists = [np.linalg.norm(rho_init - rho_mm, 'fro')]
    rho_curr = rho_init.copy()
    for t in range(1, max_iter + 1):
        rho_curr = apply_channel(unitaries, rho_curr)
        dists.append(np.linalg.norm(rho_curr - rho_mm, 'fro'))
    ax3.semilogy(range(max_iter + 1), dists, 'o-', color=color,
                 linewidth=2, markersize=4, label=label)

ax3.set_xlabel('Iterations', fontsize=12)
ax3.set_ylabel('‖ρ - ρ_mm‖_F', fontsize=12)
ax3.set_title('Distance to Maximally Mixed', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle(f'Certified Quantum Scrambling via GL₂(𝔽₅) Channel (|G|={N})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entanglement_plot.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entanglement_plot.png")
