#!/usr/bin/env python3
"""
Algorithms for Berggren-Generated Exact Arithmetic Shell Meshes

Implements:
  1. BerggrenTree — recursive generation of the Berggren ternary tree
  2. ExactShellMesh — exact rational point cloud on the unit circle
  3. TropicalDistanceEngine — exact tropical metric computation
  4. MeshAnalyzer — separation, covering radius, discrepancy analysis
"""

from fractions import Fraction
from typing import Tuple, List, Dict, Set, Optional
from dataclasses import dataclass
from math import gcd, sqrt, pi, atan2
import heapq

Triple = Tuple[int, int, int]
RatPoint = Tuple[Fraction, Fraction]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Berggren Tree Generator
# ═══════════════════════════════════════════════════════════════════════

class BerggrenTree:
    """
    Generates the Berggren ternary tree of primitive Pythagorean triples.

    The tree is rooted at (3, 4, 5) and branches via three linear
    transformations (A, B, C) that preserve the Pythagorean property
    and primitivity.

    Time complexity: O(3^d) for depth d
    Space complexity: O(3^d) for storing all nodes
    """

    ROOT: Triple = (3, 4, 5)

    @staticmethod
    def child_A(a: int, b: int, c: int) -> Triple:
        """Berggren matrix A transformation."""
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

    @staticmethod
    def child_B(a: int, b: int, c: int) -> Triple:
        """Berggren matrix B transformation."""
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

    @staticmethod
    def child_C(a: int, b: int, c: int) -> Triple:
        """Berggren matrix C transformation."""
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

    @classmethod
    def generate(cls, max_depth: int) -> List[Triple]:
        """
        Generate all Berggren descendants up to given depth.

        Args:
            max_depth: Maximum tree depth (0 = root only)

        Returns:
            List of all primitive Pythagorean triples up to given depth.
            Size: (3^(d+1) - 1) / 2 triples.
        """
        result: List[Triple] = []
        cls._generate_recursive(cls.ROOT, max_depth, result)
        return result

    @classmethod
    def _generate_recursive(cls, node: Triple, depth: int,
                            result: List[Triple]) -> None:
        result.append(node)
        if depth == 0:
            return
        a, b, c = node
        for child_fn in [cls.child_A, cls.child_B, cls.child_C]:
            cls._generate_recursive(child_fn(a, b, c), depth - 1, result)

    @classmethod
    def generate_by_hypotenuse(cls, max_hyp: int) -> List[Triple]:
        """
        Generate all Berggren triples with hypotenuse ≤ max_hyp.

        Uses BFS to explore the tree, pruning branches where the
        hypotenuse exceeds the bound.

        Time: O(N) where N is the number of triples with c ≤ max_hyp
        """
        result: List[Triple] = []
        queue = [cls.ROOT]
        while queue:
            node = queue.pop(0)
            a, b, c = node
            if c > max_hyp:
                continue
            result.append(node)
            for child_fn in [cls.child_A, cls.child_B, cls.child_C]:
                child = child_fn(a, b, c)
                if child[2] <= max_hyp:
                    queue.append(child)
        return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Exact Shell Mesh
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class ShellPoint:
    """A point on the exact rational unit circle shell."""
    triple: Triple
    x: Fraction
    y: Fraction
    depth: int

    @property
    def angle(self) -> float:
        """Approximate angle in [0, 2π) for visualization."""
        return atan2(float(self.y), float(self.x)) % (2 * pi)


