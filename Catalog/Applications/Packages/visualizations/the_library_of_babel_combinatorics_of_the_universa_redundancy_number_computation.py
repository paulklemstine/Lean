def redundancy_number(A: int, L: int, r: int) -> int:
    import math
    return sum(math.comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))