#!/usr/bin/env python3
"""
Demo 4: Quaternionic Extension — Pythagorean Quadruples Tree

Hypothesis 4: The Pythagorean equation generalizes to a² + b² + c² = d²
(Pythagorean quadruples). We construct and analyze a "hyper-tree" of 
primitive quadruples using matrix generators.

Known generators for Pythagorean quadruples form a more complex structure
than the Berggren ternary tree. We explore:
1. Enumeration of primitive quadruples
2. Tree structure and branching
3. Spectral properties of generators
4. Connection to quaternion arithmetic

Author: Meta-Oracle Research Program
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from collections import deque
import os
from itertools import product
from math import gcd

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'figures')
os.makedirs(OUTPUT_DIR, exist_ok=True)


def is_primitive_quadruple(a, b, c, d):
    """Check if (a,b,c,d) is a primitive Pythagorean quadruple."""
    if a <= 0 or b <= 0 or c <= 0 or d <= 0:
        return False
    if a**2 + b**2 + c**2 != d**2:
        return False
    g = gcd(gcd(a, b), gcd(c, d))
    return g == 1


def enumerate_quadruples(max_d=200):
    """Enumerate all primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(2, max_d + 1):
        d2 = d * d
        for a in range(1, d):
            a2 = a * a
            if a2 >= d2:
                break
            for b in range(a, d):
                b2 = b * b
                if a2 + b2 >= d2:
                    break
                rem = d2 - a2 - b2
                c = int(np.sqrt(rem))
                if c >= b and c * c == rem:
                    if is_primitive_quadruple(a, b, c, d):
                        quads.append((a, b, c, d))
    return quads


# ─── Quaternionic Tree Generators (4×4 matrices) ─────────────────────────────
# These are analogous to Berggren matrices for the quadratic form a²+b²+c²-d²=0
# Based on SO(3,1) preserving the form.

# Generator matrices preserving a²+b²+c²=d²
# We use the parametrization from Carmichael/Spira
Q1 = np.array([
    [ 1,  0,  0,  0],
    [ 0,  1,  0,  0],
    [-2, -2,  1,  2],
    [-2, -2,  2,  3]
], dtype=np.int64)

Q2 = np.array([
    [ 1,  0, -2,  2],
    [ 0,  1,  0,  0],
    [ 0,  0,  1,  0],
    [ 0,  0, -2,  3]
], dtype=np.int64)

Q3 = np.array([
    [ 1,  0,  0,  0],
    [ 0,  1, -2,  2],
    [ 0,  0,  1,  0],
    [ 0,  0, -2,  3]
], dtype=np.int64)

Q4 = np.array([
    [-1,  2,  2,  2],
    [-2,  1,  2,  2],
    [-2,  2,  1,  2],
    [-2,  2,  2,  3]
], dtype=np.int64)

Q5 = np.array([
    [ 1,  2,  2,  2],
    [ 2,  1,  2,  2],
    [ 2,  2,  1,  2],
    [ 2,  2,  2,  3]  # This is B₂ analog
], dtype=np.int64)

QUAD_MATRICES = [Q1, Q2, Q3, Q4, Q5]
QUAD_NAMES = ['Q₁', 'Q₂', 'Q₃', 'Q₄', 'Q₅']


def verify_quadruple_preservation(matrices, root):
    """Verify that matrices preserve the quadruple property."""
    a, b, c, d = root
    assert a**2 + b**2 + c**2 == d**2, f"Root is not a quadruple: {root}"
    
    print("Verifying matrix preservation of a²+b²+c²=d²:")
    valid_matrices = []
    for i, (M, name) in enumerate(zip(matrices, QUAD_NAMES)):
        child = M @ root
        a2, b2, c2, d2 = child
        check = a2**2 + b2**2 + c2**2 == d2**2
        positive = all(x > 0 for x in child)
        print(f"  {name} · {root} = {tuple(child)}, "
              f"a²+b²+c² = {a2**2+b2**2+c2**2}, d² = {d2**2}, "
              f"valid={check}, positive={positive}")
        if check:
            valid_matrices.append((M, name))
    return valid_matrices


