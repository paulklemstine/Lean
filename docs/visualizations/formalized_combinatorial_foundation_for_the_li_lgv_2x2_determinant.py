def lgv_2x2(n: int, d: int) -> int:
    from math import comb
    return comb(n + d, d) - comb(n, d)