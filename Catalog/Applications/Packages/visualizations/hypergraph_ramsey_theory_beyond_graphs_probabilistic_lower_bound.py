def prob_lower_bound(r, k):
    from math import comb
    target = 2 ** comb(k, r)
    n = k
    while 2 * comb(n, k) < target:
        n += 1
    return n - 1