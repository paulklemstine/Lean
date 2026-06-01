def hecke_seq(a, q, n):
    if n == 0: return 1
    if n == 1: return a
    h0, h1 = 1, a
    for _ in range(2, n + 1):
        h0, h1 = h1, a * h1 - q * h0
    return h1