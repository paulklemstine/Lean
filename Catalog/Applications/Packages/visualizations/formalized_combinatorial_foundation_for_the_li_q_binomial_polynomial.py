def q_binomial_poly(m, n):
    from functools import lru_cache
    @lru_cache(maxsize=None)
    def qb(i, j):
        if i == 0 or j == 0: return (1,)
        a, b = list(qb(i-1, j)), [0]*j + list(qb(i, j-1))
        r = [0] * max(len(a), len(b))
        for k in range(len(a)): r[k] += a[k]
        for k in range(len(b)): r[k] += b[k]
        return tuple(r)
    return list(qb(m, n))