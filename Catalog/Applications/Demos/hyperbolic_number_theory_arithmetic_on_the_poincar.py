#!/usr/bin/env python3
"""
Hyperbolic Number Theory — Applications

Shows real-world applications of hyperbolic arithmetic:
1. Hyperbolic signal processing (Poincaré embeddings)
2. Network routing on hyperbolic lattices
3. Cryptographic key generation using Möbius maps
"""

import numpy as np
from typing import List, Tuple


# ─── Inline core functions (self-contained) ──────────────────────────

def mobius_map(a: complex, z: complex) -> complex:
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z: complex) -> float:
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


def hyp_dist(z: complex, w: complex) -> float:
    return hyp_norm(mobius_map(w, z))


def cayley_transform(z: complex) -> complex:
    return 1j * (1 + z) / (1 - z)


# ─── Application 1: Poincaré Embeddings ──────────────────────────────

def poincare_embed_tree(adj: dict, root: str, radius: float = 0.5) -> dict:
    """Embed a tree graph into the Poincaré disk.
    
    Trees embed with zero distortion in hyperbolic space because
    hyperbolic space has exponential growth matching tree branching.
    Uses Möbius translations to place children around each parent.
    
    Args:
        adj: adjacency list {node: [children]}
        root: root node name
        radius: distance parameter for child placement
    
    Returns:
        dict mapping node names to disk positions
    """
    positions = {root: 0j}
    queue = [root]
    visited = {root}
    
    while queue:
        node = queue.pop(0)
        parent_pos = positions[node]
        children = [c for c in adj.get(node, []) if c not in visited]
        n = len(children)
        
        for i, child in enumerate(children):
            angle = 2 * np.pi * i / max(n, 1)
            child_offset = radius * np.exp(1j * angle)
            # Translate from origin to parent position using Möbius map
            # φ_{-parent}(child_offset) places child near parent
            neg_parent = -parent_pos
            child_pos = mobius_map(neg_parent, child_offset)
            
            # Ensure we stay in disk
            if abs(child_pos) >= 0.999:
                child_pos *= 0.999 / abs(child_pos)
            
            positions[child] = child_pos
            visited.add(child)
            queue.append(child)
    
    return positions


# ─── Application 2: Hyperbolic Routing ───────────────────────────────

def greedy_hyperbolic_route(
    positions: dict,
    source: str,
    target: str,
    adj: dict
) -> List[str]:
    """Greedy routing on a hyperbolic network.
    
    At each hop, forward to the neighbor closest (in hyperbolic distance)
    to the target. Hyperbolic routing achieves near-optimal stretch on
    networks with hierarchical/tree-like structure — this is the basis
    for Internet routing protocols using hyperbolic coordinates.
    
    Returns:
        List of node names forming the route.
    """
    path = [source]
    current = source
    visited = {source}
    
    for _ in range(100):  # max hops
        if current == target:
            break
        
        neighbors = [n for n in adj.get(current, []) if n not in visited]
        if not neighbors:
            break
        
        # Pick neighbor closest to target in hyperbolic distance
        target_pos = positions[target]
        best = min(neighbors,
                   key=lambda n: hyp_dist(positions[n], target_pos))
        
        visited.add(best)
        path.append(best)
        current = best
    
    return path


# ─── Application 3: Möbius Key Exchange ──────────────────────────────

def mobius_key_exchange(
    alice_secret: complex,
    bob_secret: complex,
    base_point: complex = 0.1 + 0.1j
) -> Tuple[complex, complex, complex]:
    """Diffie-Hellman-style key exchange using Möbius compositions.
    
    1. Alice applies φ_{alice_secret} to base_point, sends result
    2. Bob applies φ_{bob_secret} to base_point, sends result
    3. Shared secret: both compute φ_a(φ_b(base)) or φ_b(φ_a(base))
    
    Note: Möbius composition is NOT commutative (nonabelian), so this
    is a simplified demo. Real protocols would use the noncommutative
    structure more carefully (cf. AAG protocol).
    
    Returns: (alice_public, bob_public, shared_secret)
    """
    alice_public = mobius_map(alice_secret, base_point)
    bob_public = mobius_map(bob_secret, base_point)
    
    # Alice computes shared secret from Bob's public value
    shared_alice = mobius_map(alice_secret, bob_public)
    # Bob computes shared secret from Alice's public value
    shared_bob = mobius_map(bob_secret, alice_public)
    
    return alice_public, bob_public, shared_alice


