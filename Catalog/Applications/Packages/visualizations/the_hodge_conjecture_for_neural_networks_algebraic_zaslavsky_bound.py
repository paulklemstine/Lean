def zaslavsky_bound(w, n):
    from math import comb
    return sum(comb(w, k) for k in range(n + 1))