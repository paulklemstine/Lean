def binomial_sum(n: int, d: int) -> int:
    from math import comb
    return sum(comb(n, k) for k in range(min(d, n) + 1))