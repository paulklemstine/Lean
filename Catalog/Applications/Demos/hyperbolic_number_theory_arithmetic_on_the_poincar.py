"""
Applications of Hyperbolic Number Theory
==========================================

Real-world applications connecting hyperbolic arithmetic to:
1. Special relativity (velocity addition)
2. Signal processing (hyperbolic tangent compression)
3. Network science (tree-like network analysis)
4. Cryptography (Möbius transformations as ciphers)
"""

import math
from typing import List, Tuple


# ============================================================
# Application 1: Special Relativity
# ============================================================

def relativistic_velocity_add(v1: float, v2: float, c: float = 1.0) -> float:
    """Add two velocities using special relativity.

    The formula v = (v1 + v2) / (1 + v1*v2/c²) is exactly
    hyperbolic addition when we normalize by c.

    This is the SAME as our formally verified hypAdd function,
    with the speed of light as the unit.

    Args:
        v1: First velocity (|v1| < c)
        v2: Second velocity (|v2| < c)
        c: Speed of light (default: 1, natural units)

    Returns:
        Combined velocity according to special relativity
    """
    return (v1 + v2) / (1 + v1 * v2 / c**2)


def demonstrate_relativity():
    """Show how hyperbolic addition governs relativistic velocities."""
    c = 299792458  # m/s

    print("=== Special Relativity: Velocity Addition ===")
    print(f"Speed of light: c = {c:,} m/s\n")

    # Two spaceships approaching each other
    v1 = 0.8 * c  # 80% of light speed
    v2 = 0.8 * c

    classical = v1 + v2
    relativistic = relativistic_velocity_add(v1, v2, c)

    print(f"Spaceship 1 velocity: {v1/c:.1f}c = {v1:,.0f} m/s")
    print(f"Spaceship 2 velocity: {v2/c:.1f}c = {v2:,.0f} m/s")
    print(f"Classical (wrong):    {classical/c:.1f}c = {classical:,.0f} m/s {'(> c!)' if classical > c else ''}")
    print(f"Relativistic (right): {relativistic/c:.6f}c = {relativistic:,.0f} m/s")
    print(f"  → Always < c, as proven in hypAdd_lt_one!\n")

    # Iterated boosts
    print("Iterated velocity boosts (v = 0.5c each time):")
    v = 0.5 * c
    current = 0.0
    for n in range(1, 11):
        current = relativistic_velocity_add(current, v, c)
        print(f"  After {n:2d} boosts: {current/c:.10f}c "
              f"(gap from c: {(c - current)/c:.2e})")
    print("  → Approaches c but never reaches it (hypAdd_iter_lt_one)!\n")


# ============================================================
# Application 2: Signal Compression
# ============================================================

def tanh_compress(x: float) -> float:
    """Compress a real value to (-1, 1) using tanh."""
    return math.tanh(x)


def tanh_compose(a: float, b: float) -> float:
    """Compose two tanh-compressed signals.

    If a = tanh(x) and b = tanh(y), then
    hypAdd(a, b) = tanh(x + y).

    This means hyperbolic addition corresponds to
    addition in the uncompressed domain!
    """
    return (a + b) / (1 + a * b)


def demonstrate_signal_processing():
    """Show the signal compression application."""
    print("=== Signal Processing: Hyperbolic Compression ===\n")

    signals = [1.5, 2.3, -0.7, 3.1]
    print(f"Original signals: {signals}")
    print(f"True sum: {sum(signals):.4f}")
    print(f"tanh(true sum): {math.tanh(sum(signals)):.10f}\n")

    # Compress each signal
    compressed = [tanh_compress(s) for s in signals]
    print(f"Compressed (tanh): {[f'{c:.6f}' for c in compressed]}")

    # Add using hyperbolic addition
    result = 0.0
    for c in compressed:
        result = tanh_compose(result, c)
    print(f"hypAdd chain:      {result:.10f}")
    print(f"tanh(sum):         {math.tanh(sum(signals)):.10f}")
    print(f"Match: {abs(result - math.tanh(sum(signals))) < 1e-10}")
    print("  → Hyperbolic addition lets us ADD in compressed space!\n")


