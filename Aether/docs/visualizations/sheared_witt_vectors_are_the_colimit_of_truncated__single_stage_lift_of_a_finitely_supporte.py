from __future__ import annotations
from typing import Callable, Optional, Tuple

def lift_finite_support(
    stage_of: Callable[[int], int],
    support_cutoff: int,
) -> Tuple[int, bool]:
    """
    Lift a finitely supported Witt vector over a directed union of subrings to a
    single stage.

    stage_of(k):      least stage index containing coordinate k (-1 if the
                      coordinate equals the basepoint 0, which lies in every stage).
    support_cutoff N: coordinate k = 0 for all k >= N.

    Returns (i, ok) where S_i contains every coordinate and ok certifies success.
    Complexity: O(N).
    """
    nonzero = [stage_of(k) for k in range(support_cutoff)]
    i = max(nonzero + [0])
    ok = all(stage_of(k) <= i for k in range(support_cutoff))
    return i, ok
