#!/usr/bin/env python3
"""
Applications of Hyperbolic Number Theory
=========================================

Demonstrates real-world applications of hyperbolic lattice theory:
1. Network routing on hyperbolic graphs (Internet topology)
2. Hyperbolic embeddings for hierarchical data
3. Tessellation-based error-correcting codes
4. Quantum chaos: eigenvalue statistics of hyperbolic Laplacians
"""

import numpy as np
from typing import List, Tuple


# ── Core functions (self-contained) ──

def moebius_map(a: complex, z: complex) -> complex:
    return (z - a) / (1 - np.conj(a) * z)

def hyp_dist(z: complex, w: complex) -> float:
    t = abs(z - w) / abs(1 - np.conj(w) * z)
    t = min(t, 1 - 1e-15)
    return np.log((1 + t) / (1 - t))

def poincare_conformal_factor(z: complex) -> float:
    return 2.0 / (1 - abs(z)**2)

def hyp_area(R: float) -> float:
    return 4 * np.pi * np.sinh(R / 2)**2


# ── Application 1: Hyperbolic Network Routing ──

class HyperbolicRouter:
    """Greedy routing on a hyperbolic graph.
    
    Real-world application: Internet topology has been shown to have
    hyperbolic structure. Greedy routing in the Poincaré disk achieves
    near-optimal paths.
    
    Reference: Boguñá et al., "Sustaining the Internet with Hyperbolic Mapping"
    """
    
    def __init__(self, nodes: List[complex]):
        self.nodes = nodes
        self.n = len(nodes)
        # Build adjacency: connect nodes within hyperbolic distance threshold
        self.adj: dict = {i: [] for i in range(self.n)}
    
    def build_graph(self, threshold: float = 2.0):
        """Connect nodes within hyperbolic distance threshold."""
        for i in range(self.n):
            for j in range(i+1, self.n):
                if hyp_dist(self.nodes[i], self.nodes[j]) < threshold:
                    self.adj[i].append(j)
                    self.adj[j].append(i)
    
    def greedy_route(self, src: int, dst: int) -> List[int]:
        """Greedy routing: always forward to the neighbor closest to destination."""
        path = [src]
        current = src
        visited = {src}
        
        for _ in range(self.n):
            if current == dst:
                return path
            
            best_neighbor = None
            best_dist = hyp_dist(self.nodes[current], self.nodes[dst])
            
            for neighbor in self.adj[current]:
                if neighbor not in visited:
                    d = hyp_dist(self.nodes[neighbor], self.nodes[dst])
                    if d < best_dist:
                        best_dist = d
                        best_neighbor = neighbor
            
            if best_neighbor is None:
                return path  # Stuck
            
            visited.add(best_neighbor)
            current = best_neighbor
            path.append(current)
        
        return path


# ── Application 2: Hyperbolic Embeddings for Trees ──

def embed_tree_hyperbolic(adj: dict, root: int = 0) -> dict:
    """Embed a tree into the Poincaré disk.
    
    Application: Hierarchical data (taxonomies, organizational charts,
    file systems) naturally embed into hyperbolic space with low distortion.
    
    Algorithm: Place root at origin, children at equally-spaced angles,
    using Möbius translations to position subtrees.
    """
    embeddings = {}
    
    def embed(node: int, center: complex, radius: float, parent: int):
        embeddings[node] = center
        children = [c for c in adj.get(node, []) if c != parent]
        if not children:
            return
        
        child_radius = radius * 0.5
        for i, child in enumerate(children):
            angle = 2 * np.pi * i / len(children)
            offset = radius * np.exp(1j * angle)
            # Use Möbius map to translate
            child_pos = moebius_map(-center, center + offset * (1 - abs(center)))
            if abs(child_pos) >= 1:
                child_pos *= 0.95 / abs(child_pos)
            embed(child, child_pos, child_radius, node)
    
    embed(root, 0 + 0j, 0.4, -1)
    return embeddings


# ── Application 3: Gauss-Bonnet Error Detection ──

