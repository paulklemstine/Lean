#!/usr/bin/env python3
"""
Complex Weighted Random Graphs: Numerical Demonstrations

This script demonstrates the key results from the spectral theory of complex-weighted
random graphs G(n, z), verifying:

1. Scalar Factorization: A_z = z * B
2. Trace Identity: tr(A_z) = 0
3. Normality: A_z * A_z^H = A_z^H * A_z
4. Spectral Collinearity: eigenvalues lie on a line through the origin
5. Walk Phase Accumulation: A_z^k = z^k * B^k
6. Frobenius Norm Identity: tr(A_z^H * A_z) = |z|^2 * edge_count
7. Comparison: directed vs undirected complex graphs
"""

import numpy as np
from typing import Tuple

np.random.seed(42)


def generate_complex_weighted_graph(
    n: int, z: complex, p: float = 0.5
) -> Tuple[np.ndarray, np.ndarray]:
    """Generate a random complex weighted graph G(n, z) with edge probability p.
    
    Returns:
        A_z: The complex-weighted adjacency matrix (n x n)
        B: The Boolean adjacency matrix (n x n)
    """
    # Generate symmetric Boolean adjacency matrix
    upper = np.random.random((n, n)) < p
    B = np.triu(upper, k=1)
    B = B + B.T  # symmetrize
    B = B.astype(float)
    np.fill_diagonal(B, 0)  # no self-loops
    
    A_z = z * B
    return A_z, B


def generate_directed_complex_graph(
    n: int, z: complex, p: float = 0.5
) -> Tuple[np.ndarray, np.ndarray]:
    """Generate a random DIRECTED complex weighted graph.
    
    Returns:
        A_z: The directed complex-weighted adjacency matrix
        B: The directed Boolean adjacency matrix
    """
    B = (np.random.random((n, n)) < p).astype(float)
    np.fill_diagonal(B, 0)
    A_z = z * B
    return A_z, B


def demo_scalar_factorization(n: int = 100, z: complex = 0.5 + 0.3j):
    """Verify A_z = z * B."""
    print("=" * 60)
    print("Demo 1: Scalar Factorization  A_z = z * B")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    diff = np.max(np.abs(A_z - z * B))
    print(f"  n = {n}, z = {z}")
    print(f"  max|A_z - z*B| = {diff:.2e}")
    print(f"  ✓ Scalar factorization verified" if diff < 1e-14 else "  ✗ FAILED")
    print()


def demo_trace_identity(n: int = 200, z: complex = 1 + 2j):
    """Verify tr(A_z) = 0."""
    print("=" * 60)
    print("Demo 2: Trace Identity  tr(A_z) = 0")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    trace = np.trace(A_z)
    print(f"  n = {n}, z = {z}")
    print(f"  tr(A_z) = {trace}")
    print(f"  ✓ Trace is zero" if abs(trace) < 1e-12 else "  ✗ FAILED")
    print()


def demo_normality(n: int = 100, z: complex = 0.5 + 0.3j):
    """Verify A_z * A_z^H = A_z^H * A_z (normality)."""
    print("=" * 60)
    print("Demo 3: Normality  A·A* = A*·A")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    AH = A_z.conj().T
    diff = np.max(np.abs(A_z @ AH - AH @ A_z))
    print(f"  n = {n}, z = {z}")
    print(f"  max|A·A* - A*·A| = {diff:.2e}")
    print(f"  ✓ Matrix is normal" if diff < 1e-10 else "  ✗ FAILED")
    print()


