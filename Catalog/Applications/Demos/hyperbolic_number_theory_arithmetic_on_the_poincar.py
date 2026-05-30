"""
Applications of Hyperbolic Number Theory
==========================================
Real-world applications connecting hyperbolic arithmetic to
special relativity, network routing, and machine learning.
"""

import cmath
import math


# ─────────────────────────────────────────────────
# Application 1: Relativistic Velocity Addition
# ─────────────────────────────────────────────────

def relativistic_velocity_add(v1: complex, v2: complex) -> complex:
    """Add two 2D relativistic velocities using hyperbolic addition.

    In special relativity, velocities don't add linearly. The correct
    formula for collinear velocities is (v1 + v2)/(1 + v1*v2/c²).
    For 2D velocities in the Poincaré disk model (with c=1),
    this becomes the hyperbolic addition: (v1+v2)/(1+conj(v1)*v2).

    Args:
        v1, v2: 2D velocities as complex numbers (|v| < 1 in units of c)

    Returns:
        Combined velocity satisfying |result| < 1

    Example:
        Two particles each moving at 0.9c in the same direction:
        Their combined velocity is NOT 1.8c but ~0.994c.
    """
    return (v1 + v2) / (1 + v1.conjugate() * v2)


def demo_relativity():
    """Demonstrate relativistic velocity addition."""
    print("APPLICATION 1: Relativistic Velocity Addition")
    print("-" * 50)

    # Two particles moving at 0.9c in the same direction
    v1 = 0.9 + 0j  # 90% speed of light, x-direction
    v2 = 0.9 + 0j
    v_combined = relativistic_velocity_add(v1, v2)
    print(f"  v₁ = 0.9c, v₂ = 0.9c (same direction)")
    print(f"  Classical: v₁ + v₂ = 1.8c (impossible!)")
    print(f"  Relativistic: v₁ ⊕ v₂ = {abs(v_combined):.6f}c")
    print(f"  Still less than c: {abs(v_combined) < 1}")

    # Perpendicular velocities
    v1 = 0.6 + 0j
    v2 = 0.6j
    v_combined = relativistic_velocity_add(v1, v2)
    print(f"\n  v₁ = 0.6c (x), v₂ = 0.6c (y)")
    print(f"  v₁ ⊕ v₂ = ({v_combined.real:.4f}, {v_combined.imag:.4f})c")
    print(f"  |v₁ ⊕ v₂| = {abs(v_combined):.6f}c < 1")

    # Speed of light is an absorbing element
    v1 = 0.5 + 0j
    v2 = 0.999999 + 0j
    v_combined = relativistic_velocity_add(v1, v2)
    print(f"\n  v₁ = 0.5c, v₂ → c")
    print(f"  v₁ ⊕ v₂ = {abs(v_combined):.8f}c → 1")


# ─────────────────────────────────────────────────
# Application 2: Hyperbolic Embeddings for Trees
# ─────────────────────────────────────────────────

def embed_binary_tree(depth: int) -> dict[str, complex]:
    """Embed a binary tree in the Poincaré disk.

    Trees have exponential growth, which matches hyperbolic geometry's
    exponential area growth. This makes the Poincaré disk ideal for
    embedding hierarchical data.

    Algorithm:
        Place root at origin. Each child is placed via a Möbius
        transformation that moves deeper into the disk.

    Args:
        depth: Depth of the binary tree

    Returns:
        Dictionary mapping node labels to disk positions
    """
    def mobius(a: complex, theta: float, z: complex) -> complex:
        phase = cmath.exp(1j * theta)
        return phase * (z - a) / (1 - a.conjugate() * z)

    positions: dict[str, complex] = {"root": 0j}
    r = 0.5  # Initial displacement

    queue = [("root", 0j, 0)]
    while queue:
        label, pos, d = queue.pop(0)
        if d >= depth:
            continue

        for i, angle in enumerate([math.pi / 4, -math.pi / 4]):
            child_label = f"{label}.{'L' if i == 0 else 'R'}"
            # Place child at distance r from parent
            displacement = r * cmath.exp(1j * angle)
            child_pos = mobius(-displacement, 0, pos)
            positions[child_label] = child_pos
            queue.append((child_label, child_pos, d + 1))

    return positions


