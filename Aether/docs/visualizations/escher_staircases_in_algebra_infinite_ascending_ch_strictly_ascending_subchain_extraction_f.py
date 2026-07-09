from __future__ import annotations
from typing import Callable, List, Optional


def extract_escher_staircase(
    ideal_eq: Callable[[int, int], bool],
    start: int = 0,
    max_index: int = 10_000,
) -> List[int]:
    """
    Extract a strictly ascending subchain (an Escher staircase) from a
    non-stabilizing ascending chain J_0 ⊆ J_1 ⊆ ... .

    Parameters
    ----------
    ideal_eq : predicate with ideal_eq(a, b) == True iff J_a == J_b.
    start    : starting index n_0.
    max_index: search bound standing in for the infinite chain.

    Returns the indices n_0 < n_1 < ... of a strictly ascending subchain,
    realizing the (2 => 1) direction of the Escher Characterization.
    """
    indices: List[int] = [start]
    current = start
    while True:
        nxt: Optional[int] = None
        for m in range(current + 1, max_index):
            if not ideal_eq(current, m):  # J_current ⊊ J_m
                nxt = m
                break
        if nxt is None:
            return indices
        indices.append(nxt)
        current = nxt
