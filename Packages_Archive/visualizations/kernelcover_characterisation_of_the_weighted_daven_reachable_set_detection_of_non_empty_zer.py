from typing import Sequence

def has_zero_sum_subsequence(seq: Sequence[int], m: int) -> bool:
    """Return True iff some non-empty subset of `seq` sums to 0 modulo m.

    Reachable-set dynamic program over the additive group Z/m: `reachable`
    holds all non-empty subset sums seen so far.  Runs in O(len(seq) * m)."""
    reachable: set[int] = set()
    for value in seq:
        v = value % m
        new_reachable = {v}
        for r in reachable:
            new_reachable.add((r + v) % m)
        reachable |= new_reachable
        if 0 in reachable:
            return True
    return 0 in reachable
