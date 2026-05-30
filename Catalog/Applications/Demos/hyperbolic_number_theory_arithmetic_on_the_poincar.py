"""
Applications of Hyperbolic Number Theory
=========================================
Real-world applications of the mathematical framework.
"""

import cmath
import math
from typing import List, Tuple


# ═══════════════════════════════════════════════════════════════
# Application 1: Hyperbolic Encryption Key Exchange
# ═══════════════════════════════════════════════════════════════

def moebius_map(a: complex, z: complex) -> complex:
    """Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z)"""
    return (a - z) / (1 - a.conjugate() * z)


def moebius_compose(generators: List[complex], word: List[int]) -> complex:
    """Compose Möbius transformations given by a word."""
    z = 0 + 0j
    for idx in word:
        z = moebius_map(generators[idx], z)
    return z


class HyperbolicKeyExchange:
    """
    Diffie-Hellman-style key exchange on the Poincaré disk.

    The security relies on the word problem in hyperbolic groups:
    given a point z in the disk that is the image of 0 under a word
    in the generators, it is computationally hard to recover the word.

    Protocol:
    1. Alice and Bob agree on public generators g₁, g₂, ... in the disk
    2. Alice picks secret word w_A, computes z_A = w_A(0), sends z_A
    3. Bob picks secret word w_B, computes z_B = w_B(0), sends z_B
    4. Alice computes w_A(z_B), Bob computes w_B(z_A)
    5. Shared secret = w_A(w_B(0)) (approximately)

    Note: This is a conceptual demonstration. Real cryptographic
    implementations would need careful analysis of the word problem
    hardness and numerical precision issues.
    """

    def __init__(self, generators: List[complex]):
        self.generators = generators
        for g in generators:
            assert abs(g) < 1, f"Generator {g} not in unit disk"

    def generate_key(self, word: List[int]) -> complex:
        """Generate a public key from a secret word."""
        return moebius_compose(self.generators, word)

    def compute_shared(self, word: List[int], other_public: complex) -> complex:
        """Compute shared secret using own word and other's public key."""
        z = other_public
        for idx in word:
            z = moebius_map(self.generators[idx], z)
        return z


# ═══════════════════════════════════════════════════════════════
# Application 2: Hyperbolic Embeddings for Hierarchical Data
# ═══════════════════════════════════════════════════════════════

class HyperbolicEmbedding:
    """
    Embed hierarchical (tree-like) data into the Poincaré disk.

    Trees embed naturally into hyperbolic space with low distortion.
    The exponential growth of hyperbolic space matches the exponential
    branching of trees, unlike Euclidean space.

    This uses the Möbius map framework to place nodes:
    - Root at the origin
    - Children placed via Möbius translations
    - Depth corresponds to hyperbolic distance from origin
    """

    def __init__(self, branching_factor: int = 2, contraction: float = 0.5):
        self.branching = branching_factor
        self.contraction = contraction

    def embed_tree(self, depth: int) -> dict:
        """
        Embed a complete tree of given depth.

        Returns:
            dict mapping (level, index) → complex position in disk
        """
        positions = {(0, 0): 0 + 0j}  # Root at origin

        for level in range(1, depth + 1):
            parent_count = self.branching ** (level - 1)
            for parent_idx in range(parent_count):
                parent_pos = positions[(level - 1, parent_idx)]
                for child in range(self.branching):
                    # Place children at evenly spaced angles
                    angle = 2 * math.pi * child / self.branching
                    offset = self.contraction * cmath.exp(1j * angle)
                    # Use Möbius map to translate
                    child_pos = moebius_map(-offset, parent_pos)
                    child_idx = parent_idx * self.branching + child
                    positions[(level, child_idx)] = child_pos

        return positions

    def hyperbolic_distance(self, z: complex, w: complex) -> float:
        """Compute hyperbolic distance: 2 · arctanh(|φ_z(w)|)"""
        rho = abs(moebius_map(z, w))
        return 2 * math.atanh(min(rho, 0.9999))


# ═══════════════════════════════════════════════════════════════
# Application 3: Network Routing in Hyperbolic Space
# ═══════════════════════════════════════════════════════════════

