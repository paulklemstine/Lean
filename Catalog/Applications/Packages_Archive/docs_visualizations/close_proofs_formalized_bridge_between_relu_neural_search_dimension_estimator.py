from __future__ import annotations
import math

def estimate_search_dimension(branch_counts: list[int],
                              survival_counts: list[int]) -> float:
    """Estimate the search dimension D = log k / log b from sampled nodes.

    branch_counts:   number of applicable steps observed at each sampled node
    survival_counts: number of those steps lying on some successful path
    Returns D in [0, 1]; D < 1 certifies the subcritical (genuine-search) regime.
    """
    b = sum(branch_counts) / len(branch_counts)
    k = sum(survival_counts) / len(survival_counts)
    assert b >= 2 and 1 <= k <= b
    d = math.log(k) / math.log(b)
    return max(0.0, min(1.0, d))
