"""
Applications of Hyperbolic Number Theory
==========================================
Real-world applications of arithmetic on the Poincaré disk.
"""
import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Hyperbolic Tiling & Network Topology
# ============================================================

def hyperbolic_tree_layout(branching: int = 3, depth: int = 4) -> List[Tuple[complex, int]]:
    """Lay out a tree in hyperbolic space using disk automorphisms.

    Hyperbolic space naturally accommodates exponentially-growing trees,
    making it ideal for network visualization (internet topology, social
    networks, file systems).

    Args:
        branching: Number of children per node.
        depth: Maximum tree depth.

    Returns:
        List of (position, depth) pairs for each node.
    """
    nodes = [(0+0j, 0)]
    radius = 0.5  # Euclidean radius for first ring

    def place_children(parent: complex, level: int, angle_start: float, angle_span: float):
        if level >= depth:
            return
        r = 1 - (1 - radius) ** (level + 1)
        for i in range(branching):
            angle = angle_start + angle_span * (i + 0.5) / branching
            child = parent + r * np.exp(1j * angle) * (1 - abs(parent))
            # Project back into disk if needed
            if abs(child) >= 0.99:
                child = child / abs(child) * 0.98
            nodes.append((child, level + 1))
            place_children(child, level + 1, angle - angle_span/(2*branching),
                         angle_span / branching)

    place_children(0, 0, 0, 2 * np.pi)
    return nodes


# ============================================================
# Application 2: Relativistic Velocity Addition
# ============================================================

def relativistic_velocity_add(v1: complex, v2: complex) -> complex:
    """Add two relativistic velocities using the Poincaré disk model.

    In special relativity, velocities in the plane are bounded by c.
    Normalizing c=1, the velocity space is the unit disk, and
    velocity addition is exactly a disk automorphism:

        v1 ⊕ v2 = (v1 + v2) / (1 + conj(v1)·v2)

    This is the physical incarnation of Möbius composition!

    Args:
        v1, v2: Complex velocities with |v| < 1 (in units of c).

    Returns:
        Combined velocity, still in the disk.
    """
    return (v1 + v2) / (1 + np.conj(v1) * v2)


def demo_relativistic():
    """Demonstrate non-commutativity of relativistic velocity addition."""
    print("=== Relativistic Velocity Addition ===")
    v1 = 0.6 + 0.0j   # 60% of c in x-direction
    v2 = 0.0 + 0.5j   # 50% of c in y-direction

    v12 = relativistic_velocity_add(v1, v2)
    v21 = relativistic_velocity_add(v2, v1)

    print(f"v1 = {v1} ({abs(v1)*100:.0f}% of c)")
    print(f"v2 = {v2} ({abs(v2)*100:.0f}% of c)")
    print(f"v1 ⊕ v2 = {v12:.4f} (|v| = {abs(v12)*100:.1f}% of c)")
    print(f"v2 ⊕ v1 = {v21:.4f} (|v| = {abs(v21)*100:.1f}% of c)")
    print(f"Non-commutativity: |v1⊕v2 - v2⊕v1| = {abs(v12-v21):.6f}")
    print(f"Thomas rotation: {np.angle(v12/v21)*180/np.pi:.2f}°")

    # Verify: speed never exceeds c
    speeds = []
    for _ in range(1000):
        v = (np.random.random() * 0.99) * np.exp(2j * np.pi * np.random.random())
        w = (np.random.random() * 0.99) * np.exp(2j * np.pi * np.random.random())
        speeds.append(abs(relativistic_velocity_add(v, w)))
    print(f"Max speed in 1000 random additions: {max(speeds):.6f}c (< 1)")


# ============================================================
# Application 3: Signal Propagation in Hyperbolic Networks
# ============================================================

def hyperbolic_routing_cost(source: complex, target: complex) -> float:
    """Compute routing cost in a hyperbolic network.

    Greedy routing in hyperbolic space has O(log n) stretch for
    n-node networks, making it asymptotically optimal. The cost
    is the hyperbolic distance.

    Args:
        source, target: Points in the Poincaré disk.

    Returns:
        Hyperbolic distance (routing cost).
    """
    cross = abs(source - target)**2 / ((1 - abs(source)**2) * (1 - abs(target)**2))
    return 2 * np.arcsinh(np.sqrt(cross))


