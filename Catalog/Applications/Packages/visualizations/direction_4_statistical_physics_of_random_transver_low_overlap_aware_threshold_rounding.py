"""
algorithms.py — Low-overlap-aware threshold rounding for hypergraph transversals.

Implements the key algorithmic insights from the formal theory:
1. Fractional transversal LP relaxation via linear programming
2. Overlap profile computation (pair-codegree statistics)
3. Threshold rounding with overlap-aware parameter tuning
4. Greedy repair for uncovered edges
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Dict, Optional
from scipy.optimize import linprog


class Hypergraph:
    """A finite hypergraph on vertex set {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Set[int]]):
        self.n = n
        self.edges = [frozenset(e) for e in edges]
        self.m = len(self.edges)

    def degree(self, v: int) -> int:
        """Number of edges containing vertex v."""
        return sum(1 for e in self.edges if v in e)

    def pair_codegree(self, u: int, v: int) -> int:
        """Number of edges containing both u and v."""
        return sum(1 for e in self.edges if u in e and v in e)

    def max_pair_codegree(self) -> int:
        """Maximum pair-codegree over all distinct vertex pairs."""
        max_cod = 0
        vertices_in_edges = set()
        for e in self.edges:
            vertices_in_edges.update(e)
        vlist = sorted(vertices_in_edges)
        for i, u in enumerate(vlist):
            for v in vlist[i+1:]:
                cod = self.pair_codegree(u, v)
                max_cod = max(max_cod, cod)
        return max_cod

    def overlap_profile(self) -> Dict[str, float]:
        """Compute overlap profile statistics."""
        max_cod = self.max_pair_codegree()
        return {
            'max_pair_codegree': max_cod,
            'normalized_overlap': max_cod / max(self.m, 1),
            'is_linear': max_cod <= 1,
            'is_disjoint': max_cod == 0,
        }

    def is_uniform(self) -> Tuple[bool, int]:
        """Check if hypergraph is d-uniform; return (is_uniform, d)."""
        if not self.edges:
            return True, 0
        d = len(self.edges[0])
        return all(len(e) == d for e in self.edges), d

    def is_transversal(self, S: Set[int]) -> bool:
        """Check if S is a transversal (hits every edge)."""
        return all(S & e for e in self.edges)


def random_uniform_hypergraph(n: int, m: int, d: int, rng=None) -> Hypergraph:
    """Generate a random d-uniform hypergraph on n vertices with m edges.

    Edges are sampled uniformly at random (with replacement for simplicity).
    """
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    vertices = list(range(n))
    for _ in range(m):
        edge = set(rng.choice(vertices, size=d, replace=False))
        edges.append(edge)
    return Hypergraph(n, edges)


def solve_fractional_transversal_lp(H: Hypergraph) -> Tuple[float, np.ndarray]:
    """Solve the fractional transversal LP relaxation.

    Minimize ∑ x(v) subject to:
        ∑_{v ∈ e} x(v) ≥ 1 for all edges e
        x(v) ≥ 0 for all v

    Returns (optimal_value, optimal_x).
    """
    n = H.n
    if not H.edges:
        return 0.0, np.zeros(n)

    c = np.ones(n)  # minimize sum of x
    # Constraints: -∑_{v∈e} x(v) ≤ -1
    A_ub = np.zeros((len(H.edges), n))
    b_ub = -np.ones(len(H.edges))
    for i, e in enumerate(H.edges):
        for v in e:
            A_ub[i, v] = -1

    bounds = [(0, None) for _ in range(n)]
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return result.fun, result.x
    else:
        return float('inf'), np.ones(n)


def threshold_rounding(x: np.ndarray, d: int) -> Set[int]:
    """Standard threshold rounding at 1/d."""
    threshold = 1.0 / d
    return {v for v in range(len(x)) if x[v] >= threshold}


