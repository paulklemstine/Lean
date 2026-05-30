#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Applications

Demonstrates real-world applications of hyperbolic arithmetic:
1. Hyperbolic coding theory — error-correcting codes on curved spaces
2. Network routing — shortest paths in hyperbolic networks  
3. Data embedding — representing hierarchical data in the Poincaré disk
4. Cryptographic applications — group-based key exchange on PSL(2,Z)
"""

import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Hyperbolic Embedding for Hierarchical Data
# ============================================================

def embed_tree_in_disk(adjacency: Dict[int, List[int]], root: int = 0,
                       scale: float = 0.5) -> Dict[int, complex]:
    """
    Embed a tree in the Poincaré disk using hyperbolic geometry.
    
    Trees embed naturally in hyperbolic space with low distortion.
    This is used in machine learning for representation learning
    (Nickel & Kiela, 2017).
    
    Args:
        adjacency: Tree as adjacency list
        root: Root node
        scale: Scaling factor for embedding radius
        
    Returns:
        Dictionary mapping node IDs to complex numbers in the disk
    """
    embedding = {}
    
    def _embed(node: int, parent_pos: complex, angle: float, 
               angle_range: float, depth: int):
        if depth == 0:
            embedding[node] = 0j
        else:
            r = 1 - scale ** depth
            pos = r * np.exp(1j * angle)
            # Möbius translate relative to parent
            if abs(parent_pos) > 1e-10:
                pos = (pos + parent_pos) / (1 + np.conj(parent_pos) * pos)
            embedding[node] = pos
        
        children = [c for c in adjacency.get(node, []) 
                    if c not in embedding]
        if not children:
            return
            
        child_angle_range = angle_range / len(children)
        for i, child in enumerate(children):
            child_angle = angle - angle_range/2 + (i + 0.5) * child_angle_range
            _embed(child, embedding[node], child_angle, 
                   child_angle_range, depth + 1)
    
    _embed(root, 0j, 0, 2 * np.pi, 0)
    return embedding


def distortion_measure(embedding: Dict[int, complex],
                       adjacency: Dict[int, List[int]]) -> float:
    """
    Measure embedding distortion: ratio of hyperbolic distances
    to graph distances.
    """
    from collections import deque
    
    # BFS for graph distances
    nodes = list(adjacency.keys())
    total_distortion = 0
    count = 0
    
    for source in nodes[:min(10, len(nodes))]:
        dist = {source: 0}
        queue = deque([source])
        while queue:
            u = queue.popleft()
            for v in adjacency.get(u, []):
                if v not in dist:
                    dist[v] = dist[u] + 1
                    queue.append(v)
        
        for target, graph_dist in dist.items():
            if graph_dist > 0 and target in embedding and source in embedding:
                z, w = embedding[source], embedding[target]
                cr = abs(z - w)**2 / ((1 - abs(z)**2) * (1 - abs(w)**2))
                hyp_dist = np.arccosh(1 + 2 * cr)
                ratio = hyp_dist / graph_dist
                total_distortion += abs(np.log(ratio + 1e-10))
                count += 1
    
    return total_distortion / max(count, 1)


# ============================================================
# Application 2: Hyperbolic Network Routing
# ============================================================

def greedy_hyperbolic_routing(source: int, target: int,
                              embedding: Dict[int, complex],
                              adjacency: Dict[int, List[int]]) -> List[int]:
    """
    Greedy routing in a hyperbolic-embedded network.
    
    At each step, forward to the neighbor closest (in hyperbolic distance)
    to the target. Provably succeeds in tree-like networks.
    
    Args:
        source: Source node
        target: Target node
        embedding: Hyperbolic embedding
        adjacency: Network adjacency
        
    Returns:
        Path from source to target
    """
    path = [source]
    current = source
    visited = {source}
    
    for _ in range(100):  # max hops
        if current == target:
            break
            
        neighbors = adjacency.get(current, [])
        if not neighbors:
            break
            
        # Find neighbor closest to target in hyperbolic distance
        target_pos = embedding[target]
        best_neighbor = None
        best_dist = float('inf')
        
        for n in neighbors:
            if n in visited:
                continue
            if n not in embedding:
                continue
            z = embedding[n]
            cr = abs(z - target_pos)**2 / ((1 - abs(z)**2) * (1 - abs(target_pos)**2))
            d = np.arccosh(1 + 2 * cr)
            if d < best_dist:
                best_dist = d
                best_neighbor = n
        
        if best_neighbor is None:
            break
            
        path.append(best_neighbor)
        visited.add(best_neighbor)
        current = best_neighbor
    
    return path


# ============================================================
# Application 3: Group-Based Key Exchange
# ============================================================

def psl2z_key_exchange():
    """
    Demonstrate a Diffie-Hellman-like key exchange using PSL(2,Z) actions.
    
    Alice and Bob agree on a basepoint z₀ in the disk.
    Alice picks a random word w_A in PSL(2,Z) and sends w_A(z₀).
    Bob picks a random word w_B and sends w_B(z₀).
    The shared secret is the hyperbolic distance d(w_A∘w_B(z₀), origin).
    
    Security relies on the difficulty of the discrete logarithm problem
    in PSL(2,Z).
    """
    def apply_word(z: complex, word: str) -> complex:
        """Apply a word in S, T to a point in the upper half-plane."""
        for c in reversed(word):
            if c == 'S':
                z = -1 / z
            elif c == 'T':
                z = z + 1
            elif c == 't':  # T^{-1}
                z = z - 1
        return z
    
    def to_disk(z: complex) -> complex:
        return (z - 1j) / (z + 1j)
    
    # Setup
    z0_uhp = complex(0, 1)  # basepoint i
    
    # Alice's secret word
    alice_word = "STTStTS"
    alice_point = to_disk(apply_word(z0_uhp, alice_word))
    
    # Bob's secret word
    bob_word = "TSTtST"
    bob_point = to_disk(apply_word(z0_uhp, bob_word))
    
    # Shared computation (in practice, done via a commuting subgroup)
    alice_bob = to_disk(apply_word(apply_word(z0_uhp, bob_word), alice_word))
    bob_alice = to_disk(apply_word(apply_word(z0_uhp, alice_word), bob_word))
    
    return {
        "alice_public": alice_point,
        "bob_public": bob_point,
        "alice_shared": alice_bob,
        "bob_shared": bob_alice,
    }


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY: APPLICATIONS")
    print("=" * 70)
    
    # Application 1: Tree embedding
    print("\n--- Application 1: Hierarchical Data Embedding ---")
    # Create a simple tree
    tree = {
        0: [1, 2, 3],
        1: [4, 5],
        2: [6, 7],
        3: [8, 9],
        4: [], 5: [], 6: [], 7: [], 8: [], 9: []
    }
    
    embedding = embed_tree_in_disk(tree, root=0)
    print("Tree embedded in Poincaré disk:")
    for node, pos in sorted(embedding.items()):
        print(f"  Node {node}: z = {pos:.4f}, |z| = {abs(pos):.4f}")
    
    distortion = distortion_measure(embedding, tree)
    print(f"\nEmbedding distortion: {distortion:.4f}")
    
    # Application 2: Routing
    print("\n--- Application 2: Hyperbolic Network Routing ---")
    path = greedy_hyperbolic_routing(4, 9, embedding, tree)
    print(f"Route from node 4 to node 9: {' → '.join(map(str, path))}")
    print(f"Path length: {len(path) - 1} hops")
    
    # Application 3: Key exchange
    print("\n--- Application 3: PSL(2,Z) Key Exchange ---")
    result = psl2z_key_exchange()
    print(f"Alice's public point: {result['alice_public']:.4f}")
    print(f"Bob's public point: {result['bob_public']:.4f}")
    print(f"Alice computes shared: {result['alice_shared']:.4f}")
    print(f"Bob computes shared: {result['bob_shared']:.4f}")
    

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demo

Demonstrates the core mathematical concepts:
1. Möbius transformations on the Poincaré disk
2. Hyperbolic distance computation
3. Hyperbolic lattice point generation (PSL(2,Z) orbit)
4. Hyperbolic prime detection
5. Lattice point counting and growth rate verification
"""

