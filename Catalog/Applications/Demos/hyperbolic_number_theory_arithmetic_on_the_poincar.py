"""
Applications of Hyperbolic Number Theory
=========================================

Real-world applications connecting hyperbolic geometry to:
1. Network routing in hyperbolic space (Greedy embedding)
2. Cryptographic hash functions from Möbius transforms
3. Machine learning: hyperbolic embeddings for hierarchical data
"""

import math
from typing import List, Dict, Tuple


class DiskPoint:
    """Point in the Poincaré disk."""
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    @property
    def norm(self) -> float:
        return math.sqrt(self.x**2 + self.y**2)

    def hyp_dist_to(self, other: 'DiskPoint') -> float:
        """Hyperbolic distance via Möbius translation."""
        dx, dy = other.x - self.x, other.y - self.y
        denom = (1 - self.x*other.x - self.y*other.y)**2 + \
                (self.x*other.y - self.y*other.x)**2
        if denom < 1e-15:
            return 0.0
        ratio = (dx**2 + dy**2) / denom
        r = math.sqrt(max(0, ratio))
        if r >= 1.0:
            return float('inf')
        return math.log((1 + r) / (1 - r))


# === Application 1: Hyperbolic Network Routing ===

class HyperbolicNetwork:
    """
    Network where nodes are embedded in hyperbolic space.
    Greedy routing forwards to the neighbor closest to destination
    in hyperbolic distance. Guaranteed to succeed in tree-like topologies.
    """

    def __init__(self):
        self.nodes: Dict[str, DiskPoint] = {}
        self.edges: Dict[str, List[str]] = {}

    def add_node(self, name: str, pos: DiskPoint):
        self.nodes[name] = pos
        self.edges.setdefault(name, [])

    def add_edge(self, a: str, b: str):
        self.edges[a].append(b)
        self.edges[b].append(a)

    def greedy_route(self, src: str, dst: str, max_hops: int = 100) -> List[str]:
        """
        Greedy routing: at each step, forward to neighbor closest to dst.
        Returns path from src to dst.
        """
        path = [src]
        current = src
        for _ in range(max_hops):
            if current == dst:
                break
            neighbors = self.edges[current]
            dst_pos = self.nodes[dst]
            best = min(neighbors,
                      key=lambda n: self.nodes[n].hyp_dist_to(dst_pos))
            path.append(best)
            current = best
        return path


def demo_hyperbolic_routing():
    """Demo: Greedy routing on a tree embedded in the Poincaré disk."""
    print("=" * 60)
    print("Application 1: Hyperbolic Network Routing")
    print("=" * 60)

    net = HyperbolicNetwork()
    # Create a binary tree embedded in the disk
    net.add_node("root", DiskPoint(0, 0))
    net.add_node("L", DiskPoint(-0.4, 0))
    net.add_node("R", DiskPoint(0.4, 0))
    net.add_node("LL", DiskPoint(-0.6, -0.3))
    net.add_node("LR", DiskPoint(-0.2, -0.5))
    net.add_node("RL", DiskPoint(0.2, -0.5))
    net.add_node("RR", DiskPoint(0.6, -0.3))

    for parent, children in [("root", ["L", "R"]),
                              ("L", ["LL", "LR"]),
                              ("R", ["RL", "RR"])]:
        for c in children:
            net.add_edge(parent, c)

    path = net.greedy_route("LL", "RR")
    print(f"  Route LL → RR: {' → '.join(path)}")
    print(f"  Hops: {len(path) - 1}")

    path2 = net.greedy_route("LR", "RL")
    print(f"  Route LR → RL: {' → '.join(path2)}")
    print(f"  Hops: {len(path2) - 1}")
    print()


# === Application 2: Möbius Hash Function ===

