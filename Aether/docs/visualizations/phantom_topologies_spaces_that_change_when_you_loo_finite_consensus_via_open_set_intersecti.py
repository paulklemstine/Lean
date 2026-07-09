from itertools import chain, combinations
from typing import Callable, FrozenSet, Iterable, List

def powerset(elems: Iterable[object]) -> List[FrozenSet[object]]:
    xs = list(elems)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(xs, r) for r in range(len(xs) + 1))]

def topology_from_predicate(ground: Iterable[object],
                            is_open: Callable[[FrozenSet[object]], bool]):
    return frozenset(U for U in powerset(ground) if is_open(U))

def consensus(topologies: List[FrozenSet[FrozenSet[object]]]):
    """Consensus = supremum in the fineness order = intersection of open families."""
    if not topologies:
        raise ValueError("need at least one observer")
    result = topologies[0]
    for t in topologies[1:]:
        result = result & t
    return result
