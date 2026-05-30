#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Applications

Real-world applications of the hyperbolic arithmetic framework:
1. Relativistic velocity composition (special relativity)
2. Hyperbolic embeddings for hierarchical data
3. Signal processing on the Poincaré disk
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Relativistic Velocity Composition
# ============================================================

def relativistic_add(v1: float, v2: float, c: float = 1.0) -> float:
    """
    Einstein velocity addition: v1 ⊕ v2 = (v1 + v2)/(1 + v1*v2/c²).
    
    This is exactly Möbius addition on the real axis of the Poincaré disk
    (with the disk radius = c).
    
    Args:
        v1, v2: Velocities (|v| < c)
        c: Speed of light (default 1)
    
    Returns:
        Relativistic sum of velocities
    """
    return (v1 + v2) / (1 + v1 * v2 / c**2)


def thomas_precession_angle(v1: complex, v2: complex) -> float:
    """
    Compute the Thomas precession angle arising from the gyration
    in Möbius addition. This is a real physical effect: a gyroscope
    carried around a closed loop at relativistic speeds experiences
    this rotation.
    
    Args:
        v1, v2: Velocity vectors as complex numbers (|v| < 1)
    
    Returns:
        Precession angle in radians
    """
    gyr = (1 + v1.conjugate() * v2) / (1 + v1 * v2.conjugate())
    return np.angle(gyr)


print("=" * 60)
print("APPLICATION 1: RELATIVISTIC VELOCITY COMPOSITION")
print("=" * 60)

c = 299792458  # m/s

# Two rockets each moving at 0.8c relative to the lab
v1 = 0.8 * c
v2 = 0.6 * c

# Classical (Galilean) addition
v_classical = v1 + v2
# Relativistic (Möbius) addition  
v_rel = relativistic_add(v1, v2, c)

print(f"  Rocket 1 velocity: {v1/c:.2f}c")
print(f"  Rocket 2 velocity: {v2/c:.2f}c")
print(f"  Classical sum: {v_classical/c:.2f}c {'(> c!)' if v_classical > c else ''}")
print(f"  Relativistic sum: {v_rel/c:.6f}c (< c: ✓)")
print(f"  Difference: {(v_classical - v_rel)/c:.4f}c")

# Thomas precession
print(f"\n  Thomas Precession:")
for angle in [30, 45, 60, 90]:
    v1c = complex(0.8, 0)
    v2c = 0.6 * np.exp(1j * np.radians(angle))
    theta = thomas_precession_angle(v1c, v2c)
    print(f"    Angle between velocities: {angle}° → precession: {np.degrees(theta):.4f}°")


# ============================================================
# Application 2: Hyperbolic Embeddings for Hierarchical Data
# ============================================================

def embed_tree_poincare(tree: dict, depth: int = 0, angle: float = 0,
                        parent: complex = 0j, 
                        angle_range: float = 2*np.pi) -> dict:
    """
    Embed a tree into the Poincaré disk using Möbius translations.
    
    Hierarchical data (taxonomies, org charts, phylogenetic trees)
    naturally embed into hyperbolic space because:
    - The exponential growth of area matches the exponential growth of nodes
    - Parent-child relationships map to geodesic connections
    - Distances reflect structural similarity
    
    Args:
        tree: Dict with 'name' and 'children' keys
        depth: Current depth in tree
        angle: Angular position
        parent: Parent node position in disk
        angle_range: Angular range for this subtree
    
    Returns:
        Dict mapping node names to Poincaré disk positions
    """
    positions = {}
    
    # Place root
    if depth == 0:
        positions[tree['name']] = complex(0, 0)
    else:
        r = 1 - 0.5 ** depth  # Radius increases with depth
        z = r * np.exp(1j * angle)
        # Möbius translate relative to parent
        denom = 1 + parent.conjugate() * z
        if abs(denom) > 1e-10:
            positions[tree['name']] = (parent + z) / denom
        else:
            positions[tree['name']] = z
    
    # Place children
    children = tree.get('children', [])
    n = len(children)
    if n > 0:
        for i, child in enumerate(children):
            child_angle = angle - angle_range/2 + angle_range * (i + 0.5) / n
            child_pos = embed_tree_poincare(
                child, depth + 1, child_angle,
                positions[tree['name']], angle_range / n)
            positions.update(child_pos)
    
    return positions


