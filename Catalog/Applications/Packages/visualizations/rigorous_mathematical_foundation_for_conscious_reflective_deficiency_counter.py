from math import comb
def reflective_deficiency(n):
    return sum((-1)**k * comb(n, k) * n**(n-k) for k in range(n+1))