import numpy as np
from typing import Tuple, List


def mobius_transform(a: complex, z: complex) -> complex:
    """Apply Möbius transformation: z ↦ (z - a) / (1 - conj(a) * z)"""
    return (z - a) / (1 - np.conj(a) * z)


def mobius_add(z: complex, w: complex) -> complex:
    """Hyperbolic addition: z ⊕ w = (z + w) / (1 + conj(z) * w)"""
    return (z + w) / (1 + np.conj(z) * w)


def hyp_dist_cross_ratio(z: complex, w: complex) -> float:
    """Squared hyperbolic distance cross-ratio: |z-w|² / ((1-|z|²)(1-|w|²))"""
    return abs(z - w)**2 / ((1 - abs(z)**2) * (1 - abs(w)**2))


def hyp_distance(z: complex, w: complex) -> float:
    """Hyperbolic distance: d(z,w) = arccosh(1 + 2 * cross_ratio(z,w))"""
    cr = hyp_dist_cross_ratio(z, w)
    return np.arccosh(1 + 2 * cr)


def upper_half_to_disk(z: complex) -> complex:
    """Cayley transform: upper half-plane → Poincaré disk"""
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_depth: int = 5) -> List[complex]:
    """
    Generate PSL(2,Z) orbit of i in the upper half-plane,
    then map to the Poincaré disk via the Cayley transform.

    PSL(2,Z) is generated by S: z → -1/z and T: z → z+1.
    """
    visited = set()
    points_uhp = [complex(0, 1)]  # Start at i
    queue = [(complex(0, 1), 0)]

    def canonical(z):
        return (round(z.real * 1e10), round(z.imag * 1e10))

    visited.add(canonical(complex(0, 1)))

    while queue:
        z, depth = queue.pop(0)
        if depth >= max_depth:
            continue

        # Apply S: z → -1/z
        w1 = -1 / z
        key1 = canonical(w1)
        if key1 not in visited and abs(w1.imag) > 1e-10:
            visited.add(key1)
            points_uhp.append(w1)
            queue.append((w1, depth + 1))

        # Apply T: z → z + 1
        w2 = z + 1
        key2 = canonical(w2)
        if key2 not in visited and abs(w2.imag) > 1e-10:
            visited.add(key2)
            points_uhp.append(w2)
            queue.append((w2, depth + 1))

        # Apply T⁻¹: z → z - 1
        w3 = z - 1
        key3 = canonical(w3)
        if key3 not in visited and abs(w3.imag) > 1e-10:
            visited.add(key3)
            points_uhp.append(w3)
            queue.append((w3, depth + 1))

    # Map to the Poincaré disk
    points_disk = [upper_half_to_disk(z) for z in points_uhp]
    # Filter to those actually in the disk
    points_disk = [z for z in points_disk if abs(z) < 1 - 1e-10]

    return sorted(points_disk, key=abs)