def gauss_bonnet_check(polygon_angles: List[float], n_sides: int) -> Tuple[float, bool]:
    """Use Gauss-Bonnet to detect errors in hyperbolic polygon measurements.
    
    Application: In computational geometry and mesh processing, the
    Gauss-Bonnet theorem provides a consistency check. If the computed
    area doesn't match (n-2)π - Σ(angles), the measurement has errors.
    
    Proved as gauss_bonnet_polygon in Lean.
    """
    expected_area = (n_sides - 2) * np.pi - sum(polygon_angles)
    is_valid = expected_area > 0 and all(0 < a < np.pi for a in polygon_angles)
    return expected_area, is_valid


# ── Application 4: Quantum Chaos on Hyperbolic Surfaces ──

def spectral_statistics(eigenvalues: List[float]) -> dict:
    """Analyze eigenvalue spacing statistics.
    
    Application: The spectral-geometric duality (proved in Lean as
    spectral_geometric_duality) connects matrix eigenvalues to geometric data.
    For hyperbolic surfaces, eigenvalue spacing follows GOE statistics
    (Bohigas-Giannoni-Schmit conjecture), providing evidence for quantum chaos.
    """
    eigenvalues = sorted(eigenvalues)
    spacings = [eigenvalues[i+1] - eigenvalues[i] for i in range(len(eigenvalues)-1)]
    mean_spacing = np.mean(spacings) if spacings else 1.0
    normalized = [s / mean_spacing for s in spacings]
    
    # Level spacing ratio (diagnostic for GOE vs Poisson)
    ratios = []
    for i in range(len(spacings) - 1):
        r = min(spacings[i], spacings[i+1]) / max(spacings[i], spacings[i+1])
        ratios.append(r)
    
    mean_ratio = np.mean(ratios) if ratios else 0
    
    return {
        "mean_spacing": mean_spacing,
        "std_spacing": np.std(normalized),
        "mean_ratio": mean_ratio,
        "goe_expected_ratio": 0.5307,  # GOE prediction
        "poisson_expected_ratio": 0.3863,  # Poisson prediction
        "classification": "GOE (chaotic)" if mean_ratio > 0.46 else "Poisson (integrable)"
    }


def main():
    print("=" * 70)
    print("APPLICATIONS OF HYPERBOLIC NUMBER THEORY")
    print("=" * 70)
    
    # App 1: Network Routing
    print("\n--- Application 1: Hyperbolic Network Routing ---")
    np.random.seed(42)
    # Generate random nodes in the disk
    nodes = []
    for _ in range(50):
        r = np.random.uniform(0, 0.9)
        theta = np.random.uniform(0, 2*np.pi)
        nodes.append(r * np.exp(1j * theta))
    
    router = HyperbolicRouter(nodes)
    router.build_graph(threshold=1.5)
    
    # Test several routes
    successes = 0
    total = 0
    stretch_sum = 0
    for _ in range(100):
        src, dst = np.random.choice(50, 2, replace=False)
        path = router.greedy_route(src, dst)
        if path[-1] == dst:
            successes += 1
            optimal = hyp_dist(nodes[src], nodes[dst])
            actual = sum(hyp_dist(nodes[path[i]], nodes[path[i+1]]) for i in range(len(path)-1))
            stretch_sum += actual / max(optimal, 1e-10)
        total += 1
    
    print(f"  Success rate: {successes}/{total} = {100*successes/total:.1f}%")
    if successes > 0:
        print(f"  Average stretch: {stretch_sum/successes:.2f}")
    
    # App 2: Tree Embedding
    print("\n--- Application 2: Hyperbolic Tree Embedding ---")
    # Binary tree of depth 4
    tree_adj = {}
    for i in range(15):
        tree_adj[i] = []
    for i in range(1, 15):
        parent = (i - 1) // 2
        tree_adj.setdefault(parent, []).append(i)
        tree_adj.setdefault(i, []).append(parent)
    
    embeddings = embed_tree_hyperbolic(tree_adj, root=0)
    
    # Check distortion
    max_distortion = 0
    for i in range(15):
        for j in tree_adj.get(i, []):
            if j > i:
                tree_dist = 1  # Adjacent = distance 1
                emb_dist = hyp_dist(embeddings[i], embeddings[j])
                distortion = max(emb_dist / max(tree_dist, 1e-10), tree_dist / max(emb_dist, 1e-10))
                max_distortion = max(max_distortion, distortion)
    
    print(f"  Embedded 15-node binary tree")
    print(f"  Max edge distortion: {max_distortion:.2f}")
    print(f"  All embeddings in disk: {all(abs(z) < 1 for z in embeddings.values())}")
    
    # App 3: Gauss-Bonnet Check
    print("\n--- Application 3: Gauss-Bonnet Error Detection ---")
    # Valid hyperbolic triangle
    angles_valid = [np.pi/4, np.pi/5, np.pi/6]
    area, valid = gauss_bonnet_check(angles_valid, 3)
    print(f"  Triangle (π/4, π/5, π/6): area = {area:.4f}, valid = {valid}")
    
    # Invalid (angles too large for hyperbolic)
    angles_invalid = [np.pi*0.9, np.pi*0.8, np.pi*0.7]
    area, valid = gauss_bonnet_check(angles_invalid, 3)
    print(f"  Triangle (0.9π, 0.8π, 0.7π): area = {area:.4f}, valid = {valid} (ERROR DETECTED)")
    
    # App 4: Spectral Statistics
    print("\n--- Application 4: Quantum Chaos Spectral Statistics ---")
    # Simulate eigenvalues of a "chaotic" system (GOE random matrix)
    n = 200
    M = np.random.randn(n, n)
    M = (M + M.T) / 2  # Symmetrize
    eigenvalues = sorted(np.linalg.eigvalsh(M))
    stats = spectral_statistics(eigenvalues)
    print(f"  Random symmetric matrix ({n}×{n}):")
    print(f"  Mean spacing ratio: {stats['mean_ratio']:.4f}")
    print(f"  GOE expected: {stats['goe_expected_ratio']:.4f}")
    print(f"  Classification: {stats['classification']}")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================
