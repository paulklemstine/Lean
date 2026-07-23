from __future__ import annotations
from typing import Callable, Dict, Hashable, List

World = Hashable

def gl_rank(worlds: List[World],
            R: Callable[[World, World], bool]) -> Dict[World, int]:
    """Ordinal (here natural-number) rank of every world in a finite GL frame.

    rank w = max over successors v of (rank v + 1); dead ends have rank 0.
    Memoized recursion; well-defined since R is a strict partial order (acyclic).
    Complexity O(|worlds| + |R|) after the implicit DAG traversal.
    """
    memo: Dict[World, int] = {}

    def succ(w: World) -> List[World]:
        return [v for v in worlds if R(w, v)]

    def go(w: World) -> int:
        if w in memo:
            return memo[w]
        s = succ(w)
        memo[w] = 0 if not s else 1 + max(go(v) for v in s)
        return memo[w]

    return {w: go(w) for w in worlds}
