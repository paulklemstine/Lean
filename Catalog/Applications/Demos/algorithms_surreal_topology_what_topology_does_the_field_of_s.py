"""
algorithms.py — Algorithms for Surreal Topology

Implements the core algorithms from the research paper:
1. Bounded-day dyadic generation with complexity analysis
2. Interval graph construction
3. Union-find for connectivity analysis
4. Contraction homotopy simulation
5. Order-complex homology computation (Betti numbers)
"""

from fractions import Fraction
from typing import List, Set, Dict, Tuple, Optional
from collections import defaultdict
import itertools


class UnionFind:
    """Weighted union-find with path compression.

    Time complexity: O(α(n)) amortized per operation,
    where α is the inverse Ackermann function.
    Space complexity: O(n).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.count = n  # number of components

    def find(self, x: int) -> int:
        """Find root with path compression."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if a merge occurred."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.count -= 1
        return True

    def components(self) -> List[Set[int]]:
        """Return all connected components."""
        comp = defaultdict(set)
        for i in range(len(self.parent)):
            comp[self.find(i)].add(i)
        return list(comp.values())


def bounded_day_dyadics(n: int) -> List[Fraction]:
    """Generate sorted dyadic rationals of bounded day complexity.

    Algorithm: Generate all k/2^n for k ∈ [-2^n, 2^n], then deduplicate and sort.

    Time complexity: O(2^n · log(2^n)) = O(n · 2^n) due to sorting.
    Space complexity: O(2^n).

    Args:
        n: Day/precision level (non-negative integer).

    Returns:
        Sorted list of distinct dyadic rationals.

    Example:
        >>> bounded_day_dyadics(2)
        [Fraction(-1, 1), Fraction(-3, 4), Fraction(-1, 2), Fraction(-1, 4),
         Fraction(0, 1), Fraction(1, 4), Fraction(1, 2), Fraction(3, 4), Fraction(1, 1)]
    """
    if n < 0:
        raise ValueError(f"Day level must be non-negative, got {n}")
    denom = 2 ** n
    return sorted(set(Fraction(k, denom) for k in range(-denom, denom + 1)))


def interval_graph(
    points: List[Fraction],
    epsilon: Fraction
) -> Tuple[int, List[Tuple[int, int]]]:
    """Build the ε-interval graph on an ordered point set.

    Two points p_i, p_j are adjacent iff |p_i - p_j| ≤ ε.
    Since points are sorted, we only need to scan forward.

    Time complexity: O(n · k) where k is the average neighborhood size.
    In the worst case (ε ≥ diameter), this is O(n²).
    Space complexity: O(n + m) where m is the number of edges.

    Args:
        points: Sorted list of rational points.
        epsilon: Adjacency threshold.

    Returns:
        Tuple of (number of vertices, list of edge pairs).
    """
    n = len(points)
    edges = []
    for i in range(n):
        j = i + 1
        while j < n and points[j] - points[i] <= epsilon:
            edges.append((i, j))
            j += 1
    return n, edges


def connectivity_analysis(
    points: List[Fraction],
    epsilon: Fraction
) -> Dict:
    """Analyze the connectivity of an ε-interval graph.

    Returns a dictionary with:
    - num_vertices: number of points
    - num_edges: number of edges in the ε-graph
    - num_components: Betti-0 (number of connected components)
    - is_connected: whether the graph is connected
    - component_sizes: sorted list of component sizes

    Args:
        points: Sorted list of rational points.
        epsilon: Adjacency threshold.

    Returns:
        Analysis dictionary.
    """
    n, edges = interval_graph(points, epsilon)
    uf = UnionFind(n)
    for i, j in edges:
        uf.union(i, j)

    components = uf.components()
    return {
        "num_vertices": n,
        "num_edges": len(edges),
        "num_components": len(components),
        "is_connected": len(components) == 1,
        "component_sizes": sorted(len(c) for c in components),
    }