def moebius_hash(data: bytes, a: DiskPoint) -> DiskPoint:
    """
    Hash bytes by iterated Möbius transformation.
    Each byte rotates and translates in the disk.

    NOT cryptographically secure — for demonstration only.
    """
    z = DiskPoint(0, 0)
    for byte in data:
        # Use byte to create a small perturbation
        angle = 2 * math.pi * byte / 256
        r = 0.3  # Fixed translation distance
        gen = DiskPoint(r * math.cos(angle), r * math.sin(angle))
        # Apply Möbius translation
        denom = (1 - gen.x*z.x - gen.y*z.y)**2 + (gen.x*z.y - gen.y*z.x)**2
        if denom < 1e-15:
            continue
        nx = ((z.x - gen.x)*(1 - gen.x*z.x - gen.y*z.y)
              + (z.y - gen.y)*(gen.x*z.y - gen.y*z.x)) / denom
        ny = ((z.y - gen.y)*(1 - gen.x*z.x - gen.y*z.y)
              - (z.x - gen.x)*(gen.x*z.y - gen.y*z.x)) / denom
        z = DiskPoint(nx, ny)
    return z


def demo_moebius_hash():
    """Demo: Hashing via Möbius transformations."""
    print("=" * 60)
    print("Application 2: Möbius Transform Hash (Demonstration)")
    print("=" * 60)

    a = DiskPoint(0.5, 0)
    test_strings = ["hello", "world", "hello!", "helln"]
    for s in test_strings:
        h = moebius_hash(s.encode(), a)
        print(f"  hash('{s}') = ({h.x:.8f}, {h.y:.8f}), "
              f"|h| = {h.norm:.6f}")
    print()


# === Application 3: Hierarchical Embeddings ===

def embed_tree_hyperbolic(adj: Dict[str, List[str]], root: str,
                          base_r: float = 0.5) -> Dict[str, DiskPoint]:
    """
    Embed a tree into the Poincaré disk with exponential separation.
    Children are placed at increasing hyperbolic distance from parent.

    Args:
        adj: Adjacency list
        root: Root node
        base_r: Base radius for children

    Returns:
        Dictionary mapping node names to disk positions.
    """
    positions: Dict[str, DiskPoint] = {}
    positions[root] = DiskPoint(0, 0)

    def place_children(node: str, parent_r: float, angle_start: float,
                       angle_span: float, depth: int):
        children = [c for c in adj.get(node, []) if c not in positions]
        if not children:
            return
        r = min(0.95, parent_r + (1 - parent_r) * 0.5)
        for i, child in enumerate(children):
            angle = angle_start + angle_span * (i + 0.5) / len(children)
            positions[child] = DiskPoint(r * math.cos(angle),
                                        r * math.sin(angle))
            place_children(child, r, angle - angle_span/(2*len(children)),
                          angle_span / len(children), depth + 1)

    place_children(root, 0, 0, 2 * math.pi, 0)
    return positions


def demo_hierarchical_embedding():
    """Demo: Embedding a taxonomy tree in hyperbolic space."""
    print("=" * 60)
    print("Application 3: Hierarchical Data in Hyperbolic Space")
    print("=" * 60)

    # A simple taxonomy
    taxonomy = {
        "Life": ["Animals", "Plants"],
        "Animals": ["Mammals", "Birds", "Fish"],
        "Mammals": ["Dogs", "Cats", "Whales"],
        "Plants": ["Trees", "Flowers"],
        "Birds": [], "Fish": [], "Dogs": [], "Cats": [],
        "Whales": [], "Trees": [], "Flowers": []
    }

    positions = embed_tree_hyperbolic(taxonomy, "Life")
    print("  Node positions in Poincaré disk:")
    for name, pos in sorted(positions.items()):
        print(f"    {name:10s}: ({pos.x:+.4f}, {pos.y:+.4f}), "
              f"hyp_norm = {math.log((1+pos.norm)/(1-pos.norm)) if pos.norm < 1 else float('inf'):.3f}")

    # Show that hierarchical distances are preserved
    print("\n  Hyperbolic distances reflect hierarchy:")
    pairs = [("Life", "Animals"), ("Life", "Dogs"),
             ("Animals", "Dogs"), ("Dogs", "Cats")]
    for a, b in pairs:
        d = positions[a].hyp_dist_to(positions[b])
        print(f"    d({a}, {b}) = {d:.3f}")
    print()


