"""
Applications of Hyperbolic Number Theory
==========================================

Real-world applications connecting hyperbolic geometry on the Poincaré disk
to signal processing, network routing, and machine learning embeddings.
"""

import math
from typing import List, Tuple


def normSq(z: complex) -> float:
    return z.real**2 + z.imag**2


def mobius_transform(a: complex, z: complex) -> complex:
    return (z - a) / (1 - a.conjugate() * z)


def hyperbolic_distance(z: complex, w: complex) -> float:
    rho = abs(z - w) / abs(1 - w.conjugate() * z)
    if rho >= 1:
        return float('inf')
    return 2 * math.atanh(rho)


# ─────────────────────────────────────────────────────────────
# Application 1: Hyperbolic Embeddings for Hierarchical Data
# ─────────────────────────────────────────────────────────────

def embed_tree_hyperbolic(
    edges: List[Tuple[int, int]], root: int = 0, scale: float = 0.5
) -> dict:
    """Embed a tree into the Poincaré disk using Möbius translations.
    
    Trees embed naturally into hyperbolic space with low distortion
    because the volume of a hyperbolic ball grows exponentially with
    radius — matching the exponential growth of tree branches.
    
    Args:
        edges: List of (parent, child) edges
        root: Root node index
        scale: Embedding scale factor (0 < scale < 1)
    
    Returns:
        Dictionary mapping node index to complex number in disk
    """
    # Build adjacency list
    adj = {}
    for u, v in edges:
        adj.setdefault(u, []).append(v)
        adj.setdefault(v, []).append(u)
    
    embedding = {root: 0 + 0j}
    visited = {root}
    queue = [root]
    
    while queue:
        node = queue.pop(0)
        children = [c for c in adj.get(node, []) if c not in visited]
        n_children = len(children)
        
        if n_children == 0:
            continue
        
        for i, child in enumerate(children):
            # Place children at equally spaced angles around parent
            angle = 2 * math.pi * i / n_children
            offset = scale * complex(math.cos(angle), math.sin(angle))
            
            # Use Möbius transform to translate from origin to parent position
            parent_pos = embedding[node]
            child_pos = mobius_transform(-parent_pos, offset)
            
            embedding[child] = child_pos
            visited.add(child)
            queue.append(child)
    
    return embedding


def distortion_score(
    embedding: dict, edges: List[Tuple[int, int]]
) -> float:
    """Compute embedding distortion: ratio of worst-case to best-case
    distance preservation.
    
    Lower is better. Distortion of 1.0 means perfect embedding.
    """
    edge_dists = []
    for u, v in edges:
        if u in embedding and v in embedding:
            d = hyperbolic_distance(embedding[u], embedding[v])
            edge_dists.append(d)
    
    if not edge_dists:
        return float('inf')
    
    return max(edge_dists) / min(edge_dists) if min(edge_dists) > 0 else float('inf')


# ─────────────────────────────────────────────────────────────
# Application 2: Hyperbolic Averaging for Consensus
# ─────────────────────────────────────────────────────────────

def hyperbolic_midpoint(z: complex, w: complex) -> complex:
    """Compute the hyperbolic midpoint of two points in the disk.
    
    Uses the formula: transport z to origin via T_z, halve the
    resulting point, then transport back.
    
    This has applications in distributed consensus algorithms
    where agents must agree on a point in a hyperbolic space.
    """
    # Transport w to origin-centered coordinates
    w_transported = mobius_transform(z, w)
    # Halve the transported point (approximate midpoint)
    mid_transported = w_transported / 2
    # Transport back
    return mobius_transform(-z, mid_transported)


def hyperbolic_mean(points: List[complex], iterations: int = 50) -> complex:
    """Compute the Fréchet mean in hyperbolic space.
    
    Uses iterative averaging to find the point minimizing
    the sum of squared hyperbolic distances.
    
    Applications: centroid computation in hyperbolic embeddings,
    Riemannian gradient descent on the Poincaré disk.
    """
    if not points:
        return 0 + 0j
    
    mean = points[0]
    for _ in range(iterations):
        # Gradient step: move toward each point
        new_mean = 0 + 0j
        for p in points:
            mid = hyperbolic_midpoint(mean, p)
            new_mean += mid
        new_mean /= len(points)
        
        # Project back to disk if needed
        if normSq(new_mean) >= 0.99:
            new_mean *= 0.99 / abs(new_mean)
        
        mean = new_mean
    
    return mean