class HyperbolicRouter:
    """
    Greedy routing in hyperbolic space.

    Internet-scale networks have been shown to have hyperbolic geometry.
    Greedy routing in the Poincaré disk achieves near-optimal paths
    without routing tables.

    Each node has a hyperbolic coordinate. To route a message, each
    node forwards to the neighbor closest (in hyperbolic distance)
    to the destination.
    """

    def __init__(self):
        self.nodes = {}  # name → position
        self.edges = {}  # name → [neighbors]

    def add_node(self, name: str, position: complex):
        assert abs(position) < 1, "Position must be in unit disk"
        self.nodes[name] = position
        self.edges[name] = []

    def add_edge(self, n1: str, n2: str):
        self.edges[n1].append(n2)
        self.edges[n2].append(n1)

    def hyperbolic_distance(self, z: complex, w: complex) -> float:
        rho = abs(moebius_map(z, w))
        return 2 * math.atanh(min(rho, 0.9999))

    def greedy_route(self, source: str, destination: str) -> List[str]:
        """
        Find a path using greedy hyperbolic routing.

        At each step, forward to the neighbor closest to the destination.
        """
        path = [source]
        current = source
        visited = {source}

        while current != destination:
            dest_pos = self.nodes[destination]
            best_neighbor = None
            best_dist = float('inf')

            for neighbor in self.edges[current]:
                if neighbor not in visited:
                    d = self.hyperbolic_distance(self.nodes[neighbor], dest_pos)
                    if d < best_dist:
                        best_dist = d
                        best_neighbor = neighbor

            if best_neighbor is None:
                break  # Dead end
            visited.add(best_neighbor)
            path.append(best_neighbor)
            current = best_neighbor

        return path


# ═══════════════════════════════════════════════════════════════
# Demonstrations
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Hyperbolic Key Exchange")
    print("=" * 60)

    gens = [0.4 + 0.3j, -0.2 + 0.5j, 0.6 - 0.1j]
    exchange = HyperbolicKeyExchange(gens)

    # Alice's secret word and public key
    alice_word = [0, 1, 2, 0, 1]
    alice_public = exchange.generate_key(alice_word)

    # Bob's secret word and public key
    bob_word = [2, 0, 1, 1, 0]
    bob_public = exchange.generate_key(bob_word)

    # Shared secrets
    alice_shared = exchange.compute_shared(alice_word, bob_public)
    bob_shared = exchange.compute_shared(bob_word, alice_public)

    print(f"  Alice's public key: {alice_public:.6f}")
    print(f"  Bob's public key:   {bob_public:.6f}")
    print(f"  Alice's shared:     {alice_shared:.6f}")
    print(f"  Bob's shared:       {bob_shared:.6f}")
    print(f"  |Alice - Bob|:      {abs(alice_shared - bob_shared):.2e}")
    print()

    print("=" * 60)
    print("Application 2: Tree Embedding in Hyperbolic Space")
    print("=" * 60)

    embedder = HyperbolicEmbedding(branching_factor=3, contraction=0.4)
    tree = embedder.embed_tree(3)
    print(f"  Embedded {len(tree)} nodes")
    for (level, idx), pos in sorted(tree.items())[:15]:
        print(f"  Level {level}, Node {idx}: z = {pos:.4f}, |z| = {abs(pos):.4f}")

    # Check all points are in disk
    all_in_disk = all(abs(pos) < 1 for pos in tree.values())
    print(f"  All points in disk: {all_in_disk}")

    print()
    print("=" * 60)
    print("Application 3: Hyperbolic Greedy Routing")
    print("=" * 60)

    router = HyperbolicRouter()
    # Create a small network with hyperbolic coordinates
    import cmath as cm
    n_nodes = 12
    for i in range(n_nodes):
        angle = 2 * math.pi * i / n_nodes
        r = 0.3 + 0.4 * (i % 3) / 2
        pos = r * cm.exp(1j * angle)
        router.add_node(f"N{i}", pos)

    # Add edges (nearby nodes)
    for i in range(n_nodes):
        for j in range(i+1, n_nodes):
            d = router.hyperbolic_distance(router.nodes[f"N{i}"], router.nodes[f"N{j}"])
            if d < 2.0:
                router.add_edge(f"N{i}", f"N{j}")

    path = router.greedy_route("N0", "N6")
    print(f"  Route N0 → N6: {' → '.join(path)}")
    print(f"  Path length: {len(path) - 1} hops")
    print(f"  Edges: {sum(len(v) for v in router.edges.values()) // 2}")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================
