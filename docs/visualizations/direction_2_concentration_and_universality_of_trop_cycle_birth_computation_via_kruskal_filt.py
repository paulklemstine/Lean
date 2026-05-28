"""
Algorithms for Cycle-Birth Analysis in Weighted Graph Filtrations.

Implements the core algorithms for computing cycle-birth edges, empirical CDFs,
and related quantities from the formal theory of probabilistic tropical topology.

Application keywords: tropical Morse theory, persistent homology, minimum spanning tree,
graphic matroid, Kruskal duality, empirical process.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from collections import namedtuple

# --------------------------------------------------------------------------
# Union-Find data structure for Kruskal-style filtration
# --------------------------------------------------------------------------

class UnionFind:
    """Weighted quick-union with path compression.

    Time complexity: near O(α(n)) per operation (amortized),
    where α is the inverse Ackermann function.
    Space complexity: O(n).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.components = n

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
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)


# --------------------------------------------------------------------------
# Core: Cycle-birth computation via Kruskal filtration
# --------------------------------------------------------------------------

EdgeInfo = namedtuple('EdgeInfo', ['u', 'v', 'weight', 'is_cycle_birth'])


def compute_cycle_births(n: int, edges: List[Tuple[int, int, float]]) -> List[EdgeInfo]:
    """
    Compute cycle-birth classification for all edges via Kruskal filtration.

    This implements the deterministic characterization (Theorem 1):
    an edge is a cycle-birth edge iff its endpoints are already connected
    in the subgraph of lighter edges.

    Args:
        n: Number of vertices.
        edges: List of (u, v, weight) tuples.

    Returns:
        List of EdgeInfo sorted by weight, each labeled as cycle-birth or merge.

    Time complexity: O(m log m + m α(n)) where m = len(edges).
    Space complexity: O(n + m).
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    result = []

    for u, v, w in sorted_edges:
        is_cycle = uf.connected(u, v)
        if not is_cycle:
            uf.union(u, v)
        result.append(EdgeInfo(u, v, w, is_cycle))

    return result


def cycle_birth_weights(n: int, edges: List[Tuple[int, int, float]]) -> List[float]:
    """Extract the list of cycle-birth weights (tropical critical values).

    These are exactly the weights of non-MST edges (Theorem 5).
    """
    info = compute_cycle_births(n, edges)
    return [e.weight for e in info if e.is_cycle_birth]


def mst_edges(n: int, edges: List[Tuple[int, int, float]]) -> List[Tuple[int, int, float]]:
    """Compute MST edges via Kruskal's algorithm.

    By Theorem 5, these are exactly the complement of cycle-birth edges.
    """
    info = compute_cycle_births(n, edges)
    return [(e.u, e.v, e.weight) for e in info if not e.is_cycle_birth]


# --------------------------------------------------------------------------
# Empirical CDF and counting functions
# --------------------------------------------------------------------------

def cycle_birth_count_le(n: int, edges: List[Tuple[int, int, float]], t: float) -> int:
    """Count cycle births with weight ≤ t.

    This is the tropical spectral counting function N_G(t).
    """
    births = cycle_birth_weights(n, edges)
    return sum(1 for w in births if w <= t)


def empirical_cycle_birth_cdf(n: int, edges: List[Tuple[int, int, float]],
                               t: float) -> float:
    """Empirical CDF of cycle-birth times at threshold t.

    Returns cycleBirthCountLE(t) / totalCycleBirths.
    """
    births = cycle_birth_weights(n, edges)
    if not births:
        return 0.0
    return sum(1 for w in births if w <= t) / len(births)


def empirical_cdf_function(births: List[float]) -> callable:
    """Return a vectorized empirical CDF function from a list of birth weights."""
    sorted_births = np.sort(births)
    def cdf(t):
        return np.searchsorted(sorted_births, t, side='right') / len(sorted_births)
    return cdf


# --------------------------------------------------------------------------
# Random graph generation
# --------------------------------------------------------------------------

def sample_erdos_renyi_weighted(n: int, p: float,
                                 weight_dist: str = 'uniform',
                                 rng: Optional[np.random.Generator] = None
                                 ) -> Tuple[int, List[Tuple[int, int, float]]]:
    """
    Sample G(n,p) with i.i.d. edge weights.

    Args:
        n: Number of vertices.
        p: Edge probability.
        weight_dist: One of 'uniform', 'exponential', 'normal'.
        rng: Random number generator.

    Returns:
        (n, edges) where edges is a list of (u, v, weight).
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
                    w = rng.normal(0, 1)
                else:
                    raise ValueError(f"Unknown distribution: {weight_dist}")
                edges.append((i, j, w))

    return n, edges


