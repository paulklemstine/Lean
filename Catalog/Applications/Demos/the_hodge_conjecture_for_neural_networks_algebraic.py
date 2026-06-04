#!/usr/bin/env python3
"""
Neural Hodge Theory: Demonstration of Decision Surface Topology

This script demonstrates the key mathematical structures and bounds
from the Graded Sign Poset theory applied to ReLU neural networks.
"""

import numpy as np
from itertools import product
from math import comb, factorial
from typing import List, Tuple, Dict

# ============================================================
# Core Definitions
# ============================================================

class TriSign:
    """Three-valued sign type: {+1, 0, -1}"""
    POS = 1
    ZERO = 0
    NEG = -1

def sign_vector(point: np.ndarray, normals: np.ndarray, offsets: np.ndarray) -> Tuple[int, ...]:
    """Compute the sign vector of a point relative to hyperplanes.
    
    Each hyperplane is defined by normal · x + offset = 0.
    Returns tuple of {+1, 0, -1} values.
    """
    values = normals @ point + offsets
    return tuple(int(np.sign(v)) if abs(v) > 1e-10 else 0 for v in values)

def rank(sv: Tuple[int, ...]) -> int:
    """Rank of a sign vector = number of nonzero entries."""
    return sum(1 for s in sv if s != 0)

def is_face(tau: Tuple[int, ...], sigma: Tuple[int, ...]) -> bool:
    """Check if tau ≤ sigma in the face partial order."""
    return all(t == 0 or t == s for t, s in zip(tau, sigma))

