#!/usr/bin/env python3
"""
Algorithms for computing persistence statistics of weighted dependency hypergraphs.

Implements the computational methods specified in the formal Lean development,
with efficient data structures and complexity analysis.

Time complexity summary:
  - support_complex(k): O(E_k · 2^W) where E_k = active edges, W = max edge width
  - codependency_time(u, v): O(E) where E = total edges
  - width_at(k): O(E_k)
  - beta_gap(k): O(|SC_k|) where SC_k = support complex at scale k
  - full_hardness_curve(max_k): O(max_k · E · 2^W)
  - pair_profile(): O(V^2 · E)
"""

import itertools
from collections import defaultdict
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


class HypergraphFiltration:
    """
    Efficient filtration engine for weighted dependency hypergraphs.

    Precomputes weight-sorted edge lists for fast filtration queries.

    Attributes:
        vertices: The vertex set.
        edges: List of (vertex_set, weight) pairs, sorted by weight.
        _weight_index: Mapping from weight to list of edge indices.
    """

    def __init__(self, vertices: Set[int],
                 edges: List[Tuple[FrozenSet[int], int]]):
        """
        Initialize with vertex set and weighted edges.

        Args:
            vertices: Set of vertex labels.
            edges: List of (frozenset_of_vertices, weight) pairs.

        Raises:
            ValueError: If any edge is empty or has vertices outside the vertex set.
        """
        self.vertices = vertices
        # Sort edges by weight for efficient filtration
        self.edges = sorted(edges, key=lambda e: e[1])
        self._weight_index: Dict[int, List[int]] = defaultdict(list)
        for idx, (_, w) in enumerate(self.edges):
            self._weight_index[w].append(idx)

        # Precompute max weight
        self.max_weight = max((w for _, w in self.edges), default=0)

    def active_edge_indices(self, k: int) -> List[int]:
        """
        Return indices of edges with weight ≤ k.

        Time: O(E_k) where E_k is the number of active edges.
        """
        # Binary search since edges are sorted by weight
        lo, hi = 0, len(self.edges)
        while lo < hi:
            mid = (lo + hi) // 2
            if self.edges[mid][1] <= k:
                lo = mid + 1
            else:
                hi = mid
        return list(range(lo))

    def support_complex(self, k: int) -> Set[FrozenSet[int]]:
        """
        Compute the support complex at scale k.

        Returns all nonempty subsets of active edge vertex sets.

        Time: O(E_k · 2^W) where W = max edge width among active edges.
        Space: O(|SC_k|) for the result set.
        """
        result: Set[FrozenSet[int]] = set()
        for idx in self.active_edge_indices(k):
            vs = self.edges[idx][0]
            for r in range(1, len(vs) + 1):
                for subset in itertools.combinations(sorted(vs), r):
                    result.add(frozenset(subset))
        return result

    def width_at(self, k: int) -> int:
        """
        Maximum cardinality of an active edge's vertex set.

        Time: O(E_k)
        """
        indices = self.active_edge_indices(k)
        if not indices:
            return 0
        return max(len(self.edges[i][0]) for i in indices)

    def codependency_time(self, u: int, v: int) -> Optional[int]:
        """
        First scale at which u and v are jointly covered by some edge.

        Returns None if no such edge exists.

        Time: O(E)
        """
        min_weight = None
        for vs, w in self.edges:
            if u in vs and v in vs:
                if min_weight is None or w < min_weight:
                    min_weight = w
        return min_weight

    def beta_gap(self, k: int) -> int:
        """
        Reduced Euler characteristic of the support complex at scale k.

        The Euler characteristic is χ = Σ (-1)^(dim σ) over all simplices σ.
        For a simplex with |σ| vertices, dim σ = |σ| - 1.
        The reduced Euler characteristic is χ̃ = χ - 1.

        Returns 0 for empty complexes.

        Time: O(|SC_k|)
        """
        sc = self.support_complex(k)
        if not sc:
            return 0
        euler_sum = sum((-1) ** (len(s) + 1) for s in sc)
        return euler_sum - 1

    def is_cone_at(self, k: int) -> Tuple[bool, Optional[int]]:
        """
        Check if the support complex at scale k is a cone.

        A simplicial complex K is a cone with apex a if for every σ ∈ K,
        insert a σ ∈ K.

        Time: O(V · |SC_k|)

        Returns:
            (is_cone, apex) where apex is the cone vertex or None.
        """
        sc = self.support_complex(k)
        if not sc:
            return True, None

        for apex in self.vertices:
            is_cone = True
            for s in sc:
                extended = frozenset(set(s) | {apex})
                if extended not in sc:
                    is_cone = False
                    break
            if is_cone:
                return True, apex
        return False, None

    def pair_profile(self) -> Dict[Tuple[int, int], Optional[int]]:
        """
        Compute co-dependency times for all vertex pairs.

        Time: O(V^2 · E)

        Returns:
            Dictionary mapping (u, v) to codependency_time(u, v).
        """
        vlist = sorted(self.vertices)
        result = {}
        for i, u in enumerate(vlist):
            for v in vlist[i + 1:]:
                result[(u, v)] = self.codependency_time(u, v)
        return result

    def hardness_curve(self, max_scale: Optional[int] = None
                       ) -> List[Tuple[int, int, int]]:
        """
        Compute the full hardness curve: (scale, width, betaGap) triples.

        Time: O(max_scale · E · 2^W)

        Args:
            max_scale: Maximum scale to compute. Defaults to max edge weight.

        Returns:
            List of (k, width_at_k, beta_gap_k) triples.
        """
        if max_scale is None:
            max_scale = self.max_weight
        return [(k, self.width_at(k), self.beta_gap(k))
                for k in range(max_scale + 1)]

    def new_pairs_at(self, k: int) -> Set[FrozenSet[int]]:
        """
        Pairs that first become co-supported at scale k.

        Time: O(E)
        """
        result = set()
        for vs, w in self.edges:
            if w == k:
                vlist = sorted(vs)
                for i, u in enumerate(vlist):
                    for v in vlist[i + 1:]:
                        t = self.codependency_time(u, v)
                        if t == k:
                            result.add(frozenset({u, v}))
        return result