def demo_tree_embedding():
    """Demonstrate tree embedding in hyperbolic space."""
    print("\nAPPLICATION 2: Hyperbolic Tree Embedding")
    print("-" * 50)

    positions = embed_binary_tree(4)
    print(f"  Embedded binary tree of depth 4: {len(positions)} nodes")
    print(f"  All nodes in disk: {all(abs(z) < 1 for z in positions.values())}")

    # Show some positions
    for label in sorted(positions.keys())[:8]:
        z = positions[label]
        print(f"    {label:20s} → ({z.real:+.4f}, {z.imag:+.4f}), "
              f"|z| = {abs(z):.4f}")

    # Compute distortion
    print(f"\n  Key property: All leaf nodes have similar hyperbolic distances")
    leaves = {k: v for k, v in positions.items() if k.count('.') == 4}
    leaf_dists = [abs(v) ** 2 / (1 - abs(v) ** 2) if abs(v) < 1 else float('inf')
                  for v in leaves.values()]
    if leaf_dists:
        print(f"    Min leaf distance proxy: {min(leaf_dists):.4f}")
        print(f"    Max leaf distance proxy: {max(leaf_dists):.4f}")


# ─────────────────────────────────────────────────
# Application 3: Hyperbolic Random Walk
# ─────────────────────────────────────────────────

def hyperbolic_random_walk(steps: int, step_size: float = 0.1,
                           seed: int = 42) -> list[complex]:
    """Simulate a random walk on the Poincaré disk.

    At each step, the walker takes a step of fixed hyperbolic size
    in a random direction. This uses the Möbius addition to stay
    on the disk.

    Args:
        steps: Number of steps
        step_size: Size of each step (Euclidean, < 1)
        seed: Random seed

    Returns:
        List of positions visited
    """
    import random
    rng = random.Random(seed)

    positions = [0j]
    for _ in range(steps):
        angle = rng.uniform(0, 2 * math.pi)
        displacement = step_size * cmath.exp(1j * angle)
        # Hyperbolic addition to get new position
        new_pos = (positions[-1] + displacement) / \
                  (1 + positions[-1].conjugate() * displacement)
        positions.append(new_pos)
    return positions


def demo_random_walk():
    """Demonstrate hyperbolic random walk."""
    print("\nAPPLICATION 3: Hyperbolic Random Walk")
    print("-" * 50)

    walk = hyperbolic_random_walk(1000, step_size=0.1)
    print(f"  Simulated 1000-step walk with step size 0.1")
    print(f"  Final position: ({walk[-1].real:+.4f}, {walk[-1].imag:+.4f})")
    print(f"  Final |z| = {abs(walk[-1]):.4f}")
    print(f"  Max |z| reached: {max(abs(z) for z in walk):.4f}")

    # Compare with Euclidean random walk distance
    euclidean_dist = abs(walk[-1])
    hyp_dist = euclidean_dist ** 2 / (1 - euclidean_dist ** 2) if euclidean_dist < 1 else float('inf')
    print(f"  Euclidean distance from origin: {euclidean_dist:.4f}")
    print(f"  Hyperbolic distance proxy: {hyp_dist:.4f}")

    # Hyperbolic diffusion is faster than Euclidean
    print(f"\n  Key insight: Hyperbolic random walks drift to the boundary")
    print(f"  (reflecting the negative curvature of the space)")


def main():
    print("=" * 60)
    print("APPLICATIONS OF HYPERBOLIC NUMBER THEORY")
    print("=" * 60)
    demo_relativity()
    demo_tree_embedding()
    demo_random_walk()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================