def demo_spectral_collinearity(n: int = 200, z: complex = 0.5 + 0.3j):
    """Verify eigenvalues lie on a line through the origin."""
    print("=" * 60)
    print("Demo 4: Spectral Collinearity")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    
    eigenvalues = np.linalg.eigvals(A_z)
    
    # Check collinearity: eigenvalues/z should be real
    scaled = eigenvalues / z
    max_imag = np.max(np.abs(scaled.imag))
    
    print(f"  n = {n}, z = {z}")
    print(f"  Number of eigenvalues: {len(eigenvalues)}")
    print(f"  max|Im(λ/z)| = {max_imag:.2e}")
    print(f"  ✓ Eigenvalues are collinear" if max_imag < 1e-8 else "  ✗ FAILED")
    
    # Direction
    direction = np.angle(z)
    eig_angles = np.angle(eigenvalues[np.abs(eigenvalues) > 0.1])
    # Angles should be ~direction or ~direction + pi
    angle_residuals = np.minimum(
        np.abs(eig_angles - direction) % (2 * np.pi),
        np.abs(eig_angles - direction - np.pi) % (2 * np.pi)
    )
    max_residual = np.max(angle_residuals)
    print(f"  Direction arg(z) = {np.degrees(direction):.1f}°")
    print(f"  Max angle deviation from ray: {np.degrees(max_residual):.2e}°")
    print()


def demo_directed_vs_undirected(n: int = 500, z: complex = 0.5 + 0.3j):
    """Compare eigenvalue distributions: undirected (line) vs directed (disk)."""
    print("=" * 60)
    print("Demo 5: Directed vs Undirected")
    print("=" * 60)
    
    # Undirected
    A_u, _ = generate_complex_weighted_graph(n, z)
    eig_u = np.linalg.eigvals(A_u)
    scaled_u = eig_u / z
    imag_spread_u = np.std(scaled_u.imag)
    
    # Directed
    A_d, _ = generate_directed_complex_graph(n, z)
    eig_d = np.linalg.eigvals(A_d)
    
    # For directed, eigenvalues should fill a 2D region
    imag_spread_d = np.std(eig_d.imag)
    
    print(f"  n = {n}, z = {z}")
    print(f"  Undirected: std(Im(λ/z)) = {imag_spread_u:.2e} (should be ~0)")
    print(f"  Directed:   std(Im(λ))   = {imag_spread_d:.2f} (should be >> 0)")
    print(f"  ✓ Directed eigenvalues spread into 2D" if imag_spread_d > 1 else "  Note: spread is small")
    print()


def demo_walk_phase(n: int = 50, z: complex = 0.5 + 0.3j, max_k: int = 5):
    """Verify A_z^k = z^k * B^k for several k."""
    print("=" * 60)
    print("Demo 6: Walk Phase Accumulation  A^k = z^k · B^k")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    
    for k in range(1, max_k + 1):
        A_k = np.linalg.matrix_power(A_z, k)
        B_k = np.linalg.matrix_power(B, k)
        diff = np.max(np.abs(A_k - z**k * B_k))
        status = "✓" if diff < 1e-8 else "✗"
        print(f"  k={k}: max|A^k - z^k·B^k| = {diff:.2e}  {status}")
    print()


def demo_frobenius_norm(n: int = 100, z: complex = 0.5 + 0.3j):
    """Verify tr(A^H · A) = |z|^2 * edge_pair_count."""
    print("=" * 60)
    print("Demo 7: Frobenius Norm Identity")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    
    frobenius_sq = np.real(np.trace(A_z.conj().T @ A_z))
    edge_pairs = int(np.sum(B))  # directed edge pair count
    predicted = abs(z) ** 2 * edge_pairs
    
    rel_error = abs(frobenius_sq - predicted) / max(abs(predicted), 1e-16)
    
    print(f"  n = {n}, z = {z}, |z|² = {abs(z)**2:.4f}")
    print(f"  Edge pairs (directed): {edge_pairs}")
    print(f"  tr(A*·A) = {frobenius_sq:.4f}")
    print(f"  |z|² × edge_pairs = {predicted:.4f}")
    print(f"  Relative error: {rel_error:.2e}")
    print(f"  ✓ Identity verified" if rel_error < 1e-10 else "  ✗ FAILED")
    print()


