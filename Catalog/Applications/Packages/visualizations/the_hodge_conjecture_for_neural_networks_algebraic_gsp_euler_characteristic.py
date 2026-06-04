def gsp_euler(m):
    from math import comb
    return sum((-1)**k * comb(m, k) * 2**k for k in range(m + 1))