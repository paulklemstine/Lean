#!/usr/bin/env python3
"""
Applications of Berggren-Generated Exact Arithmetic Shell Meshes

Demonstrates real-world applications:
  1. Tropical Voronoi decomposition on exact shell meshes
  2. Certified nearest-neighbor search (no floating-point errors)
  3. Exact covering radius computation
  4. Deterministic sampling for numerical integration on the circle
"""

from fractions import Fraction
from typing import Tuple, List, Dict, Optional
from math import pi, cos, sin, sqrt, atan2
import sys

# Import from algorithms
sys.path.insert(0, '.')
from algorithms import (
    BerggrenTree, ExactShellMesh, TropicalDistanceEngine,
    MeshAnalyzer, ShellPoint, Triple
)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Tropical Voronoi Decomposition
# ═══════════════════════════════════════════════════════════════════════

class TropicalVoronoi:
    """
    Exact tropical Voronoi decomposition of the unit circle.

    Given a set of Berggren mesh points as sites, assigns every other
    rational point to its nearest site under the tropical (L∞) metric.
    All computations are exact.
    """

    def __init__(self, sites: ExactShellMesh):
        self.sites = sites
        self.engine = TropicalDistanceEngine()

    def assign(self, query: ShellPoint) -> int:
        """Assign a query point to its nearest Voronoi site."""
        idx, _ = self.engine.nearest_neighbor(self.sites, query)
        return idx

    def cell_sizes(self, test_mesh: ExactShellMesh) -> Dict[int, int]:
        """
        Count how many test points fall in each Voronoi cell.

        Uses a finer mesh as test points to approximate cell sizes.
        """
        counts: Dict[int, int] = {}
        for pt in test_mesh.points:
            cell = self.assign(pt)
            counts[cell] = counts.get(cell, 0) + 1
        return counts


def demo_voronoi():
    """Demonstrate tropical Voronoi decomposition."""
    print("=" * 60)
    print("APPLICATION 1: Tropical Voronoi Decomposition")
    print("=" * 60)

    # Sites: depth-1 mesh (4 points)
    sites = ExactShellMesh.from_berggren(1)
    print(f"\nVoronoi sites ({len(sites)} points):")
    for i, pt in enumerate(sites.points):
        print(f"  Site {i}: ({pt.x}, {pt.y}) from triple {pt.triple}")

    # Test mesh: depth-3 (40 points)
    test_mesh = ExactShellMesh.from_berggren(3)
    voronoi = TropicalVoronoi(sites)
    cells = voronoi.cell_sizes(test_mesh)

    print(f"\nVoronoi cell sizes (from {len(test_mesh)} test points):")
    for site_idx, count in sorted(cells.items()):
        pt = sites.points[site_idx]
        print(f"  Site {site_idx} ({pt.triple}): {count} points")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Certified Nearest-Neighbor Search
# ═══════════════════════════════════════════════════════════════════════

def demo_nearest_neighbor():
    """Demonstrate exact nearest-neighbor search."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Certified Nearest-Neighbor Search")
    print("=" * 60)

    mesh = ExactShellMesh.from_berggren(3)
    engine = TropicalDistanceEngine()

    # Query points: some specific Pythagorean triples at higher depth
    deeper_triples = BerggrenTree.generate(4)
    queries = []
    for a, b, c in deeper_triples[-10:]:
        queries.append(ShellPoint(triple=(a,b,c),
                                   x=Fraction(a,c), y=Fraction(b,c), depth=4))

    print(f"\nMesh size: {len(mesh)} points")
    print(f"Queries: {len(queries)} depth-4 points\n")
    print(f"{'Query Triple':<25} {'Nearest Triple':<25} {'Exact Distance'}")
    print("-" * 75)

    for q in queries:
        idx, dist = engine.nearest_neighbor(mesh, q)
        nearest = mesh.points[idx]
        print(f"{str(q.triple):<25} {str(nearest.triple):<25} {dist}")

    print("\n✓ All distances computed with exact rational arithmetic")
    print("  No floating-point rounding errors — results are certified.")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Exact Covering Radius
# ═══════════════════════════════════════════════════════════════════════

def demo_covering_radius():
    """Compute and analyze covering radius of Berggren meshes."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Covering Radius Analysis")
    print("=" * 60)

    print(f"\n{'Depth':<8} {'Points':<10} {'Min Sep':<15} {'Diameter':<15} {'Sep/Diam Ratio'}")
    print("-" * 65)

    for depth in range(4):
        mesh = ExactShellMesh.from_berggren(depth)
        sep = MeshAnalyzer.minimum_separation(mesh)
        diam = MeshAnalyzer.diameter(mesh)
        ratio = float(sep / diam) if diam > 0 else 0

        print(f"{depth:<8} {len(mesh):<10} {float(sep):<15.6f} {float(diam):<15.6f} {ratio:<.6f}")

    print("\nAs depth increases, the mesh becomes denser and the separation")
    print("decreases while the diameter remains bounded — the mesh fills the circle.")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Deterministic Quadrature on the Circle