def demo_routing():
    """Compare Euclidean vs hyperbolic routing in a tree network."""
    print("\n=== Hyperbolic Network Routing ===")
    # Place nodes on concentric rings (hyperbolic layout)
    np.random.seed(42)
    nodes = [0+0j]  # root
    for ring in range(1, 5):
        r = 1 - 0.5**ring  # Euclidean radius
        n_nodes = 2**ring
        for i in range(n_nodes):
            angle = 2 * np.pi * i / n_nodes + 0.1 * ring
            nodes.append(r * np.exp(1j * angle))

    # Compare distances
    print(f"Network: {len(nodes)} nodes in 4 rings")
    print(f"{'Pair':<15} {'Euclidean':>10} {'Hyperbolic':>12}")
    for i, j in [(0, 1), (0, 15), (1, 8), (7, 15)]:
        euc = abs(nodes[i] - nodes[j])
        hyp = hyperbolic_routing_cost(nodes[i], nodes[j])
        print(f"  ({i:2d}, {j:2d})      {euc:10.4f}   {hyp:12.4f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Tree layout
    tree = hyperbolic_tree_layout(branching=3, depth=3)
    print(f"Hyperbolic tree: {len(tree)} nodes placed in disk\n")

    demo_relativistic()
    demo_routing()

    print("\n=== Summary ===")
    print("Hyperbolic number theory connects to:")
    print("  1. Network topology (hyperbolic tree layouts)")
    print("  2. Special relativity (velocity addition = Möbius composition)")
    print("  3. Routing algorithms (O(log n) greedy routing)")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================
Demonstrates the core mathematical concepts with concrete numerical examples.
"""
import numpy as np
from typing import Tuple, List

def moebius_apply(a: complex, b: complex, c: complex, d: complex, z: complex) -> complex:
    """Apply Möbius transformation z -> (az+b)/(cz+d)."""
    return (a * z + b) / (c * z + d)

def moebius_compose(S: Tuple, T: Tuple) -> Tuple:
    """Compose two Möbius transformations via matrix multiplication.
    Each is (a,b,c,d)."""
    sa, sb, sc, sd = S
    ta, tb, tc, td = T
    return (
        sa*ta + sb*tc,
        sa*tb + sb*td,
        sc*ta + sd*tc,
        sc*tb + sd*td
    )

def moebius_det(T: Tuple) -> complex:
    """Compute determinant ad - bc."""
    a, b, c, d = T
    return a * d - b * c

def disk_aut(a: complex, z: complex) -> complex:
    """Disk automorphism T_a(z) = (z - a) / (1 - conj(a)*z)."""
    return (z - a) / (1 - np.conj(a) * z)

def hyp_cross_ratio(z: complex, w: complex) -> float:
    """Hyperbolic cross-ratio: |z-w|² / ((1-|z|²)(1-|w|²))."""
    return abs(z - w)**2 / ((1 - abs(z)**2) * (1 - abs(w)**2))

def hyp_distance(z: complex, w: complex) -> float:
    """Hyperbolic distance d_H(z,w) = 2 * arcsinh(sqrt(cross_ratio))."""
    cr = hyp_cross_ratio(z, w)
    return 2 * np.arcsinh(np.sqrt(cr))

def gauss_circle_count(n: int) -> int:
    """Count integer points (a,b) with a²+b² ≤ n in [-n,n]²."""
    count = 0
    for a in range(-n, n+1):
        for b in range(-n, n+1):
            if a**2 + b**2 <= n:
                count += 1
    return count


def main():
    print("=" * 60)
    print("HYPERBOLIC NUMBER THEORY: Arithmetic on the Poincaré Disk")
    print("=" * 60)

    # 1. Möbius transformation identity
    print("\n--- Möbius Identity Test ---")
    identity = (1+0j, 0+0j, 0+0j, 1+0j)
    z = 0.3 + 0.4j
    result = moebius_apply(*identity, z)
    print(f"Id({z}) = {result}  (should equal {z})")
    assert abs(result - z) < 1e-10, "Identity failed!"

    # 2. Determinant multiplicativity
    print("\n--- Determinant Multiplicativity ---")
    S = (2+1j, 1+0j, 0+1j, 1+1j)
    T = (1+0j, 1+1j, 0+0j, 2+0j)
    ST = moebius_compose(S, T)
    det_S = moebius_det(S)
    det_T = moebius_det(T)
    det_ST = moebius_det(ST)
    print(f"det(S) = {det_S}")
    print(f"det(T) = {det_T}")
    print(f"det(S·T) = {det_ST}")
    print(f"det(S)·det(T) = {det_S * det_T}")
    assert abs(det_ST - det_S * det_T) < 1e-10, "Multiplicativity failed!"
    print("✓ det(S·T) = det(S)·det(T)")

    # 3. Composition = sequential application
    print("\n--- Composition vs Sequential Application ---")
    z = 0.2 + 0.1j
    Tz = moebius_apply(*T, z)
    STz_seq = moebius_apply(*S, Tz)
    STz_comp = moebius_apply(*ST, z)
    print(f"S(T(z)) = {STz_seq}")
    print(f"(S·T)(z) = {STz_comp}")
    assert abs(STz_seq - STz_comp) < 1e-10, "Composition failed!"
    print("✓ Composition agrees with sequential application")

    # 4. Disk automorphism properties
    print("\n--- Disk Automorphism ---")
    a = 0.3 + 0.2j
    print(f"a = {a}, |a| = {abs(a):.4f}")
    print(f"T_a(a) = {disk_aut(a, a):.6f}  (should be 0)")
    print(f"T_a(0) = {disk_aut(a, 0)}  (should be {-a})")
    assert abs(disk_aut(a, a)) < 1e-10
    assert abs(disk_aut(a, 0) - (-a)) < 1e-10
    print("✓ T_a(a) = 0 and T_a(0) = -a")

    # 5. Hyperbolic distance properties
    print("\n--- Hyperbolic Distance ---")
    z = 0.1 + 0.2j
    w = 0.4 + 0.3j
    d_zw = hyp_distance(z, w)
    d_wz = hyp_distance(w, z)
    d_zz = hyp_distance(z, z)
    print(f"d_H(z, w) = {d_zw:.6f}")
    print(f"d_H(w, z) = {d_wz:.6f}")
    print(f"d_H(z, z) = {d_zz:.6f}")
    assert abs(d_zw - d_wz) < 1e-10, "Symmetry failed!"
    assert abs(d_zz) < 1e-10, "Self-distance failed!"
    print("✓ Distance is symmetric and d(z,z) = 0")

    # 6. Gauss circle problem
    print("\n--- Gauss Circle Problem ---")
    for n in [1, 2, 5, 10, 20]:
        count = gauss_circle_count(n)
        bound = (2*n+1)**2
        ratio = count / (np.pi * n) if n > 0 else 0
        print(f"  G({n:2d}) = {count:5d},  (2n+1)² = {bound:5d},  G(n)/(πn) = {ratio:.4f}")
    print("  (G(n)/(πn) → 1 as n → ∞, the Gauss circle theorem)")

    # 7. Integer square counting
    print("\n--- Integer Square Counting ---")
    for R in [1, 2, 3, 5, 10]:
        count = (2*R + 1)**2
        print(f"  |[-{R},{R}]²| = (2·{R}+1)² = {count}")

    # 8. Hyperbolic vs Euclidean growth
    print("\n--- Hyperbolic vs Euclidean Lattice Growth ---")
    print("  R   Euclidean~πR²   Hyperbolic~e^R/R")
    for R in [1, 2, 5, 10, 20]:
        euc = np.pi * R**2
        hyp = np.exp(R) / R
        print(f"  {R:2d}   {euc:12.1f}      {hyp:12.1f}")
    print("  Hyperbolic growth dominates exponentially!")

    print("\n" + "=" * 60)
    print("All demonstrations passed successfully.")
    print("=" * 60)

if __name__ == "__main__":
    main()


"""
Visualization 1: Poincaré Disk Tessellation and Hyperbolic Lattice Points
=========================================================================
Shows the orbit of a basepoint under a group of Möbius transformations,
illustrating how hyperbolic integers tile the disk. The exponential growth
of lattice points is visible as density increases toward the boundary.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from collections import deque


def moebius_apply(a, b, c, d, z):
    return (a * z + b) / (c * z + d)


def disk_aut(center, z):
    """Disk automorphism sending center to 0."""
    return (z - center) / (1 - np.conj(center) * z)


def enumerate_orbit(generators, basepoint=0, max_depth=6, tol=1e-6):
    """BFS orbit enumeration."""
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append((g[3], -g[1], -g[2], g[0]))  # inverse

    orbit = [basepoint]
    seen = {(round(basepoint.real/tol), round(basepoint.imag/tol))}
    queue = deque([(basepoint, 0)])

    while queue:
        pt, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for g in all_gens:
            new_pt = moebius_apply(*g, pt)
            if abs(new_pt) >= 1 - 1e-10:
                continue
            key = (round(new_pt.real/tol), round(new_pt.imag/tol))
            if key not in seen:
                seen.add(key)
                orbit.append(new_pt)
                queue.append((new_pt, depth + 1))
    return orbit


def hyp_distance(z, w):
    cr = abs(z-w)**2 / ((1-abs(z)**2) * (1-abs(w)**2))
    return 2 * np.arcsinh(np.sqrt(max(cr, 0)))


# Create generators (approximate PSL(2,Z) in disk model)
g1 = (1, -0.3, -0.3, 1)    # disk automorphism-like
g2 = (1, -0.3j, 0.3j, 1)   # rotation-like

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Orbit tessellation
ax = axes[0]
orbit = enumerate_orbit([g1, g2], basepoint=0, max_depth=5)

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Color by hyperbolic distance from origin
distances = [hyp_distance(0, p) for p in orbit]
max_d = max(distances) if distances else 1

xs = [p.real for p in orbit]
ys = [p.imag for p in orbit]
scatter = ax.scatter(xs, ys, c=distances, cmap='viridis', s=15, zorder=5,
                     edgecolors='none', vmin=0, vmax=max_d)
ax.scatter([0], [0], c='red', s=80, zorder=10, marker='*', label='Origin')

plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin')
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Lattice Points on the Poincaré Disk', fontsize=13)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper right')
ax.grid(True, alpha=0.3)