def low_overlap_rounding(H: Hypergraph, x: np.ndarray, d: int,
                          overlap_stats: Optional[Dict] = None) -> Set[int]:
    """Overlap-aware threshold rounding.

    If the hypergraph has low overlap (disjoint or near-linear edges),
    we can use an improved threshold that exploits the structure.

    For disjoint edges (max_pair_codegree = 0), we pick one max-weight
    vertex per edge, achieving factor 1 instead of d.

    For linear hypergraphs (max_pair_codegree ≤ 1), we use an intermediate strategy.
    """
    if overlap_stats is None:
        overlap_stats = H.overlap_profile()

    if overlap_stats['is_disjoint']:
        # Pick the vertex with highest x-value from each edge
        S = set()
        for e in H.edges:
            best_v = max(e, key=lambda v: x[v])
            S.add(best_v)
        return S
    elif overlap_stats['is_linear']:
        # Use threshold 1/(d-0.5) for slight improvement
        threshold = 1.0 / max(d - 0.5, 1)
        S = {v for v in range(len(x)) if x[v] >= threshold}
        # Greedy repair
        for e in H.edges:
            if not S & e:
                best_v = max(e, key=lambda v: x[v])
                S.add(best_v)
        return S
    else:
        # Standard threshold + greedy repair
        S = threshold_rounding(x, d)
        for e in H.edges:
            if not S & e:
                best_v = max(e, key=lambda v: x[v])
                S.add(best_v)
        return S


def greedy_transversal(H: Hypergraph) -> Set[int]:
    """Greedy transversal: iteratively pick the highest-degree uncovered vertex."""
    uncovered = list(range(len(H.edges)))
    covered = [False] * len(H.edges)
    S = set()

    while uncovered:
        # Count how many uncovered edges each vertex hits
        vertex_hits = {}
        for idx in uncovered:
            for v in H.edges[idx]:
                vertex_hits[v] = vertex_hits.get(v, 0) + 1
        if not vertex_hits:
            break
        # Pick vertex with most hits
        best_v = max(vertex_hits, key=vertex_hits.get)
        S.add(best_v)
        # Remove covered edges
        new_uncovered = []
        for idx in uncovered:
            if best_v not in H.edges[idx]:
                new_uncovered.append(idx)
        uncovered = new_uncovered

    return S


def compute_integrality_gap(H: Hypergraph, d: int) -> Dict[str, float]:
    """Compute integrality gap and related observables.

    Returns dict with:
        fractional_opt: LP relaxation optimum (τ*)
        greedy_upper: greedy transversal size (upper bound on τ)
        lp_rounded: threshold-rounded transversal size
        overlap_rounded: overlap-aware rounded size
        gap_greedy: greedy/fractional ratio
        gap_lp: lp_rounded/fractional ratio
        gap_overlap: overlap_rounded/fractional ratio
        overlap_stats: overlap profile
        rounding_defect: greedy - fractional
    """
    frac_opt, x = solve_fractional_transversal_lp(H)

    overlap_stats = H.overlap_profile()

    # Standard threshold rounding
    S_threshold = threshold_rounding(x, d)
    # Repair uncovered edges
    for e in H.edges:
        if not S_threshold & e:
            S_threshold.add(max(e, key=lambda v: x[v]))

    # Overlap-aware rounding
    S_overlap = low_overlap_rounding(H, x, d, overlap_stats)

    # Greedy
    S_greedy = greedy_transversal(H)

    integral_upper = min(len(S_threshold), len(S_greedy), len(S_overlap))

    result = {
        'fractional_opt': frac_opt,
        'greedy_size': len(S_greedy),
        'threshold_size': len(S_threshold),
        'overlap_rounded_size': len(S_overlap),
        'integral_upper': integral_upper,
        'gap_greedy': len(S_greedy) / max(frac_opt, 1e-10),
        'gap_threshold': len(S_threshold) / max(frac_opt, 1e-10),
        'gap_overlap': len(S_overlap) / max(frac_opt, 1e-10),
        'rounding_defect': integral_upper - frac_opt,
        'normalized_defect': (integral_upper - frac_opt) / max(H.n, 1),
        'overlap_stats': overlap_stats,
    }
    return result


if __name__ == '__main__':
    # Example usage
    rng = np.random.default_rng(42)
    H = random_uniform_hypergraph(20, 10, 3, rng)
    print(f"Hypergraph: n={H.n}, m={H.m}, d=3")
    print(f"Overlap profile: {H.overlap_profile()}")
    result = compute_integrality_gap(H, 3)
    print(f"Fractional optimum: {result['fractional_opt']:.4f}")
    print(f"Greedy size: {result['greedy_size']}")
    print(f"Threshold rounded: {result['threshold_size']}")
    print(f"Overlap rounded: {result['overlap_rounded_size']}")
    print(f"Gap (greedy): {result['gap_greedy']:.4f}")
    print(f"Gap (overlap): {result['gap_overlap']:.4f}")
    print(f"Rounding defect: {result['rounding_defect']:.4f}")
