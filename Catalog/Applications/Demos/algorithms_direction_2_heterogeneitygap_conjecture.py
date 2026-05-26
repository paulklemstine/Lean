#!/usr/bin/env python3
"""
Algorithms for Hypergraph Transversal Analysis

Implements certified computation of edge-size invariants, transversal
numbers, and fractional transversal bounds for finite hypergraphs.

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Set, Optional, FrozenSet
from collections import Counter
import itertools
import math


class Hypergraph:
    """A finite hypergraph on vertices {0, 1, ..., n-1}.

    Attributes:
        n_vertices: Number of vertices
        edges: List of edges, each a frozenset of vertex indices

    Example:
        >>> H = Hypergraph(5, [{0,1,2}, {1,3}, {2,3,4}])
        >>> H.edge_heterogeneity()
        0.222...
    """

    def __init__(self, n_vertices: int, edges: List[Set[int]]):
        self.n_vertices = n_vertices
        self.vertices = list(range(n_vertices))
        self.edges = [frozenset(e) for e in edges]

    def edge_sizes(self) -> List[int]:
        """Return list of edge cardinalities.

        Time: O(|E|)
        """
        return [len(e) for e in self.edges]

    def edge_heterogeneity(self) -> float:
        """Compute edge-size variance (heterogeneity).

        Formula: (1/|E|) Σ_e (|e| - d̄)²
        where d̄ = (1/|E|) Σ_e |e|

        Time: O(|E|)
        Space: O(1) beyond input

        Returns:
            Non-negative float. Zero iff all edges have the same size.

        Example:
            >>> H = Hypergraph(5, [{0,1}, {2,3,4}])
            >>> H.edge_heterogeneity()
            0.25
        """
        if not self.edges:
            return 0.0
        sizes = self.edge_sizes()
        n = len(sizes)
        mean = sum(sizes) / n
        return sum((s - mean) ** 2 for s in sizes) / n

    def edge_size_support_width(self) -> int:
        """Compute max edge size - min edge size.

        Time: O(|E|)

        Returns:
            Non-negative integer. Zero iff uniform or empty.
        """
        if not self.edges:
            return 0
        sizes = self.edge_sizes()
        return max(sizes) - min(sizes)

    def edge_size_distribution_support(self) -> Set[int]:
        """Return the set of distinct edge sizes.

        Time: O(|E|)
        """
        return set(self.edge_sizes())

    def edge_size_collision_index(self) -> float:
        """Compute collision index Σ_k p_k² of edge-size distribution.

        This is the Rényi 2-entropy exponent: exp(-H₂) = Σ p_k².
        Equals 1 iff uniform, strictly less than 1 iff non-uniform.

        Time: O(|E|)

        Example:
            >>> H = Hypergraph(4, [{0,1}, {2,3}])  # uniform
            >>> H.edge_size_collision_index()
            1.0
            >>> H = Hypergraph(5, [{0,1}, {2,3,4}])  # non-uniform
            >>> H.edge_size_collision_index()
            0.5
        """
        if not self.edges:
            return 1.0
        counts = Counter(self.edge_sizes())
        n = len(self.edges)
        return sum((c / n) ** 2 for c in counts.values())

    def is_transversal(self, S: Set[int]) -> bool:
        """Check if vertex set S intersects every edge.

        Time: O(|E| · |S|) in worst case
        """
        return all(S & e for e in self.edges)

    def transversal_number(self) -> int:
        """Compute exact transversal number τ(H) by brute force.

        Enumerates all subsets of vertices in order of increasing size.

        Time: O(2^n · |E| · n) worst case
        Space: O(n)

        Suitable only for n ≤ 20.
        """
        for size in range(self.n_vertices + 1):
            for subset in itertools.combinations(self.vertices, size):
                if self.is_transversal(set(subset)):
                    return size
        return self.n_vertices

    def fractional_transversal_number_lp(self) -> float:
        """Compute τ*(H) using linear programming.

        Solves: min Σ x_v  s.t. Σ_{v∈e} x_v ≥ 1 ∀e, x_v ≥ 0

        Time: polynomial (LP solver dependent)

        Falls back to greedy heuristic if scipy unavailable.
        """
        try:
            import numpy as np
            from scipy.optimize import linprog

            n = self.n_vertices
            m = len(self.edges)
            if m == 0:
                return 0.0

            c = np.ones(n)
            A_ub = np.zeros((m, n))
            b_ub = -np.ones(m)

            for i, e in enumerate(self.edges):
                for v in e:
                    A_ub[i, v] = -1.0

            bounds = [(0, None)] * n
            result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

            if result.success:
                return result.fun
            return self._greedy_fractional()
        except ImportError:
            return self._greedy_fractional()

    def _greedy_fractional(self) -> float:
        """Greedy approximation of τ* as fallback."""
        if not self.edges:
            return 0.0
        weights = {v: 0.0 for v in self.vertices}
        for e in self.edges:
            for v in e:
                weights[v] += 1.0 / len(e)
        # Scale to feasibility
        for _ in range(200):
            min_slack = min(sum(weights[v] for v in e) for e in self.edges)
            if min_slack >= 1.0 - 1e-10:
                break
            if min_slack > 0:
                scale = 1.0 / min_slack
                for v in self.vertices:
                    weights[v] *= scale
        # Reduce
        for _ in range(500):
            for v in sorted(self.vertices, key=lambda v: -weights[v]):
                if weights[v] <= 0:
                    continue
                min_slack = float('inf')
                for e in self.edges:
                    if v in e:
                        s = sum(weights[u] for u in e)
                        min_slack = min(min_slack, s - 1.0)
                if min_slack > 1e-10:
                    weights[v] -= min(weights[v], min_slack)
        return sum(weights.values())

    def integrality_gap(self) -> float:
        """Compute τ(H) - τ*(H)."""
        return self.transversal_number() - self.fractional_transversal_number_lp()

    def has_positive_ceil_gap(self) -> bool:
        """Check if τ(H) > ⌈τ*(H)⌉."""
        tau = self.transversal_number()
        tau_star = self.fractional_transversal_number_lp()
        return tau > math.ceil(tau_star)

    def edge_size_generating_polynomial_coeffs(self) -> Dict[int, int]:
        """Return coefficients of P_H(x) = Σ x^{|e|}.

        Returns dict mapping degree to coefficient.
        """
        coeffs: Dict[int, int] = {}
        for e in self.edges:
            d = len(e)
            coeffs[d] = coeffs.get(d, 0) + 1
        return coeffs

    def certified_analysis(self) -> Dict:
        """Run complete certified analysis of the hypergraph.

        Returns a dictionary with all computed invariants.
        """
        het = self.edge_heterogeneity()
        sw = self.edge_size_support_width()
        ci = self.edge_size_collision_index()
        supp = self.edge_size_distribution_support()
        tau = self.transversal_number()
        tau_star = self.fractional_transversal_number_lp()

        return {
            'n_vertices': self.n_vertices,
            'n_edges': len(self.edges),
            'edge_sizes': sorted(self.edge_sizes()),
            'heterogeneity': het,
            'support_width': sw,
            'collision_index': ci,
            'distribution_support': supp,
            'is_uniform': len(supp) <= 1,
            'tau': tau,
            'tau_star': round(tau_star, 6),
            'integrality_gap': round(tau - tau_star, 6),
            'ceil_gap': tau - math.ceil(tau_star),
            'has_positive_ceil_gap': tau > math.ceil(tau_star),
            'generating_poly_coeffs': self.edge_size_generating_polynomial_coeffs(),
        }


def verify_collision_index_theorem(H: Hypergraph) -> str:
    """Verify the collision index theorem computationally.

    Checks: CI = 1 iff uniform edge sizes.
    """
    ci = H.edge_size_collision_index()
    is_uniform = len(H.edge_size_distribution_support()) <= 1
    ci_is_one = abs(ci - 1.0) < 1e-10

    if ci_is_one == is_uniform:
        return f"VERIFIED: CI={ci:.6f}, uniform={is_uniform} (theorem holds)"
    else:
        return f"VIOLATION: CI={ci:.6f}, uniform={is_uniform} (theorem FAILS!)"


def verify_heterogeneity_theorem(H: Hypergraph) -> str:
    """Verify: two distinct edge sizes => positive heterogeneity."""
    supp = H.edge_size_distribution_support()
    het = H.edge_heterogeneity()

    if len(supp) >= 2:
        if het > 0:
            return f"VERIFIED: |support|={len(supp)}, het={het:.6f} > 0"
        else:
            return f"VIOLATION: |support|={len(supp)} ≥ 2 but het={het:.6f} = 0"
    else:
        return f"N/A: uniform (|support|={len(supp)}), het={het:.6f}"


def two_scale_family(m: int) -> Hypergraph:
    """Construct the explicit two-scale family H_m.

    Vertices: {0, ..., 2m}
    Small edges: {2i, 2i+1} for i=0,...,m-1
    Large edge: {0, 2, 4, ..., 2(m-1)}
    """
    n = 2 * m + 1
    edges: List[Set[int]] = []

    for i in range(m):
        edges.append({2 * i, 2 * i + 1})

    large = set(range(0, 2 * m, 2))
    if len(large) >= 2:
        edges.append(large)

    return Hypergraph(n, edges)


if __name__ == '__main__':
    print("=" * 50)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 50)

    # Example 1: Simple uniform hypergraph
    print("\n--- Example 1: Uniform hypergraph (all edges size 2) ---")
    H1 = Hypergraph(6, [{0, 1}, {2, 3}, {4, 5}])
    analysis = H1.certified_analysis()
    for k, v in analysis.items():
        print(f"  {k}: {v}")
    print(f"  {verify_collision_index_theorem(H1)}")
    print(f"  {verify_heterogeneity_theorem(H1)}")

    # Example 2: Non-uniform hypergraph
    print("\n--- Example 2: Non-uniform hypergraph ---")
    H2 = Hypergraph(6, [{0, 1}, {2, 3, 4}, {0, 1, 2, 3, 4, 5}])
    analysis = H2.certified_analysis()
    for k, v in analysis.items():
        print(f"  {k}: {v}")
    print(f"  {verify_collision_index_theorem(H2)}")
    print(f"  {verify_heterogeneity_theorem(H2)}")

    # Example 3: Two-scale family
    print("\n--- Example 3: Two-scale family ---")
    for m in range(2, 8):
        H = two_scale_family(m)
        a = H.certified_analysis()
        print(f"  m={m}: het={a['heterogeneity']:.4f}, CI={a['collision_index']:.4f}, "
              f"τ={a['tau']}, τ*={a['tau_star']}, gap={a['integrality_gap']}")