# ============================================================
# Application 3: Network Science
# ============================================================

def analyze_tree_network(branching_factor: int, depth: int):
    """Analyze a tree-like network using our counting formulas."""
    print(f"=== Network Analysis: {branching_factor}-ary Tree, Depth {depth} ===\n")

    total_nodes = 0
    for d in range(depth + 1):
        if d == 0:
            count = 1
        else:
            count = branching_factor * (branching_factor - 1) ** (d - 1)
        total_nodes += count
        print(f"  Level {d:2d}: {count:8d} nodes (cumulative: {total_nodes:8d})")

    if branching_factor == 2:
        formula = 2 * depth + 1
        print(f"\n  Binary tree formula (proven): 2n+1 = {formula}")
        print(f"  Actual total: {total_nodes}")
        print(f"  Match: {total_nodes == formula}")

    # Exponential bound
    exp_bound = sum(branching_factor ** d for d in range(depth + 1))
    print(f"\n  Exponential bound (proven): Σ k^d = {exp_bound}")
    print(f"  Actual total: {total_nodes}")
    print(f"  Bound holds: {total_nodes <= exp_bound}")

    # Growth rate
    if depth > 0:
        growth = total_nodes / (1 + sum(
            branching_factor * (branching_factor - 1) ** (d - 1)
            for d in range(1, depth)
        )) if depth > 1 else total_nodes
        print(f"  Growth factor ≈ {growth:.4f}")
    print()


# ============================================================
# Application 4: Hyperbolic Embeddings (ML/NLP)
# ============================================================

def hyperbolic_midpoint(z: complex, w: complex) -> complex:
    """Compute the hyperbolic midpoint of two Poincaré disk points.

    Uses Möbius operations to find the point equidistant from z and w.
    This is used in hyperbolic neural networks for averaging embeddings.
    """
    # Transform so w -> 0
    m = (z - w) / (1 - w.conjugate() * z)
    # Take midpoint in transformed coords (halfway along geodesic)
    mid_m = m / (1 + (1 - abs(m)**2)**0.5)
    # Transform back
    result = (mid_m + w) / (1 + w.conjugate() * mid_m)
    return result


def demonstrate_embeddings():
    """Show hyperbolic space for hierarchical data embeddings."""
    print("=== Hyperbolic Embeddings for Hierarchical Data ===\n")

    # Simulate a taxonomy: root → animals/plants → subtypes
    root = 0j
    animals = 0.3 + 0j
    plants = -0.3 + 0j
    mammals = 0.5 + 0.2j
    birds = 0.5 - 0.2j
    trees = -0.5 + 0.1j

    entities = {
        "root": root, "animals": animals, "plants": plants,
        "mammals": mammals, "birds": birds, "trees": trees
    }

    print("  Entity positions in Poincaré disk:")
    for name, z in entities.items():
        r = abs(z)
        hn = math.log((1 + r) / (1 - r)) if r > 0 else 0
        print(f"    {name:10s}: z = ({z.real:+.3f}, {z.imag:+.3f}), "
              f"|z| = {r:.3f}, hyp_norm = {hn:.3f}")

    print("\n  Distances (closer in hierarchy → closer in hyperbolic space):")
    pairs = [
        ("root", "animals"), ("root", "plants"),
        ("animals", "mammals"), ("animals", "birds"),
        ("mammals", "birds"), ("animals", "plants")
    ]
    for n1, n2 in pairs:
        z1, z2 = entities[n1], entities[n2]
        m = abs((z1 - z2) / (1 - z2.conjugate() * z1))
        d = math.log((1 + m) / (1 - m))
        print(f"    d({n1:10s}, {n2:10s}) = {d:.4f}")

    print("\n  → Hierarchically related entities are closer!")
    print("  → The exponential growth of hyperbolic space matches tree structure.\n")


# ============================================================
# Run all applications
# ============================================================

