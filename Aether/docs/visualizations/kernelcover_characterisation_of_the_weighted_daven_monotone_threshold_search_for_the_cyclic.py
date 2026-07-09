from itertools import product
from typing import Sequence

def _has_zero_sum(seq: Sequence[int], m: int) -> bool:
    reachable: set[int] = set()
    for value in seq:
        v = value % m
        nxt = {v} | {(r + v) % m for r in reachable}
        reachable |= nxt
        if 0 in reachable:
            return True
    return 0 in reachable

def davenport_constant_cyclic(m: int) -> int:
    """Least n such that every length-n sequence over Z/m has a non-empty
    zero-sum subsequence.  By the Cyclic Davenport Theorem this equals m;
    the routine locates the monotone threshold by increasing n."""
    n = 1
    while True:
        if all(_has_zero_sum(seq, m) for seq in product(range(m), repeat=n)):
            return n
        n += 1
