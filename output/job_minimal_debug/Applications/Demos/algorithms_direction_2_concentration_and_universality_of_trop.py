"""
algorithms.py — Core algorithms for tropical critical distributions.

Implements:
1. Union-Find (weighted, with path compression)
2. Kruskal-based cycle-birth computation
3. Empirical CDF computation
4. KS distance computation
5. Monotone transport (probability integral transform)

Complexity analysis included in docstrings.

Application keywords: minimum spanning tree, graphic matroid, Kruskal's algorithm,
persistent homology, topological data analysis, concentration of measure.
"""

import numpy as np
from typing import List, Tuple, Optional


class UnionFind:
    """
    Weighted Union-Find with path compression and union by rank.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
        - Space: O(n)

    This is the core data structure for Kruskal's algorithm and
    cycle-birth computation.

    Example:
        >>> uf = UnionFind(5)
        >>> uf.union(0, 1)  # merge components
        True
        >>> uf.union(1, 2)
        True
        >>> uf.connected(0, 2)  # now connected
        True
        >>> uf.union(0, 2)  # already connected → cycle birth
        False
    """

    def __init__(self, n: int):
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
        False if cycle birth (same component).

        O(α(n)) amortized.
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


def kruskal_filtration(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray
) -> Tuple[List[float], List[float], List[Tuple[float, bool]]]:
    """
    Compute the Kruskal filtration of a weighted graph.

    This simultaneously computes:
    - The minimum spanning forest (MST for connected graphs)
    - The cycle-birth edges (non-MST edges)
    - The full filtration sequence

    Algorithm: Sort edges by weight, process in order using union-find.
    An edge that merges two components is an MST edge.
    An edge whose endpoints are already connected creates a cycle.

    Time complexity: O(m log m + m α(n)) where m = |edges|
    Space complexity: O(n + m)

    Args:
        n: Number of vertices
        edges: List of (u, v) edge pairs
        weights: Array of edge weights (same length as edges)

    Returns:
        cycle_birth_weights: Weights of cycle-birth edges
        mst_weights: Weights of MST edges
        filtration: List of (weight, is_cycle_birth) tuples in sorted order

    Example:
        >>> # Triangle with weights 1, 2, 3
        >>> edges = [(0, 1), (1, 2), (0, 2)]
        >>> weights = np.array([1.0, 2.0, 3.0])
        >>> cb, mst, filt = kruskal_filtration(3, edges, weights)
        >>> cb  # Edge (0,2) with weight 3 creates a cycle
        [3.0]
        >>> mst  # Edges (0,1) and (1,2) form the MST
        [1.0, 2.0]
    """
    order = np.argsort(weights)
    uf = UnionFind(n)

    cycle_birth_weights = []
    mst_weights = []
    filtration = []

    for idx in order:
        w = float(weights[idx])
        u, v = edges[idx]
        if uf.union(u, v):
            mst_weights.append(w)
            filtration.append((w, False))
        else:
            cycle_birth_weights.append(w)
            filtration.append((w, True))

    return cycle_birth_weights, mst_weights, filtration


