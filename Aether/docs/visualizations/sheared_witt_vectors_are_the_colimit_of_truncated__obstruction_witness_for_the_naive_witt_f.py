from __future__ import annotations
from typing import Callable, Optional

def obstruction_witness(
    var_index_of: Callable[[int], int],
    stage: int,
    horizon: int,
) -> Optional[int]:
    """
    Detect that an infinite Witt vector does not lift to a given stage.

    var_index_of(k): the largest variable index used by coordinate k.
    stage i:         the candidate stage S_i = {vars <= i}.

    Returns a coordinate index k whose variables escape {0,...,i}, or None.
    For the variable vector var_index_of(k)=k, the witness for stage i is k=i+1.
    Complexity: O(horizon).
    """
    for k in range(horizon + 1):
        if var_index_of(k) > stage:
            return k
    return None