if __name__ == "__main__":
    demonstrate_relativity()
    demonstrate_signal_processing()
    analyze_tree_network(2, 10)
    analyze_tree_network(3, 6)
    demonstrate_embeddings()


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================

Demonstrates the key mathematical concepts from the formal proofs:
1. Hyperbolic addition (relativistic velocity addition)
2. Iterated hyperbolic addition and its convergence
3. Lattice orbit counting on regular trees
4. The hyperbolic-arithmetic bridge

Each demo prints concrete numerical examples that illustrate the theorems.
"""

import math


def hyp_add(a: float, b: float) -> float:
    """Hyperbolic addition: (a + b) / (1 + a*b).
    This is the relativistic velocity addition formula."""
    return (a + b) / (1 + a * b)


def hyp_add_iter(a: float, n: int) -> float:
    """Iterate hyperbolic addition n times starting from 0."""
    result = 0.0
    for _ in range(n):
        result = hyp_add(result, a)
    return result


def tree_count_at_depth(k: int, n: int) -> int:
    """Number of vertices at depth n in a k-regular tree."""
    if n == 0:
        return 1
    return k * (k - 1) ** (n - 1)


def tree_total_count(k: int, n: int) -> int:
    """Total vertices up to depth n in a k-regular tree."""
    return sum(tree_count_at_depth(k, i) for i in range(n + 1))


def moebius_diff(z: complex, w: complex) -> complex:
    """Möbius difference on the Poincaré disk."""
    return (z - w) / (1 - w.conjugate() * z)


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance on the Poincaré disk."""
    m = abs(moebius_diff(z, w))
    if m >= 1:
        return float('inf')
    return math.log((1 + m) / (1 - m))


# ============================================================
# Demo 1: Hyperbolic Addition Properties
# ============================================================
print("=" * 60)
print("Demo 1: Hyperbolic Addition (Relativistic Velocity Addition)")
print("=" * 60)

print("\n--- Commutativity: hypAdd(a, b) = hypAdd(b, a) ---")
a, b = 0.3, 0.7
print(f"  hypAdd({a}, {b}) = {hyp_add(a, b):.10f}")
print(f"  hypAdd({b}, {a}) = {hyp_add(b, a):.10f}")
print(f"  Equal: {abs(hyp_add(a, b) - hyp_add(b, a)) < 1e-15}")

print("\n--- Identity: hypAdd(a, 0) = a ---")
for a in [0.1, 0.5, 0.99]:
    print(f"  hypAdd({a}, 0) = {hyp_add(a, 0):.10f}")

print("\n--- Inverse: hypAdd(a, -a) = 0 ---")
for a in [0.3, -0.7, 0.999]:
    result = hyp_add(a, -a)
    print(f"  hypAdd({a}, {-a}) = {result:.2e}")

print("\n--- Associativity: hypAdd(hypAdd(a,b), c) = hypAdd(a, hypAdd(b,c)) ---")
a, b, c = 0.3, 0.5, 0.7
lhs = hyp_add(hyp_add(a, b), c)
rhs = hyp_add(a, hyp_add(b, c))
print(f"  LHS = {lhs:.10f}")
print(f"  RHS = {rhs:.10f}")
print(f"  Equal: {abs(lhs - rhs) < 1e-15}")

print("\n--- Closure: |hypAdd(a,b)| < 1 when |a|, |b| < 1 ---")
test_vals = [(0.9, 0.9), (-0.8, 0.7), (0.99, 0.99)]
for a, b in test_vals:
    result = hyp_add(a, b)
    print(f"  hypAdd({a}, {b}) = {result:.6f}, |result| = {abs(result):.6f} < 1: {abs(result) < 1}")


# ============================================================
# Demo 2: Iterated Hyperbolic Addition
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Iterated Hyperbolic Addition")
print("=" * 60)

print("\n--- hypAdd_iter(0.5, n) for n = 0..10 ---")
print("  (Approaches 1 but never reaches it)")
a = 0.5
for n in range(11):
    val = hyp_add_iter(a, n)
    print(f"  n={n:2d}: hypAdd_iter(0.5, {n}) = {val:.10f}, "
          f"gap from 1: {1 - val:.2e}")