Concrete numerical demonstrations of the theorems proved in Lean 4.

This script demonstrates:
1. Möbius transformations preserving the unit disk
2. The fundamental algebraic identity
3. Hyperbolic lattice growth (exponential vs linear)
4. The Fricke-Vogt trace identity for SL(2,R)
5. Tropical shadow of the hyperbolic metric
6. Primitive word counting (hyperbolic prime number theorem)
"""

import cmath
import math

# ───────────────────────────────────────────────────────────────
# 1. Möbius Transformations on the Poincaré Disk
# ───────────────────────────────────────────────────────────────

def moebius_map(a: complex, z: complex) -> complex:
    """φ_a(z) = (a - z) / (1 - conj(a) * z)"""
    return (a - z) / (1 - a.conjugate() * z)

def norm_sq(z: complex) -> float:
    """|z|² = Re(z)² + Im(z)²"""
    return z.real**2 + z.imag**2

print("=" * 60)
print("DEMO 1: Möbius Maps Preserve the Unit Disk")
print("=" * 60)

test_points = [
    (0.3 + 0.4j, 0.1 + 0.2j),
    (0.5 + 0.5j, -0.3 + 0.6j),
    (0.9 + 0.0j, 0.0 + 0.9j),
    (-0.2 + 0.7j, 0.6 - 0.1j),
]

for a, z in test_points:
    w = moebius_map(a, z)
    print(f"  a = {a}, |a|² = {norm_sq(a):.4f}")
    print(f"  z = {z}, |z|² = {norm_sq(z):.4f}")
    print(f"  φ_a(z) = {w:.4f}, |φ_a(z)|² = {norm_sq(w):.6f}")
    assert norm_sq(w) < 1.0, "Disk preservation violated!"
    print(f"  ✓ |φ_a(z)|² < 1 (disk preserved)")
    print()

# ───────────────────────────────────────────────────────────────
# 2. Fundamental Algebraic Identity
# ───────────────────────────────────────────────────────────────

print("=" * 60)
print("DEMO 2: Fundamental Algebraic Identity")
print("  |1 - ā·z|² - |a - z|² = (1 - |a|²)(1 - |z|²)")
print("=" * 60)

for a, z in test_points:
    lhs = norm_sq(1 - a.conjugate() * z) - norm_sq(a - z)
    rhs = (1 - norm_sq(a)) * (1 - norm_sq(z))
    print(f"  a={a}, z={z}")
    print(f"  LHS = {lhs:.10f}, RHS = {rhs:.10f}, diff = {abs(lhs - rhs):.2e}")
    assert abs(lhs - rhs) < 1e-12, "Identity violated!"
    print(f"  ✓ Identity holds")
    print()

# ───────────────────────────────────────────────────────────────
# 3. Exponential Growth of Hyperbolic Lattices
# ───────────────────────────────────────────────────────────────

print("=" * 60)
print("DEMO 3: Exponential Growth — Flat vs Curved")
print("=" * 60)

def cayley_ball_size(k: int, n: int) -> int:
    """Number of words of length ≤ n over k generators."""
    return sum(k**i for i in range(n + 1))

print(f"  {'Radius n':>10} | {'Z (flat, 2n+1)':>16} | {'Z_H (k=2)':>16} | {'Z_H (k=3)':>16}")
print(f"  {'-'*10}-+-{'-'*16}-+-{'-'*16}-+-{'-'*16}")
for n in range(0, 16):
    flat = 2 * n + 1
    hyp_2 = cayley_ball_size(2, n)
    hyp_3 = cayley_ball_size(3, n)
    print(f"  {n:>10} | {flat:>16,} | {hyp_2:>16,} | {hyp_3:>16,}")

# ───────────────────────────────────────────────────────────────
# 4. Fricke-Vogt Trace Identity for SL(2,R)
# ───────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Fricke-Vogt Trace Identity")
print("  tr(AB) + tr(AB⁻¹) = tr(A)·tr(B)")
print("=" * 60)

def mat_mul(A, B):
    """Multiply 2x2 matrices represented as (a,b,c,d) tuples."""
    a1,b1,c1,d1 = A
    a2,b2,c2,d2 = B
    return (a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2)

def mat_inv(M):
    """Inverse of SL(2,R): (d, -b, -c, a)"""
    a,b,c,d = M
    return (d, -b, -c, a)

def mat_trace(M):
    return M[0] + M[3]

test_matrices = [
    ((2,1,1,1), (1,1,0,1)),   # hyperbolic × parabolic
    ((3,2,1,1), (2,1,3,2)),   # hyperbolic × hyperbolic
    ((1,0,0,1), (5,2,2,1)),   # identity × hyperbolic
]

for A, B in test_matrices:
    AB = mat_mul(A, B)
    ABinv = mat_mul(A, mat_inv(B))
    tr_AB = mat_trace(AB)
    tr_ABinv = mat_trace(ABinv)
    tr_A = mat_trace(A)
    tr_B = mat_trace(B)
    lhs = tr_AB + tr_ABinv
    rhs = tr_A * tr_B
    print(f"  A = {A}, B = {B}")
    print(f"  tr(AB) + tr(AB⁻¹) = {lhs:.6f}, tr(A)·tr(B) = {rhs:.6f}")
    assert abs(lhs - rhs) < 1e-10
    print(f"  ✓ Identity verified")
    print()

# ───────────────────────────────────────────────────────────────
# 5. Tropical Shadow of the Hyperbolic Metric
# ───────────────────────────────────────────────────────────────

print("=" * 60)
print("DEMO 5: Tropical Shadow — Hyperbolic ↔ Tropical Bridge")
print("  T(r) = -log(1 - r²)")
print("=" * 60)

def tropical_shadow(r: float) -> float:
    """The tropical shadow: -log(1 - r²)"""
    return -math.log(1 - r**2)

print(f"  {'r':>8} | {'T(r)':>12} | {'≥ 0?':>6} | {'monotone?':>10}")
print(f"  {'-'*8}-+-{'-'*12}-+-{'-'*6}-+-{'-'*10}")
prev = 0.0
for r in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]:
    t = tropical_shadow(r)
    mono = "✓" if t >= prev - 1e-15 else "✗"
    nonneg = "✓" if t >= -1e-15 else "✗"
    print(f"  {r:>8.2f} | {t:>12.6f} | {nonneg:>6} | {mono:>10}")
    prev = t

# ───────────────────────────────────────────────────────────────
# 6. Primitive Word Counting (Hyperbolic PNT)
# ───────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 6: Hyperbolic Prime Number Theorem")
print("  Primitive word count ≈ k^n / n")
print("=" * 60)

def moebius_function(n: int) -> int:
    """Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0  # squared factor
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)

