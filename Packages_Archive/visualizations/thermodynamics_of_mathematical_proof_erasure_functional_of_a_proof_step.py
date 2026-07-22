from math import log2
from typing import Callable, Hashable, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def erased_bits(f: Callable[[A], B], domain: Sequence[A]) -> float:
    """Bits erased by a step f on a finite domain: log2|domain| - log2|image f|.

    Nonnegative, and zero exactly when f is injective (logically reversible).
    """
    n: int = len(domain)
    if n == 0:
        raise ValueError("domain must be nonempty")
    image_size: int = len({f(x) for x in domain})
    return log2(n) - log2(image_size)
