"""
Visualization: Quantum Channel Convergence Rate

Plots the Frobenius-norm distance of the iterated quantum channel Φ^t
from the Haar twirl, compared against the theoretical (1-Δ)^t bound.
Shows exponential convergence certified by the spectral gap.

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


def apply_channel(unitaries, X):
    result = np.zeros_like(X)
    for U in unitaries:
        result += U @ X @ U.conj().T
    return result / len(unitaries)


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

# Compute spectral gap
T = np.zeros((N, N))
for i, x in enumerate(elements):
    for s in [g, g_inv, h, h_inv]:
        sx = (s @ x) % q
        key = tuple(int(sx[r, c] % q) for r in range(2) for c in range(2))
        T[idx_map[key], i] += 0.25
eigs = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
gap = 1.0 - eigs[1]

# Run convergence experiment
np.random.seed(42)
X = np.random.randn(N, N) + 1j * np.random.randn(N, N)
X -= (np.trace(X) / N) * np.eye(N, dtype=complex)
X_norm0 = np.linalg.norm(X, 'fro')

max_iter = 25
iterations = list(range(max_iter + 1))
norms = [X_norm0]
bounds = [X_norm0]

X_curr = X.copy()
for t in range(1, max_iter + 1):
    X_curr = apply_channel(unitaries, X_curr)
    norms.append(np.linalg.norm(X_curr, 'fro'))
    bounds.append((1 - gap) ** t * X_norm0)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Log-scale convergence
ax1.semilogy(iterations, norms, 'o-', color='#2196F3', linewidth=2,
             markersize=5, label='Actual ‖Φᵗ(X)‖_F')
ax1.semilogy(iterations, bounds, '--', color='#FF5722', linewidth=2,
             label=f'Bound (1−Δ)ᵗ·‖X‖_F, Δ={gap:.4f}')
ax1.set_xlabel('Iterations t', fontsize=13)
ax1.set_ylabel('Frobenius Norm', fontsize=13)
ax1.set_title(f'Quantum Channel Convergence (GL₂(𝔽₅), |G|={N})', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Right: Eigenvalue spectrum
ax2.stem(range(min(50, len(eigs))), eigs[:50], linefmt='#4CAF50',
         markerfmt='o', basefmt='gray')
ax2.axhline(y=1 - gap, color='#FF5722', linestyle='--', linewidth=2,
            label=f'1−Δ = {1-gap:.4f}')
ax2.axhline(y=1.0, color='#2196F3', linestyle=':', linewidth=1,
            label='λ₁ = 1')
ax2.set_xlabel('Eigenvalue Index', fontsize=13)
ax2.set_ylabel('Eigenvalue', fontsize=13)
ax2.set_title('Walk Operator Eigenvalues', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_plot.png")