if __name__ == "__main__":
    demo_hyperbolic_routing()
    demo_moebius_hash()
    demo_hierarchical_embedding()


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================

Demonstrates key theorems with concrete numerical examples:
1. Möbius transformations preserve the disk
2. Hyperbolic norm and distance computations
3. Embedding natural numbers into hyperbolic space
4. Lattice point counting (Gauss circle problem connection)
"""

import math
from typing import Tuple

# --- Poincaré Disk Point ---

class DiskPoint:
    """A point in the Poincaré disk (x² + y² < 1)."""

    def __init__(self, x: float, y: float):
        assert x**2 + y**2 < 1.0, f"Point ({x}, {y}) not in unit disk"
        self.x = x
        self.y = y

    @property
    def norm_sq(self) -> float:
        return self.x**2 + self.y**2

    @property
    def euclidean_norm(self) -> float:
        return math.sqrt(self.norm_sq)

    @property
    def hyp_norm(self) -> float:
        """Hyperbolic distance from origin: log((1+|z|)/(1-|z|))."""
        r = self.euclidean_norm
        return math.log((1 + r) / (1 - r))

    def __repr__(self):
        return f"DiskPoint({self.x:.6f}, {self.y:.6f})"


# --- Möbius Transformation ---

def moebius_denom(a: DiskPoint, z: DiskPoint) -> float:
    """Denominator |1 - ā·z|² of Möbius transform T_a(z)."""
    return (1 - a.x*z.x - a.y*z.y)**2 + (a.x*z.y - a.y*z.x)**2

def moebius_numer(a: DiskPoint, z: DiskPoint) -> float:
    """Numerator |z - a|² of Möbius transform T_a(z)."""
    return (z.x - a.x)**2 + (z.y - a.y)**2

def moebius_apply(a: DiskPoint, z: DiskPoint) -> DiskPoint:
    """Apply Möbius translation T_a(z) = (z-a)/(1-āz)."""
    d = moebius_denom(a, z)
    rx = ((z.x - a.x)*(1 - a.x*z.x - a.y*z.y)
          + (z.y - a.y)*(a.x*z.y - a.y*z.x)) / d
    ry = ((z.y - a.y)*(1 - a.x*z.x - a.y*z.y)
          - (z.x - a.x)*(a.x*z.y - a.y*z.x)) / d
    return DiskPoint(rx, ry)


# --- Demo 1: Möbius Preservation ---

def demo_moebius_preservation():
    """Verify that Möbius transforms map disk to disk."""
    print("=" * 60)
    print("Demo 1: Möbius Transformations Preserve the Disk")
    print("=" * 60)

    test_cases = [
        (DiskPoint(0.5, 0.0), DiskPoint(0.3, 0.4)),
        (DiskPoint(0.1, 0.2), DiskPoint(-0.3, 0.6)),
        (DiskPoint(0.7, 0.3), DiskPoint(-0.5, -0.5)),
        (DiskPoint(0.9, 0.0), DiskPoint(0.0, 0.9)),
    ]

    for a, z in test_cases:
        numer = moebius_numer(a, z)
        denom = moebius_denom(a, z)
        result = moebius_apply(a, z)
        print(f"  a = {a}, z = {z}")
        print(f"    |z-a|²/|1-āz|² = {numer/denom:.6f} < 1 ✓")
        print(f"    T_a(z) = {result}, |T_a(z)| = {result.euclidean_norm:.6f}")
        assert result.norm_sq < 1.0
    print()


# --- Demo 2: Hyperbolic Norm ---

def demo_hyperbolic_norm():
    """Show hyperbolic norm vs Euclidean norm."""
    print("=" * 60)
    print("Demo 2: Hyperbolic Norm (distance from origin)")
    print("=" * 60)

    for r in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        p = DiskPoint(r, 0)
        print(f"  |p| = {r:.2f}  →  d_H(0, p) = {p.hyp_norm:.4f}")
    print(f"\n  Note: as |p| → 1, d_H → ∞ (hyperbolic space is infinite)")
    print()


# --- Demo 3: Embedding Natural Numbers ---

def demo_embedding():
    """Embed natural numbers into the disk and show ordering."""
    print("=" * 60)
    print("Demo 3: Embedding ℕ → Poincaré Disk")
    print("=" * 60)

    N = 10
    print(f"  Embedding n = 0..{N-1} into disk at x = (n+1)/(N+2)")
    prev_norm = -1
    for n in range(N):
        x = (n + 1) / (N + 2)
        p = DiskPoint(x, 0)
        print(f"    n={n}: x={x:.4f}, hyp_norm={p.hyp_norm:.4f}", end="")
        if p.hyp_norm > prev_norm:
            print(" ↑ (monotone ✓)")
        else:
            print(" ✗ NOT MONOTONE")
        prev_norm = p.hyp_norm
    print()


# --- Demo 4: Triangle Defect ---

def demo_triangle_defect():
    """Gauss-Bonnet: hyperbolic triangle area = π - angle_sum."""
    print("=" * 60)
    print("Demo 4: Hyperbolic Triangle Defect (Gauss-Bonnet)")
    print("=" * 60)

    pi = math.pi
    triangles = [
        (pi/4, pi/4, pi/4),   # Very deficient
        (pi/3, pi/3, pi/6),   # 5π/6 sum
        (pi/6, pi/6, pi/6),   # π/2 sum
        (0.01, 0.01, 0.01),   # Nearly ideal (large area)
    ]

    for a, b, c in triangles:
        defect = pi - (a + b + c)
        print(f"  angles = ({a:.3f}, {b:.3f}, {c:.3f})")
        print(f"    sum = {a+b+c:.4f} < π = {pi:.4f}")
        print(f"    area (defect) = {defect:.4f}")
        assert defect > 0
    print()


# --- Demo 5: Lattice Points (Gauss Circle) ---

def demo_lattice_counting():
    """Count lattice points in balls — connection to number theory."""
    print("=" * 60)
    print("Demo 5: Lattice Points in Ball (Gauss Circle Problem)")
    print("=" * 60)

    for R in range(1, 11):
        count = sum(1 for a in range(-R, R+1) for b in range(-R, R+1)
                    if a**2 + b**2 <= R**2)
        pi_approx = count / R**2
        print(f"  R={R:2d}: {count:4d} points, "
              f"count/R² = {pi_approx:.4f} (→ π = {math.pi:.4f})")
    print()


if __name__ == "__main__":
    demo_moebius_preservation()
    demo_hyperbolic_norm()
    demo_embedding()
    demo_triangle_defect()
    demo_lattice_counting()


"""
Visualization 2: Möbius Transformation Orbits and Hyperbolic Tessellation