class ExactShellMesh:
    """
    Exact rational shell mesh on the unit circle.

    Every point has coordinates (a/c, b/c) where (a, b, c) is a
    primitive Pythagorean triple. All arithmetic is exact — no
    floating-point approximation is ever used for geometric computation.

    Invariant: For every point p in the mesh, p.x² + p.y² = 1 exactly.
    """

    def __init__(self, triples: List[Triple]):
        self.points: List[ShellPoint] = []
        for a, b, c in triples:
            assert a**2 + b**2 == c**2, f"Not Pythagorean: {(a,b,c)}"
            assert c != 0, f"Zero hypotenuse: {(a,b,c)}"
            x = Fraction(a, c)
            y = Fraction(b, c)
            assert x**2 + y**2 == 1, f"Not on unit circle: ({x}, {y})"
            self.points.append(ShellPoint(triple=(a, b, c), x=x, y=y, depth=0))

    @classmethod
    def from_berggren(cls, max_depth: int) -> 'ExactShellMesh':
        """Construct a shell mesh from Berggren tree up to given depth."""
        triples = BerggrenTree.generate(max_depth)
        mesh = cls(triples)
        # Set depths
        cls._set_depths(mesh, max_depth)
        return mesh

    @classmethod
    def _set_depths(cls, mesh: 'ExactShellMesh', max_depth: int) -> None:
        """Assign depth labels based on tree structure."""
        depth_map: Dict[Triple, int] = {}
        def _recurse(node: Triple, d: int):
            depth_map[node] = d
            if d >= max_depth:
                return
            a, b, c = node
            for fn in [BerggrenTree.child_A, BerggrenTree.child_B, BerggrenTree.child_C]:
                _recurse(fn(a, b, c), d + 1)
        _recurse(BerggrenTree.ROOT, 0)
        for pt in mesh.points:
            pt.depth = depth_map.get(pt.triple, -1)

    def __len__(self) -> int:
        return len(self.points)

    def verify_shell(self) -> bool:
        """Verify all points lie exactly on the unit circle."""
        return all(pt.x**2 + pt.y**2 == 1 for pt in self.points)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Tropical Distance Engine
# ═══════════════════════════════════════════════════════════════════════

class TropicalDistanceEngine:
    """
    Exact tropical (Chebyshev/L∞) distance computation on rational shell meshes.

    The key theorem (B) shows that for Berggren points p₁ = (a₁/c₁, b₁/c₁)
    and p₂ = (a₂/c₂, b₂/c₂):

        d_trop(p₁, p₂) = max(|a₁c₂ - a₂c₁|, |b₁c₂ - b₂c₁|) / |c₁c₂|

    This reduces tropical distance to pure integer arithmetic with
    controlled denominator.
    """

    @staticmethod
    def distance(p: ShellPoint, q: ShellPoint) -> Fraction:
        """
        Compute exact tropical distance between two shell points.

        Uses the integer cross-product formula for maximum efficiency.
        No floating-point arithmetic is involved.

        Time: O(1) integer arithmetic operations
        """
        a1, b1, c1 = p.triple
        a2, b2, c2 = q.triple
        num = max(abs(a1*c2 - a2*c1), abs(b1*c2 - b2*c1))
        den = abs(c1 * c2)
        return Fraction(num, den)

    @staticmethod
    def distance_direct(p: ShellPoint, q: ShellPoint) -> Fraction:
        """Compute tropical distance directly from rational coordinates."""
        return max(abs(p.x - q.x), abs(p.y - q.y))

    @classmethod
    def pairwise_distances(cls, mesh: ExactShellMesh) -> List[Tuple[int, int, Fraction]]:
        """
        Compute all pairwise tropical distances in a mesh.

        Returns list of (i, j, distance) tuples.
        Time: O(n²) where n = |mesh|
        """
        distances = []
        n = len(mesh.points)
        for i in range(n):
            for j in range(i+1, n):
                d = cls.distance(mesh.points[i], mesh.points[j])
                distances.append((i, j, d))
        return distances

    @classmethod
    def nearest_neighbor(cls, mesh: ExactShellMesh,
                         query: ShellPoint) -> Tuple[int, Fraction]:
        """
        Find the nearest mesh point to a query point in tropical metric.

        Time: O(n) — exact, no floating-point errors
        """
        best_idx = 0
        best_dist = cls.distance(query, mesh.points[0])
        for i in range(1, len(mesh.points)):
            d = cls.distance(query, mesh.points[i])
            if d < best_dist:
                best_dist = d
                best_idx = i
        return best_idx, best_dist


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Mesh Analyzer
# ═══════════════════════════════════════════════════════════════════════

