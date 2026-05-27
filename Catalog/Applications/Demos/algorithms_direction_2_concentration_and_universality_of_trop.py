#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Cycle-Birth Analysis in Weighted Graphs

Implements the certified algorithms from the formal proofs:
1. Union-Find for component tracking
2. Kruskal-based cycle-birth classification
3. Empirical CDF computation
4. KS distance computation
5. Monotone transport verification

All algorithms have complexity analysis in docstrings.
"""

import numpy as np
from typing import List, Tuple, Set, Optional, Callable


class UnionFind:
    """
    Union-Find (Disjoint Set Union) data structure with path compression
    and union by rank.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
        - __init__: O(n)

    Space complexity: O(n)
    """

    def __init__(self, n: int):
        """Initialize n singleton components."""
        self.parent: List[int] = list(range(n))
        self.rank: List[int] = [0] * n
        self.num_components: int = n

    def find(self, x: int) -> int:
        """Find representative of x's component with path compression."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]  # path splitting
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """
        Merge components of x and y.
        Returns True if they were in different components (merge event).
        Returns False if already connected (cycle-birth event).
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False  # cycle birth
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True  # merge


def classify_edges(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray
) -> Tuple[List[float], Set[int], Set[int], List[bool]]:
    """
    Classify each edge as merge or cycle-birth by processing in weight order.

    This implements the filtration from the formal proof: edges are processed
    in increasing weight order, and each either merges two components or
    creates a cycle.

    Args:
        n: number of vertices
        edges: list of (u, v) pairs
        weights: array of edge weights

    Returns:
        cycle_birth_weights: weights at which cycles are born
        mst_edges: indices of merge (MST/forest) edges
        cycle_birth_edges: indices of cycle-birth edges
        classification: boolean list, True = cycle birth, False = merge

    Time complexity: O(m log m + m α(n)) where m = |edges|
    Space complexity: O(n + m)
    """
    m = len(edges)
    order = sorted(range(m), key=lambda i: weights[i])
    uf = UnionFind(n)

    cycle_birth_weights: List[float] = []
    mst_edges: Set[int] = set()
    cycle_birth_edges: Set[int] = set()
    classification: List[bool] = [False] * m

    for idx in order:
        u, v = edges[idx]
        if uf.union(u, v):
            mst_edges.add(idx)
            classification[idx] = False
        else:
            cycle_birth_weights.append(float(weights[idx]))
            cycle_birth_edges.add(idx)
            classification[idx] = True

    return cycle_birth_weights, mst_edges, cycle_birth_edges, classification


def cycle_birth_count_le(
    cycle_birth_weights: List[float],
    t: float
) -> int:
    """
    Count cycle births with weight ≤ t.

    This is the tropical spectral counting function N(t).

    Time complexity: O(|cycle_birth_weights|)
    Space complexity: O(1)
    """
    return sum(1 for w in cycle_birth_weights if w <= t)


def empirical_cycle_birth_cdf(
    cycle_birth_weights: List[float],
    t: float
) -> float:
    """
    Compute the empirical cycle-birth CDF at threshold t.

    F(t) = N(t) / β₁, where β₁ = total number of cycle births.

    Time complexity: O(|cycle_birth_weights|)
    Space complexity: O(1)
    """
    if len(cycle_birth_weights) == 0:
        return 0.0
    return cycle_birth_count_le(cycle_birth_weights, t) / len(cycle_birth_weights)


def empirical_cdf_array(
    cycle_birth_weights: List[float],
    thresholds: np.ndarray
) -> np.ndarray:
    """
    Compute empirical CDF at multiple thresholds efficiently.

    Time complexity: O(β₁ log β₁ + |thresholds| log β₁)
    Space complexity: O(β₁ + |thresholds|)
    """
    if len(cycle_birth_weights) == 0:
        return np.zeros(len(thresholds))
    sorted_births = np.sort(cycle_birth_weights)
    indices = np.searchsorted(sorted_births, thresholds, side='right')
    return indices / len(sorted_births)


def ks_distance(data1: np.ndarray, data2: np.ndarray) -> float:
    """
    Compute Kolmogorov-Smirnov distance between two empirical distributions.

    sup_t |F₁(t) - F₂(t)|

    Time complexity: O((n₁ + n₂) log(n₁ + n₂))
    Space complexity: O(n₁ + n₂)
    """
    if len(data1) == 0 or len(data2) == 0:
        return 1.0
    combined = np.sort(np.unique(np.concatenate([data1, data2])))
    max_diff = 0.0
    for t in combined:
        f1 = np.sum(data1 <= t) / len(data1)
        f2 = np.sum(data2 <= t) / len(data2)
        max_diff = max(max_diff, abs(f1 - f2))
    return max_diff


def verify_monotone_invariance(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray,
    phi: Callable[[np.ndarray], np.ndarray]
) -> bool:
    """
    Verify that a strictly monotone transformation preserves cycle-birth edge sets.

    This is the computational validation of Theorem 4 (universality).

    Args:
        n: number of vertices
        edges: edge list
        weights: original weights
        phi: strictly monotone function

    Returns:
        True if cycle-birth edge sets are identical

    Time complexity: O(m log m + m α(n))
    """
    _, _, cb_original, _ = classify_edges(n, edges, weights)
    transformed_weights = phi(weights)
    _, _, cb_transformed, _ = classify_edges(n, edges, transformed_weights)
    return cb_original == cb_transformed


def verify_mst_complement(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray
) -> bool:
    """
    Verify that cycle-birth edges are exactly the complement of MST edges.

    This is the computational validation of Theorem 5.

    Time complexity: O(m log m + m α(n))
    """
    _, mst, cb, _ = classify_edges(n, edges, weights)
    all_edges = set(range(len(edges)))
    return (mst | cb == all_edges) and (mst & cb == set())


def verify_lipschitz(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray,
    edge_idx: int,
    new_weight: float,
    thresholds: np.ndarray
) -> int:
    """
    Check the maximum change in cycle-birth count when one edge weight is modified.

    Should always return ≤ 1 (Theorem 2).

    Time complexity: O(m log m + m α(n) + |thresholds|)
    """
    births_orig, _, _, _ = classify_edges(n, edges, weights)
    weights_new = weights.copy()
    weights_new[edge_idx] = new_weight
    births_new, _, _, _ = classify_edges(n, edges, weights_new)

    max_change = 0
    for t in thresholds:
        c1 = cycle_birth_count_le(births_orig, t)
        c2 = cycle_birth_count_le(births_new, t)
        max_change = max(max_change, abs(c1 - c2))
    return max_change


def gnp_random_graph(
    n: int,
    p: float,
    rng: Optional[np.random.Generator] = None
) -> List[Tuple[int, int]]:
    """
    Generate G(n,p) Erdős-Rényi random graph.

    Time complexity: O(n²)
    Space complexity: O(n² p) expected
    """
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


# ─── Example usage ───

if __name__ == "__main__":
    print("Algorithms for Cycle-Birth Analysis")
    print("=" * 50)

    rng = np.random.default_rng(42)
    n, p = 100, 0.2
    edges = gnp_random_graph(n, p, rng)
    weights = rng.random(len(edges))

    births, mst, cb, classification = classify_edges(n, edges, weights)

    print(f"Graph: n={n}, m={len(edges)}")
    print(f"MST edges: {len(mst)}")
    print(f"Cycle births: {len(cb)} (β₁ = {len(cb)})")
    print(f"MST ∪ CB = all edges: {mst | cb == set(range(len(edges)))}")
    print(f"MST ∩ CB = ∅: {mst & cb == set()}")

    # Monotone invariance
    for name, phi in [("x²", lambda x: x**2), ("eˣ", np.exp), ("ln(x+1)", lambda x: np.log(x+1))]:
        ok = verify_monotone_invariance(n, edges, weights, phi)
        print(f"Monotone invariance ({name}): {ok}")

    # Lipschitz
    max_change = verify_lipschitz(n, edges, weights, 0, rng.random(),
                                   np.linspace(0, 1, 100))
    print(f"Lipschitz max change: {max_change} (should be ≤ 1)")