Shows how Möbius transformations generate lattice-like structures in the
Poincaré disk, creating "hyperbolic integers" through orbit generation.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Helper functions (all self-contained) ---

def moebius_translate(ax, ay, zx, zy):
    """Apply Möbius translation T_a(z) = (z-a)/(1-āz)."""
    denom = (1 - ax*zx - ay*zy)**2 + (ax*zy - ay*zx)**2
    if denom < 1e-15:
        return zx, zy
    rx = ((zx - ax)*(1 - ax*zx - ay*zy) + (zy - ay)*(ax*zy - ay*zx)) / denom
    ry = ((zy - ay)*(1 - ax*zx - ay*zy) - (zx - ax)*(ax*zy - ay*zx)) / denom
    return rx, ry

def generate_orbit(generators, max_depth=5):
    """Generate orbit of origin under iterated Möbius translations."""
    points = [(0.0, 0.0)]
    current = [(0.0, 0.0)]
    seen = {(0, 0)}

    for _ in range(max_depth):
        next_layer = []
        for px, py in current:
            for gx, gy in generators:
                nx, ny = moebius_translate(gx, gy, px, py)
                key = (round(nx, 6), round(ny, 6))
                if key not in seen and nx**2 + ny**2 < 0.999:
                    seen.add(key)
                    points.append((nx, ny))
                    next_layer.append((nx, ny))
                # Also apply inverse
                nx2, ny2 = moebius_translate(-gx, -gy, px, py)
                key2 = (round(nx2, 6), round(ny2, 6))
                if key2 not in seen and nx2**2 + ny2**2 < 0.999:
                    seen.add(key2)
                    points.append((nx2, ny2))
                    next_layer.append((nx2, ny2))
        current = next_layer
    return points

