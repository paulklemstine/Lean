"""
Visualization: Quantum Expander Convergence

Shows how the quantum averaging channel drives arbitrary quantum states
toward the maximally mixed state. Plots the Frobenius distance ‖ρ_k - I/n‖²
as a function of iteration k for multiple dimensions and initial states.

CRITICAL: This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def quantum_channel(U, V, rho):
    Ud, Vd = U.conj().T, V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)


def construct_clock_shift(n):
    omega = np.exp(2j * np.pi / n)
    U = np.diag([omega**k for k in range(n)])
    V = np.zeros((n, n), dtype=complex)
    for i in range(n):
        V[i, (i + 1) % n] = 1.0
    return U, V


def frobenius_dist_sq(A, B):
    D = A - B
    return np.real(np.trace(D.conj().T @ D))


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: convergence for different dimensions
ax1 = axes[0]
for n in [2, 3, 4, 5, 8]:
    U, V = construct_clock_shift(n)
    target = np.eye(n, dtype=complex) / n
    
    # Pure state |0⟩⟨0|
    rho = np.zeros((n, n), dtype=complex)
    rho[0, 0] = 1.0
    
    dists = []
    K = 30
    for k in range(K):
        dists.append(frobenius_dist_sq(rho, target))
        rho = quantum_channel(U, V, rho)
    
    ax1.semilogy(range(K), dists, 'o-', markersize=3, label=f'n = {n}')

ax1.set_xlabel('Iteration k', fontsize=12)
ax1.set_ylabel('‖ρ_k - I/n‖²_F', fontsize=12)
ax1.set_title('Convergence to Maximally Mixed State', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right panel: eigenvalue spectrum for n=4
ax2 = axes[1]
n = 4
U, V = construct_clock_shift(n)
dim = n * n
S = np.zeros((dim, dim), dtype=complex)
for i in range(n):
    for j in range(n):
        E = np.zeros((n, n), dtype=complex)
        E[i, j] = 1.0
        PhiE = quantum_channel(U, V, E)
        S[:, i*n+j] = PhiE.flatten()

evals = np.sort(np.real(np.linalg.eigvals(S)))[::-1]
colors = ['#2ecc71' if abs(e - 1.0) < 0.01 else '#3498db' if e > 0 else '#e74c3c' for e in evals]
ax2.bar(range(len(evals)), evals, color=colors, alpha=0.8)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.axhline(y=1, color='green', linewidth=1, linestyle='--', alpha=0.5, label='Fixed point λ=1')
gap = 1 - evals[1]
ax2.axhline(y=evals[1], color='orange', linewidth=1, linestyle='--', alpha=0.7, 
            label=f'λ₂ = {evals[1]:.3f} (gap γ = {gap:.3f})')
ax2.set_xlabel('Eigenvalue index', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Spectrum of Φ (n={n}, Clock-Shift)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualization_convergence.png', dpi=150, bbox_inches='tight')
print("Saved visualization_convergence.png")
