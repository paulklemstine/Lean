from __future__ import annotations
from itertools import product as iproduct
from typing import Dict, List, Set, Tuple

def synchronized_product_ranks(
        Fw: List[int], Fs: Dict[int, Set[int]],
        Gw: List[int], Gs: Dict[int, Set[int]]) -> Dict[Tuple[int, int], int]:
    """Build the synchronized product (a step moves BOTH coordinates) and return
    its world ranks.  By the product-rank theorem each equals
    min(rank_F(a), rank_G(b)).  Time O(|Fw||Gw| + product edges)."""
    Pw: List[Tuple[int, int]] = list(iproduct(Fw, Gw))
    Ps: Dict[Tuple[int, int], Set[Tuple[int, int]]] = {
        (a, b): {(c, d) for c in Fs[a] for d in Gs[b]} for (a, b) in Pw}
    memo: Dict[Tuple[int, int], int] = {}
    def rank(w: Tuple[int, int]) -> int:
        if w in memo:
            return memo[w]
        memo[w] = 1 + max((rank(v) for v in Ps[w]), default=-1)
        return memo[w]
    return {w: rank(w) for w in Pw}