# --- Left panel: Orbit of a single generator ---
ax = axes[0]
ax.set_aspect('equal')
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='blue')

# Single generator: translation along x-axis
gen = [(0.5, 0.0)]
orbit = generate_orbit(gen, max_depth=8)

xs = [p[0] for p in orbit]
ys = [p[1] for p in orbit]

# Color by hyperbolic distance from origin
hyp_norms = []
for x, y in orbit:
    r = np.sqrt(x**2 + y**2)
    if r < 0.9999:
        hyp_norms.append(np.log((1+r)/(1-r)))
    else:
        hyp_norms.append(10)

sc = ax.scatter(xs, ys, c=hyp_norms, cmap='plasma', s=20, zorder=5,
                edgecolors='black', linewidths=0.3)
plt.colorbar(sc, ax=ax, label='Hyperbolic distance from origin', shrink=0.8)
ax.plot(0, 0, 'r*', markersize=12, zorder=10)
ax.set_title('Orbit of Single Generator (r=0.5)', fontsize=12)
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)

# --- Right panel: Two generators (richer tessellation) ---
ax2 = axes[1]
ax2.set_aspect('equal')
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax2.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='green')

# Two generators: translations in different directions
angle1, angle2 = 0, 2*np.pi/3
r = 0.4
gens = [(r*np.cos(angle1), r*np.sin(angle1)),
        (r*np.cos(angle2), r*np.sin(angle2))]

orbit2 = generate_orbit(gens, max_depth=5)
xs2 = [p[0] for p in orbit2]
ys2 = [p[1] for p in orbit2]

hyp_norms2 = []
for x, y in orbit2:
    rr = np.sqrt(x**2 + y**2)
    if rr < 0.9999:
        hyp_norms2.append(np.log((1+rr)/(1-rr)))
    else:
        hyp_norms2.append(10)

sc2 = ax2.scatter(xs2, ys2, c=hyp_norms2, cmap='viridis', s=15, zorder=5,
                  edgecolors='black', linewidths=0.2)
plt.colorbar(sc2, ax=ax2, label='Hyperbolic distance from origin', shrink=0.8)
ax2.plot(0, 0, 'r*', markersize=12, zorder=10)
ax2.set_title(f'Orbit of 2 Generators ({len(orbit2)} points)', fontsize=12)
ax2.set_xlim(-1.1, 1.1)
ax2.set_ylim(-1.1, 1.1)

plt.tight_layout()
plt.savefig('viz_moebius_orbits.png', dpi=150, bbox_inches='tight')
plt.close()