# ─── Application 4: Hyperbolic Fourier Analysis ─────────────────────

def hyperbolic_fourier_coefficient(
    f_values: List[Tuple[complex, float]],
    eigenvalue: float
) -> complex:
    """Approximate a Fourier coefficient of a function on the disk.
    
    In hyperbolic space, the Fourier transform uses eigenfunctions of
    the Laplace-Beltrami operator (spherical functions). For the disk,
    these are related to Legendre functions.
    
    This computes a discrete approximation using the sample points.
    
    Args:
        f_values: list of (point, function_value) pairs
        eigenvalue: the spectral parameter λ
    
    Returns:
        Approximate Fourier coefficient
    """
    total = 0j
    for z, fz in f_values:
        # The spherical function for the disk at eigenvalue λ
        # is approximately (1-|z|²)^(1/2 + iλ) for large λ
        r2 = abs(z)**2
        if r2 < 1:
            weight = (1 - r2) ** (0.5 + 1j * eigenvalue)
            # Hyperbolic area element: 4/(1-|z|²)²
            area = 4 / (1 - r2)**2
            total += fz * np.conj(weight) * area
    
    return total / len(f_values) if f_values else 0j


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY — APPLICATIONS")
    print("=" * 70)
    
    # App 1: Tree embedding
    print("\n--- Application 1: Poincaré Tree Embedding ---")
    tree = {
        "root": ["A", "B", "C"],
        "A": ["A1", "A2"],
        "B": ["B1", "B2", "B3"],
        "C": ["C1"],
        "A1": ["A1a", "A1b"],
    }
    positions = poincare_embed_tree(tree, "root", radius=0.4)
    print(f"  Embedded {len(positions)} nodes into Poincaré disk:")
    for node, pos in sorted(positions.items()):
        print(f"    {node}: z = {pos:.4f}, |z| = {abs(pos):.4f}, "
              f"hypNorm = {hyp_norm(pos):.4f}")
    
    # Verify distances
    print("\n  Hyperbolic distances (parent-child ≈ constant):")
    for parent, children in tree.items():
        if parent in positions:
            for child in children:
                if child in positions:
                    d = hyp_dist(positions[parent], positions[child])
                    print(f"    d({parent}, {child}) = {d:.4f}")
    
    # App 2: Routing
    print("\n--- Application 2: Greedy Hyperbolic Routing ---")
    route = greedy_hyperbolic_route(positions, "A1a", "B2", tree)
    print(f"  Route A1a → B2: {' → '.join(route)}")
    print(f"  Hops: {len(route) - 1}")
    
    # App 3: Key exchange
    print("\n--- Application 3: Möbius Key Exchange ---")
    alice = 0.3 + 0.2j
    bob = -0.1 + 0.4j
    pub_a, pub_b, shared = mobius_key_exchange(alice, bob)
    print(f"  Alice's secret: {alice}")
    print(f"  Bob's secret: {bob}")
    print(f"  Alice's public: {pub_a:.6f}")
    print(f"  Bob's public: {pub_b:.6f}")
    print(f"  Shared secret: {shared:.6f}")
    print(f"  |shared| = {abs(shared):.4f} (in disk: {abs(shared) < 1})")
    
    # App 4: Fourier analysis
    print("\n--- Application 4: Hyperbolic Fourier Analysis ---")
    # Create sample function on disk
    np.random.seed(42)
    samples = []
    for _ in range(200):
        r = np.random.random() * 0.9
        theta = np.random.random() * 2 * np.pi
        z = r * np.exp(1j * theta)
        fz = np.exp(-hyp_norm(z))  # Gaussian in hyperbolic distance
        samples.append((z, fz))
    
    print("  Fourier coefficients of exp(-hypNorm):")
    for lam in [0, 1, 2, 5, 10]:
        coeff = hyperbolic_fourier_coefficient(samples, lam)
        print(f"    λ = {lam:2d}: â(λ) = {coeff:.6f}, |â(λ)| = {abs(coeff):.6f}")
    
    # Cayley bridge demo
    print("\n--- Cross-Domain: Cayley Bridge to Number Theory ---")
    print("  Mapping hyperbolic lattice to upper half-plane (modular forms domain):")
    lat_pts = [0.3+0.1j, -0.2+0.4j, 0.5j, 0.6-0.1j]
    for z in lat_pts:
        w = cayley_transform(z)
        print(f"    disk: {z:.3f} → half-plane: {w:.4f}, Im = {w.imag:.4f}")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demo

