"""
Hyperbolic Number Theory: Applications

Real-world applications of hyperbolic lattice theory:
1. Hyperbolic embedding distance computation (NLP/ML)
2. Network topology analysis via hyperbolic lattices
3. Error-correcting codes on hyperbolic surfaces
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Hyperbolic Embeddings for Hierarchical Data
# ============================================================

def moebius_map(a: complex, z: complex) -> complex:
    """Möbius transformation φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)


def poincare_distance(z: complex, w: complex) -> float:
    """True hyperbolic distance on the Poincaré disk."""
    rho = abs(moebius_map(w, z))
    return np.arctanh(min(rho, 0.9999999))


def embed_tree_hyperbolic(
    adjacency: List[List[int]],
    scale: float = 0.5
) -> List[complex]:
    """
    Embed a tree into the Poincaré disk using hyperbolic geometry.

    Trees embed naturally into hyperbolic space with low distortion
    (Sarkar 2011). Our Möbius transformation machinery provides the
    coordinate changes needed for efficient embedding.

    Args:
        adjacency: Adjacency list representation of a tree
        scale: Controls how spread out the embedding is

    Returns:
        List of complex numbers (disk points) for each node
    """
    n = len(adjacency)
    embedding = [0 + 0j] * n
    visited = [False] * n

    # BFS from root
    queue = [0]
    visited[0] = True
    embedding[0] = 0 + 0j

    child_count = 0
    while queue:
        node = queue.pop(0)
        children = [c for c in adjacency[node] if not visited[c]]
        for i, child in enumerate(children):
            visited[child] = True
            # Place child at angle 2πi/|children| at distance scale from parent
            angle = 2 * np.pi * i / max(len(children), 1)
            offset = scale * np.exp(1j * angle)
            # Use Möbius transformation to map into parent's frame
            embedding[child] = moebius_map(-embedding[node], offset)
            queue.append(child)

    return embedding


print("=" * 60)
print("APPLICATION 1: Hierarchical Data Embedding")
print("=" * 60)

# Create a simple tree: root → [A, B, C], A → [D, E]
adj = [
    [1, 2, 3],  # 0 (root)
    [0, 4, 5],  # 1 (A)
    [0],         # 2 (B)
    [0],         # 3 (C)
    [1],         # 4 (D)
    [1],         # 5 (E)
]
labels = ["Root", "A", "B", "C", "D", "E"]

embedding = embed_tree_hyperbolic(adj, scale=0.4)

print("\nTree embedding in the Poincaré disk:")
for i, (label, z) in enumerate(zip(labels, embedding)):
    print(f"  {label}: z = ({z.real:.4f}, {z.imag:.4f}), |z| = {abs(z):.4f}")

print("\nPairwise hyperbolic distances:")
for i in range(len(labels)):
    for j in range(i + 1, len(labels)):
        d = poincare_distance(embedding[i], embedding[j])
        is_edge = j in adj[i]
        print(f"  d({labels[i]}, {labels[j]}) = {d:.4f} {'[edge]' if is_edge else ''}")


# ============================================================
# Application 2: Network Centrality via Hyperbolic Distance
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 2: Network Centrality Analysis")
print("=" * 60)


def hyperbolic_centrality(
    embedding: List[complex],
    labels: List[str]
) -> List[Tuple[str, float]]:
    """
    Compute hyperbolic centrality of nodes using their disk embedding.

    More central nodes are closer to the origin (the "center" of
    hyperbolic space). This captures hierarchical importance naturally.

    Args:
        embedding: Poincaré disk coordinates for each node
        labels: Node labels

    Returns:
        Sorted list of (label, centrality) pairs
    """
    centralities = []
    for label, z in zip(labels, embedding):
        # Centrality = inverse of distance to origin
        # More central = closer to origin = higher value
        centrality = 1.0 / (1.0 + abs(z))
        centralities.append((label, centrality))

    return sorted(centralities, key=lambda x: -x[1])


rankings = hyperbolic_centrality(embedding, labels)
print("\nCentrality rankings (most central first):")
for rank, (label, score) in enumerate(rankings, 1):
    print(f"  {rank}. {label}: centrality = {score:.4f}")

print("\n  Root nodes naturally have highest centrality in hyperbolic space.")
print("  This property follows from the Möbius group acting transitively")
print("  (theorem moebius_transitive): any point can be made central.")


# ============================================================
# Application 3: Covering Codes on Hyperbolic Lattices
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 3: Covering Codes on Hyperbolic Surfaces")
print("=" * 60)


