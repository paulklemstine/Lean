from __future__ import annotations
from itertools import combinations, permutations
from typing import Dict, Set, Tuple

Graph = Tuple[Set[int], Dict[int, Set[int]]]


def contains_induced(host: Graph, pattern: Graph) -> bool:
    """Detect an induced copy of `pattern` in `host` by testing every injective
    vertex map for exact adjacency agreement (edges to edges, non-edges to
    non-edges). Polynomial for a fixed-size pattern: O(|V_host|^{|V_pattern|})."""
    host_verts, host_adj = host
    pat_verts, pat_adj = pattern
    pat = sorted(pat_verts)
    for image in permutations(host_verts, len(pat)):
        f = dict(zip(pat, image))
        if all((b in pat_adj[a]) == (f[b] in host_adj[f[a]])
               for a, b in combinations(pat, 2)):
            return True
    return False
