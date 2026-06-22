from __future__ import annotations
from typing import Callable

SizeFn = Callable[[int], int]


def diagonal_size(sec: SizeFn) -> SizeFn:
    """Given a candidate-top proof system T via its section sizes
    sec(t) = size of T's chosen proof of theorem t, return the diagonal size
    function t -> 2^(sec t) + 2^t. Its degree strictly exceeds T: no monotone
    polynomial blow-up of sec can dominate it, so T is not a greatest element."""
    return lambda t: 2 ** sec(t) + 2 ** t


def diagonal_escapes(sec: SizeFn, k: int, t_max: int) -> int:
    """Witness that no (sec+2)^k bound dominates the diagonal: since sec is
    bounded, find t with 2^t >= the bound, defeating any fixed exponent k."""
    bound = max((sec(t) + 2) ** k for t in range(t_max + 1))
    t = 0
    while 2 ** t < bound:
        t += 1
    return t