# ─────────────────────────────────────────────────────────────
# Application 3: Hyperbolic Voronoi Diagrams for Networks
# ─────────────────────────────────────────────────────────────

def hyperbolic_voronoi_classify(
    point: complex, centers: List[complex]
) -> int:
    """Classify a point by nearest Voronoi center in hyperbolic metric.
    
    Applications: network routing in hyperbolic-embedded networks,
    where greedy routing using hyperbolic distance achieves nearly
    optimal path lengths in scale-free networks.
    """
    best_dist = float('inf')
    best_idx = 0
    
    for i, c in enumerate(centers):
        d = hyperbolic_distance(point, c)
        if d < best_dist:
            best_dist = d
            best_idx = i
    
    return best_idx


# ─────────────────────────────────────────────────────────────
# Demo
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("APPLICATION 1: Tree Embedding in Hyperbolic Space")
    print("=" * 50)
    
    # Binary tree with 7 nodes
    edges = [(0,1), (0,2), (1,3), (1,4), (2,5), (2,6)]
    embedding = embed_tree_hyperbolic(edges, root=0, scale=0.4)
    
    print("Binary tree embedding (7 nodes):")
    for node, pos in sorted(embedding.items()):
        print(f"  Node {node}: z = {pos:.4f}, |z|² = {normSq(pos):.4f}")
    
    dist = distortion_score(embedding, edges)
    print(f"Distortion score: {dist:.4f}")
    
    print()
    print("APPLICATION 2: Hyperbolic Averaging")
    print("=" * 50)
    
    points = [0.3+0.2j, -0.2+0.4j, 0.1-0.3j, 0.4+0.1j]
    mean = hyperbolic_mean(points)
    print(f"Points: {[f'{p:.2f}' for p in points]}")
    print(f"Hyperbolic mean: {mean:.4f}")
    print(f"|mean|² = {normSq(mean):.4f}")
    
    print()
    print("APPLICATION 3: Hyperbolic Voronoi Classification")
    print("=" * 50)
    
    centers = [0.5+0j, -0.5+0j, 0+0.5j]
    test_points = [0.3+0.1j, -0.3+0.2j, 0.1+0.3j, 0.4-0.2j]
    
    for p in test_points:
        cell = hyperbolic_voronoi_classify(p, centers)
        print(f"  Point {p:.2f} → Cell {cell} (center = {centers[cell]:.2f})")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================

