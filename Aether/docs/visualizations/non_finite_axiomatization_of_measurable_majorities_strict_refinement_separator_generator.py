from __future__ import annotations
from typing import FrozenSet, List, Tuple

def separator(B: int) -> Tuple[int, FrozenSet[int], List[int]]:
    """Maximal frame separating coherence-width B from width B+1.

    Returns (n, frame, witness_loop) where frame = {1} in Z/(B+1)Z has
    incoherence index exactly B+1: it admits no balanced loop of length <= B,
    but witness_loop of length B+1 sums to 0 mod (B+1).
    """
    n = B + 1
    frame: FrozenSet[int] = frozenset({1})
    witness_loop = [1] * (B + 1)
    assert sum(witness_loop) % n == 0
    return n, frame, witness_loop
