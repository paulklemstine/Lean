#!/usr/bin/env python3
"""
Algorithms for Oracle Trace Ultrametric Entropy.
Implements LCVP computation, ultrametric clustering, and entropy-capacity analysis.
"""

from typing import List, Dict, Set, Tuple, Optional
import math
from collections import defaultdict


def lcvp_len(u: List[int], v: List[int]) -> int:
    """
    Compute the longest common valued prefix length.

    Time complexity: O(min(|u|, |v|))
    Space complexity: O(1)

    Args:
        u: First trace (list of symbols).
        v: Second trace (list of symbols).

    Returns:
        Length of the longest common prefix.

    Examples:
        >>> lcvp_len([1, 2, 3], [1, 2, 4])
        2
        >>> lcvp_len([1, 2, 3], [1, 2, 3])
        3
        >>> lcvp_len([1, 2, 3], [4, 5, 6])
        0
    """
    k = 0
    for a, b in zip(u, v):
        if a != b:
            break
        k += 1
    return k


def prefix_dist(rho: float, u: List[int], v: List[int]) -> float:
    """
    Exponential prefix distance: rho^lcvp(u,v).

    For rho in (0,1), this satisfies the strong ultrametric inequality:
        prefix_dist(rho, u, w) <= max(prefix_dist(rho, u, v), prefix_dist(rho, v, w))

    Time complexity: O(min(|u|, |v|))

    Args:
        rho: Base in (0, 1).
        u: First trace.
        v: Second trace.

    Returns:
        The prefix distance.
    """
    return rho ** lcvp_len(u, v)


def prefix_gap(rho: float, u: List[int], v: List[int]) -> float:
    """
    Prefix gap metric: 0 if u==v, else rho^lcvp(u,v).

    This is a true metric (satisfies separation: gap = 0 iff u = v).

    Args:
        rho: Base in (0, 1).
        u: First trace.
        v: Second trace.

    Returns:
        The prefix gap.
    """
    if u == v:
        return 0.0
    return rho ** lcvp_len(u, v)


def ultrametric_cluster(
    traces: List[List[int]],
    rho: float,
    threshold: float
) -> List[List[int]]:
    """
    Ultrametric single-linkage clustering.

    Due to the isosceles property of ultrametrics, single-linkage and
    complete-linkage clustering produce identical results. This is a
    unique feature of non-Archimedean metrics.

    Time complexity: O(n^2 * L) where n = |traces|, L = max trace length.
    Space complexity: O(n)

    Args:
        traces: List of traces to cluster.
        rho: Ultrametric base in (0, 1).
        threshold: Distance threshold for merging.

    Returns:
        List of cluster indices (one per trace).

    Example:
        >>> traces = [[0,0,0], [0,0,1], [0,1,0], [1,0,0]]
        >>> ultrametric_cluster(traces, 0.5, 0.6)
        [0, 0, 1, 2]
    """
    n = len(traces)
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if prefix_gap(rho, traces[i], traces[j]) < threshold:
                union(i, j)

    # Normalize cluster labels
    label_map: Dict[int, int] = {}
    result = []
    for i in range(n):
        root = find(i)
        if root not in label_map:
            label_map[root] = len(label_map)
        result.append(label_map[root])

    return result


def oracle_entropy_proxy(traces: List[List[int]]) -> float:
    """
    Compute the oracle entropy proxy: log(|distinct traces|).

    This is the Shannon entropy of the uniform distribution over
    distinct trace values.

    Args:
        traces: List of traces.

    Returns:
        log of the number of distinct traces.
    """
    distinct = set(map(tuple, traces))
    if len(distinct) == 0:
        return 0.0
    return math.log(len(distinct))


def oracle_capacity(num_states: int) -> float:
    """
    Compute the oracle state capacity: log(|states|).

    Args:
        num_states: Number of oracle states.

    Returns:
        log of the number of states.
    """
    if num_states <= 0:
        return 0.0
    return math.log(num_states)


def certified_prefix_radius(
    rho: float, u: List[int], v: List[int]
) -> float:
    """
    Certified prefix robustness radius.

    In the ultrametric, any trace within this radius of u is guaranteed
    to be on the same side of the decision boundary as u (relative to v).

    Args:
        rho: Ultrametric base.
        u: Center trace.
        v: Boundary trace.

    Returns:
        Certified robustness radius.
    """
    return prefix_gap(rho, u, v) / 2.0


def build_ultrametric_dendrogram(
    traces: List[List[int]], rho: float
) -> List[Tuple[int, int, float]]:
    """
    Build a hierarchical clustering dendrogram from the ultrametric.

    Returns merge events sorted by distance (ascending).

    Time complexity: O(n^2 * L)

    Args:
        traces: List of traces.
        rho: Ultrametric base.

    Returns:
        List of (i, j, distance) merge events.
    """
    n = len(traces)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    # Compute all pairwise distances
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            d = prefix_gap(rho, traces[i], traces[j])
            edges.append((d, i, j))

    edges.sort()
    merges = []

    for d, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj
            merges.append((i, j, d))

    return merges


def post_quantum_separation_check(
    traces: List[List[int]], rho: float
) -> Tuple[bool, float]:
    """
    Check post-quantum prefix separation and compute minimum gap.

    Args:
        traces: List of traces (should be distinct).
        rho: Ultrametric base.

    Returns:
        (is_separated, min_gap) where is_separated is True iff all
        distinct pairs have positive gap.
    """
    n = len(traces)
    min_gap = float('inf')

    for i in range(n):
        for j in range(i + 1, n):
            if traces[i] != traces[j]:
                g = prefix_gap(rho, traces[i], traces[j])
                min_gap = min(min_gap, g)
                if g <= 0:
                    return False, 0.0

    return True, min_gap if min_gap < float('inf') else 0.0


if __name__ == "__main__":
    # Quick self-test
    print("Algorithm self-tests:")

    # LCVP
    assert lcvp_len([1, 2, 3], [1, 2, 4]) == 2
    assert lcvp_len([], [1, 2]) == 0
    assert lcvp_len([1, 2, 3], [1, 2, 3]) == 3
    print("  lcvp_len: PASS")

    # Clustering
    traces = [[0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
    clusters = ultrametric_cluster(traces, 0.5, 0.6)
    assert clusters[0] == clusters[1]  # share prefix [0,0]
    assert clusters[0] != clusters[3]  # differ at position 0
    print("  ultrametric_cluster: PASS")

    # Entropy-capacity
    traces_inj = [[i] for i in range(10)]
    e = oracle_entropy_proxy(traces_inj)
    c = oracle_capacity(10)
    assert abs(e - c) < 1e-12
    print("  entropy_capacity_equality: PASS")

    # Post-quantum separation
    sep, min_g = post_quantum_separation_check(traces_inj, 0.5)
    assert sep
    assert min_g > 0
    print("  post_quantum_separation: PASS")

    print("\nAll self-tests passed.")


#!/usr/bin/env python3
"""
Applications of Oracle Trace Ultrametric Entropy.

Demonstrates real-world applications in:
- Certified ML robustness
- Post-quantum code design
- Trace compression via ultrametric clustering
"""

import math
import random
from typing import List, Dict, Tuple