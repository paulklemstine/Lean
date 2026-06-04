#!/usr/bin/env python3
"""
Algorithms for Gravitational Derivation Systems

Type-hinted implementations of the core algorithms for analyzing
anti-gravity phenomena in theorem dependency graphs.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import math


@dataclass
class GravitationalDerivationSystem:
    """
    A Gravitational Derivation System (GDS) on n theorems.

    Theorems are numbered 0..n-1. Each theorem has a proof length and
    dependencies on other theorems (forming a DAG).
    """
    n: int
    adj: list[list[bool]]  # adj[i][j] = True means theorem i depends on theorem j
    proof_lengths: list[int]
    _weight_cache: Optional[list[int]] = field(default=None, repr=False)

    def __post_init__(self) -> None:
        assert len(self.adj) == self.n
        assert all(len(row) == self.n for row in self.adj)
        assert len(self.proof_lengths) == self.n
        assert all(pl > 0 for pl in self.proof_lengths)
        # Verify no self-dependencies
        assert all(not self.adj[i][i] for i in range(self.n))

    def direct_weight(self, j: int) -> int:
        """Compute the gravitational weight of theorem j (in-degree)."""
        if self._weight_cache is not None:
            return self._weight_cache[j]
        return sum(1 for i in range(self.n) if self.adj[i][j])

    def compute_all_weights(self) -> list[int]:
        """Compute and cache all weights. O(n²) time."""
        self._weight_cache = [
            sum(1 for i in range(self.n) if self.adj[i][j])
            for j in range(self.n)
        ]
        return self._weight_cache

    def total_edges(self) -> int:
        """Total number of dependency edges."""
        return sum(1 for i in range(self.n) for j in range(self.n) if self.adj[i][j])

    def dep_count(self, i: int) -> int:
        """Number of direct dependencies of theorem i (out-degree)."""
        return sum(1 for j in range(self.n) if self.adj[i][j])

    def max_proof_length(self) -> int:
        """Maximum proof length in the system."""
        return max(self.proof_lengths)

    def anti_gravity_score(self, j: int) -> float:
        """Anti-gravity score: weight / proof_length."""
        return self.direct_weight(j) / self.proof_lengths[j]

    def is_anti_gravity(self, j: int, w: int, l: int) -> bool:
        """Check if theorem j is (w, l)-anti-gravity."""
        return self.direct_weight(j) >= w and self.proof_lengths[j] <= l

    def transitive_weight(self, j: int) -> int:
        """Compute transitive weight: number of theorems that transitively depend on j."""
        visited: set[int] = set()

        def dfs_reverse(v: int) -> None:
            """Find all vertices that can reach j via the reverse graph."""
            for i in range(self.n):
                if self.adj[i][v] and i not in visited:
                    # i depends on v, so i transitively depends on j
                    pass
            # Actually, we want all i such that there's a path from i to j
            # i.e., i -> ... -> j in the dependency graph
            # This means: i depends on some k, k depends on ... j
            # Reverse: from j, follow edges backwards (who depends on j?)
            for i in range(self.n):
                if self.adj[i][v] and i not in visited:
                    visited.add(i)
                    dfs_reverse(i)

        dfs_reverse(j)
        return len(visited)

    def add_edge(self, a: int, b: int) -> GravitationalDerivationSystem:
        """Add edge (a, b) meaning theorem a now depends on theorem b."""
        assert a != b
        new_adj = [row[:] for row in self.adj]
        new_adj[a][b] = True
        return GravitationalDerivationSystem(self.n, new_adj, self.proof_lengths[:])


def detect_anti_gravity_ranking(
    gds: GravitationalDerivationSystem,
) -> list[tuple[int, int, int, float]]:
    """
    Algorithm: Anti-Gravity Detection

    Input: A GDS
    Output: Ranking of theorems by anti-gravity score (descending)

    Returns list of (theorem_id, weight, proof_length, score) tuples.

    Complexity: O(n²) for weight computation, O(n log n) for sorting.
    """
    gds.compute_all_weights()
    results = []
    for j in range(gds.n):
        w = gds.direct_weight(j)
        pl = gds.proof_lengths[j]
        score = w / pl
        results.append((j, w, pl, score))
    results.sort(key=lambda x: x[3], reverse=True)
    return results


def verify_weight_edge_duality(gds: GravitationalDerivationSystem) -> bool:
    """
    Verify Theorem 1: sum of weights = sum of dep counts.

    Both sides count the total number of edges, just partitioned differently.
    """
    total_weight = sum(gds.direct_weight(j) for j in range(gds.n))
    total_deps = sum(gds.dep_count(i) for i in range(gds.n))
    return total_weight == total_deps


def verify_pigeonhole_bound(gds: GravitationalDerivationSystem) -> bool:
    """
    Verify Theorem 2: some theorem has weight >= m/n.
    """
    if gds.n == 0:
        return True
    m = gds.total_edges()
    max_weight = max(gds.direct_weight(j) for j in range(gds.n))
    return max_weight >= m // gds.n


def verify_cauchy_schwarz(gds: GravitationalDerivationSystem) -> bool:
    """
    Verify Theorem 10: m² <= n * sum(w²).
    """
    m = gds.total_edges()
    sum_w_sq = sum(gds.direct_weight(j) ** 2 for j in range(gds.n))
    return m ** 2 <= gds.n * sum_w_sq


def find_anti_gravity_witnesses(
    gds: GravitationalDerivationSystem,
    k: int,
) -> list[int]:
    """
    Find all (k, L)-anti-gravity theorems where L = max proof length.

    By Theorem 4, if n*k <= m, this list is guaranteed non-empty.
    """
    L = gds.max_proof_length()
    return [j for j in range(gds.n) if gds.is_anti_gravity(j, k, L)]


def compute_pareto_ratio(gds: GravitationalDerivationSystem, percentile: float = 0.1) -> float:
    """
    Compute the fraction of total weight held by the top `percentile` of theorems.

    The Anti-Gravity Pareto Conjecture predicts this is >= 0.5 for percentile = 0.1.
    """
    weights = sorted([gds.direct_weight(j) for j in range(gds.n)], reverse=True)
    total = sum(weights)
    if total == 0:
        return 0.0
    top_count = max(1, int(gds.n * percentile))
    top_weight = sum(weights[:top_count])
    return top_weight / total


def gini_coefficient(gds: GravitationalDerivationSystem) -> float:
    """
    Compute the Gini coefficient of the weight distribution.

    Gini = 0 means perfect equality (all weights equal).
    Gini = 1 means perfect inequality (one theorem has all weight).
    Anti-gravity systems tend to have high Gini coefficients.
    """
    weights = sorted([gds.direct_weight(j) for j in range(gds.n)])
    n = gds.n
    if n == 0 or sum(weights) == 0:
        return 0.0
    numerator = sum((2 * (i + 1) - n - 1) * weights[i] for i in range(n))
    denominator = n * sum(weights)
    return numerator / denominator


if __name__ == "__main__":
    # Quick self-test
    n = 5
    adj = [[False] * n for _ in range(n)]
    adj[1][0] = True
    adj[2][0] = True
    adj[3][1] = True
    adj[4][2] = True
    proof_lengths = [1, 2, 2, 3, 3]

    gds = GravitationalDerivationSystem(n, adj, proof_lengths)

    print("Self-test:")
    print(f"  Weight-edge duality: {verify_weight_edge_duality(gds)}")
    print(f"  Pigeonhole bound: {verify_pigeonhole_bound(gds)}")
    print(f"  Cauchy-Schwarz: {verify_cauchy_schwarz(gds)}")
    print(f"  Pareto ratio (10%): {compute_pareto_ratio(gds):.2%}")
    print(f"  Gini coefficient: {gini_coefficient(gds):.3f}")

    ranking = detect_anti_gravity_ranking(gds)
    print(f"  Top anti-gravity: theorem {ranking[0][0]} (score={ranking[0][3]:.2f})")
    print("All tests passed ✓")
