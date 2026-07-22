from __future__ import annotations
from math import factorial
from typing import List


def unrank_permutation(rank: int, k: int) -> List[int]:
    """Return the rank-th permutation of {0,...,k-1} in lexicographic order.

    Decodes `rank` into a Lehmer code by successive division by descending
    factorials, then rebuilds the permutation by removing the code-th remaining
    element at each step. Runs in O(k^2) without enumerating predecessors.
    """
    code: List[int] = []
    remaining: int = rank
    for position in range(k):
        f: int = factorial(k - 1 - position)
        code.append(remaining // f)
        remaining %= f
    available: List[int] = list(range(k))
    permutation: List[int] = []
    for d in code:
        permutation.append(available.pop(d))
    return permutation
