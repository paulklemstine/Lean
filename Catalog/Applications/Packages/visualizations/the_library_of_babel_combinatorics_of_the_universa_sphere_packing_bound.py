def sphere_packing_bound(A, L, min_dist):
    from math import comb
    r = (min_dist - 1) // 2
    ball = sum(comb(L, i) * (A - 1) ** i for i in range(r + 1))
    return A ** L // ball