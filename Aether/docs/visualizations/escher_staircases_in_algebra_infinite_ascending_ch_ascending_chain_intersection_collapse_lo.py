from __future__ import annotations
from typing import Callable, Iterable, Set, TypeVar

T = TypeVar("T")


def ascending_intersection(
    members: Iterable[T],
    in_ideal: Callable[[T, int], bool],
    up_to: int,
) -> Set[T]:
    """
    Compute the intersection I_0 ∩ ... ∩ I_{up_to} of an ascending chain given
    by a membership oracle in_ideal(x, n). By the Loop-Back Lemma the result
    equals I_0 regardless of up_to; this routine verifies that computationally
    on any finite pool of candidate members.
    """
    pool: Set[T] = set(members)
    result: Set[T] = set(pool)
    for n in range(up_to + 1):
        result = {x for x in result if in_ideal(x, n)}
    return result
