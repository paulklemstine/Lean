"""
algorithms.py — Low-Overlap-Aware Threshold Rounding for Hypergraph Transversals

Implements the core algorithmic pipeline from the random transversal
thermodynamics theory:

1. Fractional transversal LP solver (via scipy)
2. Overlap profile computation (pair codegrees)
3. Threshold rounding with overlap-aware parameter selection
4. Greedy repair for uncovered edges
5. Integrality gap and rounding defect computation

Author: Harmonic Research
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Dict, Optional
from scipy.optimize import linprog


class Hypergraph:
    """A finite hypergraph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Set[int]]):
        self.n = n
        self.edges = [frozenset(e) for e in edges]

    @staticmethod
    def random_uniform(n: int, m: int, d: int, rng=None) -> 'Hypergraph':
        """Generate a random d-uniform hypergraph on n vertices with m edges."""
        if rng is None:
            rng = np.random.default_rng()
        edges = []
        vertices = list(range(n))
        for _ in range(m):
            e = frozenset(rng.choice(vertices, size=d, replace=False))
            edges.append(e)
        return Hypergraph(n, edges)

    def unique_edges(self) -> List[frozenset]:
        """Return deduplicated edges."""
        return list(set(self.edges))

    def is_uniform(self) -> Optional[int]:
        """Return uniformity d if uniform, else None."""
        if not self.edges:
            return None
        sizes = set(len(e) for e in self.edges)
        return sizes.pop() if len(sizes) == 1 else None


def solve_fractional_transversal(H: Hypergraph) -> Tuple[np.ndarray, float]:
    """
    Solve the fractional transversal LP:
        min  sum x_v
        s.t. sum_{v in e} x_v >= 1 for all e
             x_v >= 0

    Returns (x_opt, tau_star) where x_opt is the optimal assignment
    and tau_star is the fractional transversal number.
    """
    n = H.n
    edges = H.unique_edges()
    if not edges:
        return np.zeros(n), 0.0

    c = np.ones(n)  # minimize sum x_v

    # Constraints: -sum_{v in e} x_v <= -1
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0

    bounds = [(0, None) for _ in range(n)]

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

    if result.success:
        return result.x, result.fun
    else:
        # Fallback: uniform assignment
        d = max(len(e) for e in edges) if edges else 1
        x = np.full(n, 1.0 / d)
        return x, n / d


def compute_pair_codegrees(H: Hypergraph) -> Dict[Tuple[int, int], int]:
    """Compute pair codegree for all vertex pairs appearing in edges."""
    codeg = {}
    for e in H.unique_edges():
        for u, v in combinations(sorted(e), 2):
            codeg[(u, v)] = codeg.get((u, v), 0) + 1
    return codeg


def compute_overlap_profile(H: Hypergraph) -> Dict[str, float]:
    """
    Compute overlap profile statistics:
    - max_pair_codegree: maximum pair codegree
    - mean_pair_codegree: mean pair codegree (over pairs with codeg > 0)
    - num_high_overlap_pairs: pairs with codegree > 1
    """
    codeg = compute_pair_codegrees(H)
    if not codeg:
        return {'max_pair_codegree': 0, 'mean_pair_codegree': 0.0,
                'num_high_overlap_pairs': 0}

    vals = list(codeg.values())
    return {
        'max_pair_codegree': max(vals),
        'mean_pair_codegree': np.mean(vals),
        'num_high_overlap_pairs': sum(1 for v in vals if v > 1)
    }


def threshold_round(x: np.ndarray, theta: float) -> Set[int]:
    """Round fractional solution: include vertex v iff x_v >= theta."""
    return set(int(v) for v in np.where(x >= theta)[0])


def greedy_repair(H: Hypergraph, S: Set[int]) -> Set[int]:
    """Greedily add vertices to S to cover all uncovered edges."""
    S = set(S)
    for e in H.unique_edges():
        if not S & e:
            # Add the first vertex of the uncovered edge
            S.add(min(e))
    return S


