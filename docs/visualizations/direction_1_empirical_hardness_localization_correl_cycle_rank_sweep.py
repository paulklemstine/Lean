"""
Topological Proof Pressure: Core Algorithms

Implements the computational pipeline for computing local cycle pressure
from semantic threshold graphs and correlating it with proof-search hardness.

All algorithms correspond to the formal definitions in the Lean 4 formalization.
"""

import numpy as np
from collections import defaultdict
from typing import List, Dict, Tuple, Set, Optional


def symmetric_difference_card(a: Set[str], b: Set[str]) -> int:
    """Compute |A Δ B| = |A \\ B| + |B \\ A|.
    
    Corresponds to `symmDiffCard` in Lean.
    
    >>> symmetric_difference_card({'a', 'b'}, {'b', 'c'})
    2
    """
    return len(a - b) + len(b - a)


def build_threshold_graph(
    features: List[Set[str]], 
    epsilon: int
) -> Dict[int, Set[int]]:
    """Build the semantic threshold graph at parameter epsilon.
    
    Corresponds to `semanticGraph` in Lean.
    Two vertices i, j are adjacent iff i ≠ j and |S(i) Δ S(j)| ≤ epsilon.
    
    Args:
        features: List of feature sets, one per vertex.
        epsilon: Distance threshold.
    
    Returns:
        Adjacency list representation of the graph.
    
    >>> features = [{'a', 'b'}, {'b', 'c'}, {'a', 'c'}]
    >>> g = build_threshold_graph(features, 2)
    >>> sorted(g[0])
    [1, 2]
    """
    n = len(features)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            dist = symmetric_difference_card(features[i], features[j])
            if dist <= epsilon:
                adj[i].add(j)
                adj[j].add(i)
    # Ensure all vertices appear
    for i in range(n):
        if i not in adj:
            adj[i] = set()
    return dict(adj)


def count_edges(adj: Dict[int, Set[int]]) -> int:
    """Count edges in an undirected graph (adjacency list)."""
    return sum(len(neighbors) for neighbors in adj.values()) // 2


def connected_components(adj: Dict[int, Set[int]]) -> List[Set[int]]:
    """Find connected components via BFS.
    
    >>> adj = {0: {1}, 1: {0}, 2: set()}
    >>> comps = connected_components(adj)
    >>> len(comps)
    2
    """
    visited = set()
    components = []
    for start in adj:
        if start in visited:
            continue
        comp = set()
        queue = [start]
        while queue:
            v = queue.pop()
            if v in visited:
                continue
            visited.add(v)
            comp.add(v)
            for w in adj.get(v, set()):
                if w not in visited:
                    queue.append(w)
        components.append(comp)
    return components


def graph_cycle_rank(adj: Dict[int, Set[int]]) -> int:
    """Compute the cycle rank (cyclomatic number) β₁ = |E| - |V| + |C|.
    
    Corresponds to `graphCycleRank` in Lean.
    
    >>> adj = {0: {1, 2}, 1: {0, 2}, 2: {0, 1}}  # Triangle
    >>> graph_cycle_rank(adj)
    1
    >>> adj = {0: {1}, 1: {0, 2}, 2: {1}}  # Path
    >>> graph_cycle_rank(adj)
    0
    """
    e = count_edges(adj)
    v = len(adj)
    c = len(connected_components(adj))
    return e - v + c


def find_bridges(adj: Dict[int, Set[int]]) -> Set[Tuple[int, int]]:
    """Find all bridges using Tarjan's algorithm.
    
    A bridge is an edge whose removal increases the number of
    connected components. Equivalently, it's an edge not contained
    in any cycle.
    
    Time complexity: O(V + E)
    
    >>> adj = {0: {1, 2}, 1: {0, 2, 3}, 2: {0, 1}, 3: {1}}
    >>> bridges = find_bridges(adj)
    >>> (1, 3) in bridges or (3, 1) in bridges
    True
    """
    bridges = set()
    visited = set()
    disc = {}
    low = {}
    timer = [0]
    
    def dfs(u, parent):
        visited.add(u)
        disc[u] = low[u] = timer[0]
        timer[0] += 1
        for v in adj.get(u, set()):
            if v not in visited:
                dfs(v, u)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u]:
                    bridges.add((min(u, v), max(u, v)))
            elif v != parent:
                low[u] = min(low[u], disc[v])
    
    for v in adj:
        if v not in visited:
            dfs(v, -1)
    
    return bridges


