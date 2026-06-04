def probabilistic_lower_bound(k: int, r: int = 3) -> int:
    from math import comb
    target = 2 ** comb(k, r)
    n = k
    while 2 * comb(n, k) < target:
        n += 1
    return n - 1