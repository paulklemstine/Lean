def zaslavsky(m: int, n: int) -> int:
    from math import comb
    return sum(comb(m, k) for k in range(min(m, n) + 1))