def symmetric_subspace_dim(d: int, k: int) -> int:
    from math import comb
    return comb(d + k - 1, k)