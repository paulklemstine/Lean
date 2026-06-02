def hodge_bound(w1: int, wL: int, p: int, q: int) -> int:
    from math import comb
    return comb(w1, p) * comb(wL, q)