print("\n--- Strict monotonicity verified ---")
a = 0.3
vals = [hyp_add_iter(a, n) for n in range(10)]
is_increasing = all(vals[i] < vals[i+1] for i in range(9))
print(f"  Sequence with a=0.3: {[f'{v:.4f}' for v in vals]}")
print(f"  Strictly increasing: {is_increasing}")


# ============================================================
# Demo 3: Tree Counting
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Regular Tree Counting")
print("=" * 60)

print("\n--- Binary tree (k=2): total = 2n + 1 ---")
for n in range(1, 8):
    total = tree_total_count(2, n)
    formula = 2 * n + 1
    print(f"  n={n}: total = {total}, 2n+1 = {formula}, match: {total == formula}")

print("\n--- 2-generator free group conjecture: total = 3^n ---")
print("  (conjectured_count: depth n has 2·3^{n-1} points for n≥1)")
for n in range(1, 7):
    conj_total = 1 + sum(2 * 3**(k-1) for k in range(1, n+1))
    formula = 3**n
    print(f"  n={n}: sum = {conj_total}, 3^n = {formula}, match: {conj_total == formula}")

print("\n--- Exponential growth bound: card(depth n) ≤ k^n ---")
for k in [2, 3, 4]:
    print(f"\n  k={k} generators:")
    for n in range(6):
        count = tree_count_at_depth(k, n)
        bound = k ** n
        print(f"    depth {n}: count = {count:5d}, k^n = {bound:5d}, "
              f"bound holds: {count <= bound}")


# ============================================================
# Demo 4: Hyperbolic Distance
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Hyperbolic Distance on the Poincaré Disk")
print("=" * 60)

print("\n--- Distance from origin ---")
for r in [0.0, 0.1, 0.5, 0.9, 0.99, 0.999]:
    z = complex(r, 0)
    d = hyp_dist(z, 0)
    formula = math.log((1 + r) / (1 - r)) if r < 1 else float('inf')
    print(f"  z={r:.3f}: hypDist = {d:.6f}, log formula = {formula:.6f}")

print("\n--- Symmetry: hypDist(z, w) = hypDist(w, z) ---")
z, w = complex(0.3, 0.2), complex(-0.1, 0.4)
d1, d2 = hyp_dist(z, w), hyp_dist(w, z)
print(f"  z={z}, w={w}")
print(f"  hypDist(z,w) = {d1:.10f}")
print(f"  hypDist(w,z) = {d2:.10f}")
print(f"  Equal: {abs(d1 - d2) < 1e-12}")

print("\n--- Self-distance is zero ---")
for z in [complex(0.3, 0.4), complex(-0.5, 0.2), complex(0, 0)]:
    d = hyp_dist(z, z)
    print(f"  hypDist({z}, {z}) = {d:.2e}")


# ============================================================
# Demo 5: Bridge to Number Theory
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Hyperbolic-Arithmetic Bridge")
print("=" * 60)

print("\n--- Multiplicative function partial sum bound ---")
print("  f(n) = 1 if n is squarefree, 0 otherwise (bounded by 1)")


def is_squarefree(n: int) -> bool:
    if n <= 1:
        return True
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


for N in [10, 50, 100, 500]:
    partial_sum = sum(1 for k in range(1, N + 1) if is_squarefree(k))
    print(f"  N={N:3d}: count of squarefree = {partial_sum}, "
          f"bound (N) = {N}, ratio = {partial_sum/N:.4f}")
    # Known: ratio → 6/π² ≈ 0.6079

print(f"\n  (Asymptotic density = 6/π² ≈ {6/math.pi**2:.4f})")

print("\n" + "=" * 60)
print("All demos complete!")
print("=" * 60)