Demonstrates the core mathematical concepts with concrete numerical examples.
"""

import cmath
import math


def mobius_map(a: complex, theta: float, z: complex) -> complex:
    """Möbius disk automorphism: z ↦ e^{iθ} · (z - a) / (1 - conj(a) · z)"""
    phase = cmath.exp(1j * theta)
    denom = 1 - a.conjugate() * z
    if abs(denom) < 1e-15:
        raise ValueError("Denominator too close to zero")
    return phase * (z - a) / denom


def hyp_add(z: complex, w: complex) -> complex:
    """Hyperbolic addition (Einstein velocity addition): (z+w)/(1+conj(z)w)"""
    denom = 1 + z.conjugate() * w
    if abs(denom) < 1e-15:
        raise ValueError("Denominator too close to zero")
    return (z + w) / denom


def hyp_dist_proxy(z: complex, w: complex) -> float:
    """Hyperbolic distance proxy: |z-w|²/|1-conj(w)z|²"""
    num = abs(z - w) ** 2
    denom = abs(1 - w.conjugate() * z) ** 2
    if denom < 1e-30:
        return float('inf')
    return num / denom


def orbit_points(a: complex, theta: float, n: int) -> list[complex]:
    """Generate n orbit points starting from origin."""
    pts = [0j]
    for _ in range(n - 1):
        pts.append(mobius_map(a, theta, pts[-1]))
    return pts


def counting_function(points: list[complex], r: float) -> int:
    """Count orbit points within Euclidean radius r."""
    return sum(1 for p in points if abs(p) <= r)


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 70)

    # Demo 1: Möbius map sends center to 0
    print("\n--- Demo 1: Möbius map sends center to origin ---")
    a = 0.3 + 0.4j
    theta = math.pi / 6
    result = mobius_map(a, theta, a)
    print(f"  a = {a}")
    print(f"  θ = π/6")
    print(f"  φ_a(a) = {result:.6f}")
    print(f"  |φ_a(a)| = {abs(result):.2e} (should be ~0)")

    # Demo 2: Möbius map preserves disk
    print("\n--- Demo 2: Möbius map preserves the disk ---")
    test_points = [0.5 + 0.3j, -0.2 + 0.7j, 0.1 - 0.6j, 0.9 + 0j]
    for z in test_points:
        w = mobius_map(a, theta, z)
        print(f"  |z| = {abs(z):.4f} → |φ(z)| = {abs(w):.4f}  (< 1: {abs(w) < 1})")

    # Demo 3: Hyperbolic addition
    print("\n--- Demo 3: Hyperbolic addition (gyrogroup) ---")
    z, w = 0.3 + 0.2j, 0.1 - 0.4j
    s = hyp_add(z, w)
    print(f"  z = {z}, w = {w}")
    print(f"  z ⊕ w = {s:.6f}")
    print(f"  |z ⊕ w| = {abs(s):.6f} (< 1: {abs(s) < 1})")

    # Identity
    print(f"  z ⊕ 0 = {hyp_add(z, 0):.6f} (should be {z})")
    print(f"  0 ⊕ z = {hyp_add(0, z):.6f} (should be {z})")

    # Inverse
    neg_result = hyp_add(z, -z)
    print(f"  z ⊕ (-z) = {neg_result:.2e} (should be ~0)")

    # Non-commutativity (gyrogroup)
    print(f"  z ⊕ w = {hyp_add(z, w):.6f}")
    print(f"  w ⊕ z = {hyp_add(w, z):.6f}")
    print(f"  (NOT equal in general — gyrogroup, not abelian group)")

    # Demo 4: Orbit generation and counting
    print("\n--- Demo 4: Orbit generation and counting ---")
    a_gen = 0.5 + 0.0j
    theta_gen = math.pi / 3
    pts = orbit_points(a_gen, theta_gen, 20)
    print(f"  Generator: a = {a_gen}, θ = π/3")
    print(f"  First 10 orbit points:")
    for i, p in enumerate(pts[:10]):
        print(f"    orbit[{i}] = ({p.real:+.6f}, {p.imag:+.6f}), |p| = {abs(p):.6f}")

    print(f"\n  Counting function N(r):")
    for r in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
        count = counting_function(pts, r)
        print(f"    N({r:.2f}) = {count}")

    # Demo 5: Hyperbolic distance proxy
    print("\n--- Demo 5: Hyperbolic distance proxy ---")
    z1, z2 = 0.2 + 0.1j, 0.3 - 0.2j
    d = hypDistProxy = hyp_dist_proxy(z1, z2)
    d_rev = hyp_dist_proxy(z2, z1)
    print(f"  d(z₁, z₂) = {d:.6f}")
    print(f"  d(z₂, z₁) = {d_rev:.6f}")
    print(f"  Symmetric: {abs(d - d_rev) < 1e-12}")
    print(f"  d(z₁, z₁) = {hyp_dist_proxy(z1, z1):.2e} (should be 0)")

    # Demo 6: Testable prediction
    print("\n--- Demo 6: Testable Prediction (Counting Bound) ---")
    pts_large = orbit_points(a_gen, theta_gen, 1000)
    print(f"  Generated 1000 orbit points with a={a_gen}, θ=π/3")
    print(f"  Testing conjecture: N(r) ≤ C/(1-r)² for C ≈ 1")
    for r in [0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99]:
        count = counting_function(pts_large, r)
        bound = 1.0 / (1 - r) ** 2
        satisfied = count <= bound
        print(f"    r={r:.2f}: N(r)={count:4d}, 1/(1-r)²={bound:10.1f}, "
              f"satisfied={satisfied}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization 2: Hyperbolic Counting Function and Density
==========================================================
Visualizes how orbit points distribute in the Poincaré disk
and the growth of the counting function N(r).
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, theta, z):
    """Möbius disk automorphism."""
    phase = np.exp(1j * theta)
    return phase * (z - a) / (1 - np.conj(a) * z)


def generate_orbit(a, theta, n):
    """Generate orbit points."""
    pts = [0j]
    for _ in range(n - 1):
        pts.append(mobius_map(a, theta, pts[-1]))
    return np.array(pts)


def counting_function(points, r_values):
    """Compute counting function for array of radii."""
    norms = np.abs(points)
    return np.array([np.sum(norms <= r) for r in r_values])


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Generate orbit data for different generators
configs = [
    (0.5 + 0j, np.pi / 3, 'a=0.5, θ=π/3'),
    (0.3 + 0.3j, np.pi / 4, 'a=0.3+0.3i, θ=π/4'),
    (0.7 + 0j, np.pi / 7, 'a=0.7, θ=π/7'),
    (0.2 + 0.1j, np.pi / 2, 'a=0.2+0.1i, θ=π/2'),
]

# Panel 1: Radial distribution histograms
ax = axes[0, 0]
for a, theta, label in configs:
    orbit = generate_orbit(a, theta, 500)
    norms = np.abs(orbit)
    ax.hist(norms, bins=30, alpha=0.4, label=label, density=True)
ax.set_xlabel('|z| (Euclidean distance from origin)', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Radial Distribution of Orbit Points', fontsize=12)
ax.legend(fontsize=9)
ax.set_xlim(0, 1)
ax.grid(True, alpha=0.3)

# Panel 2: Counting functions N(r)
ax = axes[0, 1]
r_vals = np.linspace(0, 0.999, 200)
for a, theta, label in configs:
    orbit = generate_orbit(a, theta, 500)
    N_r = counting_function(orbit, r_vals)
    ax.plot(r_vals, N_r, linewidth=2, label=label)

# Add theoretical bound N ≤ total
ax.axhline(y=500, color='gray', linestyle='--', alpha=0.5, label='N=500 (total)')
ax.set_xlabel('Radius r', fontsize=11)
ax.set_ylabel('N(r) = #{orbit points with |z| ≤ r}', fontsize=11)
ax.set_title('Counting Function N(r)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Log-scale counting vs 1/(1-r)²
ax = axes[1, 0]
r_vals_log = np.linspace(0.1, 0.99, 100)
for a, theta, label in configs[:2]:
    orbit = generate_orbit(a, theta, 1000)
    N_r = counting_function(orbit, r_vals_log)
    one_minus_r_inv_sq = 1 / (1 - r_vals_log) ** 2
    ax.plot(one_minus_r_inv_sq, N_r, linewidth=2, label=label)

# Reference line y = x (the conjecture bound)
x_ref = np.logspace(0, 3, 100)
ax.plot(x_ref, x_ref, 'k--', alpha=0.5, label='N(r) = 1/(1-r)²')
ax.set_xlabel('1/(1-r)²', fontsize=11)
ax.set_ylabel('N(r)', fontsize=11)
ax.set_title('Counting vs. Conjectured Bound', fontsize=12)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Hyperbolic distance proxy distribution
ax = axes[1, 1]
a, theta = 0.5 + 0j, np.pi / 3
orbit = generate_orbit(a, theta, 500)
norms = np.abs(orbit)
hyp_dists = norms ** 2 / (1 - norms ** 2 + 1e-15)
hyp_dists_finite = hyp_dists[hyp_dists < 100]

ax.hist(hyp_dists_finite, bins=40, color='coral', alpha=0.7, edgecolor='darkred')
ax.set_xlabel('Hyperbolic distance proxy |z|²/(1-|z|²)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Hyperbolic Distance Distribution\n(a=0.5, θ=π/3)', fontsize=12)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Counting Function Analysis',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('counting_function_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: counting_function_analysis.png")


"""
Visualization 3: Gyrogroup Structure and Non-Commutativity
============================================================
Visualizes the gyrogroup structure of hyperbolic addition,
showing how it differs from ordinary vector addition.
"""

import numpy as np
import matplotlib.pyplot as plt


def hyp_add(z, w):
    """Hyperbolic addition."""
    return (z + w) / (1 + np.conj(z) * w)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Commutativity failure
ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Sample many pairs and show z⊕w vs w⊕z
np.random.seed(42)
n_pairs = 200
z_pts = 0.6 * np.random.randn(n_pairs) + 0.6j * np.random.randn(n_pairs)
z_pts = z_pts * 0.3  # Keep in disk
w_pts = 0.6 * np.random.randn(n_pairs) + 0.6j * np.random.randn(n_pairs)
w_pts = w_pts * 0.3

zw = np.array([hyp_add(z, w) for z, w in zip(z_pts, w_pts)])
wz = np.array([hyp_add(w, z) for z, w in zip(z_pts, w_pts)])

ax.scatter(zw.real, zw.imag, c='blue', s=8, alpha=0.5, label='z ⊕ w')
ax.scatter(wz.real, wz.imag, c='red', s=8, alpha=0.5, label='w ⊕ z')

# Connect corresponding points
for i in range(min(50, n_pairs)):
    ax.plot([zw[i].real, wz[i].real], [zw[i].imag, wz[i].imag],
            'gray', alpha=0.2, linewidth=0.5)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Non-Commutativity of ⊕\n(z⊕w ≠ w⊕z in general)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Comparison with Euclidean addition
ax = axes[1]

# Points near origin (nearly commutative) vs far from origin
radii = np.linspace(0.05, 0.95, 50)
comm_errors = []
for r in radii:
    errs = []
    for _ in range(100):
        angle1 = np.random.uniform(0, 2 * np.pi)
        angle2 = np.random.uniform(0, 2 * np.pi)
        z = r * np.exp(1j * angle1)
        w = r * np.exp(1j * angle2)
        zw = hyp_add(z, w)
        wz = hyp_add(w, z)
        errs.append(abs(zw - wz))
    comm_errors.append(np.mean(errs))

ax.plot(radii, comm_errors, 'b-', linewidth=2, label='Mean |z⊕w - w⊕z|')
ax.fill_between(radii, 0, comm_errors, alpha=0.2, color='blue')
ax.set_xlabel('Radius |z| = |w|', fontsize=11)
ax.set_ylabel('Commutativity Error', fontsize=11)
ax.set_title('Non-Commutativity vs. Radius\n(Approaches 0 near origin)', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

# Panel 3: Velocity addition in special relativity
ax = axes[2]

# Compare Galilean vs Einstein velocity addition
v1_vals = np.linspace(0, 0.99, 100)
v2 = 0.5  # Fixed second velocity

galilean = v1_vals + v2
einstein = np.array([abs(hyp_add(v1 + 0j, v2 + 0j)) for v1 in v1_vals])

ax.plot(v1_vals, galilean, 'r--', linewidth=2, label='Galilean: v₁ + v₂')
ax.plot(v1_vals, einstein, 'b-', linewidth=2, label='Einstein: v₁ ⊕ v₂')
ax.axhline(y=1.0, color='gold', linewidth=3, alpha=0.7, label='Speed of light (c=1)')
ax.fill_between(v1_vals, einstein, 1, alpha=0.1, color='blue')

ax.set_xlabel('v₁ (in units of c)', fontsize=11)
ax.set_ylabel('Combined velocity', fontsize=11)
ax.set_title('Einstein vs. Galilean Addition\n(v₂ = 0.5c fixed)', fontsize=12)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.6)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Gyrogroup Structure: Hyperbolic Addition on the Poincaré Disk',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gyrogroup_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: gyrogroup_structure.png")


"""
Visualization 1: Poincaré Disk Orbits and Tessellation
=======================================================
Visualizes the orbit of the origin under iterated Möbius transformations,
showing how "hyperbolic integers" tile the Poincaré disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius_map(a, theta, z):
    """Möbius disk automorphism."""
    phase = np.exp(1j * theta)
    return phase * (z - a) / (1 - np.conj(a) * z)


