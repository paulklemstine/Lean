#!/usr/bin/env python3
"""
Visualization: Spectral Embedding — Eigenvalue Landscape

Visualizes the core theorem: the Lorentzian leaf condition of P_A = t²·Q_A(x)
is equivalent to A having at most one positive eigenvalue.

Shows:
1. Heatmap of the block-zero-extended Hessian
2. Eigenvalue spectrum comparison: A vs. its block extension
3. Quadratic form level curves on a 2D section

Must be fully self-contained — no imports from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def eigenvalue_inertia(A, tol=1e-10):
    evals = np.linalg.eigvalsh(A)
    return (int(np.sum(evals > tol)), 
            int(np.sum(np.abs(evals) <= tol)),
            int(np.sum(evals < -tol)))


def block_zero_extend(A):
    n = A.shape[0]
    B = np.zeros((n + 1, n + 1))
    B[1:, 1:] = A
    return B


def quadratic_form_2d(A, u, v, s_range, t_range):
    """Evaluate Q_A(s·u + t·v) on a grid."""
    S, T = np.meshgrid(s_range, t_range)
    Q = np.zeros_like(S)
    for i in range(A.shape[0]):
        for j in range(A.shape[0]):
            Q += A[i, j] * (S * u[i] + T * v[i]) * (S * u[j] + T * v[j])
    return S, T, Q


# ── Create figure ──
fig = plt.figure(figsize=(16, 12))
fig.suptitle("Spectral Embedding: Matrix Positivity → Lorentzian Leaves\n"
             r"$P_A(t, x) = t^2 \cdot Q_A(x)$, Lorentzian$(P_A) \Leftrightarrow$ "
             "at most 1 positive eigenvalue",
             fontsize=14, fontweight='bold')

gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# ── Matrices to test ──
matrices = [
    (np.diag([3.0, -1.0, -2.0]), "diag(3, −1, −2)\n1 positive eigenvalue\n→ LORENTZIAN"),
    (np.diag([2.0, 1.0, -3.0]), "diag(2, 1, −3)\n2 positive eigenvalues\n→ NOT LORENTZIAN"),
    (np.array([[1, 2, 0], [2, -1, 1], [0, 1, -3.0]]), "Mixed symmetric\nCheck eigenvalues"),
]

# ── Row 1: Hessian heatmaps ──
for col, (A, title) in enumerate(matrices):
    ax = fig.add_subplot(gs[0, col])
    B = 2 * block_zero_extend(A)  # Hessian of critical leaf
    
    vmax = max(abs(B.min()), abs(B.max())) or 1
    im = ax.imshow(B, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                   interpolation='nearest', aspect='equal')
    
    n = B.shape[0]
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{B[i,j]:.1f}', ha='center', va='center',
                    fontsize=8, color='black' if abs(B[i,j]) < vmax*0.5 else 'white')
    
    evals = np.linalg.eigvalsh(A)
    n_pos = np.sum(evals > 1e-10)
    is_lor = n_pos <= 1
    
    ax.set_title(title, fontsize=10, 
                 color='green' if is_lor else 'red',
                 fontweight='bold')
    ax.set_xlabel("Column index")
    ax.set_ylabel("Row index")
    
    # Add eigenvalue annotation
    evals_str = ", ".join(f"{e:.2f}" for e in sorted(evals)[::-1])
    ax.text(0.5, -0.15, f"λ(A) = [{evals_str}]",
            transform=ax.transAxes, ha='center', fontsize=8)

# ── Row 2: Quadratic form contours ──
for col, (A, title) in enumerate(matrices):
    ax = fig.add_subplot(gs[1, col])
    
    n = A.shape[0]
    # Use first two standard basis vectors for 2D section
    u = np.zeros(n); u[0] = 1
    v = np.zeros(n); v[1] = 1
    
    s_range = np.linspace(-2, 2, 200)
    t_range = np.linspace(-2, 2, 200)
    S, T, Q = quadratic_form_2d(A, u, v, s_range, t_range)
    
    # Contour plot
    levels = np.linspace(-10, 10, 21)
    cs = ax.contourf(S, T, Q, levels=levels, cmap='RdBu_r', extend='both')
    ax.contour(S, T, Q, levels=[0], colors='black', linewidths=2)
    
    evals = np.linalg.eigvalsh(A)
    n_pos = np.sum(evals > 1e-10)
    is_lor = n_pos <= 1
    
    status = "LORENTZIAN ✓" if is_lor else "NOT LORENTZIAN ✗"
    ax.set_title(f"$Q_A(s e_1 + t e_2)$\n{status}",
                 fontsize=10, color='green' if is_lor else 'red',
                 fontweight='bold')
    ax.set_xlabel("s")
    ax.set_ylabel("t")
    ax.set_aspect('equal')
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    
    plt.colorbar(cs, ax=ax, shrink=0.8, label=r"$Q_A$")

plt.savefig("spectral_embedding_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: spectral_embedding_visualization.png")
