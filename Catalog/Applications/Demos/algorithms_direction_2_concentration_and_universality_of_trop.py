"""
Algorithms for Cycle-Birth Analysis in Weighted Graph Filtrations.

This module implements certified algorithms for computing cycle-birth edges,
empirical CDFs, and related statistics for weighted graphs. These correspond
to the formally verified definitions in the Lean formalization.

Application keywords: tropical Morse theory, persistent homology, minimum spanning tree,
graphic matroid, Kruskal duality, empirical process, KS distance.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class FiltrationStep:
    """A single step in the weighted graph filtration.

    Attributes:
        edge: Tuple (u, v) identifying the edge.
        weight: The edge weight.
        same_component: True if endpoints were already connected (cycle birth),
                        False if this edge merges two components.
    """
    edge: Tuple[int, int]
    weight: float
    same_component: bool


class UnionFind:
    """Union-Find data structure for tracking connected components.

    Time complexity: O(α(n)) amortized per operation, where α is the
    inverse Ackermann function.
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        """Find the root of the component containing x, with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Merge components of x and y. Returns True if a merge occurred (they were in different components)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False  # Already in same component → cycle birth
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True  # Merge event

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component."""
        return self.find(x) == self.find(y)


def compute_filtration(n: int, edges: List[Tuple[int, int, float]]) -> List[FiltrationStep]:
    """Compute the weighted graph filtration by inserting edges in weight order.

    This implements Kruskal's algorithm perspective: edges are inserted in order
    of increasing weight. Each insertion either merges two components (the edge
    would be in the MST) or creates a cycle (the edge is a cycle-birth edge).

    Args:
        n: Number of vertices.
        edges: List of (u, v, weight) triples.

    Returns:
        List of FiltrationStep objects in weight order.

    Time complexity: O(m log m + m α(n)) where m = len(edges).
    Space complexity: O(n + m).
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    steps = []
    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        steps.append(FiltrationStep(
            edge=(u, v),
            weight=w,
            same_component=not merged
        ))
    return steps


def cycle_birth_edges(steps: List[FiltrationStep]) -> List[FiltrationStep]:
    """Extract cycle-birth edges from a filtration.

    By Theorem 5 (MST complement), these are exactly the edges NOT in the
    minimum spanning tree/forest.

    Args:
        steps: Filtration steps from compute_filtration.

    Returns:
        List of FiltrationStep where same_component is True.
    """
    return [s for s in steps if s.same_component]


def cycle_birth_weights(steps: List[FiltrationStep]) -> np.ndarray:
    """Extract the weights of cycle-birth edges.

    These are the tropical critical values of the graph filtration.

    Args:
        steps: Filtration steps.

    Returns:
        Sorted array of cycle-birth weights.
    """
    return np.array([s.weight for s in steps if s.same_component])


def mst_edges(steps: List[FiltrationStep]) -> List[FiltrationStep]:
    """Extract MST edges from a filtration.

    By Theorem 5, these are exactly the complement of cycle-birth edges.

    Args:
        steps: Filtration steps.

    Returns:
        List of merge (non-cycle-birth) steps.
    """
    return [s for s in steps if not s.same_component]


def cycle_birth_count_le(steps: List[FiltrationStep], t: float) -> int:
    """Count cycle births with weight ≤ t.

    This is the cumulative cycle-birth counting function N_G(t).

    Args:
        steps: Filtration steps.
        t: Threshold.

    Returns:
        Number of cycle-birth edges with weight ≤ t.
    """
    return sum(1 for s in steps if s.same_component and s.weight <= t)


def empirical_cycle_birth_cdf(steps: List[FiltrationStep], t: float) -> float:
    """Compute the empirical cycle-birth CDF at threshold t.

    F_n(t) = (# cycle births with weight ≤ t) / (total # cycle births).

    Args:
        steps: Filtration steps.
        t: Threshold.

    Returns:
        CDF value in [0, 1], or 0 if no cycle births.
    """
    births = cycle_birth_weights(steps)
    if len(births) == 0:
        return 0.0
    return np.mean(births <= t)


def empirical_cdf_curve(steps: List[FiltrationStep],
                        grid: Optional[np.ndarray] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the full empirical cycle-birth CDF curve.

    Args:
        steps: Filtration steps.
        grid: Optional array of threshold values. If None, uses birth weights.

    Returns:
        Tuple of (thresholds, cdf_values).
    """
    births = cycle_birth_weights(steps)
    if len(births) == 0:
        if grid is None:
            return np.array([0.0, 1.0]), np.array([0.0, 0.0])
        return grid, np.zeros_like(grid)

    if grid is None:
        grid = np.sort(births)

    cdf_values = np.array([np.mean(births <= t) for t in grid])
    return grid, cdf_values


def ks_distance(cdf1: np.ndarray, cdf2: np.ndarray) -> float:
    """Compute the Kolmogorov-Smirnov distance between two empirical CDFs.

    Args:
        cdf1, cdf2: Arrays of CDF values evaluated on the same grid.

    Returns:
        Maximum absolute difference.
    """
    return float(np.max(np.abs(cdf1 - cdf2)))


def generate_erdos_renyi(n: int, p: float,
                         weight_distribution: str = 'uniform',
                         rng: Optional[np.random.Generator] = None
                         ) -> Tuple[int, List[Tuple[int, int, float]]]:
    """Generate an Erdős-Rényi random graph G(n,p) with random edge weights.

    Args:
        n: Number of vertices.
        p: Edge probability.
        weight_distribution: One of 'uniform', 'exponential', 'normal'.
        rng: Random number generator.

    Returns:
        Tuple of (n, edges) where edges is list of (u, v, weight).
    """
    if rng is None:
        rng = np.random.default_rng()

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                if weight_distribution == 'uniform':
                    w = rng.random()
                elif weight_distribution == 'exponential':
                    w = rng.exponential(1.0)
                elif weight_distribution == 'normal':
                    w = rng.normal(0, 1)
                else:
                    raise ValueError(f"Unknown distribution: {weight_distribution}")
                edges.append((i, j, w))
    return n, edges


def verify_mst_complement(n: int, edges: List[Tuple[int, int, float]]) -> bool:
    """Verify Theorem 5: cycle-birth edges = complement of MST edges.

    Checks that the set of cycle-birth edges and MST edges partition
    all edges, and that MST edges form a forest.

    Args:
        n: Number of vertices.
        edges: List of (u, v, weight) triples.

    Returns:
        True if the MST complement property holds.
    """
    steps = compute_filtration(n, edges)
    births = set(s.edge for s in steps if s.same_component)
    forest = set(s.edge for s in steps if not s.same_component)
    all_edges = set(s.edge for s in steps)

    # Check partition
    if births | forest != all_edges:
        return False
    if births & forest:
        return False

    # Check forest is acyclic (|forest| ≤ n - 1 for connected, ≤ n - components)
    uf = UnionFind(n)
    for u, v in forest:
        if not uf.union(u, v):
            return False  # Forest has a cycle!

    return True


def monotone_transport_test(n: int, edges_base: List[Tuple[int, int, float]],
                            phi: callable) -> bool:
    """Verify Theorem 4: monotone transport preserves cycle-birth classification.

    Args:
        n: Number of vertices.
        edges_base: Base edges with original weights.
        phi: Strictly monotone function to apply to weights.

    Returns:
        True if cycle-birth edges are identical under transport.
    """
    edges_transformed = [(u, v, phi(w)) for u, v, w in edges_base]

    steps_base = compute_filtration(n, edges_base)
    steps_trans = compute_filtration(n, edges_transformed)

    births_base = set(s.edge for s in steps_base if s.same_component)
    births_trans = set(s.edge for s in steps_trans if s.same_component)

    return births_base == births_trans


if __name__ == "__main__":
    # Example: K4 with weights 1..6
    n = 4
    edges = [(0, 1, 1), (0, 2, 2), (0, 3, 3), (1, 2, 4), (1, 3, 5), (2, 3, 6)]
    steps = compute_filtration(n, edges)

    print("K4 Filtration:")
    for s in steps:
        status = "CYCLE BIRTH" if s.same_component else "MERGE"
        print(f"  Edge {s.edge}, weight {s.weight}: {status}")

    births = cycle_birth_weights(steps)
    print(f"\nCycle-birth weights: {births}")
    print(f"Cycle count: {len(births)}")
    print(f"Merge count: {sum(1 for s in steps if not s.same_component)}")
    print(f"MST complement verified: {verify_mst_complement(n, edges)}")

    # Monotone transport test
    print(f"\nMonotone transport (x -> x^2): {monotone_transport_test(n, edges, lambda x: x**2)}")
    print(f"Monotone transport (x -> exp(x)): {monotone_transport_test(n, edges, lambda x: np.exp(x))}")