def generate_quadruple_tree(root, matrices, max_depth=6):
    """Generate quadruple tree via BFS."""
    quads = []
    queue = deque()
    queue.append((np.array(root), 0))
    seen = set()
    seen.add(tuple(sorted(root[:3])) + (root[3],))
    
    while queue:
        q, d = queue.popleft()
        quads.append({'quad': tuple(q), 'depth': d})
        if d >= max_depth:
            continue
        for M, name in zip(matrices, QUAD_NAMES):
            child = M @ q
            # Normalize: sort first 3 components
            key = tuple(sorted(abs(child[:3]))) + (abs(child[3]),)
            if all(x > 0 for x in child) and key not in seen:
                a2, b2, c2, d2 = child
                if a2**2 + b2**2 + c2**2 == d2**2:
                    seen.add(key)
                    queue.append((child, d + 1))
    
    return quads


def plot_quadruples_3d(quads_enum, quads_tree):
    """3D visualization of Pythagorean quadruples."""
    fig = plt.figure(figsize=(18, 8))
    
    # Plot 1: Enumerated quadruples
    ax1 = fig.add_subplot(121, projection='3d')
    if len(quads_enum) > 0:
        a_vals = [q[0] for q in quads_enum]
        b_vals = [q[1] for q in quads_enum]
        c_vals = [q[2] for q in quads_enum]
        d_vals = [q[3] for q in quads_enum]
        scatter = ax1.scatter(a_vals, b_vals, c_vals, c=d_vals, cmap='viridis', 
                            s=20, alpha=0.6)
        plt.colorbar(scatter, ax=ax1, label='d (hypotenuse)', shrink=0.6)
    ax1.set_xlabel('a')
    ax1.set_ylabel('b')
    ax1.set_zlabel('c')
    ax1.set_title(f'Primitive Quadruples (n={len(quads_enum)})', fontsize=13, fontweight='bold')
    
    # Plot 2: Quadruples colored by tree depth
    ax2 = fig.add_subplot(122, projection='3d')
    if len(quads_tree) > 0:
        a_vals = [q['quad'][0] for q in quads_tree]
        b_vals = [q['quad'][1] for q in quads_tree]
        c_vals = [q['quad'][2] for q in quads_tree]
        d_depths = [q['depth'] for q in quads_tree]
        scatter = ax2.scatter(a_vals, b_vals, c_vals, c=d_depths, cmap='plasma', 
                            s=30, alpha=0.7)
        plt.colorbar(scatter, ax=ax2, label='Tree depth', shrink=0.6)
    ax2.set_xlabel('a')
    ax2.set_ylabel('b')
    ax2.set_zlabel('c')
    ax2.set_title(f'Tree-Generated Quadruples (n={len(quads_tree)})', fontsize=13, fontweight='bold')
    
    plt.suptitle('Pythagorean Quadruples: a² + b² + c² = d²', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'quadruples_3d.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved quadruples_3d.png")


def quaternion_analysis():
    """Analyze the connection to quaternion algebra."""
    print("\n══════ QUATERNIONIC STRUCTURE ══════")
    
    # A Pythagorean quadruple (a,b,c,d) corresponds to a quaternion
    # q = a + bi + cj + dk with |q|² = d²
    # Actually: a² + b² + c² = d² means the quaternion (a,b,c) has 
    # norm-square equal to d²
    
    # Hurwitz quaternion representation
    print("\nQuaternionic representation of quadruples:")
    test_quads = [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9), (2, 6, 9, 11)]
    for a, b, c, d in test_quads:
        # The quaternion q = a·i + b·j + c·k is a pure quaternion with |q| = d
        norm_sq = a**2 + b**2 + c**2
        print(f"  ({a},{b},{c},{d}): q = {a}i + {b}j + {c}k, |q|² = {norm_sq}, d² = {d**2}, match = {norm_sq == d**2}")
    
    # Spectral analysis of Q matrices
    print("\nSpectral analysis of quaternionic generators:")
    fig, axes = plt.subplots(1, len(QUAD_MATRICES), figsize=(4*len(QUAD_MATRICES), 4))
    
    for i, (M, name) in enumerate(zip(QUAD_MATRICES, QUAD_NAMES)):
        evs = np.linalg.eigvals(M.astype(float))
        mags = sorted(np.abs(evs), reverse=True)
        print(f"  {name}: eigenvalues = {[f'{e:.3f}' for e in evs]}")
        print(f"       spectral radius = {mags[0]:.6f}, gap = {mags[0]-mags[1]:.6f}")
        
        ax = axes[i]
        ax.scatter(evs.real, evs.imag, s=100, c=f'C{i}', edgecolors='black', zorder=5)
        theta = np.linspace(0, 2*np.pi, 100)
        ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.2)
        ax.set_title(f'{name}', fontsize=12, fontweight='bold')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('Re(λ)')
        ax.set_ylabel('Im(λ)')
    
    plt.suptitle('Eigenvalues of Quaternionic Tree Generators', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'quaternionic_spectra.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved quaternionic_spectra.png")


def d_ratio_distribution(quads_enum):
    """Analyze the distribution of a/d ratios for quadruples."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    if len(quads_enum) > 0:
        # a/d ratios
        ad_ratios = [q[0] / q[3] for q in quads_enum]
        ax1.hist(ad_ratios, bins=80, color='#3498db', alpha=0.7, density=True, edgecolor='white')
        ax1.set_xlabel('a/d ratio', fontsize=12)
        ax1.set_ylabel('Density', fontsize=12)
        ax1.set_title('Distribution of a/d in Quadruples', fontsize=14, fontweight='bold')
        ax1.grid(True, alpha=0.3)
        
        # (a² + b²) / d² ratio — how "3D" is the triple?
        flatness = [(q[0]**2 + q[1]**2) / q[3]**2 for q in quads_enum]
        ax2.hist(flatness, bins=80, color='#e74c3c', alpha=0.7, density=True, edgecolor='white')
        ax2.set_xlabel('(a²+b²)/d²', fontsize=12)
        ax2.set_ylabel('Density', fontsize=12)
        ax2.set_title('Flatness Ratio Distribution', fontsize=14, fontweight='bold')
        ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Pythagorean Quadruple Statistics', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'quadruple_statistics.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved quadruple_statistics.png")


if __name__ == '__main__':
    print("=" * 60)
    print("  QUATERNIONIC EXTENSION — PYTHAGOREAN QUADRUPLES")
    print("=" * 60)
    
    # 1. Enumerate primitive quadruples
    print("\nEnumerating primitive Pythagorean quadruples...")
    quads_enum = enumerate_quadruples(max_d=100)
    print(f"  Found {len(quads_enum)} primitive quadruples with d ≤ 100")
    print(f"  First 10: {quads_enum[:10]}")
    
    # 2. Verify and build tree
    root = np.array([1, 2, 2, 3])  # Smallest primitive quadruple
    valid_mats = verify_quadruple_preservation(QUAD_MATRICES, root)
    
    # 3. Generate tree
    quads_tree = generate_quadruple_tree([1, 2, 2, 3], QUAD_MATRICES, max_depth=4)
    print(f"\n  Tree-generated quadruples: {len(quads_tree)}")
    
    # 4. Visualize
    plot_quadruples_3d(quads_enum, quads_tree)
    d_ratio_distribution(quads_enum)
    
    # 5. Quaternion analysis
    quaternion_analysis()
    
    print("\n✓ Quaternionic analysis complete!")
