from __future__ import annotations
from typing import Dict, Iterable, List, Set, Tuple

def gl_frame_ranks(worlds: List[int],
                   edges: Iterable[Tuple[int, int]]) -> Dict[int, int]:
    """Ordinal rank of every world of a finite GL frame via memoized DFS.

    rank(w) = 0 if w is a dead end, else 1 + max rank over successors.
    Runs in O(|worlds| + |edges|) on the (acyclic) accessibility graph.
    """
    succ: Dict[int, Set[int]] = {w: set() for w in worlds}
    for a, b in edges:
        succ[a].add(b)
    memo: Dict[int, int] = {}
    def rank(w: int) -> int:
        if w in memo:
            return memo[w]
        memo[w] = 1 + max((rank(v) for v in succ[w]), default=-1)
        return memo[w]
    return {w: rank(w) for w in worlds}
