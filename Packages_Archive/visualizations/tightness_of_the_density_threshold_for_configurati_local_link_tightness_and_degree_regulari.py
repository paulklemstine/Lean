from typing import FrozenSet, List, Set

Edge = FrozenSet[int]


def certify_local_tightness(n: int, r: int, edges: List[Edge]) -> dict:
    """Per-vertex link analysis: degree bound and tightness (Theorems 2-4).

    For each vertex v, compute deg(v), verify deg(v)*(r-1) <= n-1, and check
    that equality holds iff the edges through v reach every other vertex.
    Also reports degree-regularity for covering systems (Theorem 4).
    """
    degrees: List[int] = []
    bound_ok: bool = True
    tight_iff_cover: bool = True
    for v in range(n):
        link: List[Edge] = [e for e in edges if v in e]
        d: int = len(link)
        degrees.append(d)
        reached: Set[int] = set()
        for e in link:
            reached |= set(e)
        reached.discard(v)
        covers: bool = reached == (set(range(n)) - {v})
        bound_ok &= d * (r - 1) <= n - 1
        tight_iff_cover &= (d * (r - 1) == n - 1) == covers
    regular: bool = len(set(degrees)) <= 1
    return {
        "degrees": degrees,
        "local_bound_holds": bound_ok,
        "local_tightness_matches_link_cover": tight_iff_cover,
        "regular": regular,
        "expected_regular_degree": (n - 1) // (r - 1),
    }
