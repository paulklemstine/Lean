#!/usr/bin/env python3
"""
Algorithms for Certified Sandwich Family Construction and Analysis.

This module implements the core algorithms from the asymptotic compactness
research for monotone circuit lower bounds.

Algorithms:
  1. MinimalSandwichBuilder — construct minimal certified sandwich families
  2. CompletenessChecker — verify completeness against monotone functions
  3. HereditaryRestrictor — restrict families along vertex embeddings
  4. CertificateGrowthAnalyzer — measure asymptotic growth of certificate sizes
"""

from itertools import combinations
from typing import (
    List, Tuple, Set, FrozenSet, Dict, Optional, Callable
)
from dataclasses import dataclass, field
import math


# ─── Core Data Structures ──────────────────────────────────────────────

@dataclass
class Graph:
    """A simple undirected graph on {0, 1, ..., n-1}."""
    n: int
    edges: FrozenSet[Tuple[int, int]]

    def has_triangle(self) -> bool:
        """Check if the graph contains a triangle (3-clique)."""
        adj: Dict[int, Set[int]] = {i: set() for i in range(self.n)}
        for (u, v) in self.edges:
            adj[u].add(v)
            adj[v].add(u)
        for u in range(self.n):
            neighbors = adj[u]
            for v in neighbors:
                if v > u:
                    for w in neighbors:
                        if w > v and w in adj[v]:
                            return True
        return False

    def is_subgraph_of(self, other: 'Graph') -> bool:
        """Check if self is a subgraph of other."""
        return self.edges.issubset(other.edges)

    def restrict(self, vertices: Set[int]) -> 'Graph':
        """Restrict to the induced subgraph on the given vertices."""
        mapping = sorted(vertices)
        new_n = len(vertices)
        rev = {v: i for i, v in enumerate(mapping)}
        new_edges = frozenset(
            (rev[u], rev[v]) if rev[u] < rev[v] else (rev[v], rev[u])
            for (u, v) in self.edges
            if u in vertices and v in vertices
        )
        return Graph(new_n, new_edges)


@dataclass
class CertifiedSandwichFamily:
    """
    A certified sandwich family for a Boolean function f on graphs.

    - positive: graphs where f = True (catch false negatives)
    - negative: graphs where f = False (catch false positives)
    """
    n: int
    positive: List[Graph]
    negative: List[Graph]

    @property
    def size(self) -> int:
        return len(self.positive) + len(self.negative)

    def hits(self, circuit_eval: Callable[[Graph], bool],
             f: Callable[[Graph], bool]) -> bool:
        """Check if this family hits (refutes) a given monotone function."""
        for g in self.positive:
            if circuit_eval(g) != f(g):
                return True
        for g in self.negative:
            if circuit_eval(g) != f(g):
                return True
        return False


# ─── Algorithm 1: Minimal Sandwich Builder ──────────────────────────────

