def compute_phi(f, n):
    if n < 2: return 0
    min_cross = n
    for bits in product([False, True], repeat=n):
        if True in bits and False in bits:
            p = lambda i, b=bits: b[i]
            cc = sum(1 for i in range(n) if p(f(i)) != p(i))
            min_cross = min(min_cross, cc)
    return min_cross