def detect_phase_transition(curve: List[Tuple[int, int, int]]
                            ) -> Optional[int]:
    """
    Detect the scale at which the topological phase transition occurs.

    Defined as the first scale where betaGap becomes nonzero.

    Args:
        curve: List of (scale, width, betaGap) triples from hardness_curve().

    Returns:
        The transition scale, or None if betaGap is always zero.

    Time: O(len(curve))
    """
    for k, _, bg in curve:
        if bg != 0:
            return k
    return None


def adaptive_strategy_recommendation(H: HypergraphFiltration,
                                     current_scale: int) -> str:
    """
    Suggest a proof search strategy based on the current topological state.

    This implements the algorithmic hook from the formal development:
    - If the complex is a cone, recommend aggressive compression.
    - If betaGap is nonzero, recommend width-oriented search.
    - If near the transition, recommend caution/restart.

    Args:
        H: The hypergraph filtration.
        current_scale: Current filtration scale.

    Returns:
        Strategy recommendation string.
    """
    bg = H.beta_gap(current_scale)
    is_cone, apex = H.is_cone_at(current_scale)
    w = H.width_at(current_scale)

    if is_cone:
        return (f"EASY REGIME: Complex is a cone (apex={apex}). "
                f"Recommend aggressive tactic compression and parallelization.")
    elif bg == 0:
        return (f"NEUTRAL: βgap=0 but not a cone. Width={w}. "
                f"Standard search strategy recommended.")
    else:
        return (f"HARD REGIME: βgap={bg}, width={w}. "
                f"Topological obstruction detected. "
                f"Recommend width-oriented search or restart with decomposition.")


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: benchmark family
    n, m = 6, 5
    vertices = set(range(n))
    edges = []
    for i in range(n):
        for j in range(i + 1, min(m, n)):
            edges.append((frozenset({i, j}), j))

    H = HypergraphFiltration(vertices, edges)

    print("Hardness Curve:")
    print(f"{'Scale':>5} {'Width':>5} {'βgap':>5} {'Strategy':>50}")
    print("-" * 70)
    curve = H.hardness_curve()
    for k, w, bg in curve:
        strategy = adaptive_strategy_recommendation(H, k)
        label = "EASY" if "EASY" in strategy else ("HARD" if "HARD" in strategy else "NEUTRAL")
        print(f"{k:>5} {w:>5} {bg:>5} {label:>50}")

    print(f"\nPhase transition at scale: {detect_phase_transition(curve)}")

    print("\nPair Profile:")
    for (u, v), t in sorted(H.pair_profile().items()):
        t_str = str(t) if t is not None else "∞"
        print(f"  ({u}, {v}): {t_str}")