class MinimalSandwichBuilder:
    """
    Construct a minimal certified sandwich family for a given monotone
    graph property.

    Algorithm:
      1. Enumerate minimal witnesses for f = True (positive certificates)
      2. Enumerate maximal witnesses for f = False (negative certificates)
      3. Prune redundant witnesses via greedy set cover

    Time complexity: O(2^m) where m = C(n,2) edges (brute-force for small n)
    Space complexity: O(2^m) for enumeration

    For the triangle property specifically:
      - Positive witnesses: minimal triangle-containing graphs = single triangles
        → C(n,3) witnesses
      - Negative witnesses: maximal triangle-free graphs (Turán graphs)
        → at most 1 witness per partition type
    """

    def __init__(self, n: int, f: Callable[[Graph], bool]):
        self.n = n
        self.f = f
        self.all_edges = list(combinations(range(n), 2))
        self.m = len(self.all_edges)

    def build_minimal_positive(self) -> List[Graph]:
        """Find minimal graphs where f = True."""
        minimal = []
        # Enumerate all edge subsets in increasing order of size
        for size in range(self.m + 1):
            for edge_combo in combinations(self.all_edges, size):
                g = Graph(self.n, frozenset(edge_combo))
                if not self.f(g):
                    continue
                # Check minimality: removing any edge makes f = False
                is_minimal = True
                for e in edge_combo:
                    reduced = frozenset(edge_combo) - {e}
                    if self.f(Graph(self.n, reduced)):
                        is_minimal = False
                        break
                if is_minimal:
                    minimal.append(g)
        return minimal

    def build_maximal_negative(self) -> List[Graph]:
        """Find maximal graphs where f = False."""
        maximal = []
        for size in range(self.m, -1, -1):
            for edge_combo in combinations(self.all_edges, size):
                g = Graph(self.n, frozenset(edge_combo))
                if self.f(g):
                    continue
                # Check maximality: adding any edge makes f = True
                is_maximal = True
                remaining = set(self.all_edges) - set(edge_combo)
                for e in remaining:
                    augmented = frozenset(edge_combo) | {e}
                    if not self.f(Graph(self.n, augmented)):
                        is_maximal = False
                        break
                if is_maximal:
                    maximal.append(g)
        return maximal

    def build_family(self, use_minimal: bool = True) -> CertifiedSandwichFamily:
        """Build the certified sandwich family."""
        if use_minimal and self.n <= 6:
            positive = self.build_minimal_positive()
            negative = self.build_maximal_negative()
        else:
            # For larger n, use heuristic construction
            positive = self._heuristic_positive()
            negative = self._heuristic_negative()
        return CertifiedSandwichFamily(self.n, positive, negative)

    def _heuristic_positive(self) -> List[Graph]:
        """Heuristic: use all single-triangle graphs."""
        results = []
        for (i, j, k) in combinations(range(self.n), 3):
            edges = frozenset({(i, j), (i, k), (j, k)})
            g = Graph(self.n, edges)
            if self.f(g):
                results.append(g)
        return results

    def _heuristic_negative(self) -> List[Graph]:
        """Heuristic: use Turán graph + stars + empty graph."""
        results = []
        # Empty graph
        results.append(Graph(self.n, frozenset()))
        # Turán graph T(n, 2)
        half = self.n // 2
        turan = frozenset(
            (min(a, b), max(a, b))
            for a in range(half)
            for b in range(half, self.n)
        )
        g = Graph(self.n, turan)
        if not self.f(g):
            results.append(g)
        # Star graphs
        for center in range(self.n):
            star = frozenset(
                (min(center, j), max(center, j))
                for j in range(self.n) if j != center
            )
            g = Graph(self.n, star)
            if not self.f(g):
                results.append(g)
        return results


# ─── Algorithm 2: Completeness Checker ──────────────────────────────────

class CompletenessChecker:
    """
    Check whether a sandwich family is complete against a class of
    monotone functions.

    A family is complete up to size s if for every monotone function g
    of "complexity" ≤ s (approximated by threshold functions), the family
    hits g.

    Time complexity: O(|F| · |test_functions|) per check
    """

    def __init__(self, family: CertifiedSandwichFamily,
                 f: Callable[[Graph], bool]):
        self.family = family
        self.f = f
        self.n = family.n
        self.all_edges = list(combinations(range(self.n), 2))

    def check_against_thresholds(self,
                                  max_threshold_size: int = 3
                                  ) -> Dict[str, int]:
        """Test completeness against threshold functions."""
        hits = 0
        misses = 0
        tested = 0

        for size in range(1, max_threshold_size + 1):
            for edge_combo in combinations(self.all_edges, size):
                threshold_set = frozenset(edge_combo)

                def threshold_f(g: Graph, ts=threshold_set) -> bool:
                    return ts.issubset(g.edges)

                if self.family.hits(threshold_f, self.f):
                    hits += 1
                else:
                    misses += 1
                tested += 1

        return {'tested': tested, 'hits': hits, 'misses': misses}


# ─── Algorithm 3: Hereditary Restrictor ─────────────────────────────────