# --------------------------------------------------------------------------
# Kolmogorov-Smirnov distance
# --------------------------------------------------------------------------

def ks_distance(sample1: List[float], sample2: List[float]) -> float:
    """Compute the two-sample Kolmogorov-Smirnov distance.

    Time complexity: O(m log m + n log n) where m, n are sample sizes.
    """
    if not sample1 or not sample2:
        return 1.0

    s1 = np.sort(sample1)
    s2 = np.sort(sample2)
    all_vals = np.sort(np.concatenate([s1, s2]))

    cdf1 = np.searchsorted(s1, all_vals, side='right') / len(s1)
    cdf2 = np.searchsorted(s2, all_vals, side='right') / len(s2)

    return float(np.max(np.abs(cdf1 - cdf2)))


def ks_distance_from_births(births1: List[float], births2: List[float]) -> float:
    """KS distance between two empirical cycle-birth distributions."""
    return ks_distance(births1, births2)


# --------------------------------------------------------------------------
# Monotone transport
# --------------------------------------------------------------------------

def apply_monotone_transport(births: List[float], phi: callable) -> List[float]:
    """Apply a monotone transformation to cycle-birth weights.

    By Theorem 4, if phi is strictly monotone, the cycle-birth edge set
    is unchanged; only the weight values transform.
    """
    return [phi(w) for w in births]


def quantile_transform(values: List[float]) -> List[float]:
    """Transform values to uniform quantiles (probability integral transform).

    This is the canonical monotone transport that maps any continuous
    distribution to Uniform[0,1], establishing universality.
    """
    n = len(values)
    if n == 0:
        return []
    ranks = np.argsort(np.argsort(values))
    return list((ranks + 0.5) / n)


# --------------------------------------------------------------------------
# Lipschitz stability verification
# --------------------------------------------------------------------------

def verify_lipschitz_bound(n: int, edges: List[Tuple[int, int, float]],
                            edge_idx: int, new_weight: float,
                            threshold: float) -> Dict:
    """
    Verify Theorem 2: changing one edge weight changes cycleBirthCountLE by ≤ 1.

    Returns diagnostic dict with original count, modified count, and difference.
    """
    original_count = cycle_birth_count_le(n, edges, threshold)

    modified_edges = list(edges)
    u, v, _ = modified_edges[edge_idx]
    modified_edges[edge_idx] = (u, v, new_weight)

    modified_count = cycle_birth_count_le(n, modified_edges, threshold)

    diff = abs(original_count - modified_count)
    return {
        'original_count': original_count,
        'modified_count': modified_count,
        'difference': diff,
        'bound_satisfied': diff <= 1,
        'edge_modified': edge_idx,
        'threshold': threshold,
    }


# --------------------------------------------------------------------------
# Summary statistics
# --------------------------------------------------------------------------

def filtration_summary(n: int, edges: List[Tuple[int, int, float]]) -> Dict:
    """Compute a complete summary of the graph filtration.

    Returns dict with:
    - total_edges: number of edges
    - merge_count: number of merge edges (= MST edges)
    - cycle_birth_count: number of cycle-birth edges (= non-MST edges)
    - beta_0: final number of connected components
    - beta_1: first Betti number = cycle_birth_count
    - euler_char: V - E
    - cycle_birth_weights: sorted list of cycle-birth weights
    """
    info = compute_cycle_births(n, edges)
    merges = sum(1 for e in info if not e.is_cycle_birth)
    cycles = sum(1 for e in info if e.is_cycle_birth)
    births = sorted([e.weight for e in info if e.is_cycle_birth])

    uf = UnionFind(n)
    for e in info:
        if not e.is_cycle_birth:
            uf.union(e.u, e.v)

    return {
        'vertices': n,
        'total_edges': len(edges),
        'merge_count': merges,
        'cycle_birth_count': cycles,
        'beta_0': uf.components,
        'beta_1': cycles,
        'euler_char': n - len(edges),
        'cycle_birth_weights': births,
        'identity_check': merges + cycles == len(edges),  # Theorem 1
    }


if __name__ == '__main__':
    # Quick demo
    rng = np.random.default_rng(42)
    n, edges = sample_erdos_renyi_weighted(20, 0.3, 'uniform', rng)
    summary = filtration_summary(n, edges)
    print("Filtration Summary:")
    for k, v in summary.items():
        if k != 'cycle_birth_weights':
            print(f"  {k}: {v}")
    print(f"  cycle_birth_weights: {summary['cycle_birth_weights'][:5]}...")
    print(f"\nTheorem 1 verified: merges + cycles = edges: {summary['identity_check']}")
