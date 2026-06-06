def counting_lower_bound(r, k):
    import math
    threshold = 2 ** math.comb(k, r)
    n = k
    while 2 * math.comb(n, k) < threshold:
        n += 1
    return n - 1