def demo_eigenvector_scaling(n: int = 50, z: complex = 0.5 + 0.3j):
    """Verify eigenvector inheritance: eigenvectors of B are eigenvectors of A_z."""
    print("=" * 60)
    print("Demo 8: Eigenvector Scaling")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    
    # Get eigenvectors of B
    eigenvalues_B, eigenvectors_B = np.linalg.eigh(B)
    
    max_error = 0
    for i in range(n):
        v = eigenvectors_B[:, i]
        mu = eigenvalues_B[i]
        
        # A_z · v should equal (z * mu) * v
        Av = A_z @ v
        expected = (z * mu) * v
        error = np.max(np.abs(Av - expected))
        max_error = max(max_error, error)
    
    print(f"  n = {n}, z = {z}")
    print(f"  Max error over all {n} eigenvectors: {max_error:.2e}")
    print(f"  ✓ All eigenvectors inherited" if max_error < 1e-10 else "  ✗ FAILED")
    print()


def demo_degree_weight(n: int = 50, z: complex = 0.5 + 0.3j):
    """Verify row sum = z * degree for each vertex."""
    print("=" * 60)
    print("Demo 9: Degree-Weight Connection")
    print("=" * 60)
    A_z, B = generate_complex_weighted_graph(n, z)
    
    degrees = B.sum(axis=1)  # degree of each vertex
    row_sums = A_z.sum(axis=1)
    predicted = z * degrees
    
    max_error = np.max(np.abs(row_sums - predicted))
    
    print(f"  n = {n}, z = {z}")
    print(f"  Degree range: [{int(degrees.min())}, {int(degrees.max())}]")
    print(f"  max|row_sum - z·degree| = {max_error:.2e}")
    print(f"  ✓ Degree-weight connection verified" if max_error < 1e-12 else "  ✗ FAILED")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Complex Weighted Random Graphs: Numerical Demos       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_scalar_factorization()
    demo_trace_identity()
    demo_normality()
    demo_spectral_collinearity()
    demo_directed_vs_undirected()
    demo_walk_phase()
    demo_frobenius_norm()
    demo_eigenvector_scaling()
    demo_degree_weight()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Normality and Spectral Dimension

Shows how the normality defect and spectral dimension change as we
interpolate between symmetric (undirected) and asymmetric (directed) graphs.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

n = 300
z = 0.5 + 0.3j
p = 0.5

alphas = np.linspace(0, 1, 21)
normality_defects = []
spectral_dims = []

for alpha in alphas:
    # Generate symmetric part
    upper = np.random.random((n, n)) < p
    B_sym = np.triu(upper, k=1).astype(float)
    B_sym = B_sym + B_sym.T
    np.fill_diagonal(B_sym, 0)
    
    # Generate asymmetric perturbation
    B_asym = (np.random.random((n, n)) < p).astype(float)
    np.fill_diagonal(B_asym, 0)
    
    # Interpolate: alpha=1 is fully symmetric, alpha=0 is fully asymmetric
    B = alpha * B_sym + (1 - alpha) * B_asym
    B = (B > 0.5).astype(float)  # threshold to {0,1}
    np.fill_diagonal(B, 0)
    
    A = z * B
    AH = A.conj().T
    
    # Normality defect
    defect = np.linalg.norm(A @ AH - AH @ A, 'fro') / max(np.linalg.norm(A, 'fro')**2, 1e-10)
    normality_defects.append(defect)
    
    # Spectral dimension
    eigs = np.linalg.eigvals(A)
    eigs_filtered = eigs[np.abs(eigs) > 0.1]
    if len(eigs_filtered) > 3:
        points = np.column_stack([eigs_filtered.real, eigs_filtered.imag])
        points -= points.mean(axis=0)
        cov = np.cov(points.T)
        svs = np.linalg.svd(cov, compute_uv=False)
        dim = svs[1] / max(svs[0], 1e-14)
    else:
        dim = 0
    spectral_dims.append(dim)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Normality defect
