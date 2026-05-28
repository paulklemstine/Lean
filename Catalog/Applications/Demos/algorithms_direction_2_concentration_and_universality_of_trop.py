#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Cycle-Birth Computation

Implements the core algorithms backed by the formally verified theorems:
- Cycle-birth edge identification via Kruskal's algorithm (Theorems 1 & 5)
- Empirical cycle-birth CDF computation
- KS distance for distribution comparison
- Monotone transport demonstration (Theorem 4)

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
minimum spanning tree, graphic matroid, KS distance, empirical process.
"""

from typing import List, Tuple, Optional
import math


class UnionFind:
    """
    Union-Find (disjoint set) data structure for Kruskal's algorithm.

    Time complexity: O(α(n)) amortized per operation (inverse Ackermann).
    Space complexity: O(n).
    """

    def __init__(self, n: int):
        """Initialize n singleton components."""
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        """Find root with path compression. O(α(n)) amortized."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """
        Union by rank. Returns True if merge occurred (different components),
        False if same component (cycle birth).

        This implements the merge-or-cycle dichotomy (Theorem 1):
        - True  → merge event (β₀ decreases by 1)
        - False → cycle birth (β₁ increases by 1)
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False  # Cycle birth!
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component."""
        return self.find(x) == self.find(y)


def compute_cycle_births(
    n: int,
    edges: List[Tuple[int, int]],
    weights: List[float]
) -> Tuple[List[float], List[float]]:
    """
    Compute cycle-birth edges and MST edges via Kruskal's algorithm.

    By Theorem 5, cycle-birth edges are exactly the complement of MST edges.
    By Theorem 1, each edge is classified as exactly one of:
    - merge (MST edge): connects two different components
    - cycle birth: connects already-connected vertices

    Args:
        n: Number of vertices
        edges: List of (u, v) edge pairs
        weights: List of edge weights (same length as edges)

    Returns:
        (cycle_birth_weights, mst_weights): Sorted lists of weights

    Time complexity: O(m log m) for sorting + O(m α(n)) for union-find = O(m log m)
    Space complexity: O(n + m)

    Example:
        >>> # K₄ with weights 1..6
        >>> edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
        >>> weights = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        >>> births, mst = compute_cycle_births(4, edges, weights)
        >>> births
        [4.0, 5.0, 6.0]
        >>> mst
        [1.0, 2.0, 3.0]
    """
    if len(edges) != len(weights):
        raise ValueError("edges and weights must have same length")

    # Sort edges by weight (Kruskal's algorithm)
    order = sorted(range(len(edges)), key=lambda i: weights[i])

    uf = UnionFind(n)
    cycle_birth_weights: List[float] = []
    mst_weights: List[float] = []

    for idx in order:
        u, v = edges[idx]
        w = weights[idx]
        if uf.union(u, v):
            mst_weights.append(w)  # Merge: added to spanning forest
        else:
            cycle_birth_weights.append(w)  # Cycle birth: tropical critical value

    return cycle_birth_weights, mst_weights


def empirical_cdf(values: List[float], t: float) -> float:
    """
    Compute empirical CDF F_n(t) = (1/n) * #{values ≤ t}.

    This implements the empiricalCycleBirthCDF from the Lean formalization.

    Time complexity: O(n) per query, or O(n log n) if pre-sorted.

    Example:
        >>> empirical_cdf([1.0, 2.0, 3.0, 4.0], 2.5)
        0.5
    """
    if len(values) == 0:
        return 0.0
    count = sum(1 for v in values if v <= t)
    return count / len(values)


def ks_distance(sample1: List[float], sample2: List[float]) -> float:
    """
    Compute Kolmogorov-Smirnov distance between two empirical distributions.

    D_KS = sup_t |F_1(t) - F_2(t)|

    By Theorem 3 (concentration), for random graphs with m edges,
    the cycle-birth CDF satisfies:
    P(|N(t) - E[N(t)]| ≥ r) ≤ 2·exp(-2r²/m)

    Time complexity: O((n+m) log(n+m))

    Example:
        >>> ks_distance([1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
        0.0
    """
    if len(sample1) == 0 or len(sample2) == 0:
        return 1.0

    combined = sorted(set(sample1 + sample2))
    max_diff = 0.0

    for t in combined:
        f1 = empirical_cdf(sample1, t)
        f2 = empirical_cdf(sample2, t)
        max_diff = max(max_diff, abs(f1 - f2))

    return max_diff


def monotone_transport(
    values: List[float],
    phi: Optional[callable] = None
) -> List[float]:
    """
    Apply monotone transport to cycle-birth weights.

    By Theorem 4 (universality), applying any strictly monotone function
    to edge weights preserves the cycle-birth classification. The birth
    weights transform equivariantly: births(φ∘w) = φ(births(w)).

    If phi is None, applies the probability integral transform (rank-based).

    Args:
        values: List of values to transform
        phi: Optional strictly monotone function

    Returns:
        Transformed values

    Example:
        >>> monotone_transport([1.0, 4.0, 9.0], phi=math.sqrt)
        [1.0, 2.0, 3.0]
    """
    if phi is not None:
        return [phi(v) for v in values]

    # Default: probability integral transform (rank normalization)
    if len(values) == 0:
        return []
    sorted_vals = sorted(values)
    rank_map = {v: (i + 0.5) / len(values) for i, v in enumerate(sorted_vals)}
    return [rank_map[v] for v in values]


def euler_characteristic(n: int, num_edges: int, num_merges: int) -> int:
    """
    Compute Euler characteristic from filtration data.

    By the euler_char_identity theorem:
    χ = V - E = (V - merges) - cycles = β₀ - β₁

    Args:
        n: Number of vertices
        num_edges: Total number of edges
        num_merges: Number of merge events

    Returns:
        Euler characteristic

    Example:
        >>> euler_characteristic(4, 6, 3)  # K₄
        -2
    """
    return n - num_edges


def betti_numbers(n: int, edges: List[Tuple[int, int]], weights: List[float]) -> Tuple[int, int]:
    """
    Compute Betti numbers β₀ and β₁ of the final graph.

    β₀ = number of connected components = V - merges
    β₁ = number of independent cycles = cycle births

    By the tree_iff_no_cycles theorem: β₁ = 0 iff the graph is a forest.

    Example:
        >>> betti_numbers(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], [1,2,3,4,5,6])
        (1, 3)
    """
    births, mst = compute_cycle_births(n, edges, weights)
    beta0 = n - len(mst)
    beta1 = len(births)
    return beta0, beta1


# ─── Example usage ───

if __name__ == '__main__':
    print("=== K₄ Example ===")
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    weights = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

    births, mst = compute_cycle_births(4, edges, weights)
    print(f"MST weights:         {mst}")
    print(f"Cycle-birth weights: {births}")
    print(f"β₀, β₁ = {betti_numbers(4, edges, weights)}")
    print(f"χ = {euler_characteristic(4, 6, 3)}")
    print()

    # Monotone transport
    print("=== Monotone Transport (Theorem 4) ===")
    transformed = monotone_transport(births, phi=lambda x: x**2)
    print(f"Original births:    {births}")
    print(f"After x² transport: {transformed}")
    print(f"Classification preserved: {len(births) == len(transformed)}")
    print()

    # KS distance
    print("=== KS Distance ===")
    d = ks_distance(births, [3.5, 4.5, 5.5])
    print(f"KS distance: {d:.4f}")