"""
Visualization 1: The Poincaré Disk with Hyperbolic Geodesics and Lattice Points

Visualizes the Poincaré disk model of hyperbolic geometry:
- The unit disk boundary
- Hyperbolic geodesics (circular arcs orthogonal to boundary)
- Embedded natural numbers along the x-axis
- Concentric hyperbolic circles showing metric distortion
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Disk with geodesics and embedded integers ---
ax = axes[0]
ax.set_aspect('equal')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_title('Poincaré Disk: Integers in Curved Space', fontsize=13)

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')

# Draw concentric hyperbolic circles (loci of constant hyp distance)
for hyp_r in [0.5, 1.0, 1.5, 2.0, 3.0]:
    # Euclidean radius for given hyperbolic distance: r = tanh(d/2)
    euc_r = np.tanh(hyp_r / 2)
    circle = plt.Circle((0, 0), euc_r, fill=False, linestyle='--',
                        color='lightblue', alpha=0.7, linewidth=0.8)
    ax.add_patch(circle)
    ax.text(euc_r + 0.02, 0.02, f'd={hyp_r}', fontsize=7, color='steelblue')

# Embed integers 0-9 along x-axis
N = 10
colors = plt.cm.viridis(np.linspace(0.2, 0.9, N))
for n in range(N):
    x = (n + 1) / (N + 2)
    hyp_norm = np.log((1 + x) / (1 - x))
    ax.plot(x, 0, 'o', color=colors[n], markersize=8, zorder=5)
    ax.annotate(f'{n}', (x, 0), textcoords="offset points",
               xytext=(0, 10), ha='center', fontsize=8, color=colors[n])

# Draw a few hyperbolic geodesics (arcs of circles orthogonal to unit circle)
def draw_geodesic(ax, p1, p2, color='red', alpha=0.5):
    """Draw the hyperbolic geodesic between two disk points."""
    x1, y1 = p1
    x2, y2 = p2
    if abs(x1*y2 - x2*y1) < 1e-10:
        # Points are collinear with origin — geodesic is a diameter
        ax.plot([x1, x2], [y1, y2], '-', color=color, alpha=alpha, linewidth=1.5)
        return
    # Find circle through p1, p2 orthogonal to unit circle
    d1, d2 = x1**2 + y1**2, x2**2 + y2**2
    denom = 2*(x1*y2 - x2*y1)
    if abs(denom) < 1e-10:
        return
    cx = ((d1 - 1)*y2 - (d2 - 1)*y1) / denom
    cy = ((d2 - 1)*x1 - (d1 - 1)*x2) / denom
    cr = np.sqrt((x1 - cx)**2 + (y1 - cy)**2)

    # Draw arc
    a1 = np.arctan2(y1 - cy, x1 - cx)
    a2 = np.arctan2(y2 - cy, x2 - cx)
    if a2 < a1:
        a1, a2 = a2, a1
    if a2 - a1 > np.pi:
        a1, a2 = a2, a1 + 2*np.pi

    t = np.linspace(a1, a2, 100)
    ax.plot(cx + cr*np.cos(t), cy + cr*np.sin(t), '-',
            color=color, alpha=alpha, linewidth=1.5)

# Geodesics between some embedded integers
for i, j in [(0, 5), (2, 7), (1, 9), (3, 6)]:
    x1, x2 = (i+1)/(N+2), (j+1)/(N+2)
    draw_geodesic(ax, (x1, 0), (x2, 0.001), color='coral', alpha=0.4)

ax.plot(0, 0, 'k+', markersize=10, markeredgewidth=2)
ax.set_xlabel('x')
ax.set_ylabel('y')

# --- Right panel: Hyperbolic norm vs Euclidean norm ---
ax2 = axes[1]
r_vals = np.linspace(0, 0.999, 500)
hyp_norms = np.log((1 + r_vals) / (1 - r_vals))

ax2.plot(r_vals, hyp_norms, 'b-', linewidth=2, label=r'$d_H(0,p) = \ln\frac{1+|p|}{1-|p|}$')
ax2.plot(r_vals, 2*r_vals, 'r--', linewidth=1.5, alpha=0.7, label=r'$2|p|$ (Euclidean approx)')
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.axvline(x=1, color='gray', linewidth=0.5, linestyle=':')

# Mark embedded integers
for n in range(N):
    x = (n+1)/(N+2)
    hn = np.log((1+x)/(1-x))
    ax2.plot(x, hn, 'o', color=colors[n], markersize=6, zorder=5)

ax2.set_xlabel('Euclidean norm |p|')
ax2.set_ylabel('Hyperbolic norm $d_H(0, p)$')
ax2.set_title('Hyperbolic vs Euclidean Distance', fontsize=13)
ax2.set_ylim(0, 10)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()


"""
Visualization 3: Hyperbolic Prime Counting — The PNT on Curved Space

