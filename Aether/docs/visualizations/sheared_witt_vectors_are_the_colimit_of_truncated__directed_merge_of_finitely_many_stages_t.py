from __future__ import annotations
from typing import Callable, Iterable, TypeVar

I = TypeVar("I")

def common_upper_bound(
    indices: Iterable[I],
    join: Callable[[I, I], I],
    bottom: I,
) -> I:
    """Directed-merge principle: any finite set of indices in a directed order
    has a common upper bound, obtained by folding the binary join.

    Args:
        indices: a finite iterable of indices from a directed order.
        join: binary directed join a, b |-> some c >= a, c >= b.
        bottom: an initial index below (or comparable to) all others.

    Returns:
        A single index M that is an upper bound for every element of `indices`.

    Complexity: O(m) join operations for m indices.
    """
    m = bottom
    for i in indices:
        m = join(m, i)
    return m