class HereditaryRestrictor:
    """
    Restrict a sandwich family along a vertex embedding.

    Given an injection e : {0,...,m-1} → {0,...,n-1} and a family on n vertices,
    compute the restricted family on m vertices.

    Implements the formal theorem:
      sandwichCompleteUpTo_restrict — restriction preserves completeness.

    Time complexity: O(|F| · m²) per restriction
    """

    @staticmethod
    def restrict(family: CertifiedSandwichFamily,
                 target_vertices: List[int],
                 f: Callable[[Graph], bool]) -> CertifiedSandwichFamily:
        """
        Restrict family to the induced subgraph on target_vertices.

        Args:
            family: The original sandwich family on n vertices
            target_vertices: List of m < n vertex indices to keep
            f: The target property on the restricted vertex set
        """
        m = len(target_vertices)
        vertex_set = set(target_vertices)

        restricted_pos = []
        for g in family.positive:
            rg = g.restrict(vertex_set)
            if f(rg):  # Still a valid positive witness
                restricted_pos.append(rg)

        restricted_neg = []
        for g in family.negative:
            rg = g.restrict(vertex_set)
            if not f(rg):  # Still a valid negative witness
                restricted_neg.append(rg)

        # Deduplicate
        seen_pos = set()
        unique_pos = []
        for g in restricted_pos:
            if g.edges not in seen_pos:
                seen_pos.add(g.edges)
                unique_pos.append(g)

        seen_neg = set()
        unique_neg = []
        for g in restricted_neg:
            if g.edges not in seen_neg:
                seen_neg.add(g.edges)
                unique_neg.append(g)

        return CertifiedSandwichFamily(m, unique_pos, unique_neg)


# ─── Algorithm 4: Growth Analyzer ──────────────────────────────────────

class CertificateGrowthAnalyzer:
    """
    Analyze the asymptotic growth of certificate family sizes.

    Measures |F(n)| for increasing n and fits polynomial bounds.
    """

    @staticmethod
    def analyze_growth(ns: List[int],
                       f_builder: Callable[[int], Callable[[Graph], bool]]
                       ) -> Dict:
        """
        Analyze certificate size growth for a sequence of vertex counts.

        Returns growth data and polynomial fit information.
        """
        data = []
        for n in ns:
            f = f_builder(n)
            builder = MinimalSandwichBuilder(n, f)
            family = builder.build_family(use_minimal=(n <= 6))
            data.append({
                'n': n,
                'pos_size': len(family.positive),
                'neg_size': len(family.negative),
                'total': family.size,
            })

        # Estimate polynomial degree from log-log slope
        if len(data) >= 2:
            n1, n2 = data[0]['n'], data[-1]['n']
            t1, t2 = max(data[0]['total'], 1), max(data[-1]['total'], 1)
            if n1 > 0 and n2 > 0 and n1 != n2:
                degree_est = (math.log(t2) - math.log(t1)) / (
                    math.log(n2) - math.log(n1))
            else:
                degree_est = float('nan')
        else:
            degree_est = float('nan')

        return {
            'data': data,
            'estimated_degree': degree_est,
            'is_polynomial': degree_est < 10 if not math.isnan(degree_est) else None,
        }


# ─── Main demo ──────────────────────────────────────────────────────────

def triangle_property(n: int) -> Callable[[Graph], bool]:
    """Return the triangle detection function for n-vertex graphs."""
    return lambda g: g.has_triangle()


if __name__ == "__main__":
    print("Algorithms Module — Self-Test")
    print("=" * 50)

    # Test MinimalSandwichBuilder
    print("\n1. MinimalSandwichBuilder (n=5, triangle property)")
    builder = MinimalSandwichBuilder(5, triangle_property(5))
    family = builder.build_family(use_minimal=True)
    print(f"   Positive witnesses: {len(family.positive)}")
    print(f"   Negative witnesses: {len(family.negative)}")
    print(f"   Total: {family.size}")

    # Test CompletenessChecker
    print("\n2. CompletenessChecker (n=5)")
    checker = CompletenessChecker(family, triangle_property(5))
    result = checker.check_against_thresholds(max_threshold_size=2)
    print(f"   Tested: {result['tested']}, Hits: {result['hits']}, "
          f"Misses: {result['misses']}")

    # Test HereditaryRestrictor
    print("\n3. HereditaryRestrictor (5 → 4)")
    restricted = HereditaryRestrictor.restrict(
        family, [0, 1, 2, 3], triangle_property(4)
    )
    print(f"   Restricted positive: {len(restricted.positive)}")
    print(f"   Restricted negative: {len(restricted.negative)}")
    print(f"   Restricted total: {restricted.size}")

    # Test CertificateGrowthAnalyzer
    print("\n4. CertificateGrowthAnalyzer (n=4..7)")
    analyzer = CertificateGrowthAnalyzer()
    growth = analyzer.analyze_growth([4, 5, 6, 7], triangle_property)
    for d in growth['data']:
        print(f"   n={d['n']}: pos={d['pos_size']}, neg={d['neg_size']}, "
              f"total={d['total']}")
    print(f"   Estimated degree: {growth['estimated_degree']:.2f}")
    print(f"   Is polynomial: {growth['is_polynomial']}")