Demonstrates the core mathematical structures formalized in Lean:
1. Möbius transformations and disk preservation
2. Hyperbolic distance and norm
3. Cayley transform (disk ↔ upper half-plane)
4. Hyperbolic lattice generation and prime counting
"""

import numpy as np


def mobius_map(a: complex, z: complex) -> complex:
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z)"""
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z: complex) -> float:
    """Hyperbolic norm: artanh(|z|) = log((1+|z|)/(1-|z|))/2"""
    r = abs(z)
    if r >= 1:
        return float('inf')
    return np.log((1 + r) / (1 - r)) / 2


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance between z and w in the Poincaré disk."""
    return hyp_norm(mobius_map(w, z))


def cayley_transform(z: complex) -> complex:
    """Cayley transform: disk → upper half-plane, C(z) = i(1+z)/(1-z)"""
    return 1j * (1 + z) / (1 - z)


def cayley_inverse(w: complex) -> complex:
    """Inverse Cayley transform: upper half-plane → disk"""
    return (w - 1j) / (w + 1j)


def verify_normSq_identity(a: complex, z: complex) -> dict:
    """Verify: |1 - conj(a)*z|^2 - |z - a|^2 = (1 - |a|^2)(1 - |z|^2)"""
    lhs = abs(1 - np.conj(a) * z)**2 - abs(z - a)**2
    rhs = (1 - abs(a)**2) * (1 - abs(z)**2)
    return {"lhs": lhs, "rhs": rhs, "error": abs(lhs - rhs)}


def generate_hyperbolic_lattice(generators: list, depth: int = 5) -> list:
    """Generate hyperbolic lattice points by composing Möbius maps."""
    points = {0j}  # Start from origin
    frontier = {0j}
    for d in range(depth):
        new_frontier = set()
        for z in frontier:
            for g in generators:
                w = mobius_map(g, z)
                if abs(w) < 0.9999:  # Stay in disk
                    # Round to avoid floating point duplicates
                    w_round = round(w.real, 10) + 1j * round(w.imag, 10)
                    if w_round not in points:
                        points.add(w_round)
                        new_frontier.add(w_round)
        frontier = new_frontier
        if not frontier:
            break
    return sorted(points, key=abs)


def is_hyp_prime(z: complex, generators: list) -> bool:
    """Check if z is a hyperbolic prime (not decomposable)."""
    if abs(z) < 1e-10:
        return False
    for g1 in generators:
        for g2 in generators:
            if abs(mobius_map(g1, g2) - z) < 1e-8:
                return False
    return True


def count_hyp_primes(points: list, generators: list, R: float) -> int:
    """Count hyperbolic primes with norm ≤ R."""
    return sum(1 for z in points
               if is_hyp_prime(z, generators) and hyp_norm(z) <= R)


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 70)

    # Demo 1: Möbius map properties
    print("\n--- Demo 1: Möbius Transformation Properties ---")
    a = 0.3 + 0.4j
    z = -0.2 + 0.5j
    w = mobius_map(a, z)
    print(f"a = {a}, |a| = {abs(a):.4f}")
    print(f"z = {z}, |z| = {abs(z):.4f}")
    print(f"φ_a(z) = {w:.6f}, |φ_a(z)| = {abs(w):.4f}")
    print(f"Disk preserved: |φ_a(z)| < 1? {abs(w) < 1}")

    # Verify φ_a(a) = 0
    print(f"\nφ_a(a) = {mobius_map(a, a):.2e} (should be 0)")

    # Verify involution: φ_a(φ_a(z)) = z
    print(f"φ_a(φ_a(z)) = {mobius_map(a, w):.6f} (should be {z})")
    print(f"Involution error: {abs(mobius_map(a, w) - z):.2e}")

    # Demo 2: Key algebraic identity
    print("\n--- Demo 2: NormSq Identity Verification ---")
    for _ in range(5):
        a = (np.random.random() * 0.8) * np.exp(2j * np.pi * np.random.random())
        z = (np.random.random() * 0.8) * np.exp(2j * np.pi * np.random.random())
        result = verify_normSq_identity(a, z)
        print(f"  |a|={abs(a):.3f}, |z|={abs(z):.3f}: "
              f"LHS={result['lhs']:.6f}, RHS={result['rhs']:.6f}, "
              f"error={result['error']:.2e}")

    # Demo 3: Hyperbolic distance
    print("\n--- Demo 3: Hyperbolic Norm and Distance ---")
    test_points = [0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]
    for r in test_points:
        z = r + 0j
        print(f"  |z| = {r:.2f} → hypNorm = {hyp_norm(z):.4f}")

    print(f"\n  hypDist(0.3, 0.5) = {hyp_dist(0.3+0j, 0.5+0j):.4f}")
    print(f"  hypDist(0, 0) = {hyp_dist(0, 0):.4f} (should be 0)")

    # Demo 4: Cayley transform
    print("\n--- Demo 4: Cayley Transform (Disk ↔ Half-Plane) ---")
    print(f"  C(0) = {cayley_transform(0):.4f} (should be i)")
    print(f"  C⁻¹(i) = {cayley_inverse(1j):.4f} (should be 0)")
    disk_pts = [0.3+0.2j, -0.5+0.1j, 0.7j, 0.4-0.3j]
    for z in disk_pts:
        w = cayley_transform(z)
        print(f"  C({z}) = {w:.4f}, Im(w) = {w.imag:.4f} > 0? {w.imag > 0}")

    # Demo 5: Hyperbolic lattice
    print("\n--- Demo 5: Hyperbolic Lattice Generation ---")
    gens = [0.5, 0.3j, -0.4+0.2j, 0.2-0.3j]
    lattice = generate_hyperbolic_lattice(gens, depth=4)
    print(f"  Generators: {gens}")
    print(f"  Lattice points (depth 4): {len(lattice)}")
    print(f"  First 10 by |z|:")
    for z in lattice[:10]:
        print(f"    z = {z:.6f}, |z| = {abs(z):.4f}, hypNorm = {hyp_norm(z):.4f}")

    # Demo 6: Prime counting
    print("\n--- Demo 6: Hyperbolic Prime Counting ---")
    for R in [0.5, 1.0, 2.0, 3.0, 5.0]:
        n_primes = count_hyp_primes(lattice, gens, R)
        n_total = sum(1 for z in lattice if hyp_norm(z) <= R)
        ratio = n_primes / max(n_total, 1)
        print(f"  R={R:.1f}: π_H(R) = {n_primes}, N(R) = {n_total}, "
              f"ratio = {ratio:.3f}")

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Cayley Transform — Bridge Between Disk and Half-Plane

Shows how the Cayley transform C(z) = i(1+z)/(1-z) maps the Poincaré disk
to the upper half-plane. This is the geometric bridge between hyperbolic
geometry (where our integers live) and the domain of modular forms
and L-functions (where the Riemann hypothesis lives).
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def cayley_transform(z):
    if abs(1 - z) < 1e-15:
        return complex(0, 1e6)
    return 1j * (1 + z) / (1 - z)


def cayley_inverse(w):
    return (w - 1j) / (w + 1j)


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# ─── Left: Poincaré Disk ───────────────────────────────────────────

ax1 = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax1.add_patch(circle)

# Draw geodesics (circles orthogonal to boundary)
# A geodesic through 0 is a diameter
for angle in np.linspace(0, np.pi, 6, endpoint=False):
    t = np.linspace(-0.95, 0.95, 100)
    x = t * np.cos(angle)
    y = t * np.sin(angle)
    ax1.plot(x, y, 'gray', alpha=0.3, linewidth=0.8)

# Draw concentric hyperbolic circles (constant hyperbolic distance from origin)
for R in [0.5, 1.0, 1.5, 2.0]:
    r_euclid = np.tanh(R)
    circ = plt.Circle((0, 0), r_euclid, fill=False, color='steelblue',
                       linewidth=0.8, linestyle='--', alpha=0.5)
    ax1.add_patch(circ)
    ax1.text(r_euclid + 0.02, 0.02, f'R={R}', fontsize=7, color='steelblue')

# Sample points with colors
np.random.seed(42)
disk_points = []
colors = []
for i in range(50):
    r = np.random.random() * 0.9
    theta = np.random.random() * 2 * np.pi
    z = r * np.exp(1j * theta)
    disk_points.append(z)
    colors.append(hyp_norm(z))

scatter1 = ax1.scatter([z.real for z in disk_points],
                        [z.imag for z in disk_points],
                        c=colors, cmap='plasma', s=30, zorder=3,
                        edgecolors='black', linewidth=0.5)
ax1.scatter(0, 0, c='red', s=80, zorder=5, marker='*')

ax1.set_xlim(-1.3, 1.3)
ax1.set_ylim(-1.3, 1.3)
ax1.set_aspect('equal')
ax1.set_title('Poincaré Disk Model', fontsize=14, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')
plt.colorbar(scatter1, ax=ax1, label='Hyperbolic norm', shrink=0.7)

# ─── Right: Upper Half-Plane ───────────────────────────────────────

ax2 = axes[1]

# Transform points
uhp_points = [cayley_transform(z) for z in disk_points]

# Filter out extreme points for display
uhp_filtered = [(w, c) for w, c in zip(uhp_points, colors)
                if abs(w.real) < 15 and 0 < w.imag < 15]

if uhp_filtered:
    ws, cs = zip(*uhp_filtered)
    scatter2 = ax2.scatter([w.real for w in ws], [w.imag for w in ws],
                            c=cs, cmap='plasma', s=30, zorder=3,
                            edgecolors='black', linewidth=0.5)

# Mark C(0) = i
ax2.scatter(0, 1, c='red', s=80, zorder=5, marker='*')
ax2.annotate('C(0) = i', (0, 1), (0.5, 1.5), fontsize=10, color='red',
             arrowprops=dict(arrowstyle='->', color='red'))

# Draw the real axis (boundary of UHP)
ax2.axhline(y=0, color='black', linewidth=2)

# Draw some horizontal horocycles
for y in [0.5, 1, 2, 4]:
    ax2.axhline(y=y, color='steelblue', linewidth=0.5, linestyle='--', alpha=0.4)

ax2.set_xlim(-8, 8)
ax2.set_ylim(-0.5, 10)
ax2.set_title('Upper Half-Plane (via Cayley Transform)', fontsize=14, fontweight='bold')
ax2.set_xlabel('Re(w)')
ax2.set_ylabel('Im(w)')
ax2.text(3, 9, 'C(z) = i(1+z)/(1−z)', fontsize=11, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

# Draw arrow between panels
fig.patches.append(FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    color='darkgreen', linewidth=3
))
fig.text(0.5, 0.54, 'Cayley\nTransform', ha='center', va='bottom',
         fontsize=11, color='darkgreen', fontweight='bold',
         transform=fig.transFigure)

plt.tight_layout(w_pad=3)
plt.savefig('viz_cayley_bridge.png', dpi=150, bbox_inches='tight')
print("Saved Cayley bridge visualization")


#!/usr/bin/env python3
"""
Visualization 1: Poincaré Disk Lattice and Hyperbolic Primes

