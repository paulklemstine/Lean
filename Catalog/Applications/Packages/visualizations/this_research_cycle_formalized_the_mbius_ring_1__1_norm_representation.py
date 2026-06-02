def norm_represent(n):
    if n % 4 in (2, -2): return None
    if n % 2 != 0:
        return ((n+1)//2, (n-1)//2)
    k = n // 4
    return (k+1, k-1)