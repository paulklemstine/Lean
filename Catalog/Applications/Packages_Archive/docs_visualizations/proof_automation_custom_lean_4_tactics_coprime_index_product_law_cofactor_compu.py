from functools import reduce
from math import gcd
from typing import Callable, Sequence, Optional


def pairwise_coprime(indices: Sequence[int]) -> bool:
    """True iff every distinct pair of indices is coprime (O(k^2) gcd calls)."""
    n = len(indices)
    return all(
        gcd(indices[i], indices[j]) == 1
        for i in range(n)
        for j in range(i + 1, n)
    )


def coprime_product_cofactor(
    a: Callable[[int], int], indices: Sequence[int]
) -> Optional[int]:
    """For a strong divisibility sequence `a` with a(1) = 1 and pairwise-coprime
    `indices`, verify  prod_i a(g_i) | a(prod_i g_i)  and return the integer
    cofactor  a(prod g) / prod a(g).  Returns None if the precondition fails or
    divisibility does not hold (which would contradict the theorem)."""
    if a(1) != 1 or not pairwise_coprime(indices):
        return None
    prod_idx: int = reduce(lambda u, v: u * v, indices, 1)
    prod_val: int = reduce(lambda u, v: u * v, (a(g) for g in indices), 1)
    target: int = a(prod_idx)
    if prod_val == 0 or target % prod_val != 0:
        return None
    return target // prod_val
