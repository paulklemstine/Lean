from math import factorial
from typing import List


def unrank_permutation(rank: int, n: int) -> List[int]:
    """Return the lexicographically rank-th permutation of {0,...,n-1}.

    Converts the rank to a factoradic (Lehmer) digit vector, then rebuilds the
    permutation by repeated selection-and-deletion from the remaining symbols.
    Requires 0 <= rank < n!. Runs in O(n^2) with a list, O(n log n) with an
    order-statistics tree.
    """
    lehmer: List[int] = []
    for i in range(n):
        f = factorial(n - 1 - i)
        lehmer.append(rank // f)
        rank %= f
    available: List[int] = list(range(n))
    perm: List[int] = []
    for code in lehmer:
        perm.append(available.pop(code))
    return perm
