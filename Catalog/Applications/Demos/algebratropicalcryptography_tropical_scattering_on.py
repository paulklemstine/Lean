#!/usr/bin/env python3
"""
Tropical Scattering One-Way Duality — Demonstration

This script demonstrates the core mathematical concepts from the formally
verified tropical scattering theory:
1. Min-plus (tropical) matrix multiplication and transfer matrices
2. Scattering network construction and transfer computation
3. Essential vertex detection and network reduction
4. Certified reconstruction from path-separation certificates
5. The one-way structure: easy forward, hard inverse

All computations here mirror the formally verified Lean 4 definitions.
"""

import numpy as np
from itertools import product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

INF = float('inf')

# ============================================================
# Section 1: Scattering Network and Transfer Matrix
# ============================================================

class ScatteringNetwork:
    """A tropical scattering network with m inputs, n outputs, k internal vertices.
    
    Transfer matrix: T(i,j) = min_v (inputWeights[i,v] + outputWeights[v,j])
    """
    def __init__(self, inputWeights, outputWeights):
        self.inputWeights = np.array(inputWeights, dtype=float)
        self.outputWeights = np.array(outputWeights, dtype=float)
        self.m = self.inputWeights.shape[0]
        self.k = self.inputWeights.shape[1]
        self.n = self.outputWeights.shape[1]
        assert self.outputWeights.shape[0] == self.k
    
    def path_weight(self, i, v, j):
        """Weight of path from input i through vertex v to output j."""
        return self.inputWeights[i, v] + self.outputWeights[v, j]
    
    def transfer_matrix(self):
        """Compute the transfer matrix T(i,j) = min_v path_weight(i,v,j)."""
        T = np.zeros((self.m, self.n))
        for i in range(self.m):
            for j in range(self.n):
                T[i, j] = min(self.path_weight(i, v, j) for v in range(self.k))
        return T
    
    def is_essential(self, v):
        """Check if vertex v is essential (strict unique minimizer for some pair)."""
        for i in range(self.m):
            for j in range(self.n):
                pw_v = self.path_weight(i, v, j)
                if all(pw_v < self.path_weight(i, w, j) for w in range(self.k) if w != v):
                    return True, (i, j)
        return False, None
    
    def is_reduced(self):
        """Check if every vertex is essential."""
        for v in range(self.k):
            ess, _ = self.is_essential(v)
            if not ess:
                return False
        return True
    
    def remove_vertex(self, v0):
        """Remove vertex v0, returning a network with k-1 vertices."""
        mask = [v for v in range(self.k) if v != v0]
        return ScatteringNetwork(
            self.inputWeights[:, mask],
            self.outputWeights[mask, :]
        )


def diag_realization(T):
    """Construct a diagonal realization of matrix T using n internal vertices."""
    m, n = T.shape
    M = np.max(np.abs(T))
    penalty = 2 * M + 1
    inputWeights = T.copy()
    outputWeights = np.full((n, n), penalty)
    np.fill_diagonal(outputWeights, 0.0)
    return ScatteringNetwork(inputWeights, outputWeights)


# ============================================================
# Section 2: Demonstrations
# ============================================================

def demo_basic_transfer():
    """Demonstrate basic transfer matrix computation."""
    print("=" * 60)
    print("DEMO 1: Basic Transfer Matrix Computation")
    print("=" * 60)
    
    # Network with 2 inputs, 2 outputs, 3 internal vertices
    A = np.array([[0, 10, 5],
                  [10, 0, 5]])
    B = np.array([[0, 10],
                  [10, 0],
                  [2, 2]])
    
    G = ScatteringNetwork(A, B)
    T = G.transfer_matrix()
    
    print(f"Network: {G.m} inputs, {G.n} outputs, {G.k} internal vertices")
    print(f"\nInput weights A:\n{A}")
    print(f"\nOutput weights B:\n{B}")
    print(f"\nTransfer matrix T(i,j) = min_v (A[i,v] + B[v,j]):\n{T}")
    
    # Show which vertex achieves the minimum for each pair
    print("\nMinimizer analysis:")
    for i in range(G.m):
        for j in range(G.n):
            weights = [G.path_weight(i, v, j) for v in range(G.k)]
            argmin = np.argmin(weights)
            print(f"  T({i},{j}) = {T[i,j]:.0f}, achieved by vertex {argmin} "
                  f"(weights: {[f'{w:.0f}' for w in weights]})")
    
    # Check essentiality
    print("\nVertex essentiality:")
    for v in range(G.k):
        ess, witness = G.is_essential(v)
        if ess:
            print(f"  Vertex {v}: ESSENTIAL (witness pair {witness})")
        else:
            print(f"  Vertex {v}: NOT essential")
    
    print(f"\nNetwork is {'REDUCED' if G.is_reduced() else 'NOT reduced'}")
    return T