ax = axes[0]
ax.plot(alphas, normality_defects, 'b-o', markersize=4, linewidth=2)
ax.set_xlabel('Symmetry fraction α', fontsize=12)
ax.set_ylabel('Normality defect', fontsize=12)
ax.set_title('Normality vs Symmetry', fontweight='bold', fontsize=13)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Panel 2: Spectral dimension
ax = axes[1]
ax.plot(alphas, spectral_dims, 'r-o', markersize=4, linewidth=2)
ax.set_xlabel('Symmetry fraction α', fontsize=12)
ax.set_ylabel('Spectral dimension ratio', fontsize=12)
ax.set_title('Spectral Dimension vs Symmetry', fontweight='bold', fontsize=13)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Panel 3: Eigenvalue plots for α = 0, 0.5, 1.0
ax = axes[2]
for alpha_val, color, label in [(0.0, '#FF5722', 'α=0 (directed)'),
                                  (0.5, '#9C27B0', 'α=0.5 (mixed)'),
                                  (1.0, '#2196F3', 'α=1 (symmetric)')]:
    upper = np.random.random((n, n)) < p
    B_sym = np.triu(upper, k=1).astype(float)
    B_sym = B_sym + B_sym.T
    np.fill_diagonal(B_sym, 0)
    B_asym = (np.random.random((n, n)) < p).astype(float)
    np.fill_diagonal(B_asym, 0)
    B = alpha_val * B_sym + (1 - alpha_val) * B_asym
    B = (B > 0.5).astype(float)
    np.fill_diagonal(B, 0)
    A = z * B
    eigs = np.linalg.eigvals(A)
    ax.scatter(eigs.real, eigs.imag, s=3, alpha=0.5, c=color, label=label)

ax.set_xlabel('Re(λ)', fontsize=12)
ax.set_ylabel('Im(λ)', fontsize=12)
ax.set_title('Eigenvalue Distributions', fontweight='bold', fontsize=13)
ax.set_aspect('equal')
ax.legend(fontsize=9, markerscale=3)
ax.grid(True, alpha=0.3)