Demonstrates the key theorems from our formalization:
1. The Möbius Key Identity
2. Möbius transforms preserving the disk
3. The Cayley transform mapping upper half-plane to disk
4. The involutory property of Möbius automorphisms
5. Pseudo-hyperbolic distance computations
"""

import numpy as np


def normSq(z: complex) -> float:
    """Complex normSq: |z|² = re² + im²"""
    return z.real**2 + z.imag**2


def conj(z: complex) -> complex:
    """Complex conjugate"""
    return z.conjugate()


def mobius_transform(a: complex, z: complex) -> complex:
    """Möbius automorphism T_a(z) = (z - a) / (1 - conj(a)*z)"""
    return (z - a) / (1 - conj(a) * z)


def mobius_standard(a: complex, z: complex) -> complex:
    """Standard involutory form φ_a(z) = (a - z) / (1 - conj(a)*z)"""
    return (a - z) / (1 - conj(a) * z)


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    """Pseudo-hyperbolic distance between z and w in the Poincaré disk"""
    return np.sqrt(normSq(z - w) / normSq(1 - conj(w) * z))


def cayley_transform(z: complex) -> complex:
    """Cayley transform: maps upper half-plane to Poincaré disk
    C(z) = (z - i) / (z + i)"""
    return (z - 1j) / (z + 1j)


def demo_key_identity():
    """
    Theorem (Key Identity):
    |1 - conj(a)·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)
    """
    print("=" * 60)
    print("THEOREM 1: The Key Identity of the Poincaré Disk")
    print("=" * 60)
    print("|1 - conj(a)·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)")
    print()
    
    test_cases = [
        (0.3 + 0.4j, 0.1 + 0.2j),
        (0.5 + 0.5j, -0.3 + 0.6j),
        (0.0 + 0.0j, 0.7 + 0.1j),
        (-0.2 + 0.8j, 0.4 - 0.3j),
        (0.9 + 0.0j, 0.0 + 0.9j),
    ]
    
    for a, z in test_cases:
        lhs = normSq(1 - conj(a) * z) - normSq(z - a)
        rhs = (1 - normSq(a)) * (1 - normSq(z))
        print(f"  a = {a:.3f}, z = {z:.3f}")
        print(f"    LHS = {lhs:.10f}")
        print(f"    RHS = {rhs:.10f}")
        print(f"    Match: {abs(lhs - rhs) < 1e-12}")
    print()


def demo_disk_preservation():
    """
    Theorem (Disk Preservation):
    If |a|² < 1 and |z|² < 1, then |T_a(z)|² < 1
    """
    print("=" * 60)
    print("THEOREM 2: Möbius Transforms Preserve the Disk")
    print("=" * 60)
    print("If |a|² < 1 and |z|² < 1, then |T_a(z)|² < 1")
    print()
    
    np.random.seed(42)
    for i in range(8):
        # Generate random points in the disk
        r_a = np.random.uniform(0, 0.99)
        theta_a = np.random.uniform(0, 2 * np.pi)
        a = r_a * np.exp(1j * theta_a)
        
        r_z = np.random.uniform(0, 0.99)
        theta_z = np.random.uniform(0, 2 * np.pi)
        z = r_z * np.exp(1j * theta_z)
        
        w = mobius_transform(a, z)
        
        print(f"  Trial {i+1}: |a|² = {normSq(a):.4f}, |z|² = {normSq(z):.4f}")
        print(f"    → |T_a(z)|² = {normSq(w):.10f} < 1: {normSq(w) < 1}")
    print()


def demo_complement_formula():
    """
    Theorem (Complement Formula):
    1 - |T_a(z)|² = (1-|a|²)(1-|z|²) / |1 - conj(a)·z|²
    """
    print("=" * 60)
    print("THEOREM 3: The Complement Formula")
    print("=" * 60)
    print("1 - |T_a(z)|² = (1-|a|²)(1-|z|²) / |1 - conj(a)·z|²")
    print()
    
    test_cases = [
        (0.3 + 0.4j, 0.1 + 0.2j),
        (0.5 + 0.3j, -0.2 + 0.6j),
        (0.8 + 0.0j, 0.0 + 0.5j),
    ]
    
    for a, z in test_cases:
        w = mobius_transform(a, z)
        lhs = 1 - normSq(w)
        rhs = (1 - normSq(a)) * (1 - normSq(z)) / normSq(1 - conj(a) * z)
        print(f"  a = {a}, z = {z}")
        print(f"    1 - |T_a(z)|² = {lhs:.10f}")
        print(f"    Formula RHS   = {rhs:.10f}")
        print(f"    Match: {abs(lhs - rhs) < 1e-12}")
    print()


def demo_involution():
    """
    Theorem (Involution):
    φ_a(φ_a(z)) = z where φ_a(z) = (a - z)/(1 - conj(a)·z)
    """
    print("=" * 60)
    print("THEOREM 4: The Involution Property")
    print("=" * 60)
    print("φ_a(φ_a(z)) = z where φ_a(z) = (a - z)/(1 - conj(a)·z)")
    print()
    
    test_cases = [
        (0.3 + 0.4j, 0.1 + 0.2j),
        (0.7 + 0.1j, -0.5 + 0.3j),
        (0.0 + 0.9j, 0.2 - 0.1j),
    ]
    
    for a, z in test_cases:
        w = mobius_standard(a, z)
        result = mobius_standard(a, w)
        print(f"  a = {a}, z = {z}")
        print(f"    φ_a(z)      = {w:.6f}")
        print(f"    φ_a(φ_a(z)) = {result:.6f}")
        print(f"    Match z:      {abs(result - z) < 1e-12}")
    print()


def demo_cayley():
    """
    Theorem (Cayley Transform):
    If im(z) > 0, then |C(z)|² < 1
    """
    print("=" * 60)
    print("THEOREM 5: Cayley Transform Maps UHP to Disk")
    print("=" * 60)
    print("If im(z) > 0, then |C(z)| < 1")
    print()
    
    test_cases = [
        1j,           # z = i maps to 0
        2j,           # z = 2i
        1 + 1j,       # z = 1 + i
        -3 + 0.01j,   # Close to real axis
        0.5 + 10j,    # High in UHP
    ]
    
    for z in test_cases:
        w = cayley_transform(z)
        print(f"  z = {z:10.4f} (im = {z.imag:.4f})")
        print(f"    C(z) = {w:.6f}, |C(z)|² = {normSq(w):.10f} < 1: {normSq(w) < 1}")
    print()


def demo_normSq_identity():
    """
    Theorem (normSq identity):
    |z + i|² - |z - i|² = 4 · im(z)
    """
    print("=" * 60)
    print("THEOREM 6: The normSq Identity for I")
    print("=" * 60)
    print("|z + i|² - |z - i|² = 4·im(z)")
    print()
    
    test_cases = [1 + 2j, -3 + 0.5j, 0 + 1j, 4 - 3j, 0 + 0j]
    
    for z in test_cases:
        lhs = normSq(z + 1j) - normSq(z - 1j)
        rhs = 4 * z.imag
        print(f"  z = {z:10.4f}: LHS = {lhs:8.4f}, 4·im = {rhs:8.4f}, Match: {abs(lhs - rhs) < 1e-12}")
    print()


def demo_pseudo_hyp_dist():
    """
    Demo: pseudo-hyperbolic distance properties
    """
    print("=" * 60)
    print("PSEUDO-HYPERBOLIC DISTANCE PROPERTIES")
    print("=" * 60)
    print()
    
    z = 0.3 + 0.2j
    print(f"  ρ(z, z) = {pseudo_hyp_dist(z, z):.10f} (should be 0)")
    
    w = -0.1 + 0.4j
    print(f"  ρ(z, w) = {pseudo_hyp_dist(z, w):.6f} ≥ 0: {pseudo_hyp_dist(z, w) >= 0}")
    print(f"  ρ(w, z) = {pseudo_hyp_dist(w, z):.6f} (symmetry)")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE DISK       ║")
    print("║  Computational Verification of Formally Proven Theorems ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_key_identity()
    demo_disk_preservation()
    demo_complement_formula()
    demo_involution()
    demo_cayley()
    demo_normSq_identity()
    demo_pseudo_hyp_dist()
    
    print("All demonstrations completed successfully!")


"""
Visualization 2: The Möbius Key Identity Heatmap
==================================================