Visualizes the hyperbolic integer lattice on the Poincaré disk model,
color-coding points by depth and highlighting hyperbolic primes.
The unit circle boundary represents infinity in hyperbolic space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


def generate_lattice(generators, depth=5):
    points = {0j}
    depths = {0j: 0}
    frontier = {0j}
    for d in range(1, depth + 1):
        new_frontier = set()
        for z in frontier:
            for g in generators:
                w = mobius_map(g, z)
                if abs(w) < 0.9999:
                    w_key = round(w.real, 9) + 1j * round(w.imag, 9)
                    if w_key not in points:
                        points.add(w_key)
                        depths[w_key] = d
                        new_frontier.add(w_key)
        frontier = new_frontier
        if not frontier:
            break
    return list(points), depths


def is_prime(z, generators):
    if abs(z) < 1e-10:
        return False
    for g1 in generators:
        for g2 in generators:
            if abs(mobius_map(g1, g2) - z) < 1e-7:
                return False
    return True


# Generate the lattice
generators = [0.5, 0.35j, -0.3 + 0.25j, 0.2 - 0.35j]
points, depths = generate_lattice(generators, depth=5)

fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# Left panel: lattice colored by depth
ax1 = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax1.add_patch(circle)

max_depth = max(depths.values()) if depths else 1
cmap = plt.cm.viridis
for z in sorted(points, key=lambda p: depths.get(p, 0)):
    d = depths.get(z, 0)
    color = cmap(d / max_depth)
    size = 40 if d == 0 else max(8, 30 - 4 * d)
    ax1.scatter(z.real, z.imag, c=[color], s=size, zorder=3, edgecolors='white',
                linewidth=0.3)

