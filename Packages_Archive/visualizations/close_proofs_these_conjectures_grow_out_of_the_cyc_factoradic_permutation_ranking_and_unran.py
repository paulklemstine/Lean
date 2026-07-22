from math import factorial
from typing import List, Sequence

def rank_permutation(perm: Sequence[int]) -> int:
    """Rank of a permutation of {0,...,n-1} via its Lehmer code, read as a
    factoradic number. Bijective onto {0, ..., n!-1}."""
    n = len(perm)
    lehmer = [sum(1 for j in range(i + 1, n) if perm[j] < perm[i])
              for i in range(n)]
    # place worth j! carries digit <= j (little-endian, reversed Lehmer code)
    code = list(reversed(lehmer))
    return sum(c * factorial(i) for i, c in enumerate(code))

def unrank_permutation(r: int, n: int) -> List[int]:
    """Inverse of rank_permutation: the r-th permutation of {0,...,n-1}."""
    code = [(r // factorial(i)) % (i + 1) for i in range(n)]
    lehmer = list(reversed(code))
    avail = list(range(n))
    perm = []
    for c in lehmer:
        perm.append(avail.pop(c))
    return perm
