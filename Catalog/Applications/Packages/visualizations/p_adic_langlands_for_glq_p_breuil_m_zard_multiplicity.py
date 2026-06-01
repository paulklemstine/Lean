def bm_mult(k, a):
    if a <= (k-1)//2: return max(0, k-1-2*a)
    return 0