from __future__ import annotations
from typing import List, Optional


def apparition_support(entry_point: Optional[int], N: int) -> List[int]:
    """
    Enumerate { n in 1..N : p | a(n) } for a strong divisibility sequence,
    GIVEN the entry point of p. By the local-to-global gluing theorem this
    set is exactly the arithmetic progression of multiples of the entry
    point, so we list e, 2e, 3e, ... <= N in O(N/e) time instead of testing
    each n.
    """
    if not entry_point:
        return []
    return list(range(entry_point, N + 1, entry_point))