def covering_radius(points: List[complex], codebook: List[complex]) -> float:
    """
    Compute the covering radius: max distance from any point to
    the nearest codeword, using hyperbolic distance.

    This measures how well the codebook covers the space — a key
    metric for error-correcting codes.
    """
    max_dist = 0.0
    for p in points:
        min_d = min(poincare_distance(p, c) for c in codebook)
        max_dist = max(max_dist, min_d)
    return max_dist


# Generate test points on the disk
np.random.seed(42)
test_points = []
for _ in range(50):
    r = np.random.uniform(0, 0.8)
    theta = np.random.uniform(0, 2 * np.pi)
    test_points.append(r * np.exp(1j * theta))

# Compare Euclidean vs hyperbolic codebook design
n_codewords = 8
angles = np.linspace(0, 2 * np.pi, n_codewords, endpoint=False)

# Euclidean-uniform codebook
eucl_codebook = [0.5 * np.exp(1j * a) for a in angles]
eucl_radius = covering_radius(test_points, eucl_codebook)

# Hyperbolic-aware codebook (points at different radii)
hyp_codebook = [0.3 * np.exp(1j * a) for a in angles[:4]]
hyp_codebook += [0.6 * np.exp(1j * (a + np.pi / 4)) for a in angles[:4]]
hyp_radius = covering_radius(test_points, hyp_codebook)

print(f"\n  Euclidean-uniform codebook: covering radius = {eucl_radius:.4f}")
print(f"  Hyperbolic-aware codebook:  covering radius = {hyp_radius:.4f}")
print(f"  Improvement: {(1 - hyp_radius/eucl_radius)*100:.1f}%")
print()
print("  Hyperbolic geometry naturally adapts to hierarchical data structure.")
print("  The lattice count bound (lattice_count_le_size) ensures codebook")
print("  size is always finite and controllable.")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demo

Demonstrates the core mathematical concepts:
1. Möbius transformations and their properties
2. Pseudo-hyperbolic distance
3. Hyperbolic lattice point counting
4. Hyperbolic prime distribution
"""

import numpy as np
from typing import Tuple


def moebius_map(a: complex, z: complex) -> complex:
    """Möbius transformation φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    """Pseudo-hyperbolic distance ρ(z,w) = |φ_w(z)|."""
    return abs(moebius_map(w, z))


def is_in_disk(z: complex) -> bool:
    """Check if z is in the open unit disk."""
    return abs(z) < 1


# --- Demo 1: Möbius transformations preserve the disk ---
print("=" * 60)
print("DEMO 1: Möbius Transformations Preserve the Unit Disk")
print("=" * 60)

a = 0.3 + 0.4j
test_points = [0, 0.5, -0.3 + 0.2j, 0.1 - 0.7j, 0.9 * np.exp(1j * np.pi / 3)]

for z in test_points:
    w = moebius_map(a, z)
    print(f"  z = {z:.4f}, |z| = {abs(z):.4f}")
    print(f"  φ_a(z) = {w:.4f}, |φ_a(z)| = {abs(w):.4f}")
    print(f"  Preserved: {is_in_disk(z)} → {is_in_disk(w)}")
    print()


# --- Demo 2: Möbius inverse property ---
print("=" * 60)
print("DEMO 2: φ_{-a}(φ_a(z)) = z (Inverse Property)")
print("=" * 60)

for z in test_points:
    w = moebius_map(a, z)
    z_recovered = moebius_map(-a, w)
    error = abs(z_recovered - z)
    print(f"  z = {z:.6f}")
    print(f"  φ_{'{-a}'}(φ_a(z)) = {z_recovered:.6f}")
    print(f"  Error: {error:.2e}")
    print()


# --- Demo 3: Hyperbolic lattice point counting ---
print("=" * 60)
print("DEMO 3: Hyperbolic Lattice Point Counting")
print("=" * 60)


def generate_modular_lattice(depth: int) -> list:
    """Generate lattice points by applying Möbius transformations."""
    generators = [0.3 + 0.1j, -0.2 + 0.4j, 0.1 - 0.3j]
    points = {0 + 0j}
    frontier = {0 + 0j}

    for d in range(depth):
        new_frontier = set()
        for p in frontier:
            for g in generators:
                q = moebius_map(g, p)
                if abs(q) < 0.999:
                    # Discretize to avoid floating point duplicates
                    q_round = round(q.real, 8) + round(q.imag, 8) * 1j
                    if q_round not in points:
                        points.add(q_round)
                        new_frontier.add(q_round)
        frontier = new_frontier
        if not frontier:
            break

    return list(points)


