from math import comb
from typing import Tuple

def kk_edge_lower_bound(triangle_count: int, n: int) -> Tuple[int, int]:
    """
    Kruskal-Katona graph bridge: given a triangle count T in a graph on n
    vertices, return (k, C(k,2)) where k is the largest k <= n with C(k,3) <= T.
    The graph is then guaranteed to have at least C(k,2) edges
    (card_edgeFinset_ge_of_triangles).

    Uses binary search over k for O(log n) binomial comparisons.
    """
    lo, hi, best = 3, n, 2
    while lo <= hi:
        mid = (lo + hi) // 2
        if comb(mid, 3) <= triangle_count:
            best = mid
            lo = mid + 1
        else:
            hi = mid - 1
    return best, comb(best, 2)
