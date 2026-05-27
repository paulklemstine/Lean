"""
Algorithms for Cycle-Birth Analysis in Weighted Graphs

Implements the core algorithms from the tropical spectral theory:
- Union-Find for efficient component tracking
- Kruskal-based cycle-birth detection
- Empirical CDF computation
- KS distance calculation

All algorithms are backed by the formally verified theorems in the Lean code.
"""

from __future__ import annotations
import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass, field


class UnionFind:
    """Weighted Union-Find with path compression and union by rank.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
        - connected: O(α(n)) amortized

    Space complexity: O(n)
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        """Find root with path compression."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if a merge occurred (different components)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False  # same component → cycle birth
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True  # merge event

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)


@dataclass
class FiltrationStep:
    """A single step in the weight filtration.

    Attributes:
        u, v: Edge endpoints
        weight: Edge weight
        is_cycle_birth: True if endpoints were already connected (cycle birth),
                        False if they were in different components (merge)
    """
    u: int
    v: int
    weight: float
    is_cycle_birth: bool


@dataclass
class FiltrationResult:
    """Complete result of processing a weighted graph filtration.

    Attributes:
        n: Number of vertices
        steps: Ordered list of filtration steps
        cycle_birth_weights: Weights at which cycles are born
        merge_weights: Weights at which components merge
        mst_edges: Set of edges in the minimum spanning tree/forest
        non_mst_edges: Set of edges NOT in the MST (= cycle-birth edges)
    """
    n: int
    steps: List[FiltrationStep] = field(default_factory=list)
    cycle_birth_weights: List[float] = field(default_factory=list)
    merge_weights: List[float] = field(default_factory=list)
    mst_edges: Set[Tuple[int, int]] = field(default_factory=set)
    non_mst_edges: Set[Tuple[int, int]] = field(default_factory=set)


