from typing import List, Dict, Set, Tuple, Optional
import math
from collections import defaultdict
import math
import random
from typing import List, Dict, Tuple
from algorithms import (
    lcvp_len, prefix_dist, prefix_gap,
    ultrametric_cluster, oracle_entropy_proxy, oracle_capacity,
    certified_prefix_radius, post_quantum_separation_check
)
import random
import math
from typing import List, Tuple
import math
import base64
import io

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