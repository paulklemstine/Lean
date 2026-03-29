#!/usr/bin/env python3
"""
Demo 2: Tropical Matrix Eigenvalues — The Mirror Image

In tropical algebra, matrix "multiplication" uses (max, +) instead of (+, ×).
The tropical eigenvalue of a matrix is the maximum cycle mean, and the
eigenvector is the "mirror image" — the stable self-referential state.

This demo computes tropical eigenvalues and visualizes the convergence
of tropical matrix powers to a stable "mirror state."
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 150

NEG_INF = -1e10  # Stand-in for -∞ in tropical algebra


def tropical_add(a, b):
    """Tropical addition: max(a, b)."""
    return max(a, b)


def tropical_mult(a, b):
    """Tropical multiplication: a + b (classical)."""
    if a <= NEG_INF or b <= NEG_INF:
        return NEG_INF
    return a + b


def tropical_matmul(A, B):
    """Tropical matrix multiplication: C[i,j] = max_k(A[i,k] + B[k,j])."""
    n = A.shape[0]
    m = B.shape[1]
    p = A.shape[1]
    C = np.full((n, m), NEG_INF)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                val = tropical_mult(A[i, k], B[k, j])
                C[i, j] = tropical_add(C[i, j], val)
    return C


def tropical_matvec(A, x):
    """Tropical matrix-vector product: y[i] = max_j(A[i,j] + x[j])."""
    n = A.shape[0]
    y = np.full(n, NEG_INF)
    for i in range(n):
        for j in range(A.shape[1]):
            val = tropical_mult(A[i, j], x[j])
            y[i] = tropical_add(y[i], val)
    return y


def tropical_eigenvalue(A):
    """Compute the tropical eigenvalue (maximum cycle mean) of a square matrix."""
    n = A.shape[0]
    max_mean = NEG_INF
    
    # Check all cycle lengths from 1 to n
    for length in range(1, n + 1):
        # For each possible cycle of this length
        # Use dynamic programming: compute A^k and look at diagonal
        Ak = np.copy(A)
        for _ in range(length - 1):
            Ak = tropical_matmul(Ak, A)
        
        for i in range(n):
            if Ak[i, i] > NEG_INF:
                cycle_mean = Ak[i, i] / length
                max_mean = max(max_mean, cycle_mean)
    
    return max_mean


def demo_tropical_eigenvalue():
    """Compute and visualize tropical eigenvalues."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # --- Example matrices ---
    matrices = [
        np.array([[0, 3, NEG_INF],
                  [NEG_INF, 0, 2],
                  [1, NEG_INF, 0]]),
        np.array([[1, 4, 2],
                  [3, 0, 1],
                  [2, 3, 0]]),
        np.array([[0, 1],
                  [2, 0]])
    ]
    titles = ['Sparse 3×3', 'Dense 3×3', 'Simple 2×2']
    
    for idx, (A, title) in enumerate(zip(matrices, titles)):
        ax = axes[idx]
        n = A.shape[0]
        
        # Compute tropical eigenvalue
        lam = tropical_eigenvalue(A)
        
        # Iterate: x_{k+1} = A ⊗ x_k - λ (normalized)
        x = np.zeros(n)
        trajectories = [x.copy()]
        
        for step in range(15):
            y = tropical_matvec(A, x)
            x = y - lam  # Normalize by subtracting eigenvalue
            trajectories.append(x.copy())
        
        trajectories = np.array(trajectories)
        
        for i in range(n):
            ax.plot(trajectories[:, i], 'o-', label=f'x[{i}]', markersize=5, linewidth=1.5)
        
        ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='-')
        ax.set_title(f'{title}\nλ_trop = {lam:.2f}', fontsize=13, fontweight='bold')
        ax.set_xlabel('Iteration')
        ax.set_ylabel('Normalized Component')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        
        # Show the matrix
        mat_str = 'A = '
        for i in range(n):
            row = [f'{A[i,j]:.0f}' if A[i,j] > NEG_INF else '-∞' for j in range(n)]
            mat_str += '[' + ','.join(row) + ']'
            if i < n - 1:
                mat_str += '\n      '
        ax.text(0.95, 0.95, mat_str, transform=ax.transAxes, fontsize=8,
                verticalalignment='top', horizontalalignment='right',
                fontfamily='monospace', bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.suptitle('Tropical Matrix Eigenvalues: The Mirror Image\n'
                 'Normalized tropical power iteration converges to the eigenvector',
                 fontsize=15, fontweight='bold', y=1.05)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo2_tropical_eigenvalue.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo2_tropical_eigenvalue.png")


def demo_tropical_power_convergence():
    """Show how tropical matrix powers converge (the mirror stabilizes)."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    
    A = np.array([[0, 3, 1],
                  [2, 0, 4],
                  [1, 3, 0]])
    
    lam = tropical_eigenvalue(A)
    
    # Compute A^k for k = 1, ..., 6
    Ak = np.eye(3) * 0  # Tropical identity (0 on diagonal, -inf off)
    for i in range(3):
        for j in range(3):
            if i != j:
                Ak[i, j] = NEG_INF
    
    powers = []
    for k in range(6):
        Ak = tropical_matmul(Ak, A)
        # Normalize: subtract k*lambda from each entry
        Ak_norm = Ak - (k + 1) * lam
        powers.append(Ak_norm.copy())
    
    for k, (Ak_norm, ax) in enumerate(zip(powers, axes.flat)):
        im = ax.imshow(Ak_norm, cmap='RdYlBu_r', vmin=-5, vmax=5)
        ax.set_title(f'A^{k+1} / λ^{k+1}\n(Power {k+1})', fontsize=12, fontweight='bold')
        
        n = Ak_norm.shape[0]
        for i in range(n):
            for j in range(n):
                val = Ak_norm[i, j]
                ax.text(j, i, f'{val:.1f}', ha='center', va='center', fontsize=10,
                        color='white' if abs(val) > 2.5 else 'black')
        
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    
    plt.suptitle(f'Tropical Matrix Powers Converge\n'
                 f'A^k normalized by λ^k (λ_trop = {lam:.2f}) → stable mirror image',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo2_power_convergence.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo2_power_convergence.png")


def demo_cycle_means():
    """Visualize the cycle structure that determines tropical eigenvalues."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # 4-node directed graph with weights
    n = 4
    positions = {
        0: (1, 3),
        1: (3, 3),
        2: (3, 1),
        3: (1, 1)
    }
    
    edges = [
        (0, 1, 3), (1, 2, 2), (2, 3, 4), (3, 0, 1),  # Outer cycle
        (0, 2, 5), (1, 3, 1),  # Diagonals
        (0, 0, 2), (2, 2, 3),  # Self-loops
    ]
    
    # Draw nodes
    for node, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.3, color='steelblue', ec='navy', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(node), ha='center', va='center', fontsize=16,
                fontweight='bold', color='white', zorder=6)
    
    # Draw edges with weights
    for (i, j, w) in edges:
        xi, yi = positions[i]
        xj, yj = positions[j]
        
        if i == j:  # Self-loop
            angle = 45 if i < 2 else -45
            loop = mpatches.FancyArrowPatch(
                (xi + 0.2, yi + 0.25), (xi - 0.2, yi + 0.25),
                connectionstyle=f"arc3,rad=-0.8",
                arrowstyle='->', mutation_scale=15,
                color='darkred', linewidth=2, zorder=3)
            ax.add_patch(loop)
            ax.text(xi, yi + 0.7, f'w={w}', ha='center', fontsize=10, color='darkred')
        else:
            dx, dy = xj - xi, yj - yi
            length = np.sqrt(dx**2 + dy**2)
            # Shorten arrow to not overlap with nodes
            shrink = 0.35 / length
            ax.annotate('', xy=(xj - dx*shrink, yj - dy*shrink),
                        xytext=(xi + dx*shrink, yi + dy*shrink),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5),
                        zorder=3)
            # Weight label
            mx, my = (xi + xj) / 2, (yi + yj) / 2
            # Offset perpendicular to edge
            nx, ny = -dy / length * 0.2, dx / length * 0.2
            ax.text(mx + nx, my + ny, f'{w}', ha='center', va='center',
                    fontsize=11, fontweight='bold', color='darkgreen',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.9))
    
    # Highlight the maximum cycle mean
    ax.text(2, 0.2, 'Tropical eigenvalue = max cycle mean\n'
                     'Cycle 0→1→2→3→0: mean = (3+2+4+1)/4 = 2.5\n'
                     'Self-loop 2→2: mean = 3/1 = 3.0  ← MAXIMUM\n'
                     'λ_trop = 3.0',
            ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange', alpha=0.9))
    
    ax.set_xlim(0, 4)
    ax.set_ylim(-0.2, 4.2)
    ax.set_aspect('equal')
    ax.set_title('Tropical Eigenvalue = Maximum Cycle Mean\n'
                 'The "mirror image" is the dominant cycle',
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo2_cycle_means.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo2_cycle_means.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Demo 2: Tropical Matrix Eigenvalues")
    print("=" * 60)
    demo_tropical_eigenvalue()
    demo_tropical_power_convergence()
    demo_cycle_means()
    print("\nAll Demo 2 visualizations generated successfully!")
