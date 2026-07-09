from __future__ import annotations
from typing import Callable, Sequence, TypeVar

T = TypeVar("T")

def descend_to_single_stage(
    seq: Sequence[T],
    is_basepoint: Callable[[T], bool],
    locate_stage: Callable[[T], int],
    join: Callable[[int, int], int],
) -> tuple[int, int]:
    """Descend a finitely-supported sequence over a directed union of subrings
    to a single stage.

    Args:
        seq: sampled coordinate sequence over R = union_i S_i.
        is_basepoint: predicate testing equality with the basepoint (0).
        locate_stage: returns some index i with seq[k] in S_i.
        join: directed join; returns a common upper bound of two indices.

    Returns:
        (M, N): stage M with seq[k] in S_M for all k, and level N with
        seq[k] == basepoint for all k >= N.
    """
    N = 0
    for k, x in enumerate(seq):
        if not is_basepoint(x):
            N = k + 1                      # support bound (arity colimit)
    M = 0
    for k in range(N):                     # only finitely many constraints
        M = join(M, locate_stage(seq[k]))  # merge stages (base-ring colimit)
    return M, N
