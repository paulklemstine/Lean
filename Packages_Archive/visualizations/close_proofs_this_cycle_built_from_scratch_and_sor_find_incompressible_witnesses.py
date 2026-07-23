from typing import Callable, Hashable, List, Sequence

def has_short_code(encoder: Callable[[int], Hashable], n: int, k: int, x: Hashable) -> bool:
    """True iff some index i <= k (i < n) satisfies E(i) == x."""
    return any(encoder(i) == x and i <= k for i in range(n))

def find_incompressible(encoder: Callable[[int], Hashable], n: int,
                        universe: Sequence[Hashable], k: int) -> List[Hashable]:
    """Return every x in `universe` with no code of index at most k.

    By the Incompressibility Principle, if |universe| > k + 1 this list is
    nonempty; in fact it has length >= |universe| - (k + 1).
    """
    return [x for x in universe if not has_short_code(encoder, n, k, x)]