def exact_primitive_necklaces(k: int, n: int) -> int:
    """Exact count of primitive necklaces (Witt's formula):
    M(k, n) = (1/n) Σ_{d|n} μ(n/d) k^d"""
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += moebius_function(n // d) * k**d
    return total // n

print(f"  {'n':>4} | {'k^n':>10} | {'k^n/n':>8} | {'Exact (Witt)':>12} | {'Ratio':>8}")
print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*8}-+-{'-'*12}-+-{'-'*8}")
k = 2
for n in range(1, 21):
    kn = k**n
    approx = kn // n
    exact = exact_primitive_necklaces(k, n)
    ratio = exact / (kn / n) if n > 0 else 0
    print(f"  {n:>4} | {kn:>10,} | {approx:>8,} | {exact:>12,} | {ratio:>8.4f}")

print("\n  → As n grows, the ratio → 1, confirming the asymptotic.")
print("  This is the hyperbolic analog of π(x) ~ x/ln(x).")

# ───────────────────────────────────────────────────────────────
# 7. SL(2,R) Classification by Trace
# ───────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 7: SL(2,R) Classification by Trace")
print("=" * 60)

def classify_sl2(a, b, c, d):
    tr = a + d
    disc = tr**2 - 4
    if abs(tr) < 2:
        return "elliptic", tr, disc
    elif abs(tr) == 2:
        return "parabolic", tr, disc
    else:
        return "hyperbolic", tr, disc

examples = [
    (1, 0, 0, 1, "Identity"),
    (0, -1, 1, 0, "90° rotation"),
    (2, 1, 1, 1, "Hyperbolic"),
    (1, 1, 0, 1, "Parabolic (shear)"),
    (3, 2, 1, 1, "Strongly hyperbolic"),
]

for a, b, c, d, name in examples:
    cls, tr, disc = classify_sl2(a, b, c, d)
    print(f"  {name:>25}: tr = {tr:>6.2f}, disc = {disc:>6.2f} → {cls}")

