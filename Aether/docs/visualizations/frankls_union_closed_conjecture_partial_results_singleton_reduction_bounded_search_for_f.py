from itertools import combinations
from typing import FrozenSet, List, Optional, Set

Family = Set[FrozenSet[int]]


def frankl_search(n: int) -> Optional[Family]:
    """Singleton-reduction + bounded search.  Returns a counterexample family
       on {0,...,n-1} if one exists, else None (conjecture holds for Fin n)."""
    sets: List[FrozenSet[int]] = [
        frozenset(c) for r in range(n + 1) for c in combinations(range(n), r)
    ]
    for mask in range(1 << len(sets)):
        F: Family = {sets[i] for i in range(len(sets)) if mask & (1 << i)}
        if not F or not any(len(A) for A in F):
            continue
        if not all((a | b) in F for a in F for b in F):
            continue
        # singleton reduction: if {x} in F then x is abundant automatically
        if any(frozenset({x}) in F for x in range(n)):
            continue
        elems = set().union(*F)
        if not any(2 * sum(1 for A in F if x in A) >= len(F) for x in elems):
            return F
    return None