def demo_reduction():
    """Demonstrate network reduction by removing non-essential vertices."""
    print("\n" + "=" * 60)
    print("DEMO 2: Network Reduction")
    print("=" * 60)
    
    # Network with a redundant vertex
    A = np.array([[0, 1, 0],
                  [1, 0, 1]])
    B = np.array([[0, 5],
                  [5, 0],
                  [3, 3]])
    
    G = ScatteringNetwork(A, B)
    T = G.transfer_matrix()
    
    print(f"Original network: k={G.k} vertices")
    print(f"Transfer matrix:\n{T}")
    print(f"Reduced: {G.is_reduced()}")
    
    # Find and remove non-essential vertices
    step = 0
    while not G.is_reduced() and G.k > 1:
        for v in range(G.k):
            ess, _ = G.is_essential(v)
            if not ess:
                print(f"\n  Step {step+1}: Removing non-essential vertex {v}")
                G = G.remove_vertex(v)
                T_new = G.transfer_matrix()
                print(f"  New k={G.k}, transfer preserved: {np.allclose(T, T_new)}")
                step += 1
                break
    
    print(f"\nFinal reduced network: k={G.k} vertices")
    print(f"Transfer matrix preserved: {np.allclose(T, G.transfer_matrix())}")


def demo_realization():
    """Demonstrate that every matrix is realizable."""
    print("\n" + "=" * 60)
    print("DEMO 3: Matrix Realization")
    print("=" * 60)
    
    T = np.array([[0, 3, 7],
                  [2, 1, 4],
                  [5, 8, 0]])
    
    print(f"Target matrix T:\n{T}")
    
    G = diag_realization(T)
    T_realized = G.transfer_matrix()
    
    print(f"\nDiagonal realization: k={G.k} vertices")
    print(f"Realized transfer matrix:\n{T_realized}")
    print(f"Correct: {np.allclose(T, T_realized)}")
    print(f"Reduced: {G.is_reduced()}")


def demo_one_way():
    """Demonstrate the one-way structure: easy forward, hard inverse."""
    print("\n" + "=" * 60)
    print("DEMO 4: One-Way Structure (Cryptographic)")
    print("=" * 60)
    
    np.random.seed(42)
    m, n, k = 5, 5, 8
    
    # Secret: internal structure
    A_secret = np.random.randn(m, k) * 3
    B_secret = np.random.randn(k, n) * 3
    G_secret = ScatteringNetwork(A_secret, B_secret)
    
    # Public: transfer matrix (easy to compute)
    T_public = G_secret.transfer_matrix()
    
    print(f"Secret network: {m} inputs, {n} outputs, {k} internal vertices")
    print(f"\nPublic transfer matrix (easy to compute via min-plus):")
    print(np.round(T_public, 2))
    
    # Count how many factorizations give the same transfer
    print(f"\nCryptographic properties:")
    print(f"  Forward computation (min-plus over {k} vertices): O({m}*{n}*{k}) = O({m*n*k})")
    print(f"  Reduced: {G_secret.is_reduced()}")
    
    # Show essential vertices
    essential_count = sum(1 for v in range(k) if G_secret.is_essential(v)[0])
    print(f"  Essential vertices: {essential_count}/{k}")
    print(f"  Vertex bound (reduced): k ≤ m*n = {m*n}")


def demo_certified_reconstruction():
    """Demonstrate certified reconstruction from path-separation certificates."""
    print("\n" + "=" * 60)
    print("DEMO 5: Certified Reconstruction")
    print("=" * 60)
    
    # Construct a reduced network (all vertices essential)
    A = np.array([[0, 5],
                  [5, 0]])
    B = np.array([[0, 10],
                  [10, 0]])
    
    G = ScatteringNetwork(A, B)
    T = G.transfer_matrix()
    
    print(f"Network: k={G.k}, reduced={G.is_reduced()}")
    print(f"Transfer matrix:\n{T}")
    
    # Build certificate
    print("\nPath-separation certificate:")
    for v in range(G.k):
        ess, witness = G.is_essential(v)
        if ess:
            i, j = witness
            pw_v = G.path_weight(i, v, j)
            others = [(w, G.path_weight(i, w, j)) for w in range(G.k) if w != v]
            gap = min(pw - pw_v for _, pw in others)
            print(f"  Vertex {v}: witness=({i},{j}), "
                  f"pathWeight={pw_v:.1f}, gap={gap:.1f}")


def demo_minimal_uniqueness():
    """Demonstrate that minimal realizations have unique size."""
    print("\n" + "=" * 60)
    print("DEMO 6: Minimal Realization Uniqueness")
    print("=" * 60)
    
    T = np.array([[0, 7],
                  [7, 0]])
    
    print(f"Matrix T:\n{T}")
    
    # Find minimal k by trying all sizes
    for k_try in range(1, 6):
        found = False
        for _ in range(10000):
            A = np.random.randn(2, k_try) * 5
            B = np.random.randn(k_try, 2) * 5
            G = ScatteringNetwork(A, B)
            if np.allclose(G.transfer_matrix(), T, atol=0.01):
                found = True
                print(f"  k={k_try}: Realization FOUND (reduced={G.is_reduced()})")
                break
        if not found:
            print(f"  k={k_try}: No realization found in random search")
    
    print("\nNote: Minimal realizations all have the same k (tropical inner rank)")


