from __future__ import annotations
from typing import List

def support(e: int, N: int) -> List[int]:
    """All indices n in [1, N] where the prime with entry point e appears.
    By the support theorem this is exactly the multiples of e."""
    if e == 0:
        return []
    return list(range(e, N + 1, e))