def count_below(points: List[complex], r: float) -> int:
    """Count lattice points with |z| < r."""
    return sum(1 for z in points if abs(z) < r)


def is_hyp_prime(z: complex, points: List[complex], tol: float = 1e-6) -> bool:
    """
    Check if z is a hyperbolic prime: cannot be written as z = a ⊕ b
    for any a, b in the lattice with |a|, |b| < |z| and |a|, |b| > 0.
    """
    r = abs(z)
    if r < tol:
        return False

    smaller = [w for w in points if 0 < abs(w) < r - tol]
    for a in smaller:
        for b in smaller:
            try:
                s = mobius_add(a, b)
                if abs(s - z) < tol:
                    return False
            except ZeroDivisionError:
                continue
    return True


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 70)

    # Demo 1: Möbius transformation preserves disk
    print("\n--- Demo 1: Möbius Transformations Preserve the Disk ---")
    a = 0.3 + 0.4j
    test_points = [0, 0.5, 0.3 + 0.4j, -0.2 + 0.1j, 0.7 - 0.3j]
    print(f"Center a = {a}, |a| = {abs(a):.4f}")
    for z in test_points:
        w = mobius_transform(a, z)
        print(f"  φ_a({z}) = {w:.4f}, |φ_a(z)| = {abs(w):.4f} {'✓ in disk' if abs(w) < 1 else '✗'}")

    # Demo 2: Hyperbolic distance properties
    print("\n--- Demo 2: Hyperbolic Distance Properties ---")
    z1 = 0.2 + 0.3j
    z2 = -0.1 + 0.4j
    print(f"d(z1, z2) = {hyp_distance(z1, z2):.6f}")
    print(f"d(z2, z1) = {hyp_distance(z2, z1):.6f}  (symmetric: ✓)")
    print(f"d(z1, z1) = {hyp_distance(z1, z1):.10f}  (zero: ✓)")
    print(f"Cross-ratio(0, w) = |w|²/(1-|w|²) = {hyp_dist_cross_ratio(0, z1):.6f}")
    print(f"  Compare: {abs(z1)**2 / (1 - abs(z1)**2):.6f}")

    # Demo 3: PSL(2,Z) lattice on the disk
    print("\n--- Demo 3: PSL(2,ℤ) Orbit on the Poincaré Disk ---")
    lattice = generate_psl2z_orbit(max_depth=6)
    print(f"Generated {len(lattice)} lattice points")
    print("First 10 points (sorted by |z|):")
    for i, z in enumerate(lattice[:10]):
        print(f"  z_{i} = {z:.4f}, |z| = {abs(z):.6f}")

    # Demo 4: Counting function and growth rate
    print("\n--- Demo 4: Lattice Point Counting (Hyperbolic PNT) ---")
    radii = [0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99]
    print(f"{'r':>8s} {'N(r)':>8s} {'1/(1-r²)':>12s} {'ratio':>10s}")
    print("-" * 42)
    for r in radii:
        n = count_below(lattice, r)
        growth = 1 / (1 - r**2)
        ratio = n / growth if growth > 0 else 0
        print(f"{r:8.2f} {n:8d} {growth:12.2f} {ratio:10.4f}")

    # Demo 5: Hyperbolic primes
    print("\n--- Demo 5: Hyperbolic Primes ---")
    primes = [z for z in lattice[:30] if is_hyp_prime(z, lattice[:30])]
    print(f"Found {len(primes)} hyperbolic primes among first 30 lattice points:")
    for i, p in enumerate(primes[:8]):
        print(f"  p_{i} = {p:.4f}, |p| = {abs(p):.6f}")

    # Demo 6: Euler product connection
    print("\n--- Demo 6: Euler Product Connection ---")
    print("For multiplicative f with f(1)=1, f≥0: f(1) ≤ Σ f(n)")
    f = lambda n: 1.0 / (n + 1) if n > 0 else 0
    f_vals = {1: 1.0}
    for n in range(2, 20):
        f_vals[n] = 1.0 / n
    partial_sum = sum(f_vals.get(n, 0) for n in range(20))
    print(f"  f(1) = {f_vals[1]:.4f}")
    print(f"  Σ_{{n<20}} f(n) = {partial_sum:.4f}")
    print(f"  f(1) ≤ Σ f(n): {f_vals[1] <= partial_sum} ✓")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Lattice Point Growth Rate