def contraction_homotopy(
    q: Fraction,
    num_steps: int,
    target: Fraction = Fraction(0)
) -> List[Fraction]:
    """Simulate the contraction homotopy H(x,t) = (1-t)·x + t·target.

    At t=0: H(x,0) = x (identity).
    At t=1: H(x,1) = target (constant map).

    We discretize t into num_steps equal intervals.

    Time complexity: O(num_steps).
    Space complexity: O(num_steps).

    Args:
        q: Starting point.
        num_steps: Number of discrete time steps.
        target: Contraction target (default 0).

    Returns:
        List of positions at each time step.
    """
    if num_steps <= 0:
        return [q]
    path = []
    for i in range(num_steps + 1):
        t = Fraction(i, num_steps)
        pos = (1 - t) * q + t * target
        path.append(pos)
    return path


def persistence_betti_0(
    points: List[Fraction],
    epsilon_values: Optional[List[Fraction]] = None
) -> List[Tuple[Fraction, int]]:
    """Compute Betti-0 as a function of epsilon (persistence diagram).

    This is a simplified version of persistent homology in dimension 0.
    For each epsilon value, we compute the number of connected components
    in the ε-interval graph.

    Time complexity: O(len(epsilon_values) · n²) in the worst case.
    Space complexity: O(n).

    Args:
        points: Sorted list of rational points.
        epsilon_values: List of epsilon thresholds to test.
            If None, uses the set of all pairwise distances.

    Returns:
        List of (epsilon, betti_0) pairs, sorted by epsilon.
    """
    if epsilon_values is None:
        # Use all distinct gaps as critical values
        gaps = sorted(set(
            points[j] - points[i]
            for i in range(len(points))
            for j in range(i + 1, len(points))
        ))
        epsilon_values = [Fraction(0)] + gaps

    result = []
    for eps in sorted(epsilon_values):
        analysis = connectivity_analysis(points, eps)
        result.append((eps, analysis["num_components"]))

    return result


def order_complex_simplices(
    points: List[Fraction],
    max_dim: int = 2
) -> Dict[int, int]:
    """Count simplices in the order complex up to a given dimension.

    The order complex on a finite totally ordered set is the simplicial
    complex whose k-simplices are chains of length k+1.
    For a totally ordered set of size n, every subset is a chain,
    so the number of k-simplices is C(n, k+1).

    Time complexity: O(max_dim).
    Space complexity: O(max_dim).

    Args:
        points: List of points (must be totally ordered).
        max_dim: Maximum simplex dimension to count.

    Returns:
        Dictionary mapping dimension to simplex count.
    """
    n = len(points)
    from math import comb
    return {d: comb(n, d + 1) for d in range(min(max_dim + 1, n))}


# ─── Example usage ───────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Bounded-Day Dyadics ===")
    for n in range(4):
        d = bounded_day_dyadics(n)
        print(f"Day {n}: {len(d)} points — {[float(x) for x in d[:5]]}...")

    print("\n=== Contraction Homotopy ===")
    path = contraction_homotopy(Fraction(3, 4), 8)
    print(f"Path from 3/4 to 0: {[float(x) for x in path]}")

    print("\n=== Connectivity Analysis (Day 3) ===")
    pts = bounded_day_dyadics(3)
    for eps in [Fraction(1, 8), Fraction(1, 4), Fraction(1, 2)]:
        analysis = connectivity_analysis(pts, eps)
        print(f"ε={float(eps):.3f}: "
              f"{analysis['num_components']} components, "
              f"connected={analysis['is_connected']}")

    print("\n=== Persistence Betti-0 (Day 2) ===")
    pts2 = bounded_day_dyadics(2)
    persistence = persistence_betti_0(pts2,
        [Fraction(k, 8) for k in range(17)])
    for eps, b0 in persistence:
        print(f"  ε={float(eps):.3f}: β₀ = {b0}")

    print("\n=== Order Complex (Day 2) ===")
    simplices = order_complex_simplices(pts2, max_dim=3)
    for dim, count in simplices.items():
        print(f"  dim {dim}: {count} simplices")
