def zaslavsky_bound(n, k):
    from math import comb
    exact = sum(comb(k, j) for j in range(min(n, k) + 1))
    upper = (k + 1) ** n
    return exact, upper