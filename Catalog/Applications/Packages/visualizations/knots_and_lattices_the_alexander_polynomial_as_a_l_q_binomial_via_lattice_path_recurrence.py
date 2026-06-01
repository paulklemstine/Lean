from functools import lru_cache

@lru_cache(maxsize=None)
def q_binomial(m, n):
    if m == 0 or n == 0:
        return {0: 1}
    p1 = q_binomial(m - 1, n)
    p2 = q_binomial(m, n - 1)
    result = dict(p1)
    for k, v in p2.items():
        result[k + m] = result.get(k + m, 0) + v
    return result