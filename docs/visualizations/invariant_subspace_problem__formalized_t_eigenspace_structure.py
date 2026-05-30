#!/usr/bin/env python3
"""
Visualization: Eigenspace Structure and Invariant Subspace Decomposition

Visualizes how eigenspaces of a self-adjoint operator decompose the space
into orthogonal invariant sectors (reducing subspaces). Shows the connection
to quantum measurement theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D


def create_eigenspace_visualization():
    fig = plt.figure(figsize=(16, 12))
    
    # --- Panel 1: Eigenspace decomposition in 3D ---
    ax1 = fig.add_subplot(221, projection='3d')
    
    # Self-adjoint operator with eigenvalues 1, 2, 3
    eigenvalues = [1, 2, 3]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    # Draw eigenspace planes
    for i, (ev, color) in enumerate(zip(eigenvalues, colors)):
        if i == 0:
            # E_1: xy-plane (z=0)
            xx, yy = np.meshgrid(np.linspace(-1, 1, 10), np.linspace(-1, 1, 10))
            zz = np.zeros_like(xx)
            ax1.plot_surface(xx, yy, zz, alpha=0.15, color=color)
            ax1.text(0.8, 0.8, 0.1, f'$E_{{{ev}}}$', fontsize=14, color=color, fontweight='bold')
        elif i == 1:
            # E_2: xz-plane (y=0)
            xx, zz = np.meshgrid(np.linspace(-1, 1, 10), np.linspace(-1, 1, 10))
            yy = np.zeros_like(xx)
            ax1.plot_surface(xx, yy, zz, alpha=0.15, color=color)
            ax1.text(0.8, 0.1, 0.8, f'$E_{{{ev}}}$', fontsize=14, color=color, fontweight='bold')
        else:
            # E_3: yz-plane (x=0)
            yy, zz = np.meshgrid(np.linspace(-1, 1, 10), np.linspace(-1, 1, 10))
            xx = np.zeros_like(yy)
            ax1.plot_surface(xx, yy, zz, alpha=0.15, color=color)
            ax1.text(0.1, 0.8, 0.8, f'$E_{{{ev}}}$', fontsize=14, color=color, fontweight='bold')
    
    # Draw eigenvectors
    origin = [0, 0, 0]
    dirs = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    for d, color in zip(dirs, colors):
        ax1.quiver(*origin, *d, color=color, arrow_length_ratio=0.1, linewidth=2)
    
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('z')
    ax1.set_title('Eigenspace Decomposition\n$H = E_1 \\oplus E_2 \\oplus E_3$', fontsize=13)
    
    # --- Panel 2: Eigenvalue spectrum of compact operator ---
    ax2 = fig.add_subplot(222)
    
    # Simulate compact operator spectrum (eigenvalues → 0)
    N = 200
    x = np.linspace(0, 1, N)
    dx = 1.0 / N
    K = np.exp(-10 * (x[:, None] - x[None, :]) ** 2) * dx
    evals = np.sort(np.linalg.eigvalsh(K))[::-1]
    
    ax2.semilogy(range(1, len(evals) + 1), np.abs(evals), 'b-', linewidth=1.5)
    ax2.axhline(y=1e-6, color='r', linestyle='--', alpha=0.7, label='Threshold')
    n_sig = np.sum(np.abs(evals) > 1e-6)
    ax2.axvline(x=n_sig, color='g', linestyle='--', alpha=0.7, label=f'dim(E_{{μ≠0}}) ≈ {n_sig}')
    ax2.set_xlabel('Index', fontsize=12)
    ax2.set_ylabel('|Eigenvalue|', fontsize=12)
    ax2.set_title('Compact Operator Spectrum\n(eigenvalues accumulate at 0)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 50)
    ax2.grid(True, alpha=0.3)
    
    # --- Panel 3: Orthogonality of eigenspaces ---
    ax3 = fig.add_subplot(223)
    
    # 6×6 Hermitian matrix
    np.random.seed(42)
    A = np.random.randn(6, 6) + 1j * np.random.randn(6, 6)
    H_mat = (A + A.conj().T) / 2
    evals, evecs = np.linalg.eig(H_mat)
    
    # Gram matrix |⟨v_i, v_j⟩|
    gram = np.abs(evecs.conj().T @ evecs)
    
    im = ax3.imshow(gram, cmap='RdYlBu_r', vmin=0, vmax=1)
    plt.colorbar(im, ax=ax3, label='$|\\langle v_i, v_j \\rangle|$')
    ax3.set_xlabel('Eigenvector index', fontsize=12)
    ax3.set_ylabel('Eigenvector index', fontsize=12)
    ax3.set_title('Eigenspace Orthogonality\n(self-adjoint ⟹ diagonal Gram matrix)', fontsize=13)
    
    # --- Panel 4: Reducing subspace diagram ---
    ax4 = fig.add_subplot(224)
    
    # Draw the space decomposition
    theta = np.linspace(0, 2 * np.pi, 100)
    ax4.plot(2 * np.cos(theta), 2 * np.sin(theta), 'k-', linewidth=2)
    ax4.fill(2 * np.cos(theta), 2 * np.sin(theta), alpha=0.05, color='gray')
    
    # M (reducing subspace)
    ax4.fill_between([-2, 2], [-0.4, -0.4], [0.4, 0.4], alpha=0.3, color='#3498db', label='$M$ (reducing)')
    
    # M⊥
    ax4.fill_between([-0.4, 0.4], [-2, -2], [2, 2], alpha=0.3, color='#e74c3c', label='$M^\\perp$ (also invariant)')
    
    # Arrows showing T maps each to itself
    ax4.annotate('', xy=(1.5, 0.2), xytext=(0.5, 0.2),
                arrowprops=dict(arrowstyle='->', color='#3498db', lw=2))
    ax4.text(1.0, 0.35, '$T$', fontsize=14, color='#3498db', ha='center')
    
    ax4.annotate('', xy=(0.2, 1.5), xytext=(0.2, 0.5),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
    ax4.text(0.4, 1.0, '$T$', fontsize=14, color='#e74c3c', ha='center')
    
    ax4.set_xlim(-2.5, 2.5)
    ax4.set_ylim(-2.5, 2.5)
    ax4.set_aspect('equal')
    ax4.legend(fontsize=11, loc='lower right')
    ax4.set_title('Reducing Subspace\n$T(M) \\subseteq M$ and $T(M^\\perp) \\subseteq M^\\perp$', fontsize=13)
    ax4.axis('off')
    
    plt.tight_layout()
    plt.savefig('eigenspace_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eigenspace_structure.png")


if __name__ == "__main__":
    create_eigenspace_visualization()