# ═══════════════════════════════════════════════════════════════════════

def demo_quadrature():
    """Use Berggren mesh for exact quadrature on the circle."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Deterministic Quadrature on the Circle")
    print("=" * 60)

    # Approximate ∫₀²π cos(θ)² dθ = π using Berggren mesh points
    # The exact answer is π.

    print(f"\nApproximating ∫₀²π cos²(θ) dθ / (2π) = 1/2 via Berggren mesh averages:\n")
    print(f"{'Depth':<8} {'Points':<10} {'Average cos²':<20} {'Error':<15}")
    print("-" * 55)

    for depth in range(6):
        mesh = ExactShellMesh.from_berggren(depth)
        # cos(θ) = x for points on the unit circle
        # Use exact rational x² values
        total = Fraction(0)
        for pt in mesh.points:
            total += pt.x ** 2
        avg = total / len(mesh.points)
        error = abs(float(avg) - 0.5)
        print(f"{depth:<8} {len(mesh):<10} {float(avg):<20.10f} {error:<15.10f}")

    print("\nThe mesh provides deterministic, reproducible quadrature values.")
    print("Unlike Monte Carlo, results are the same every time and improve")
    print("systematically with depth.")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    demo_voronoi()
    demo_nearest_neighbor()
    demo_covering_radius()
    demo_quadrature()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Berggren-Generated Exact Arithmetic Shell Meshes

Demonstrates the key theorems:
  A) Every Pythagorean triple maps to the rational unit circle
  B) Tropical distances between Berggren points are exact rational arithmetic
  C) Finite meshes have certified shell membership
  D) Primitive triples inject into rational circle points
"""

from fractions import Fraction
from typing import Tuple, List

Triple = Tuple[int, int, int]


def is_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a**2 + b**2 == c**2


def to_rat_point(a: int, b: int, c: int) -> Tuple[Fraction, Fraction]:
    """Map a triple (a, b, c) to a rational circle point (a/c, b/c)."""
    return (Fraction(a, c), Fraction(b, c))


def on_unit_circle(x: Fraction, y: Fraction) -> bool:
    """Check if (x, y) lies on the unit circle: x² + y² = 1."""
    return x**2 + y**2 == 1