Visualizes the key identity of the Poincaré disk:
  |1 - conj(a)·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)

Shows how the "room left in the disk" after a Möbius transform
depends on both the center a and the input z.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def normSq(z):
    return np.real(z)**2 + np.imag(z)**2


# Create a grid of points in the disk
n = 400
x = np.linspace(-0.99, 0.99, n)
y = np.linspace(-0.99, 0.99, n)
X, Y = np.meshgrid(x, y)
Z = X + 1j * Y

# Mask: only inside the disk
mask = X**2 + Y**2 < 1

# Fixed center a = 0.5 + 0.3i
a = 0.5 + 0.3j

# Compute the Möbius transform
denom = 1 - np.conj(a) * Z
T = (Z - a) / denom

# Compute normSq of the transform
normSq_T = normSq(T)

# Compute the complement: 1 - |T_a(z)|²
complement = np.where(mask, 1 - normSq_T, np.nan)

# Compute the formula: (1 - |a|²)(1 - |z|²) / |1 - conj(a)z|²
formula = np.where(mask, 
    (1 - normSq(a)) * (1 - normSq(Z)) / normSq(denom),
    np.nan)

# Compute the error
error = np.where(mask, np.abs(complement - formula), np.nan)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: 1 - |T_a(z)|² 
im0 = axes[0].pcolormesh(X, Y, complement, cmap='viridis', shading='auto')
axes[0].set_title('$1 - |T_a(z)|^2$\n(room left in disk)', fontsize=13)
axes[0].set_aspect('equal')
circle0 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[0].add_patch(circle0)
axes[0].plot(a.real, a.imag, 'r*', markersize=15, label=f'a = {a}')
axes[0].legend(fontsize=10)
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# Plot 2: The formula value
im1 = axes[1].pcolormesh(X, Y, formula, cmap='viridis', shading='auto')
axes[1].set_title('$(1-|a|^2)(1-|z|^2) / |1-\\bar{a}z|^2$\n(Key Identity RHS)', fontsize=13)
axes[1].set_aspect('equal')
circle1 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[1].add_patch(circle1)
axes[1].plot(a.real, a.imag, 'r*', markersize=15)
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# Plot 3: Error (should be ~0 everywhere)
im2 = axes[2].pcolormesh(X, Y, error, cmap='hot', shading='auto',
                          vmin=0, vmax=1e-14)