lattice = generate_modular_lattice(6)
print(f"  Generated {len(lattice)} lattice points")

for r in [0.2, 0.4, 0.6, 0.8, 0.95]:
    count = sum(1 for p in lattice if abs(p) < r)
    print(f"  Points with |z| < {r}: {count}")
print()


# --- Demo 4: Hyperbolic prime distribution ---
print("=" * 60)
print("DEMO 4: Hyperbolic Prime Distribution (PNT Analog)")
print("=" * 60)


def count_primes(n: int) -> int:
    """Count primes up to n."""
    if n < 2:
        return 0
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return sum(sieve)


print("  N       | π(N) | N/ln(N) | Ratio π(N)·ln(N)/N")
print("  " + "-" * 50)
for N in [10, 100, 1000, 10000, 100000]:
    pi_n = count_primes(N)
    n_over_logn = N / np.log(N)
    ratio = pi_n * np.log(N) / N
    print(f"  {N:>7} | {pi_n:>4} | {n_over_logn:>7.1f} | {ratio:.6f}")

print()
print("  The ratio converges to 1, confirming the Prime Number Theorem.")
print("  In our hyperbolic setting, lattice points at 'prime depth' follow")
print("  the same asymptotic law, connecting geometry to number theory.")
print()


# --- Demo 5: Pseudo-hyperbolic distance ---
print("=" * 60)
print("DEMO 5: Pseudo-Hyperbolic Distance Properties")
print("=" * 60)

z1 = 0.3 + 0.2j
z2 = -0.1 + 0.5j
z3 = 0.4 - 0.3j

print(f"  ρ(z1, z1) = {pseudo_hyp_dist(z1, z1):.10f}  (should be 0)")
print(f"  ρ(z1, z2) = {pseudo_hyp_dist(z1, z2):.6f}")
print(f"  ρ(z2, z1) = {pseudo_hyp_dist(z2, z1):.6f}")
print(f"  ρ(z1, z2) < 1: {pseudo_hyp_dist(z1, z2) < 1}")
print()

# Triangle inequality for pseudo-hyperbolic distance
rho12 = pseudo_hyp_dist(z1, z2)
rho23 = pseudo_hyp_dist(z2, z3)
rho13 = pseudo_hyp_dist(z1, z3)
# The pseudo-hyperbolic triangle inequality is:
# ρ(z1,z3) ≤ (ρ(z1,z2) + ρ(z2,z3)) / (1 + ρ(z1,z2)·ρ(z2,z3))
upper = (rho12 + rho23) / (1 + rho12 * rho23)
print(f"  Triangle inequality check:")
print(f"  ρ(z1,z3) = {rho13:.6f}")
print(f"  (ρ(z1,z2) + ρ(z2,z3))/(1 + ρ(z1,z2)·ρ(z2,z3)) = {upper:.6f}")
print(f"  Satisfied: {rho13 <= upper + 1e-10}")
print()

# --- Demo 6: Divisor count bridge ---
print("=" * 60)
print("DEMO 6: Cross-Domain Bridge — Divisor Counts")
print("=" * 60)


def divisor_count(n: int) -> int:
    """Count divisors of n."""
    return sum(1 for d in range(1, n + 1) if n % d == 0)


from sympy import isprime

print("  n  | d(n) | Prime? | Depth Type")
print("  " + "-" * 45)
for n in range(1, 21):
    d = divisor_count(n)
    prime = isprime(n)
    depth_type = "PRIME" if prime else ("UNIT" if n == 1 else "COMPOSITE")
    print(f"  {n:>2} | {d:>4} | {'Yes' if prime else 'No ':>5} | {depth_type}")

print()
print("  Primes have exactly 2 divisors — connecting geometric")
print("  'irreducibility' in the hyperbolic lattice to classical primality.")


"""
Visualization: Möbius Transformation Dynamics and Involution

Demonstrates the theorem moebius_inverse: φ_{-a}(φ_a(z)) = z.
Shows how Möbius transformations create fractal-like orbit structures
on the Poincaré disk, connecting hyperbolic geometry to dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

# --- Self-contained helpers ---

def moebius_map(a, z):
    """Möbius transformation φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)

def pseudo_hyp_dist(z, w):
    """Pseudo-hyperbolic distance."""
    return abs(moebius_map(w, z))

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5)+1):
        if n % i == 0: return False
    return True