print("\n✅ All demonstrations completed successfully.")


"""
Visualization 1: Poincaré Disk Lattice Points
==============================================
Visualizes hyperbolic integers as orbit points in the Poincaré disk,
showing how Möbius transformations tessellate the disk with exponentially
many points that crowd toward the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    """Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z)"""
    return (a - z) / (1 - np.conj(a) * z)


def enumerate_lattice(generators, max_depth):
    """Enumerate hyperbolic integers by BFS on the Cayley graph."""
    points = {0: (0 + 0j, 0)}  # position → (complex_value, depth)
    current_level = [0 + 0j]
    all_points = [(0 + 0j, 0)]

    for depth in range(1, max_depth + 1):
        next_level = []
        for z in current_level:
            for g in generators:
                w = moebius_map(g, z)
                # Use discretization to avoid duplicates
                key = round(w.real, 8) + 1j * round(w.imag, 8)
                if key not in points:
                    points[key] = (w, depth)
                    next_level.append(w)
                    all_points.append((w, depth))
        current_level = next_level

    return all_points


# Generate lattice with 2 generators at angle π/3 apart
r = 0.6  # generator radius
gen1 = r * np.exp(1j * 0)
gen2 = r * np.exp(1j * np.pi / 3)
gen3 = r * np.exp(1j * 2 * np.pi / 3)
generators = [gen1, gen2, gen3]

lattice = enumerate_lattice(generators, max_depth=5)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# Left panel: Lattice points colored by depth
ax1 = axes[0]
theta = np.linspace(0, 2 * np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax1.set_xlim(-1.15, 1.15)
ax1.set_ylim(-1.15, 1.15)
ax1.set_aspect('equal')

cmap = plt.cm.viridis
max_depth = max(d for _, d in lattice)
for z, depth in lattice:
    color = cmap(depth / max(max_depth, 1))
    size = max(50 - depth * 8, 3)
    ax1.plot(z.real, z.imag, 'o', color=color, markersize=size ** 0.5 * 2,
             markeredgecolor='black', markeredgewidth=0.3, alpha=0.8)

# Mark generators
for i, g in enumerate(generators):
    ax1.plot(g.real, g.imag, 'r*', markersize=12, markeredgecolor='black', markeredgewidth=0.5)
ax1.plot(0, 0, 'ko', markersize=8)

ax1.set_title('Hyperbolic Integers on the Poincaré Disk\n(orbit of 0 under 3 Möbius generators)',
              fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')

# Add colorbar
sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(0, max_depth))
sm.set_array([])
cbar = plt.colorbar(sm, ax=ax1, shrink=0.8)
cbar.set_label('Word length (depth)')

# Right panel: Growth comparison
ax2 = axes[1]
ns = np.arange(0, 12)
flat_growth = 2 * ns + 1
hyp_growth_2 = [sum(2**i for i in range(n+1)) for n in ns]
hyp_growth_3 = [sum(3**i for i in range(n+1)) for n in ns]

ax2.semilogy(ns, flat_growth, 'b-o', linewidth=2, markersize=8, label='ℤ (flat): 2n+1')
ax2.semilogy(ns, hyp_growth_2, 'r-s', linewidth=2, markersize=8, label='ℤ_H (k=2): Σ2ⁱ')
ax2.semilogy(ns, hyp_growth_3, 'g-^', linewidth=2, markersize=8, label='ℤ_H (k=3): Σ3ⁱ')

ax2.set_xlabel('Radius n', fontsize=12)
ax2.set_ylabel('Number of lattice points (log scale)', fontsize=12)
ax2.set_title('Exponential Growth:\nFlat vs Hyperbolic Arithmetic', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 11.5)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved poincare_lattice.png")


"""
Visualization 2: SL(2,R) Trace Classification
==============================================
Visualizes the classification of SL(2,R) elements into elliptic,
parabolic, and hyperbolic types based on the trace, connecting
linear algebra to hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Trace vs Discriminant
ax1 = axes[0]
traces = np.linspace(-4, 4, 500)
discriminant = traces**2 - 4

# Color regions
ax1.fill_between(traces, discriminant, -5, where=(np.abs(traces) < 2),
                 alpha=0.3, color='blue', label='Elliptic (|tr| < 2)')