def compute_filtration(n: int, edges: List[Tuple[int, int, float]]) -> FiltrationResult:
    """Compute the weight filtration of a graph using Kruskal's algorithm.

    This is the certified algorithm: process edges in weight order,
    track connectivity via Union-Find, classify each edge as merge or cycle birth.

    By Theorem 5 (cycleBirth_eq_complement_forest), cycle-birth edges are
    exactly the non-MST edges.

    Args:
        n: Number of vertices
        edges: List of (u, v, weight) tuples

    Returns:
        FiltrationResult with complete classification

    Time complexity: O(m log m + m α(n)) where m = |edges|
    Space complexity: O(n + m)

    Example:
        >>> result = compute_filtration(3, [(0, 1, 1.0), (1, 2, 2.0), (0, 2, 3.0)])
        >>> result.cycle_birth_weights
        [3.0]
        >>> len(result.mst_edges)
        2
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    result = FiltrationResult(n=n)

    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        is_cycle = not merged
        step = FiltrationStep(u=u, v=v, weight=w, is_cycle_birth=is_cycle)
        result.steps.append(step)

        edge = (min(u, v), max(u, v))
        if is_cycle:
            result.cycle_birth_weights.append(w)
            result.non_mst_edges.add(edge)
        else:
            result.merge_weights.append(w)
            result.mst_edges.add(edge)

    return result


def empirical_cdf(values: List[float], t: float) -> float:
    """Compute the empirical CDF at threshold t.

    F_n(t) = (1/n) * |{i : values[i] ≤ t}|

    This corresponds to WFiltration.empiricalCycleBirthCDF in the Lean code.

    Args:
        values: Sample values
        t: Threshold

    Returns:
        Empirical CDF value in [0, 1]

    Example:
        >>> empirical_cdf([1.0, 2.0, 3.0], 2.5)
        0.6666666666666666
    """
    if not values:
        return 0.0
    count = sum(1 for v in values if v <= t)
    return count / len(values)


def empirical_cdf_values(values: List[float], grid: np.ndarray) -> np.ndarray:
    """Compute the empirical CDF on a grid of thresholds.

    Args:
        values: Sample values
        grid: Array of threshold values

    Returns:
        Array of CDF values
    """
    sorted_vals = np.sort(values)
    return np.searchsorted(sorted_vals, grid, side='right') / len(sorted_vals)


def ks_distance(values1: List[float], values2: List[float],
                grid_size: int = 1000) -> float:
    """Compute the Kolmogorov-Smirnov distance between two empirical distributions.

    KS(F, G) = sup_t |F(t) - G(t)|

    This is the metric used to test concentration and universality.

    Args:
        values1, values2: Two samples
        grid_size: Number of grid points for approximation

    Returns:
        KS distance in [0, 1]

    Example:
        >>> ks_distance([1.0, 2.0, 3.0], [1.1, 2.1, 3.1])  # small distance
        0.0  # approximately
    """
    if not values1 or not values2:
        return 1.0

    all_vals = sorted(set(values1 + values2))
    lo, hi = all_vals[0], all_vals[-1]
    if lo == hi:
        return 0.0

    grid = np.linspace(lo - 0.01 * (hi - lo), hi + 0.01 * (hi - lo), grid_size)
    cdf1 = empirical_cdf_values(values1, grid)
    cdf2 = empirical_cdf_values(values2, grid)
    return float(np.max(np.abs(cdf1 - cdf2)))


def sample_erdos_renyi(n: int, p: float,
                       weight_dist: str = 'uniform',
                       rng: Optional[np.random.Generator] = None
                       ) -> Tuple[int, List[Tuple[int, int, float]]]:
    """Sample an Erdős–Rényi random graph G(n,p) with random edge weights.

    Args:
        n: Number of vertices
        p: Edge probability
        weight_dist: 'uniform', 'exponential', or 'normal'
        rng: Random number generator (for reproducibility)

    Returns:
        (n, edges) where edges is a list of (u, v, weight) tuples

    Example:
        >>> rng = np.random.default_rng(42)
        >>> n, edges = sample_erdos_renyi(10, 0.5, rng=rng)
        >>> len(edges) > 0
        True
    """
    if rng is None:
        rng = np.random.default_rng()

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                if weight_dist == 'uniform':
                    w = rng.random()
                elif weight_dist == 'exponential':
                    w = rng.exponential(1.0)
                elif weight_dist == 'normal':
                    w = rng.normal(0.0, 1.0)
                else:
                    raise ValueError(f"Unknown weight distribution: {weight_dist}")
                edges.append((i, j, w))

    return n, edges


def cycle_birth_analysis(n: int, p: float,
                         weight_dist: str = 'uniform',
                         rng: Optional[np.random.Generator] = None
                         ) -> FiltrationResult:
    """Complete cycle-birth analysis of a random graph.

    Combines sampling and filtration computation.

    Args:
        n: Number of vertices
        p: Edge probability
        weight_dist: Weight distribution type
        rng: Random number generator

    Returns:
        FiltrationResult with full analysis
    """
    n_verts, edges = sample_erdos_renyi(n, p, weight_dist, rng)
    return compute_filtration(n_verts, edges)


def verify_mst_complement(result: FiltrationResult) -> bool:
    """Verify Theorem 5: cycle-birth edges = complement of MST edges.

    This is a computational validation of cycleBirth_eq_complement_forest.

    Args:
        result: FiltrationResult from compute_filtration

    Returns:
        True if the theorem holds (should always be True)

    Example:
        >>> result = compute_filtration(4, [(0,1,1),(1,2,2),(2,3,3),(0,2,4),(1,3,5),(0,3,6)])
        >>> verify_mst_complement(result)
        True
    """
    all_edges = set()
    for step in result.steps:
        edge = (min(step.u, step.v), max(step.u, step.v))
        all_edges.add(edge)

    # Check partition
    if result.mst_edges | result.non_mst_edges != all_edges:
        return False
    if result.mst_edges & result.non_mst_edges:
        return False

    # Check cycle-birth edges = non-MST edges
    cycle_edges = set()
    for step in result.steps:
        if step.is_cycle_birth:
            edge = (min(step.u, step.v), max(step.u, step.v))
            cycle_edges.add(edge)

    return cycle_edges == result.non_mst_edges


def verify_monotone_invariance(n: int, edges_base: List[Tuple[int, int, float]],
                                phi) -> bool:
    """Verify Theorem 4: strictly monotone transport preserves cycle-birth classification.

    Args:
        n: Number of vertices
        edges_base: Original edges with weights
        phi: A strictly monotone function

    Returns:
        True if cycle-birth edge sets are identical

    Example:
        >>> edges = [(0,1,1.0), (1,2,2.0), (0,2,3.0)]
        >>> verify_monotone_invariance(3, edges, lambda x: 2*x + 1)
        True
    """
    result1 = compute_filtration(n, edges_base)
    edges_transformed = [(u, v, phi(w)) for u, v, w in edges_base]
    result2 = compute_filtration(n, edges_transformed)

    births1 = [s.is_cycle_birth for s in result1.steps]
    births2 = [s.is_cycle_birth for s in result2.steps]
    return births1 == births2
