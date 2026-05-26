"""
Visualization: Spectral Gaps Across Dimensions

Computes and plots the spectral gap γ(n) for clock-shift quantum expanders
as a function of dimension n. Shows how the gap varies and compares with
the Singer condition bound δ/4.

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


def compute_spectral_gap(U, V, n):
    dim = n * n
    S = np.zeros((dim, dim), dtype=complex)
    for i in range(n):
        for j in range(n):
            E = np.zeros((n, n), dtype=complex)
            E[i, j] = 1.0
            PhiE = quantum_channel(U, V, E)
            S[:, i*n+j] = PhiE.flatten()
    evals = np.sort(np.real(np.linalg.eigvals(S)))[::-1]
    return 1 - evals[1], evals


dims = list(range(2, 16))
gaps = []
min_abs_evals = []

for n in dims:
    U, V = construct_clock_shift(n)
    gap, evals = compute_spectral_gap(U, V, n)
    gaps.append(gap)
    # Maximum absolute eigenvalue on traceless subspace
    abs_evals = np.abs(evals[1:])
    min_abs_evals.append(1 - max(abs_evals))

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: spectral gap vs dimension
ax1 = axes[0]
ax1.plot(dims, gaps, 'bo-', markersize=6, linewidth=2, label='Spectral gap γ')
ax1.plot(dims, min_abs_evals, 'rs--', markersize=5, linewidth=1.5, 
         label='1 - max|λ| (norm gap)')
ax1.set_xlabel('Dimension n', fontsize=12)
ax1.set_ylabel('Gap', fontsize=12)
ax1.set_title('Quantum Expander Spectral Gap vs Dimension', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Right panel: full spectrum for several dimensions
ax2 = axes[1]
for n in [2, 3, 5, 8]:
    U, V = construct_clock_shift(n)
    _, evals = compute_spectral_gap(U, V, n)
    y_pos = [n] * len(evals)
    ax2.scatter(evals, y_pos, s=30, alpha=0.7, label=f'n={n}')

ax2.axvline(x=1, color='green', linewidth=1, linestyle='--', alpha=0.5)
ax2.axvline(x=-1, color='red', linewidth=1, linestyle='--', alpha=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5, linestyle='-', alpha=0.3)
ax2.set_xlabel('Eigenvalue', fontsize=12)
ax2.set_ylabel('Dimension n', fontsize=12)
ax2.set_title('Eigenvalue Spectra of Φ', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualization_spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved visualization_spectral_gaps.png")