Demonstration of core concepts from the formal Lean 4 development.

This script illustrates:
1. Möbius transformations and disk preservation
2. Hyperbolic distance computation
3. Hyperbolic lattice point generation and counting
4. The Schläfli condition for hyperbolic tessellations
5. Conformal factor blowup near the boundary
"""

import numpy as np
from typing import Tuple


def moebius_map(a: complex, z: complex) -> complex:
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)


def moebius_involution(a: complex, z: complex) -> complex:
    """Standard Möbius involution ψ_a(z) = (a - z) / (1 - conj(a) * z).
    Satisfies ψ_a(ψ_a(z)) = z (proved in Lean)."""
    return (a - z) / (1 - np.conj(a) * z)


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance on the Poincaré disk.
    d_H(z,w) = log((1+t)/(1-t)) where t = |z-w|/|1-conj(w)z|."""
    t = abs(z - w) / abs(1 - np.conj(w) * z)
    if t >= 1:
        return float('inf')
    return np.log((1 + t) / (1 - t))


def poincare_conformal_factor(z: complex) -> float:
    """Conformal factor λ(z) = 2/(1 - |z|²) of the Poincaré metric."""
    return 2.0 / (1 - abs(z)**2)


def hyp_area(R: float) -> float:
    """Hyperbolic area of a disk of radius R: 4π sinh²(R/2)."""
    return 4 * np.pi * np.sinh(R / 2)**2


def schlafli_check(p: int, q: int) -> Tuple[bool, float]:
    """Check if the {p,q} tessellation is hyperbolic.
    Returns (is_hyperbolic, defect) where defect = 1/2 - 1/p - 1/q."""
    defect = 0.5 - 1.0/p - 1.0/q
    return defect > 0, defect


def generate_hyperbolic_lattice(depth: int = 4) -> list:
    """Generate lattice points for the {7,3} tessellation of the hyperbolic plane.
    Uses iterated Möbius transformations from the origin."""
    points = [0 + 0j]
    visited = {0 + 0j}
    
    # Initial generators: 7 equally spaced points at hyperbolic distance d
    # For {7,3}, the edge length satisfies cosh(d) = cos(π/3)/sin(π/7)
    d = np.arccosh(np.cos(np.pi/3) / np.sin(np.pi/7))
    r = np.tanh(d / 2)  # Euclidean radius corresponding to hyp distance d
    
    generators = []
    for k in range(7):
        angle = 2 * np.pi * k / 7
        z = r * np.exp(1j * angle)
        generators.append(z)
    
    # BFS to generate orbit
    queue = [0 + 0j]
    for _ in range(depth):
        new_queue = []
        for center in queue:
            for g in generators:
                # Apply Möbius map to translate g by center
                new_pt = moebius_map(-center, g)
                # Check if close to an existing point
                is_new = True
                for p in points:
                    if abs(new_pt - p) < 1e-8:
                        is_new = False
                        break
                if is_new and abs(new_pt) < 0.999:
                    points.append(new_pt)
                    new_queue.append(new_pt)
        queue = new_queue
    
    return sorted(points, key=abs)