"""
Visualization: Hyperbolic Addition and Its Properties
======================================================

Visualizes the key properties of hyperbolic addition
(a ⊕ b = (a+b)/(1+ab)), which is the relativistic velocity
addition formula.

Shows:
1. The hyperbolic addition surface
2. Comparison with ordinary addition
3. Iterated hypAdd convergence to 1
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def hyp_add(a, b):
    """Hyperbolic addition."""
    return (a + b) / (1 + a * b)


def hyp_add_iter(a, n):
    """Iterated hyperbolic addition."""
    result = 0.0
    for _ in range(n):
        result = hyp_add(result, a)
    return result


fig = plt.figure(figsize=(18, 5.5))

# --- Panel 1: Surface plot of hypAdd ---
ax1 = fig.add_subplot(131, projection='3d')

a_vals = np.linspace(-0.95, 0.95, 80)
b_vals = np.linspace(-0.95, 0.95, 80)
A, B = np.meshgrid(a_vals, b_vals)
Z = (A + B) / (1 + A * B)

# Mask where result is outside (-1, 1) — shouldn't happen but just in case
mask = np.abs(Z) < 1
Z_masked = np.where(mask, Z, np.nan)

surf = ax1.plot_surface(A, B, Z_masked, cmap='coolwarm', alpha=0.85,
                        edgecolor='none', antialiased=True)
ax1.set_xlabel('a', fontsize=11)
ax1.set_ylabel('b', fontsize=11)
ax1.set_zlabel('a ⊕ b', fontsize=11)
ax1.set_title('Hyperbolic Addition\na ⊕ b = (a+b)/(1+ab)', fontsize=12, fontweight='bold')
ax1.view_init(elev=25, azim=-60)

# Add the plane z = 1 for reference
ax1.plot_surface(A, B, np.ones_like(A), alpha=0.1, color='red')
ax1.plot_surface(A, B, -np.ones_like(A), alpha=0.1, color='red')

# --- Panel 2: Comparison with ordinary addition ---
ax2 = fig.add_subplot(132)

a_vals = np.linspace(0, 0.99, 100)
b_fixed = [0.3, 0.5, 0.7, 0.9]

for b in b_fixed:
    hyp = (a_vals + b) / (1 + a_vals * b)
    ax2.plot(a_vals, hyp, linewidth=2, label=f'a ⊕ {b}')
    # Ordinary addition (capped at 1 for display)
    ordinary = np.minimum(a_vals + b, 1.5)
    ax2.plot(a_vals, ordinary, '--', alpha=0.4, linewidth=1)

ax2.axhline(y=1, color='red', linestyle=':', alpha=0.5, label='Speed limit (1)')
ax2.set_xlabel('a', fontsize=12)
ax2.set_ylabel('a ⊕ b', fontsize=12)
ax2.set_title('Hyperbolic vs Ordinary Addition\n(dashed = ordinary)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9, loc='lower right')
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 1.1)
ax2.grid(True, alpha=0.3)
ax2.fill_between([0, 1], 1, 1.1, alpha=0.1, color='red')
ax2.text(0.5, 1.03, 'Forbidden zone', ha='center', fontsize=9, color='red', alpha=0.7)

# --- Panel 3: Iterated hypAdd convergence ---
ax3 = fig.add_subplot(133)

a_values = [0.1, 0.3, 0.5, 0.7, 0.9]
n_max = 30

for a in a_values:
    seq = [hyp_add_iter(a, n) for n in range(n_max + 1)]
    ax3.plot(range(n_max + 1), seq, 'o-', markersize=3, linewidth=1.5,
             label=f'a = {a}')

ax3.axhline(y=1, color='red', linestyle=':', alpha=0.5, linewidth=2)
ax3.set_xlabel('Number of iterations n', fontsize=12)
ax3.set_ylabel('hypAdd_iter(a, n)', fontsize=12)
ax3.set_title('Iterated Hyperbolic Addition\nConverges to 1 (proven < 1 always)',
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(-0.05, 1.05)

# Annotate the proven bound
ax3.annotate('Proven: always < 1\n(hypAdd_iter_lt_one)',
             xy=(20, 0.98), fontsize=9, color='red',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig('hyperbolic_addition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hyperbolic_addition.png")


"""
Visualization: Poincaré Disk Lattice Orbits
=============================================

