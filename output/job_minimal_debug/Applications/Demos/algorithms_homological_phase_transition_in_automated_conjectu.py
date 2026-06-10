"""
Algorithms for Proof-Theoretic Topology

Implements the core computational pipeline for semantic threshold graph analysis:
- Symmetric difference distance computation
- Threshold graph construction
- Connected component counting
- Cycle rank (cyclomatic number) computation
- Transition profile scanning

All algorithms operate on finite feature-set representations of statement families.
"""

from typing import List, Tuple, Dict, Set, FrozenSet
import itertools
from collections import deque


def symm_diff_card(A: Set[int], B: Set[int]) -> int:
    """Compute the symmetric difference cardinality |A Δ B|.

    This is the fundamental dissimilarity measure between two feature sets.

    Args:
        A: First feature set.
        B: Second feature set.

    Returns:
        |A \\ B| + |B \\ A| = |A Δ B|

    Examples:
        >>> symm_diff_card({1, 2, 3}, {2, 3, 4})
        2
        >>> symm_diff_card({1, 2}, {1, 2})
        0
        >>> symm_diff_card({1, 2}, {3, 4})
        4
    """
    return len(A - B) + len(B - A)


def pairwise_distances(feature_sets: List[Set[int]]) -> List[List[int]]:
    """Compute the full pairwise distance matrix.

    Args:
        feature_sets: List of feature sets, one per statement.

    Returns:
        Symmetric matrix D where D[i][j] = symm_diff_card(S_i, S_j).

    Time complexity: O(n^2 * k) where n = number of statements, k = max feature set size.

    Examples:
        >>> pairwise_distances([{1, 2}, {2, 3}, {3, 4}])
        [[0, 2, 4], [2, 0, 2], [4, 2, 0]]
    """
    n = len(feature_sets)
    D = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            d = symm_diff_card(feature_sets[i], feature_sets[j])
            D[i][j] = d
            D[j][i] = d
    return D


def threshold_graph_edges(D: List[List[int]], epsilon: int) -> List[Tuple[int, int]]:
    """Build the edge list of the threshold graph G_ε.

    Two distinct vertices i, j are adjacent iff D[i][j] <= epsilon.

    Args:
        D: Pairwise distance matrix.
        epsilon: Threshold parameter.

    Returns:
        List of edges (i, j) with i < j.

    Time complexity: O(n^2).
    """
    n = len(D)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if D[i][j] <= epsilon:
                edges.append((i, j))
    return edges


def adjacency_list(n: int, edges: List[Tuple[int, int]]) -> Dict[int, List[int]]:
    """Convert edge list to adjacency list representation.

    Args:
        n: Number of vertices.
        edges: List of edges (i, j).

    Returns:
        Dictionary mapping each vertex to its list of neighbors.
    """
    adj: Dict[int, List[int]] = {i: [] for i in range(n)}
    for i, j in edges:
        adj[i].append(j)
        adj[j].append(i)
    return adj


def connected_components(n: int, edges: List[Tuple[int, int]]) -> List[List[int]]:
    """Compute connected components via BFS.

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        List of connected components, each a list of vertex indices.

    Time complexity: O(n + m) where m = number of edges.
    """
    adj = adjacency_list(n, edges)
    visited = [False] * n
    components = []

    for start in range(n):
        if visited[start]:
            continue
        component = []
        queue = deque([start])
        visited[start] = True
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in adj[v]:
                if not visited[w]:
                    visited[w] = True
                    queue.append(w)
        components.append(component)

    return components