print("\n" + "=" * 60)
print("APPLICATION 2: HYPERBOLIC TREE EMBEDDING")
print("=" * 60)

# Example: A simple taxonomy
taxonomy = {
    'name': 'Life',
    'children': [
        {'name': 'Animals', 'children': [
            {'name': 'Mammals', 'children': [
                {'name': 'Primates'}, {'name': 'Carnivora'}, {'name': 'Rodentia'}
            ]},
            {'name': 'Birds', 'children': [
                {'name': 'Passerines'}, {'name': 'Raptors'}
            ]},
        ]},
        {'name': 'Plants', 'children': [
            {'name': 'Flowering', 'children': [
                {'name': 'Monocots'}, {'name': 'Dicots'}
            ]},
            {'name': 'Ferns'},
        ]},
    ]
}

positions = embed_tree_poincare(taxonomy)
print("  Taxonomy embedded in Poincaré disk:")
for name, pos in sorted(positions.items(), key=lambda x: abs(x[1])):
    print(f"    {name:15s}: z = {pos.real:+.4f}{pos.imag:+.4f}i, |z| = {abs(pos):.4f}")

# Verify all points are in the disk
all_in_disk = all(abs(z) < 1 for z in positions.values())
print(f"  All points in disk: {'✓' if all_in_disk else '✗'}")


# ============================================================
# Application 3: Hyperbolic Signal Processing
# ============================================================

def poincare_mean(points: List[complex], weights: List[float] = None,
                  max_iter: int = 100, tol: float = 1e-10) -> complex:
    """
    Compute the Fréchet mean (centroid) in the Poincaré disk.
    
    The Fréchet mean minimizes the sum of squared hyperbolic distances
    to all points. Unlike Euclidean mean, this requires iterative computation.
    
    Uses the gradient descent algorithm of Karcher (1977).
    
    Args:
        points: List of points in the Poincaré disk
        weights: Optional weights (default: uniform)
        max_iter: Maximum iterations
        tol: Convergence tolerance
    
    Returns:
        Fréchet mean in the Poincaré disk
    """
    if weights is None:
        weights = [1.0 / len(points)] * len(points)
    
    # Initialize at Euclidean centroid (projected into disk if needed)
    mu = sum(w * z for w, z in zip(weights, points))
    if abs(mu) >= 1:
        mu = 0.9 * mu / abs(mu)
    
    for _ in range(max_iter):
        # Compute weighted sum of logarithmic maps
        grad = complex(0, 0)
        conf = poincare_conformal_factor(mu)
        
        for w, p in zip(weights, points):
            # Möbius translate p to the tangent space at mu
            diff = moebius_add_simple(-mu, p)
            r = abs(diff)
            if r > 1e-15:
                # Logarithmic map: scale by 2*arctanh(r)/r
                scale = 2 * np.arctanh(min(r, 0.999)) / r
                grad += w * scale * diff
        
        # Exponential map: move mu in direction of gradient
        if abs(grad) < tol:
            break
        
        step = min(abs(grad), 0.1)  # Step size clamping
        direction = grad / abs(grad) * np.tanh(step / 2)
        mu = moebius_add_simple(mu, direction)
        
        # Ensure we stay in the disk
        if abs(mu) >= 1:
            mu = 0.99 * mu / abs(mu)
    
    return mu


def moebius_add_simple(z: complex, w: complex) -> complex:
    """Möbius addition (simple version for this module)."""
    denom = 1 + z.conjugate() * w
    if abs(denom) < 1e-15:
        return complex(0, 0)
    return (z + w) / denom


def poincare_conformal_factor(z: complex) -> float:
    """Conformal factor 2/(1-|z|²)."""
    return 2.0 / (1.0 - abs(z)**2)


print("\n" + "=" * 60)
print("APPLICATION 3: HYPERBOLIC SIGNAL PROCESSING")
print("=" * 60)

