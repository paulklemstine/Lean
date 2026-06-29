from itertools import combinations
from typing import List, Tuple


def phi_mincut(weight: List[List[float]]) -> Tuple[float, Tuple[int, ...]]:
    """Compute integrated information Phi of a causal system (weighted digraph)
    as the minimum cross-information over all nontrivial bipartitions, returning
    (Phi, the Minimum Information Partition). Brute force, O(2^n * n^2)."""
    n = len(weight)
    best_val = float("inf")
    best_cut: Tuple[int, ...] = ()
    for k in range(1, n):
        for s in combinations(range(n), k):
            s_set = set(s)
            comp = [j for j in range(n) if j not in s_set]
            val = sum(weight[i][j] for i in s for j in comp)
            if val < best_val:
                best_val, best_cut = val, s
    return best_val, best_cut
