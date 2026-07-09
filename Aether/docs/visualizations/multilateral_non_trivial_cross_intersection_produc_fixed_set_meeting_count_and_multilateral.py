from math import comb
from typing import List, Sequence


def fixed_set_meeting_count(n: int, k: int) -> int:
    """g(n,k) = C(n,k) - C(n-k,k): k-subsets of [n] meeting a fixed k-set."""
    if n < k:
        return 0
    return comb(n, k) - comb(n - k, k)


def multilateral_product_ceiling(n: int, k: int, r: int) -> int:
    """g(n,k)^r: the right-hand side of the multilateral product bound."""
    return fixed_set_meeting_count(n, k) ** r


def certify_multilateral_bound(n: int, k: int, sizes: Sequence[int]) -> bool:
    """Certify prod_i sizes[i] <= g(n,k)^r for realized family sizes (r = len(sizes))."""
    r = len(sizes)
    product = 1
    for s in sizes:
        product *= s
    return product <= multilateral_product_ceiling(n, k, r)