def faces_of(sigma: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    """Enumerate all faces of sigma."""
    m = len(sigma)
    faces = []
    for bits in product([True, False], repeat=m):
        face = tuple(sigma[i] if bits[i] and sigma[i] != 0 else 0 for i in range(m))
        if is_face(face, sigma):
            faces.append(face)
    return list(set(faces))

# ============================================================
# Zaslavsky Bound
# ============================================================

def zaslavsky_bound(w: int, n: int) -> int:
    """Upper bound on regions from w hyperplanes in R^n."""
    return sum(comb(w, k) for k in range(n + 1))

def network_region_bound(input_dim: int, widths: List[int]) -> int:
    """Product Zaslavsky bound for a multi-layer ReLU network."""
    bound = 1
    for w in widths:
        bound *= zaslavsky_bound(w, input_dim)
    return bound

# ============================================================
# Demo 1: Sign Vector Face Lattice
# ============================================================

def demo_face_lattice():
    """Demonstrate the face lattice of sign vectors."""
    print("=" * 60)
    print("Demo 1: Sign Vector Face Lattice")
    print("=" * 60)
    
    # Full sign vector in R^3 with 3 hyperplanes
    sigma = (1, -1, 1)
    faces = faces_of(sigma)
    
    print(f"\nSign vector σ = {sigma} (rank {rank(sigma)})")
    print(f"Number of faces: {len(faces)} = 2^{rank(sigma)} = {2**rank(sigma)}")
    print("\nFaces by rank:")
    for r in range(rank(sigma) + 1):
        r_faces = [f for f in faces if rank(f) == r]
        print(f"  Rank {r}: {r_faces}")
    
    # Verify face count formula
    for m in range(1, 6):
        full_sv = tuple([1] * m)
        n_faces = len(faces_of(full_sv))
        expected = 2 ** m
        assert n_faces == expected, f"Face count mismatch for m={m}"
        print(f"\n✓ Verified: |faces(+1^{m})| = 2^{m} = {expected}")

# ============================================================
# Demo 2: Zaslavsky Bound and Network Architecture
# ============================================================

def demo_zaslavsky():
    """Demonstrate Zaslavsky bounds for network architectures."""
    print("\n" + "=" * 60)
    print("Demo 2: Zaslavsky Bound and Network Architecture")
    print("=" * 60)
    
    architectures = [
        ("Simple (2→4→1)", 2, [4]),
        ("Deep (2→4→4→1)", 2, [4, 4]),
        ("Wide (2→8→1)", 2, [8]),
        ("Very Deep (2→4→4→4→1)", 2, [4, 4, 4]),
        ("High-dim (10→20→1)", 10, [20]),
    ]
    
    print(f"\n{'Architecture':<25} {'Region Bound':<15} {'2^neurons':<15} {'Ratio':<10}")
    print("-" * 65)
    for name, n, widths in architectures:
        bound = network_region_bound(n, widths)
        total_neurons = sum(widths)
        pow_bound = 2 ** total_neurons
        ratio = bound / pow_bound if pow_bound > 0 else 0
        print(f"{name:<25} {bound:<15} {pow_bound:<15} {ratio:.4f}")

# ============================================================
# Demo 3: Depth Amplification
# ============================================================

def demo_depth_amplification():
    """Show how depth exponentially increases decision surface complexity."""
    print("\n" + "=" * 60)
    print("Demo 3: Depth Amplification")
    print("=" * 60)
    
    n = 2  # input dimension
    w = 4  # width per layer
    
    print(f"\nInput dim n={n}, Width w={w}")
    print(f"\n{'Depth L':<10} {'Region Bound':<20} {'(2^w)^L':<20} {'Ratio'}")
    print("-" * 60)
    for L in range(1, 8):
        bound = network_region_bound(n, [w] * L)
        depth_bound = (2 ** w) ** L
        ratio = bound / depth_bound
        print(f"{L:<10} {bound:<20} {depth_bound:<20} {ratio:.6f}")

# ============================================================
# Demo 4: Sign Vector Counting
# ============================================================

def demo_signvec_counting():
    """Verify the sign vector counting formula."""
    print("\n" + "=" * 60)
    print("Demo 4: Sign Vector Counting")
    print("=" * 60)
    
    for m in range(1, 6):
        total = 3 ** m
        print(f"\nm = {m}: Total sign vectors = 3^{m} = {total}")
        
        for k in range(m + 1):
            expected = comb(m, k) * (2 ** k)
            print(f"  Rank {k}: C({m},{k}) · 2^{k} = {expected}")
        
        total_check = sum(comb(m, k) * (2 ** k) for k in range(m + 1))
        assert total_check == total, f"Sum mismatch for m={m}"
        print(f"  ✓ Sum = {total_check} = 3^{m}")

# ============================================================
# Demo 5: Euler Characteristic
# ============================================================

def demo_euler():
    """Compute Euler characteristic of complete sign arrangements."""
    print("\n" + "=" * 60)
    print("Demo 5: Complete GSP Euler Characteristic")
    print("=" * 60)
    
    for m in range(1, 10):
        euler = sum((-1)**k * comb(m, k) * (2**k) for k in range(m + 1))
        expected = (-1)**m
        print(f"  m={m}: Σ(-1)^k C(m,k)·2^k = {euler:>5} = (-1)^{m} ✓" 
              if euler == expected else f"  m={m}: MISMATCH!")

# ============================================================
# Demo 6: Hodge Number Bounds
# ============================================================

def demo_hodge_bounds():
    """Compute Hodge number bounds for various architectures."""
    print("\n" + "=" * 60)
    print("Demo 6: Hodge Number Bounds")
    print("=" * 60)
    
    architectures = [
        ("2→4→4→1", 2, [4, 4]),
        ("3→8→8→1", 3, [8, 8]),
        ("2→4→6→4→1", 2, [4, 6, 4]),
    ]
    
    for name, n, widths in architectures:
        w1, wL = widths[0], widths[-1]
        print(f"\nArchitecture: {name}")
        print(f"  w₁={w1}, wₗ={wL}")
        print(f"  {'(p,q)':<10} {'C(w₁,p)·C(wₗ,q)':<20} {'2^w₁·2^wₗ':<15}")
        print(f"  {'-'*45}")
        for p in range(min(w1, n) + 1):
            for q in range(min(wL, n) + 1):
                hodge = comb(w1, p) * comb(wL, q)
                upper = 2**w1 * 2**wL
                print(f"  ({p},{q}){'':<6} {hodge:<20} {upper:<15}")

# ============================================================
# Demo 7: ReLU Decision Surface Visualization Data
# ============================================================

def demo_relu_surface():
    """Generate data for a simple ReLU network decision surface."""
    print("\n" + "=" * 60)
    print("Demo 7: 2D ReLU Network Decision Surface")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Simple 2→3→1 network
    W1 = np.array([[1.0, 0.5], [-0.3, 1.2], [0.8, -0.9]])
    b1 = np.array([0.1, -0.5, 0.3])
    W2 = np.array([[1.0, -1.5, 0.8]])
    b2 = np.array([-0.2])
    
    def relu(x):
        return np.maximum(x, 0)
    
    def network(x):
        h = relu(W1 @ x + b1)
        return (W2 @ h + b2)[0]
    
    # Count sign changes along grid
    grid_size = 100
    x_range = np.linspace(-3, 3, grid_size)
    y_range = np.linspace(-3, 3, grid_size)
    
    sign_changes = 0
    for i in range(grid_size - 1):
        for j in range(grid_size - 1):
            vals = [
                network(np.array([x_range[i], y_range[j]])),
                network(np.array([x_range[i+1], y_range[j]])),
                network(np.array([x_range[i], y_range[j+1]])),
                network(np.array([x_range[i+1], y_range[j+1]])),
            ]
            if min(vals) * max(vals) < 0:
                sign_changes += 1
    
    region_bound = zaslavsky_bound(3, 2)
    print(f"\n  Network: 2→3→1")
    print(f"  Zaslavsky bound (3 hyperplanes in R²): {region_bound}")
    print(f"  Grid cells with sign change: {sign_changes}")
    print(f"  Grid resolution: {grid_size}×{grid_size}")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Neural Hodge Theory: Decision Surface Topology Demonstrations")
    print("=" * 60)
    
    demo_face_lattice()
    demo_zaslavsky()
    demo_depth_amplification()
    demo_signvec_counting()
    demo_euler()
    demo_hodge_bounds()
    demo_relu_surface()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: ReLU Network Decision Surface and Hyperplane Arrangement

Generates plots showing:
1. Decision surface of a 2D ReLU network
2. Hyperplane arrangement and sign regions
3. Face lattice diagram (Hasse diagram)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb

def relu(x):
    return np.maximum(x, 0)

def plot_decision_surface():
    """Plot the decision surface of a simple 2→3→1 ReLU network."""
    np.random.seed(42)
    
    W1 = np.array([[1.0, 0.5], [-0.3, 1.2], [0.8, -0.9]])
    b1 = np.array([0.1, -0.5, 0.3])
    W2 = np.array([[1.0, -1.5, 0.8]])
    b2 = np.array([-0.2])
    
    x = np.linspace(-3, 3, 500)
    y = np.linspace(-3, 3, 500)
    X, Y = np.meshgrid(x, y)
    
    Z = np.zeros_like(X)
    for i in range(len(x)):
        for j in range(len(y)):
            point = np.array([X[j, i], Y[j, i]])
            h = relu(W1 @ point + b1)
            Z[j, i] = (W2 @ h + b2)[0]
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Decision surface (zero level set)
    ax = axes[0]
    im = ax.contourf(X, Y, Z, levels=50, cmap='RdBu_r', alpha=0.8)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    plt.colorbar(im, ax=ax, label='f(x)')
    ax.set_title('ReLU Network Output f(x)', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    
    # Plot hyperplane boundaries
    for k in range(3):
        w = W1[k]
        b = b1[k]
        if abs(w[1]) > 1e-10:
            x_line = np.linspace(-3, 3, 100)
            y_line = -(w[0] * x_line + b) / w[1]
            mask = (y_line >= -3) & (y_line <= 3)
            ax.plot(x_line[mask], y_line[mask], '--', alpha=0.5, 
                    label=f'H_{k+1}', linewidth=1.5)
    ax.legend(loc='upper right', fontsize=9)
    
    # Plot 2: Activation regions
    ax = axes[1]
    # Color by activation pattern
    patterns = np.zeros_like(X)
    for i in range(len(x)):
        for j in range(len(y)):
            point = np.array([X[j, i], Y[j, i]])
            pre = W1 @ point + b1
            pattern = sum(2**k for k in range(3) if pre[k] > 0)
            patterns[j, i] = pattern
    
    ax.contourf(X, Y, patterns, levels=np.arange(-0.5, 8.5), cmap='Set3', alpha=0.7)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    for k in range(3):
        w = W1[k]
        b = b1[k]
        if abs(w[1]) > 1e-10:
            x_line = np.linspace(-3, 3, 100)
            y_line = -(w[0] * x_line + b) / w[1]
            mask = (y_line >= -3) & (y_line <= 3)
            ax.plot(x_line[mask], y_line[mask], 'k--', alpha=0.4, linewidth=1)
    ax.set_title('Activation Regions (colored)', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    
    # Plot 3: Zaslavsky bound comparison
    ax = axes[2]
    widths = range(1, 20)
    for n in [2, 3, 5, 10]:
        bounds = [sum(comb(w, k) for k in range(n + 1)) for w in widths]
        ax.plot(list(widths), bounds, '-o', markersize=4, label=f'n={n}')
    
    pow_bounds = [2**w for w in widths]
    ax.plot(list(widths), pow_bounds, 'k--', alpha=0.5, label='2^w')
    ax.set_xlabel('Number of hyperplanes w', fontsize=11)
    ax.set_ylabel('Max regions', fontsize=11)
    ax.set_title('Zaslavsky Bound vs 2^w', fontsize=13)
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('neural_hodge_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: neural_hodge_visualization.png")

def plot_depth_amplification():
    """Show how depth amplifies decision surface complexity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Region bound vs depth
    ax = axes[0]
    for w in [3, 4, 5, 8]:
        n = 2
        depths = range(1, 8)
        bounds = []
        for L in depths:
            zb = sum(comb(w, k) for k in range(n + 1))
            bounds.append(zb ** L)
        ax.semilogy(list(depths), bounds, '-o', markersize=5, label=f'w={w}')
    
    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Region Bound', fontsize=12)
    ax.set_title('Depth Amplification (n=2)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Hodge numbers for 2→w→w→1
    ax = axes[1]
    widths_range = range(2, 15)
    for pq in [(0, 0), (1, 0), (0, 1), (1, 1), (2, 0)]:
        p, q = pq
        bounds = [comb(w, p) * comb(w, q) for w in widths_range]
        ax.plot(list(widths_range), bounds, '-o', markersize=4, 
                label=f'h^({p},{q})')
    
    ax.set_xlabel('Width w', fontsize=12)
    ax.set_ylabel('Hodge Number Bound', fontsize=12)
    ax.set_title('Hodge Number Bounds (n→w→w→1)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('depth_amplification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_amplification.png")

def plot_euler_characteristic():
    """Plot the Euler characteristic formula verification."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    ms = range(1, 15)
    euler_vals = []
    for m in ms:
        chi = sum((-1)**k * comb(m, k) * 2**k for k in range(m + 1))
        euler_vals.append(chi)
    
    ax.bar(list(ms), euler_vals, color=['#4CAF50' if v > 0 else '#f44336' for v in euler_vals],
           alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Number of hyperplanes m', fontsize=12)
    ax.set_ylabel('Euler characteristic χ', fontsize=12)
    ax.set_title('Complete GSP Euler Characteristic: χ = (-1)^m', fontsize=13)
    ax.set_xticks(list(ms))
    
    # Add formula annotation
    ax.annotate('χ = Σ (-1)^k · C(m,k) · 2^k = (-1)^m',
                xy=(7, 0.5), fontsize=11, 
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('euler_characteristic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: euler_characteristic.png")

if __name__ == "__main__":
    plot_decision_surface()
    plot_depth_amplification()
    plot_euler_characteristic()
    print("\nAll visualizations generated.")
