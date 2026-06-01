def count_triangles(n, m):
    from math import comb
    return 0 if m < 3 else n * comb(m, 3) * m**(n-1)