def cycle_rank(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute the cycle rank (cyclomatic number) β₁ = |E| - |V| + c.

    This is the first Betti number of the graph viewed as a 1-dimensional
    CW complex. It counts the number of independent cycles.

    Args:
        n: Number of vertices (|V|).
        edges: List of edges (|E| = len(edges)).

    Returns:
        |E| - |V| + c where c is the number of connected components.

    Time complexity: O(n + m).

    Examples:
        >>> cycle_rank(3, [(0,1), (1,2), (0,2)])  # triangle
        1
        >>> cycle_rank(4, [(0,1), (1,2), (2,3)])  # path
        0
        >>> cycle_rank(4, [(0,1), (1,2), (2,3), (0,3), (0,2)])  # K4 minus one edge
        2
    """
    c = len(connected_components(n, edges))
    return len(edges) - n + c


def transition_profile(
    feature_sets: List[Set[int]],
    thresholds: List[int]
) -> List[Dict[str, int]]:
    """Compute the full transition profile across a range of thresholds.

    For each threshold ε, computes:
    - Number of connected components
    - Number of edges
    - Cycle rank (first Betti number)

    This is the core diagnostic pipeline for detecting topological phase transitions.

    Args:
        feature_sets: List of feature sets for each statement.
        thresholds: List of threshold values to scan.

    Returns:
        List of dictionaries with keys 'epsilon', 'components', 'edges', 'cycle_rank'.

    Time complexity: O(T * n^2) where T = number of thresholds.
    Space complexity: O(n^2) for the distance matrix.
    """
    n = len(feature_sets)
    D = pairwise_distances(feature_sets)

    profile = []
    for eps in thresholds:
        edges = threshold_graph_edges(D, eps)
        comps = connected_components(n, edges)
        cr = len(edges) - n + len(comps)
        profile.append({
            'epsilon': eps,
            'components': len(comps),
            'edges': len(edges),
            'cycle_rank': cr,
        })

    return profile


def find_transition_thresholds(
    feature_sets: List[Set[int]],
    max_threshold: int = None
) -> Dict[str, int]:
    """Identify key transition thresholds in the filtration.

    Scans thresholds from 0 to max_threshold and identifies:
    - connectivity_threshold: smallest ε where graph becomes connected
    - cycle_threshold: smallest ε where cycle rank becomes positive
    - complete_threshold: smallest ε where graph is complete

    Args:
        feature_sets: List of feature sets.
        max_threshold: Maximum threshold to scan (default: max pairwise distance).

    Returns:
        Dictionary with threshold values. Value is -1 if threshold not found.

    Time complexity: O(D_max * n^2).
    """
    n = len(feature_sets)
    D = pairwise_distances(feature_sets)

    if max_threshold is None:
        max_threshold = max(D[i][j] for i in range(n) for j in range(n))

    result = {
        'connectivity_threshold': -1,
        'cycle_threshold': -1,
        'complete_threshold': -1,
    }

    max_edges = n * (n - 1) // 2

    for eps in range(max_threshold + 1):
        edges = threshold_graph_edges(D, eps)
        comps = connected_components(n, edges)
        cr = len(edges) - n + len(comps)

        if len(comps) == 1 and result['connectivity_threshold'] == -1:
            result['connectivity_threshold'] = eps

        if cr > 0 and result['cycle_threshold'] == -1:
            result['cycle_threshold'] = eps

        if len(edges) == max_edges and result['complete_threshold'] == -1:
            result['complete_threshold'] = eps
            break

    return result


def hardness_variance_profile(
    feature_sets: List[Set[int]],
    hardness: List[float],
    thresholds: List[int]
) -> List[Dict[str, float]]:
    """Compute variance of hardness across connected components.

    For each threshold, computes the between-component variance of
    mean hardness values. This tests the hardness-correlation conjecture.

    Args:
        feature_sets: List of feature sets.
        hardness: Hardness values for each statement.
        thresholds: List of threshold values.

    Returns:
        List of dicts with 'epsilon', 'hardness_variance', 'cycle_rank'.
    """
    import statistics

    n = len(feature_sets)
    D = pairwise_distances(feature_sets)
    profile = []

    for eps in thresholds:
        edges = threshold_graph_edges(D, eps)
        comps = connected_components(n, edges)
        cr = len(edges) - n + len(comps)

        # Compute mean hardness per component
        comp_means = []
        for comp in comps:
            comp_hardness = [hardness[i] for i in comp]
            comp_means.append(statistics.mean(comp_hardness))

        # Between-component variance
        if len(comp_means) > 1:
            var = statistics.variance(comp_means)
        else:
            var = 0.0

        profile.append({
            'epsilon': eps,
            'hardness_variance': var,
            'cycle_rank': cr,
        })

    return profile


if __name__ == "__main__":
    # Example: clustered family
    print("=== Clustered Family Example ===")
    cluster_A = [{1, 2, 3, 4}, {1, 2, 3, 5}, {1, 2, 4, 5}]
    cluster_B = [{10, 11, 12, 13}, {10, 11, 12, 14}, {10, 11, 13, 14}]
    features = cluster_A + cluster_B

    print(f"Number of statements: {len(features)}")
    D = pairwise_distances(features)
    print("Distance matrix:")
    for row in D:
        print("  ", row)

    thresholds = list(range(15))
    profile = transition_profile(features, thresholds)
    print("\nTransition Profile:")
    print(f"{'eps':>4} {'comps':>6} {'edges':>6} {'cycle_rank':>11}")
    for p in profile:
        print(f"{p['epsilon']:4d} {p['components']:6d} {p['edges']:6d} {p['cycle_rank']:11d}")

    transitions = find_transition_thresholds(features)
    print(f"\nTransition thresholds: {transitions}")
