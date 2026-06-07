from math import comb
def zaslavsky_bound(n, w):
    return sum(comb(w, j) for j in range(min(n, w) + 1))