# Mark origin
ax1.scatter(0, 0, c='red', s=100, zorder=5, marker='*', edgecolors='black')
# Mark generators
for g in generators:
    ax1.scatter(g.real, g.imag, c='orange', s=60, zorder=4, marker='D',
                edgecolors='black', linewidth=1)

ax1.set_xlim(-1.15, 1.15)
ax1.set_ylim(-1.15, 1.15)
ax1.set_aspect('equal')
ax1.set_title('Hyperbolic Integer Lattice on the Poincaré Disk', fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')
ax1.grid(True, alpha=0.2)

legend_elements = [
    mpatches.Patch(color='red', label='Origin (0)'),
    mpatches.Patch(color='orange', label='Generators'),
    mpatches.Patch(color=cmap(0.0), label='Depth 0'),
    mpatches.Patch(color=cmap(0.5), label=f'Depth {max_depth//2}'),
    mpatches.Patch(color=cmap(1.0), label=f'Depth {max_depth}'),
]
ax1.legend(handles=legend_elements, loc='lower right', fontsize=9)

# Right panel: primes highlighted
ax2 = axes[1]
circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax2.add_patch(circle2)

primes = [z for z in points if is_prime(z, generators)]
composites = [z for z in points if not is_prime(z, generators) and abs(z) > 1e-10]

for z in composites:
    ax2.scatter(z.real, z.imag, c='lightblue', s=15, zorder=2, alpha=0.6)
for z in primes:
    hn = hyp_norm(z)
    ax2.scatter(z.real, z.imag, c='crimson', s=25, zorder=3, edgecolors='darkred',
                linewidth=0.5)
ax2.scatter(0, 0, c='gold', s=100, zorder=5, marker='*', edgecolors='black')

ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)
ax2.set_aspect('equal')
ax2.set_title('Hyperbolic Primes (red) vs Composites (blue)', fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')
ax2.grid(True, alpha=0.2)
ax2.text(0.02, -1.08, f'{len(primes)} primes / {len(points)} total points',
         fontsize=10, color='crimson')

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(points)} points, {len(primes)} primes")


