#!/usr/bin/env python3
"""
Algorithms for Proof-Theoretic Locality Analysis

Implements the core algorithms from the research paper:
1. Cyclomatic number computation
2. Normalized cyclomatic density
3. Critical threshold finder
4. Proof-theoretic locality computation
5. Transition profile scanner

All algorithms have polynomial time complexity and are designed for
finite metric spaces arising from theorem dependency structures.

Usage:
    from algorithms import MetricSpace, ThresholdGraphAnalyzer
    ms = MetricSpace(points, dist_fn)
    analyzer = ThresholdGraphAnalyzer(ms)
    eps_star = analyzer.critical_threshold()
    localities = analyzer.locality_coefficients(eps_star)
"""

from __future__ import annotations
from collections import defaultdict
from typing import Callable, Any, Optional
import itertools


class SimpleGraph:
    """
    Simple undirected graph on n vertices {0, 1, ..., n-1}.

    Time complexity:
        - add_edge: O(1) amortized
        - has_edge: O(1) average
        - degree: O(1)
        - edges: O(n + m)
        - connected_components: O(n + m) via BFS
        - induced_subgraph: O(|S|^2)
    Space complexity: O(n + m)
    """

    def __init__(self, n: int):
        self.n = n
        self._adj: dict[int, set[int]] = defaultdict(set)

    def add_edge(self, u: int, v: int) -> None:
        """Add an undirected edge {u, v}. Self-loops are ignored."""
        if u != v:
            self._adj[u].add(v)
            self._adj[v].add(u)

    def has_edge(self, u: int, v: int) -> bool:
        return v in self._adj[u]

    def degree(self, v: int) -> int:
        return len(self._adj[v])

    def neighbors(self, v: int) -> set[int]:
        return set(self._adj[v])

    def edges(self) -> set[tuple[int, int]]:
        seen: set[tuple[int, int]] = set()
        for u in range(self.n):
            for v in self._adj[u]:
                edge = (min(u, v), max(u, v))
                if edge not in seen:
                    seen.add(edge)
        return seen

    def num_edges(self) -> int:
        return len(self.edges())

    def closed_neighborhood(self, v: int) -> set[int]:
        """Return N[v] = {v} ∪ N(v)."""
        return {v} | self._adj[v]

    def connected_components(self) -> list[set[int]]:
        """BFS-based connected components. O(n + m)."""
        visited: set[int] = set()
        components: list[set[int]] = []
        for v in range(self.n):
            if v not in visited:
                comp: set[int] = set()
                queue = [v]
                while queue:
                    u = queue.pop(0)
                    if u not in visited:
                        visited.add(u)
                        comp.add(u)
                        queue.extend(self._adj[u] - visited)
                components.append(comp)
        return components

    def num_connected_components(self) -> int:
        return len(self.connected_components())

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited: set[int] = set()
        queue = [0]
        while queue:
            u = queue.pop(0)
            if u not in visited:
                visited.add(u)
                queue.extend(self._adj[u] - visited)
        return len(visited) == self.n

    def induced_subgraph(self, vertices: set[int]) -> 'SimpleGraph':
        """
        Return the induced subgraph on a subset of vertices.
        Vertices are re-indexed 0..len(vertices)-1.
        Returns (subgraph, index_map) where index_map maps new → old indices.
        """
        vertex_list = sorted(vertices)
        n = len(vertex_list)
        old_to_new = {v: i for i, v in enumerate(vertex_list)}
        H = SimpleGraph(n)
        for u in vertex_list:
            for v in self._adj[u]:
                if v in old_to_new and u < v:
                    H.add_edge(old_to_new[u], old_to_new[v])
        return H


def cyclomatic_number(G: SimpleGraph) -> int:
    """
    Compute the cyclomatic number (first Betti number) of graph G.

    r(G) = |E| - |V| + |CC|

    where |CC| is the number of connected components.

    Time complexity: O(n + m)
    Space complexity: O(n)

    Returns:
        The cyclomatic number, always ≥ 0.
    """
    return G.num_edges() - G.n + G.num_connected_components()


def normalized_cyclomatic_density(G: SimpleGraph) -> float:
    """
    Compute the normalized cyclomatic density φ(G) = r(G) / |E(G)|.

    This measures the fraction of edges that participate in creating
    cyclic structure rather than maintaining connectivity.

    Time complexity: O(n + m)

    Returns:
        φ(G) ∈ [0, 1). Returns 0.0 if |E| = 0.
    """
    m = G.num_edges()
    if m == 0:
        return 0.0
    return cyclomatic_number(G) / m


def proof_theoretic_locality(G: SimpleGraph, v: int) -> float:
    """
    Compute the proof-theoretic locality L_G(v).

    L_G(v) = r(G[N[v]]) / r(G)

    where N[v] is the closed neighborhood and r is the cyclomatic number.

    Time complexity: O(d^2 + n + m) where d = deg(v)

    Returns:
        L_G(v) ≥ 0. Returns 0.0 if r(G) ≤ 0.
    """
    r_global = cyclomatic_number(G)
    if r_global <= 0:
        return 0.0
    nbhd = G.closed_neighborhood(v)
    H = G.induced_subgraph(nbhd)
    r_local = cyclomatic_number(H)
    return max(0, r_local) / r_global