# Right: Growth comparison
ax2 = axes[1]
Rs = np.arange(1, 15)
orbit_full = enumerate_orbit([g1, g2], basepoint=0, max_depth=8)
all_dists = sorted([hyp_distance(0, p) for p in orbit_full])

counts = []
for R in Rs:
    count = sum(1 for d in all_dists if d <= R)
    counts.append(count)

ax2.semilogy(Rs, counts, 'bo-', label='Orbit count N(R)', markersize=6)
ax2.semilogy(Rs, [np.exp(r)/r for r in Rs], 'r--', label='$e^R / R$', linewidth=2)
ax2.semilogy(Rs, [np.pi * r**2 for r in Rs], 'g:', label='$\\pi R^2$ (Euclidean)', linewidth=2)

ax2.set_xlabel('Hyperbolic radius R')
ax2.set_ylabel('Count (log scale)')
ax2.set_title('Lattice Point Growth:\nHyperbolic (exp) vs Euclidean (poly)', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('poincare_disk_tessellation.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: poincare_disk_tessellation.png")


"""
Visualization 3: Relativistic Velocity Addition as Möbius Composition
======================================================================
Shows how special-relativistic velocity addition is a Möbius transformation
on the Poincaré disk, connecting hyperbolic number theory to physics.
The Thomas rotation effect emerges naturally from non-commutativity.
"""
import numpy as np
import matplotlib.pyplot as plt


def relativistic_add(v1, v2):
    """Relativistic velocity addition (Poincaré disk model)."""
    return (v1 + v2) / (1 + np.conj(v1) * v2)


def hyp_geodesic(z, w, n=100):
    """Compute the hyperbolic geodesic between z and w in the disk."""
    # Use the disk automorphism to map z to 0, draw a line, map back
    if abs(z - w) < 1e-10:
        return [z]
    # Parametric Möbius interpolation
    T = disk_aut_matrix(z)
    w_mapped = moebius_apply_tuple(T, w)
    # Geodesic through 0 and w_mapped is a diameter
    t = np.linspace(0, 1, n)
    line = w_mapped * t
    # Map back
    T_inv = (T[3], -T[1], -T[2], T[0])
    return [moebius_apply_tuple(T_inv, p) for p in line]


def disk_aut_matrix(a):
    return (1, -a, -np.conj(a), 1)


def moebius_apply_tuple(T, z):
    return (T[0]*z + T[1]) / (T[2]*z + T[3])


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Velocity addition grid
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Fix v1, vary v2
v1 = 0.5 + 0j
n_arrows = 12
colors = plt.cm.hsv(np.linspace(0, 1, n_arrows, endpoint=False))
for i in range(n_arrows):
    angle = 2 * np.pi * i / n_arrows
    for speed in [0.2, 0.4, 0.6]:
        v2 = speed * np.exp(1j * angle)
        v_sum = relativistic_add(v1, v2)
        ax.plot([v2.real], [v2.imag], 'o', color=colors[i], markersize=4, alpha=0.5)
        ax.plot([v_sum.real], [v_sum.imag], 's', color=colors[i], markersize=5)
        ax.annotate('', xy=(v_sum.real, v_sum.imag),
                   xytext=(v2.real, v2.imag),
                   arrowprops=dict(arrowstyle='->', color=colors[i], alpha=0.4))

ax.plot([v1.real], [v1.imag], 'r*', markersize=15, label=f'$v_1 = {v1.real}c$', zorder=10)
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Relativistic Velocity Addition\n$v_1 \\oplus v_2$ (circles → squares)', fontsize=12)
ax.set_xlabel('$v_x / c$')
ax.set_ylabel('$v_y / c$')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Non-commutativity (Thomas rotation)
ax = axes[1]
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

v1s = [0.3+0j, 0.5+0j, 0.7+0j]
v2 = 0.0 + 0.4j
markers = ['o', 's', '^']
for idx, v1 in enumerate(v1s):
    angles = np.linspace(0, 2*np.pi, 60)
    v12_pts = [relativistic_add(v1, 0.3*np.exp(1j*a)) for a in angles]
    v21_pts = [relativistic_add(0.3*np.exp(1j*a), v1) for a in angles]
    ax.plot([p.real for p in v12_pts], [p.imag for p in v12_pts],
            '-', linewidth=1.5, label=f'$v_1={abs(v1):.1f}c \\oplus$ circle')
    ax.plot([p.real for p in v21_pts], [p.imag for p in v21_pts],
            '--', linewidth=1.5, alpha=0.6)

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Thomas Rotation Effect\nSolid: $v_1 \\oplus v_2$, Dashed: $v_2 \\oplus v_1$', fontsize=12)
ax.set_xlabel('$v_x / c$')
ax.set_ylabel('$v_y / c$')
ax.legend(fontsize=9, loc='lower left')
ax.grid(True, alpha=0.3)

# Panel 3: Speed composition saturation
ax = axes[2]
speeds = np.linspace(0, 0.99, 200)
# Collinear addition: v1 ⊕ v2 = (v1 + v2)/(1 + v1*v2)
for v1_base in [0.1, 0.3, 0.5, 0.7, 0.9]:
    result = [(v1_base + s) / (1 + v1_base * s) for s in speeds]
    ax.plot(speeds, result, linewidth=2, label=f'$v_1 = {v1_base}c$')

ax.plot(speeds, speeds, 'k:', linewidth=1, alpha=0.5, label='Galilean ($v_1+v_2$)')
ax.axhline(y=1, color='red', linestyle='--', linewidth=1, alpha=0.7, label='Speed of light')

ax.set_xlabel('$v_2 / c$', fontsize=12)
ax.set_ylabel('$v_1 \\oplus v_2$ / c', fontsize=12)
ax.set_title('Velocity Addition Saturation\n(speed of light as absolute limit)', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.05)

plt.tight_layout()
plt.savefig('velocity_addition.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: velocity_addition.png")


"""
Visualization 2: Hyperbolic Zeta Function and Euclidean Comparison
===================================================================
Plots the truncated hyperbolic zeta function ζ_H(s) = Σ d^{-2s}
alongside the classical Riemann zeta for comparison, illustrating
how curved-space number theory modifies the analytic structure.
"""
import numpy as np
import matplotlib.pyplot as plt
from collections import deque


def moebius_apply(a, b, c, d, z):
    return (a * z + b) / (c * z + d)


def enumerate_orbit_distances(generators, basepoint=0, max_depth=6, tol=1e-6):
    """Enumerate orbit and return hyperbolic distances."""
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append((g[3], -g[1], -g[2], g[0]))

    distances = []
    seen = {(round(basepoint.real/tol), round(basepoint.imag/tol))}
    queue = deque([(basepoint, 0)])

    while queue:
        pt, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for g in all_gens:
            new_pt = moebius_apply(*g, pt)
            if abs(new_pt) >= 1 - 1e-10:
                continue
            key = (round(new_pt.real/tol), round(new_pt.imag/tol))
            if key not in seen:
                seen.add(key)
                d = abs(new_pt - basepoint)**2 / ((1-abs(new_pt)**2)*(1-abs(basepoint)**2))
                dist = 2 * np.arcsinh(np.sqrt(max(d, 0)))
                if dist > 0.01:
                    distances.append(dist)
                queue.append((new_pt, depth + 1))
    return sorted(distances)


def trunc_hyp_zeta(distances, s):
    return sum(d**(-2*s) for d in distances if d > 0)


def gauss_circle_count(n):
    count = 0
    for a in range(-int(np.sqrt(n))-1, int(np.sqrt(n))+2):
        if a*a > n:
            continue
        b_max = int(np.sqrt(n - a*a))
        count += 2*b_max + 1
    return count


# Generate data
g1 = (1, -0.3, -0.3, 1)
g2 = (1, -0.3j, 0.3j, 1)
distances = enumerate_orbit_distances([g1, g2], max_depth=7)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: ζ_H(s) vs s
ax = axes[0, 0]
s_vals = np.linspace(0.6, 4.0, 100)
zeta_vals = [trunc_hyp_zeta(distances, s) for s in s_vals]
ax.plot(s_vals, zeta_vals, 'b-', linewidth=2, label='$\\zeta_H(s)$ (hyperbolic)')

# Classical Riemann zeta (truncated)
riemann_vals = [sum(n**(-2*s) for n in range(1, 200)) for s in s_vals]
ax.plot(s_vals, riemann_vals, 'r--', linewidth=2, label='$\\zeta(2s)$ (Riemann, truncated)')

ax.set_xlabel('s', fontsize=12)
ax.set_ylabel('$\\zeta(s)$', fontsize=12)
ax.set_title('Hyperbolic vs Classical Zeta Function', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, max(max(zeta_vals), max(riemann_vals)) * 1.1)

# Top-right: Distance distribution
ax = axes[0, 1]
ax.hist(distances, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
ax.set_xlabel('Hyperbolic distance', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Distribution of {len(distances)} Orbit Distances', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-left: Gauss circle count vs πn
ax = axes[1, 0]
ns = np.arange(1, 101)
gc = [gauss_circle_count(int(n)) for n in ns]
theory = [np.pi * n for n in ns]
ax.plot(ns, gc, 'b-', linewidth=2, label='$G(n)$ (actual count)')
ax.plot(ns, theory, 'r--', linewidth=2, label='$\\pi n$ (asymptotic)')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Gauss Circle Problem: $G(n) \\sim \\pi n$', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-right: Error term in Gauss circle problem
ax = axes[1, 1]
errors = [(gc[i] - np.pi * (i+1)) / np.sqrt(i+1) for i in range(len(gc))]
ax.plot(ns, errors, 'g-', linewidth=1.5, alpha=0.8)
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('$(G(n) - \\pi n) / \\sqrt{n}$', fontsize=12)
ax.set_title('Gauss Circle Error (normalized)', fontsize=13)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zeta_function_comparison.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: zeta_function_comparison.png")
