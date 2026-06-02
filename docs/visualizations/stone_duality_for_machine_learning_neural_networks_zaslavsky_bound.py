def zaslavsky_bound(n, m):
    from math import comb
    return sum(comb(m, i) for i in range(min(n, m) + 1))