#!/usr/bin/env python3
"""
Visualization 3: Hyperbolic Prime Counting Function

Plots the hyperbolic prime counting function π_H(R) against the
conjectured asymptotic R²/(2 log R), testing the Hyperbolic Prime
Number Theorem conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


def generate_lattice(generators, depth=6):
    points = {0j}
    frontier = {0j}
    for d in range(depth):
        new_frontier = set()
        for z in frontier:
            for g in generators:
                w = mobius_map(g, z)
                if abs(w) < 0.99999:
                    w_key = round(w.real, 9) + 1j * round(w.imag, 9)
                    if w_key not in points:
                        points.add(w_key)
                        new_frontier.add(w_key)
        frontier = new_frontier
        if not frontier:
            break
    return list(points)


def is_prime(z, generators):
    if abs(z) < 1e-10:
        return False
    for g1 in generators:
        for g2 in generators:
            if abs(mobius_map(g1, g2) - z) < 1e-7:
                return False
    return True


# Generate a large lattice
generators = [0.5, 0.3j, -0.4 + 0.2j, 0.2 - 0.3j, -0.35 - 0.15j]
print("Generating lattice...")
points = generate_lattice(generators, depth=7)
print(f"Generated {len(points)} points")

# Compute hyperbolic norms
norms = [(z, hyp_norm(z)) for z in points if abs(z) > 1e-10]
norms.sort(key=lambda x: x[1])

# Identify primes
prime_norms = [hn for z, hn in norms if is_prime(z, generators)]
prime_norms.sort()

# Compute counting functions
R_values = np.linspace(0.1, max(hn for _, hn in norms) * 0.95, 200)
pi_H = np.array([sum(1 for pn in prime_norms if pn <= R) for R in R_values])
N_total = np.array([sum(1 for _, hn in norms if hn <= R) for R in R_values])

# Conjectured asymptotic
with np.errstate(divide='ignore', invalid='ignore'):
    asymptotic = R_values**2 / (2 * np.log(R_values))
    asymptotic = np.where(np.isfinite(asymptotic) & (asymptotic > 0), asymptotic, 0)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Top left: π_H(R) vs R
ax1 = axes[0, 0]
ax1.plot(R_values, pi_H, 'crimson', linewidth=2, label='π_H(R) (actual)')
ax1.plot(R_values, asymptotic, 'blue', linewidth=1.5, linestyle='--',
         label='R²/(2 log R) (conjectured)')
ax1.set_xlabel('Hyperbolic radius R', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Top right: N(R) total counting function
ax2 = axes[0, 1]
ax2.plot(R_values, N_total, 'darkgreen', linewidth=2, label='N(R) total')
ax2.plot(R_values, pi_H, 'crimson', linewidth=1.5, label='π_H(R) primes')
ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Total vs Prime Counting Functions', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Bottom left: ratio π_H(R) / (R²/(2 log R))
ax3 = axes[1, 0]
with np.errstate(divide='ignore', invalid='ignore'):
    ratio = np.where(asymptotic > 0, pi_H / asymptotic, 0)
    valid = (asymptotic > 0) & (R_values > 0.5)
ax3.plot(R_values[valid], ratio[valid], 'purple', linewidth=2)
ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='ratio = 1')
ax3.set_xlabel('Hyperbolic radius R', fontsize=12)
ax3.set_ylabel('π_H(R) / [R²/(2 log R)]', fontsize=12)
ax3.set_title('Ratio Test for Hyperbolic PNT Conjecture', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, max(ratio[valid]) * 1.2 if np.any(valid) else 5)

# Bottom right: prime density π_H(R)/N(R)
ax4 = axes[1, 1]
with np.errstate(divide='ignore', invalid='ignore'):
    density = np.where(N_total > 0, pi_H / N_total, 0)
    valid_d = N_total > 0
ax4.plot(R_values[valid_d], density[valid_d], 'darkorange', linewidth=2)
ax4.set_xlabel('Hyperbolic radius R', fontsize=12)
ax4.set_ylabel('π_H(R) / N(R)', fontsize=12)
ax4.set_title('Hyperbolic Prime Density', fontsize=13, fontweight='bold')
ax4.grid(True, alpha=0.3)

# Summary stats
total_primes = len(prime_norms)
total_points = len(norms)
fig.suptitle(f'Hyperbolic Prime Number Theorem — {total_primes} primes among '
             f'{total_points} lattice points',
             fontsize=14, fontweight='bold', y=1.01)

plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
print(f"Saved prime counting visualization: {total_primes} primes / {total_points} points")
