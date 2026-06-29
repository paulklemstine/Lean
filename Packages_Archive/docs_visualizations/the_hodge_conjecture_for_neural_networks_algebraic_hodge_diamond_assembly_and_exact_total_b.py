from math import comb
from typing import List, Tuple

def hodge_diamond_and_betti(w1: int, wL: int, mid: int
                            ) -> Tuple[List[List[int]], int]:
    """Return (diamond, total Betti number) for a ReLU network.

    diamond[p][q] = C(w1,p) * C(wL,q) * mid ; the total Betti number
    sum_{p,q} diamond[p][q] equals the closed form 2^{w1} * 2^{wL} * mid.
    Complexity O(w1 * wL).
    """
    diamond: List[List[int]] = [
        [comb(w1, p) * comb(wL, q) * mid for q in range(wL + 1)]
        for p in range(w1 + 1)
    ]
    total: int = sum(sum(row) for row in diamond)
    assert total == (2 ** w1) * (2 ** wL) * mid
    return diamond, total