def generate_orbit(a, theta, n):
    """Generate orbit points."""
    pts = [0j]
    for _ in range(n - 1):
        pts.append(mobius_map(a, theta, pts[-1]))
    return np.array(pts)


def hyp_add(z, w):
    """Hyperbolic addition."""
    return (z + w) / (1 + np.conj(z) * w)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Single generator orbit
ax = axes[0]
a, theta = 0.4 + 0.1j, np.pi / 5
orbit = generate_orbit(a, theta, 200)

circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)
ax.scatter(orbit.real, orbit.imag, c=np.arange(len(orbit)),
           cmap='viridis', s=15, zorder=5)
ax.plot(orbit.real[:50], orbit.imag[:50], 'b-', alpha=0.3, linewidth=0.5)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Orbit under Möbius Generator\n(Hyperbolic Integers)', fontsize=12)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.grid(True, alpha=0.3)

# Panel 2: Multiple generator orbits (tessellation seed)
ax = axes[1]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

generators = [
    (0.5 + 0j, 0),
    (0.3j, np.pi / 3),
    (-0.4 + 0.2j, np.pi / 6),
]
colors_gen = ['#e74c3c', '#3498db', '#2ecc71']
labels = ['Gen 1: a=0.5', 'Gen 2: a=0.3i', 'Gen 3: a=-0.4+0.2i']