def local_cycle_pressure(adj: Dict[int, Set[int]]) -> Dict[int, int]:
    """Compute local cycle pressure for each vertex.
    
    Corresponds to `localCyclePressure` in Lean:
    the number of non-bridge edges incident to each vertex.
    
    Args:
        adj: Adjacency list.
    
    Returns:
        Dictionary mapping vertex to its local cycle pressure.
    
    >>> adj = {0: {1, 2}, 1: {0, 2, 3}, 2: {0, 1}, 3: {1}}
    >>> pressure = local_cycle_pressure(adj)
    >>> pressure[0]  # In triangle, 2 non-bridge edges
    2
    >>> pressure[3]  # Leaf, only bridge edge
    0
    """
    bridges = find_bridges(adj)
    pressure = {}
    for v in adj:
        count = 0
        for w in adj[v]:
            edge = (min(v, w), max(v, w))
            if edge not in bridges:
                count += 1
        pressure[v] = count
    return pressure


def pairwise_concordance(f: List[int], g: List[int]) -> int:
    """Compute the pairwise concordance score C(f, g).
    
    Corresponds to `pairwiseConcordance` in Lean:
    |{(i,j) : f[i] < f[j] ∧ g[i] < g[j]}| - |{(i,j) : f[i] < f[j] ∧ g[j] < g[i]}|
    
    This is the numerator of Kendall's τ (without normalization).
    
    >>> pairwise_concordance([1, 2, 3], [1, 2, 3])
    6
    >>> pairwise_concordance([1, 2, 3], [3, 2, 1])
    -6
    >>> pairwise_concordance([1, 1, 1], [1, 2, 3])
    0
    """
    n = len(f)
    concordant = 0
    discordant = 0
    for i in range(n):
        for j in range(n):
            if f[i] < f[j] and g[i] < g[j]:
                concordant += 1
            if f[i] < f[j] and g[j] < g[i]:
                discordant += 1
    return concordant - discordant


def spearman_correlation(x: List[float], y: List[float]) -> float:
    """Compute Spearman rank correlation coefficient.
    
    >>> abs(spearman_correlation([1, 2, 3, 4, 5], [1, 2, 3, 4, 5]) - 1.0) < 1e-10
    True
    >>> abs(spearman_correlation([1, 2, 3, 4, 5], [5, 4, 3, 2, 1]) + 1.0) < 1e-10
    True
    """
    n = len(x)
    if n <= 1:
        return 0.0
    
    def rank(vals):
        sorted_indices = sorted(range(n), key=lambda i: vals[i])
        ranks = [0.0] * n
        i = 0
        while i < n:
            j = i
            while j < n and vals[sorted_indices[j]] == vals[sorted_indices[i]]:
                j += 1
            avg_rank = (i + j - 1) / 2.0 + 1
            for k in range(i, j):
                ranks[sorted_indices[k]] = avg_rank
            i = j
        return ranks
    
    rx = rank(x)
    ry = rank(y)
    
    mean_rx = sum(rx) / n
    mean_ry = sum(ry) / n
    
    cov = sum((rx[i] - mean_rx) * (ry[i] - mean_ry) for i in range(n))
    var_x = sum((rx[i] - mean_rx) ** 2 for i in range(n))
    var_y = sum((ry[i] - mean_ry) ** 2 for i in range(n))
    
    if var_x == 0 or var_y == 0:
        return 0.0
    
    return cov / (var_x ** 0.5 * var_y ** 0.5)


def cycle_rank_sweep(
    features: List[Set[str]], 
    max_epsilon: int = 20
) -> Tuple[int, int, List[Tuple[int, int, int]]]:
    """Sweep thresholds and find ε* maximizing cycle rank.
    
    Args:
        features: Feature sets for each vertex.
        max_epsilon: Maximum threshold to test.
    
    Returns:
        (best_epsilon, best_cycle_rank, profile) where profile is
        list of (epsilon, edge_count, cycle_rank) tuples.
    
    >>> features = [{'a', 'b'}, {'b', 'c'}, {'c', 'd'}, {'d', 'a'}]
    >>> best_eps, best_rank, profile = cycle_rank_sweep(features, 5)
    >>> best_rank >= 0
    True
    """
    best_eps = 0
    best_rank = -1
    profile = []
    
    for eps in range(max_epsilon + 1):
        adj = build_threshold_graph(features, eps)
        e = count_edges(adj)
        cr = graph_cycle_rank(adj)
        profile.append((eps, e, cr))
        if cr > best_rank:
            best_rank = cr
            best_eps = eps
    
    return best_eps, best_rank, profile


