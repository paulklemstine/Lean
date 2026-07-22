from math import comb


def chain_cover_lower_bound(n: int) -> int:
    """Return C(n, floor(n/2)), the minimum number of chains covering B_n."""
    return comb(n, n // 2)
