from math import prod
from typing import List

def unrank(bs: List[int], n: int) -> List[int]:
    """Unrank: map an index n in [0, prod(bs)) to its valid digit list.

    This is exactly mdigits restricted to the capacity range; by the master
    reconstruction law it is a bijection onto valid digit lists. For the
    factorial base bs = [2,3,...,k+1] the output is the Lehmer code of the
    n-th permutation in lexicographic order.
    """
    assert 0 <= n < prod(bs)
    out: List[int] = []
    for b in bs:
        out.append(n % b)
        n //= b
    return out

def rank(bs: List[int], ds: List[int]) -> int:
    """Rank: map a valid digit list back to its index (inverse of unrank)."""
    assert all(d < b for d, b in zip(ds, bs)) and len(ds) == len(bs)
    acc = 0
    for i in range(len(ds) - 1, -1, -1):
        acc = ds[i] + bs[i] * acc
    return acc