for (a, theta), color, label in zip(generators, colors_gen, labels):
    orb = generate_orbit(a, theta, 100)
    ax.scatter(orb.real, orb.imag, c=color, s=10, alpha=0.7, label=label, zorder=5)

ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10, label='Origin')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Multiple Generator Orbits\n(Hyperbolic Lattice Seeds)', fontsize=12)
ax.legend(fontsize=8, loc='lower right')
ax.grid(True, alpha=0.3)

# Panel 3: Hyperbolic addition grid
ax = axes[2]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Create a grid of hyperbolic sums
base_points = [0.3 * np.exp(2j * np.pi * k / 6) for k in range(6)]
grid_pts = []
for z in base_points:
    for w in base_points:
        s = hyp_add(z, w)
        grid_pts.append(s)
        # Second level
        for v in base_points[:3]:
            grid_pts.append(hyp_add(s, v))

grid_pts = np.array(grid_pts)
mask = np.abs(grid_pts) < 1
grid_pts = grid_pts[mask]

ax.scatter(grid_pts.real, grid_pts.imag, c='purple', s=5, alpha=0.5)
for z in base_points:
    ax.scatter([z.real], [z.imag], c='red', s=50, zorder=10)
ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Addition Grid\n(Gyrogroup Structure)', fontsize=12)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory: Arithmetic on the Poincaré Disk',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('poincare_disk_orbits.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_disk_orbits.png")