Compares:
- Classical prime counting π(n) vs n/ln(n)
- Lyndon word counting L(k,n) vs k^n/n (hyperbolic PNT analog)
- Lattice point counting in balls vs π·R² (Gauss circle problem)
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_function(m):
    """Compute the Möbius function μ(m)."""
    if m == 1:
        return 1
    factors = set()
    temp = m
    for p in range(2, int(np.sqrt(m)) + 2):
        if temp % p == 0:
            factors.add(p)
            temp //= p
            if temp % p == 0:
                return 0
    if temp > 1:
        factors.add(temp)
    return (-1) ** len(factors)

def count_lyndon(k, n):
    """Count Lyndon words of length n on k symbols via Witt's formula."""
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius_function(n // d) * k**d
    return total // n

def sieve_primes(N):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(np.sqrt(N)) + 1):
        if is_prime[i]:
            for j in range(i*i, N+1, i):
                is_prime[j] = False
    return [i for i in range(N+1) if is_prime[i]]

def lattice_count(R):
    """Count lattice points in disk of radius R."""
    count = 0
    for a in range(-R, R+1):
        for b in range(-R, R+1):
            if a*a + b*b <= R*R:
                count += 1
    return count


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Classical PNT ---
ax = axes[0]
primes = sieve_primes(200)
ns = np.arange(2, 201)
pi_n = np.array([sum(1 for p in primes if p <= n) for n in ns])
approx = ns / np.log(ns)

ax.plot(ns, pi_n, 'b-', linewidth=2, label=r'$\pi(n)$')
ax.plot(ns, approx, 'r--', linewidth=1.5, label=r'$n / \ln(n)$')
ax.fill_between(ns, pi_n, approx, alpha=0.1, color='purple')
ax.set_xlabel('n')
ax.set_ylabel('Count')
ax.set_title('Classical Prime Number Theorem', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 2: Hyperbolic PNT (Lyndon words) ---
ax2 = axes[1]
k = 2  # Binary alphabet
n_vals = np.arange(1, 25)
lyndon_counts = np.array([count_lyndon(k, n) for n in n_vals])
asymptotic = k**n_vals / n_vals

ax2.semilogy(n_vals, lyndon_counts, 'go-', markersize=6, linewidth=2,
             label=f'Lyndon words $L({k}, n)$')
ax2.semilogy(n_vals, asymptotic, 'r--', linewidth=1.5,
             label=f'${k}^n / n$')
ax2.set_xlabel('Word length n')
ax2.set_ylabel('Count (log scale)')
ax2.set_title('Hyperbolic PNT: Primitive Words', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the ratio
ratios = lyndon_counts / asymptotic
ax2_twin = ax2.twinx()
ax2_twin.plot(n_vals, ratios, 'b:', alpha=0.5, linewidth=1)
ax2_twin.set_ylabel('Ratio L(k,n) / (k^n/n)', color='blue', alpha=0.7)
ax2_twin.tick_params(axis='y', labelcolor='blue')
ax2_twin.set_ylim(0.5, 1.1)

# --- Panel 3: Gauss Circle Problem ---
ax3 = axes[2]
R_vals = np.arange(1, 51)
counts = np.array([lattice_count(R) for R in R_vals])
pi_R2 = np.pi * R_vals**2

ax3.plot(R_vals, counts, 'b-', linewidth=2, label=r'$|\{(a,b) : a^2+b^2 \leq R^2\}|$')
ax3.plot(R_vals, pi_R2, 'r--', linewidth=1.5, label=r'$\pi R^2$')
ax3.set_xlabel('Radius R')
ax3.set_ylabel('Count')
ax3.set_title('Lattice Points in Ball (Gauss Circle)', fontsize=12)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Inset: error term
ax3_inset = ax3.inset_axes([0.15, 0.55, 0.4, 0.35])
error = counts - pi_R2
ax3_inset.plot(R_vals, error, 'purple', linewidth=1.5)
ax3_inset.axhline(0, color='gray', linewidth=0.5)
ax3_inset.set_title('Error term', fontsize=8)
ax3_inset.set_xlabel('R', fontsize=7)
ax3_inset.tick_params(labelsize=7)

plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
plt.close()