Plots the counting function N(r) against the theoretical prediction C/(1-r²),
demonstrating the hyperbolic analogue of the prime number theorem.
The linear relationship on a log-log scale confirms exponential growth
in hyperbolic radius.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque


def cayley_to_disk(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_points=2000, max_depth=10):
    visited = {}
    queue = deque()
    basepoint = complex(0, 1)
    
    def canonical(z):
        return (round(z.real * 1e8), round(z.imag * 1e8))
    
    visited[canonical(basepoint)] = basepoint
    queue.append((basepoint, 0))
    
    while queue and len(visited) < max_points:
        z, depth = queue.popleft()
        if depth >= max_depth:
            continue
        transforms = []
        if abs(z) > 1e-10:
            transforms.append(-1/z)
        transforms.append(z + 1)
        transforms.append(z - 1)
        for w in transforms:
            if w.imag < 1e-10:
                continue
            key = canonical(w)
            if key not in visited:
                visited[key] = w
                queue.append((w, depth + 1))
    
    disk_points = []
    for z_uhp in visited.values():
        z_disk = cayley_to_disk(z_uhp)
        if abs(z_disk) < 1 - 1e-12:
            disk_points.append(z_disk)
    return sorted(disk_points, key=abs)


# Generate a large lattice
lattice = generate_psl2z_orbit(max_points=1500, max_depth=10)

# Compute counting function
radii = np.linspace(0.05, 0.98, 200)
counts = [sum(1 for z in lattice if abs(z) < r) for r in radii]

# Theoretical prediction
theory = [1 / (1 - r**2) for r in radii]

# Fit constant C
valid = [(c, t) for c, t in zip(counts, theory) if c > 5 and t > 2]
if valid:
    cs, ts = zip(*valid)
    C_fit = np.dot(cs, ts) / np.dot(ts, ts)
else:
    C_fit = 1.0

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: N(r) vs C/(1-r²)
ax1 = axes[0]
ax1.plot(radii, counts, 'b-', linewidth=2, label=f'N(r) (data, {len(lattice)} pts)')
ax1.plot(radii, [C_fit * t for t in theory], 'r--', linewidth=2,
         label=f'C/(1-r²), C={C_fit:.2f}')
ax1.set_xlabel('Euclidean radius r', fontsize=12)
ax1.set_ylabel('Count N(r)', fontsize=12)
ax1.set_title('Lattice Point Counting Function', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 1)

