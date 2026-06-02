def zaslavsky_bound(n: int, w: int) -> int:
    from math import comb
    return sum(comb(w, k) for k in range(min(n, w) + 1))