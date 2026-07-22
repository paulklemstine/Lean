from itertools import combinations
from typing import FrozenSet, Iterable, List

Subset = FrozenSet[int]

def shatters(family: Iterable[Subset], s: Subset) -> bool:
    """True iff every subset T of s appears as (member & s) for some member."""
    traces = {frozenset(m & s) for m in family}
    for size in range(len(s) + 1):
        for t in combinations(sorted(s), size):
            if frozenset(t) not in traces:
                return False
    return True

def vc_dimension(family: List[Subset], n: int) -> int:
    """Brute-force VC dimension over ground set {0, ..., n-1}."""
    best = 0
    for size in range(n + 1):
        if any(shatters(family, frozenset(c))
               for c in combinations(range(n), size)):
            best = size
    return best