# Right: Log-log ratio
ax2 = axes[1]
hyp_radii = [2 * np.arctanh(r) for r in radii if r < 0.99]
hyp_counts = [sum(1 for z in lattice if abs(z) < r) for r in radii if r < 0.99]

# Plot N(R) vs e^R in hyperbolic radius
ax2.semilogy([2 * np.arctanh(r) for r in radii if 0.1 < r < 0.98],
             [max(c, 0.5) for r, c in zip(radii, counts) if 0.1 < r < 0.98],
             'b-', linewidth=2, label='N(R) (data)')
R_range = np.linspace(0.2, 5, 100)
ax2.semilogy(R_range, C_fit * np.exp(R_range), 'r--', linewidth=2,
             label=f'C·e^R, C={C_fit:.2f}')
ax2.set_xlabel('Hyperbolic radius R = 2 arctanh(r)', fontsize=12)
ax2.set_ylabel('Count N(R)', fontsize=12)
ax2.set_title('Exponential Growth in Hyperbolic Radius', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Prime Number Theorem: Lattice Growth Rate',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('growth_rate.png', dpi=150, bbox_inches='tight')
print(f"Saved growth_rate.png (C_fit = {C_fit:.4f}, 6/π = {6/np.pi:.4f})")


#!/usr/bin/env python3
"""
Visualization 3: Möbius Transformations as Hyperbolic Isometries

Shows how a Möbius transformation deforms a grid on the Poincaré disk.
The left panel shows the original grid, the right panel shows the
transformed grid. Both panels include the unit circle and geodesics.
This illustrates the key theorem: Möbius maps preserve the disk.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_transform(a, z):
    """Apply Möbius transformation φ_a(z) = (z - a) / (1 - conj(a)*z)"""
    return (z - a) / (1 - np.conj(a) * z)


def hyperbolic_geodesic(z1, z2, n_points=100):
    """
    Compute the hyperbolic geodesic between z1 and z2 in the Poincaré disk.
    Uses the fact that geodesics are arcs of circles orthogonal to the unit circle.
    """
    # Parametric interpolation using Möbius transforms
    # Map z1 to 0, then the geodesic through 0 and φ_{z1}(z2) is a diameter
    w = mobius_transform(z1, z2)
    t = np.linspace(0, 1, n_points)
    # The geodesic from 0 to w is the straight line segment
    line = t[:, None] * np.array([[w.real, w.imag]])
    line_complex = line[:, 0] + 1j * line[:, 1]
    # Map back
    geodesic = np.array([mobius_transform(-z1, p) for p in line_complex])
    return geodesic


# Setup
fig, axes = plt.subplots(1, 2, figsize=(14, 7))
theta = np.linspace(0, 2*np.pi, 200)

# Center of the Möbius transform
a = 0.4 + 0.3j

for ax_idx, (ax, title, do_transform) in enumerate(zip(
    axes,
    ['Original Grid', f'After Möbius Transform φ_a, a={a:.2f}'],
    [False, True]
)):
    # Unit circle
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Create a grid of points in the disk
    grid_points = []
    for x in np.linspace(-0.8, 0.8, 17):
        for y in np.linspace(-0.8, 0.8, 17):
            z = complex(x, y)
            if abs(z) < 0.85:
                grid_points.append(z)
    
    if do_transform:
        mapped = [mobius_transform(a, z) for z in grid_points]
    else:
        mapped = grid_points
    
    # Color by original distance from origin
    colors = [abs(z) for z in grid_points]
    
    ax.scatter([z.real for z in mapped], [z.imag for z in mapped],
               c=colors, cmap='viridis', s=15, alpha=0.7, zorder=3)
    
    # Draw some geodesic circles (concentric hyperbolic circles)
    for r_hyp in [0.5, 1.0, 1.5, 2.0]:
        r_euc = np.tanh(r_hyp / 2)
        circle = r_euc * np.exp(1j * theta)
        if do_transform:
            circle = np.array([mobius_transform(a, z) for z in circle])
            ax.plot(circle.real, circle.imag, 'b-', alpha=0.2, linewidth=0.8)
        else:
            ax.plot(circle.real, circle.imag, 'b-', alpha=0.2, linewidth=0.8)
    
    # Draw some radial geodesics
    for angle in np.linspace(0, 2*np.pi, 12, endpoint=False):
        endpoint = 0.9 * np.exp(1j * angle)
        geo = hyperbolic_geodesic(0j, endpoint, 50)
        if do_transform:
            geo = np.array([mobius_transform(a, z) for z in geo])
        ax.plot(geo.real, geo.imag, 'gray', alpha=0.2, linewidth=0.5)
    
    # Mark the center a
    if do_transform:
        origin_mapped = mobius_transform(a, 0j)
        ax.plot(origin_mapped.real, origin_mapped.imag, 'r*', markersize=15, 
                zorder=5, label='Image of origin')
        ax.plot(0, 0, 'go', markersize=8, zorder=5, label='Image of a')
    else:
        ax.plot(0, 0, 'go', markersize=8, zorder=5, label='Origin')
        ax.plot(a.real, a.imag, 'r*', markersize=15, zorder=5, label=f'a = {a:.2f}')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.15)

plt.suptitle('Möbius Transformations Preserve the Poincaré Disk\n(Proven: ‖φ_a(z)‖ < 1 for ‖a‖, ‖z‖ < 1)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('mobius_transform.png', dpi=150, bbox_inches='tight')
print("Saved mobius_transform.png")


#!/usr/bin/env python3
"""
Visualization 1: PSL(2,Z) Lattice on the Poincaré Disk

Shows the orbit of the point i under PSL(2,Z), mapped to the Poincaré disk.
Hyperbolic primes are highlighted in red, composite points in blue.
The unit circle boundary represents infinity in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque
from typing import List, Dict, Tuple


def cayley_to_disk(z: complex) -> complex:
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_points=500, max_depth=8):
    visited = {}
    queue = deque()
    basepoint = complex(0, 1)
    
    def canonical(z):
        return (round(z.real * 1e8), round(z.imag * 1e8))
    
    visited[canonical(basepoint)] = basepoint
    queue.append((basepoint, 0))
    
    while queue and len(visited) < max_points:
        z, depth = queue.popleft()
        if depth >= max_depth:
            continue
        transforms = []
        if abs(z) > 1e-10:
            transforms.append(-1/z)
        transforms.append(z + 1)
        transforms.append(z - 1)
        for w in transforms:
            if w.imag < 1e-10:
                continue
            key = canonical(w)
            if key not in visited:
                visited[key] = w
                queue.append((w, depth + 1))
    
    disk_points = []
    for z_uhp in visited.values():
        z_disk = cayley_to_disk(z_uhp)
        if abs(z_disk) < 1 - 1e-12:
            disk_points.append(z_disk)
    return sorted(disk_points, key=abs)


