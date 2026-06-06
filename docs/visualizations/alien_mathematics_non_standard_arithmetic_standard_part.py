def standard_part(f, bound, is_large, N=10000):
    for m in range(bound + 1):
        eq_set = {i for i in range(N) if f(i) == m}
        if is_large(eq_set): return m
    return None