def create_visualization():
    """Create visualization of a scattering network."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Network diagram
    ax = axes[0]
    ax.set_title("Scattering Network Structure", fontsize=14, fontweight='bold')
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Draw inputs
    inputs = [(0, 2.5), (0, 0.5)]
    for idx, (x, y) in enumerate(inputs):
        ax.add_patch(plt.Circle((x, y), 0.2, color='steelblue', zorder=5))
        ax.text(x, y, f'i{idx}', ha='center', va='center', fontsize=10, color='white', fontweight='bold')
    
    # Draw internal vertices
    internals = [(1.5, 3), (1.5, 1.5), (1.5, 0)]
    colors = ['#e74c3c', '#2ecc71', '#f39c12']
    for idx, (x, y) in enumerate(internals):
        ax.add_patch(plt.Circle((x, y), 0.2, color=colors[idx], zorder=5))
        ax.text(x, y, f'v{idx}', ha='center', va='center', fontsize=10, color='white', fontweight='bold')
    
    # Draw outputs
    outputs = [(3, 2.5), (3, 0.5)]
    for idx, (x, y) in enumerate(outputs):
        ax.add_patch(plt.Circle((x, y), 0.2, color='purple', zorder=5))
        ax.text(x, y, f'o{idx}', ha='center', va='center', fontsize=10, color='white', fontweight='bold')
    
    # Draw edges (subset)
    A = np.array([[0, 10, 5], [10, 0, 5]])
    B = np.array([[0, 10], [10, 0], [2, 2]])
    for ii, (ix, iy) in enumerate(inputs):
        for vi, (vx, vy) in enumerate(internals):
            w = A[ii, vi]
            alpha = max(0.1, 1 - w/15)
            ax.annotate('', xy=(vx-0.2, vy), xytext=(ix+0.2, iy),
                       arrowprops=dict(arrowstyle='->', color='gray', alpha=alpha, lw=1.5))
    for vi, (vx, vy) in enumerate(internals):
        for oi, (ox, oy) in enumerate(outputs):
            w = B[vi, oi]
            alpha = max(0.1, 1 - w/15)
            ax.annotate('', xy=(ox-0.2, oy), xytext=(vx+0.2, vy),
                       arrowprops=dict(arrowstyle='->', color='gray', alpha=alpha, lw=1.5))
    
    ax.text(0, -0.3, 'Inputs', ha='center', fontsize=11, color='steelblue')
    ax.text(1.5, -0.3, 'Internal', ha='center', fontsize=11, color='gray')
    ax.text(3, -0.3, 'Outputs', ha='center', fontsize=11, color='purple')
    
    # Transfer matrix heatmap
    ax = axes[1]
    G = ScatteringNetwork(A, B)
    T = G.transfer_matrix()
    im = ax.imshow(T, cmap='YlOrRd_r', aspect='auto')
    ax.set_title("Transfer Matrix T(i,j)", fontsize=14, fontweight='bold')
    ax.set_xlabel("Output j")
    ax.set_ylabel("Input i")
    for i in range(T.shape[0]):
        for j in range(T.shape[1]):
            ax.text(j, i, f'{T[i,j]:.0f}', ha='center', va='center', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # Essential vertex analysis
    ax = axes[2]
    ax.set_title("Vertex Essentiality", fontsize=14, fontweight='bold')
    vertex_data = []
    for v in range(G.k):
        ess, witness = G.is_essential(v)
        if ess:
            i, j = witness
            gap = min(G.path_weight(i, w, j) - G.path_weight(i, v, j)
                     for w in range(G.k) if w != v)
            vertex_data.append((v, gap, True))
        else:
            vertex_data.append((v, 0, False))
    
    bars = ax.bar([f'v{d[0]}' for d in vertex_data],
                  [d[1] for d in vertex_data],
                  color=[colors[d[0]] if d[2] else 'lightgray' for d in vertex_data],
                  edgecolor='black', linewidth=1.5)
    ax.set_ylabel("Separation Gap", fontsize=12)
    ax.set_xlabel("Internal Vertex", fontsize=12)
    ax.axhline(y=0, color='black', linewidth=0.5)
    for d in vertex_data:
        ax.text(d[0], d[1] + 0.2, 'Essential' if d[2] else 'Redundant',
               ha='center', fontsize=9, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('tropical_scattering_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nVisualization saved to tropical_scattering_visualization.png")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Scattering One-Way Duality — Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    demo_basic_transfer()
    demo_reduction()
    demo_realization()
    demo_one_way()
    demo_certified_reconstruction()
    demo_minimal_uniqueness()
    create_visualization()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)