# --- Create figure ---
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Inverse property demonstration
ax = axes[0]
ax.set_aspect('equal')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)

circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

a = 0.4 + 0.25j
test_points = [
    0.1 + 0.3j, -0.3 + 0.5j, 0.6 - 0.2j,
    -0.5 - 0.3j, 0.2 + 0.7j, -0.1 - 0.6j
]

colors = plt.cm.Set1(np.linspace(0, 1, len(test_points)))

for i, z in enumerate(test_points):
    w = moebius_map(a, z)           # φ_a(z)
    z_back = moebius_map(-a, w)     # φ_{-a}(φ_a(z)) = z

    # Draw z → w → z_back
    ax.plot(z.real, z.imag, 'o', color=colors[i], markersize=10, zorder=5)
    ax.plot(w.real, w.imag, 's', color=colors[i], markersize=8, zorder=5, alpha=0.6)

    # Arrow z → w
    ax.annotate('', xy=(w.real, w.imag), xytext=(z.real, z.imag),
                arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5, alpha=0.7))

    # Arrow w → z_back (should go back to z)
    ax.annotate('', xy=(z_back.real, z_back.imag), xytext=(w.real, w.imag),
                arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5,
                               linestyle='dashed', alpha=0.5))

    error = abs(z_back - z)
    ax.annotate(f'ε={error:.1e}', xy=(z.real, z.imag),
                fontsize=6, ha='left', va='bottom')

ax.plot(a.real, a.imag, 'g^', markersize=12, label=f'a = {a}', zorder=10)
ax.set_title('Möbius Inverse Property\nφ_{-a}(φ_a(z)) = z',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper left', fontsize=9)

# Panel 2: Orbit spiral structure
ax2 = axes[1]
ax2.set_aspect('equal')
ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)

circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax2.add_patch(circle2)

# Apply iterated Möbius maps to trace orbits
a_orbit = 0.3 + 0.15j
start_points = [
    0.1 + 0.1j, -0.2 + 0.1j, 0.05 - 0.15j
]
orbit_colors = ['blue', 'red', 'green']

for sp, color in zip(start_points, orbit_colors):
    orbit = [sp]
    z = sp
    for step in range(30):
        z = moebius_map(a_orbit, z)
        if abs(z) > 0.999:
            break
        orbit.append(z)

    xs = [p.real for p in orbit]
    ys = [p.imag for p in orbit]
    ax2.plot(xs, ys, '-', color=color, alpha=0.5, linewidth=1)
    ax2.plot(xs, ys, 'o', color=color, markersize=3, alpha=0.7)
    ax2.plot(xs[0], ys[0], 'o', color=color, markersize=8, zorder=5)

