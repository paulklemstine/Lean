from itertools import combinations
from typing import Dict, List, Set, Tuple

def ap_triangle_count(a_set: Set[int], n: int) -> int:
    """
    3-AP <-> triangle correspondence (the mechanism behind Roth's theorem).

    Build the tripartite graph on vertex classes X = {x_i}, Y = {y_i}, Z = {z_i}
    (each indexed by {0,...,n-1}) with edges encoding the linear forms of a 3-AP,
    so that triangles of the graph biject with 3-term APs of a_set. Here we count
    them directly. Returns the number of (a, a+d, a+2d) with d != 0 inside a_set.
    Complexity O(n^2).
    """
    aps = 0
    smax = max(a_set) if a_set else 0
    for x in a_set:
        for d in range(1, smax + 1):
            if (x + d) in a_set and (x + 2 * d) in a_set:
                aps += 1
    return aps
