from itertools import combinations
from typing import Sequence, Set, Tuple

def verify_fisher_hypotheses(
    family: Sequence[Set[int]], n: int, k: int, lam: int
) -> Tuple[bool, int]:
    """
    Decide whether a family of subsets of {0,...,n-1} satisfies the spectral
    Fisher hypotheses (k-uniform, constant pairwise intersection lam, 0 <= lam < k)
    and, if so, report the implied bound n on the family size.

    Returns (hypotheses_hold, bound). When hypotheses_hold is True the theorem
    guarantees len(family) <= bound (= n).
    """
    if not (0 <= lam < k):
        return (False, n)
    if any(len(A) != k for A in family):
        return (False, n)
    for A, B in combinations(family, 2):
        if len(A & B) != lam:
            return (False, n)
    return (True, n)