Visualizes the orbit of the origin under Möbius transformations
on the Poincaré disk, showing how "hyperbolic integers" tile
the hyperbolic plane. Points are colored by their generation depth.

This illustrates the core concept: arithmetic on curved space,
where the density of lattice points increases exponentially
near the boundary of the disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import LineCollection


def moebius_transform(z, center, angle):
    """Apply Möbius transformation z ↦ e^{iθ} · (z - a) / (1 - ā·z)."""
    rotation = np.exp(1j * angle)
    return rotation * (z - center) / (1 - np.conj(center) * z)


def hyp_add(a, b):
    """Hyperbolic addition: (a + b) / (1 + a*b)."""
    return (a + b) / (1 + a * b)


def enumerate_orbit(generators, max_depth):
    """Enumerate orbit points by depth."""
    levels = [{0j}]
    all_points = {(0.0, 0.0)}
    tol = 1e-8

    for depth in range(1, max_depth + 1):
        new_points = set()
        for z in levels[depth - 1]:
            for center, angle in generators:
                w = moebius_transform(z, center, angle)
                key = (round(w.real / tol) * tol, round(w.imag / tol) * tol)
                if key not in all_points and abs(w) < 1 - tol:
                    all_points.add(key)
                    new_points.add(w)
        levels.append(new_points)

    return levels


# Generate orbit
generators = [
    (0.4 + 0j, 0.0),
    (0j + 0.4j, np.pi / 3),
    (-0.3 + 0.2j, np.pi / 2),
]

max_depth = 6
orbit = enumerate_orbit(generators, max_depth)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# --- Left panel: Orbit visualization ---
ax = axes[0]

# Draw the unit disk boundary
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='blue')

# Draw geodesic grid lines (arcs of circles orthogonal to boundary)
for r in [0.2, 0.4, 0.6, 0.8]:
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k-', alpha=0.08, linewidth=0.5)

# Color scheme
colors = plt.cm.viridis(np.linspace(0.1, 0.9, max_depth + 1))

# Plot orbit points
for depth, points in enumerate(orbit):
    if not points:
        continue
    xs = [z.real for z in points]
    ys = [z.imag for z in points]
    size = max(120 - depth * 15, 10)
    ax.scatter(xs, ys, c=[colors[depth]], s=size, zorder=5,
               edgecolors='white', linewidth=0.5,
               label=f'Depth {depth} ({len(points)} pts)')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers on the Poincaré Disk', fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=8, framealpha=0.9)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')

# Add annotation
ax.annotate('Origin\n(identity)', xy=(0, 0), xytext=(0.3, -0.7),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.8))

# --- Right panel: Counting function ---
ax2 = axes[1]

depths = list(range(max_depth + 1))
counts_per_depth = [len(orbit[d]) for d in depths]
cumulative = [sum(counts_per_depth[:d+1]) for d in depths]

# Exponential bound
k = len(generators)
exp_bound = [k**d for d in depths]
cumulative_bound = [sum(k**i for i in range(d+1)) for d in depths]

ax2.semilogy(depths, cumulative, 'bo-', linewidth=2, markersize=8,
             label='Actual count N(d)', zorder=5)
ax2.semilogy(depths, cumulative_bound, 'r--', linewidth=2,
             label=f'Bound: Σ {k}^i', alpha=0.7)

# Bar chart for per-depth counts
ax2_twin = ax2.twinx()
ax2_twin.bar(depths, counts_per_depth, alpha=0.2, color='green',
             label='Points at depth d')
ax2_twin.set_ylabel('Points at depth d', color='green', fontsize=11)
ax2_twin.tick_params(axis='y', labelcolor='green')

