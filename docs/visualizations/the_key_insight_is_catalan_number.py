def catalan_number(n):
    import math
    return math.comb(2 * n, n) // (n + 1)