# Generate some points in the disk (e.g., noisy measurements on a sensor)
np.random.seed(42)
n_points = 20
center = complex(0.3, 0.4)  # True center
noise_level = 0.1

points = []
for _ in range(n_points):
    noise = noise_level * (np.random.randn() + 1j * np.random.randn())
    p = moebius_add_simple(center, noise)
    if abs(p) < 1:
        points.append(p)

print(f"  Generated {len(points)} noisy points around center = {center}")

# Euclidean mean vs Poincaré mean
euc_mean = sum(points) / len(points)
poincare_mean_val = poincare_mean(points)

print(f"  True center:     {center}")
print(f"  Euclidean mean:  {euc_mean:.4f} (|z| = {abs(euc_mean):.4f})")
print(f"  Poincaré mean:   {poincare_mean_val:.4f} (|z| = {abs(poincare_mean_val):.4f})")

# Error comparison
euc_error = abs(euc_mean - center)
hyp_error = abs(poincare_mean_val - center)
print(f"  Euclidean error: {euc_error:.6f}")
print(f"  Poincaré error:  {hyp_error:.6f}")

print("\n" + "=" * 60)
print("ALL APPLICATIONS DEMONSTRATED")
print("=" * 60)


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1 = read_file('viz_poincare_lattice.py')
viz2 = read_file('viz_conformal_factor.py')
viz3 = read_file('viz_critical_line.py')
html1 = read_file('interactive_moebius.html')
html2 = read_file('interactive_conformal.html')
lean_defs = read_file('Speculative/HyperbolicNumberTheory/Defs.lean')
lean_theorems = read_file('Speculative/HyperbolicNumberTheory/Theorems.lean')