def low_overlap_round(H: Hypergraph, x: np.ndarray,
                       overlap_stats: Dict[str, float]) -> Tuple[Set[int], Dict]:
    """
    Low-overlap-aware threshold rounding algorithm.

    1. Compute threshold based on uniformity and overlap profile
    2. Round vertices above threshold
    3. Greedily repair uncovered edges
    4. Return the cover and diagnostic statistics

    The key insight: when pair codegrees are low (sparse overlap),
    we can use a slightly higher threshold than 1/d, which gives
    a smaller initial rounded set. The greedy repair cost is controlled
    by the overlap profile.
    """
    d = H.is_uniform()
    if d is None:
        d = max(len(e) for e in H.unique_edges()) if H.edges else 1

    max_codeg = overlap_stats.get('max_pair_codegree', d)

    # Standard threshold: 1/d
    # Overlap-adjusted threshold: slightly higher when overlap is low
    if max_codeg <= 1 and d >= 2:
        # Low overlap regime: we can be more aggressive
        theta = 1.0 / d + 0.5 / (d * d)
    else:
        theta = 1.0 / d

    # Round
    S_initial = threshold_round(x, theta)

    # Repair
    S_final = greedy_repair(H, S_initial)

    # Diagnostics
    uncovered = sum(1 for e in H.unique_edges() if not S_initial & e)
    diagnostics = {
        'threshold': theta,
        'initial_size': len(S_initial),
        'repair_count': len(S_final) - len(S_initial),
        'final_size': len(S_final),
        'uncovered_before_repair': uncovered,
        'overlap_adjusted': max_codeg <= 1 and d >= 2
    }

    return S_final, diagnostics


def compute_integrality_gap_estimate(H: Hypergraph) -> Dict[str, float]:
    """
    Compute integrality gap estimate for a hypergraph.
    Returns fractional optimum, rounded integer solution size,
    and the ratio.
    """
    x_opt, tau_star = solve_fractional_transversal(H)

    if tau_star < 1e-10:
        return {
            'tau_star': 0.0,
            'tau_rounded': 0,
            'gap_ratio': 1.0,
            'rounding_defect': 0.0
        }

    overlap = compute_overlap_profile(H)
    S, diag = low_overlap_round(H, x_opt, overlap)

    tau_rounded = len(S)
    gap_ratio = tau_rounded / tau_star if tau_star > 0 else 1.0
    rounding_defect = tau_rounded - tau_star

    return {
        'tau_star': tau_star,
        'tau_rounded': tau_rounded,
        'gap_ratio': gap_ratio,
        'rounding_defect': rounding_defect,
        'normalized_rounding_defect': rounding_defect / H.n if H.n > 0 else 0,
        'overlap_profile': overlap,
        'rounding_diagnostics': diag
    }


def compute_greedy_transversal(H: Hypergraph) -> Set[int]:
    """Greedy transversal: repeatedly pick the highest-degree vertex."""
    S = set()
    uncovered = list(H.unique_edges())

    while uncovered:
        # Count vertex degrees in uncovered edges
        degree = {}
        for e in uncovered:
            for v in e:
                degree[v] = degree.get(v, 0) + 1

        if not degree:
            break

        # Pick highest-degree vertex
        best = max(degree, key=degree.get)
        S.add(best)

        # Remove covered edges
        uncovered = [e for e in uncovered if best not in e]

    return S


# Example usage
if __name__ == '__main__':
    np.random.seed(42)

    print("=" * 60)
    print("Low-Overlap-Aware Threshold Rounding Algorithm")
    print("=" * 60)

    for d in [3, 4, 5]:
        n = 50
        m = int(2.0 * n)
        H = Hypergraph.random_uniform(n, m, d)

        result = compute_integrality_gap_estimate(H)
        print(f"\nd={d}, n={n}, m={m}:")
        print(f"  τ* (fractional) = {result['tau_star']:.3f}")
        print(f"  τ  (rounded)    = {result['tau_rounded']}")
        print(f"  Gap ratio       = {result['gap_ratio']:.3f}")
        print(f"  Worst-case d    = {d}")
        print(f"  Rounding defect = {result['rounding_defect']:.3f}")
        print(f"  Max pair codeg  = {result['overlap_profile']['max_pair_codegree']}")
        print(f"  Overlap-adjusted= {result['rounding_diagnostics']['overlap_adjusted']}")
