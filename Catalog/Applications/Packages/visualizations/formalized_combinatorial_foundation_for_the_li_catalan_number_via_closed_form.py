def catalan(n: int) -> int:
    from math import comb
    return comb(2 * n, n) // (n + 1)