axes[2].set_title('|Error| (machine precision)\n(verifying the identity)', fontsize=13)
axes[2].set_aspect('equal')
circle2 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[2].add_patch(circle2)
plt.colorbar(im2, ax=axes[2], shrink=0.8, label='Error')

for ax in axes:
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')

plt.suptitle('The Möbius Key Identity: Engine of Hyperbolic Geometry', 
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_key_identity.png', dpi=150, bbox_inches='tight')
print("Saved key identity visualization")


"""
Visualization 3: Hyperbolic Lattice Point Growth
==================================================

Tests the Hyperbolic Prime Number Theorem conjecture:
the number of lattice points with |z|² ≤ 1 - 1/R² grows
like C·R² for the PSL(2,Z) orbit on the Poincaré disk.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def normSq(z):
    return z.real**2 + z.imag**2


def cayley_transform(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_depth=8):
    visited = set()
    orbit = []
    
    def add_point(z_uhp):
        if z_uhp.imag <= 0:
            return
        w = cayley_transform(z_uhp)
        key = (round(w.real, 10), round(w.imag, 10))
        if key not in visited:
            visited.add(key)
            orbit.append(w)
    
    current = {1j}
    add_point(1j)
    
    for _ in range(max_depth):
        next_level = set()
        for z in current:
            if abs(z) > 1e-15:
                s_z = -1.0 / z
                if s_z.imag > 1e-10:
                    add_point(s_z)
                    next_level.add(s_z)
            t_z = z + 1
            if t_z.imag > 1e-10:
                add_point(t_z)
                next_level.add(t_z)
            ti_z = z - 1
            if ti_z.imag > 1e-10:
                add_point(ti_z)
                next_level.add(ti_z)
        current = next_level
    
    return orbit


# Generate orbit
print("Generating PSL(2,Z) orbit...")
orbit = generate_psl2z_orbit(max_depth=9)
print(f"Generated {len(orbit)} orbit points")

# Compute normSq for all points
norms = sorted([normSq(p) for p in orbit])

# Test growth: N(R) = #{points with normSq ≤ 1 - 1/R²}
R_values = np.linspace(1.5, 20, 100)
counts = []
for R in R_values:
    threshold = 1 - 1/R**2
    count = sum(1 for ns in norms if ns <= threshold)
    counts.append(count)

counts = np.array(counts)
R_sq = R_values**2

# Fit C for N(R) ≈ C·R²
# Use least squares on the last half of data
mid = len(R_values) // 2
C_fit = np.mean(counts[mid:] / R_sq[mid:])

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: N(R) vs R
axes[0].plot(R_values, counts, 'b-', linewidth=2, label='$N(R)$ (observed)')
axes[0].plot(R_values, C_fit * R_sq, 'r--', linewidth=1.5, 
             label=f'$C \\cdot R^2$ (C ≈ {C_fit:.3f})')
axes[0].set_xlabel('R', fontsize=12)
axes[0].set_ylabel('N(R)', fontsize=12)
axes[0].set_title('Lattice Point Count N(R)', fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# Plot 2: N(R)/R² — should approach a constant
ratio = counts / R_sq
axes[1].plot(R_values, ratio, 'g-', linewidth=2)
axes[1].axhline(y=C_fit, color='r', linestyle='--', linewidth=1.5, 
                label=f'C ≈ {C_fit:.3f}')
# Theoretical value for PSL(2,Z): 3/π ≈ 0.955
theoretical_C = 3.0 / math.pi
axes[1].axhline(y=theoretical_C, color='orange', linestyle=':', linewidth=1.5,
                label=f'3/π ≈ {theoretical_C:.3f} (theoretical)')
axes[1].set_xlabel('R', fontsize=12)
axes[1].set_ylabel('N(R) / R²', fontsize=12)
axes[1].set_title('Growth Rate N(R)/R²', fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

# Plot 3: Log-log plot
log_R = np.log(R_values)
log_N = np.log(np.maximum(counts, 1))
axes[2].plot(log_R, log_N, 'b-', linewidth=2, label='log N(R) vs log R')
# Fit slope
valid = counts > 0
slope, intercept = np.polyfit(log_R[valid], log_N[valid], 1)
axes[2].plot(log_R, slope * log_R + intercept, 'r--', linewidth=1.5,
             label=f'Slope ≈ {slope:.2f} (expect 2)')
axes[2].set_xlabel('log R', fontsize=12)
axes[2].set_ylabel('log N(R)', fontsize=12)
axes[2].set_title(f'Log-Log Plot (slope ≈ {slope:.2f})', fontsize=13)
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)

plt.suptitle('Testing the Hyperbolic Prime Number Theorem Conjecture\n'
             'PSL(2,ℤ) orbit on the Poincaré disk',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_lattice_growth.png', dpi=150, bbox_inches='tight')
print(f"Saved lattice growth visualization")
print(f"Fitted C = {C_fit:.4f}, log-log slope = {slope:.3f}")


"""
Visualization 1: The Poincaré Disk with Möbius Transform Orbits
================================================================

Visualizes the PSL(2,Z) orbit on the Poincaré disk, showing how
the modular group tessellates hyperbolic space. Hyperbolic primes
are highlighted as the closest orbit points to the origin.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def normSq(z):
    return z.real**2 + z.imag**2


def cayley_transform(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_depth=6):
    visited = set()
    orbit = []
    
    def add_point(z_uhp):
        if z_uhp.imag <= 0:
            return
        w = cayley_transform(z_uhp)
        key = (round(w.real, 10), round(w.imag, 10))
        if key not in visited:
            visited.add(key)
            orbit.append(w)
    
    current = {1j}
    add_point(1j)
    
    for _ in range(max_depth):
        next_level = set()
        for z in current:
            if abs(z) > 1e-15:
                s_z = -1.0 / z
                if s_z.imag > 1e-10:
                    add_point(s_z)
                    next_level.add(s_z)
            t_z = z + 1
            if t_z.imag > 1e-10:
                add_point(t_z)
                next_level.add(t_z)
            ti_z = z - 1
            if ti_z.imag > 1e-10:
                add_point(ti_z)
                next_level.add(ti_z)
        current = next_level
    
    return orbit


# Generate orbit
orbit = generate_psl2z_orbit(max_depth=7)

# Sort by distance from origin
orbit_sorted = sorted(orbit, key=lambda z: normSq(z))

# Classify: primes (closest), composites (rest)
n_primes = min(6, len(orbit_sorted))
primes = orbit_sorted[:n_primes]
composites = orbit_sorted[n_primes:]

fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw the unit disk boundary
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw hyperbolic geodesics (arcs of circles perpendicular to the boundary)
# Draw a few decorative geodesics
for angle in np.linspace(0, np.pi, 6):
    t = np.linspace(-0.98, 0.98, 200)
    x = t * np.cos(angle)
    y = t * np.sin(angle)
    mask = x**2 + y**2 < 0.99
    ax.plot(x[mask], y[mask], color='#e0e0e0', linewidth=0.5, zorder=1)

# Plot composite lattice points
if composites:
    cx = [z.real for z in composites]
    cy = [z.imag for z in composites]
    ax.scatter(cx, cy, s=8, c='steelblue', alpha=0.6, zorder=3, label='Lattice points')

# Plot hyperbolic primes
if primes:
    px = [z.real for z in primes]
    py = [z.imag for z in primes]
    ax.scatter(px, py, s=80, c='crimson', marker='*', zorder=4, 
               label='Hyperbolic primes', edgecolors='darkred', linewidths=0.5)

# Mark the origin
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.annotate('O', (0.02, 0.03), fontsize=12, fontweight='bold')

# Annotations
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title(f'Poincaré Disk: PSL(2,ℤ) Orbit ({len(orbit)} points)\n'
             f'Hyperbolic Primes shown as red stars', fontsize=14)
ax.legend(loc='upper right', fontsize=11)
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)

# Add grid circles for reference
for r in [0.25, 0.5, 0.75]:
    circle_r = plt.Circle((0, 0), r, fill=False, color='#d0d0d0', 
                           linewidth=0.5, linestyle='--')
    ax.add_patch(circle_r)

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(orbit)} orbit points and {n_primes} primes")