ax2.set_xlabel('Depth d', fontsize=12)
ax2.set_ylabel('Cumulative count N(d)', fontsize=12, color='blue')
ax2.tick_params(axis='y', labelcolor='blue')
ax2.set_title('Exponential Growth of Lattice Points', fontsize=14, fontweight='bold')
ax2.legend(loc='upper left', fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_lattice.png")


"""
Visualization: Tree Counting and the Hyperbolic Prime Number Theorem
=====================================================================

Visualizes the combinatorial structure underlying the counting
of "hyperbolic primes" — vertices in regular trees that serve as
analogues of prime numbers in hyperbolic arithmetic.

Shows:
1. Binary tree counting (2n+1 formula, formally proven)
2. General k-regular tree growth rates
3. The geometric sum bound (formally proven)
"""

import numpy as np
import matplotlib.pyplot as plt


def tree_count_at_depth(k, n):
    """Vertices at depth n in a k-regular tree."""
    if n == 0:
        return 1
    return k * (k - 1) ** (n - 1)


def tree_total(k, n):
    """Total vertices up to depth n."""
    return sum(tree_count_at_depth(k, d) for d in range(n + 1))


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# --- Panel 1: Binary tree formula ---
ax1 = axes[0]

n_max = 15
ns = list(range(n_max + 1))
totals = [tree_total(2, n) for n in ns]
formula = [2 * n + 1 for n in ns]

ax1.plot(ns, totals, 'bo-', markersize=8, linewidth=2, label='Actual count', zorder=5)
ax1.plot(ns, formula, 'r--', linewidth=2, label='Formula: 2n + 1')

# Shade the "proven" region
ax1.fill_between(ns, 0, formula, alpha=0.1, color='green')

ax1.set_xlabel('Depth n', fontsize=12)
ax1.set_ylabel('Total vertices', fontsize=12)
ax1.set_title('Binary Tree: Total = 2n + 1\n(Formally Proven)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Annotate
ax1.annotate('treeCount_binary:\nΣ treeCountAtDepth 2 i = 2n + 1',
             xy=(10, 21), fontsize=9,
             bbox=dict(boxstyle='round,pad=0.4', facecolor='lightgreen', alpha=0.8))

# --- Panel 2: k-regular tree growth ---
ax2 = axes[1]

n_max = 10
ns = list(range(n_max + 1))

for k in [2, 3, 4, 5]:
    totals = [tree_total(k, n) for n in ns]
    ax2.semilogy(ns, totals, 'o-', linewidth=2, markersize=6,
                 label=f'k = {k}')

    # Exponential bound
    bounds = [sum(k**i for i in range(n + 1)) for n in ns]
    ax2.semilogy(ns, bounds, '--', alpha=0.4, linewidth=1)

ax2.set_xlabel('Depth n', fontsize=12)
ax2.set_ylabel('Total vertices (log scale)', fontsize=12)
ax2.set_title('k-Regular Tree Growth\n(dashed = exponential bound, proven)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, which='both')

# --- Panel 3: Per-depth counts and "hyperbolic primes" ---
ax3 = axes[2]

k = 3
n_max = 8
ns = list(range(n_max + 1))
per_depth = [tree_count_at_depth(k, n) for n in ns]

# Color depth-1 points as "primes"
colors = ['gold' if n == 1 else 'steelblue' for n in ns]
bars = ax3.bar(ns, per_depth, color=colors, edgecolor='black', linewidth=0.5)

# Add exponential bound line
exp_bound = [k**n for n in ns]
ax3.plot(ns, exp_bound, 'r--', linewidth=2, label=f'Bound: {k}^n', zorder=5)

ax3.set_xlabel('Depth n', fontsize=12)
ax3.set_ylabel('Vertices at depth n', fontsize=12)
ax3.set_title(f'{k}-Regular Tree: Depth Counts\n(Gold = "Hyperbolic Primes")',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3, axis='y')

# Annotate primes
ax3.annotate('"Primes" = depth 1\n(generators of lattice)',
             xy=(1, per_depth[1]),
             xytext=(3, per_depth[1] * 1.5),
             fontsize=9,
             arrowprops=dict(arrowstyle='->', color='darkgoldenrod', linewidth=2),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

# Add counts as labels
for i, (n, c) in enumerate(zip(ns, per_depth)):
    ax3.text(n, c + max(per_depth) * 0.02, str(c),
             ha='center', fontsize=8, fontweight='bold')

plt.tight_layout()
plt.savefig('tree_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tree_counting.png")
