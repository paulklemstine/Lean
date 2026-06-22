from itertools import combinations
from typing import Hashable, List, Sequence, Set, FrozenSet, Tuple

Vertex = Hashable

def is_clique(adj: Set[FrozenSet[Vertex]], s: Sequence[Vertex]) -> bool:
    """True iff every distinct pair of s is an edge."""
    return all(frozenset((u, v)) in adj for u, v in combinations(set(s), 2))

def clique_complex(vertices: Sequence[Vertex],
                   edges: Sequence[Tuple[Vertex, Vertex]]) -> Set[FrozenSet[Vertex]]:
    """Enumerate all faces of the clique complex Delta(G), level by level.

    Uses downward closure for pruning: a (k+1)-set can be a face only if every one
    of its k-subsets is already a face (apriori-style growth)."""
    adj: Set[FrozenSet[Vertex]] = {frozenset(e) for e in edges if e[0] != e[1]}
    faces: Set[FrozenSet[Vertex]] = {frozenset()}
    level: Set[FrozenSet[Vertex]] = {frozenset((v,)) for v in vertices}
    faces |= level
    k = 1
    while level:
        nxt: Set[FrozenSet[Vertex]] = set()
        for s in level:
            for v in vertices:
                if v in s:
                    continue
                cand = s | {v}
                if len(cand) != k + 1:
                    continue
                # downward-closure pruning + direct clique check
                if all((cand - {w}) in faces for w in cand) and is_clique(adj, cand):
                    nxt.add(cand)
        faces |= nxt
        level = nxt
        k += 1
    return faces
