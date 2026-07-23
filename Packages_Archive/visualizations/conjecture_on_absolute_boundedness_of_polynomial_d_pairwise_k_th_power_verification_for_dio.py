from itertools import combinations
from typing import Callable, List, Sequence, TypeVar

T = TypeVar("T")


def is_dio_set(members: Sequence[T],
               shifted_product_is_kth_power: Callable[[T, T], bool]) -> bool:
    """Return True iff every distinct pair yields a perfect k-th power.

    ``shifted_product_is_kth_power(a, b)`` must decide whether a*b + n is a
    perfect k-th power in the ambient ring.
    """
    return all(shifted_product_is_kth_power(a, b)
               for a, b in combinations(members, 2))
