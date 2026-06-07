def probabilistic_lower_bound(k: int, r: int) -> int:
    from math import comb
    if k < r: return k
    ckr = comb(k, r)
    threshold = 2 ** ckr
    lo, hi = k, min(threshold, 10**18)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if 2 * comb(mid, k) < threshold:
            lo = mid
        else:
            hi = mid - 1
    return lo