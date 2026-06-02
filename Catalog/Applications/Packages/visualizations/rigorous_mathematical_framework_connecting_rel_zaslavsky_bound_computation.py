def zaslavsky_bound(m, n):
    from math import comb
    return sum(comb(m, k) for k in range(n + 1))