class MeshAnalyzer:
    """
    Analyze geometric properties of exact shell meshes.

    Computes separation, covering radius, discrepancy, and
    angular distribution statistics — all exactly where possible.
    """

    @staticmethod
    def minimum_separation(mesh: ExactShellMesh) -> Fraction:
        """
        Compute the minimum pairwise tropical distance in the mesh.

        This is the mesh's separation constant: the minimum distance
        between any two distinct points.

        Time: O(n²)
        """
        engine = TropicalDistanceEngine()
        min_dist = Fraction(10**18)
        n = len(mesh.points)
        for i in range(n):
            for j in range(i+1, n):
                d = engine.distance(mesh.points[i], mesh.points[j])
                if d < min_dist:
                    min_dist = d
        return min_dist

    @staticmethod
    def diameter(mesh: ExactShellMesh) -> Fraction:
        """
        Compute the maximum pairwise tropical distance (diameter).

        Time: O(n²)
        """
        engine = TropicalDistanceEngine()
        max_dist = Fraction(0)
        n = len(mesh.points)
        for i in range(n):
            for j in range(i+1, n):
                d = engine.distance(mesh.points[i], mesh.points[j])
                if d > max_dist:
                    max_dist = d
        return max_dist

    @staticmethod
    def angular_gaps(mesh: ExactShellMesh) -> List[float]:
        """
        Compute angular gaps between consecutive mesh points.

        Returns sorted list of gap sizes in radians.
        """
        angles = sorted(pt.angle for pt in mesh.points)
        if not angles:
            return []
        gaps = [angles[i+1] - angles[i] for i in range(len(angles)-1)]
        gaps.append(2*pi - angles[-1] + angles[0])  # wrap-around gap
        return sorted(gaps, reverse=True)

    @staticmethod
    def denominator_profile(mesh: ExactShellMesh) -> Dict[int, int]:
        """
        Profile the denominators (hypotenuses) appearing in the mesh.

        Returns a dictionary mapping hypotenuse values to their count.
        """
        profile: Dict[int, int] = {}
        for pt in mesh.points:
            c = pt.triple[2]
            profile[c] = profile.get(c, 0) + 1
        return dict(sorted(profile.items()))


# ═══════════════════════════════════════════════════════════════════════
# Main: Run all algorithms
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Berggren Shell Mesh Algorithms")
    print("=" * 60)

    # Generate meshes at various depths
    for depth in range(5):
        mesh = ExactShellMesh.from_berggren(depth)
        print(f"\nDepth {depth}: {len(mesh)} points")
        print(f"  Shell verified: {mesh.verify_shell()}")

        if depth <= 2:
            sep = MeshAnalyzer.minimum_separation(mesh)
            diam = MeshAnalyzer.diameter(mesh)
            print(f"  Min separation: {sep} ≈ {float(sep):.6f}")
            print(f"  Diameter:       {diam} ≈ {float(diam):.6f}")
            print(f"  Ratio:          {float(diam/sep):.3f}")

        denoms = MeshAnalyzer.denominator_profile(mesh)
        print(f"  Hypotenuses: {denoms}")

    # Verify formula consistency
    print("\n" + "=" * 60)
    print("Formula Verification (Theorem B)")
    mesh = ExactShellMesh.from_berggren(2)
    engine = TropicalDistanceEngine()
    mismatches = 0
    total = 0
    for i in range(len(mesh.points)):
        for j in range(i+1, len(mesh.points)):
            d1 = engine.distance(mesh.points[i], mesh.points[j])
            d2 = engine.distance_direct(mesh.points[i], mesh.points[j])
            if d1 != d2:
                mismatches += 1
            total += 1
    print(f"Checked {total} pairs, mismatches: {mismatches}")