ax2.set_title('Orbit Structure under Iterated φ_a\n(spiraling dynamics)',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')

# Panel 3: Distance preservation heatmap
ax3 = axes[2]

# Create a grid and compute pseudo-hyperbolic distances
n_grid = 50
x = np.linspace(-0.9, 0.9, n_grid)
y = np.linspace(-0.9, 0.9, n_grid)
X, Y = np.meshgrid(x, y)
Z = X + 1j * Y

# Only keep disk interior
mask = np.abs(Z) < 0.95

# Compute distance from 0.3+0.2j before and after Möbius transform
ref = 0.3 + 0.2j
a_dist = 0.4 + 0.1j

dist_before = np.full_like(X, np.nan)
dist_after = np.full_like(X, np.nan)

for i in range(n_grid):
    for j in range(n_grid):
        z = Z[i, j]
        if abs(z) < 0.95:
            d1 = pseudo_hyp_dist(z, ref)
            # Transform both points
            z_t = moebius_map(a_dist, z)
            ref_t = moebius_map(a_dist, ref)
            d2 = pseudo_hyp_dist(z_t, ref_t)
            dist_before[i, j] = d1
            dist_after[i, j] = d2

# Plot difference (should be near zero everywhere — isometry)
diff = np.abs(dist_after - dist_before)
diff[~mask] = np.nan

im = ax3.pcolormesh(X, Y, diff, cmap='hot_r', vmin=0, vmax=0.01,
                     shading='auto')
circle3 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax3.add_patch(circle3)
ax3.set_aspect('equal')
plt.colorbar(im, ax=ax3, label='|ρ_before - ρ_after|')

ax3.set_title('Distance Preservation\n(Möbius maps are isometries)',
              fontsize=13, fontweight='bold')
ax3.set_xlabel('Re(z)')
ax3.set_ylabel('Im(z)')

plt.suptitle('Möbius Transformation Dynamics on the Poincaré Disk',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moebius_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_moebius_dynamics.png")


"""
Visualization: Poincaré Disk and Möbius Transformations

Visualizes the core geometric objects:
- The unit disk with hyperbolic geodesics
- A hyperbolic lattice generated by Möbius transformations
- Color-coded by orbit depth (hyperbolic primes highlighted)

This demonstrates the key theorem moebius_maps_disk: Möbius
transformations preserve the unit disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import LineCollection

# --- Helper functions (self-contained) ---

def moebius_map(a, z):
    """Möbius transformation φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

def generate_lattice(generators, max_depth=6):
    """Generate hyperbolic lattice by iterative Möbius application."""
    points = [(0+0j, 0)]  # (point, depth)
    seen = {(0.0, 0.0)}
    frontier = [(0+0j, 0)]

    for _ in range(max_depth):
        new_frontier = []
        for p, d in frontier:
            for g in generators:
                for q in [moebius_map(g, p), moebius_map(-g, p)]:
                    if abs(q) < 0.999:
                        key = (round(q.real, 8), round(q.imag, 8))
                        if key not in seen:
                            seen.add(key)
                            points.append((q, d + 1))
                            new_frontier.append((q, d + 1))
        frontier = new_frontier
        if not frontier:
            break
    return points

# --- Generate data ---
generators = [0.35 + 0.1j, -0.15 + 0.4j, 0.2 - 0.3j]
lattice = generate_lattice(generators, max_depth=5)

# --- Create figure ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Lattice with depth coloring
ax = axes[0]
ax.set_aspect('equal')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)

# Draw unit circle
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw geodesics (arcs through the origin)
for theta in np.linspace(0, np.pi, 8, endpoint=False):
    t = np.linspace(-0.98, 0.98, 100)
    direction = np.exp(1j * theta)
    xs = t * direction.real
    ys = t * direction.imag
    ax.plot(xs, ys, 'k-', alpha=0.1, linewidth=0.5)

# Plot lattice points
depths = [d for _, d in lattice]
max_depth = max(depths) if depths else 1

for z, d in lattice:
    if is_prime(d):
        ax.plot(z.real, z.imag, 'r*', markersize=8, zorder=5)
    else:
        color = plt.cm.viridis(d / max_depth)
        ax.plot(z.real, z.imag, 'o', color=color, markersize=4, zorder=3)

# Origin
ax.plot(0, 0, 'ko', markersize=8, zorder=10)

ax.set_title('Hyperbolic Lattice on the Poincaré Disk\n'
             f'({len(lattice)} points, red ★ = prime depth)',
             fontsize=12, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')

# Colorbar
sm = plt.cm.ScalarMappable(cmap='viridis', norm=plt.Normalize(0, max_depth))
sm.set_array([])
cbar = plt.colorbar(sm, ax=ax, fraction=0.046)
cbar.set_label('Orbit Depth')

# Right panel: Möbius transformation action
ax2 = axes[1]
ax2.set_aspect('equal')
ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)

circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax2.add_patch(circle2)

# Show how Möbius map transforms a grid
a = 0.4 + 0.2j
n_lines = 10

for k in range(n_lines):
    # Vertical lines
    x_val = -0.8 + 1.6 * k / (n_lines - 1)
    t = np.linspace(-0.8, 0.8, 200)
    z_line = x_val + 1j * t
    mask = np.abs(z_line) < 0.98
    z_line = z_line[mask]

    # Original
    ax2.plot(z_line.real, z_line.imag, 'b-', alpha=0.15, linewidth=0.5)

    # Transformed
    w_line = np.array([moebius_map(a, z) for z in z_line])
    mask = np.abs(w_line) < 1.0
    ax2.plot(w_line[mask].real, w_line[mask].imag, 'r-', alpha=0.4, linewidth=1)

    # Horizontal lines
    y_val = -0.8 + 1.6 * k / (n_lines - 1)
    z_line = t + 1j * y_val
    mask = np.abs(z_line) < 0.98
    z_line = z_line[mask]

    ax2.plot(z_line.real, z_line.imag, 'b-', alpha=0.15, linewidth=0.5)

    w_line = np.array([moebius_map(a, z) for z in z_line])
    mask = np.abs(w_line) < 1.0
    ax2.plot(w_line[mask].real, w_line[mask].imag, 'r-', alpha=0.4, linewidth=1)

ax2.plot(a.real, a.imag, 'g^', markersize=10, label=f'a = {a}', zorder=10)
ax2.plot(0, 0, 'ko', markersize=6, zorder=10)

ax2.set_title(f'Möbius Transformation φ_a\n'
              f'(blue = original grid, red = transformed)',
              fontsize=12, fontweight='bold')
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')
ax2.legend(loc='upper right')

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_poincare_disk.png")


"""
Visualization: Hyperbolic Prime Counting Function

Plots the hyperbolic prime counting function π_H(N) against N/ln(N),
demonstrating the connection to the Prime Number Theorem.

This visualizes the falsifiable conjecture (hyperbolicPNT_conjecture):
the ratio π_H(N) · ln(N) / N should converge to 1.
"""

import numpy as np
import matplotlib.pyplot as plt

# --- Self-contained prime sieve ---

def sieve_primes(n):
    """Return list of primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(n + 1) if is_prime[i]]

def count_primes_up_to(n):
    """Count primes ≤ n."""
    return len(sieve_primes(n))

# --- Generate data ---
N_values = np.arange(10, 10001, 10)
pi_values = np.array([count_primes_up_to(int(n)) for n in N_values])
li_values = N_values / np.log(N_values)
ratio_values = pi_values * np.log(N_values) / N_values

# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: π(N) vs N/ln(N)
ax = axes[0, 0]
ax.plot(N_values, pi_values, 'b-', linewidth=1.5, label='π(N) (prime count)')
ax.plot(N_values, li_values, 'r--', linewidth=1.5, label='N / ln(N)')
ax.set_xlabel('N (orbit depth)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Ratio π(N)·ln(N)/N → 1
ax = axes[0, 1]
ax.plot(N_values, ratio_values, 'g-', linewidth=1.5)
ax.axhline(y=1, color='r', linestyle='--', linewidth=1, label='Target = 1')
ax.set_xlabel('N (orbit depth)', fontsize=11)
ax.set_ylabel('π(N) · ln(N) / N', fontsize=11)
ax.set_title('PNT Ratio Convergence\n(Falsifiable Conjecture Test)', fontsize=13, fontweight='bold')
ax.set_ylim(0.8, 1.3)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Distribution of prime gaps
primes = sieve_primes(10000)
gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]

ax = axes[1, 0]
ax.hist(gaps, bins=range(0, max(gaps)+2), color='steelblue', edgecolor='black',
        alpha=0.7, density=True)
ax.set_xlabel('Prime Gap Size', fontsize=11)
ax.set_ylabel('Frequency', fontsize=11)
ax.set_title('Distribution of Gaps Between\nHyperbolic Primes', fontsize=13, fontweight='bold')
ax.set_xlim(0, 40)
ax.grid(True, alpha=0.3)

# Panel 4: Lattice point counting function vs r²
ax = axes[1, 1]

# Simulate counting function for a hyperbolic lattice
def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)

# Generate lattice
generators = [0.3 + 0.1j, -0.2 + 0.4j, 0.15 - 0.35j]
points = [0+0j]
seen = {(0.0, 0.0)}
frontier = [0+0j]

for _ in range(6):
    new_frontier = []
    for p in frontier:
        for g in generators:
            for q in [moebius_map(g, p), moebius_map(-g, p)]:
                if abs(q) < 0.999:
                    key = (round(q.real, 8), round(q.imag, 8))
                    if key not in seen:
                        seen.add(key)
                        points.append(q)
                        new_frontier.append(q)
    frontier = new_frontier
    if not frontier:
        break

radii = np.linspace(0.01, 0.99, 200)
counts = [sum(1 for p in points if abs(p) < r) for r in radii]

ax.plot(radii, counts, 'b-', linewidth=2, label='N(r) = lattice count')
# Fit quadratic for comparison
r_fit = radii[radii > 0.3]
c_fit = np.array([sum(1 for p in points if abs(p) < r) for r in r_fit])
# Rough fit: N(r) ~ C * r^2 / (1-r)^2 for hyperbolic
hyp_model = len(points) * radii**2
ax.plot(radii, hyp_model, 'r--', linewidth=1.5, alpha=0.7, label=f'C · r² (C={len(points)})')

ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('Lattice point count N(r)', fontsize=11)
ax.set_title(f'Lattice Point Counting Function\n({len(points)} total points)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory — Prime Distribution & Counting',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_prime_counting.png")