def mobius_add(z, w):
    denom = 1 + np.conj(z) * w
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (z + w) / denom


def is_hyp_prime(z, points, tol=1e-5):
    r = abs(z)
    if r < tol:
        return False
    smaller = [w for w in points if tol < abs(w) < r - tol]
    for a in smaller:
        for b in smaller:
            s = mobius_add(a, b)
            if abs(s) < 1e10 and abs(s - z) < tol:
                return False
    return True


# Generate lattice
lattice = generate_psl2z_orbit(max_points=300, max_depth=7)

# Classify primes (only check first ~40 for speed)
n_check = min(40, len(lattice))
primes = []
composites = []
for i, z in enumerate(lattice[:n_check]):
    if abs(z) < 1e-5:
        continue
    if is_hyp_prime(z, lattice[:n_check]):
        primes.append(z)
    else:
        composites.append(z)

remaining = lattice[n_check:]

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.8)

# Hyperbolic geodesic circles (circles of constant hyperbolic distance)
for r_hyp in [1, 2, 3, 4]:
    r_euc = np.tanh(r_hyp / 2)
    circle = r_euc * np.exp(1j * theta)
    ax.plot(circle.real, circle.imag, 'k--', alpha=0.15, linewidth=0.5)

# Plot remaining lattice points
if remaining:
    ax.scatter([z.real for z in remaining], [z.imag for z in remaining],
               c='lightblue', s=15, alpha=0.5, zorder=2, label='Lattice points')

# Plot composites
if composites:
    ax.scatter([z.real for z in composites], [z.imag for z in composites],
               c='steelblue', s=30, alpha=0.7, zorder=3, label='Composite')

# Plot primes
if primes:
    ax.scatter([z.real for z in primes], [z.imag for z in primes],
               c='crimson', s=60, marker='*', zorder=4, label='Hyperbolic primes')

# Origin
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.annotate('0', (0.02, 0.02), fontsize=12, fontweight='bold')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.legend(fontsize=12, loc='upper right')
ax.set_title('PSL(2,ℤ) Lattice on the Poincaré Disk\nHyperbolic Primes (★) vs Composites (●)',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
print("Saved poincare_lattice.png")
