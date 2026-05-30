#!/usr/bin/env python3
"""
Visualization: Subspace Iteration Convergence

Shows how subspace iteration converges to invariant subspaces,
demonstrating the computational testability of the ISP conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import qr, norm, eig


def subspace_iteration(T, dim, max_iter=200):
    """Run subspace iteration and record convergence."""
    n = T.shape[0]
    V = np.random.randn(n, dim) + 1j * np.random.randn(n, dim)
    V, _ = qr(V, mode='reduced')
    V = V[:, :dim]
    
    angles = []
    leakages = []
    
    for _ in range(max_iter):
        TV = T @ V
        V_new, _ = qr(TV, mode='reduced')
        V_new = V_new[:, :dim]
        
        # Subspace angle
        P_old = V @ V.conj().T
        P_new = V_new @ V_new.conj().T
        angles.append(norm(P_new - P_old))
        
        # Invariance leakage
        P_perp = np.eye(n) - P_new
        leakages.append(norm(P_perp @ T @ V_new))
        
        V = V_new
    
    return V, angles, leakages


def create_convergence_visualization():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    np.random.seed(42)
    
    # --- Panel 1: Convergence for different operator types ---
    ax1 = axes[0, 0]
    n = 30
    
    # Self-adjoint
    A = np.random.randn(n, n)
    H = (A + A.T) / 2
    _, angles_sa, _ = subspace_iteration(H + 0j, dim=3)
    ax1.semilogy(angles_sa, label='Self-adjoint', linewidth=2, color='#3498db')
    
    # Normal (unitary-like)
    Q, _ = qr(np.random.randn(n, n) + 1j * np.random.randn(n, n))
    D = np.diag(np.exp(1j * np.sort(np.random.rand(n) * 2 * np.pi)))
    N_mat = Q @ D @ Q.conj().T
    _, angles_norm, _ = subspace_iteration(N_mat, dim=3)
    ax1.semilogy(angles_norm, label='Normal', linewidth=2, color='#2ecc71')
    
    # Generic
    G = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    _, angles_gen, _ = subspace_iteration(G, dim=3)
    ax1.semilogy(angles_gen, label='Generic', linewidth=2, color='#e74c3c')
    
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Subspace angle change', fontsize=12)
    ax1.set_title('Convergence Rate by Operator Type', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # --- Panel 2: Invariance leakage over iterations ---
    ax2 = axes[0, 1]
    
    _, _, leak_sa = subspace_iteration(H + 0j, dim=3)
    _, _, leak_gen = subspace_iteration(G, dim=3)
    
    ax2.semilogy(leak_sa, label='Self-adjoint', linewidth=2, color='#3498db')
    ax2.semilogy(leak_gen, label='Generic', linewidth=2, color='#e74c3c')
    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('$\\|P_{M^\\perp} T M\\|$ (leakage)', fontsize=12)
    ax2.set_title('Invariance Leakage During Iteration', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # --- Panel 3: Effect of target dimension ---
    ax3 = axes[1, 0]
    
    for dim in [1, 3, 5, 10]:
        _, angles, _ = subspace_iteration(H + 0j, dim=dim)
        ax3.semilogy(angles, label=f'dim = {dim}', linewidth=1.5)
    
    ax3.set_xlabel('Iteration', fontsize=12)
    ax3.set_ylabel('Subspace angle change', fontsize=12)
    ax3.set_title('Convergence vs Target Dimension\n(self-adjoint operator)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    
    # --- Panel 4: Truncation test for ISP conjecture ---
    ax4 = axes[1, 1]
    
    # Weighted shift operator (truncated)
    truncation_sizes = [10, 20, 50, 100, 200]
    min_leakages = []
    
    for n in truncation_sizes:
        # Weighted shift: T e_k = w_k e_{k+1}
        weights = 1.0 / (np.arange(1, n) + 1)  # Decreasing weights
        T_shift = np.zeros((n, n))
        for k in range(n - 1):
            T_shift[k + 1, k] = weights[k]
        
        # Find best 1D invariant subspace by eigenvector
        evals, evecs = eig(T_shift)
        best_leak = np.inf
        for i in range(n):
            v = evecs[:, i:i+1]
            P_perp = np.eye(n) - v @ v.conj().T
            leak = norm(P_perp @ T_shift @ v)
            best_leak = min(best_leak, leak)
        min_leakages.append(best_leak)
    
    ax4.semilogy(truncation_sizes, min_leakages, 'ko-', linewidth=2, markersize=8)
    ax4.set_xlabel('Truncation size N', fontsize=12)
    ax4.set_ylabel('Best invariance leakage', fontsize=12)
    ax4.set_title('ISP Conjecture Test:\nWeighted Shift Truncations', fontsize=13)
    ax4.grid(True, alpha=0.3)
    ax4.text(0.5, 0.95, 'Leakage → 0 supports ISP conjecture',
             transform=ax4.transAxes, fontsize=10, va='top', ha='center',
             style='italic', color='#2c3e50')
    
    plt.tight_layout()
    plt.savefig('subspace_iteration.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: subspace_iteration.png")


if __name__ == "__main__":
    create_convergence_visualization()
