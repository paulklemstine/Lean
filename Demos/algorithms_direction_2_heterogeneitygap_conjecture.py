"""
algorithms.py — Core algorithms for hypergraph transversal analysis
and edge-size disorder measurement.

Implements:
  - Hypergraph representation and transversal computation
  - Fractional transversal (LP relaxation) via linear programming
  - Edge-size disorder invariants: heterogeneity, support width, collision index
  - Certified gap detection
"""

from __future__ import annotations
import numpy as np
from itertools import combinations
from typing import Optional
from fractions import Fraction


class Hypergraph:
    """A hypergraph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: list[frozenset[int]]):
        """
        Args:
            n: number of vertices
            edges: list of edges, each a frozenset of vertex indices
        """
        self.n = n
        self.edges = list(set(edges))  # deduplicate

    @classmethod
    def random(cls, n: int, num_edges: int, size_options: list[int],
               rng: np.random.Generator | None = None) -> "Hypergraph":
        """Generate a random hypergraph with edge sizes drawn from size_options."""
        if rng is None:
            rng = np.random.default_rng()
        edges = set()
        vertices = list(range(n))
        attempts = 0
        while len(edges) < num_edges and attempts < num_edges * 100:
            k = rng.choice(size_options)
            if k > n:
                attempts += 1
                continue
            e = frozenset(rng.choice(vertices, size=k, replace=False))
            edges.add(e)
            attempts += 1
        return cls(n, list(edges))

    def edge_sizes(self) -> list[int]:
        """Return list of edge cardinalities."""
        return [len(e) for e in self.edges]

    def edge_heterogeneity(self) -> float:
        """Variance of edge sizes (population variance)."""
        sizes = self.edge_sizes()
        if not sizes:
            return 0.0
        mu = np.mean(sizes)
        return float(np.mean([(s - mu) ** 2 for s in sizes]))

    def edge_size_support_width(self) -> int:
        """Max edge size - min edge size."""
        sizes = self.edge_sizes()
        if not sizes:
            return 0
        return max(sizes) - min(sizes)

    def edge_size_collision_index(self) -> float:
        """Collision index: sum of p_k^2 where p_k = freq(k)/n."""
        sizes = self.edge_sizes()
        if not sizes:
            return 1.0
        n = len(sizes)
        from collections import Counter
        counts = Counter(sizes)
        return sum((c / n) ** 2 for c in counts.values())

    def edge_size_distribution_support(self) -> set[int]:
        """Set of distinct edge sizes."""
        return set(self.edge_sizes())

    def is_transversal(self, S: set[int]) -> bool:
        """Check if S is a transversal (hitting set)."""
        return all(bool(S & e) for e in self.edges)

    def transversal_number_brute(self) -> int:
        """Compute τ(H) by brute force (exponential)."""
        for k in range(self.n + 1):
            for S in combinations(range(self.n), k):
                if self.is_transversal(set(S)):
                    return k
        return self.n  # fallback

    def fractional_transversal_number(self) -> float:
        """Compute τ*(H) via LP relaxation using scipy."""
        try:
            from scipy.optimize import linprog
        except ImportError:
            return float('nan')

        m = len(self.edges)
        n = self.n
        if m == 0:
            return 0.0

        # minimize sum x_v
        c = np.ones(n)
        # subject to: for each edge e, sum_{v in e} x_v >= 1
        # i.e. -sum_{v in e} x_v <= -1
        A_ub = np.zeros((m, n))
        b_ub = -np.ones(m)
        for i, e in enumerate(self.edges):
            for v in e:
                A_ub[i, v] = -1.0

        bounds = [(0, None)] * n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return float(result.fun)
        return float('nan')

    def has_positive_ceil_gap(self) -> tuple[bool, int, float]:
        """Check if τ > ⌈τ*⌉. Returns (gap_exists, τ, τ*)."""
        tau = self.transversal_number_brute()
        tau_star = self.fractional_transversal_number()
        import math
        ceil_tau_star = math.ceil(tau_star - 1e-9)  # numerical guard
        return (tau > ceil_tau_star, tau, tau_star)

    def __repr__(self) -> str:
        return f"Hypergraph(n={self.n}, |E|={len(self.edges)}, sizes={sorted(self.edge_size_distribution_support())})"


def two_scale_family(m: int) -> Hypergraph:
    """
    Construct a two-scale hypergraph family for demonstrating
    heterogeneity-gap phenomena.

    The construction:
    - Vertices: {0, ..., 3m-1}
    - Small edges (size 2): pairs from m disjoint pairs in {0,...,2m-1}
      These force at least m vertices in any transversal.
    - Large edge (size 2m): the set {0, 1, ..., 2m-1}
      A fractional transversal can assign 1/(2m) to each of these vertices
      and cover the large edge with total weight 1, while also covering
      each small pair with weight 2/(2m) = 1/m. When m >= 3, this is < 1
      so we need a modified construction.

    Better construction for demonstrable gap:
    - n = 2m vertices
    - m disjoint pairs as small edges of size 2
    - One big edge of all 2m vertices
    - τ = m (must pick one from each pair)
    - τ* = m (assign 1/2 to each vertex: each pair sums to 1, big edge sums to m)
    This doesn't give a gap. Let me use a classic construction instead.

    Classic gap construction (Lovász):
    - Complete k-uniform hypergraph on n vertices where k < n
    - τ* = n/k, τ = n - k + 1

    For heterogeneity, use mixed sizes:
    - n = 2m + 1 vertices
    - All pairs {i,j} as edges (size 2): C(2m+1, 2) edges
    - The full vertex set {0,...,2m} as one edge (size 2m+1)
    - τ = 2m (need all but one vertex to hit all pairs)
    - τ* ≤ (2m+1)/2 = m + 1/2 (assign 1/2 to each vertex)
    - So gap = 2m - (m+1) = m - 1 for m ≥ 2
    """
    n = 2 * m + 1
    edges = []
    # All pairs
    for i in range(n):
        for j in range(i + 1, n):
            edges.append(frozenset([i, j]))
    # Full vertex set
    edges.append(frozenset(range(n)))
    return Hypergraph(n, edges)


def projective_plane_family(q: int) -> Hypergraph:
    """
    Construct a hypergraph based on the Fano-like structure
    for demonstrating uniform vs non-uniform behavior.
    Uses a simple q x q grid construction.

    - Vertices: q^2 grid points
    - Row edges (size q): each row
    - Column edges (size q): each column
    - Diagonal edge (size q): main diagonal (if q entries)
    - Extra small edges (size 2): some pairs

    This gives heterogeneity when mixing row/col edges with small edges.
    """
    n = q * q
    edges = []
    # Row edges (size q)
    for i in range(q):
        edges.append(frozenset(range(i * q, (i + 1) * q)))
    # Column edges (size q)
    for j in range(q):
        edges.append(frozenset(range(j, n, q)))
    # Add some small edges of size 2 for heterogeneity
    for i in range(min(q, n - 1)):
        edges.append(frozenset([i, i + 1]))

    return Hypergraph(n, edges)


def compute_disorder_stats(H: Hypergraph) -> dict:
    """Compute all disorder statistics for a hypergraph."""
    return {
        'heterogeneity': H.edge_heterogeneity(),
        'support_width': H.edge_size_support_width(),
        'collision_index': H.edge_size_collision_index(),
        'support': H.edge_size_distribution_support(),
        'num_edges': len(H.edges),
        'num_vertices': H.n,
        'edge_sizes': sorted(H.edge_sizes()),
    }


if __name__ == "__main__":
    print("=== Algorithms Module Demo ===\n")

    # Demo 1: Two-scale family
    for m in [2, 3, 4, 5]:
        H = two_scale_family(m)
        stats = compute_disorder_stats(H)
        print(f"Two-scale family m={m}: {H}")
        print(f"  Heterogeneity: {stats['heterogeneity']:.4f}")
        print(f"  Support width: {stats['support_width']}")
        print(f"  Collision index: {stats['collision_index']:.4f}")
        print(f"  τ* = {H.fractional_transversal_number():.4f}")
        print()

    # Demo 2: Random hypergraphs
    rng = np.random.default_rng(42)
    for trial in range(5):
        H = Hypergraph.random(10, 15, [2, 3, 4, 5], rng)
        stats = compute_disorder_stats(H)
        tau_star = H.fractional_transversal_number()
        print(f"Random hypergraph {trial+1}: {H}")
        print(f"  Heterogeneity: {stats['heterogeneity']:.4f}")
        print(f"  Collision index: {stats['collision_index']:.4f}")
        print(f"  τ* = {tau_star:.4f}")
        print()