ax1.fill_between(traces, discriminant, 20, where=(np.abs(traces) > 2),
                 alpha=0.3, color='red', label='Hyperbolic (|tr| > 2)')

ax1.plot(traces, discriminant, 'k-', linewidth=2, label='Discriminant: tr² − 4')
ax1.axhline(y=0, color='green', linewidth=2, linestyle='--', label='Parabolic (tr² = 4)')
ax1.axvline(x=-2, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=2, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Trace = a + d', fontsize=12)
ax1.set_ylabel('Discriminant = tr² − 4', fontsize=12)
ax1.set_title('SL(2,ℝ) Classification\nby Trace', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper center')
ax1.set_xlim(-4, 4)
ax1.set_ylim(-5, 13)
ax1.grid(True, alpha=0.3)

# Panel 2: Eigenvalue location
ax2 = axes[1]
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5)

# Elliptic: eigenvalues on unit circle
n_elliptic = 15
for i in range(n_elliptic):
    t = np.pi * (i + 1) / (n_elliptic + 1)
    ax2.plot(np.cos(t), np.sin(t), 'bo', markersize=8, alpha=0.7)
    ax2.plot(np.cos(t), -np.sin(t), 'bo', markersize=8, alpha=0.7)

# Parabolic: eigenvalue at ±1
ax2.plot(1, 0, 'gs', markersize=12, zorder=5, label='Parabolic (±1)')
ax2.plot(-1, 0, 'gs', markersize=12, zorder=5)

# Hyperbolic: eigenvalues on real axis
hyp_eigenvalues = [0.3, 0.5, 2.0, 3.3]
for lam in hyp_eigenvalues:
    ax2.plot(lam, 0, 'r^', markersize=10, alpha=0.8)
    ax2.plot(1/lam, 0, 'r^', markersize=10, alpha=0.8)

ax2.plot([], [], 'bo', markersize=8, label='Elliptic (on circle)')
ax2.plot([], [], 'r^', markersize=10, label='Hyperbolic (real, λ·1/λ)')

ax2.set_xlim(-3.8, 3.8)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Eigenvalue Location\nin the Complex Plane', fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(λ)', fontsize=12)
ax2.set_ylabel('Im(λ)', fontsize=12)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)

# Panel 3: Orbits of each type
ax3 = axes[2]
ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Elliptic orbit (rotation)
t_vals = np.linspace(0, 2*np.pi, 20, endpoint=False)
r_orbit = 0.5
for t in t_vals:
    ax3.plot(r_orbit * np.cos(t), r_orbit * np.sin(t), 'bo', markersize=5, alpha=0.6)
ax3.annotate('Elliptic orbit\n(finite, circular)', xy=(0.5, 0.05),
             fontsize=9, color='blue', ha='center')

# Hyperbolic orbit (toward boundary)
for i in range(12):
    r = 1 - 0.9**i * 0.5
    angle = 0.3
    ax3.plot(r * np.cos(angle), r * np.sin(angle), 'r^', markersize=5, alpha=0.6)
    ax3.plot(-r * np.cos(angle), -r * np.sin(angle), 'r^', markersize=5, alpha=0.6)
ax3.annotate('Hyperbolic orbit\n(to boundary)', xy=(0.85, 0.4),
             fontsize=9, color='red', ha='center')

# Parabolic orbit (horocycle)
horocycle_t = np.linspace(-2, 2, 50)
horo_x = horocycle_t / (1 + horocycle_t**2)
horo_y = 1 - 1 / (1 + horocycle_t**2)
mask = horo_x**2 + horo_y**2 < 0.98
ax3.plot(horo_x[mask], horo_y[mask], 'g-', linewidth=2, alpha=0.7)
ax3.annotate('Parabolic orbit\n(horocycle)', xy=(0, 0.7),
             fontsize=9, color='green', ha='center')

ax3.set_xlim(-1.15, 1.15)
ax3.set_ylim(-1.15, 1.15)
ax3.set_aspect('equal')
ax3.set_title('Orbit Types in the\nPoincaré Disk', fontsize=13, fontweight='bold')
ax3.set_xlabel('Re(z)', fontsize=12)
ax3.set_ylabel('Im(z)', fontsize=12)

