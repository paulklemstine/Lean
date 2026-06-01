def catalan_number(n: int) -> int:
    import math
    return math.comb(2 * n, n) // (n + 1)