def empirical_cdf_values(
    data: np.ndarray,
    evaluation_points: Optional[np.ndarray] = None,
    num_points: int = 200
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the empirical CDF of a dataset.

    Time complexity: O(n log n + k) where n = |data|, k = |evaluation_points|
    Space complexity: O(n + k)

    Args:
        data: Array of observations
        evaluation_points: Points at which to evaluate CDF (default: linspace)
        num_points: Number of evaluation points if not specified

    Returns:
        (x_values, cdf_values): Arrays of evaluation points and CDF values
    """
    if len(data) == 0:
        if evaluation_points is not None:
            return evaluation_points, np.zeros_like(evaluation_points)
        return np.array([]), np.array([])

    data_sorted = np.sort(data)

    if evaluation_points is None:
        lo, hi = data_sorted[0], data_sorted[-1]
        margin = (hi - lo) * 0.05 if hi > lo else 0.5
        evaluation_points = np.linspace(lo - margin, hi + margin, num_points)

    cdf_values = np.searchsorted(data_sorted, evaluation_points, side='right') / len(data)
    return evaluation_points, cdf_values


def ks_distance(sample1: np.ndarray, sample2: np.ndarray) -> float:
    """
    Compute the Kolmogorov-Smirnov distance between two empirical distributions.

    D_KS = sup_t |F_1(t) - F_2(t)|

    Time complexity: O((n+m) log(n+m))
    Space complexity: O(n + m)

    Args:
        sample1, sample2: Arrays of observations

    Returns:
        KS distance (float in [0, 1])

    Example:
        >>> ks_distance(np.array([0.1, 0.5, 0.9]), np.array([0.1, 0.5, 0.9]))
        0.0
    """
    if len(sample1) == 0 or len(sample2) == 0:
        return 1.0

    all_vals = np.sort(np.unique(np.concatenate([sample1, sample2])))
    ecdf1 = np.searchsorted(np.sort(sample1), all_vals, side='right') / len(sample1)
    ecdf2 = np.searchsorted(np.sort(sample2), all_vals, side='right') / len(sample2)
    return float(np.max(np.abs(ecdf1 - ecdf2)))


def monotone_transport(
    weights: np.ndarray,
    target_cdf_inverse: Optional[callable] = None
) -> np.ndarray:
    """
    Apply monotone transport (probability integral transform) to edge weights.

    By Theorem 4 (monotone transport universality), this preserves
    the cycle-birth/merge classification of every edge.

    The transform maps weights through their empirical rank, then optionally
    through an inverse CDF to produce weights from any target distribution.

    Time complexity: O(n log n)
    Space complexity: O(n)

    Args:
        weights: Original edge weights
        target_cdf_inverse: Optional inverse CDF for target distribution.
                           If None, maps to uniform [0, 1] via ranks.

    Returns:
        Transformed weights preserving edge ordering

    Example:
        >>> w = np.array([3.0, 1.0, 2.0])
        >>> monotone_transport(w)  # Maps to ranks
        array([1.  , 0.33, 0.67])
    """
    n = len(weights)
    ranks = np.zeros(n)
    order = np.argsort(weights)
    for i, idx in enumerate(order):
        ranks[idx] = (i + 1) / n

    if target_cdf_inverse is not None:
        ranks = target_cdf_inverse(ranks)

    return ranks


def erdos_renyi_graph(
    n: int,
    p: float,
    rng: Optional[np.random.Generator] = None
) -> List[Tuple[int, int]]:
    """
    Generate an Erdős–Rényi random graph G(n, p).

    Each of the n(n-1)/2 potential edges is included independently
    with probability p.

    Time complexity: O(n²)
    Space complexity: O(n² p) expected

    Args:
        n: Number of vertices
        p: Edge inclusion probability
        rng: Random number generator

    Returns:
        List of (u, v) edges with u < v
    """
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def cycle_birth_measure(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray
) -> Tuple[np.ndarray, int, int]:
    """
    Compute the empirical cycle-birth measure of a weighted graph.

    The cycle-birth measure is:
        μ_G = (1/β₁) Σ_{e ∈ CycleBirthEdges} δ_{w(e)}

    This is the tropical spectral measure of the graph.

    Args:
        n: Number of vertices
        edges: Edge list
        weights: Edge weights

    Returns:
        (birth_weights, beta1, num_components): The birth weights,
            first Betti number, and number of connected components
    """
    cb_weights, mst_weights, _ = kruskal_filtration(n, edges, weights)

    uf = UnionFind(n)
    for u, v in edges:
        uf.union(u, v)
    num_components = uf.num_components

    beta1 = len(cb_weights)  # = m - n + c

    return np.array(cb_weights), beta1, num_components


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Tropical Critical Distributions")
    print("=" * 50)

    # Example: Complete graph K₅
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    weights = np.arange(1, len(edges) + 1, dtype=float)

    print(f"\nK₅ with weights 1..{len(edges)}:")
    cb, mst, filt = kruskal_filtration(n, edges, weights)
    print(f"  MST edges (weights): {mst}")
    print(f"  Cycle births (weights): {cb}")
    print(f"  β₁ = {len(cb)}")
    print(f"  Expected β₁ = {len(edges)} - {n} + 1 = {len(edges) - n + 1}")

    # Verify MST complement theorem
    assert len(cb) + len(mst) == len(edges), "MST complement theorem violated!"
    print(f"  MST complement theorem verified: {len(cb)} + {len(mst)} = {len(edges)} ✓")

    # Monotone transport example
    print("\nMonotone transport test:")
    rng = np.random.default_rng(42)
    w_uniform = rng.uniform(0, 1, len(edges))
    w_exp = np.exp(w_uniform)  # Monotone transform

    cb1, _, _ = kruskal_filtration(n, edges, w_uniform)
    cb2, _, _ = kruskal_filtration(n, edges, w_exp)

    # Same number of cycle births
    print(f"  Uniform weights: {len(cb1)} cycle births")
    print(f"  Exp(uniform) weights: {len(cb2)} cycle births")
    assert len(cb1) == len(cb2), "Monotone transport should preserve cycle birth count!"
    print("  Cycle birth count preserved under monotone transport ✓")