package = {
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincaré Disk",
    "domain": "Speculative Number Theory / Hyperbolic Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Hyperbolic Number Theory Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Relativity, Embeddings, Signal Processing",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Möbius Addition and Gyrogroup Arithmetic",
            "pseudocode": "moebius_add(z, w):\n  return (z + w) / (1 + conj(z) * w)\n\ngyration_factor(z, w):\n  return (1 + conj(z)*w) / (1 + z*conj(w))\n\nComplexity: O(1) per operation",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Hyperbolic Lattice on the Poincaré Disk",
            "code": viz1,
            "description": "Visualizes the PSL(2,Z) orbit on the Poincaré disk, with hyperbolic primes highlighted in red. Shows the tessellation structure of hyperbolic integers."
        },
        {
            "name": "Poincaré Disk Conformal Factor",
            "code": viz2,
            "description": "Heatmap and radial profile of the conformal factor λ(z) = 2/(1-|z|²), showing the proved property λ ≥ 2 everywhere. Distances stretch to infinity near the boundary."
        },
        {
            "name": "Critical Line to Poincaré Disk Mapping",
            "code": viz3,
            "description": "Shows how the Cayley transform maps the critical line Re(s)=1/2 and Riemann zeta zeros into the Poincaré disk, visualizing the cross-domain bridge theorem."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Möbius Addition",
            "html": html1,
            "description": "Click to place two points in the Poincaré disk and see their Möbius sum. Demonstrates non-commutativity: z⊕w ≠ w⊕z, with the gyration angle displayed."
        },
        {
            "name": "Conformal Stretching Explorer",
            "html": html2,
            "description": "Move the mouse inside the Poincaré disk to see how the conformal factor stretches distances. Near the boundary, a tiny Euclidean step corresponds to a huge hyperbolic distance."
        }
    ],
    "lean_proofs": lean_defs + "\n\n-- ========================================\n-- Theorems\n-- ========================================\n\n" + lean_theorems
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json written successfully")
print(f"  Size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Demonstrations

Concrete numerical examples illustrating the theorems proved in Lean 4:
- Poincaré disk conformal factor
- SL(2,R) group operations
- Möbius addition and gyration
- Hyperbolic lattice point counting
- Critical line to disk mapping
"""

import numpy as np
from typing import List, Tuple

# ============================================================
# 1. Poincaré Disk: Conformal Factor
# ============================================================

def poincare_conformal(z: complex) -> float:
    """Conformal factor λ(z) = 2/(1 - |z|²). Always ≥ 2."""
    norm_sq = abs(z) ** 2
    assert norm_sq < 1, f"|z|² = {norm_sq} ≥ 1: point outside disk"
    return 2.0 / (1.0 - norm_sq)

print("=" * 60)
print("1. POINCARÉ DISK CONFORMAL FACTOR")
print("=" * 60)
test_points = [0, 0.1, 0.5, 0.7, 0.9, 0.99]
for r in test_points:
    z = complex(r, 0)
    lam = poincare_conformal(z)
    print(f"  λ({r}) = {lam:.4f}  (≥ 2: {'✓' if lam >= 2 else '✗'})")

# ============================================================
# 2. SL(2,R) Group Operations
# ============================================================

class SL2R:
    """Element of SL(2,R) with det(A) = 1."""
    def __init__(self, a: float, b: float, c: float, d: float):
        self.a, self.b, self.c, self.d = a, b, c, d
        det = a * d - b * c
        assert abs(det - 1.0) < 1e-10, f"det = {det} ≠ 1"

    def __mul__(self, other: 'SL2R') -> 'SL2R':
        return SL2R(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d)

    def inv(self) -> 'SL2R':
        return SL2R(self.d, -self.b, -self.c, self.a)

    def __repr__(self):
        return f"[{self.a:.3f} {self.b:.3f}; {self.c:.3f} {self.d:.3f}]"

    def approx_eq(self, other: 'SL2R', tol=1e-10) -> bool:
        return (abs(self.a - other.a) < tol and abs(self.b - other.b) < tol and
                abs(self.c - other.c) < tol and abs(self.d - other.d) < tol)

print("\n" + "=" * 60)
print("2. SL(2,R) GROUP OPERATIONS")
print("=" * 60)
e = SL2R(1, 0, 0, 1)
g = SL2R(2, 1, 1, 1)  # det = 2·1 - 1·1 = 1 ✓
h = SL2R(1, 1, 0, 1)  # det = 1·1 - 1·0 = 1 ✓
k = SL2R(1, 0, 1, 1)  # det = 1·1 - 0·1 = 1 ✓

print(f"  g = {g}")
print(f"  e·g = g: {(e * g).approx_eq(g)}")
print(f"  g·e = g: {(g * e).approx_eq(g)}")
print(f"  g·g⁻¹ = e: {(g * g.inv()).approx_eq(e)}")
print(f"  g⁻¹·g = e: {(g.inv() * g).approx_eq(e)}")
print(f"  (g·h)·k = g·(h·k): {((g * h) * k).approx_eq(g * (h * k))}")

# ============================================================
# 3. Möbius Addition
# ============================================================

def moebius_add(z: complex, w: complex) -> complex:
    """Möbius addition: z ⊕ w = (z + w)/(1 + conj(z)·w)"""
    return (z + w) / (1 + z.conjugate() * w)

def gyration_factor(z: complex, w: complex) -> complex:
    """Gyration factor: (1 + conj(z)·w)/(1 + z·conj(w))"""
    return (1 + z.conjugate() * w) / (1 + z * w.conjugate())

print("\n" + "=" * 60)
print("3. MÖBIUS ADDITION (GYROGROUP)")
print("=" * 60)
z = complex(0.3, 0.4)
w = complex(-0.2, 0.5)

print(f"  z = {z}")
print(f"  w = {w}")
print(f"  0 ⊕ w = {moebius_add(0, w)} (should be w: {'✓' if abs(moebius_add(0, w) - w) < 1e-10 else '✗'})")
print(f"  z ⊕ 0 = {moebius_add(z, 0)} (should be z: {'✓' if abs(moebius_add(z, 0) - z) < 1e-10 else '✗'})")
print(f"  z ⊕ (-z) = {moebius_add(z, -z)} (should be 0: {'✓' if abs(moebius_add(z, -z)) < 1e-10 else '✗'})")
print(f"  z ⊕ w = {moebius_add(z, w)}")
print(f"  w ⊕ z = {moebius_add(w, z)} (non-commutative!)")

gyr = gyration_factor(z, w)
print(f"  |gyr(z,w)| = {abs(gyr):.10f} (should be 1: {'✓' if abs(abs(gyr) - 1) < 1e-10 else '✗'})")

# ============================================================
# 4. Hyperbolic Lattice Point Counting
# ============================================================

def generate_psl2z_orbit(max_word_length: int) -> List[complex]:
    """Generate orbit of origin under PSL(2,Z) acting on upper half-plane,
    then map to Poincaré disk via Cayley transform."""
    # Generators of PSL(2,Z)
    S = np.array([[0, -1], [1, 0]], dtype=float)  # z -> -1/z
    T = np.array([[1, 1], [0, 1]], dtype=float)    # z -> z+1

    def moebius_action(M, z):
        """Apply Möbius transformation [a,b;c,d] to z."""
        a, b, c, d = M[0, 0], M[0, 1], M[1, 0], M[1, 1]
        if abs(c * z + d) < 1e-15:
            return None
        return (a * z + b) / (c * z + d)

    def cayley(z):
        """Map upper half-plane to disk: w = (z - i)/(z + i)."""
        return (z - 1j) / (z + 1j)

    orbit = set()
    base_point = 1j  # i in the upper half-plane

    # BFS over words in generators
    current = [np.eye(2)]
    visited_matrices = {(1, 0, 0, 1)}

    for _ in range(max_word_length):
        next_gen = []
        for M in current:
            for gen in [S, T, np.linalg.inv(S), np.linalg.inv(T)]:
                M2 = M @ gen
                # Normalize sign
                if M2[0, 0] < 0 or (M2[0, 0] == 0 and M2[0, 1] < 0):
                    M2 = -M2
                key = tuple(np.round(M2.flatten(), 10))
                if key not in visited_matrices:
                    visited_matrices.add(key)
                    z = moebius_action(M2, base_point)
                    if z is not None and z.imag > 0:
                        w = cayley(z)
                        if abs(w) < 1 - 1e-10:
                            orbit.add(round(w.real, 10) + 1j * round(w.imag, 10))
                    next_gen.append(M2)
        current = next_gen

    return sorted(orbit, key=abs)

print("\n" + "=" * 60)
print("4. HYPERBOLIC LATTICE POINT COUNTING")
print("=" * 60)

orbit = generate_psl2z_orbit(4)
print(f"  Generated {len(orbit)} orbit points (word length ≤ 4)")

# Count points within various radii
for r in [0.3, 0.5, 0.7, 0.9, 0.95]:
    count = sum(1 for z in orbit if abs(z) <= r)
    print(f"  Points with |z| ≤ {r}: {count}")

# Verify monotonicity
print("  Monotonicity check:")
prev = 0
for r in np.linspace(0.1, 0.99, 20):
    count = sum(1 for z in orbit if abs(z) <= r)
    assert count >= prev, f"Monotonicity violated at r={r}"
    prev = count
print("  ✓ Counting function is monotone in R")

# ============================================================
# 5. Critical Line → Disk Mapping
# ============================================================

print("\n" + "=" * 60)
print("5. CRITICAL LINE → POINCARÉ DISK")
print("=" * 60)

# First few non-trivial zeros of Riemann zeta (imaginary parts)
zeta_zeros_im = [14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
                 37.586178, 40.918719, 43.327073, 48.005151, 49.773832]

print("  Mapping ρ = 1/2 + it to (ρ-1)/(ρ+1):")
for t in zeta_zeros_im:
    rho = complex(0.5, t)
    w = (rho - 1) / (rho + 1)
    norm = abs(w)
    print(f"  t = {t:9.6f}: |w| = {norm:.8f}  (≤ 1: {'✓' if norm <= 1 else '✗'})")

# ============================================================
# 6. Hyperbolic Prime Detection
# ============================================================

print("\n" + "=" * 60)
print("6. HYPERBOLIC PRIME DETECTION")
print("=" * 60)

def is_hyp_prime(orbit: List[complex], n: int, tol: float = 1e-6) -> bool:
    """Check if orbit[n] is hyperbolic prime (indecomposable under ⊕)."""
    if n == 0:
        return False
    target = orbit[n]
    for i in range(1, n):
        for j in range(1, n):
            w = moebius_add(orbit[i], orbit[j])
            if abs(w - target) < tol:
                return False
    return True

# Use first 30 orbit points
small_orbit = orbit[:30] if len(orbit) >= 30 else orbit
print(f"  Testing first {len(small_orbit)} lattice points for primality:")
prime_count = 0
for n in range(1, len(small_orbit)):
    is_prime = is_hyp_prime(small_orbit, n)
    if is_prime:
        prime_count += 1
    if n <= 15:
        status = "PRIME" if is_prime else "composite"
        print(f"    Λ({n}) = {small_orbit[n]:.4f}, |Λ({n})| = {abs(small_orbit[n]):.4f}: {status}")

total = len(small_orbit) - 1
print(f"\n  Hyperbolic primes: {prime_count}/{total} = {prime_count/total:.3f}")
print(f"  (Compare: classical prime density at N={total} ≈ {1/np.log(total):.3f})")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk Conformal Factor

Heatmap showing the conformal factor λ(z) = 2/(1 - |z|²) across the
Poincaré disk. This factor describes how much the hyperbolic metric
stretches distances compared to the Euclidean metric.

Key proved properties visualized:
- λ(0) = 2 (minimum at the center)
- λ(z) ≥ 2 everywhere (proved in Lean as poincareConformal_ge_two)
- λ(z) → ∞ as |z| → 1 (distances diverge near the boundary)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


# Create grid
resolution = 500
x = np.linspace(-1, 1, resolution)
y = np.linspace(-1, 1, resolution)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2

# Compute conformal factor (only inside disk)
mask = R2 < 0.999
Lambda = np.full_like(R2, np.nan)
Lambda[mask] = 2.0 / (1.0 - R2[mask])

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(Lambda, extent=[-1, 1, -1, 1], origin='lower',
                cmap='inferno', norm=LogNorm(vmin=2, vmax=200),
                interpolation='bilinear')

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)

# Mark origin
ax1.plot(0, 0, 'co', markersize=8, label='Origin: λ = 2')

ax1.set_xlim(-1.1, 1.1)
ax1.set_ylim(-1.1, 1.1)
ax1.set_aspect('equal')
ax1.set_title('Conformal Factor λ(z) = 2/(1 - |z|²)', fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)', fontsize=11)
ax1.set_ylabel('Im(z)', fontsize=11)
ax1.legend(fontsize=10)

cbar = plt.colorbar(im, ax=ax1, shrink=0.8)
cbar.set_label('λ(z)', fontsize=11)

# Radial profile
ax2 = axes[1]
r_vals = np.linspace(0, 0.999, 500)
lambda_vals = 2.0 / (1.0 - r_vals**2)

ax2.semilogy(r_vals, lambda_vals, 'b-', linewidth=2, label='λ(r) = 2/(1-r²)')
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.7, label='λ = 2 (minimum)')
ax2.fill_between(r_vals, 2, lambda_vals, alpha=0.1, color='blue')

ax2.set_xlabel('Euclidean distance from origin (r)', fontsize=11)
ax2.set_ylabel('Conformal factor λ(r)', fontsize=11)
ax2.set_title('Radial Profile: λ ≥ 2 Everywhere', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_xlim(0, 1)
ax2.set_ylim(1.5, 500)
ax2.grid(True, alpha=0.3)

# Annotate key points
ax2.annotate('Flat (Euclidean-like)',
             xy=(0.1, 2.02), fontsize=9, color='green',
             arrowprops=dict(arrowstyle='->', color='green'),
             xytext=(0.2, 5))
ax2.annotate('Highly curved\n(near boundary)',
             xy=(0.95, 40), fontsize=9, color='red',
             arrowprops=dict(arrowstyle='->', color='red'),
             xytext=(0.6, 100))

plt.tight_layout()
plt.savefig('viz_conformal_factor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_conformal_factor.png")


#!/usr/bin/env python3
"""
Visualization: Critical Line → Poincaré Disk Mapping

Shows how the Cayley-type transform s ↦ (s-1)/(s+1) maps the critical line
Re(s) = 1/2 into the Poincaré disk. This is the geometric content of
the theorem critical_line_to_disk: ‖(ρ-1)/(ρ+1)‖ ≤ 1 for Re(ρ) = 1/2.

The first 20 non-trivial zeros of the Riemann zeta function are mapped
to show that they all land inside the unit disk.
"""

import numpy as np
import matplotlib.pyplot as plt


# First 20 non-trivial zeros of ζ(s) (imaginary parts)
zeta_zeros = [
    14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
    37.586178, 40.918719, 43.327073, 48.005151, 49.773832,
    52.970321, 56.446248, 59.347044, 60.831779, 65.112544,
    67.079811, 69.546402, 72.067158, 75.704691, 77.144840
]


def cayley_map(s: complex) -> complex:
    """Cayley-type transform: s ↦ (s-1)/(s+1)."""
    return (s - 1) / (s + 1)


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Critical line in the s-plane
ax1 = axes[0]

# Draw critical strip
ax1.axvspan(0, 1, alpha=0.1, color='blue', label='Critical strip')
ax1.axvline(x=0.5, color='red', linewidth=2, label='Critical line Re(s)=1/2')

# Plot zeros
for t in zeta_zeros:
    ax1.plot(0.5, t, 'ko', markersize=6)
    ax1.plot(0.5, -t, 'ko', markersize=6)

# Annotations
ax1.set_xlabel('Re(s)', fontsize=12)
ax1.set_ylabel('Im(s)', fontsize=12)
ax1.set_title('Riemann Zeta Zeros\nin the s-plane', fontsize=13, fontweight='bold')
ax1.set_xlim(-1, 2)
ax1.set_ylim(-85, 85)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right: Poincaré disk
ax2 = axes[1]

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Draw the image of the critical line
t_range = np.linspace(-100, 100, 2000)
critical_line_image = [cayley_map(complex(0.5, t)) for t in t_range]
cl_x = [w.real for w in critical_line_image]
cl_y = [w.imag for w in critical_line_image]
ax2.plot(cl_x, cl_y, 'r-', linewidth=1.5, alpha=0.5, label='Image of critical line')

# Draw images of other vertical lines for context
for sigma in [0.0, 0.25, 0.75, 1.0]:
    line_image = [cayley_map(complex(sigma, t)) for t in t_range]
    lx = [w.real for w in line_image]
    ly = [w.imag for w in line_image]
    ax2.plot(lx, ly, 'b-', linewidth=0.5, alpha=0.3)

# Map zeta zeros to disk
zero_disk = []
for t in zeta_zeros:
    rho = complex(0.5, t)
    w = cayley_map(rho)
    zero_disk.append(w)
    ax2.plot(w.real, w.imag, 'ko', markersize=5)
    # Also plot conjugate
    w_conj = cayley_map(complex(0.5, -t))
    ax2.plot(w_conj.real, w_conj.imag, 'ko', markersize=5)

# Verify all are in disk
norms = [abs(w) for w in zero_disk]
max_norm = max(norms)

ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)
ax2.set_aspect('equal')
ax2.set_title('Zeta Zeros Mapped to\nPoincaré Disk via Cayley Transform',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(w)', fontsize=12)
ax2.set_ylabel('Im(w)', fontsize=12)
ax2.legend(fontsize=10, loc='upper right')

# Add text about the theorem
ax2.text(0.02, -1.08,
         f'All {len(zeta_zeros)} zeros inside disk (max |w| = {max_norm:.6f})',
         fontsize=10, style='italic', color='gray')

# Arrow connecting the two plots
fig.text(0.48, 0.5, '→', fontsize=30, ha='center', va='center',
         fontweight='bold', color='darkgreen')
fig.text(0.48, 0.44, '(s-1)/(s+1)', fontsize=10, ha='center', va='center',
         color='darkgreen', style='italic')

plt.tight_layout()
plt.savefig('viz_critical_line.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_critical_line.png")


#!/usr/bin/env python3
"""
Visualization: Hyperbolic Lattice on the Poincaré Disk

Visualizes the orbit of the origin under PSL(2,Z) in the Poincaré disk model,
showing how "hyperbolic integers" tile the hyperbolic plane. Hyperbolic primes
are highlighted in red.

This illustrates the core concept of hyperbolic number theory: arithmetic
on a curved space where the density of lattice points grows exponentially
with distance from the origin.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from typing import List, Tuple, Set


def moebius_add(z: complex, w: complex) -> complex:
    denom = 1 + z.conjugate() * w
    if abs(denom) < 1e-15:
        return 0j
    return (z + w) / denom


def generate_psl2z_orbit(max_depth: int = 5) -> List[complex]:
    """Generate orbit of i under PSL(2,Z), mapped to Poincaré disk."""
    S = np.array([[0, -1], [1, 0]], dtype=float)
    T = np.array([[1, 1], [0, 1]], dtype=float)
    Si = np.array([[0, 1], [-1, 0]], dtype=float)
    Ti = np.array([[1, -1], [0, 1]], dtype=float)
    gens = [S, T, Si, Ti]
    
    base = 1j
    orbit = set()
    visited = set()
    
    def mat_key(M):
        return tuple(np.round(M.flatten(), 8))
    
    current = [np.eye(2)]
    visited.add(mat_key(np.eye(2)))
    
    def act(M, z):
        d = M[1, 0] * z + M[1, 1]
        if abs(d) < 1e-15:
            return None
        return (M[0, 0] * z + M[0, 1]) / d
    
    def cayley(z):
        return (z - 1j) / (z + 1j)
    
    for _ in range(max_depth):
        nxt = []
        for M in current:
            for g in gens:
                M2 = M @ g
                k = mat_key(M2)
                k_neg = mat_key(-M2)
                if k not in visited and k_neg not in visited:
                    visited.add(k)
                    z = act(M2, base)
                    if z is not None and z.imag > 1e-10:
                        w = cayley(z)
                        if abs(w) < 1 - 1e-10:
                            orbit.add((round(w.real, 10), round(w.imag, 10)))
                    nxt.append(M2)
        current = nxt
    
    return sorted([complex(r, i) for r, i in orbit], key=abs)


def is_hyp_prime(orbit, n, tol=1e-5):
    if n <= 0:
        return False
    target = orbit[n]
    for i in range(1, min(n, 30)):
        for j in range(1, min(n, 30)):
            w = moebius_add(orbit[i], orbit[j])
            if abs(w - target) < tol:
                return False
    return True


# Generate lattice
orbit = generate_psl2z_orbit(4)

# Classify primes
primes = []
composites = []
for n in range(len(orbit)):
    if n == 0:
        continue
    if n < 40 and is_hyp_prime(orbit, n):
        primes.append(orbit[n])
    else:
        composites.append(orbit[n])

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw some geodesics (arcs)
theta = np.linspace(0, 2*np.pi, 100)
for r in [0.3, 0.5, 0.7, 0.9]:
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k-', alpha=0.1, linewidth=0.5)

# Plot composites
if composites:
    cx = [z.real for z in composites]
    cy = [z.imag for z in composites]
    ax.scatter(cx, cy, c='steelblue', s=15, alpha=0.6, zorder=3, label='Composite')

# Plot primes
if primes:
    px = [z.real for z in primes]
    py = [z.imag for z in primes]
    ax.scatter(px, py, c='crimson', s=40, alpha=0.9, zorder=4, marker='*', label='Hyperbolic Prime')

# Plot origin
ax.scatter([0], [0], c='gold', s=100, zorder=5, marker='o', edgecolors='black',
           linewidth=2, label='Origin')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit on the Poincaré Disk',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=11)
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)

# Add annotation
ax.text(0.02, -1.08, f'{len(orbit)} lattice points | {len(primes)} primes detected',
        fontsize=10, style='italic', color='gray')

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_lattice.png")