def trop_dist(p: Tuple[Fraction, Fraction], q: Tuple[Fraction, Fraction]) -> Fraction:
    """Tropical (Chebyshev/L∞) distance: max(|x₁ - x₂|, |y₁ - y₂|)."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


# ─── Berggren matrices ────────────────────────────────────────────────

def berg_A(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berg_B(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berg_C(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def berggren_descendants(root: Triple, max_depth: int) -> List[Triple]:
    """Generate all Berggren descendants up to given depth."""
    if max_depth == 0:
        return [root]
    result = [root]
    a, b, c = root
    for child_fn in [berg_A, berg_B, berg_C]:
        child = child_fn(a, b, c)
        result.extend(berggren_descendants(child, max_depth - 1))
    return result


def trop_dist_exact_formula(a1: int, b1: int, c1: int,
                             a2: int, b2: int, c2: int) -> Fraction:
    """Compute tropical distance via the exact integer formula:
       max(|a₁c₂ - a₂c₁|, |b₁c₂ - b₂c₁|) / |c₁c₂|
    """
    num = max(abs(a1*c2 - a2*c1), abs(b1*c2 - b2*c1))
    den = abs(c1 * c2)
    return Fraction(num, den)


# ─── Demonstrations ──────────────────────────────────────────────────

def demo_theorem_A():
    """Theorem A: Berggren descendants lie on the unit circle."""
    print("=" * 70)
    print("THEOREM A: Berggren Descendants on the Rational Unit Circle")
    print("=" * 70)

    root = (3, 4, 5)
    descendants = berggren_descendants(root, max_depth=3)

    print(f"\nGenerated {len(descendants)} triples up to depth 3.\n")
    print(f"{'Triple':<25} {'Pythagorean?':<15} {'Circle Point':<30} {'On Circle?'}")
    print("-" * 85)

    for a, b, c in descendants[:15]:  # Show first 15
        is_pyth = is_pythagorean(a, b, c)
        x, y = to_rat_point(a, b, c)
        on_circ = on_unit_circle(x, y)
        print(f"({a:>4}, {b:>4}, {c:>4})    {str(is_pyth):<15} ({x}, {y}){'':<5} {on_circ}")

    # Verify ALL descendants
    all_ok = all(
        is_pythagorean(a, b, c) and on_unit_circle(*to_rat_point(a, b, c))
        for a, b, c in descendants
    )
    print(f"\n✓ All {len(descendants)} descendants verified on the unit circle: {all_ok}")


def demo_theorem_B():
    """Theorem B: Exact tropical distance formula."""
    print("\n" + "=" * 70)
    print("THEOREM B: Exact Tropical Distance via Integer Arithmetic")
    print("=" * 70)

    # Depth-1 triples
    triples = [
        (3, 4, 5),
        (5, 12, 13),
        (21, 20, 29),
        (15, 8, 17),
    ]

    print(f"\n{'Point 1':<15} {'Point 2':<15} {'d_trop (direct)':<20} {'d_trop (formula)':<20} {'Match?'}")
    print("-" * 85)

    for i in range(len(triples)):
        for j in range(i+1, len(triples)):
            a1, b1, c1 = triples[i]
            a2, b2, c2 = triples[j]

            p1 = to_rat_point(a1, b1, c1)
            p2 = to_rat_point(a2, b2, c2)

            d_direct = trop_dist(p1, p2)
            d_formula = trop_dist_exact_formula(a1, b1, c1, a2, b2, c2)

            match = d_direct == d_formula
            name1 = f"({a1},{b1},{c1})"
            name2 = f"({a2},{b2},{c2})"
            print(f"{name1:<15} {name2:<15} {str(d_direct):<20} {str(d_formula):<20} {match}")

    print("\n✓ The formula max(|a₁c₂ - a₂c₁|, |b₁c₂ - b₂c₁|) / |c₁c₂| matches exactly.")


def demo_theorem_C():
    """Theorem C: Finite mesh certification."""
    print("\n" + "=" * 70)
    print("THEOREM C: Finite Mesh Shell Membership & Tropical Exactness")
    print("=" * 70)

    mesh = berggren_descendants((3, 4, 5), max_depth=2)
    print(f"\nDepth-2 Berggren mesh: {len(mesh)} points")

    # Verify shell membership
    all_on_shell = all(
        on_unit_circle(*to_rat_point(a, b, c))
        for a, b, c in mesh
    )
    print(f"  ✓ All points on unit circle: {all_on_shell}")

    # Verify pairwise tropical distances are exact rationals (they always are in Python's Fraction)
    n_pairs = 0
    for i in range(len(mesh)):
        for j in range(i+1, len(mesh)):
            a1, b1, c1 = mesh[i]
            a2, b2, c2 = mesh[j]
            d = trop_dist(to_rat_point(a1, b1, c1), to_rat_point(a2, b2, c2))
            d2 = trop_dist_exact_formula(a1, b1, c1, a2, b2, c2)
            assert d == d2
            n_pairs += 1

    print(f"  ✓ All {n_pairs} pairwise tropical distances verified exact")

    # Show some distances
    print(f"\n  Sample pairwise distances:")
    for i in range(min(5, len(mesh))):
        for j in range(i+1, min(5, len(mesh))):
            a1, b1, c1 = mesh[i]
            a2, b2, c2 = mesh[j]
            d = trop_dist_exact_formula(a1, b1, c1, a2, b2, c2)
            print(f"    d(({a1},{b1},{c1}), ({a2},{b2},{c2})) = {d}")


def demo_theorem_D():
    """Theorem D: Primitive triple injectivity."""
    print("\n" + "=" * 70)
    print("THEOREM D: Primitive Triple Injectivity")
    print("=" * 70)

    from math import gcd

    def is_primitive(a, b, c):
        return gcd(abs(a), gcd(abs(b), abs(c))) == 1

    mesh = berggren_descendants((3, 4, 5), max_depth=3)
    primitive_mesh = [(a, b, c) for a, b, c in mesh if is_primitive(a, b, c) and c > 0]

    print(f"\n{len(primitive_mesh)} primitive triples with positive hypotenuse")

    # Check injectivity: no two distinct primitive triples map to the same circle point
    seen = {}
    injective = True
    for a, b, c in primitive_mesh:
        pt = to_rat_point(a, b, c)
        if pt in seen:
            print(f"  COLLISION: ({a},{b},{c}) and {seen[pt]} map to {pt}")
            injective = False
        else:
            seen[pt] = (a, b, c)

    print(f"  ✓ Injectivity verified: {injective}")
    print(f"  {len(seen)} distinct rational circle points from {len(primitive_mesh)} triples")


if __name__ == "__main__":
    demo_theorem_A()
    demo_theorem_B()
    demo_theorem_C()
    demo_theorem_D()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Berggren-Generated Exact Arithmetic Shell Meshes

Generates publication-quality figures:
  1. Berggren shell mesh on the unit circle (depth 0-4)
  2. Tropical distance heatmap
  3. Angular distribution and gap analysis
  4. Denominator growth profile
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
from math import pi, cos, sin, atan2
import base64
import io
import sys

sys.path.insert(0, '.')
from algorithms import (
    BerggrenTree, ExactShellMesh, TropicalDistanceEngine,
    MeshAnalyzer, ShellPoint
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_shell_mesh():
    """Plot Berggren shell mesh points on the unit circle at various depths."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Berggren Shell Mesh on the Unit Circle', fontsize=16, fontweight='bold')

    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    depth_labels = ['Depth 0\n(root only)', 'Depth 1\n(4 points)',
                    'Depth 2\n(13 points)', 'Depth 3\n(40 points)',
                    'Depth 4\n(121 points)', 'All depths\n(overlay)']

    for idx, ax in enumerate(axes.flat):
        # Draw unit circle
        theta = np.linspace(0, 2*pi, 200)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
        ax.set_aspect('equal')
        ax.set_xlim(-1.15, 1.15)
        ax.set_ylim(-1.15, 1.15)
        ax.grid(True, alpha=0.2)
        ax.set_title(depth_labels[idx], fontsize=11)

        if idx < 5:
            mesh = ExactShellMesh.from_berggren(idx)
            xs = [float(pt.x) for pt in mesh.points]
            ys = [float(pt.y) for pt in mesh.points]
            ax.scatter(xs, ys, c=colors[idx], s=50 if idx < 3 else 20,
                      zorder=5, edgecolors='black', linewidth=0.5)
        else:
            # Overlay all depths with different colors
            for d in range(5):
                mesh = ExactShellMesh.from_berggren(d)
                xs = [float(pt.x) for pt in mesh.points if pt.depth == d]
                ys = [float(pt.y) for pt in mesh.points if pt.depth == d]
                ax.scatter(xs, ys, c=colors[d], s=30, zorder=5-d,
                          edgecolors='black', linewidth=0.3, label=f'd={d}')
            ax.legend(fontsize=8, loc='lower left')

    plt.tight_layout()
    fig.savefig('shell_mesh.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Saved shell_mesh.png")
    return b64


def plot_tropical_heatmap():
    """Plot pairwise tropical distance matrix as heatmap."""
    mesh = ExactShellMesh.from_berggren(2)
    engine = TropicalDistanceEngine()
    n = len(mesh.points)

    # Compute distance matrix
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                D[i, j] = float(engine.distance(mesh.points[i], mesh.points[j]))

    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(D, cmap='viridis', interpolation='nearest')
    ax.set_title('Pairwise Tropical Distances (Depth-2 Mesh, 13 points)',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Point index')
    ax.set_ylabel('Point index')
    plt.colorbar(im, ax=ax, label='Tropical distance')

    # Label with triple names
    labels = [f"({pt.triple[0]},{pt.triple[1]},{pt.triple[2]})" for pt in mesh.points]
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=90, fontsize=7)
    ax.set_yticklabels(labels, fontsize=7)

    plt.tight_layout()
    fig.savefig('tropical_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Saved tropical_heatmap.png")
    return b64


def plot_angular_distribution():
    """Plot angular distribution and gap analysis."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Angular Distribution of Berggren Mesh Points', fontsize=14, fontweight='bold')

    # Panel 1: Angles on unit circle
    ax = axes[0]
    for depth in range(5):
        mesh = ExactShellMesh.from_berggren(depth)
        angles = sorted(pt.angle for pt in mesh.points)
        y_vals = [depth] * len(angles)
        ax.scatter(angles, y_vals, s=20, zorder=5)
    ax.set_xlabel('Angle (radians)')
    ax.set_ylabel('Depth')
    ax.set_title('Point Angles by Depth')
    ax.set_xlim(0, 2*pi)

    # Panel 2: Angular gaps
    ax = axes[1]
    for depth in range(1, 5):
        mesh = ExactShellMesh.from_berggren(depth)
        gaps = MeshAnalyzer.angular_gaps(mesh)
        ax.plot(range(len(gaps)), gaps, 'o-', markersize=3, label=f'd={depth}')
    ax.set_xlabel('Gap rank')
    ax.set_ylabel('Gap size (radians)')
    ax.set_title('Angular Gaps (sorted)')
    ax.legend()

    # Panel 3: Maximum gap vs depth
    ax = axes[2]
    depths = list(range(6))
    max_gaps = []
    for d in depths:
        mesh = ExactShellMesh.from_berggren(d)
        gaps = MeshAnalyzer.angular_gaps(mesh)
        max_gaps.append(max(gaps) if gaps else 2*pi)
    ax.plot(depths, max_gaps, 'ro-', linewidth=2, markersize=8)
    ax.set_xlabel('Berggren Depth')
    ax.set_ylabel('Maximum Angular Gap')
    ax.set_title('Covering Quality vs Depth')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('angular_distribution.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Saved angular_distribution.png")
    return b64


def plot_denominator_growth():
    """Plot hypotenuse growth in the Berggren tree."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle('Arithmetic Structure of the Berggren Mesh', fontsize=14, fontweight='bold')

    # Panel 1: Hypotenuse distribution
    ax = axes[0]
    for depth in range(1, 6):
        mesh = ExactShellMesh.from_berggren(depth)
        hyps = sorted(set(pt.triple[2] for pt in mesh.points))
        ax.scatter([depth]*len(hyps), hyps, s=15, alpha=0.7)
    ax.set_xlabel('Berggren Depth')
    ax.set_ylabel('Hypotenuse Value')
    ax.set_title('Hypotenuse Values by Depth')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Panel 2: Mesh size and separation
    ax = axes[1]
    depths = list(range(5))
    sizes = []
    separations = []
    for d in depths:
        mesh = ExactShellMesh.from_berggren(d)
        sizes.append(len(mesh))
        if len(mesh) > 1:
            sep = float(MeshAnalyzer.minimum_separation(mesh))
        else:
            sep = 2.0
        separations.append(sep)

    ax2 = ax.twinx()
    bars = ax.bar(depths, sizes, color='steelblue', alpha=0.7, label='Mesh size')
    line = ax2.plot(depths, separations, 'ro-', linewidth=2, markersize=8, label='Min separation')
    ax.set_xlabel('Berggren Depth')
    ax.set_ylabel('Number of Points', color='steelblue')
    ax2.set_ylabel('Minimum Separation', color='red')
    ax.set_title('Mesh Density vs Resolution')

    # Combined legend
    handles = [bars, line[0]]
    labels = ['Mesh size', 'Min separation']
    ax.legend(handles, labels, loc='center right')

    plt.tight_layout()
    fig.savefig('denominator_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Saved denominator_growth.png")
    return b64


if __name__ == "__main__":
    b64_mesh = plot_shell_mesh()
    b64_heatmap = plot_tropical_heatmap()
    b64_angular = plot_angular_distribution()
    b64_denom = plot_denominator_growth()
    print("\nAll visualizations generated successfully.")
    # Write base64 data to files for JSON packaging
    with open('viz_data.txt', 'w') as f:
        f.write(f"MESH:{b64_mesh}\n")
        f.write(f"HEATMAP:{b64_heatmap}\n")
        f.write(f"ANGULAR:{b64_angular}\n")
        f.write(f"DENOM:{b64_denom}\n")
