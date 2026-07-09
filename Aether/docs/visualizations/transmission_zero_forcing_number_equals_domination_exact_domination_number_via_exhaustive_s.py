from itertools import combinations
from typing import FrozenSet, List


def dominates_path(n: int, s: FrozenSet[int]) -> bool:
    """True iff S subseteq {0,...,n-1} dominates P_n (every vertex within distance 1)."""
    if not s.issubset(range(n)):
        return False
    return all(any(abs(i - g) <= 1 for g in s) for i in range(n))


def gamma_path_bruteforce(n: int) -> int:
    """Exact domination number of P_n by exhaustive search over subset sizes.

    Iterates k = 0, 1, 2, ...; for each k enumerates all C(n, k) subsets and
    tests the domination predicate, returning the first feasible k. This is the
    ground-truth checker against the closed form ceil(n/3)."""
    if n == 0:
        return 0
    verts: List[int] = list(range(n))
    for k in range(n + 1):
        for combo in combinations(verts, k):
            if dominates_path(n, frozenset(combo)):
                return k
    return n