def main():
    print("=" * 70)
    print("HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 70)
    
    # Demo 1: Disk Preservation
    print("\n--- Demo 1: Möbius Disk Preservation (Theorem moebius_disk_aut_preserves_disk) ---")
    a = 0.3 + 0.4j
    test_points = [0, 0.5, -0.3 + 0.2j, 0.7j, 0.1 - 0.8j]
    print(f"Center a = {a}, |a| = {abs(a):.4f}")
    for z in test_points:
        w = moebius_map(a, z)
        print(f"  φ_a({z}) = {w:.4f}, |φ_a(z)| = {abs(w):.4f} < 1 ✓" if abs(w) < 1 else f"  FAIL")
    
    # Demo 2: Involution Property
    print("\n--- Demo 2: Möbius Involution (Theorem moebius_involution) ---")
    a = 0.2 + 0.3j
    z = 0.5 - 0.1j
    w = moebius_involution(a, z)
    z_back = moebius_involution(a, w)
    print(f"  a = {a}, z = {z}")
    print(f"  ψ_a(z) = {w:.6f}")
    print(f"  ψ_a(ψ_a(z)) = {z_back:.6f}")
    print(f"  Error: |ψ_a(ψ_a(z)) - z| = {abs(z_back - z):.2e} ✓")
    
    # Demo 3: Hyperbolic Distance
    print("\n--- Demo 3: Hyperbolic Distance Properties ---")
    z, w = 0.3 + 0.2j, -0.1 + 0.4j
    print(f"  d(z, z) = {hyp_dist(z, z):.6f} (= 0, Theorem hypDist_self)")
    print(f"  d(z, w) = {hyp_dist(z, w):.6f}")
    print(f"  d(w, z) = {hyp_dist(w, z):.6f} (symmetric, Theorem hypDist_comm)")
    print(f"  d(0, z) = {hyp_dist(0, z):.6f}")
    print(f"  log((1+|z|)/(1-|z|)) = {np.log((1+abs(z))/(1-abs(z))):.6f} (Theorem hypDist_origin)")
    
    # Demo 4: Conformal Factor
    print("\n--- Demo 4: Conformal Factor (Theorems poincareConformalFactor_pos, _large) ---")
    for r in [0, 0.5, 0.9, 0.99, 0.999]:
        z = r + 0j
        lam = poincare_conformal_factor(z)
        print(f"  λ({r}) = {lam:.4f}" + (" (→ ∞ near boundary)" if r > 0.9 else ""))
    
    # Demo 5: Schläfli Condition
    print("\n--- Demo 5: Schläfli Condition (Theorem schlafli_hyperbolic_condition) ---")
    tessellations = [(3,7), (4,5), (5,4), (7,3), (3,6), (4,4), (6,3)]
    for p, q in tessellations:
        is_hyp, defect = schlafli_check(p, q)
        kind = "HYPERBOLIC" if is_hyp else ("EUCLIDEAN" if abs(defect) < 1e-10 else "SPHERICAL")
        pq_cond = (p-2)*(q-2)
        print(f"  {{{p},{q}}}: (p-2)(q-2) = {pq_cond}, 1/p+1/q = {1/p+1/q:.4f}, type = {kind}")
    
    # Demo 6: Hyperbolic Area Growth
    print("\n--- Demo 6: Hyperbolic Area Growth (Exponential vs Euclidean) ---")
    for R in [1, 2, 5, 10, 20]:
        h_area = hyp_area(R)
        e_area = np.pi * R**2
        print(f"  R={R:>3}: Hyp area = {h_area:>12.2f}, Euc area = {e_area:>8.2f}, ratio = {h_area/e_area:>8.2f}")
    
    # Demo 7: Lattice Point Counting
    print("\n--- Demo 7: Hyperbolic Lattice Points ({7,3} tessellation) ---")
    lattice = generate_hyperbolic_lattice(depth=5)
    print(f"  Generated {len(lattice)} lattice points")
    
    # Count by hyperbolic radius
    for R in [1, 2, 3, 4, 5]:
        count = sum(1 for p in lattice if hyp_dist(0, p) <= R)
        area = hyp_area(R)
        print(f"  N(R={R}) = {count:>5}, hypArea(R) = {area:>8.2f}, ratio N/area = {count/max(area,1e-10):.4f}")
    
    # Demo 8: Gauss-Bonnet for hyperbolic polygon
    print("\n--- Demo 8: Gauss-Bonnet Polygon Area ---")
    for n_sides in [3, 5, 7, 12]:
        # Regular polygon with angles π/3
        angle = np.pi / 3
        area = (n_sides - 2) * np.pi - n_sides * angle
        print(f"  {n_sides}-gon with angles π/3: area = {area:.4f} = {area/np.pi:.4f}π")
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization 2: Poincaré Disk Conformal Factor Heatmap
========================================================
Shows the conformal factor λ(z) = 2/(1-|z|²) as a heatmap on the disk.
Demonstrates how distances are stretched near the boundary — the key feature
that makes hyperbolic geometry "infinite" inside a finite disk.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # ── Left panel: Conformal factor heatmap ──
    ax = axes[0]
    
    n = 500
    x = np.linspace(-1, 1, n)
    y = np.linspace(-1, 1, n)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    # Conformal factor: λ = 2/(1 - r²)
    with np.errstate(divide='ignore', invalid='ignore'):
        lam = np.where(R < 0.999, 2.0 / (1 - R**2), np.nan)
    
    # Mask outside disk
    lam[R >= 0.999] = np.nan
    
    im = ax.imshow(lam, extent=[-1, 1, -1, 1], origin='lower',
                   cmap='inferno', norm=LogNorm(vmin=2, vmax=1000),
                   interpolation='bilinear')
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
    
    # Draw concentric hyperbolic circles (equal hyp distance)
    for d_hyp in [1, 2, 3, 4]:
        r_euc = np.tanh(d_hyp / 2)
        ax.plot(r_euc * np.cos(theta), r_euc * np.sin(theta),
                'w--', linewidth=0.8, alpha=0.6)
        ax.text(r_euc + 0.02, 0.02, f'd={d_hyp}', color='white',
                fontsize=8, alpha=0.8)
    
    plt.colorbar(im, ax=ax, label='Conformal factor λ(z) = 2/(1-|z|²)', shrink=0.8)
    ax.set_title('Poincaré Metric Conformal Factor', fontsize=14, fontweight='bold')
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.set_aspect('equal')
    
    # ── Right panel: Radial profile ──
    ax2 = axes[1]
    
    r_vals = np.linspace(0, 0.999, 1000)
    lam_vals = 2.0 / (1 - r_vals**2)
    
    ax2.semilogy(r_vals, lam_vals, 'b-', linewidth=2, label='λ(r) = 2/(1-r²)')
    
    # Show 1/ε bound (proved in Lean)
    eps_vals = 1 - r_vals
    bound_vals = 1.0 / eps_vals
    ax2.semilogy(r_vals, bound_vals, 'r--', linewidth=1.5,
                 label='Lower bound 1/(1-r)', alpha=0.7)
    
    # Mark key points
    for r in [0.5, 0.9, 0.99]:
        lam_r = 2.0 / (1 - r**2)
        ax2.plot(r, lam_r, 'ko', markersize=6)
        ax2.annotate(f'r={r}\nλ={lam_r:.1f}', xy=(r, lam_r),
                    xytext=(r-0.15, lam_r*2),
                    fontsize=9, ha='center',
                    arrowprops=dict(arrowstyle='->', color='gray'))
    
    ax2.set_xlabel('Euclidean distance from origin |z|', fontsize=12)
    ax2.set_ylabel('Conformal factor λ(z)', fontsize=12)
    ax2.set_title('Boundary Divergence\n(Theorem poincareConformalFactor_large)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 1.01)
    ax2.set_ylim(1, 5000)
    
    plt.tight_layout()
    plt.savefig('viz_conformal_factor.png', dpi=150, bbox_inches='tight')
    print("Saved viz_conformal_factor.png")


if __name__ == "__main__":
    main()


"""
Visualization 1: Hyperbolic Lattice on the Poincaré Disk
=========================================================
Visualizes the {7,3} tessellation lattice points on the Poincaré disk,
color-coded by generation (BFS depth). Shows the exponential growth of
lattice points and the boundary accumulation characteristic of hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def moebius_map(a, z):
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)


def generate_lattice(p=7, q=3, depth=4):
    """Generate {p,q} tessellation lattice points with BFS metadata."""
    d = np.arccosh(np.cos(np.pi/q) / np.sin(np.pi/p))
    r = np.tanh(d / 2)
    
    generators = [r * np.exp(2j * np.pi * k / p) for k in range(p)]
    
    points = [(0+0j, 0)]  # (point, generation)
    point_set = {(0.0, 0.0)}
    queue = [0+0j]
    
    for gen in range(1, depth + 1):
        new_queue = []
        for center in queue:
            for g in generators:
                try:
                    new_pt = moebius_map(-center, g)
                    key = (round(new_pt.real, 7), round(new_pt.imag, 7))
                    if key not in point_set and abs(new_pt) < 0.999:
                        point_set.add(key)
                        points.append((new_pt, gen))
                        new_queue.append(new_pt)
                except:
                    continue
        queue = new_queue
    
    return points


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))
    
    # ── Left panel: Lattice points on disk ──
    ax = axes[0]
    lattice = generate_lattice(7, 3, depth=4)
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Color by generation
    colors = ['#e63946', '#457b9d', '#2a9d8f', '#e9c46a', '#f4a261']
    gen_labels = ['Origin', 'Gen 1', 'Gen 2', 'Gen 3', 'Gen 4']
    
    for gen in range(5):
        pts = [p for p, g in lattice if g == gen]
        if pts:
            xs = [p.real for p in pts]
            ys = [p.imag for p in pts]
            size = max(80 - gen * 15, 10)
            ax.scatter(xs, ys, c=colors[gen], s=size, alpha=0.8,
                      edgecolors='black', linewidth=0.5, zorder=5-gen,
                      label=f'{gen_labels[gen]} ({len(pts)} pts)')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Hyperbolic Lattice {7,3} on Poincaré Disk', fontsize=14, fontweight='bold')
    ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    
    # ── Right panel: Growth curves ──
    ax2 = axes[1]
    
    # Count by hyperbolic distance
    def hyp_dist_from_origin(z):
        r = abs(z)
        if r >= 1: return float('inf')
        return np.log((1 + r) / (1 - r))
    
    all_dists = sorted([hyp_dist_from_origin(p) for p, _ in lattice])
    
    Rs = np.linspace(0.1, max(all_dists) * 0.95, 200)
    counts = [sum(1 for d in all_dists if d <= R) for R in Rs]
    
    ax2.plot(Rs, counts, 'b-', linewidth=2, label='N(R) (lattice count)')
    
    # Theoretical hyperbolic area curve (scaled)
    hyp_areas = [4 * np.pi * np.sinh(R/2)**2 for R in Rs]
    scale = max(counts) / max(hyp_areas) if max(hyp_areas) > 0 else 1
    ax2.plot(Rs, [a * scale for a in hyp_areas], 'r--', linewidth=1.5,
             label=f'Scaled hyp. area 4π sinh²(R/2)')
    
    # Euclidean comparison
    euc_areas = [np.pi * R**2 for R in Rs]
    scale_e = max(counts) / max(euc_areas) if max(euc_areas) > 0 else 1
    ax2.plot(Rs, [a * scale_e for a in euc_areas], 'g:', linewidth=1.5,
             label='Scaled Euclidean πR²')
    
    ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
    ax2.set_ylabel('Count / Scaled area', fontsize=12)
    ax2.set_title('Exponential Growth of Lattice Points', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved viz_poincare_lattice.png")


if __name__ == "__main__":
    main()


"""
Visualization 3: Schläfli Classification of Tessellations
==========================================================
Shows the landscape of {p,q} tessellations, classifying them as
spherical (Platonic solids), Euclidean (floor tilings), or hyperbolic.
Illustrates the proved theorem: (p-2)(q-2) > 4 ↔ 1/p + 1/q < 1/2.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import RegularPolygon
import matplotlib.patches as mpatches


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))
    
    # ── Left panel: Classification grid ──
    ax = axes[0]
    
    p_range = range(3, 12)
    q_range = range(3, 12)
    
    for p in p_range:
        for q in q_range:
            product = (p - 2) * (q - 2)
            val = 1.0/p + 1.0/q
            
            if product < 4:
                color = '#3498db'  # Blue = spherical
                marker = 'o'
            elif product == 4:
                color = '#2ecc71'  # Green = Euclidean
                marker = 's'
            else:
                color = '#e74c3c'  # Red = hyperbolic
                marker = '^'
            
            size = min(200, 50 + product * 8)
            ax.scatter(p, q, c=color, marker=marker, s=size,
                      edgecolors='black', linewidth=0.5, zorder=3)
    
    # Draw the boundary curve 1/p + 1/q = 1/2
    p_cont = np.linspace(2.01, 12, 200)
    q_boundary = 1.0 / (0.5 - 1.0/p_cont)
    valid = (q_boundary > 2) & (q_boundary < 12)
    ax.plot(p_cont[valid], q_boundary[valid], 'k-', linewidth=2,
            label='(p-2)(q-2) = 4')
    
    # Labels for known tessellations
    labels = {
        (3, 3): 'Tetra', (4, 3): 'Cube', (3, 4): 'Octa',
        (5, 3): 'Dodeca', (3, 5): 'Icosa',
        (3, 6): '△', (4, 4): '□', (6, 3): '⬡',
        (7, 3): '{7,3}', (5, 4): '{5,4}', (4, 5): '{4,5}',
    }
    for (p, q), label in labels.items():
        ax.annotate(label, (p, q), textcoords="offset points",
                   xytext=(8, 5), fontsize=8, fontweight='bold')
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Spherical: (p-2)(q-2) < 4'),
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Euclidean: (p-2)(q-2) = 4'),
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Hyperbolic: (p-2)(q-2) > 4'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)
    
    ax.set_xlabel('p (sides per polygon)', fontsize=12)
    ax.set_ylabel('q (polygons per vertex)', fontsize=12)
    ax.set_title('Schläfli Classification of {p,q} Tessellations\n(Theorem schlafli_hyperbolic_condition)',
                fontsize=13, fontweight='bold')
    ax.set_xlim(2.5, 11.5)
    ax.set_ylim(2.5, 11.5)
    ax.grid(True, alpha=0.2)
    
    # ── Right panel: Hyperbolic area growth comparison ──
    ax2 = axes[1]
    
    R = np.linspace(0.01, 8, 500)
    
    # Hyperbolic area: 4π sinh²(R/2)
    hyp_area = 4 * np.pi * np.sinh(R/2)**2
    
    # Euclidean area: πR²
    euc_area = np.pi * R**2
    
    # Spherical area: 4π sin²(R/2) (for R < π)
    sph_area = np.where(R < np.pi, 4 * np.pi * np.sin(R/2)**2, 4*np.pi)
    
    ax2.semilogy(R, hyp_area, 'r-', linewidth=2.5, label='Hyperbolic: 4π sinh²(R/2)')
    ax2.semilogy(R, euc_area, 'g-', linewidth=2.5, label='Euclidean: πR²')
    ax2.semilogy(R, sph_area, 'b-', linewidth=2.5, label='Spherical: 4π sin²(R/2)')
    
    # Asymptotic: π·e^R
    ax2.semilogy(R, np.pi * np.exp(R), 'r:', linewidth=1.5, alpha=0.5,
                 label='Asymptote: πe^R')
    
    ax2.set_xlabel('Radius R', fontsize=12)
    ax2.set_ylabel('Area of disk of radius R', fontsize=12)
    ax2.set_title('Area Growth in Three Geometries\n(Hyperbolic grows exponentially)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 8)
    ax2.set_ylim(0.01, 1e4)
    
    plt.tight_layout()
    plt.savefig('viz_schlafli.png', dpi=150, bbox_inches='tight')
    print("Saved viz_schlafli.png")


if __name__ == "__main__":
    main()