def fisher_exact_test_2x2(a: int, b: int, c: int, d: int) -> float:
    """Compute Fisher exact test p-value for a 2x2 contingency table.
    
    Table:      | group1 | group2 |
    timeout     |   a    |   b    |
    no timeout  |   c    |   d    |
    
    Returns two-sided p-value (approximate via hypergeometric).
    """
    from math import comb, factorial
    n = a + b + c + d
    if n == 0:
        return 1.0
    
    def hypergeom_pmf(k, K, n_draw, N):
        if k < max(0, n_draw - (N - K)) or k > min(n_draw, K):
            return 0.0
        return comb(K, k) * comb(N - K, n_draw - k) / comb(N, n_draw)
    
    K = a + b   # total timeouts
    n_draw = a + c  # group1 size
    N = n  # total
    
    observed_p = hypergeom_pmf(a, K, n_draw, N)
    
    p_value = 0.0
    for k in range(min(n_draw, K) + 1):
        p = hypergeom_pmf(k, K, n_draw, N)
        if p <= observed_p + 1e-15:
            p_value += p
    
    return min(p_value, 1.0)


def full_pipeline(
    features: List[Set[str]],
    hardness: List[float],
    max_epsilon: int = 20,
    timeout_threshold: Optional[float] = None
) -> Dict:
    """Run the full topological proof pressure pipeline.
    
    Args:
        features: Feature sets for each theorem.
        hardness: Proof-search cost for each theorem.
        max_epsilon: Maximum threshold to sweep.
        timeout_threshold: If set, classify theorems as timeout/no-timeout.
    
    Returns:
        Dictionary with all computed statistics.
    """
    n = len(features)
    
    # Step 1: Cycle rank sweep
    best_eps, best_rank, profile = cycle_rank_sweep(features, max_epsilon)
    
    # Step 2: Build graph at optimal threshold
    adj = build_threshold_graph(features, best_eps)
    
    # Step 3: Compute local cycle pressure
    pressure = local_cycle_pressure(adj)
    pressure_list = [pressure.get(i, 0) for i in range(n)]
    
    # Step 4: Compute concordance
    hardness_int = [int(h) for h in hardness]
    concordance = pairwise_concordance(pressure_list, hardness_int)
    
    # Step 5: Compute Spearman correlation
    spearman = spearman_correlation(
        [float(p) for p in pressure_list],
        [float(h) for h in hardness]
    )
    
    # Step 6: Fisher exact test (if timeout threshold provided)
    fisher_p = None
    if timeout_threshold is not None:
        median_pressure = sorted(pressure_list)[n // 2]
        high_pressure = [i for i in range(n) if pressure_list[i] > median_pressure]
        low_pressure = [i for i in range(n) if pressure_list[i] <= median_pressure]
        
        a = sum(1 for i in high_pressure if hardness[i] >= timeout_threshold)
        b = sum(1 for i in low_pressure if hardness[i] >= timeout_threshold)
        c = sum(1 for i in high_pressure if hardness[i] < timeout_threshold)
        d = sum(1 for i in low_pressure if hardness[i] < timeout_threshold)
        
        fisher_p = fisher_exact_test_2x2(a, b, c, d)
    
    results = {
        'n_theorems': n,
        'best_epsilon': best_eps,
        'best_cycle_rank': best_rank,
        'profile': profile,
        'pressure': pressure_list,
        'concordance_score': concordance,
        'spearman_correlation': spearman,
        'fisher_p_value': fisher_p,
        'n_positive_pressure': sum(1 for p in pressure_list if p > 0),
        'mean_pressure': np.mean(pressure_list) if pressure_list else 0,
        'max_pressure': max(pressure_list) if pressure_list else 0,
    }
    
    return results


if __name__ == '__main__':
    import doctest
    doctest.testmod()
    
    # Quick demonstration
    np.random.seed(42)
    n = 50
    feature_universe = [f'feat_{i}' for i in range(30)]
    features = []
    for i in range(n):
        k = np.random.randint(5, 15)
        features.append(set(np.random.choice(feature_universe, k, replace=False)))
    
    # Simulate hardness correlated with cycle pressure
    adj = build_threshold_graph(features, 8)
    pressure = local_cycle_pressure(adj)
    hardness = [pressure.get(i, 0) * 2 + np.random.randint(0, 5) for i in range(n)]
    
    results = full_pipeline(features, hardness, max_epsilon=15)
    
    print(f"Theorems: {results['n_theorems']}")
    print(f"Best ε: {results['best_epsilon']}")
    print(f"Best cycle rank: {results['best_cycle_rank']}")
    print(f"Concordance score: {results['concordance_score']}")
    print(f"Spearman correlation: {results['spearman_correlation']:.4f}")
    print(f"Vertices with positive pressure: {results['n_positive_pressure']}/{results['n_theorems']}")
