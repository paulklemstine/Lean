from itertools import combinations
from typing import Callable, FrozenSet, List

def closure_system_closed_elements(
    universe: List[int],
    cl: Callable[[FrozenSet[int]], FrozenSet[int]],
) -> List[FrozenSet[int]]:
    """Enumerate the fixed points (closed elements) of a closure operator cl.

    A subset a is closed iff cl(a) == a. By idempotence of cl, every value
    cl(a) is closed, so the closed elements are exactly the image of cl. We
    return them in a canonical, deduplicated order.
    """
    seen: set[FrozenSet[int]] = set()
    for r in range(len(universe) + 1):
        for combo in combinations(universe, r):
            seen.add(cl(frozenset(combo)))
    return sorted(seen, key=lambda s: (len(s), sorted(s)))

def closed_lattice_ops(
    closed: List[FrozenSet[int]],
    cl: Callable[[FrozenSet[int]], FrozenSet[int]],
):
    """Return inf and sup functions for the complete lattice of closed sets.

    inf(a, b) = a & b   (ambient intersection; closed under intersection),
    sup(a, b) = cl(a | b)  (closure of the ambient union).
    """
    def inf(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        return a & b
    def sup(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        return cl(a | b)
    return inf, sup
