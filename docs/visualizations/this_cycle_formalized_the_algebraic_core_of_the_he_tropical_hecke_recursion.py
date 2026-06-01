def trop_hecke_seq(a, q, n):
    if n == 0: return 0.0
    if n == 1: return float(a)
    t0, t1 = 0.0, float(a)
    for _ in range(2, n + 1):
        t0, t1 = t1, min(a + t1, q + t0)
    return t1