class MetricSpace:
    """
    A finite metric space with elements and a distance function.

    Args:
        elements: List of elements of any type.
        dist_fn: Distance function (element, element) → int.
                 Must be symmetric with dist(x, x) = 0.
    """

    def __init__(self, elements: list[Any], dist_fn: Callable[[Any, Any], int]):
        self.elements = list(elements)
        self.n = len(self.elements)
        self.dist_fn = dist_fn

        # Precompute distance matrix
        self._dist_matrix: list[list[int]] = [
            [0] * self.n for _ in range(self.n)
        ]
        self._distinct_distances: set[int] = set()
        for i in range(self.n):
            for j in range(i + 1, self.n):
                d = dist_fn(elements[i], elements[j])
                self._dist_matrix[i][j] = d
                self._dist_matrix[j][i] = d
                if d > 0:
                    self._distinct_distances.add(d)

    def dist(self, i: int, j: int) -> int:
        """Distance between elements at indices i and j."""
        return self._dist_matrix[i][j]

    def distinct_distances(self) -> list[int]:
        """All distinct nonzero pairwise distances, sorted."""
        return sorted(self._distinct_distances)


class ThresholdGraphAnalyzer:
    """
    Analyzer for semantic threshold graph families.

    Given a finite metric space, builds threshold graphs at various ε
    and computes topological invariants.

    Time complexity:
        - build_graph: O(n^2)
        - transition_profile: O(D × n^2) where D = |distinct distances|
        - critical_threshold: O(D × n^2)
        - locality_coefficients: O(n × d_max^2 + n^2)

    Space complexity: O(n^2)
    """

    def __init__(self, metric_space: MetricSpace):
        self.ms = metric_space

    def build_graph(self, epsilon: int) -> SimpleGraph:
        """Build the threshold graph at threshold ε. O(n^2)."""
        G = SimpleGraph(self.ms.n)
        for i in range(self.ms.n):
            for j in range(i + 1, self.ms.n):
                if self.ms.dist(i, j) <= epsilon:
                    G.add_edge(i, j)
        return G

    def transition_profile(
        self, thresholds: Optional[list[int]] = None
    ) -> list[dict]:
        """
        Compute the full transition profile.

        Args:
            thresholds: List of thresholds to evaluate.
                       Default: all distinct distances.

        Returns:
            List of dicts with keys: epsilon, edges, vertices,
            components, cyclomatic_number, density.
        """
        if thresholds is None:
            thresholds = self.ms.distinct_distances()

        profile = []
        for eps in thresholds:
            G = self.build_graph(eps)
            r = cyclomatic_number(G)
            phi = normalized_cyclomatic_density(G)
            profile.append({
                'epsilon': eps,
                'edges': G.num_edges(),
                'vertices': G.n,
                'components': G.num_connected_components(),
                'cyclomatic_number': r,
                'density': phi,
                'connected': G.is_connected(),
            })
        return profile

    def critical_threshold(self) -> tuple[int, float]:
        """
        Find the critical threshold ε* maximizing normalized cyclomatic density.

        Returns:
            (ε*, φ(ε*))
        """
        profile = self.transition_profile()
        if not profile:
            return 0, 0.0

        best = max(profile, key=lambda p: p['density'])
        return best['epsilon'], best['density']

    def locality_coefficients(self, epsilon: int) -> list[float]:
        """
        Compute proof-theoretic locality for all vertices at threshold ε.

        Returns:
            List of L_G(v) for v = 0, ..., n-1.
        """
        G = self.build_graph(epsilon)
        return [proof_theoretic_locality(G, v) for v in range(self.ms.n)]

    def verify_neighborhood_bound(self, epsilon: int) -> list[dict]:
        """
        Verify the neighborhood cyclomatic bound r(G[N[v]]) ≤ d*(d-1)/2
        for all vertices.

        Returns:
            List of verification results.
        """
        G = self.build_graph(epsilon)
        results = []
        for v in range(self.ms.n):
            d = G.degree(v)
            nbhd = G.closed_neighborhood(v)
            H = G.induced_subgraph(nbhd)
            r_local = cyclomatic_number(H)
            bound = d * (d - 1) // 2
            results.append({
                'vertex': v,
                'degree': d,
                'local_cyclomatic': r_local,
                'bound': bound,
                'satisfied': r_local <= bound,
            })
        return results


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    import numpy as np

    print("Algorithms Module — Example Usage")
    print("=" * 50)

    # Create a metric space from random points
    np.random.seed(42)
    n = 15
    points = np.random.randn(n, 3) * 5

    def euclidean_dist(p, q):
        return int(np.round(np.linalg.norm(np.array(p) - np.array(q))))

    ms = MetricSpace([tuple(p) for p in points], euclidean_dist)
    analyzer = ThresholdGraphAnalyzer(ms)

    # Find critical threshold
    eps_star, phi_star = analyzer.critical_threshold()
    print(f"Critical threshold ε*: {eps_star}")
    print(f"Maximum density φ*: {phi_star:.4f}")

    # Compute localities
    localities = analyzer.locality_coefficients(eps_star)
    print(f"\nLocality coefficients at ε* = {eps_star}:")
    for v, loc in enumerate(localities):
        print(f"  v{v}: L = {loc:.4f}")

    # Verify bounds
    results = analyzer.verify_neighborhood_bound(eps_star)
    violations = sum(1 for r in results if not r['satisfied'])
    print(f"\nBound verification: {violations} violations out of {n} vertices")

    # Show transition profile
    profile = analyzer.transition_profile()
    print(f"\nTransition profile:")
    print(f"{'ε':>5} | {'|E|':>5} | {'r':>4} | {'φ':>8} | {'conn':>5}")
    for p in profile[:15]:  # Show first 15
        print(f"{p['epsilon']:5d} | {p['edges']:5d} | {p['cyclomatic_number']:4d} | "
              f"{p['density']:8.4f} | {'yes' if p['connected'] else 'no':>5}")