plt.suptitle(f'Symmetry Controls Spectral Geometry (n={n}, z={z})',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('normality_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved normality_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Collinearity in Complex Weighted Graphs

Compares the eigenvalue distributions of undirected (collinear) vs directed
(circular) complex weighted random graphs.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def generate_symmetric_complex_graph(n, z, p=0.5):
    upper = np.random.random((n, n)) < p
    B = np.triu(upper, k=1).astype(float)
    B = B + B.T
    np.fill_diagonal(B, 0)
    return z * B

def generate_directed_complex_graph(n, z, p=0.5):
    B = (np.random.random((n, n)) < p).astype(float)
    np.fill_diagonal(B, 0)
    return z * B

np.random.seed(42)

n = 500
z = 0.5 + 0.3j
p = 0.5

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Undirected
A_sym = generate_symmetric_complex_graph(n, z, p)
eigs_sym = np.linalg.eigvals(A_sym)

ax = axes[0]
ax.scatter(eigs_sym.real, eigs_sym.imag, s=8, alpha=0.7, c='#2196F3', edgecolors='none')
ax.axhline(0, color='gray', linewidth=0.5, alpha=0.5)
ax.axvline(0, color='gray', linewidth=0.5, alpha=0.5)

# Draw the collinearity direction
theta = np.angle(z)
max_r = np.max(np.abs(eigs_sym)) * 1.1
ax.plot([-max_r * np.cos(theta), max_r * np.cos(theta)],
        [-max_r * np.sin(theta), max_r * np.sin(theta)],
        'r--', linewidth=1, alpha=0.7, label=f'arg(z) = {np.degrees(theta):.1f}°')

ax.set_title(f'Undirected G({n}, z)\nz = {z}', fontsize=13, fontweight='bold')
ax.set_xlabel('Re(λ)')
ax.set_ylabel('Im(λ)')
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Directed
A_dir = generate_directed_complex_graph(n, z, p)
eigs_dir = np.linalg.eigvals(A_dir)

ax = axes[1]
ax.scatter(eigs_dir.real, eigs_dir.imag, s=8, alpha=0.7, c='#FF5722', edgecolors='none')
ax.axhline(0, color='gray', linewidth=0.5, alpha=0.5)
ax.axvline(0, color='gray', linewidth=0.5, alpha=0.5)

# Draw the predicted circular law disk
radius = abs(z) * np.sqrt(n * p * (1 - p))
circle = plt.Circle((z * n * p).real, (z * n * p).imag, radius,
                     fill=False, color='green', linewidth=1.5, linestyle='--',
                     label=f'Circular law disk (r≈{radius:.1f})')
ax.add_patch(circle)

ax.set_title(f'Directed G({n}, z)\nz = {z}', fontsize=13, fontweight='bold')
ax.set_xlabel('Re(λ)')
ax.set_ylabel('Im(λ)')
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Spectral Collinearity: Undirected (Line) vs Directed (Disk)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_collinearity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_collinearity.png")


#!/usr/bin/env python3
"""
Visualization: Walk Phase Interference in Complex Weighted Graphs

Shows how walks of different lengths accumulate different phases z^k,
creating constructive and destructive interference patterns.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

n = 30
z = np.exp(1j * np.pi / 5)  # phase = π/5 per step
p = 0.4

# Generate graph
upper = np.random.random((n, n)) < p
B = np.triu(upper, k=1).astype(float)
B = B + B.T
np.fill_diagonal(B, 0)

# Pick two vertices with good connectivity
source, target = 0, 5
max_k = 20

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Walk amplitudes
amplitudes = []
phases = []
walk_counts = []
B_power = np.eye(n)
for k in range(1, max_k + 1):
    B_power = B_power @ B
    count = B_power[source, target]
    amp = z**k * count
    amplitudes.append(amp)
    phases.append(np.angle(z**k))
    walk_counts.append(count)

ks = np.arange(1, max_k + 1)

# Panel 1: Walk count vs amplitude
ax = axes[0]
ax.bar(ks, [abs(a) for a in amplitudes], color='#2196F3', alpha=0.7, label='|z^k · walks|')
ax.bar(ks, walk_counts, color='#FF9800', alpha=0.4, label='walk count (B^k)_{s,t}')
ax.set_xlabel('Walk length k')
ax.set_ylabel('Magnitude')
ax.set_title('Walk Counts vs Amplitudes', fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Phase accumulation spiral
ax = axes[1]
cumulative = np.cumsum(amplitudes)
real_parts = [a.real for a in cumulative]
imag_parts = [a.imag for a in cumulative]
ax.plot(real_parts, imag_parts, 'b-', alpha=0.5, linewidth=1)
ax.scatter(real_parts, imag_parts, c=ks, cmap='viridis', s=30, zorder=5)
ax.scatter(real_parts[0], imag_parts[0], c='green', s=100, marker='o', zorder=6, label='k=1')
ax.scatter(real_parts[-1], imag_parts[-1], c='red', s=100, marker='*', zorder=6, label=f'k={max_k}')
ax.set_xlabel('Re(cumulative amplitude)')
ax.set_ylabel('Im(cumulative amplitude)')
ax.set_title('Cumulative Walk Interference', fontweight='bold')
ax.set_aspect('equal')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Phase diagram
ax = axes[2]
for k_val, amp in zip(ks, amplitudes):
    r = abs(amp)
    theta = np.angle(amp)
    ax.arrow(0, 0, r * np.cos(theta), r * np.sin(theta),
             head_width=max(r * 0.05, 0.1), head_length=max(r * 0.03, 0.05),
             fc=plt.cm.viridis(k_val / max_k), ec='none', alpha=0.6)

# Unit circle reference
theta_ref = np.linspace(0, 2 * np.pi, 100)
max_r = max(abs(a) for a in amplitudes) * 0.3
ax.plot(max_r * np.cos(theta_ref), max_r * np.sin(theta_ref), 'k--', alpha=0.2)
ax.set_xlabel('Re')
ax.set_ylabel('Im')
ax.set_title(f'Phase Vectors (z = e^{{iπ/5}})', fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.suptitle(f'Walk Phase Interference: vertices {source}→{target}, n={n}',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('walk_interference.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved walk_interference.png")