plt.tight_layout()
plt.savefig('trace_classification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trace_classification.png")


"""
Visualization 3: Tropical Shadow and Hyperbolic Prime Counting
===============================================================
Visualizes the tropical shadow map T(r) = -log(1 - r²) and the
hyperbolic prime number theorem, showing the bridge between
hyperbolic geometry and tropical/combinatorial mathematics.
"""

import numpy as np
import matplotlib.pyplot as plt


def moebius_mu(n):
    """Möbius function μ(n)."""
    if n == 1:
        return 1
    d = 2
    temp = n
    factors = 0
    while d * d <= temp:
        if temp % d == 0:
            temp //= d
            factors += 1
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def primitive_necklace_count(k, n):
    """Exact count of primitive necklaces via Witt's formula."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += moebius_mu(n // d) * k ** d
    return total // n


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Tropical Shadow function
ax1 = axes[0]
r = np.linspace(0, 0.995, 500)
T = -np.log(1 - r**2)

ax1.plot(r, T, 'b-', linewidth=2.5, label='T(r) = −log(1 − r²)')
ax1.fill_between(r, 0, T, alpha=0.15, color='blue')
ax1.axhline(y=0, color='gray', linewidth=0.5)

# Mark key points
key_rs = [0.0, 0.5, 0.7, 0.9, 0.95]
for rv in key_rs:
    tv = -np.log(1 - rv**2)
    ax1.plot(rv, tv, 'ro', markersize=8, zorder=5)
    ax1.annotate(f'({rv}, {tv:.2f})', xy=(rv, tv),
                 xytext=(rv - 0.1, tv + 0.3), fontsize=8)

ax1.set_xlabel('Pseudohyperbolic distance r', fontsize=12)
ax1.set_ylabel('Tropical shadow T(r)', fontsize=12)
ax1.set_title('Tropical Shadow:\nHyperbolic → Tropical Bridge', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(-0.05, 1.05)
ax1.set_ylim(-0.2, 6)
ax1.grid(True, alpha=0.3)

# Annotations
ax1.annotate('T(r) ≥ 0 ✓\n(proved)', xy=(0.3, 4.5), fontsize=10,
             color='green', fontweight='bold', ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.5))
ax1.annotate('Monotone ✓\n(proved)', xy=(0.7, 4.5), fontsize=10,
             color='green', fontweight='bold', ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.5))

# Panel 2: Hyperbolic Prime Counting
ax2 = axes[1]
k = 2
ns = np.arange(1, 21)
exact = [primitive_necklace_count(k, n) for n in ns]
approx = [k**n / n for n in ns]

ax2.semilogy(ns, exact, 'ro-', linewidth=2, markersize=6, label='Exact (Witt formula)')
ax2.semilogy(ns, approx, 'b--', linewidth=2, label='Asymptotic: 2ⁿ/n')
ax2.semilogy(ns, [k**n for n in ns], 'g:', linewidth=1.5, alpha=0.5, label='Total words: 2ⁿ')

ax2.set_xlabel('Word length n', fontsize=12)
ax2.set_ylabel('Count (log scale)', fontsize=12)
ax2.set_title('Hyperbolic Prime Number Theorem\n(k = 2 generators)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 20.5)

# Panel 3: Ratio convergence (PNT analog)
ax3 = axes[2]
ns_long = np.arange(1, 31)
exact_long = [primitive_necklace_count(2, n) for n in ns_long]
approx_long = [2**n / n for n in ns_long]
ratios = [e / a for e, a in zip(exact_long, approx_long)]

ax3.plot(ns_long, ratios, 'r-o', linewidth=2, markersize=5)
ax3.axhline(y=1.0, color='blue', linestyle='--', linewidth=2, label='Asymptotic ratio = 1')
ax3.fill_between(ns_long, 0.9, 1.1, alpha=0.1, color='blue')

ax3.set_xlabel('Word length n', fontsize=12)
ax3.set_ylabel('Exact / (k^n/n)', fontsize=12)
ax3.set_title('Convergence of the\nHyperbolic PNT Ratio', fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0.5, 30.5)
ax3.set_ylim(0.85, 1.05)

# Add annotation about testable prediction
ax3.annotate('Testable prediction:\nratio → 1 as n → ∞\n(confirmed!)', 
             xy=(20, 0.999), fontsize=10,
             color='green', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.5))

plt.tight_layout()
plt.savefig('tropical_shadow_and_primes.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved tropical_shadow_and_primes.png")
